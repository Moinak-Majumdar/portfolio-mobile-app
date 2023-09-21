import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moinak05_web_dev_dashboard/app/screens/doc_delete.dart';
import 'package:moinak05_web_dev_dashboard/app/screens/doc_details.dart';
import 'package:moinak05_web_dev_dashboard/app/screens/doc_update.dart';
import 'package:moinak05_web_dev_dashboard/models/doc.dart';

class DocRoute2 extends StatelessWidget {
  const DocRoute2({super.key, required this.docData, this.pageIndex = 0});
  final DocSchema docData;
  final int pageIndex;

  @override
  Widget build(context) {
    return DefaultTabController(
      length: 3,
      initialIndex: pageIndex,
      child: Scaffold(
        body: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (ctx, scroll) => [
            SliverAppBar(
              pinned: true,
              floating: true,
              snap: true,
              elevation: 0,
              scrolledUnderElevation: 0,
              title: Text(
                docData.name,
                style: GoogleFonts.pacifico(fontSize: 22),
              ),
              centerTitle: true,
              bottom: const TabBar(
                indicatorWeight: 3,
                tabs: [
                  Tab(icon: Icon(Icons.info)),
                  Tab(icon: Icon(Icons.edit)),
                  Tab(icon: Icon(Icons.delete)),
                ],
              ),
            )
          ],
          body: TabBarView(
            children: [
              DocDetails(docData: docData),
              DocUpdate(docData: docData),
              DocDelete(docData: docData)
            ],
          ),
        ),
      ),
    );
  }
}
