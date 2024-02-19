import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:portfolio/controller/import_export.dart';
import 'package:portfolio/widget/neumorphism.dart';

class CoverImgSelector extends StatelessWidget {
  const CoverImgSelector({
    super.key,
    required this.selected,
    required this.loading,
    required this.onImport,
  });
  final ImportExport? selected;
  final bool loading;
  final void Function(ImportExport item) onImport;

  @override
  Widget build(context) {
    final textTheme = Theme.of(context).textTheme;
    return NeuListTile(
      onTap: loading
          ? null
          : () => openExportedProjectImgCollection(
                context: context,
                selectedItem: selected,
                pop: true,
                onImport: (item) {
                  onImport(item);
                },
              ),
      title: Text(
        'Select project cover Image',
        style: textTheme.titleMedium!.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      subtitle: Text(
        selected?.name == "" ? "No image is selected." : selected!.name,
        style: textTheme.labelMedium!.copyWith(
          color: selected?.name == "" ? Colors.red : Colors.white60,
        ),
      ),
      trailing: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          width: 106,
          height: 60,
          fit: BoxFit.cover,
          imageUrl: selected != null ? selected!.url : "",
          errorWidget: (context, url, error) => const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 32,
                color: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScreenshotsSelector extends StatefulWidget {
  const ScreenshotsSelector({
    super.key,
    required this.loading,
    required this.onUpdate,
    required this.selectedItems,
  });
  final List<ImportExport> selectedItems;
  final bool loading;
  final void Function(List<ImportExport> item) onUpdate;

  @override
  State<ScreenshotsSelector> createState() => _ScreenshotsSelectorState();
}

class _ScreenshotsSelectorState extends State<ScreenshotsSelector> {
  late List<ImportExport> tempItems;

  @override
  void initState() {
    if (widget.selectedItems.isEmpty) {
      tempItems = [
        const ImportExport.projectImage(
          name: "",
          projectName: "",
          url: "",
        ),
      ];
    } else {
      tempItems = [...widget.selectedItems];
    }

    super.initState();
  }

  @override
  Widget build(context) {
    final textTheme = Theme.of(context).textTheme;

    if (widget.selectedItems.isEmpty) {
      tempItems = [
        const ImportExport.projectImage(
          name: "",
          projectName: "",
          url: "",
        ),
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Divider(),
        for (int i = 0; i < tempItems.length; i++)
          Dismissible(
            key: ValueKey("$i _ ${tempItems[i].url}"),
            direction: tempItems.length < 2
                ? DismissDirection.none
                : DismissDirection.horizontal,
            onDismissed: (direction) {
              setState(() {
                tempItems.removeAt(i);
              });
              widget.onUpdate(tempItems);
            },
            background: Container(
              color: Colors.white12,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: const Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Remove",
                    style: TextStyle(fontSize: 28, color: Colors.black26),
                  ),
                  Icon(FontAwesomeIcons.xmark, color: Colors.white60, size: 40)
                ],
              ),
            ),
            child: NeuListTile(
              onTap: widget.loading
                  ? null
                  : () => openExportedProjectImgCollection(
                        context: context,
                        selectedItem: tempItems[i],
                        pop: true,
                        onImport: (item) {
                          setState(() {
                            tempItems.last = item;
                          });
                          widget.onUpdate(tempItems);
                        },
                      ),
              title: Text(
                'screenshot : ${i + 1}',
                style: textTheme.titleMedium,
              ),
              subtitle: Text(
                tempItems[i].name == ""
                    ? "No image is selected."
                    : tempItems[i].name,
                style: textTheme.labelMedium!.copyWith(
                  color: tempItems[i].name == "" ? Colors.red : Colors.white60,
                ),
              ),
              trailing: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  width: 106,
                  height: 60,
                  fit: BoxFit.cover,
                  imageUrl: tempItems[i].url,
                  errorWidget: (context, url, error) => const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 32,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        TextButton(
          onPressed: tempItems.last.url == ""
              ? null
              : () {
                  setState(() {
                    tempItems.add(const ImportExport.projectImage(
                      name: "",
                      projectName: "",
                      url: "",
                    ));
                  });
                },
          child: const Text(" ➕ Add Field ➕ "),
        ),
        const Divider(),
      ],
    );
  }
}
