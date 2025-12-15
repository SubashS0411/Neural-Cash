import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/supabase_service.dart';
import '../auth/sign_in_page.dart';
import '../../widgets/glass_container.dart';
import '../../theme/app_theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.client});

  final SupabaseClient client;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Map<String, dynamic> _prefs = {
    'reduce_this': true,
    'cross_cut': true,
    'savings_alert': true,
  };
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final svc = SupabaseService(widget.client);
    final profile = await svc.fetchProfile();
    if (!mounted) return;
    setState(() {
      _prefs = Map<String, dynamic>.from(
        profile?['notification_preferences'] ?? _prefs,
      );
      _loading = false;
    });
  }

  Future<void> _save() async {
    final svc = SupabaseService(widget.client);
    await svc.updateNotificationPrefs(_prefs);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Preferences saved'),
        backgroundColor: AppTheme.neuralGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 60, 16, 120),
        children: [
          Text(
            'Settings',
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          
          Text(
            'Preferences',
            style: GoogleFonts.outfit(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white60
            ),
          ),
          const SizedBox(height: 12),
          
          GlassContainer(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SwitchRow(
                  title: 'Reduce This',
                  subtitle: 'Budget guardrails',
                  value: _prefs['reduce_this'] ?? true,
                  onChanged: (v) {
                    setState(() => _prefs['reduce_this'] = v);
                    _save();
                  },
                ),
                Divider(color: Colors.white.withOpacity(0.1), height: 1),
                _SwitchRow(
                  title: 'Cross Cut',
                  subtitle: 'Rebalancing suggestions',
                  value: _prefs['cross_cut'] ?? true,
                  onChanged: (v) {
                    setState(() => _prefs['cross_cut'] = v);
                    _save();
                  },
                ),
                Divider(color: Colors.white.withOpacity(0.1), height: 1),
                _SwitchRow(
                  title: 'Savings Alerts',
                  subtitle: 'Celebrate over-performance',
                  value: _prefs['savings_alert'] ?? true,
                  onChanged: (v) {
                    setState(() => _prefs['savings_alert'] = v);
                    _save();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          
          Text(
            'Account',
            style: GoogleFonts.outfit(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white60
            ),
          ),
          const SizedBox(height: 12),

          GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await widget.client.auth.signOut();
                    if (!mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => SignInPage(client: widget.client),
                      ),
                      (_) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.neuralRed.withOpacity(0.2),
                    foregroundColor: AppTheme.neuralRed,
                    elevation: 0,
                  ),
                  child: const Text('Sign out'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.5))),
      value: value,
      activeColor: AppTheme.neuralBlue,
      onChanged: onChanged,
    );
  }
}
