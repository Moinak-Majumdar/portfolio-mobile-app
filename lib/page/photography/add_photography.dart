import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:portfolio/controller/db.dart';
import 'package:portfolio/controller/import_export.dart';
import 'package:portfolio/utils/get_snack.dart';
import 'package:portfolio/utils/on_error.dart';
import 'package:portfolio/widget/show_selected_img.dart';
import 'package:portfolio/widget/submit_button.dart';

class AddPhotography extends StatefulWidget {
  const AddPhotography({super.key});

  @override
  State<AddPhotography> createState() => _AddPhotographyState();
}

class _AddPhotographyState extends State<AddPhotography> {
  final dbc = Get.put(DbController());

  ImportExport? _selectedItem;
  bool _isLoading = false;
  String? _errorMsg;

  @override
  Widget build(context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Photography'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                "Add photography to mongo database.",
                style: textTheme.titleMedium!.copyWith(
                  color: Colors.white.withAlpha(200),
                ),
              ),
            ),
            ShowSelectedImg(selectedItem: _selectedItem),
            SubmitButton(
              onTap: _selectedItem != null ? handelMongoUpload : null,
              loading: _isLoading,
              title: "Upload",
              leadingIcon: Icons.upload,
              onLoadText: "Uploading ...",
              showDisable: _selectedItem == null,
              borderRadius: BorderRadius.circular(12),
              margin: const EdgeInsets.all(8),
            ),
            if (_errorMsg != null)
              OnError(
                error: _errorMsg!,
                maxHeight: 200,
                showIcon: false,
                onReset: () {
                  setState(() {
                    _selectedItem = null;
                    _errorMsg = null;
                  });
                },
              ),
          ],
        ),
      ),
      floatingActionButton: ElevatedButton.icon(
        onPressed: _isLoading
            ? null
            : () => openExportedPhotographyCollection(
                  context: context,
                  onImport: (item) {
                    setState(() {
                      _selectedItem = item;
                    });
                  },
                  pop: true,
                ),
        icon: const Icon(
          FontAwesomeIcons.plus,
          size: 20,
        ),
        label: const Text("Import"),
      ),
    );
  }

  void handelMongoUpload() async {
    final dio = Dio();

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    final isUsingTestDb = dbc.isUsingTestDb.value;
    dio.post(
      '${dotenv.env['SERVER']!}/addPhotography',
      queryParameters: {...dbc.apiQueryParamBase()},
      data: {
        "apiKey": dotenv.env['DB_KEY'],
        "url": _selectedItem!.url,
        "name": _selectedItem!.name,
      },
    ).then((res) {
      if (res.statusCode == 200) {
        GetSnack.success(
          message:
              '${_selectedItem!.name} is added in mongo `${isUsingTestDb ? "test" : "production"}` database.',
          position: SnackPosition.BOTTOM,
        );
        setState(() {
          _isLoading = false;
          _selectedItem = null;
        });
      }
    }).catchError((e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.badResponse && e.response != null) {
          setState(() {
            _isLoading = false;
            _errorMsg =
                'Failed with status code: ${e.response!.statusCode} \n${e.response!.data['error']}';
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMsg = e.message;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMsg = e.toString();
        });
      }
    });
  }
}
