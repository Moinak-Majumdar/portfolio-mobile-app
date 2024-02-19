import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:portfolio/widget/neumorphism.dart';
import 'package:rxdart/rxdart.dart' as rx_dart;

String _formatTime(Duration duration) {
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, "0");
  return "${duration.inMinutes}:$seconds";
}

class _PositionData {
  const _PositionData({
    required this.duration,
    required this.position,
    required this.buffered,
  });

  final Duration position, duration, buffered;
}

class AdvanceControls extends StatefulWidget {
  const AdvanceControls({super.key, required this.player});
  final AudioPlayer player;

  @override
  State<AdvanceControls> createState() => _AdvanceControlsState();
}

class _AdvanceControlsState extends State<AdvanceControls> {
  late AudioPlayer player;
  bool isRepeat = false;
  bool isShuffle = false;

  Stream<_PositionData> get positionDataStream =>
      rx_dart.CombineLatestStream<Duration?, _PositionData>(
        [
          player.positionStream,
          player.durationStream,
          player.bufferedPositionStream
        ],
        (position) => _PositionData(
          position: position[0] ?? Duration.zero,
          duration: position[1] ?? Duration.zero,
          buffered: position[2] ?? Duration.zero,
        ),
      );

  @override
  void initState() {
    player = widget.player;
    super.initState();
  }

  @override
  Widget build(context) {
    return StreamBuilder<_PositionData>(
      stream: positionDataStream,
      builder: (context, snapshot) {
        final positionData = snapshot.data;

        if (positionData == null) {
          return const SizedBox(
            height: 100,
            child: Center(
              child: Text('Stream error'),
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 50,
                    child: Text(_formatTime(positionData.position)),
                  ),
                  IconButton(
                    onPressed: () {
                      player.setShuffleModeEnabled(!isShuffle);
                      setState(() {
                        isShuffle = !isShuffle;
                      });
                    },
                    icon: Icon(
                      Icons.shuffle,
                      color: isShuffle ? Colors.green : Colors.white60,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      player.setLoopMode(
                        isRepeat ? LoopMode.all : LoopMode.one,
                      );
                      setState(() {
                        isRepeat = !isRepeat;
                      });
                    },
                    icon: Icon(
                      Icons.repeat,
                      color: isRepeat ? Colors.green : Colors.white70,
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    width: 50,
                    child: Text(_formatTime(positionData.duration)),
                  )
                ],
              ),
            ),
            Slider(
              min: 0,
              max: positionData.duration.inSeconds.toDouble(),
              value: positionData.position.inSeconds.toDouble(),
              secondaryTrackValue: positionData.buffered.inSeconds.toDouble(),
              secondaryActiveColor: Colors.white24,
              activeColor: Colors.green,
              onChanged: (value) {
                player.seek(Duration(seconds: value.toInt()));
              },
              onChangeEnd: (value) {
                player.seek(Duration(seconds: value.toInt()));
              },
            )
          ],
        );
      },
    );
  }
}

class BasicControls extends StatelessWidget {
  const BasicControls({super.key, required this.player});

  final AudioPlayer player;

  @override
  Widget build(context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          flex: 1,
          child: NeuBox(
            padding: const EdgeInsets.all(4),
            margin: const EdgeInsets.only(right: 8),
            borderRadius: 16,
            child: IconButton(
              onPressed: player.seekToPrevious,
              iconSize: 45,
              icon: const Icon(Icons.skip_previous, color: Colors.white54),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: NeuBox(
            padding: const EdgeInsets.all(4),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            borderRadius: 16,
            child: StreamBuilder<PlayerState>(
              stream: player.playerStateStream,
              builder: (cts, snap) {
                final playerState = snap.data;
                final processingState = playerState?.processingState;
                final playing = player.playing;

                if (!playing) {
                  return IconButton(
                    onPressed: player.play,
                    iconSize: 45,
                    icon: const Icon(Icons.play_arrow, color: Colors.white54),
                  );
                } else if (processingState != ProcessingState.completed) {
                  return IconButton(
                    onPressed: player.pause,
                    iconSize: 45,
                    icon: const Icon(Icons.pause, color: Colors.white54),
                  );
                }
                return const Icon(
                  Icons.play_arrow,
                  size: 45,
                );
              },
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: NeuBox(
            padding: const EdgeInsets.all(4),
            margin: const EdgeInsets.only(left: 8),
            borderRadius: 16,
            child: IconButton(
              onPressed: player.seekToNext,
              iconSize: 45,
              icon: const Icon(Icons.skip_next, color: Colors.white54),
            ),
          ),
        ),
      ],
    );
  }
}
