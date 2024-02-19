import 'dart:io';

import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';
import 'package:portfolio/Hive/hive_user_playlist.dart';
import 'package:portfolio/models/music.dart';

const _boxName = "user-music";
const _boxId = "music";

class MusicController extends GetxController {
  final AudioPlayer audioPlayer = AudioPlayer();
  late ConcatenatingAudioSource audioSource;
  RxList<PlayListItem> playList = <PlayListItem>[].obs;
  RxBool startupState = false.obs;

  @override
  void onInit() async {
    final memoryData = await _getMusicDataFromMemory();

    if (memoryData != null) {
      if (memoryData.playlist.isNotEmpty) {
        playList.value = memoryData.playlist;
        startupState.value = memoryData.startUpState;
        audioSource = _createAudioSource(memoryData.playlist);
        await audioPlayer.setAudioSource(
          audioSource,
          initialIndex: 0,
          initialPosition: Duration.zero,
        );
        audioPlayer.setLoopMode(LoopMode.all);

        if (startupState.value) {
          audioPlayer.play();
        }
      }
    }
    super.onInit();
  }

  bool isSongExistInPlayList(String songPath) {
    final allSongsPath = [];
    for (final item in playList) {
      allSongsPath.add(item.songPath);
    }
    return allSongsPath.contains(songPath);
  }

  // when user download full playlist from web.
  Future<void> addFullPlayListInMemory(List<PlayListItem> newPlayList) async {
    playList.value = newPlayList;
    audioSource = _createAudioSource(playList);
    await audioPlayer.setAudioSource(audioSource);
    audioPlayer.setLoopMode(LoopMode.all);

    await _saveInMemory(playlist: playList, startupState: startupState.value);
  }

  // when user upload a new song.
  Future<void> addSingleSongInMemory({required PlayListItem item}) async {
    playList.add(item);
    await audioSource.add(
      AudioSource.uri(
        Uri.file(item.songPath),
        tag: MediaItem(
          id: item.songPath,
          title: item.title,
          artist: item.artist,
          extras: {"cover": item.coverImgPath},
        ),
      ),
    );
    await audioPlayer.setAudioSource(audioSource);
    audioPlayer.setLoopMode(LoopMode.all);

    await _saveInMemory(playlist: playList, startupState: startupState.value);
  }

  Future<void> changeMusicStartupState(bool state) async {
    if (state) {
      if (!audioPlayer.playing) {
        audioPlayer.play();
      }
    } else {
      audioPlayer.stop();
    }

    await _saveInMemory(playlist: playList, startupState: startupState.value);
  }

  // app working directory for music storage.
  Future<List<String>> getWorkDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final songDir = Directory('${appDir.path}/music/playlist');
    final coverDir = Directory('${appDir.path}/music/cover');
    String songDirPath, coverDirPath;

    if (await songDir.exists()) {
      songDirPath = songDir.path;
    } else {
      final newFolder = await songDir.create(recursive: true);
      songDirPath = newFolder.path;
    }
    if (await coverDir.exists()) {
      coverDirPath = coverDir.path;
    } else {
      final newFolder = await coverDir.create(recursive: true);
      coverDirPath = newFolder.path;
    }

    return [songDirPath, coverDirPath];
  }
}

/* 
.................
    private
.................
*/

ConcatenatingAudioSource _createAudioSource(List<PlayListItem> playlist) {
  final List<AudioSource> audioSources = [];

  for (final item in playlist) {
    audioSources.add(
      AudioSource.uri(
        Uri.file(item.songPath),
        tag: MediaItem(
          id: item.songPath,
          title: item.title,
          artist: item.artist,
          extras: {"cover": item.coverImgPath},
        ),
      ),
    );
  }

  return ConcatenatingAudioSource(
    children: audioSources,
    shuffleOrder: DefaultShuffleOrder(),
    useLazyPreparation: true,
  );
}

Future<MusicModel?> _getMusicDataFromMemory() async {
  final box = await Hive.openBox<HiveUserPlaylist>(_boxName);
  final data = box.get(_boxId);

  if (data != null) {
    final List<PlayListItem> playlist = [];
    for (int i = 0; i < data.artistName.length; i++) {
      playlist.add(
        PlayListItem(
          artist: data.artistName[i],
          coverImgPath: data.coverImgPath[i],
          title: data.title[i],
          songPath: data.songPath[i],
        ),
      );
    }

    await box.close();
    return MusicModel(
      playlist: playlist,
      startUpState: data.musicStartupState,
    );
  } else {
    await box.close();
    return null;
  }
}

Future<void> _saveInMemory({
  required List<PlayListItem> playlist,
  required bool startupState,
}) async {
  final List<String> artistNames = [];
  final List<String> coverImgPath = [];
  final List<String> songPath = [];
  final List<String> title = [];

  for (final item in playlist) {
    artistNames.add(item.artist);
    coverImgPath.add(item.coverImgPath);
    songPath.add(item.songPath);
    title.add(item.title);
  }

  final box = await Hive.openBox<HiveUserPlaylist>(_boxName);
  await box.put(
    _boxId,
    HiveUserPlaylist(
      artistName: artistNames,
      coverImgPath: coverImgPath,
      songPath: songPath,
      title: title,
      musicStartupState: startupState,
    ),
  );
  await box.close();
}
