import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portfolio/controller/music.dart';
import 'package:portfolio/page/music/add_music.dart';
import 'package:portfolio/page/music/controls.dart';
import 'package:portfolio/page/music/download_music.dart';
import 'package:portfolio/page/music/meta_data.dart';
import 'package:portfolio/page/music/playlist.dart';

class MusicPlayer extends GetView<MusicController> {
  const MusicPlayer({super.key});

  @override
  Widget build(context) {
    final player = controller.audioPlayer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('M u s i c  P l a y e r'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              final playingState = player.playing;
              if (playingState) player.pause();

              await showModalBottomSheet(
                context: context,
                useSafeArea: true,
                isScrollControlled: true,
                builder: (_) => const AddMusic(),
              );
              if (playingState) player.play();
            },
            icon: const Icon(Icons.playlist_add),
          ),
        ],
      ),
      endDrawer: controller.playList.isNotEmpty ? const Playlist() : null,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (controller.playList.isEmpty)
                const DownloadMusic()
              else ...[
                MusicMetaData(player: player),
                AdvanceControls(player: player),
                const SizedBox(height: 24),
                BasicControls(player: player),
                const SizedBox(height: 32),
                Text(
                  "Swipe left to open playlist",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                  ),
                )
              ],
            ],
          ),
        ),
      ),
    );
  }
}
