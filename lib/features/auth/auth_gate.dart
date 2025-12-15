import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../home/home_shell.dart';
import '../../widgets/loading_screen.dart';
import 'sign_in_page.dart';
import '../../services/supabase_service.dart';
import '../onboarding/onboarding_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.client});

  final SupabaseClient client;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _checkingProfile = true;
  bool _hasProfile = false;
  String? _lastSessionId;

  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    final svc = SupabaseService(widget.client);
    final profile = await svc.fetchProfile();
    if (!mounted) return;
    setState(() {
      _hasProfile = profile != null;
      _checkingProfile = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: widget.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = widget.client.auth.currentSession;

        if (snapshot.connectionState == ConnectionState.waiting ||
            _checkingProfile) {
          return const LoadingScreen(label: 'Connecting to Supabase...');
        }

        if (session != null) {
          if (_lastSessionId != session.accessToken) {
            _lastSessionId = session.accessToken;
            _checkingProfile = true;
            _checkProfile();
            return const LoadingScreen(label: 'Loading profile...');
          }
          if (_hasProfile) {
            return HomeShell(client: widget.client);
          }
          return OnboardingPage(client: widget.client);
        }

        return SignInPage(client: widget.client);
      },
    );
  }
}
