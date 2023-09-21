import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moinak05_web_dev_dashboard/models/doc.dart';
import 'package:moinak05_web_dev_dashboard/provider/doc.dart';

class DocDelete extends ConsumerStatefulWidget {
  const DocDelete({super.key, required this.docData, this.title = 'Delete'});
  final DocSchema docData;
  final String title;

  @override
  ConsumerState<DocDelete> createState() => _DocDeleteState();
}

class _DocDeleteState extends ConsumerState<DocDelete> {
  static final _formKey = GlobalKey<FormState>();
  bool _isChecked = false;
  bool _isLoading = false;
  String _name = '';

  void handelDelete() async {
    if (!_formKey.currentState!.validate() || !_isChecked) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    _formKey.currentState!.save();
    await ref
        .read(docProvider.notifier)
        .deleteDoc(name: _name, docId: widget.docData.id)
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: GoogleFonts.pacifico(),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.only(top: 150),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Do you want to delete ${widget.docData.name} ?',
                  style: textTheme.titleLarge!.copyWith(
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                RichText(
                  text: TextSpan(
                    text: 'Type ` ',
                    style: textTheme.titleMedium,
                    children: [
                      TextSpan(
                        text: widget.docData.name,
                        style: textTheme.titleMedium!.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text:
                            ' ` bellow, in order to delete this ${widget.docData.type}.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: widget.docData.name,
                    border: const OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Required *';
                    }
                    if (val != widget.docData.name) {
                      return 'Invalid name.';
                    }
                    return null;
                  },
                  onSaved: (val) {
                    _name = val!;
                  },
                ),
                const SizedBox(height: 24),
                RichText(
                  text: TextSpan(
                    text: 'Type confirmation text ` ',
                    style: textTheme.titleMedium,
                    children: [
                      TextSpan(
                        text: 'delete this ${widget.docData.type}',
                        style: textTheme.titleMedium!.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(
                        text: ' ` bellow.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'delete this ${widget.docData.type}',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Required *';
                    }
                    if (val != 'delete this ${widget.docData.type}') {
                      return 'Permission denied.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                CheckboxListTile(
                  value: _isChecked,
                  onChanged: (val) {
                    setState(() {
                      _isChecked = !_isChecked;
                    });
                  },
                  title: const Text(
                    "I am fully aware that a deleted project can't be recovered again. ",
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        _formKey.currentState!.reset();
                      },
                      icon: const Icon(Icons.refresh),
                    ),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton.icon(
                            onPressed: handelDelete,
                            icon: const Icon(Icons.delete_forever),
                            label: const Text('Delete'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.error,
                              foregroundColor: colorScheme.errorContainer,
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void apiSuccess() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Success 🔥🔥'),
        content: Text(
          '$_name is no longer available.',
          style: const TextStyle(
            fontSize: 18,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              Navigator.pop(context);
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
