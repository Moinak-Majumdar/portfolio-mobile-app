import 'package:choice/choice.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:moinak05_web_dev_dashboard/app/utils/smack_msg.dart';
import 'package:moinak05_web_dev_dashboard/app/widgets/dynamic_input.dart';
import 'package:moinak05_web_dev_dashboard/app/widgets/img_importer.dart';
import 'package:moinak05_web_dev_dashboard/app/widgets/loader.dart';
import 'package:moinak05_web_dev_dashboard/app/widgets/on_error.dart';
import 'package:moinak05_web_dev_dashboard/hive_add_doc.dart';
import 'package:moinak05_web_dev_dashboard/provider/doc.dart';
import 'package:moinak05_web_dev_dashboard/provider/html.dart';

const _boxName = 'AddDocBox';
const _boxId = 'currentDoc';

enum DocType { project, work }

class AddDoc extends ConsumerStatefulWidget {
  const AddDoc({super.key});

  @override
  ConsumerState<AddDoc> createState() => _AddDocState();
}

class _AddDocState extends ConsumerState<AddDoc> {
  static final _formKey = GlobalKey<FormState>();

  late Future<HiveAddDoc> _storageFuture;

  late TextEditingController _name;
  late TextEditingController _role;
  late TextEditingController _intro;
  late TextEditingController _liveUrl;
  late TextEditingController _gitRepo;
  late TextEditingController _description;
  late TextEditingController _cover;

  late List<String> _toolsChoices;

  List<String> _img = [''], _tools = [];

  bool _statusSwitch = false;

  String? _selectedCoverUrl;

  DocType? _docType = DocType.project;

  //for limiting memory initialization call during run time.
  bool _memoryFlag = true;
  // upload state.
  bool _isLoading = false;

  @override
  void initState() {
    _storageFuture = getDocFromMemory();
    _name = TextEditingController();
    _role = TextEditingController();
    _intro = TextEditingController();
    _liveUrl = TextEditingController();
    _gitRepo = TextEditingController();
    _description = TextEditingController();
    _cover = TextEditingController();
    _toolsChoices = ref.read(docToolsProvider);
    super.initState();
  }

  @override
  void dispose() {
    _name.dispose();
    _role.dispose();
    _intro.dispose();
    _liveUrl.dispose();
    _description.dispose();
    _cover.dispose();
    super.dispose();
  }

  void handelSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    _formKey.currentState!.save();
    ref
        .read(docProvider.notifier)
        .addDoc(
          cover: _cover.text,
          description: _description.text,
          gitRepo: _gitRepo.text,
          img: _img,
          intro: _intro.text,
          liveUrl: _liveUrl.text,
          name: _name.text,
          role: _role.text,
          status: _statusSwitch,
          tools: _tools,
          type: _docType!.name,
        )
        .then((value) {
      if (value.success) {
        apiSuccess();
        setState(() {
          _isLoading = false;
        });
      } else {
        apiError(error: value.error, errors: value.errors);
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return WillPopScope(
      onWillPop: () async {
        bool willLeave = false;
        await leaveAlert(onLeave: () {
          willLeave = true;
        });
        return willLeave;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Add Doc', style: GoogleFonts.pacifico()),
        ),
        body: FutureBuilder(
          future: _storageFuture,
          builder: (ctx, snapshot) {
            if (snapshot.hasError) {
              return const OnError(error: "Memory initialization failed.");
            }

            if (snapshot.hasData) {
              if (_memoryFlag) {
                initializeMemoryData(snapshot.data!);
                _memoryFlag = false;
              }

              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // hl3  name.
                        TextFormField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            label: Text("Name"),
                            hintText: "Project / Work Name",
                            helperText: 'Unique names only!',
                          ),
                          maxLength: 20,
                          controller: _name,
                          validator: nameValidator,
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 12),
                        // hl3 status.
                        CheckboxListTile(
                          value: _statusSwitch,
                          title: Text(
                            _statusSwitch ? "completed" : "under development",
                            style: GoogleFonts.pacifico(fontSize: 20),
                          ),
                          subtitle: Text(
                            'Current status',
                            style: textTheme.bodyLarge,
                          ),
                          onChanged: (val) {
                            setState(() {
                              _statusSwitch = val!;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        // hl3 type.
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ListTile(
                                title: Text(
                                  'Project',
                                  style: GoogleFonts.pacifico(fontSize: 18),
                                ),
                                leading: Radio<DocType>(
                                  value: DocType.project,
                                  groupValue: _docType,
                                  onChanged: (e) {
                                    setState(() {
                                      _docType = e!;
                                    });
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                title: Text(
                                  "Work",
                                  style: GoogleFonts.pacifico(fontSize: 18),
                                ),
                                leading: Radio<DocType>(
                                  value: DocType.work,
                                  groupValue: _docType,
                                  onChanged: (e) {
                                    setState(() {
                                      _docType = e!;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // hl3 role.
                        TextFormField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            label: Text("Development Role"),
                            hintText: "eg: design , coding",
                          ),
                          maxLength: 100,
                          validator: requiredValidator,
                          textCapitalization: TextCapitalization.sentences,
                          controller: _role,
                        ),
                        const SizedBox(height: 12),
                        // hl3 Intro.
                        TextFormField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            label: Text("Intro"),
                            hintText: "Introduction",
                          ),
                          maxLength: 100,
                          validator: requiredValidator,
                          textCapitalization: TextCapitalization.sentences,
                          controller: _intro,
                        ),
                        const SizedBox(height: 12),
                        // hl3 Live Url.
                        TextFormField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            label: Text("Live deployment url"),
                            hintText: "https://aswomeProject.vercel.app",
                          ),
                          validator: requiredValidator,
                          textCapitalization: TextCapitalization.sentences,
                          controller: _liveUrl,
                          keyboardType: TextInputType.url,
                        ),
                        const SizedBox(height: 12),
                        // hl3 git repository.
                        TextFormField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            label: Text("Git repository"),
                            hintText:
                                "https://github.com/Moinak-Majumdar/awesomeProject",
                          ),
                          validator: requiredValidator,
                          textCapitalization: TextCapitalization.sentences,
                          controller: _gitRepo,
                          keyboardType: TextInputType.url,
                        ),
                        const SizedBox(height: 18),
                        // hl3 cover img url.
                        Row(
                          children: [
                            ImgImporter(
                              onTap: (val) {
                                _cover.text = val;
                                setState(() {
                                  _selectedCoverUrl = val;
                                });
                              },
                              selectedUrl: _selectedCoverUrl ?? _cover.text,
                              disabled: _isLoading,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  label: Text("Cover image url"),
                                  hintText: "image url from image cloud.",
                                ),
                                validator: requiredValidator,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                controller: _cover,
                                keyboardType: TextInputType.url,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 9),
                        const Divider(),
                        const SizedBox(height: 9),
                        // hl4 Tools tag based input.
                        FormField<List<String>>(
                          autovalidateMode: AutovalidateMode.always,
                          initialValue: _tools,
                          validator: toolsValidator,
                          builder: (formState) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    text: 'Used technologies : ',
                                    style: textTheme.titleLarge!.copyWith(
                                      color: colorScheme.secondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: formState.errorText ??
                                            '${formState.value!.length}/${_toolsChoices.length} selected',
                                        style: textTheme.titleSmall!.copyWith(
                                          color: formState.hasError
                                              ? Colors.red
                                              : Colors.green,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                InlineChoice<String>(
                                  multiple: true,
                                  clearable: true,
                                  value: _tools,
                                  onChanged: (val) {
                                    formState.didChange(val);
                                    setState(() {
                                      _tools = formState.value ?? [];
                                    });
                                  },
                                  itemCount: _toolsChoices.length,
                                  itemBuilder: (selection, index) {
                                    return ChoiceChip(
                                      label: Text(
                                        _toolsChoices[index],
                                        style: textTheme.titleSmall,
                                      ),
                                      selected: selection
                                          .selected(_toolsChoices[index]),
                                      onSelected: selection
                                          .onSelected(_toolsChoices[index]),
                                      labelStyle: textTheme.titleSmall,
                                    );
                                  },
                                  listBuilder: ChoiceList.createWrapped(
                                    spacing: 10,
                                    runSpacing: 5,
                                    padding: const EdgeInsets.only(
                                      top: 8,
                                      bottom: 4,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const Divider(),
                        // hl3  description.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Description',
                              style: textTheme.titleLarge!.copyWith(
                                color: colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _importHtml,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: colorScheme.secondaryContainer,
                              ),
                              child: const Text('Import HTML'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _description,
                          decoration: InputDecoration(
                            hintText:
                                'Directly import from HTML Play or write from scratch.',
                            helperStyle: textTheme.titleMedium!.copyWith(
                              color: colorScheme.primary,
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.multiline,
                          maxLines: 10,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          textInputAction: TextInputAction.newline,
                          validator: requiredValidator,
                          style: GoogleFonts.courierPrime(fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        const Divider(),
                        // hl5 images dynamic input.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Screen shots',
                              style: textTheme.titleLarge!.copyWith(
                                color: colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      setState(() => _img.add(''));
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: colorScheme.secondaryContainer,
                              ),
                              child: const Text('Add Fields'),
                            ),
                          ],
                        ),
                        for (int index = 0; index < _img.length; index++)
                          DynamicInput(
                            key: UniqueKey(),
                            initialValue: _img[index],
                            onChanged: (v) => _img[index] = v,
                            disableFirstRemove: index == 0 ? true : false,
                            disabled: _isLoading,
                            onClick: () {
                              setState(
                                () => _img.removeAt(index),
                              );
                            },
                          ),
                        const SizedBox(height: 32),
                        // hl6 submit and reset.
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _formKey.currentState!.reset();
                                  _img = [''];
                                  _tools = [];
                                  _statusSwitch = false;
                                  _docType = null;
                                });
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reset'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.error,
                                foregroundColor: colorScheme.errorContainer,
                              ),
                            ),
                            const SizedBox(width: 16),
                            _isLoading
                                ? const CircularProgressIndicator()
                                : ElevatedButton.icon(
                                    onPressed: handelSubmit,
                                    icon: const Icon(Icons.upload),
                                    label: const Text('Upload Doc'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorScheme.primary,
                                      foregroundColor:
                                          colorScheme.primaryContainer,
                                    ),
                                  ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            }

            return const Loader(splash: 'Initializing memory ..');
          },
        ),
      ),
    );
  }

  void initializeMemoryData(HiveAddDoc data) {
    _name.text = data.name;
    _cover.text = data.cover;
    _description.text = data.description;
    _gitRepo.text = data.gitRepo;
    _intro.text = data.intro;
    _liveUrl.text = data.liveUrl;
    _role.text = data.role;
    _statusSwitch = data.status;
    _img = data.img;
    _tools = data.tools;

    if (data.type != '') {
      _docType = EnumToString.fromString(DocType.values, data.type);
    }
  }

  void _importHtml() {
    final html = ref.read(htmlProvider);
    if (html == '') {
      SmackMsg(
        smack: 'Please export html first from HTML Play',
        context: context,
      );
    } else {
      _description.text = html;
    }
  }

  Future<void> leaveAlert({required Function() onLeave}) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Do you want to save the document before leaving?',
          style: TextStyle(
            color: Colors.blueGrey,
            fontWeight: FontWeight.normal,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              onLeave();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: const Text(
              'Exit',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              saveDoc(
                cover: _cover.text,
                description: _description.text,
                gitRepo: _gitRepo.text,
                img: _img,
                intro: _intro.text,
                liveUrl: _liveUrl.text,
                name: _name.text,
                role: _role.text,
                status: _statusSwitch,
                tools: _tools,
                type: _docType == null
                    ? ''
                    : EnumToString.convertToString(_docType),
              );
              onLeave();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
            ),
            child: const Text(
              'Save and Exit',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }

  void apiSuccess() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Success 🔥🔥'),
        content: Text(
          '${_name.text} is added successfully',
          style: const TextStyle(
            fontSize: 18,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Close'),
          )
        ],
      ),
    );
  }

  void apiError({required String error, required List<String> errors}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error 😵‍💫😵‍💫😵‍💫'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (error != '')
              Text(
                error,
                style: const TextStyle(fontSize: 16),
              ),
            if (error != '' && errors.isNotEmpty) const SizedBox(height: 10),
            for (final elm in errors)
              Text(
                elm,
                style: const TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}

// hl2 value fetched by future builder at run time.
Future<HiveAddDoc> getDocFromMemory() async {
  final box = await Hive.openBox<HiveAddDoc>(_boxName);
  final data = box.get(_boxId);
  await box.close();
  return data ??
      HiveAddDoc(
        cover: '',
        description: '',
        gitRepo: '',
        img: [''],
        intro: '',
        liveUrl: '',
        name: '',
        role: '',
        slug: '',
        status: false,
        tools: [],
        type: '',
      );
}

//hl4 saving data before leaving.
void saveDoc({
  required String cover,
  required String description,
  required String gitRepo,
  required List<String> img,
  required String intro,
  required String liveUrl,
  required String name,
  required String role,
  required bool status,
  required List<String> tools,
  required String type,
}) async {
  final box = await Hive.openBox<HiveAddDoc>(_boxName);
  await box.put(
    _boxId,
    HiveAddDoc(
      cover: cover,
      description: description,
      gitRepo: gitRepo,
      img: img,
      intro: intro,
      liveUrl: liveUrl,
      name: name,
      role: role,
      slug: name.toLowerCase().replaceAll(' ', ''),
      status: status,
      tools: tools,
      type: type,
    ),
  );
  await box.close();
}

// form validator.
String? nameValidator(String? val) {
  if (val == null || val.trim().isEmpty) {
    return 'Required *';
  }
  if (val.length < 4) {
    return 'Name must be at least 4 characters long.';
  }
  return null;
}

String? requiredValidator(String? val) {
  if (val == null || val.trim().isEmpty) {
    return 'Required *';
  }
  return null;
}

String? toolsValidator(List<String>? val) {
  if (val == null || val.isEmpty) {
    return 'Please select at least 1.';
  }
  return null;
}
