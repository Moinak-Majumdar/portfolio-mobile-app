import 'package:choice/choice.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio/widget/neumorphism.dart';
import 'package:portfolio/widget/titled_text.dart';

class TechChoice extends StatelessWidget {
  const TechChoice({
    super.key,
    required this.value,
    required this.onChange,
    required this.enabled,
  });
  final List<String> value;
  final void Function(FormFieldState<List<String>> formState) onChange;
  final bool enabled;

  @override
  Widget build(context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    List<String> tempValue = value;

    if (value.isEmpty) {
      tempValue = [];
    }

    return FormField<List<String>>(
      autovalidateMode: AutovalidateMode.always,
      initialValue: tempValue,
      validator: _toolsValidator,
      builder: (formState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(),
            ListTile(
              title: Text(
                'Used technologies',
                style: textTheme.titleMedium,
              ),
              subtitle: Text(
                formState.errorText ??
                    '${tempValue.length}/${_toolsChoices.length} selected',
                style: textTheme.titleSmall!.copyWith(
                  color: tempValue.isEmpty ? Colors.red : Colors.green,
                  fontSize: 12,
                ),
              ),
              trailing: Icon(
                FontAwesomeIcons.plus,
                color: colorScheme.primary,
              ),
              onTap: enabled
                  ? () => _showTechChoice(
                        context: context,
                        value: tempValue,
                        formState: formState,
                        onChange: onChange,
                      )
                  : null,
            ),
            //hl4 display selected.
            if (tempValue.isNotEmpty)
              NeuBoxDark(
                padding: const EdgeInsets.all(12),
                borderRadius: 16,
                child: TitledText(
                  title: "Selected",
                  children: [
                    TextSpan(
                      text: value
                          .toString()
                          .substring(1, value.toString().length - 1),
                      style: textTheme.labelLarge!.copyWith(
                        color: Colors.white70,
                      ),
                    )
                  ],
                ),
              ),
            const Divider(),
          ],
        );
      },
    );
  }
}

void _showTechChoice({
  required BuildContext context,
  required List<String> value,
  required FormFieldState<List<String>> formState,
  required void Function(FormFieldState<List<String>> formState) onChange,
}) {
  showModalBottomSheet(
    context: context,
    builder: (_) => Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tools & Tech !",
            style: GoogleFonts.comicNeue().copyWith(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 16, bottom: 8, right: 8),
            constraints: const BoxConstraints(
              maxHeight: 400,
              minWidth: double.infinity,
            ),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            clipBehavior: Clip.hardEdge,
            child: Scrollbar(
              thickness: 2,
              child: SingleChildScrollView(
                child: InlineChoice<String>(
                  multiple: true,
                  clearable: true,
                  value: value,
                  onChanged: (val) {
                    formState.didChange(val);
                    onChange(formState);
                  },
                  itemCount: _toolsChoices.length,
                  itemBuilder: (selection, index) => ChoiceChip(
                    label: Text(_toolsChoices[index]),
                    selected: selection.selected(_toolsChoices[index]),
                    onSelected: selection.onSelected(_toolsChoices[index]),
                    backgroundColor: Colors.black,
                    selectedColor: const Color.fromARGB(255, 129, 81, 219),
                  ),
                  listBuilder: ChoiceList.createWrapped(
                    spacing: 10,
                    runSpacing: 5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// validator
String? _toolsValidator(List<String>? val) {
  if (val == null || val.isEmpty) {
    return 'Please select at least 1.';
  }
  return null;
}

// choice option of used technologies used in project.
const List<String> _toolsChoices = [
  "c",
  'cpp',
  'css',
  'dart',
  'express',
  'figma',
  'firebase',
  'flutter',
  'framer',
  'git',
  'github',
  'graphQL',
  'heroku',
  'html',
  'java',
  'javascript',
  'mongodb',
  'mui',
  'mysql',
  'netlify',
  'next',
  'node',
  'php',
  'python',
  'react',
  'redux',
  'tailwind',
  'typescript',
  'vercel',
];
