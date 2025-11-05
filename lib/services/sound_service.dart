import 'package:audioplayers/audioplayers.dart';

/// Service for playing Pokemon sounds
class SoundService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isMuted = false;

  /// Play a tap sound when selecting a Pokemon
  static Future<void> playTapSound() async {
    if (_isMuted) return;
    
    try {
      // Using a soft, pleasant notification sound
      await _player.play(UrlSource(
        'https://assets.mixkit.co/active_storage/sfx/2000/2000-preview.mp3',
      ));
    } catch (e) {
      // Silently fail if sound can't be played
      print('Error playing sound: $e');
    }
  }

  /// Play a generic Pokemon sound - soft and pleasant
  static Future<void> playPokemonCry(int pokemonId) async {
    if (_isMuted) return;
    
    try {
      // Using a soft, magical sound instead of game cries
      // This sounds more like the anime/pleasant experience
      await _player.play(UrlSource(
        'https://assets.mixkit.co/active_storage/sfx/2869/2869-preview.mp3',
      ));
    } catch (e) {
      print('Error playing Pokemon sound: $e');
    }
  }

  /// Toggle mute on/off
  static void toggleMute() {
    _isMuted = !_isMuted;
  }

  /// Check if sound is muted
  static bool get isMuted => _isMuted;

  /// Dispose the audio player
  static Future<void> dispose() async {
    await _player.dispose();
  }
}
