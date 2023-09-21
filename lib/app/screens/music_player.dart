import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:moinak05_web_dev_dashboard/app/widgets/clip_background.dart';
import 'package:moinak05_web_dev_dashboard/provider/music.dart';
import 'package:rxdart/rxdart.dart';

class MusicPlayer extends ConsumerStatefulWidget {
  const MusicPlayer({super.key});

  @override
  ConsumerState<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends ConsumerState<MusicPlayer> {
  late AudioPlayer _player;

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _player.positionStream,
        _player.bufferedPositionStream,
        _player.durationStream,
        (position, bufferPosition, duration) => PositionData(
          bufferPosition: bufferPosition,
          duration: duration ?? Duration.zero,
          position: position,
        ),
      );

  @override
  void initState() {
    _player = ref.read(audioPlayerProvider);
    super.initState();
  }

  void init() async {}

  @override
  Widget build(context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Music player', style: GoogleFonts.pacifico()),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const ClipBackground(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                StreamBuilder<SequenceState?>(
                  stream: _player.sequenceStateStream,
                  builder: (ctx, snap) {
                    final state = snap.data;
                    if (state?.sequence.isEmpty ?? true) {
                      return const SizedBox(
                        height: 200,
                        child: Center(
                          child: Text('No Meta data'),
                        ),
                      );
                    }
                    final metaData = state!.currentSource!.tag as MediaItem;
                    return MediaMetaData(
                      artist: metaData.artist ?? '',
                      imgPath: metaData.artUri.toString(),
                      title: metaData.title,
                    );
                  },
                ),
                const SizedBox(height: 20),
                StreamBuilder<PositionData>(
                    stream: _positionDataStream,
                    builder: (ctx, snap) {
                      final positionData = snap.data;

                      return ProgressBar(
                        progress: positionData?.position ?? Duration.zero,
                        buffered: positionData?.bufferPosition ?? Duration.zero,
                        total: positionData?.duration ?? Duration.zero,
                        onSeek: _player.seek,
                        barHeight: 10,
                        baseBarColor: Colors.black26,
                        bufferedBarColor: Colors.black38,
                        thumbColor: Colors.black87,
                        progressBarColor: Colors.black87,
                        timeLabelTextStyle: textTheme.titleMedium,
                      );
                    }),
                const SizedBox(height: 10),
                const Controls(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Controls extends ConsumerWidget {
  const Controls({super.key});

  @override
  Widget build(context, ref) {
    final audioPlayer = ref.watch(audioPlayerProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        IconButton(
          onPressed: audioPlayer.seekToPrevious,
          iconSize: 45,
          icon: const Icon(Icons.skip_previous),
        ),
        StreamBuilder<PlayerState>(
            stream: audioPlayer.playerStateStream,
            builder: (cts, snap) {
              final playerState = snap.data;
              final processingState = playerState?.processingState;
              final playing = playerState?.playing;

              if (!(playing ?? false)) {
                return IconButton(
                  onPressed: audioPlayer.play,
                  iconSize: 45,
                  icon: const Icon(Icons.play_arrow),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                );
              } else if (processingState != ProcessingState.completed) {
                return IconButton(
                  onPressed: audioPlayer.pause,
                  iconSize: 45,
                  icon: const Icon(Icons.pause),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                );
              }
              return const Icon(
                Icons.play_arrow,
                size: 45,
              );
            }),
        IconButton(
          onPressed: audioPlayer.seekToNext,
          iconSize: 45,
          icon: const Icon(Icons.skip_next),
        ),
      ],
    );
  }
}

class PositionData {
  const PositionData({
    required this.bufferPosition,
    required this.duration,
    required this.position,
  });

  final Duration position, bufferPosition, duration;
}

class MediaMetaData extends StatelessWidget {
  const MediaMetaData({
    super.key,
    required this.artist,
    required this.imgPath,
    required this.title,
  });
  final String imgPath, title, artist;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      height: 400,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Colors.black,
                BlendMode.saturation,
              ),
              child: Image.asset(
                imgPath,
                height: 300,
                width: 300,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          Text(
            artist,
            style: textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
