import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:portfolio/controller/import_export.dart';
import 'package:portfolio/models/web_project.dart';
import 'package:portfolio/utils/get_snack.dart';
import 'package:portfolio/widget/neumorphism.dart';
import 'package:portfolio/widget/project_img_selector.dart';
import 'package:portfolio/widget/submit_button.dart';
import 'package:portfolio/widget/tailwind_play_content.dart';
import 'package:portfolio/widget/tech_choice.dart';
import 'package:portfolio/manager/web_manager.dart' as web_manager;

class UpdateWeb extends StatefulWidget {
  const UpdateWeb({super.key, required this.data});

  final WebProjectModel data;

  @override
  State<UpdateWeb> createState() => _UpdateWebState();
}

class _UpdateWebState extends State<UpdateWeb> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _name;
  late TextEditingController _role;
  late TextEditingController _intro;
  late TextEditingController _liveUrl;
  late TextEditingController _gitRepo;
  late List<String> _tools;
  late String? _description;
  late bool _statusSwitch;
  late String _projectType;
  late ImportExport? _selectedCoverImg;
  late List<ImportExport> _selectedScreenshots;

  bool _isLoading = false;

  final iec = Get.put(ImportExportController());

  @override
  void initState() {
    _gitRepo = TextEditingController(text: widget.data.gitRepo);
    _intro = TextEditingController(text: widget.data.intro);
    _liveUrl = TextEditingController(text: widget.data.liveUrl);
    _role = TextEditingController(text: widget.data.role);
    _name = TextEditingController(text: widget.data.name);
    _statusSwitch = widget.data.status == "completed" ? true : false;
    _projectType = widget.data.type;
    _tools = widget.data.tools;
    _description = widget.data.description;
    _selectedCoverImg = widget.data.cover;
    _selectedScreenshots = widget.data.img;
    super.initState();
  }

  @override
  Widget build(context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('U p d a t e'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // hl3  1.name.
                    TextFormField(
                      decoration: const InputDecoration(
                        label: Text("Name"),
                        hintText: "Project / Work Name",
                        helperText: 'Unique names only !',
                      ),
                      maxLength: 20,
                      controller: _name,
                      validator: _nameValidator,
                      textCapitalization: TextCapitalization.words,
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 12),
                    // hl3 2.status.
                    NeuBox(
                      padding: const EdgeInsets.all(0),
                      margin: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 8),
                      child: CheckboxListTile(
                        value: _statusSwitch,
                        title: Text(
                          'Current status',
                          style: textTheme.titleMedium,
                        ),
                        subtitle: Text(
                          _statusSwitch ? "completed" : "under development",
                          style: textTheme.labelMedium!.copyWith(
                            color: Colors.white60,
                          ),
                        ),
                        onChanged: _isLoading
                            ? null
                            : (val) {
                                setState(() {
                                  _statusSwitch = val!;
                                });
                              },
                      ),
                    ),
                    const SizedBox(height: 12),
                    // hl3 3.Project type.
                    Row(
                      children: [
                        Expanded(
                          child: NeuBox(
                            padding: const EdgeInsets.all(0),
                            margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                            child: CheckboxListTile(
                              value: _projectType == "project",
                              onChanged: _isLoading
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _projectType = "project";
                                      });
                                    },
                              title: Text(
                                'Personal Project',
                                style: textTheme.titleSmall,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: NeuBox(
                            padding: const EdgeInsets.all(0),
                            margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                            child: CheckboxListTile(
                              value: _projectType == "work",
                              onChanged: _isLoading
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _projectType = "work";
                                      });
                                    },
                              title: Text(
                                "Client Work",
                                style: textTheme.titleSmall,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // hl3 4.role.
                    TextFormField(
                      decoration: const InputDecoration(
                        label: Text("Development Role"),
                        hintText: "eg: design , coding",
                      ),
                      maxLength: 100,
                      validator: _requiredValidator,
                      textCapitalization: TextCapitalization.sentences,
                      controller: _role,
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 12),
                    // hl3 5.Intro.
                    TextFormField(
                      decoration: const InputDecoration(
                        label: Text("Intro"),
                        hintText: "Introduction",
                      ),
                      maxLength: 100,
                      validator: _requiredValidator,
                      textCapitalization: TextCapitalization.sentences,
                      controller: _intro,
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 12),
                    // hl3 6.Live Url.
                    TextFormField(
                      decoration: const InputDecoration(
                        label: Text("Live deployment url"),
                        hintText: "https://aswomeProject.vercel.app",
                      ),
                      validator: _requiredValidator,
                      textCapitalization: TextCapitalization.sentences,
                      controller: _liveUrl,
                      keyboardType: TextInputType.url,
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 12),
                    // hl3 7.git repository.
                    TextFormField(
                      decoration: const InputDecoration(
                        label: Text("Git repository"),
                        hintText:
                            "https://github.com/Moinak-Majumdar/awesomeProject",
                      ),
                      validator: _requiredValidator,
                      textCapitalization: TextCapitalization.sentences,
                      controller: _gitRepo,
                      keyboardType: TextInputType.url,
                      enabled: !_isLoading,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // hl3 8.Tools and Technology.
              TechChoice(
                value: _tools,
                onChange: (formState) {
                  setState(() {
                    _tools = formState.value ?? [];
                  });
                },
                enabled: !_isLoading,
              ),
              // hl3 9.Project description.
              ListTile(
                title: Text(
                  'Project Description',
                  style: textTheme.titleMedium,
                ),
                subtitle: _descriptionValidator(
                  storage: iec.tailwindStorage.value,
                  local: _description,
                ),
                trailing: Icon(
                  FontAwesomeIcons.plus,
                  color: colorScheme.primary,
                ),
                onTap: _isLoading
                    ? null
                    : () => setState(() {
                          _description = iec.tailwindStorage.value;
                        }),
              ),
              if (_description != null && _description != '')
                TailwindPlayContent(content: _description!),
              const Divider(),
              // hl3 10.cover img.
              CoverImgSelector(
                selected: _selectedCoverImg,
                loading: _isLoading,
                onImport: (item) {
                  setState(() {
                    _selectedCoverImg = item;
                  });
                },
              ),
              // hl3 11.Project screenshots.
              ScreenshotsSelector(
                loading: _isLoading,
                onUpdate: (items) {
                  setState(() {
                    _selectedScreenshots = [...items];
                  });
                },
                selectedItems: _selectedScreenshots,
              ),
            ],
          ),
        ),
      ),
      // hl3 12.submit button.
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 5.0,
        clipBehavior: Clip.antiAlias,
        child: SubmitButton(
          onTap: () async {
            await _handelValidateAndUpdate();
          },
          loading: _isLoading,
          onLoadText: "Uploading to mongo ...",
          title: "Update Project",
          leadingIcon: FontAwesomeIcons.cloudArrowUp,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _handelValidateAndUpdate() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    if (_validate(
      _selectedCoverImg,
      _tools,
      _description,
      _selectedScreenshots,
    )) return;

    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    final status = _statusSwitch ? "completed" : "under development";
    final String slug = _name.text.toLowerCase().replaceAll(' ', '');
    final cover = _selectedCoverImg!;
    final List<String> toolsLogo = [];
    for (final elm in _tools) {
      toolsLogo.add('$elm.svg');
    }

    final response = await web_manager.updateWebDataAtMongo(WebProjectModel(
      id: widget.data.id,
      cover: cover,
      description: _description!,
      gitRepo: _gitRepo.text,
      intro: _intro.text,
      liveUrl: _liveUrl.text,
      name: _name.text,
      role: _role.text,
      slug: slug,
      status: status,
      type: _projectType,
      img: _selectedScreenshots,
      tools: _tools,
      toolsLogo: toolsLogo,
      v: 0,
    ));

    if (response.type == WebServerResType.success) {
      GetSnack.success(message: response.message);
    } else {
      GetSnack.error(message: response.message);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _gitRepo.dispose();
    _intro.dispose();
    _liveUrl.dispose();
    _name.dispose();
    _role.dispose();
    super.dispose();
  }
}

// validate data before upload
bool _validate(
  ImportExport? coverImg,
  List<String> tools,
  String? description,
  List<ImportExport> screenshots,
) {
  if (tools.isEmpty) {
    GetSnack.error(
      message: "At least one tech is required to build this project.",
    );
    return true;
  } else if (description == null || description == "") {
    GetSnack.error(message: "Description is missing.");
    return true;
  } else if (coverImg?.name == "") {
    GetSnack.error(message: "Cover Image is missing.");
    return true;
  } else if (screenshots.isEmpty) {
    GetSnack.error(message: "At least one screenshot image is required.");
    return true;
  } else {
    return false;
  }
}

// form validator.
String? _nameValidator(String? val) {
  if (val == null || val.trim().isEmpty) {
    return 'Required *';
  }
  if (val.length < 4) {
    return 'Name must be at least 4 characters long.';
  }
  return null;
}

String? _requiredValidator(String? val) {
  if (val == null || val.trim().isEmpty) {
    return 'Required *';
  }
  return null;
}

Widget _descriptionValidator({required String storage, String? local}) {
  if (local != null && local != "") {
    return const Text(
      'Successfully imported.',
      style: TextStyle(color: Colors.green, fontSize: 12),
    );
  } else if (storage == '') {
    return const Text(
      'Nothing to import, Export something from Tailwind Play.',
      style: TextStyle(color: Colors.red, fontSize: 12),
    );
  } else if (storage != '' && (local == null || local.trim().isEmpty)) {
    return const Text(
      'Import Tailwind play',
      style: TextStyle(color: Colors.red, fontSize: 12),
    );
  }

  return const Text("");
}
