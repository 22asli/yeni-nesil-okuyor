import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:bookapp/const/links.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PromoLinkWidget extends StatelessWidget {
  const PromoLinkWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedTextKit(
      repeatForever: true,
      animatedTexts: [
        WavyAnimatedText(
          promoLink,
          textStyle: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: Colors.black),
          speed: const Duration(milliseconds: 200),
        ),
      ],
      onTap: () => launchUrl(Uri.parse(sslPromoLink)),
    );
  }
}
