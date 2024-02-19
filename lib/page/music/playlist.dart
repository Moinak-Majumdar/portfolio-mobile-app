import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:portfolio/controller/music.dart';

class Playlist extends StatefulWidget {
  const Playlist({super.key});

  @override
  State<Playlist> createState() => _PlaylistState();
}

class _PlaylistState extends State<Playlist> {
  final mc = Get.put(MusicController());
  late int currentSongIndex;

  @override
  void initState() {
    currentSongIndex = mc.audioPlayer.currentIndex!;
    mc.audioPlayer.currentIndexStream.listen((event) {
      setState(() => currentSongIndex = event!);
    });

    super.initState();
  }

  @override
  Widget build(context) {
    final playList = mc.playList;

    return Drawer(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.file(
            File(playList[currentSongIndex].coverImgPath),
            fit: BoxFit.cover,
            width: double.infinity,
            height: 200,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (int i = 0; i < playList.length; i++)
                    _SongListTile(
                      artist: playList[i].artist,
                      cover: playList[i].coverImgPath,
                      title: playList[i].title,
                      isActive: currentSongIndex == i,
                      onTap: () async {
                        if (currentSongIndex == i) {
                          if (mc.audioPlayer.playing) {
                            mc.audioPlayer.pause();
                          } else {
                            mc.audioPlayer.play();
                          }
                        } else {
                          await mc.audioPlayer.seek(Duration.zero, index: i);
                          if (!mc.audioPlayer.playing) {
                            mc.audioPlayer.play();
                          }
                          setState(() => currentSongIndex = i);
                        }
                      },
                      isCurrentSongPlaying:
                          mc.audioPlayer.playing && currentSongIndex == i,
                    ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _SongListTile extends StatelessWidget {
  const _SongListTile({
    required this.artist,
    required this.cover,
    required this.isActive,
    required this.title,
    required this.onTap,
    required this.isCurrentSongPlaying,
  });
  final bool isActive, isCurrentSongPlaying;
  final String cover, artist, title;
  final void Function()? onTap;

  @override
  Widget build(context) {
    return ListTile(
      trailing: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(cover),
          height: 40,
          width: 40,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: isActive ? Colors.green.shade400 : Colors.grey.shade300,
        ),
      ),
      subtitle: Text(
        artist,
        style: TextStyle(
          fontSize: 12,
          color: isActive ? Colors.green.shade700 : Colors.grey,
        ),
      ),
      leading: isActive
          ? isCurrentSongPlaying
              ? Image.asset(
                  'assets/image/songPlaying.gif',
                  height: 30,
                  width: 20,
                  fit: BoxFit.cover,
                )
              : Icon(
                  FontAwesomeIcons.circlePlay,
                  color: Colors.green.shade400,
                  size: 18,
                )
          : const Icon(
              Icons.music_note,
              size: 18,
              color: Colors.green,
            ),
      onTap: onTap,
      tileColor: isActive ? const Color.fromARGB(255, 28, 38, 28) : null,
    );
  }
}
