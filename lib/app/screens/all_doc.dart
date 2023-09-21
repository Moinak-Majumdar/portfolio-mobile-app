import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moinak05_web_dev_dashboard/app/widgets/doc_card.dart';
import 'package:moinak05_web_dev_dashboard/app/widgets/loader.dart';
import 'package:moinak05_web_dev_dashboard/app/widgets/on_error.dart';
import 'package:moinak05_web_dev_dashboard/models/doc.dart';
import 'package:moinak05_web_dev_dashboard/provider/doc.dart';

class AllDocScreen extends ConsumerStatefulWidget {
  const AllDocScreen({super.key});

  @override
  ConsumerState<AllDocScreen> createState() => _AllProjectsState();
}

class _AllProjectsState extends ConsumerState<AllDocScreen> {
  final choices = ['All', 'Projects', 'Works'];
  late Future<DocServerSchema> _futureDoc;
  List<DocSchema>? _severDocData, _docTypeData;

  @override
  void initState() {
    _futureDoc = ref.read(docProvider.notifier).getAllDoc();
    super.initState();
  }

  void changeDocType(dynamic val) {
    switch (val) {
      case 'All':
        setState(() {
          _docTypeData = _severDocData;
        });
        break;
      case 'Projects':
        setState(() {
          _docTypeData = _severDocData!
              .where((element) => element.type == 'project')
              .toList();
        });
        break;
      case 'Works':
        setState(() {
          _docTypeData = _severDocData!
              .where((element) => element.type == 'work')
              .toList();
        });
    }
  }

  @override
  Widget build(context) {
    final textTheme = Theme.of(context).textTheme;

    _severDocData = ref.watch(docProvider).allDoc;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Projects / Works',
          style: GoogleFonts.pacifico(),
        ),
        actions: [
          PopupMenuButton(
            initialValue: null,
            enabled: _severDocData != null ? true : false,
            itemBuilder: (context) {
              return choices
                  .map(
                    (e) => PopupMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: textTheme.titleLarge,
                      ),
                    ),
                  )
                  .toList();
            },
            onSelected: changeDocType,
          ),
        ],
      ),
      body: FutureBuilder(
        future: _futureDoc,
        builder: (ctx, snapshot) {
          if (snapshot.hasError) {
            return OnError(error: snapshot.error.toString());
          }

          if (snapshot.hasData) {
            if (_docTypeData == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Please choose an option from 3 dot menu.',
                    style: GoogleFonts.pacifico(fontSize: 22),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            } else {
              return ListView.builder(
                itemCount: _docTypeData!.length,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemBuilder: (ctx, index) => DocCard(
                  data: _docTypeData![index],
                ),
              );
            }
          }

          return const Loader(splash: 'Fetching all projects and works ..');
        },
      ),
    );
  }
}
