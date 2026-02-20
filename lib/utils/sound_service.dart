import 'package:audioplayers/audioplayers.dart' show AudioPlayer, ReleaseMode, UrlSource;

/// Sound effect types available in the game.
enum GameSound {
  click,
  captured,
  dma,
  gameover,
  timeout,
  music,
  timer,
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
    GameSound.music: 'music.mp3',
    GameSound.timer: 'timer.mp3',
  };

  // Separate audio player for background music (to allow looping)
  AudioPlayer? _musicPlayer;
  bool _isMusicPlaying = false;

  /// Initialize the audio player
  Future<void> initialize() async {
    _player = AudioPlayer();
    await _player!.setReleaseMode(ReleaseMode.stop);
    
    // Initialize music player
    _musicPlayer = AudioPlayer();
    await _musicPlayer!.setReleaseMode(ReleaseMode.loop);
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

  /// Play timer warning sound (when timer is <= 10 seconds)
  Future<void> playTimerWarning() async {
    await play(GameSound.timer);
  }

  /// Start background music (loops continuously)
  Future<void> startBackgroundMusic() async {
    if (_isMusicPlaying) return; // Already playing
    
    if (_musicPlayer == null) {
      _musicPlayer = AudioPlayer();
      await _musicPlayer!.setReleaseMode(ReleaseMode.loop);
    }
    
    try {
      await _musicPlayer!.setSource(UrlSource('/music.mp3'));
      await _musicPlayer!.setVolume(0.4); // Set to 40% volume for background music
      await _musicPlayer!.resume();
      _isMusicPlaying = true;
    } catch (e) {
      print('Background music playback error: $e');
    }
  }

  /// Stop background music
  Future<void> stopBackgroundMusic() async {
    if (!_isMusicPlaying) return;
    
    try {
      await _musicPlayer?.stop();
      _isMusicPlaying = false;
    } catch (e) {
      print('Error stopping background music: $e');
    }
  }

  /// Pause background music
  Future<void> pauseBackgroundMusic() async {
    if (!_isMusicPlaying) return;
    
    try {
      await _musicPlayer?.pause();
    } catch (e) {
      print('Error pausing background music: $e');
    }
  }

  /// Resume background music
  Future<void> resumeBackgroundMusic() async {
    if (_isMusicPlaying) return;
    
    try {
      await _musicPlayer?.resume();
      _isMusicPlaying = true;
    } catch (e) {
      print('Error resuming background music: $e');
    }
  }

  /// Check if background music is playing
  bool get isMusicPlaying => _isMusicPlaying;

  /// Dispose the audio player
  Future<void> dispose() async {
    await _player?.dispose();
    _player = null;
    await _musicPlayer?.dispose();
    _musicPlayer = null;
    _isMusicPlaying = false;
  }
}
