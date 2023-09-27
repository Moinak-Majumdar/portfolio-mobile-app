import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moinak05_web_dev_dashboard/app/utils/smack_msg.dart';
import 'package:moinak05_web_dev_dashboard/models/photography.dart';
import 'package:moinak05_web_dev_dashboard/provider/photography.dart';
import 'package:http/http.dart' as http;
import 'package:moinak05_web_dev_dashboard/provider/storage.dart';

class ViewPhotography extends ConsumerStatefulWidget {
  const ViewPhotography({super.key, required this.details, this.path});
  const ViewPhotography.usingStorage({
    super.key,
    required this.details,
    required this.path,
  });
  final PhotographySchema details;
  final File? path;

  @override
  ConsumerState<ViewPhotography> createState() => _ViewPhotographyState();
}

class _ViewPhotographyState extends ConsumerState<ViewPhotography> {
  static final _key = GlobalKey<ExpandableFabState>();
  static final _formKey = GlobalKey<FormState>();
  late StorageOptions _isUsingStorage;
  late void Function(String msg) _showSmack;

  @override
  void initState() {
    _isUsingStorage = ref.read(storageProvider);
    super.initState();
  }

  @override
  Widget build(context) {
    _showSmack = (String msg) => SmackMsg(smack: msg, context: context);

    return Scaffold(
      body: Center(
        child: Hero(
          tag: widget.details.id,
          child: _isUsingStorage == StorageOptions.offline
              ? Image.file(
                  widget.path!,
                  height: double.infinity,
                  width: double.infinity,
                  fit: BoxFit.fill,
                )
              : CachedNetworkImage(
                  placeholder: (context, url) => Image.asset(
                    'assets/image/photography.gif',
                    height: double.infinity,
                    width: double.infinity,
                    fit: BoxFit.fill,
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Text(
                      'Failed to load image from network !',
                      style: GoogleFonts.pacifico(fontSize: 22),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  imageUrl: widget.details.url,
                  height: double.infinity,
                  width: double.infinity,
                  fit: BoxFit.fill,
                ),
        ),
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        key: _key,
        childrenOffset: Offset.fromDirection(30),
        children: [
          FloatingActionButton(
            heroTag: 'deleteBtn',
            onPressed: deleteAlert,
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
            child: const Icon(Icons.delete),
          ),
          FloatingActionButton(
            heroTag: 'downloadBtn',
            onPressed: () {},
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
            child: const Icon(Icons.download),
          ),
          FloatingActionButton(
            heroTag: 'backBtn',
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

  void handelDelete() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    final imgPath = FirebaseStorage.instance.refFromURL(widget.details.url);

    final deleteRef = FirebaseStorage.instance.ref().child(imgPath.fullPath);
    await deleteRef.delete();

    final url = Uri.https(dotenv.env['SERVER']!, 'deletePhotography');

    final body = {
      "apiKey": dotenv.env['DB_KEY'],
      "url": widget.details.url,
    };

    final response = await http.post(
      url,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      ref.read(photographyProvider.notifier).fetch();
      _showSmack('Photography Deleted ...');
    } else {
      throw Exception('Api Failed...');
    }
  }

  void deleteAlert() async {
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
            const SizedBox(height: 10),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Theme.of(context).colorScheme.secondaryContainer,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
