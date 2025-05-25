import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portfolio/controller/website_status.dart';
import 'package:portfolio/utils/get_snack.dart';
import 'package:portfolio/widget/neumorphism.dart';

class WebsiteStatusChanger extends StatelessWidget {
  const WebsiteStatusChanger({super.key});

  @override
  Widget build(context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final wsc = Get.put(WebSiteStatusController());
    Future<void> changeStatus(bool value) async {
      try {
        await wsc.updateWebSiteStatus('Babar bichi fulko luchi...', value);
      } catch (e) {
        GetSnack.error(message: e.toString());
      }
    }

    return NeuBox(
      padding: const EdgeInsets.symmetric(vertical: 4),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Obx(
        () => SwitchListTile(
          value: wsc.devFlag.value,
          onChanged: changeStatus,
          title: Text(
            wsc.devFlag.value
                ? 'Development Mode is turned On'
                : "Turn on development mode",
            style: textTheme.titleMedium!.copyWith(
              color: colorScheme.primary,
            ),
          ),
          subtitle: Text(
            'Change Dev mode warning for PRODUCTION server.',
            style: textTheme.labelSmall!.copyWith(
              color: Colors.grey.shade400,
            ),
          ),
          thumbIcon: _thumb,
        ),
      ),
    );
  }
}

final MaterialStateProperty<Icon?> _thumb =
    MaterialStateProperty.resolveWith<Icon?>(
  (Set<MaterialState> states) {
    if (states.contains(MaterialState.selected)) {
      return const Icon(Icons.done_outline_sharp);
    }
    return const Icon(Icons.close);
  },
);
