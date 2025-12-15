import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/supabase_service.dart';
import '../../widgets/glass_container.dart';
import '../../theme/app_theme.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key, required this.client});

  final SupabaseClient client;

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _description = TextEditingController();
  DateTime _date = DateTime.now();
  bool _isPersonal = false;
  String? _paymentMethod;
  double? _predictedConfidence;
  String? _predictedCategoryId;
  bool _predicting = false;

  late AnimationController _aiController;

  @override
  void initState() {
    super.initState();
    _aiController = AnimationController(
        vsync: this, duration: const Duration(seconds: 1));
  }

  Future<void> _predict() async {
    if (_description.text.isEmpty) return;
    setState(() {
      _predicting = true;
      _aiController.repeat(reverse: true);
    });
    
    // Simulate network delay for "AI"
    await Future.delayed(const Duration(milliseconds: 1200));
    
    // Stub AI logic
    final conf = (_description.text.length % 10) / 10.0 + 0.5;
    
    if (mounted) {
      setState(() {
        _predictedConfidence = conf.clamp(0, 1);
        _predictedCategoryId = null; 
        _predicting = false;
        _aiController.stop();
        _aiController.reset();
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final svc = SupabaseService(widget.client);
    await svc.addTransaction(
      amount: num.tryParse(_amount.text) ?? 0,
      description: _description.text,
      date: _date,
      paymentMethod: _paymentMethod,
      isPersonal: _isPersonal,
      categoryId: _predictedCategoryId,
      confidence: _predictedConfidence,
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _amount.dispose();
    _description.dispose();
    _aiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.neuralBlack,
      appBar: AppBar(
        title: const Text('Add Transaction'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Amount Input (Hero)
              Center(
                child: IntrinsicWidth(
                  child: TextFormField(
                    controller: _amount,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.outfit(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: '0',
                      prefixText: '₹',
                      prefixStyle: GoogleFonts.outfit(
                          fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white60),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintStyle: GoogleFonts.outfit(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white24,
                      ),
                    ),
                    validator: (v) => v != null && v.isNotEmpty ? null : 'Required',
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Description & AI Prediction
              GlassContainer(
                padding: const EdgeInsets.all(4),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _description,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'What is this for?',
                        prefixIcon: Icon(Icons.edit_note_rounded),
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      onChanged: (val) {
                         // Debounce could be added here
                         if (val.length > 3) _predict();
                      },
                    ),
                    if (_predicting || _predictedConfidence != null)
                      AnimatedBuilder(
                        animation: _aiController,
                        builder: (context, child) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.neuralPurple.withOpacity(0.1 + (_aiController.value * 0.2)),
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome, 
                                  size: 16, 
                                  color: AppTheme.neuralPurple.withOpacity(0.8)
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _predicting 
                                      ? 'Neural Brain is analyzing...' 
                                      : 'Categorized with ${(_predictedConfidence! * 100).toStringAsFixed(0)}% confidence',
                                  style: TextStyle(
                                    color: AppTheme.neuralPurple,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),

              // Details Section
              Text(
                'Details',
                style: GoogleFonts.outfit(
                  fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white60
                ),
              ),
              const SizedBox(height: 12),

              GlassContainer(
                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                 child: Column(
                   children: [
                     // Date Picker
                     ListTile(
                       contentPadding: EdgeInsets.zero,
                       leading: const Icon(Icons.calendar_today_rounded, color: Colors.white70),
                       title: const Text('Date', style: TextStyle(color: Colors.white)),
                       trailing: Text(
                         _date.toLocal().toString().split(' ').first,
                         style: const TextStyle(color: Colors.white70),
                       ),
                       onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _date,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                            builder: (context, child) {
                              return Theme(
                                data: AppTheme.darkTheme, 
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) setState(() => _date = picked);
                       },
                     ),
                     Divider(color: Colors.white.withOpacity(0.1), height: 1),
                     
                     // Payment Method
                     DropdownButtonFormField<String>(
                        value: _paymentMethod,
                        dropdownColor: AppTheme.neuralDark,
                        style: const TextStyle(color: Colors.white),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.payment_rounded, color: Colors.white70),
                          labelText: 'Payment Method',
                          fillColor: Colors.transparent,
                          border: InputBorder.none,
                        ),
                        items: const [
                          DropdownMenuItem(value: 'upi', child: Text('UPI')),
                          DropdownMenuItem(value: 'card', child: Text('Card')),
                          DropdownMenuItem(value: 'cash', child: Text('Cash')),
                        ],
                        onChanged: (v) => setState(() => _paymentMethod = v),
                     ),
                     Divider(color: Colors.white.withOpacity(0.1), height: 1),

                     // Is Personal Switch
                     SwitchListTile(
                       contentPadding: EdgeInsets.zero,
                       secondary: const Icon(Icons.visibility_off_rounded, color: Colors.white70),
                       title: const Text('Personal Transaction', style: TextStyle(color: Colors.white)),
                       subtitle: const Text('Hide from family group', style: TextStyle(color: Colors.white38, fontSize: 12)),
                       value: _isPersonal,
                       activeColor: AppTheme.neuralBlue,
                       onChanged: (v) => setState(() => _isPersonal = v),
                     ),
                   ],
                 ),
              ),

              const SizedBox(height: 48),

              // Submit Button
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neuralBlue,
                  shadowColor: AppTheme.neuralBlue.withOpacity(0.5),
                  elevation: 8,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
                child: const Text('Save Transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
