# Witchat Mobile

Flutter mobile app for Witchat - anonymous ephemeral chat with ambient presence.

## Setup

```bash
cd mobile
flutter pub get
```

## Development

```bash
# Run on connected device/emulator
flutter run

# Run with hot reload
flutter run --hot
```

## Production Build

```bash
# Android APK
flutter build apk

# iOS
flutter build ios
```

## Architecture

- **State Management**: flutter_riverpod
- **Socket Connection**: socket_io_client
- **Theming**: Dark theme with witch/occult aesthetics

## Project Structure

```
lib/
├── main.dart           # Entry point
├── app.dart            # MaterialApp setup
├── theme/              # Colors, gradients, theme data
├── models/             # Message, Identity, Attention
├── services/           # Socket.io singleton
├── providers/          # Riverpod state providers
├── screens/            # Main chat screen
└── widgets/            # UI components
```

## Connection

Connects to production socket server:
- URL: `wss://witchat.0pon.com`
- Path: `/api/socketio`

## Features

- **The Public Cauldron**: Real-time messaging with socket.io
- **Rule of Three**: Only the newest 3 messages are fully visible; older ones dissolve into the mist
- **Mood-Synced Ambiance**: Floating particles and gradients react to the coven's mood (Calm, Neutral, Intense)
- **Physicality & Haptics**: Heavy pulses for Banishment and light taps for Speaking
- **The Vanish Timer**: A flickering amber indicator warns when a Circle is older than 20 hours and about to vanish
- **Banishment**: Long-press any message to dissolve it from your stream and block the source
- **Glass Morphism UI**: Frosted glass effect with backdrop blur
- **Anonymous or Revealed Identity**: Show or hide your handle, tag, and sigil

## Slash Commands

| Command | Description |
|---------|-------------|
| `/help` | Show all commands |
| `/clear` | Clear your stream |
| `/id` | Show your identity (color, handle, tag) |
| `/mood` | Show current atmosphere |
| `/anon` | Go anonymous |
| `/copy` | Copy latest message |
| `/whisper <msg>` | Send a quieter message |
| `/summon <color>` | Ping someone by their color |
| `/away` / `/back` | Set presence status |
| `/subscribe <topic>` | Follow a keyword |
| `/unsub <topic>` | Unfollow a topic |
| `/topics` | List your subscriptions |
| `/topic-sound on\|off` | Toggle notification sound |
| `/topic-notify on\|off` | Toggle push notifications |
