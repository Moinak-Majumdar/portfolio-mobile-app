import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:portfolio/controller/profile_img.dart';
import 'package:portfolio/utils/get_snack.dart';

class ProfileImgChanger extends StatefulWidget {
  const ProfileImgChanger({super.key});

  @override
  State<ProfileImgChanger> createState() => _ProfileImgChangerState();
}

class _ProfileImgChangerState extends State<ProfileImgChanger> {
  File? _selectedImage;

  final pc = Get.put(ProfileImgController());

  @override
  void initState() {
    if (pc.isProfileImgAvailable.value) {
      _selectedImage = File(pc.profileImgPath.value);
    }
    super.initState();
  }

  void pickPicture() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result == null) return;
    setState(() {
      _selectedImage = File(result.files.single.path!);
    });
  }

  Future<void> handelUpload() async {
    if (_selectedImage == null) {
      return;
    }

    final imgName = basename(_selectedImage!.path);

    final appDir = await getApplicationDocumentsDirectory();
    final workDir = Directory('${appDir.path}/userProfilePic');

    if (await workDir.exists()) {
      workDir.deleteSync(recursive: true);
    }
    final newFolder = await workDir.create(recursive: true);
    final workDirPath = newFolder.path;

    final copy = await _selectedImage!.copy('$workDirPath/$imgName');

    await pc.changeProfileImg(copy.path);
  }

  @override
  Widget build(context) {
    final textTheme = Theme.of(context).textTheme;

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
                    pc.removeProfileImg().then(
                      (value) {
                        GetSnack.success(
                          message: 'Profile image is removed.',
                          icon: Icons.account_circle_rounded,
                        );
                        setState(() {
                          _selectedImage = null;
                        });
                      },
                    );
                  },
                  icon: const Icon(Icons.delete),
                  style: IconButton.styleFrom(
                    foregroundColor: Colors.red,
                    backgroundColor: Colors.red.withAlpha(40),
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
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(16),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white24, Colors.white30, Colors.white24],
              ),
            ),
            child: _selectedImage == null
                ? Center(
                    child: TextButton.icon(
                      onPressed: pickPicture,
                      icon: const Icon(
                        Icons.upload_file,
                        color: Colors.white70,
                      ),
                      label: const Text(
                        'Select Picture',
                        style: TextStyle(color: Colors.white),
                      ),
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
                                onPressed: pickPicture,
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
                                    (_) {
                                      GetSnack.success(
                                        message: 'Profile image is changed.',
                                        icon: Icons.account_circle_rounded,
                                      );
                                    },
                                  ).whenComplete(() {
                                    Navigator.pop(context);
                                  });
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
