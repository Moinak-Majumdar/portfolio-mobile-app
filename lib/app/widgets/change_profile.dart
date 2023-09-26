import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moinak05_web_dev_dashboard/app/utils/smack_msg.dart';
import 'package:moinak05_web_dev_dashboard/provider/profile_img.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class ChangeProfile extends ConsumerStatefulWidget {
  const ChangeProfile({super.key});

  @override
  ConsumerState<ChangeProfile> createState() => _ChangeProfileState();
}

class _ChangeProfileState extends ConsumerState<ChangeProfile> {
  File? _selectedImage;
  late ImagePicker _ip;
  late void Function(String msg, bool willClose) _smackMsg;

  @override
  void initState() {
    _ip = ImagePicker();
    ref.read(profileImgProvider.notifier).isProfileImgAvailable().then((value) {
      if (value != null) {
        setState(() {
          _selectedImage = value.image;
        });
      }
    });
    super.initState();
  }

  void _pickPicture(ImageSource source) async {
    XFile? pikedImage;

    pikedImage = await _ip.pickImage(source: source);

    if (pikedImage == null) {
      return;
    }
    setState(() {
      _selectedImage = File(pikedImage!.path);
    });
  }

  Future<void> handelUpload() async {
    if (_selectedImage == null) {
      return;
    }

    final imgName = basename(_selectedImage!.path);

    final appDir = await getApplicationDocumentsDirectory();
    final workDir = Directory('${appDir.path}/userData');
    String workDirPath;

    if (await workDir.exists()) {
      workDir.deleteSync(recursive: true);
    }
    final newFolder = await workDir.create(recursive: true);
    workDirPath = newFolder.path;

    final copy = await _selectedImage!.copy('$workDirPath/$imgName');

    await ref.read(profileImgProvider.notifier).addProfileImg(
          localPath: copy.path,
        );

    _smackMsg('Profile image is changed.', false);
  }

  @override
  Widget build(context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    _smackMsg = (msg, willClose) => SmackMsg(
          smack: msg,
          context: context,
          willCloseScreen: willClose,
        );

    return Padding(
      padding: const EdgeInsets.only(top: 25, right: 16, left: 16, bottom: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedImage == null
                    ? 'Profile image'
                    : 'Change profile image',
                style: textTheme.titleLarge,
              ),
              if (_selectedImage != null)
                IconButton(
                  onPressed: () {
                    ref
                        .read(profileImgProvider.notifier)
                        .removeProfileImg()
                        .then(
                      (value) {
                        _smackMsg('Profile image removed', true);
                        setState(() {
                          _selectedImage = null;
                        });
                      },
                    );
                  },
                  icon: const Icon(Icons.delete),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: colorScheme.secondaryContainer,
                  ),
                ),
            ],
          ),
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(vertical: 25),
            height: 250,
            width: MediaQuery.of(context).size.width,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(16),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.secondary,
                  colorScheme.onSurface,
                ],
              ),
            ),
            child: _selectedImage == null
                ? Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            _pickPicture(ImageSource.camera);
                          },
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.white70,
                          ),
                          label: const Text(
                            'Camera',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const Text(
                          '/',
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.white70,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            _pickPicture(ImageSource.gallery);
                          },
                          icon: const Icon(
                            Icons.photo,
                            color: Colors.white70,
                          ),
                          label: const Text(
                            'Gallery',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  )
                : Stack(
                    children: [
                      Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width,
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: Colors.black.withAlpha(230),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedImage = null;
                                  });
                                },
                                child: Text(
                                  'Change',
                                  style: textTheme.titleMedium!.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  handelUpload().then(
                                    (value) => Navigator.pop(context),
                                  );
                                },
                                child: Text(
                                  'Done',
                                  style: textTheme.titleMedium!.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
