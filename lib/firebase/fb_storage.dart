import 'package:flutter/material.dart';
import 'package:portfolio/firebase/fb_storage_items.dart';
import 'package:portfolio/models/fb_storage.dart';
import 'package:portfolio/utils/on_error.dart';
import 'package:portfolio/utils/on_load.dart';

class FbStorage extends StatelessWidget {
  const FbStorage({super.key});

  @override
  Widget build(context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Storage'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: FutureBuilder(
          future: fetchFbStorage(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final storageData = snapshot.data;

              return ListView.builder(
                itemCount: storageData!.allDirectories.length,
                itemBuilder: (context, index) {
                  final currentDirName = storageData.allDirectories[index];

                  return ListTile(
                    title: Text(
                      currentDirName,
                      style: textTheme.titleMedium,
                    ),
                    leading: const Icon(
                      Icons.folder,
                      size: 32,
                      color: Colors.white38,
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FbStorageItems(root: currentDirName),
                      ),
                    ),
                  );
                },
              );
            }
            if (snapshot.hasError) {
              final error = snapshot.error.toString();

              return OnError(error: error);
            }

            return const OnLoad(msg: 'Fetching firebase storage ...');
          },
        ),
      ),
    );
  }
}
