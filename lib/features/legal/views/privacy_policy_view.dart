import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_color_scheme.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surfaceElevated,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/login');
            }
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/slslogo.png',
              width: 28,
              height: 28,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
            const SizedBox(width: 10),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: 'SWISS ', style: AppTextStyles.headingSmall.copyWith(color: colors.primaryRed, fontWeight: FontWeight.bold)),
                  TextSpan(text: 'LUXURY SERVICES', style: AppTextStyles.headingSmall.copyWith(color: colors.textPrimary, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          TextButton.icon(
            onPressed: () => context.go('/login'),
            icon: Icon(Icons.login_outlined, size: 18, color: colors.textSecondary),
            label: Text('Sign In', style: TextStyle(color: colors.textSecondary)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header badge & title
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: colors.primaryRed.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: colors.primaryRed.withOpacity(0.3)),
                        ),
                        child: Text(
                          'LEGAL & PRIVACY',
                          style: AppTextStyles.badgeText.copyWith(
                            color: colors.primaryRed,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Privacy Policy',
                        style: AppTextStyles.pageTitle.copyWith(
                          fontSize: 32,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Last updated: September 2026',
                        style: AppTextStyles.subtitle.copyWith(color: colors.textMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Section 1: Introduction
                _buildSection(
                  colors: colors,
                  number: '1',
                  title: 'Introduction',
                  content: [
                    'Welcome to Swiss Luxury Services ("SLS", "we", "our", or "us"). We are committed to protecting and respecting your personal privacy. This Privacy Policy sets out the basis on which any personal data we collect from you, or that you provide to us through our mobile applications, web platforms, concierge requests, private jet charter bookings, and admin services, will be processed and safeguarded.',
                    'Swiss Luxury Services complies with applicable data protection laws, including the Swiss Federal Act on Data Protection (FADP / DSG), the General Data Protection Regulation (EU GDPR), and other applicable regional data privacy frameworks.',
                  ],
                ),

                // Section 2: Information We Collect
                _buildSection(
                  colors: colors,
                  number: '2',
                  title: 'Information We Collect',
                  content: [
                    'We may collect and process the following categories of information about you:',
                  ],
                  bulletPoints: [
                    'Personal Identification & Contact Details: Full name, title, company, email address, telephone/mobile number, and passport or identification documents strictly as necessary for flight charter manifests and aviation clearances.',
                    'Flight Charter & Concierge Requests: Departure and arrival locations, travel schedules, passenger counts, luggage details, catering preferences, VIP ground transportation, and accommodation requests.',
                    'Technical & Device Data: Authentication credentials, IP address, device model, operating system, and diagnostic performance logs to ensure system reliability and security.',
                  ],
                ),

                // Section 3: How We Use Your Information
                _buildSection(
                  colors: colors,
                  number: '3',
                  title: 'How We Use Your Information',
                  content: [
                    'We use your data solely for legitimate business and luxury service operations:',
                  ],
                  bulletPoints: [
                    'Fulfilling private jet flight quotes, bookings, aircraft sourcing, and bespoke concierge experiences.',
                    'Direct communication with clients regarding itineraries, status notifications, and customer support.',
                    'Fulfilling mandatory civil aviation, customs, immigration, and Swiss regulatory obligations.',
                    'Maintaining and improving system security, preventing unauthorized access, and debugging platform features.',
                  ],
                ),

                // Section 4: Data Sharing & Third-Party Processors
                _buildSection(
                  colors: colors,
                  number: '4',
                  title: 'Data Sharing & Third-Party Disclosures',
                  content: [
                    'We treat client information with the highest degree of discretion and confidentiality. We do not sell, lease, or monetize your personal data. We disclose information only to:',
                  ],
                  bulletPoints: [
                    'Licensed aviation operators, fixed-base operators (FBOs), flight crew, and border control authorities strictly as required to fulfill flight operations.',
                    'Enterprise cloud and database infrastructure providers (such as Google Cloud / Firebase) operating under strict encryption and data protection agreements.',
                    'Law enforcement or government bodies where strictly mandated by statutory Swiss or international aviation law.',
                  ],
                ),

                // Section 5: Data Security & Retention
                _buildSection(
                  colors: colors,
                  number: '5',
                  title: 'Data Security & Retention',
                  content: [
                    'We implement rigorous administrative, technical, and physical safeguards—including SSL/TLS data transmission encryption and AES-256 resting data security—to safeguard your information from unauthorized access, alteration, or disclosure.',
                    'Your data is retained only for as long as necessary to provide requested services, satisfy legal accounting/tax retention periods, and comply with aviation oversight rules.',
                  ],
                ),

                // Section 6: Your Privacy Rights
                _buildSection(
                  colors: colors,
                  number: '6',
                  title: 'Your Privacy Rights',
                  content: [
                    'Under applicable data protection legislation (such as GDPR and Swiss FADP), you maintain the right to:',
                  ],
                  bulletPoints: [
                    'Request access to personal data retained in our systems.',
                    'Request correction or updating of incomplete or inaccurate records.',
                    'Request erasure ("right to be forgotten") subject to mandatory legal aviation retention obligations.',
                    'Object to or restrict specific processing operations.',
                    'Request data portability in a structured digital format.',
                  ],
                ),

                // Section 7: Contact Us
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.primaryRed.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: colors.shadow,
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.mail_outline, color: colors.primaryRed, size: 22),
                          const SizedBox(width: 10),
                          Text(
                            '7. Contact Information',
                            style: AppTextStyles.headingMedium.copyWith(color: colors.textPrimary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'If you have questions, inquiries, or requests regarding this Privacy Policy or wish to exercise your data rights, please contact:',
                        style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      Text('Swiss Luxury Services (SLS)', style: AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Privacy Office: privacy@swissluxuryservices.ch', style: AppTextStyles.bodyMedium.copyWith(color: colors.textSecondary)),
                      const SizedBox(height: 4),
                      Text('Support: support@swissluxuryservices.ch', style: AppTextStyles.bodyMedium.copyWith(color: colors.textSecondary)),
                      const SizedBox(height: 4),
                      Text('Website: swissluxuryservices.ch', style: AppTextStyles.bodyMedium.copyWith(color: colors.primaryRed)),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
                Center(
                  child: Text(
                    '© 2026 Swiss Luxury Services. All rights reserved.',
                    style: AppTextStyles.bodySmall.copyWith(color: colors.textMuted),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required AppColorScheme colors,
    required String number,
    required String title,
    required List<String> content,
    List<String>? bulletPoints,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: colors.primaryRed,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$number. $title',
                  style: AppTextStyles.headingMedium.copyWith(color: colors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final paragraph in content) ...[
            Text(
              paragraph,
              style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary, height: 1.6),
            ),
            const SizedBox(height: 10),
          ],
          if (bulletPoints != null) ...[
            for (final bullet in bulletPoints) ...[
              Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(color: colors.primaryRed, fontSize: 16, height: 1.4)),
                    Expanded(
                      child: Text(
                        bullet,
                        style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
