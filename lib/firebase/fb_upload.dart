import 'package:flutter/material.dart';
import 'package:portfolio/firebase/fb_photography_uploader.dart';
import 'package:portfolio/firebase/fb_project_img_uploader.dart';

class FbUpload extends StatelessWidget {
  const FbUpload({super.key});

  @override
  Widget build(context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Firebase Upload'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.camera_alt)),
              Tab(icon: Icon(Icons.laptop_windows_rounded)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            FbPhotographyUploader(),
            FbProjectImgUploader(),
          ],
        ),
      ),
    );
  }
}
