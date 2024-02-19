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

class AddProjectImage extends StatefulWidget {
  const AddProjectImage({super.key});

  @override
  State<AddProjectImage> createState() => _AddProjectImageState();
}

class _AddProjectImageState extends State<AddProjectImage> {
  ImportExport? _selectedItem;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _pnController;
  final dbc = Get.put(DbController());
  String? _errorMsg;
  bool _isLoading = false;

  @override
  void initState() {
    _pnController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _pnController.dispose();
    super.dispose();
  }

  @override
  Widget build(context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Upload Project Image"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 8, bottom: 12, left: 12, right: 12),
              child: Text(
                "Add project image to mongo database.",
                style: textTheme.titleMedium!.copyWith(
                  color: Colors.white.withAlpha(200),
                ),
              ),
            ),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: TextFormField(
                  controller: _pnController,
                  enabled: _selectedItem != null,
                  decoration: InputDecoration(
                    label: const Text('Project name'),
                    hintText: _pnController.text,
                    hintStyle: const TextStyle(color: Colors.white24),
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
            if (_errorMsg != null) ...[
              OnError(
                error: _errorMsg!,
                maxHeight: 100,
                showIcon: false,
                onReset: () {
                  setState(() {
                    _selectedItem = null;
                    _errorMsg = null;
                    _pnController.text = '';
                  });
                },
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: ElevatedButton.icon(
        onPressed: _isLoading
            ? null
            : () => openExportedProjectImgCollection(
                  context: context,
                  onImport: (item) {
                    setState(() {
                      _selectedItem = item;
                      _pnController.text = item.projectName;
                    });
                  },
                  pop: true,
                  selectedItem: _selectedItem,
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
    if (!_formKey.currentState!.validate()) {
      return;
    } else {
      _formKey.currentState!.save();
    }
    final dio = Dio();

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    final isUsingTestDb = dbc.isUsingTestDb.value;
    dio.post(
      '${dotenv.env['SERVER']!}/addProjectImg',
      queryParameters: {...dbc.apiQueryParamBase()},
      data: {
        "apiKey": dotenv.env['DB_KEY'],
        "url": _selectedItem!.url,
        "imgName": _selectedItem!.name,
        "projectName": _selectedItem!.projectName,
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
          _pnController.text = '';
        });
      }
    }).catchError((e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.badResponse && e.response != null) {
          setState(() {
            _isLoading = false;
            _errorMsg =
                'Failed with status code: ${e.response!.statusCode} \n${e.response!.data['error']}';
            _pnController.text = '';
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMsg = e.message;
            _pnController.text = '';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMsg = e.toString();
          _pnController.text = '';
        });
      }
    });
  }
}
