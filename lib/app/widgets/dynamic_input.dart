import 'package:flutter/material.dart';
import 'package:moinak05_web_dev_dashboard/app/widgets/img_importer.dart';

class DynamicInput extends StatefulWidget {
  const DynamicInput({
    super.key,
    required this.initialValue,
    required this.onChanged,
    required this.onClick,
    required this.disableFirstRemove,
    this.disabled = false,
  });

  final String? initialValue;
  final void Function(String) onChanged;
  final void Function() onClick;
  final bool disableFirstRemove;
  final bool disabled;

  @override
  State<DynamicInput> createState() => _DynamicInputState();
}

class _DynamicInputState extends State<DynamicInput> {
  late final TextEditingController _controller;
  String? _selectedUrl;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.text = widget.initialValue ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ImgImporter(
            onTap: (val) {
              _controller.text = val;
              widget.onChanged(val);
              setState(() {
                _selectedUrl = val;
              });
            },
            selectedUrl: _selectedUrl ?? _controller.text,
            disabled: widget.disabled,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: TextFormField(
              controller: _controller,
              onChanged: widget.onChanged,
              decoration: const InputDecoration(
                label: Text("Image Url"),
                hintText: "Import or paste url.",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Required *';
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            onPressed: widget.disableFirstRemove || widget.disabled
                ? null
                : widget.onClick,
            icon: const Icon(Icons.remove_circle),
            style: IconButton.styleFrom(
              foregroundColor: colorScheme.error,
              disabledForegroundColor: colorScheme.onInverseSurface,
            ),
          ),
        ],
      ),
    );
  }
}
