import 'package:audioplayers/audioplayers.dart' show AudioPlayer, ReleaseMode, UrlSource;

/// Sound effect types available in the game.
enum GameSound {
  click,
  captured,
  dma,
  gameover,
  timeout,
}

/// Service class for playing game sound effects.
/// Provides a centralized way to manage and play sounds throughout the app.
class SoundService {
  // Singleton instance
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  // Audio player for playing sounds
  AudioPlayer? _player;

  // Sound file paths - just filenames since web/ is the asset folder
  static const Map<GameSound, String> _soundPaths = {
    GameSound.click: 'click.mp3',
    GameSound.captured: 'captured.mp3',
    GameSound.dma: 'dama.mp3',
    GameSound.gameover: 'gameover.mp3',
    GameSound.timeout: 'timeout.mp3',
  };

  /// Initialize the audio player
  Future<void> initialize() async {
    _player = AudioPlayer();
    await _player!.setReleaseMode(ReleaseMode.stop);
  }

  /// Play a sound effect
  Future<void> play(GameSound sound) async {
    if (_player == null) {
      _player = AudioPlayer();
    }
    
    try {
      final filename = _soundPaths[sound]!;
      // Use UrlSource for web assets - files in web/ are served from root
      await _player!.setSource(UrlSource('/$filename'));
      await _player!.resume();
    } catch (e) {
      // Log error but don't crash
      print('Sound playback error for $sound: $e');
    }
  }

  /// Play click sound (for button taps)
  Future<void> playClick() async {
    await play(GameSound.click);
  }

  /// Play captured sound (when capturing opponent chip)
  Future<void> playCaptured() async {
    await play(GameSound.captured);
  }

  /// Play Dama promotion sound
  Future<void> playDama() async {
    await play(GameSound.dma);
  }

  /// Play game over sound
  Future<void> playGameOver() async {
    await play(GameSound.gameover);
  }

  /// Play timeout sound (when turn timer expires)
  Future<void> playTimeout() async {
    await play(GameSound.timeout);
  }

  /// Dispose the audio player
  Future<void> dispose() async {
    await _player?.dispose();
    _player = null;
  }
}
