import 'package:flutter_test/flutter_test.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

void main() {
  group('Socket Server Tests', () {
    const String serverUrl = 'http://localhost:4001';

    test('Connection and Presence', () async {
      final socket1 = io.io(serverUrl, io.OptionBuilder()
          .setTransports(['websocket'])
          .setPath('/api/socketio/')
          .build());

      final socket2 = io.io(serverUrl, io.OptionBuilder()
          .setTransports(['websocket'])
          .setPath('/api/socketio/')
          .build());

      int presence1 = 0;
      int presence2 = 0;

      socket1.on('presence', (data) => presence1 = data as int);
      socket2.on('presence', (data) => presence2 = data as int);

      socket1.emit('join', {'room': 'test-room'});
      socket2.emit('join', {'room': 'test-room'});

      await Future.delayed(const Duration(milliseconds: 500));

      expect(presence1, 2);
      expect(presence2, 2);

      socket1.disconnect();
      socket2.disconnect();
    });

    test('Message and Vanish (Toxicity)', () async {
      final socket = io.io(serverUrl, io.OptionBuilder()
          .setTransports(['websocket'])
          .setPath('/api/socketio/')
          .build());

      String? lastMessageId;
      bool vanishReceived = false;

      socket.on('message', (data) {
        lastMessageId = data['id'] as String;
      });

      socket.on('vanish', (data) {
        if (data['messageId'] == lastMessageId) {
          vanishReceived = true;
        }
      });

      socket.emit('join', {'room': 'test-room'});
      await Future.delayed(const Duration(milliseconds: 200));

      // Send toxic message
      socket.emit('message', {'text': 'banish-me'});

      await Future.delayed(const Duration(milliseconds: 1000));

      expect(vanishReceived, isTrue);
      socket.disconnect();
    });

    test('Private Circles (Separate Instances)', () async {
      final socket1 = io.io(serverUrl, io.OptionBuilder()
          .setTransports(['websocket'])
          .setPath('/api/socketio/')
          .build());

      final socket2 = io.io(serverUrl, io.OptionBuilder()
          .setTransports(['websocket'])
          .setPath('/api/socketio/')
          .build());

      bool socket2Received = false;

      socket1.emit('join', {'room': 'circle-a'});
      socket2.emit('join', {'room': 'circle-b'});

      socket2.on('message', (_) => socket2Received = true);

      socket1.emit('message', {'text': 'Hello Circle A'});

      await Future.delayed(const Duration(milliseconds: 500));

      expect(socket2Received, isFalse, reason: 'Socket in Circle B should not receive messages from Circle A');

      socket1.disconnect();
      socket2.disconnect();
    });
  });
}
