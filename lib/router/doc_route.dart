import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moinak05_web_dev_dashboard/app/screens/doc_delete.dart';
import 'package:moinak05_web_dev_dashboard/app/screens/doc_details.dart';
import 'package:moinak05_web_dev_dashboard/app/screens/doc_update.dart';
import 'package:moinak05_web_dev_dashboard/models/doc.dart';

class DocRoute extends StatefulWidget {
  const DocRoute({super.key, required this.docData, this.pageIndex = 0});

  final DocSchema docData;
  final int pageIndex;

  @override
  State<DocRoute> createState() => _DocRouteState();
}

class _DocRouteState extends State<DocRoute> {
  int _pageIndex = 0;

  @override
  void initState() {
    _pageIndex = widget.pageIndex;
    super.initState();
  }

  void _router(int route) {
    setState(() {
      _pageIndex = route;
    });
  }

  @override
  Widget build(context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget activePage = DocDetails(docData: widget.docData);
    String pageTitle = '';

    switch (_pageIndex) {
      case 1:
        activePage = DocUpdate(docData: widget.docData);
        pageTitle = 'Update';
        break;
      case 2:
        activePage = DocDelete(docData: widget.docData);
        pageTitle = 'Delete';
        break;
      default:
        activePage = DocDetails(docData: widget.docData);
        pageTitle = 'Details';
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          pageTitle,
          style: GoogleFonts.pacifico(),
        ),
        backgroundColor: colorScheme.surface,
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      body: activePage,
      bottomNavigationBar: BottomNavigationBar(
        onTap: _router,
        currentIndex: _pageIndex,
        backgroundColor: colorScheme.surface,
        selectedItemColor: Colors.blueGrey,
        unselectedItemColor: const Color.fromARGB(255, 180, 180, 180),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Details',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'Update',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delete),
            label: 'Delete',
          ),
        ],
      ),
    );
  }
}
