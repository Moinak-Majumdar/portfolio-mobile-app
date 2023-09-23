import 'dart:convert';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moinak05_web_dev_dashboard/provider/photography.dart';
import 'package:http/http.dart' as http;
import 'package:moinak05_web_dev_dashboard/provider/storage.dart';

class ViewPhotography extends ConsumerStatefulWidget {
  const ViewPhotography({super.key, required this.path});
  final String path;

  @override
  ConsumerState<ViewPhotography> createState() => _ViewPhotographyState();
}

class _ViewPhotographyState extends ConsumerState<ViewPhotography> {
  static final _key = GlobalKey<ExpandableFabState>();
  static final _formKey = GlobalKey<FormState>();
  late StorageOptions _isUsingStorage;

  @override
  void initState() {
    _isUsingStorage = ref.read(storageProvider);
    super.initState();
  }

  @override
  Widget build(context) {
    void smackMsg() {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.black,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          content: Text(
            'Photography Deleted ...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
      );
    }

    void handelDelete() async {
      if (!_formKey.currentState!.validate()) {
        return;
      }
      _formKey.currentState!.save();

      final imgPath = FirebaseStorage.instance.refFromURL(widget.path);

      final deleteRef = FirebaseStorage.instance.ref().child(imgPath.fullPath);
      await deleteRef.delete();

      final url = Uri.https(dotenv.env['SERVER']!, 'deletePhotography');

      final body = {
        "apiKey": dotenv.env['DB_KEY'],
        "url": widget.path,
      };

      final response = await http.post(
        url,
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        ref.read(photographyProvider.notifier).fetch();
        smackMsg();
      } else {
        throw Exception('Api Failed...');
      }
    }

    void confirmation() async {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Confirmation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: const TextSpan(
                  text: "Type confirmation message",
                  style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: " `delete this photography` ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.pink,
                      ),
                    ),
                    TextSpan(text: 'bellow.'),
                  ],
                ),
              ),
              Form(
                key: _formKey,
                child: TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'delete this photography',
                    // label: Text('Acknowledgement'),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Required *';
                    }
                    if (val != 'delete this photography') {
                      return 'Permission denied';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: handelDelete,
              child: const Text('Submit'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: _isUsingStorage == StorageOptions.offline
          ? FutureBuilder(
              future: ref.read(storageProvider.notifier).getStorageItem(
                    dir: 'photography',
                    imgName: widget.path,
                  ),
              builder: (ctx, snapshot) {
                if (snapshot.hasData) {
                  return Image.file(
                    snapshot.data!.image,
                    height: double.infinity,
                    width: double.infinity,
                    fit: BoxFit.fill,
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Image not found, To use local image make sure it was downloaded.',
                      style: GoogleFonts.pacifico(
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return Image.asset(
                  'assets/image/photography.gif',
                  height: double.infinity,
                  width: double.infinity,
                  fit: BoxFit.fill,
                );
              })
          : FadeInImage.assetNetwork(
              placeholder: 'assets/image/photography.gif',
              image: widget.path,
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.fill,
            ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        key: _key,
        children: [
          FloatingActionButton(
            onPressed: confirmation,
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
            child: const Icon(Icons.delete),
          ),
          FloatingActionButton(
            onPressed: () {},
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
            child: const Icon(Icons.download),
          ),
          FloatingActionButton(
            onPressed: () {
              Navigator.pop(context);
            },
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            child: const Icon(Icons.arrow_back),
          ),
        ],
      ),
    );
  }
}
