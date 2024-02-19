class PlayListItem {
  const PlayListItem({
    required this.artist,
    required this.coverImgPath,
    required this.title,
    required this.songPath,
  });

  final String songPath, title, artist, coverImgPath;
}

class MusicModel {
  const MusicModel({required this.playlist, required this.startUpState});
  final bool startUpState;
  final List<PlayListItem> playlist;
}
