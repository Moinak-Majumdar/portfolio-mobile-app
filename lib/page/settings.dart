import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:portfolio/controller/db.dart';
import 'package:portfolio/controller/music.dart';
import 'package:portfolio/controller/profile_img.dart';
import 'package:portfolio/widget/neumorphism.dart';
import 'package:portfolio/widget/profile_img_changer.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('S e t t i n g s'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(
          () {
            final mc = Get.put(MusicController());
            final dc = Get.put(DbController());
            final pc = Get.put(ProfileImgController());

            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                NeuListTile(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      useSafeArea: true,
                      builder: (ctx) => const ProfileImgChanger(),
                    );
                  },
                  title: Text(
                    'Change Profile',
                    style: textTheme.titleMedium,
                  ),
                  trailing: Container(
                    height: 32,
                    width: 32,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: pc.isProfileImgAvailable.value
                        ? Image.file(
                            File(pc.profileImgPath.value),
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.account_circle_rounded, size: 32),
                  ),
                ),
                NeuBox(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  child: SwitchListTile(
                    value: mc.startupState.value,
                    onChanged: mc.playList.isNotEmpty
                        ? (value) async {
                            mc.startupState.value = value;
                            await mc.changeMusicStartupState(value);
                          }
                        : null,
                    title: Text(
                      'Startup Audio',
                      style: textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      mc.playList.isNotEmpty
                          ? 'Play music automatically when the app start.'
                          : "User playlist is unavailable, can't use startup audio.",
                      style: textTheme.labelSmall!.copyWith(
                        color: Colors.grey.shade400,
                      ),
                    ),
                    thumbIcon: _musicThumb,
                  ),
                ),
                NeuBox(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  child: CheckboxListTile(
                    value: dc.isUsingTestDb.value,
                    onChanged: (value) {
                      dc.isUsingTestDb.value = value ?? false;
                    },
                    title: Text(
                      'Using Test Db',
                      style: textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      'Switch between Mongo test db and production db.',
                      style: textTheme.labelSmall!
                          .copyWith(color: Colors.grey.shade400),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

final MaterialStateProperty<Icon?> _musicThumb =
    MaterialStateProperty.resolveWith<Icon?>(
  (Set<MaterialState> states) {
    if (states.contains(MaterialState.selected)) {
      return const Icon(Icons.volume_up);
    }
    return const Icon(Icons.volume_off);
  },
);
