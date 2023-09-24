import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:moinak05_web_dev_dashboard/app/screens/html_preview.dart';
import 'package:moinak05_web_dev_dashboard/app/widgets/loader.dart';
import 'package:moinak05_web_dev_dashboard/hive_html.dart';

const _boxName = 'htmlPlaygroundData';
const _boxId = 'htmlPlaygroundBody';

Future<HiveHtml> futureHtml() async {
  final box = await Hive.openBox<HiveHtml>(_boxName);
  final data = box.get(_boxId);
  await box.close();
  return data ?? HiveHtml(body: '<h1>HTML Play</h1>');
}

class HtmlPlayground extends StatefulWidget {
  const HtmlPlayground({super.key});

  @override
  State<HtmlPlayground> createState() => _HtmlPlaygroundState();
}

class _HtmlPlaygroundState extends State<HtmlPlayground> {
  static final _formKey = GlobalKey<FormState>();
  late Future<HiveHtml> _futureHtml;
  String _html = '';

  @override
  void initState() {
    _futureHtml = futureHtml();
    super.initState();
  }

  void preview() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => HtmlPreview(body: _html),
      ),
    );
    final box = await Hive.openBox<HiveHtml>(_boxName);
    await box.put(
      _boxId,
      HiveHtml(body: _html),
    );
    await box.close();
  }

  @override
  Widget build(context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Html Play",
          style: GoogleFonts.pacifico(fontSize: 22),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _formKey.currentState!.reset();
              setState(() {
                _html = '';
              });
            },
            icon: const Icon(Icons.refresh),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
            ),
          ),
          IconButton(
            onPressed: preview,
            icon: const Icon(Icons.play_arrow),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: colorScheme.secondaryContainer,
            ),
          ),
          const SizedBox(width: 8)
        ],
      ),
      body: Column(
        children: [
          FutureBuilder(
            future: _futureHtml,
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loader(splash: 'Getting started ...');
              }
              if (snapshot.hasData) {
                final data = snapshot.data;
                _html = data!.body;
              }
              return Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.symmetric(vertical: 8),
                constraints: const BoxConstraints(maxHeight: 550),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      initialValue: _html,
                      decoration: InputDecoration(
                        hintText: '<b>Hello World!</b>',
                        helperText:
                            "Use text formatter like <b>, <i>, <em>, <br/> and tailwind style in `class` attribute.",
                        helperMaxLines: 2,
                        helperStyle: textTheme.titleMedium!.copyWith(
                          color: colorScheme.primary,
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: 16,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      textInputAction: TextInputAction.newline,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Write something 🥹';
                        }
                        return null;
                      },
                      style: GoogleFonts.courierPrime(fontSize: 18),
                      onSaved: (val) {
                        _html = val!;
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
