import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:portfolio/controller/import_export.dart';
import 'package:portfolio/models/flutter_project.dart';
import 'package:portfolio/utils/get_snack.dart';
import 'package:portfolio/utils/on_error.dart';
import 'package:portfolio/utils/on_load.dart';
import 'package:portfolio/widget/neumorphism.dart';
import 'package:portfolio/widget/project_img_selector.dart';
import 'package:portfolio/widget/submit_button.dart';
import 'package:portfolio/widget/tailwind_play_content.dart';
import 'package:portfolio/widget/tech_choice.dart';
import 'package:portfolio/manager/flutter_manager.dart' as flutter_manager;

class AddFlutter extends StatefulWidget {
  const AddFlutter({super.key});

  @override
  State<AddFlutter> createState() => _AddFlutterState();
}

class _AddFlutterState extends State<AddFlutter> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController name;
  late TextEditingController intro;
  late TextEditingController release;
  late TextEditingController gitRepo;
  late TextEditingController libraries;

  List<String> badgeNames = [];
  String? description;
  bool statusSwitch = false;
  ImportExport? selectedCoverImg;
  List<ImportExport> screenshots = [];

  bool isLoading = false;
  bool memoryFlag = true;

  final iec = Get.put(ImportExportController());

  @override
  void initState() {
    name = TextEditingController();
    intro = TextEditingController();
    release = TextEditingController();
    gitRepo = TextEditingController();
    libraries = TextEditingController();
    super.initState();
  }

  @override
  Widget build(context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return WillPopScope(
      onWillPop: () async {
        bool willLeave = false;
        await _handelSave(onPageLeave: () {
          willLeave = true;
        });
        return willLeave;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Add Flutter"),
          actions: [
            IconButton(
              onPressed: _handelSave,
              icon: const Icon(FontAwesomeIcons.floppyDisk),
            ),
            IconButton(
              onPressed: _handelReset,
              icon: const Icon(FontAwesomeIcons.rotateLeft, size: 22),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: FutureBuilder(
            future: flutter_manager.getFlutterDataFromMemory(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return OnError(error: snapshot.error.toString());
              }

              if (snapshot.hasData) {
                if (memoryFlag) {
                  _initializeMemory(snapshot.data);
                  memoryFlag = false;
                }

                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            // hl3  1.name.
                            TextFormField(
                              decoration: const InputDecoration(
                                label: Text("Name"),
                                hintText: "Project Name",
                                helperText: 'Unique names only !',
                              ),
                              maxLength: 20,
                              controller: name,
                              validator: _nameValidator,
                              textCapitalization: TextCapitalization.words,
                              enabled: !isLoading,
                            ),
                            const SizedBox(height: 12),
                            // hl3 2.status.
                            NeuBox(
                              padding: const EdgeInsets.all(0),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 8),
                              child: CheckboxListTile(
                                value: statusSwitch,
                                title: Text(
                                  'Current status',
                                  style: textTheme.titleMedium,
                                ),
                                subtitle: Text(
                                  statusSwitch
                                      ? "completed"
                                      : "under development",
                                  style: textTheme.labelMedium!.copyWith(
                                    color: Colors.white60,
                                  ),
                                ),
                                onChanged: isLoading
                                    ? null
                                    : (val) {
                                        setState(() {
                                          statusSwitch = val!;
                                        });
                                      },
                              ),
                            ),
                            const SizedBox(height: 12),
                            // hl3 3.Intro.
                            TextFormField(
                              decoration: const InputDecoration(
                                label: Text("Intro"),
                                hintText: "Introduction",
                              ),
                              maxLength: 100,
                              validator: _requiredValidator,
                              textCapitalization: TextCapitalization.sentences,
                              controller: intro,
                              enabled: !isLoading,
                            ),
                            const SizedBox(height: 12),
                            // hl3 4.Release.
                            TextFormField(
                              decoration: const InputDecoration(
                                label: Text("Github release"),
                                hintText:
                                    "https://github.com/Moinak-Majumdar/awesomeProject/release",
                              ),
                              validator: _requiredValidator,
                              textCapitalization: TextCapitalization.sentences,
                              controller: release,
                              keyboardType: TextInputType.url,
                              enabled: !isLoading,
                            ),
                            const SizedBox(height: 12),
                            // hl3 5.git repository.
                            TextFormField(
                              decoration: const InputDecoration(
                                label: Text("Git repository"),
                                hintText:
                                    "https://github.com/Moinak-Majumdar/awesomeProject",
                              ),
                              validator: _requiredValidator,
                              textCapitalization: TextCapitalization.sentences,
                              controller: gitRepo,
                              keyboardType: TextInputType.url,
                              enabled: !isLoading,
                            ),
                            const SizedBox(height: 12),
                            // hl3 6.libraries.
                            TextFormField(
                              decoration: const InputDecoration(
                                  label: Text("Libraries"),
                                  helperText: "flutter pub libraries",
                                  hintText: "get, dio, google_fonts ..."),
                              maxLines: null,
                              validator: _requiredValidator,
                              keyboardType: TextInputType.multiline,
                              textCapitalization: TextCapitalization.characters,
                              controller: libraries,
                              enabled: !isLoading,
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),

                      // hl3 7.Tools and Technology.
                      TechChoice(
                        value: badgeNames,
                        onChange: (formState) {
                          setState(() {
                            badgeNames = formState.value ?? [];
                          });
                        },
                        enabled: !isLoading,
                      ),
                      // hl3 8.Project description.
                      ListTile(
                        title: Text(
                          'Project Description',
                          style: textTheme.titleMedium,
                        ),
                        subtitle: _descriptionValidator(
                          storage: iec.tailwindStorage.value,
                          local: description,
                        ),
                        trailing: Icon(
                          FontAwesomeIcons.plus,
                          color: colorScheme.primary,
                        ),
                        onTap: isLoading
                            ? null
                            : () => setState(() {
                                  description = iec.tailwindStorage.value;
                                }),
                      ),
                      if (description != null && description != '')
                        TailwindPlayContent(content: description!),
                      const Divider(),
                      // hl3 9.cover img.
                      CoverImgSelector(
                        selected: selectedCoverImg,
                        loading: isLoading,
                        onImport: (item) {
                          setState(() {
                            selectedCoverImg = item;
                          });
                        },
                      ),
                      // hl3 9.Project screenshots.
                      ScreenshotsSelector(
                        loading: isLoading,
                        onUpdate: (items) {
                          setState(() {
                            screenshots = [...items];
                          });
                        },
                        selectedItems: screenshots,
                      ),
                    ],
                  ),
                );
              }

              return const OnLoad(msg: 'Initializing flutter project ...');
            },
          ),
        ),
        // hl3 11.submit button.
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 5.0,
          clipBehavior: Clip.antiAlias,
          child: SubmitButton(
            onTap: () async {
              await _handelValidateAndUpload();
            },
            loading: isLoading,
            onLoadText: "Uploading to mongo ...",
            title: "Upload Project",
            leadingIcon: FontAwesomeIcons.cloudArrowUp,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Future<void> _handelSave({void Function()? onPageLeave}) async {
    final status = statusSwitch ? "completed" : "under development";
    final String slug = name.text.toLowerCase().replaceAll(' ', '');
    final cover = selectedCoverImg ??
        ImportExport.projectImage(
          name: "",
          projectName: name.text,
          url: "",
        );
    await flutter_manager.saveFlutterData(
      context: context,
      onPageLeave: onPageLeave,
      data: FlutterProjectModel(
        id: "",
        cover: cover,
        description: description ?? '',
        gitRepo: gitRepo.text,
        intro: intro.text,
        name: name.text,
        release: release.text,
        slug: slug,
        status: status,
        img: screenshots,
        badge: badgeNames,
        libraries: [libraries.text].toList(),
        v: 0,
      ),
    );
  }

  Future<void> _handelValidateAndUpload() async {
    FocusScope.of(context).unfocus();
    if (!formKey.currentState!.validate()) return;

    if (_validate(
      selectedCoverImg,
      badgeNames,
      description,
      screenshots,
    )) return;

    formKey.currentState!.save();
    setState(() {
      isLoading = true;
    });

    final status = statusSwitch ? "completed" : "under development";
    final String slug = name.text.toLowerCase().replaceAll(' ', '');
    final cover = selectedCoverImg!;

    final response = await flutter_manager.addFlutterDataToMongo(
      FlutterProjectModel(
        id: "",
        cover: cover,
        description: description ?? "",
        gitRepo: gitRepo.text,
        intro: intro.text,
        release: release.text,
        name: name.text,
        slug: slug,
        status: status,
        img: screenshots,
        badge: badgeNames,
        libraries: [libraries.text].toList(),
        v: 0,
      ),
    );

    if (response.type == FlutterServerResType.success) {
      GetSnack.success(message: response.message);
    } else {
      GetSnack.error(message: response.message);
    }

    setState(() {
      isLoading = false;
    });
  }

  void _initializeMemory(FlutterProjectModel? data) {
    if (data != null) {
      final lib = data.libraries.toString();

      name.text = data.name;
      description = data.description;
      gitRepo.text = data.gitRepo;
      description = data.description;
      intro.text = data.intro;
      release.text = data.release;
      badgeNames = data.badge;
      selectedCoverImg = data.cover;
      screenshots = data.img;
      statusSwitch = data.status == "completed" ? true : false;
      libraries.text = lib.substring(1, lib.length - 1);
    }
  }

  void _handelReset() {
    flutter_manager.resetFlutterData(
      context: context,
      onReset: () {
        setState(() {
          name.text = "";
          description = "";
          gitRepo.text = "";
          description = null;
          intro.text = "";
          release.text = "";
          badgeNames = [];
          libraries.text = "";
          statusSwitch = false;
          selectedCoverImg = const ImportExport.projectImage(
            name: "",
            projectName: "",
            url: "",
          );
          screenshots = [];
        });
      },
    );
  }

  @override
  void dispose() {
    gitRepo.dispose();
    intro.dispose();
    release.dispose();
    name.dispose();
    libraries.dispose();
    super.dispose();
  }
}

// validate data before upload
bool _validate(
  ImportExport? coverImg,
  List<String> badge,
  String? description,
  List<ImportExport> screenshots,
) {
  if (badge.isEmpty) {
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
  } else if (screenshots.isNotEmpty) {
    if (screenshots[0].url == "") {
      GetSnack.error(message: "At least one screenshot image is required.");
      return true;
    }
  }
  return false;
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
