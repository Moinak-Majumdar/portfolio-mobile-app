import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portfolio/controller/music.dart';
import 'package:portfolio/models/music.dart';
import 'package:portfolio/utils/get_snack.dart';
import 'package:portfolio/widget/submit_button.dart';

class DownloadMusic extends StatefulWidget {
  const DownloadMusic({super.key});

  @override
  State<DownloadMusic> createState() => _DownloadMusicState();
}

class _DownloadMusicState extends State<DownloadMusic> {
  bool isLoading = false;
  final mc = Get.put(MusicController());

  @override
  Widget build(context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Your current playlist is empty",
          style: TextStyle(fontSize: 20),
        ),
        SubmitButton(
          onTap: () async {
            handelDownload().whenComplete(() => Navigator.pop(context));
          },
          loading: isLoading,
          title: "Download Playlist",
          onLoadText: "Downloading ...",
          leadingIcon: Icons.download,
          margin: const EdgeInsets.all(32),
          borderRadius: BorderRadius.circular(32),
        ),
      ],
    );
  }

  Future<void> handelDownload() async {
    setState(() {
      isLoading = true;
    });

    try {
      final workDir = await mc.getWorkDirectory();
      final songDirPath = workDir[0], coverDirPath = workDir[1];
      final List<PlayListItem> playlist = [];

      final db = FirebaseFirestore.instance;
      final storeData = await db.collection("Music").get();

      for (final item in storeData.docs) {
        final data = item.data();
        final songRef = FirebaseStorage.instance.refFromURL(data["songUrl"]);
        final coverRef = FirebaseStorage.instance.refFromURL(data["coverUrl"]);
        final songPath = "$songDirPath/${songRef.name}";
        final coverPath = "$coverDirPath/${coverRef.name}";

        // download file from firebase.
        final song = await File(songPath).create(recursive: true);
        final downloadSong = songRef.writeToFile(song);
        downloadSong.snapshotEvents.listen((event) {
          if (event.state == TaskState.error) {
            GetSnack.error(message: 'Song download failed');
          }
        });
        final cover = await File(coverPath).create(recursive: true);
        final downloadCover = coverRef.writeToFile(cover);
        downloadCover.snapshotEvents.listen((event) {
          if (event.state == TaskState.error) {
            GetSnack.error(message: 'Song cover download failed');
          }
        });
        // creating local playlist
        playlist.add(
          PlayListItem(
            artist: data["artist"],
            coverImgPath: coverPath,
            title: data["title"],
            songPath: songPath,
          ),
        );
      }
      GetSnack.success(message: "Playlist download complete.");
      await mc.addFullPlayListInMemory(playlist);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }

    setState(() {
      isLoading = false;
    });
  }
}
