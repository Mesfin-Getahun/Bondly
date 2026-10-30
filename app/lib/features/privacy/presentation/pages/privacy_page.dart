import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/privacy_controller.dart';
import '../widgets/privacy_widget.dart';

/// Feature: Privacy - Main Page
///
/// Privacy settings, data export, consent management, and account deletion.
class PrivacyPage extends StatefulWidget {
  final String? currentUserId;
  final PrivacyController? controller;

  const PrivacyPage({
    super.key,
    this.currentUserId,
    this.controller,
  });

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  late final PrivacyController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? PrivacyController();
    if (widget.currentUserId != null) {
      _controller.init(widget.currentUserId!);
    }
  }

  @override
  void didUpdateWidget(covariant PrivacyPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentUserId != null && widget.currentUserId != oldWidget.currentUserId) {
      _controller.init(widget.currentUserId!);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Privacy & Security', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final settings = _controller.settings;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Owner-Only Privacy Guarantee Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.green.shade100,
                      child: Icon(Icons.lock_rounded, color: Colors.green.shade800, size: 22),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Owner-Only Privacy Principle',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Your relationship notes, interaction logs, and private reminders belong only to you. Mutual connections never see your private notes.',
                            style: TextStyle(fontSize: 12, color: Color(0xFF2E7D32)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Discovery & Consent Controls
              const Text(
                'Consent & Discovery',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    PrivacyToggleTile(
                      icon: Icons.search_rounded,
                      title: 'Search Discoverability',
                      subtitle: 'Allow friends to find your profile by email or username',
                      value: settings?.searchVisibility ?? true,
                      onChanged: (val) => _controller.updateToggle(searchVisibility: val),
                    ),
                    const Divider(height: 1),
                    PrivacyToggleTile(
                      icon: Icons.auto_awesome_rounded,
                      title: 'AI Relationship Recommendations',
                      subtitle: 'Generate suggestions to follow up with distant friends',
                      value: settings?.personalizedRecommendations ?? true,
                      onChanged: (val) =>
                          _controller.updateToggle(personalizedRecommendations: val),
                    ),
                    const Divider(height: 1),
                    PrivacyToggleTile(
                      icon: Icons.done_all_rounded,
                      title: 'Read Receipts',
                      subtitle: 'Let contacts see when you have viewed their direct messages',
                      value: settings?.readReceipts ?? true,
                      onChanged: (val) => _controller.updateToggle(readReceipts: val),
                    ),
                    const Divider(height: 1),
                    PrivacyToggleTile(
                      icon: Icons.query_stats_rounded,
                      title: 'Anonymous Usage Analytics',
                      subtitle: 'Help improve Bondly with privacy-preserving telemetry',
                      value: settings?.analyticsConsent ?? true,
                      onChanged: (val) => _controller.updateToggle(analyticsConsent: val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Data Portability
              const Text(
                'Data Portability',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),
              DataExportCard(controller: _controller),
              const SizedBox(height: 24),

              // Danger Zone
              const Text(
                'Account Deletion',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),
              AccountDeletionCard(
                controller: _controller,
                onAccountDeleted: () {
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
