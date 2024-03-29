import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:portfolio/models/web_project.dart';
import 'package:portfolio/page/web/update.dart';
import 'package:portfolio/widget/network_img_view.dart';
import 'package:portfolio/widget/neumorphism.dart';
import 'package:portfolio/widget/tailwind_play_content.dart';
import 'package:portfolio/widget/titled_text.dart';
import 'package:url_launcher/url_launcher.dart';

class WebDetails extends StatelessWidget {
  const WebDetails({super.key, required this.data});
  final WebProjectModel data;

  @override
  Widget build(context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(data.name),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => UpdateWeb(data: data)),
              );
            },
            icon: const Icon(FontAwesomeIcons.penToSquare),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // hl3 1.cover.
              NetworkImgView(
                url: data.cover.url,
                padding: const EdgeInsets.all(12),
                height: 220,
              ),
              // hl3 2.intro.
              NeuBoxDark(
                child: TitledText(
                  title: "Intro",
                  children: [
                    TextSpan(
                      text: data.intro,
                      style: textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              // hl3 3.links.
              Row(
                children: [
                  Expanded(
                    child: NeuBox(
                      margin: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                      padding: const EdgeInsets.all(4),
                      child: TextButton.icon(
                        onPressed: () {
                          _launchUrl(data.gitRepo);
                        },
                        icon: const Icon(
                          FontAwesomeIcons.github,
                          color: Colors.white60,
                        ),
                        label: const Text("Repository"),
                      ),
                    ),
                  ),
                  Expanded(
                    child: NeuBox(
                      margin: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                      padding: const EdgeInsets.all(4),
                      child: TextButton.icon(
                        onPressed: () {
                          _launchUrl(data.liveUrl);
                        },
                        icon: const Icon(
                          FontAwesomeIcons.rocket,
                          color: Colors.white60,
                          size: 22,
                        ),
                        label: const Text("Deployment"),
                      ),
                    ),
                  ),
                ],
              ),
              // hl3 4.role.
              Padding(
                padding: const EdgeInsets.only(top: 12, left: 14),
                child: TitledText(
                  title: "Role",
                  children: [
                    TextSpan(
                      text: data.role,
                      style: textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              // hl3 5.status.
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 0, 12),
                child: TitledText(
                  title: "Status",
                  children: [
                    TextSpan(
                      text: data.status,
                      style: textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              // hl3 6.Tech.
              SizedBox(
                width: double.infinity,
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: data.toolsLogo.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) => NeuBoxDark(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/language/${data.toolsLogo[index]}',
                          semanticsLabel: data.tools[index],
                          fit: BoxFit.cover,
                          height: 50,
                          width: 50,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data.tools[index],
                          style: const TextStyle(color: Colors.white70),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              // hl3 7. Screenshots.
              NeuBox(
                borderRadius: 16,
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                child: CarouselSlider.builder(
                  itemCount: data.img.length,
                  itemBuilder: (context, index, realIndex) {
                    return NetworkImgView(
                      url: data.img[index].url,
                      borderRadius: BorderRadius.circular(6),
                    );
                  },
                  options: CarouselOptions(
                    viewportFraction: 1,
                    enableInfiniteScroll: false,
                    enlargeCenterPage: true,
                    enlargeFactor: 0.5,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 3),
                  ),
                ),
              ),

              // hl3 8. description.
              TailwindPlayContent(content: data.description),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _launchUrl(String link) async {
  final url = Uri.parse(link);
  if (!await launchUrl(url)) {
    throw Exception('Failed to launch $link');
  }
}
