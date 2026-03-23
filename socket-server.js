const http = require('http');
const { Server } = require('socket.io');

const PORT = process.env.PORT || 4001;
const MAX_MESSAGES_PER_ROOM = 50;
const CIRCLE_EXPIRY_MS = 24 * 60 * 60 * 1000;
const MODERATION_DELAY_MS = 300;

const PROHIBITED_PATTERNS = [/banish-me/i];

const rooms = new Map();

const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end('Witchat Socket Server - Fixed Rigor\n');
});

const io = new Server(server, {
  path: '/api/socketio/',
  cors: { origin: "*", methods: ["GET", "POST"] }
});

function isToxic(text) {
  return PROHIBITED_PATTERNS.some(p => p.test(text));
}

io.on('connection', (socket) => {
  let currentRoom = null;
  let userColor = '#' + Math.floor(Math.random()*16777215).toString(16).padStart(6, '0');

  console.log(`Connection: ${socket.id}`);

  socket.on('join', async (data) => {
    const room = data.room || 'lobby';

    // Isolation: Leave previous room
    if (currentRoom) {
      socket.leave(currentRoom);
      console.log(`${socket.id} left ${currentRoom}`);
    }

    await socket.join(room);
    currentRoom = room;

    if (!rooms.has(room)) {
      rooms.set(room, { messages: [], lastActivity: new Date() });
    }

    socket.emit('connected', { color: userColor, room: room });

    // Precise Presence Calculation
    const roomObj = io.sockets.adapter.rooms.get(room);
    const presenceCount = roomObj ? roomObj.size : 0;
    io.to(room).emit('presence', presenceCount);

    console.log(`User ${socket.id} joined ${room}. Presence: ${presenceCount}`);
  });

  socket.on('message', (data) => {
    if (!data.text || !currentRoom) return;

    const roomData = rooms.get(currentRoom);
    if (roomData) roomData.lastActivity = new Date();

    const message = {
      id: Date.now().toString() + '-' + socket.id.substring(0, 4),
      text: data.text,
      color: userColor,
      timestamp: new Date().toISOString()
    };

    // Broadcast only to the current room
    io.to(currentRoom).emit('message', message);

    if (isToxic(data.text)) {
      setTimeout(() => {
        io.to(currentRoom).emit('vanish', { messageId: message.id });
      }, MODERATION_DELAY_MS);
    } else {
      if (roomData) {
        roomData.messages.push(message);
        if (roomData.messages.length > MAX_MESSAGES_PER_ROOM) roomData.messages.shift();
      }
    }
  });

  socket.on('disconnecting', () => {
    for (const room of socket.rooms) {
      if (room !== socket.id) {
        const roomObj = io.sockets.adapter.rooms.get(room);
        const count = roomObj ? roomObj.size - 1 : 0;
        io.to(room).emit('presence', count);
      }
    }
  });
});

server.listen(PORT, () => console.log(`Server listening on port ${PORT}`));
