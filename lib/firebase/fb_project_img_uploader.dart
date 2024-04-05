import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:portfolio/utils/get_snack.dart';
import 'package:portfolio/widget/submit_button.dart';

class FbProjectImgUploader extends StatefulWidget {
  const FbProjectImgUploader({super.key});

  @override
  State<FbProjectImgUploader> createState() => _FbProjectImgUploaderState();
}

class _FbProjectImgUploaderState extends State<FbProjectImgUploader> {
  late TextEditingController _projectNameController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File? _selectedProjectImg;
  bool _isLoading = false;

  @override
  void initState() {
    _projectNameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    super.dispose();
  }

  void _pickPicture() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result == null) return;
    setState(() {
      _selectedProjectImg = File(result.files.single.path!);
    });
  }

  @override
  Widget build(context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        children: [
          Text(
            _selectedProjectImg == null
                ? 'Upload Project Image'
                : basename(_selectedProjectImg!.path),
            style: textTheme.titleLarge,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 8, right: 8),
            child: Form(
              key: _formKey,
              child: TextFormField(
                controller: _projectNameController,
                decoration: const InputDecoration(
                  label: Text('Project name'),
                  hintText: 'Project name',
                ),
                validator: (val) {
                  if (val == null || val == '') {
                    return 'Required *';
                  }
                  return null;
                },
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            height: 300,
            width: double.infinity,
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(16),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.black38, Colors.black26, Colors.black38],
              ),
            ),
            child: _selectedProjectImg == null
                ? Center(
                    child: TextButton.icon(
                      onPressed: _pickPicture,
                      icon: const Icon(
                        Icons.upload_file,
                        color: Colors.white70,
                      ),
                      label: const Text(
                        'Choose picture',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                : Stack(
                    children: [
                      Image.file(
                        _selectedProjectImg!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 300,
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: Colors.black.withAlpha(170),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton.icon(
                                onPressed: _isLoading ? null : _pickPicture,
                                icon: const Icon(Icons.upload_file),
                                label: const Text(
                                  'choose again',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          SubmitButton(
            onTap: _selectedProjectImg == null ? () {} : handelUpload,
            loading: _isLoading,
            title: "Upload",
            onLoadText: "Uploading ...",
            showDisable: _selectedProjectImg == null,
            leadingIcon: Icons.upload,
            borderRadius: BorderRadius.circular(12),
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ],
      ),
    );
  }

  void handelUpload() async {
    if (!_formKey.currentState!.validate()) {
      return;
    } else {
      _formKey.currentState!.save();
    }
    if (_selectedProjectImg == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final imgName = basename(_selectedProjectImg!.path);
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child(_projectNameController.text)
          .child(imgName);
      await storageRef.putFile(_selectedProjectImg!);
    } catch (e) {
      GetSnack.error(message: e.toString());
    }

    GetSnack.success(message: '$imgName is uploaded to Firebase.');

    _projectNameController.text = '';
    setState(() {
      _isLoading = false;
      _selectedProjectImg = null;
    });
  }
}
