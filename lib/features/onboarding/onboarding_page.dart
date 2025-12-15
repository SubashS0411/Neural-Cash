import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/supabase_service.dart';
import '../home/home_shell.dart';
import '../../widgets/app_scaffold.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.client});

  final SupabaseClient client;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _income = TextEditingController();
  final _tax = TextEditingController(text: '30');
  final _shortGoal = TextEditingController(text: '1000');
  final _longGoal = TextEditingController(text: '5000');
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _income.dispose();
    _tax.dispose();
    _shortGoal.dispose();
    _longGoal.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final svc = SupabaseService(widget.client);
    try {
      await svc.createProfile(
        fullName: _name.text.trim(),
        income: num.tryParse(_income.text) ?? 0,
        taxPercent: num.tryParse(_tax.text) ?? 30,
        shortTerm: num.tryParse(_shortGoal.text) ?? 0,
        longTerm: num.tryParse(_longGoal.text) ?? 0,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomeShell(client: widget.client)),
      );
    } catch (e) {
      setState(() => _error = 'Failed to save profile: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Onboarding')),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 16,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Set your guardrails',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'We keep everything local-first and private. These numbers tune your nudges.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 18),
                    _field(
                      'Full name',
                      _name,
                      TextInputType.name,
                      requiredField: true,
                    ),
                    _field(
                      'Monthly income target',
                      _income,
                      TextInputType.number,
                      requiredField: true,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _field('Tax %', _tax, TextInputType.number),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _field(
                            'Short-term savings',
                            _shortGoal,
                            TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _field(
                            'Long-term savings',
                            _longGoal,
                            TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_error != null)
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        child: _loading
                            ? const CircularProgressIndicator()
                            : const Text('Continue'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller,
    TextInputType type, {
    bool requiredField = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        keyboardType: type,
        validator: requiredField
            ? (v) => v != null && v.isNotEmpty ? null : 'Required'
            : null,
      ),
    );
  }
}
