import 'package:audioplayers/audioplayers.dart';

/// Sound effects service for Witchat
/// Plays pre-generated WAV tones from assets/sounds/
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _enabled = true;

  bool get enabled => _enabled;
  set enabled(bool value) => _enabled = value;

  Future<void> _play(String assetPath) async {
    if (!_enabled) return;
    try {
      await _player.stop();
      await _player.play(AssetSource(assetPath));
    } catch (e) {
      // Silently fail if audio not available
    }
  }

  /// Message received: 440Hz ping, 80ms
  Future<void> playMessage() async {
    await _play('sounds/message.wav');
  }

  /// User joined: rising tone 392->523Hz
  Future<void> playJoin() async {
    await _play('sounds/join.wav');
  }

  /// User left: descending tone
  Future<void> playLeave() async {
    await _play('sounds/leave.wav');
  }

  /// Summoned: bell tone 523Hz, 400ms
  Future<void> playSummon() async {
    await _play('sounds/summon.wav');
  }

  /// Topic match: C-E-G major triad arpeggio
  Future<void> playTopic() async {
    await _play('sounds/topic.wav');
  }

  void dispose() {
    _player.dispose();
  }
}
