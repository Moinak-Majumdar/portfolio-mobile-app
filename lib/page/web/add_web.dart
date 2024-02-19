import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:portfolio/manager/web_manager.dart' as web_manager;
import 'package:portfolio/controller/import_export.dart';
import 'package:portfolio/models/web_project.dart';
import 'package:portfolio/utils/get_snack.dart';
import 'package:portfolio/utils/on_error.dart';
import 'package:portfolio/utils/on_load.dart';
import 'package:portfolio/widget/neumorphism.dart';
import 'package:portfolio/widget/project_img_selector.dart';
import 'package:portfolio/widget/submit_button.dart';
import 'package:portfolio/widget/tailwind_play_content.dart';
import 'package:portfolio/widget/tech_choice.dart';

class AddWeb extends StatefulWidget {
  const AddWeb({super.key});

  @override
  State<AddWeb> createState() => _AddWebState();
}

class _AddWebState extends State<AddWeb> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController name;
  late TextEditingController intro;
  late TextEditingController liveUrl;
  late TextEditingController gitRepo;
  late TextEditingController role;
  List<String> tools = [];
  String? description;
  bool statusSwitch = false;
  String projectType = "project";
  ImportExport? selectedCoverImg;
  List<ImportExport> selectedScreenshots = [];

  bool isLoading = false;
  bool memoryFlag = true;

  final iec = Get.put(ImportExportController());

  @override
  void initState() {
    gitRepo = TextEditingController();
    intro = TextEditingController();
    liveUrl = TextEditingController();
    role = TextEditingController();
    name = TextEditingController();
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
          title: const Text('Add Web'),
          actions: [
            IconButton(
              onPressed: _handelSave,
              icon: const Icon(FontAwesomeIcons.floppyDisk),
            ),
            IconButton(
              onPressed: _handelReset,
              icon: const Icon(
                FontAwesomeIcons.rotateLeft,
                size: 22,
              ),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: FutureBuilder(
            future: web_manager.getWebDataFromMemory(),
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
                                hintText: "Project / Work Name",
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
                            // hl3 3.Project type.
                            Row(
                              children: [
                                Expanded(
                                  child: NeuBox(
                                    padding: const EdgeInsets.all(0),
                                    margin: const EdgeInsets.fromLTRB(
                                        12, 0, 12, 16),
                                    child: CheckboxListTile(
                                      value: projectType == "project",
                                      onChanged: isLoading
                                          ? null
                                          : (value) {
                                              setState(() {
                                                projectType = "project";
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
                                    margin: const EdgeInsets.fromLTRB(
                                        12, 0, 12, 16),
                                    child: CheckboxListTile(
                                      value: projectType == "work",
                                      onChanged: isLoading
                                          ? null
                                          : (value) {
                                              setState(() {
                                                projectType = "work";
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
                              controller: role,
                              enabled: !isLoading,
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
                              controller: intro,
                              enabled: !isLoading,
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
                              controller: liveUrl,
                              keyboardType: TextInputType.url,
                              enabled: !isLoading,
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
                              controller: gitRepo,
                              keyboardType: TextInputType.url,
                              enabled: !isLoading,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      // hl3 8.Tools and Technology.
                      TechChoice(
                        value: tools,
                        onChange: (formState) {
                          setState(() {
                            tools = formState.value ?? [];
                          });
                        },
                        enabled: !isLoading,
                      ),
                      // hl3 9.Project description.
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
                      // hl3 10.cover img.
                      CoverImgSelector(
                        selected: selectedCoverImg,
                        loading: isLoading,
                        onImport: (item) {
                          setState(() {
                            selectedCoverImg = item;
                          });
                        },
                      ),
                      // hl3 11.Project screenshots.
                      ScreenshotsSelector(
                        loading: isLoading,
                        onUpdate: (items) {
                          setState(() {
                            selectedScreenshots = [...items];
                          });
                        },
                        selectedItems: selectedScreenshots,
                      ),
                    ],
                  ),
                );
              }

              return const OnLoad(msg: 'Initializing web project ...');
            },
          ),
        ),
        // hl3 12.submit button.
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
    FocusScope.of(context).unfocus();
    final status = statusSwitch ? "completed" : "under development";
    final String slug = name.text.toLowerCase().replaceAll(' ', '');
    final cover = selectedCoverImg ??
        ImportExport.projectImage(
          name: "",
          projectName: name.text,
          url: "",
        );
    await web_manager.saveWebData(
      context: context,
      onPageLeave: onPageLeave,
      data: WebProjectModel(
        id: "",
        cover: cover,
        description: description ?? "",
        gitRepo: gitRepo.text,
        intro: intro.text,
        liveUrl: liveUrl.text,
        name: name.text,
        role: role.text,
        slug: slug,
        status: status,
        type: projectType,
        img: selectedScreenshots,
        tools: tools,
        toolsLogo: tools, // tools logo is not need for saving purpose.
        v: 0,
      ),
    );
  }

  Future<void> _handelValidateAndUpload() async {
    FocusScope.of(context).unfocus();
    if (!formKey.currentState!.validate()) return;

    if (_validate(
      selectedCoverImg,
      tools,
      description,
      selectedScreenshots,
    )) return;

    formKey.currentState!.save();
    setState(() {
      isLoading = true;
    });

    final status = statusSwitch ? "completed" : "under development";
    final String slug = name.text.toLowerCase().replaceAll(' ', '');
    final cover = selectedCoverImg!;
    final List<String> toolsLogo = [];
    for (final elm in tools) {
      toolsLogo.add('$elm.svg');
    }

    final response = await web_manager.addNewWebDataToMongo(WebProjectModel(
      id: "",
      cover: cover,
      description: description ?? "",
      gitRepo: gitRepo.text,
      intro: intro.text,
      liveUrl: liveUrl.text,
      name: name.text,
      role: role.text,
      slug: slug,
      status: status,
      type: projectType,
      img: selectedScreenshots,
      tools: tools,
      toolsLogo: toolsLogo,
      v: 0,
    ));

    if (response.type == WebServerResType.success) {
      GetSnack.success(message: response.message);
    } else {
      GetSnack.error(message: response.message);
    }

    setState(() {
      isLoading = false;
    });
  }

  void _initializeMemory(WebProjectModel? data) {
    if (data != null) {
      name.text = data.name;
      description = data.description;
      gitRepo.text = data.gitRepo;
      description = data.description;
      intro.text = data.intro;
      liveUrl.text = data.liveUrl;
      tools = data.tools;
      projectType = data.type;
      role.text = data.role;
      selectedCoverImg = data.cover;
      selectedScreenshots = data.img;
      statusSwitch = data.status == "completed" ? true : false;
    }
  }

  void _handelReset() {
    web_manager.resetWebData(
      context: context,
      onReset: () {
        setState(() {
          name.text = "";
          description = "";
          gitRepo.text = "";
          description = null;
          intro.text = "";
          liveUrl.text = "";
          tools = [];
          projectType = "project";
          role.text = "";
          selectedCoverImg = const ImportExport.projectImage(
            name: "",
            projectName: "",
            url: "",
          );
          selectedScreenshots = [];
          statusSwitch = false;
        });
      },
    );
  }

  @override
  void dispose() {
    gitRepo.dispose();
    intro.dispose();
    liveUrl.dispose();
    name.dispose();
    role.dispose();
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
