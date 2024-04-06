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
              final itemCount = storageData!.allDirectories.length;
              final List<Color> colors = [];
              final rem = itemCount % _colors.length;
              final newCount = itemCount - rem;

              for (int i = 0; i <= newCount; i += 5) colors.addAll(_colors);
              for (int j = 0; j < rem; j++) colors.add(_colors[j]);

              return GridView.builder(
                itemCount: itemCount,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 16 / 10,
                ),
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final currentDirName = storageData.allDirectories[index];

                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FbStorageItems(root: currentDirName),
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: colors[index],
                      ),
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        color: Colors.black38,
                        height: 40,
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          currentDirName,
                          style: textTheme.titleMedium,
                        ),
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

final List<Color> _colors = [
  Colors.tealAccent,
  Colors.lightBlue,
  Colors.pink,
  Colors.lightGreen,
  Colors.amber,
  Colors.red,
  Colors.orange,
  Colors.blue,
  Colors.green,
  Colors.indigoAccent,
];
