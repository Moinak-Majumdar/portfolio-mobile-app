import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:portfolio/widget/neumorphism.dart';

class MusicMetaData extends StatelessWidget {
  const MusicMetaData({super.key, required this.player});
  final AudioPlayer player;

  @override
  Widget build(BuildContext context) {
    return NeuBox(
      borderRadius: 16,
      child: StreamBuilder<SequenceState?>(
        stream: player.sequenceStateStream,
        builder: (context, snapshot) {
          final state = snapshot.data;
          if (state?.sequence.isEmpty ?? true) {
            return const SizedBox(
              height: 200,
              child: Center(
                child: Text('No Meta data'),
              ),
            );
          }
          final meatData = state!.currentSource!.tag as MediaItem;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(meatData.extras!['cover']),
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 250,
                          child: Text(
                            meatData.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(meatData.artist ?? ""),
                      ],
                    ),
                    const Icon(Icons.favorite, color: Colors.red)
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
