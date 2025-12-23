import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../Storage/Cache/AccentColorCache.dart';
import '../../../../api/routs/Dto/Partners/PartnerDto.dart';
import '../../../../components/viewers/ImagesCarousel.dart';
import '../../../../config/default.dart';
import '../../../../components/TTNeumorphicBox.dart';
import 'PartnerDetailsScreen.dart';

class PartnerCard extends StatelessWidget {
  final PartnerDto partner;
  final Color accentColor;

  const PartnerCard({
    super.key,
    required this.partner,
    required this.accentColor,
  });

  Future<void> _launchUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color accentColor = AccentColorCache.accentColor;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PartnerDetailsScreen(item: partner),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TTNeumorphicBox(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImagesCarousel(
                images: partner.images,
                height: 180,
                borderRadius: 24,
              ),
              const SizedBox(height: 16),
              Text(
                partner.titleController.text,
                style: TTTextStyle.title18,
              ),
              const SizedBox(height: 8),
              Text(
                partner.descriptionController.text,
                style: TTTextStyle.subtitle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (partner.instagramUrlController.text.isNotEmpty)
                    _SocialButton(
                      icon: 'assets/svg/instagram.svg',
                      color: accentColor,
                      onTap: () =>
                          _launchUrl(partner.instagramUrlController.text),
                    ),
                  if (partner.googleMapsUrlController.text.isNotEmpty)
                    _SocialButton(
                      color: accentColor,
                      icon: 'assets/svg/location.svg',
                      onTap: () =>
                          _launchUrl(partner.googleMapsUrlController.text),
                    ),
                  if (partner.websiteUrlController.text.isNotEmpty)
                    _SocialButton(
                      color: accentColor,
                      icon: 'assets/svg/globe.svg',
                      onTap: () =>
                          _launchUrl(partner.websiteUrlController.text),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String icon;
  final Color color;
  final VoidCallback onTap;

  const _SocialButton({required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: TTColors.background,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white10),
        ),
        child: SvgPicture.asset(
          icon,
          width: 20,
          height: 20,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
      ),
    );
  }
}
