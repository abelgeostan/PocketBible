import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PocketBible-നെക്കുറിച്ച്'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          // Header Logo & Title
          Center(
            child: Column(
              children: [
                Image.asset(
                  'assets/icons/app_icon.png',
                  width: 90,
                  height: 90,
                ),
                const SizedBox(height: 12),
                RichText(
                  text: TextSpan(
                    text: 'PocketBible',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                      fontFamily: 'Noto Sans Malayalam',
                    ),
                    children: [
                      TextSpan(
                        text: '.in',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: mutedColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppConstants.appTagline,
                  style: TextStyle(fontSize: 14, color: mutedColor, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Version ${AppConstants.appVersion}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Source Details Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ഉറവിടവും വിവരങ്ങളും (Source & Text)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'മലയാളം സത്യവേദപുസ്തകം 1910 പതിപ്പ്, സമകാലിക ലിപിയിൽ പുനഃക്രമീകരിച്ചത്.\n\nMalayalam Sathyavedapusthakam 1910, revised in contemporary orthography, published by The Free Bible Foundation (FBF), 2015.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Divider(height: 1, color: lineColor),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.copyright, size: 16, color: mutedColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'License: Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)',
                          style: TextStyle(fontSize: 12, color: mutedColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // App Highlights Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'പ്രധാന സവിശേഷതകൾ (Features)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildFeatureBullet('66 പുസ്തകങ്ങൾ, 1,189 അധ്യായങ്ങൾ, 31,098 വാക്യങ്ങൾ', textColor),
                  _buildFeatureBullet('100% ഓഫ്‌ലൈൻ പ്രവർത്തനം (ഇന്റർനെറ്റ് ആവശ്യമില്ല)', textColor),
                  _buildFeatureBullet('ദ്രുത തിരച്ചിൽ (Fast Malayalam Scripture Search)', textColor),
                  _buildFeatureBullet('ബുക്ക്മാർക്കുകൾ, വർണ്ണ ഹൈലൈറ്റുകൾ, വ്യക്തിഗത കുറിപ്പുകൾ', textColor),
                  _buildFeatureBullet('ലൈറ്റ് / ഡാർക്ക് തീം, ഫോണ്ട് വലിപ്പ ക്രമീകരണം', textColor),
                  _buildFeatureBullet('ദിവസത്തെ വചനവും ക്രമരഹിത വചനവും (Daily & Random Verse)', textColor),
                  _buildFeatureBullet('അവസാനം വായിച്ച അധ്യായം ഓർത്തുസൂക്ഷിക്കുന്നു', textColor),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Credits Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'സാങ്കേതിക പിന്തുണ (Powered By)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Sansnet (',
                        style: TextStyle(fontSize: 13, height: 1.6, color: textColor),
                      ),
                      InkWell(
                        onTap: () => _launchExternalUrl(AppConstants.sansnetUrl),
                        borderRadius: BorderRadius.circular(4),
                        child: Text(
                          'sansnet.com',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.6,
                            color: accentColor,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        ')',
                        style: TextStyle(fontSize: 13, height: 1.6, color: textColor),
                      ),
                    ],
                  ),
                  Text(
                    'PocketBible.in project.',
                    style: TextStyle(fontSize: 13, height: 1.6, color: textColor),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: () => _launchExternalUrl(AppConstants.websiteUrl),
                    icon: Icon(Icons.open_in_browser, size: 18, color: accentColor),
                    label: Text(
                      'Visit PocketBible.in website',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: accentColor,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: accentColor.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Privacy Policy Card
          Card(
            child: ListTile(
              leading: Icon(Icons.privacy_tip_outlined, color: accentColor),
              title: const Text('Privacy Policy (സ്വകാര്യതാ നയം)'),
              trailing: const Icon(Icons.open_in_new, size: 18),
              onTap: () => _launchExternalUrl(AppConstants.privacyPolicyUrl),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildFeatureBullet(String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, height: 1.4, color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchExternalUrl(String urlString) async {
    final url = Uri.parse(urlString);
    try {
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      try {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      } catch (_) {}
    }
  }
}
