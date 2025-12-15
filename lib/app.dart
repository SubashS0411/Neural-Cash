import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/auth/auth_gate.dart';
import 'theme/app_theme.dart';

class NeuralCashApp extends StatelessWidget {
  const NeuralCashApp({super.key, required this.client});

  final SupabaseClient client;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NeuralCash',
      theme: AppTheme.darkTheme,
      home: AuthGate(client: client),
    );
  }
}
