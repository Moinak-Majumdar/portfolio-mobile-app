import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart';
import 'package:portfolio/controller/music.dart';
import 'package:portfolio/models/music.dart';
import 'package:portfolio/utils/on_error.dart';
import 'package:portfolio/widget/neumorphism.dart';
import 'package:portfolio/widget/submit_button.dart';
import 'package:portfolio/utils/get_snack.dart';

class AddMusic extends StatefulWidget {
  const AddMusic({super.key});

  @override
  State<AddMusic> createState() => _AddMusicState();
}

class _AddMusicState extends State<AddMusic> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController title = TextEditingController();
  TextEditingController artist = TextEditingController();
  File? selectedCover, selectedSong;
  final testPlayer = AudioPlayer();

  String? error;

  final mc = Get.put(MusicController());

  bool isLoading = false;

  @override
  Widget build(context) {
    void pop() => Navigator.pop(context);

    return WillPopScope(
      onWillPop: () async {
        return !isLoading;
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Text(
                "A D D  T O  P L A Y L I S T",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.green.shade400,
                ),
              ),
              const SizedBox(height: 24),
              if (error != null)
                OnError(
                  error: error!,
                  maxHeight: 200,
                  onReset: () {
                    setState(() {
                      error = null;
                    });
                  },
                )
              else ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                  child: TextFormField(
                    controller: title,
                    decoration: const InputDecoration(
                      label: Text("Title"),
                      hintText: "Song name",
                    ),
                    validator: _requiredValidator,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                  child: TextFormField(
                    controller: artist,
                    decoration: const InputDecoration(
                      label: Text("Artist name"),
                    ),
                    validator: _requiredValidator,
                  ),
                ),
                _SongCoverImgPicker(
                  onCoverPick: (img) {
                    selectedCover = img;
                  },
                ),
                _SongPicker(
                  player: testPlayer,
                  onSongPick: (song) {
                    selectedSong = song;
                  },
                ),
                const SizedBox(height: 8),
                SubmitButton(
                  onTap: () async {
                    await handelSave();
                    pop();
                  },
                  loading: isLoading,
                  title: "Add to playlist",
                  borderRadius: BorderRadius.circular(8),
                  leadingIcon: Icons.playlist_add,
                  onLoadText: "Uploading song ...",
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }

  Future<void> handelSave() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedCover == null) {
      GetSnack.error(message: "Cover img is missing");
      return;
    }
    if (selectedSong == null) {
      GetSnack.error(message: "Song is missing.");
      return;
    }
    testPlayer.stop();

    formKey.currentState!.save();
    setState(() {
      isLoading = true;
    });

    try {
      final workDir = await mc.getWorkDirectory();
      final songDirPath = workDir[0], coverDirPath = workDir[1];
      // coping to app directory.
      final songName = basename(selectedSong!.path);
      final song = await selectedSong!.copy('$songDirPath/$songName');
      final coverName = basename(selectedCover!.path);
      final cover = await selectedCover!.copy("$coverDirPath/$coverName");
      // song will be downloader only if it is not exist.
      if (!mc.isSongExistInPlayList(song.path)) {
        // adding into memory
        mc.addSingleSongInMemory(
          item: PlayListItem(
            artist: artist.text,
            coverImgPath: cover.path,
            title: title.text,
            songPath: song.path,
          ),
        );
        // adding to custom firebase storage.
        final storageRef = FirebaseStorage.instanceFor(
          bucket: dotenv.get("MUSIC_STORAGE_BUCKET"),
        ).ref();
        final songRef = storageRef.child('music/playlist/$songName');
        final coverRef = storageRef.child('music/cover/$coverName');

        await songRef.putFile(selectedSong!);
        await coverRef.putFile(selectedCover!);

        // adding into firestore for future download.
        FirebaseFirestore.instance.collection("Music").doc().set({
          "title": title.text,
          "artist": artist.text,
          "songUrl": await songRef.getDownloadURL(),
          "coverUrl": await coverRef.getDownloadURL(),
        });
      } else {
        GetSnack.error(message: "Song already present in playlist.");
        setState(() {
          isLoading = false;
        });
        return;
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
      return;
    }
    setState(() {
      isLoading = false;
    });
    GetSnack.success(message: "Music added to playlist");
  }

  @override
  void dispose() {
    title.dispose();
    artist.dispose();
    testPlayer.dispose();
    super.dispose();
  }
}

// hl3 Song selector.
class _SongPicker extends StatefulWidget {
  const _SongPicker({required this.onSongPick, required this.player});
  final void Function(File song) onSongPick;
  final AudioPlayer player;

  @override
  State<_SongPicker> createState() => _SongPickerState();
}

class _SongPickerState extends State<_SongPicker> {
  File? selectedSong;
  bool isPlaying = false;

  void pickSong() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.audio);

    if (result != null) {
      setState(() => selectedSong = File(result.files.single.path!));
      if (selectedSong != null) {
        widget.player.setFilePath(selectedSong!.path);
        widget.player.play();
        widget.onSongPick(selectedSong!);
        setState(() => isPlaying = true);
      }
    } else {
      return;
    }
  }

  @override
  Widget build(context) {
    return NeuListTile(
      onTap: () {
        pickSong();
      },
      title: Text(
        "Select song",
        style: TextStyle(fontSize: 16, color: Colors.grey.shade300),
      ),
      subtitle: Text(
        selectedSong == null
            ? "No image is selected"
            : basename(selectedSong!.path),
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: ElevatedButton(
        onPressed: selectedSong == null
            ? null
            : () {
                if (widget.player.playing) {
                  widget.player.stop();
                  setState(() => isPlaying = false);
                } else {
                  widget.player.play();
                  setState(() => isPlaying = true);
                }
              },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent),
        child: isPlaying
            ? Image.asset(
                'assets/image/songPlaying.gif',
                width: 20,
                height: 30,
                fit: BoxFit.cover,
              )
            : const Icon(
                FontAwesomeIcons.circlePlay,
                size: 28,
                color: Colors.green,
              ),
      ),
    );
  }
}

// hl3 cover img selector.
class _SongCoverImgPicker extends StatefulWidget {
  const _SongCoverImgPicker({required this.onCoverPick});
  final void Function(File img) onCoverPick;

  @override
  State<_SongCoverImgPicker> createState() => _SongCoverImgPickerState();
}

class _SongCoverImgPickerState extends State<_SongCoverImgPicker> {
  File? selectedImage;

  void selectImg() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      setState(() {
        selectedImage = File(result.files.single.path!);
      });
      if (selectedImage != null) {
        widget.onCoverPick(selectedImage!);
      }
    }
  }

  @override
  Widget build(context) {
    return NeuListTile(
      onTap: () {
        selectImg();
      },
      title: Text(
        "Select song cover image",
        style: TextStyle(fontSize: 16, color: Colors.grey.shade300),
      ),
      subtitle: Text(
        selectedImage == null
            ? "No image is selected"
            : basename(selectedImage!.path),
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: Container(
        height: 40,
        width: 60,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white24,
        ),
        child: selectedImage == null
            ? null
            : Image.file(
                selectedImage!,
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}

String? _requiredValidator(String? val) {
  if (val == null || val.trim().isEmpty) {
    return 'Required *';
  }
  return null;
}
