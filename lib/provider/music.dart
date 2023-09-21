import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:moinak05_web_dev_dashboard/hive_music.dart';

const boxName = 'userMusic';
const boxId = 'startupAudio';

class AudioPlayerAutoStartupNotifier extends StateNotifier<bool> {
  AudioPlayerAutoStartupNotifier() : super(true);

  Future<bool> startupState() async {
    final box = await Hive.openBox<HiveMusic>(boxName);
    final item = box.get(boxId);

    state = item != null ? item.startupMusic : true;
    await box.close();
    return state;
  }

  Future<void> changeStartupState(bool val) async {
    final box = await Hive.openBox<HiveMusic>(boxName);
    await box.put(boxId, HiveMusic(startupMusic: val));
    await box.close();
    state = val;
  }
}

final audioPlayerAutoStartupProvider =
    StateNotifierProvider<AudioPlayerAutoStartupNotifier, bool>(
  (ref) => AudioPlayerAutoStartupNotifier(),
);

final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final audioPlayer = AudioPlayer();
  final playlist = ConcatenatingAudioSource(
    useLazyPreparation: true,
    shuffleOrder: DefaultShuffleOrder(),
    children: [
      AudioSource.asset(
        'assets/music/1.mp3',
        tag: MediaItem(
          id: '1',
          title: 'Horizon',
          artist: 'Pawel Blaszczak',
          artUri: Uri.file('assets/music/cover/1.jpg'),
        ),
      ),
      AudioSource.asset(
        'assets/music/2.mp3',
        tag: MediaItem(
          id: '2',
          title: 'TEARS',
          artist: 'HEALTH',
          artUri: Uri.file('assets/music/cover/2.jpg'),
        ),
      ),
      AudioSource.asset(
        'assets/music/3.mp3',
        tag: MediaItem(
          id: '3',
          title: 'Legend of the Eagle Bearer (Main Theme)',
          artist: 'The Flight',
          artUri: Uri.file('assets/music/cover/3.jpg'),
        ),
      ),
      AudioSource.asset(
        'assets/music/4.mp3',
        tag: MediaItem(
          id: '4',
          title: 'Outlaws From The West',
          artist: 'Woody Jackson',
          artUri: Uri.file('assets/music/cover/4.jpg'),
        ),
      ),
      AudioSource.asset(
        'assets/music/5.mp3',
        tag: MediaItem(
          id: '5',
          title: 'Adrenaline',
          artist: 'Jack Wall',
          artUri: Uri.file('assets/music/cover/5.jpg'),
        ),
      ),
      AudioSource.asset(
        'assets/music/6.mp3',
        tag: MediaItem(
          id: '6',
          title: 'No Turning Back',
          artist: 'Olivier Deriviere',
          artUri: Uri.file('assets/music/cover/6.jpg'),
        ),
      ),
    ],
  );

  audioPlayer.setAudioSource(
    playlist,
    initialIndex: 0,
    initialPosition: Duration.zero,
  );
  audioPlayer.setLoopMode(LoopMode.all);

  return audioPlayer;
});

final audioPlayerStart = Provider((ref) async {
  final audioPlayer = ref.read(audioPlayerProvider);
  final autoStat =
      await ref.read(audioPlayerAutoStartupProvider.notifier).startupState();

  if (autoStat) {
    await audioPlayer.play();
  }
});
