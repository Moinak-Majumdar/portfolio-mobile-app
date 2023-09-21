import 'dart:convert';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:moinak05_web_dev_dashboard/models/cloud.dart';
import 'package:moinak05_web_dev_dashboard/provider/cloud.dart';
import 'package:moinak05_web_dev_dashboard/provider/doc_img.dart';
import 'package:moinak05_web_dev_dashboard/provider/storage.dart';

class CloudImgCard extends ConsumerStatefulWidget {
  const CloudImgCard({super.key, required this.details});
  final CloudImgSchema details;

  @override
  ConsumerState<CloudImgCard> createState() => _CloudImgCardState();
}

class _CloudImgCardState extends ConsumerState<CloudImgCard> {
  static final _formKey = GlobalKey<FormState>();
  bool _isCopied = false;
  late bool _isUsingStorage;

  @override
  void initState() {
    _isUsingStorage = ref.read(storageProvider);
    super.initState();
  }

  void handelDelete() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    final imgPath = FirebaseStorage.instance.refFromURL(widget.details.url);

    final deleteRef = FirebaseStorage.instance.ref().child(imgPath.fullPath);
    await deleteRef.delete();

    final url = Uri.https(dotenv.env['SERVER']!, 'deleteCloudImg');

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
      ref.read(cloudProvider.notifier).fetch();
      smackMsg('Cloud Image Deleted ...', closeScreen: true);
    } else {
      throw Exception('Api Failed...');
    }
  }

  @override
  Widget build(context) {
    final textTheme = Theme.of(context).textTheme;
    ref.watch(imgProvider);
    final alreadyExported =
        ref.watch(imgProvider.notifier).present(widget.details.url);

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        color: Color.fromARGB(255, 225, 225, 225),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: _isUsingStorage
                  ? FutureBuilder(
                      future: ref.read(storageProvider.notifier).getStorageItem(
                            dir: widget.details.projectName,
                            imgName: widget.details.imgName,
                          ),
                      builder: (ctx, snapshot) {
                        if (snapshot.hasData) {
                          return Image.file(
                            snapshot.data!.image,
                            fit: BoxFit.fill,
                            height: 250,
                            width: double.infinity,
                          );
                        }

                        return Image.asset(
                          'assets/image/cloud.gif',
                          fit: BoxFit.fill,
                          height: 250,
                          width: double.infinity,
                        );
                      })
                  : FadeInImage.assetNetwork(
                      placeholder: 'assets/image/cloud.gif',
                      image: widget.details.url,
                      fit: BoxFit.fill,
                      height: 250,
                      width: double.infinity,
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  widget.details.imgName,
                  style: textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  onPressed: confirmation,
                  icon: const Icon(Icons.delete_outlined),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 200, 200, 200),
                    foregroundColor: const Color.fromARGB(255, 25, 25, 25),
                  ),
                ),
                IconButton(
                  onPressed: copyLink,
                  icon: Icon(
                    _isCopied
                        ? Icons.done_all_rounded
                        : Icons.content_copy_rounded,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 200, 200, 200),
                    foregroundColor: const Color.fromARGB(255, 25, 25, 25),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    alreadyExported ? removeExportedImg() : exportImg();
                  },
                  icon: Icon(
                    alreadyExported ? Icons.close : Icons.import_export,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 200, 200, 200),
                    foregroundColor: const Color.fromARGB(255, 25, 25, 25),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // hl1  alert confirmation to delete.
  void confirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Confirmation',
          style: TextStyle(
            color: Colors.blue[700],
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  text: 'Type associated name',
                  style: GoogleFonts.lato().copyWith(color: Colors.black),
                  children: [
                    TextSpan(
                      text: ' `${widget.details.projectName}` ',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.pink,
                      ),
                    ),
                    const TextSpan(text: 'bellow to delete '),
                    TextSpan(
                      text: widget.details.imgName,
                      style: const TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              TextFormField(
                decoration: InputDecoration(
                  // label: const Text('Associated'),
                  hintText: widget.details.projectName,
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Required *';
                  }
                  if (val != widget.details.projectName) {
                    return 'Wrong name.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              RichText(
                text: TextSpan(
                  text: "Type confirmation message",
                  style: GoogleFonts.lato().copyWith(
                    color: Colors.black,
                  ),
                  children: const [
                    TextSpan(
                      text: " `delete this image` ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.pink,
                      ),
                    ),
                    TextSpan(text: 'bellow.'),
                  ],
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  // label: Text('Acknowledgement'),
                  hintText: 'delete this image',
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Required *';
                  }
                  if (val != 'delete this image') {
                    return 'Permission denied.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: handelDelete,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey,
            ),
            child: const Text(
              'Submit',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void smackMsg(String smack, {bool closeScreen = false}) {
    if (closeScreen) {
      Navigator.of(context).pop();
    }
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black,
        padding: const EdgeInsets.all(16),
        content: Text(
          smack,
          style: GoogleFonts.ubuntu().copyWith(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  void copyLink() async {
    if (_isCopied == false) {
      Clipboard.setData(ClipboardData(text: widget.details.url));
      smackMsg('Url is copied to clipboard.');
      setState(() {
        _isCopied = true;
      });
    }
    await Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isCopied = false;
      });
    });
  }

  void exportImg() {
    ref.read(imgProvider.notifier).add(
          ExportedImgSchema(
            imgName: widget.details.imgName,
            projectName: widget.details.projectName,
            url: widget.details.url,
          ),
        );
    smackMsg('Exported: ${widget.details.imgName}');
  }

  void removeExportedImg() {
    ref.read(imgProvider.notifier).remove(widget.details.url);
    smackMsg('Removed: ${widget.details.imgName}');
  }
}
