import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:portfolio/controller/import_export.dart';
import 'package:portfolio/models/flutter_project.dart';
import 'package:portfolio/utils/get_snack.dart';
import 'package:portfolio/widget/neumorphism.dart';
import 'package:portfolio/widget/project_img_selector.dart';
import 'package:portfolio/widget/submit_button.dart';
import 'package:portfolio/widget/tailwind_play_content.dart';
import 'package:portfolio/widget/tech_choice.dart';
import 'package:portfolio/manager/flutter_manager.dart' as flutter_manager;

class UpdateFlutter extends StatefulWidget {
  const UpdateFlutter({super.key, required this.data});
  final FlutterProjectModel data;

  @override
  State<UpdateFlutter> createState() => _UpdateFlutterState();
}

class _UpdateFlutterState extends State<UpdateFlutter> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController name;
  late TextEditingController intro;
  late TextEditingController release;
  late TextEditingController gitRepo;
  late TextEditingController libraries;

  late List<String> badgeNames;
  late String? description;
  late bool statusSwitch;
  late ImportExport? selectedCoverImg;
  late List<ImportExport> screenshots;

  bool isLoading = false;

  final iec = Get.put(ImportExportController());

  @override
  void initState() {
    name = TextEditingController(text: widget.data.name);
    intro = TextEditingController(text: widget.data.intro);
    release = TextEditingController(text: widget.data.release);
    gitRepo = TextEditingController(text: widget.data.gitRepo);
    final lib = widget.data.libraries.toString();
    libraries = TextEditingController(text: lib.substring(1, lib.length - 1));
    badgeNames = widget.data.badgeNames;
    description = widget.data.description;
    selectedCoverImg = widget.data.cover;
    screenshots = widget.data.img;
    statusSwitch = widget.data.status == "completed";
    super.initState();
  }

  @override
  Widget build(context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("U p d a t e"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SingleChildScrollView(
          child: Column(
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
                          statusSwitch ? "completed" : "under development",
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
        ),
      ),
      // hl3 10. Submit button.
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 5.0,
        clipBehavior: Clip.antiAlias,
        child: SubmitButton(
          onTap: () async {
            await _handelValidateAndUpdate();
          },
          loading: isLoading,
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
    final badge = flutter_manager.badgeNameToBadge(badgeNames: badgeNames);

    final response = await flutter_manager.updateFlutterDataAtMongo(
      FlutterProjectModel(
        id: widget.data.id,
        cover: cover,
        description: description!,
        gitRepo: gitRepo.text,
        intro: intro.text,
        name: name.text,
        release: release.text,
        slug: slug,
        status: status,
        img: screenshots,
        badge: badge,
        badgeNames: badgeNames,
        libraries: libraries.text.replaceAll(' ', '').split(','),
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
