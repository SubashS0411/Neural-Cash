import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/supabase_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_container.dart';
import '../transactions/add_transaction_page.dart';

Future<void> showAddActions(BuildContext context, SupabaseClient client) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => _AddActionsSheet(client: client),
  );
}

class _AddActionsSheet extends StatelessWidget {
  const _AddActionsSheet({required this.client});

  final SupabaseClient client;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create New',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          _ActionTile(
            icon: Icons.receipt_long_rounded,
            color: AppTheme.neuralBlue,
            title: 'Transaction',
            subtitle: 'Log an expense or income',
            onTap: () async {
              Navigator.pop(context);
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddTransactionPage(client: client),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _ActionTile(
            icon: Icons.savings_rounded,
            color: AppTheme.neuralPurple,
            title: 'Savings Goal',
            subtitle: 'Set a target for the future',
            onTap: () {
              Navigator.pop(context);
              _showAddSavingsDialog(context, client);
            },
          ),
          const SizedBox(height: 12),
          _ActionTile(
            icon: Icons.flight_takeoff_rounded,
            color: AppTheme.neuralGreen,
            title: 'Trip Plan',
            subtitle: 'Budget for a new adventure',
            onTap: () {
              Navigator.pop(context);
              _showAddTripDialog(context, client);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showAddSavingsDialog(BuildContext context, SupabaseClient client) async {
  final nameController = TextEditingController();
  final amountController = TextEditingController();
  // Simplified dialog for premium feel
  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppTheme.neuralDark,
      title: Text('New Savings Goal', style: GoogleFonts.outfit(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: 'Goal Name', labelStyle: TextStyle(color: Colors.white60)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: 'Target Amount (₹)', labelStyle: TextStyle(color: Colors.white60)),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (nameController.text.isEmpty) return;
            final svc = SupabaseService(client);
            await svc.upsertSavingsGoal(
              name: nameController.text,
              type: 'short_term',
              targetAmount: num.tryParse(amountController.text) ?? 0,
              targetDate: DateTime.now().add(const Duration(days: 90)),
            );
            if (ctx.mounted) Navigator.pop(ctx);
          },
          child: const Text('Create'),
        ),
      ],
    ),
  );
}

Future<void> _showAddTripDialog(BuildContext context, SupabaseClient client) async {
  final nameController = TextEditingController();
  final destController = TextEditingController();
  final budgetController = TextEditingController();

  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppTheme.neuralDark,
      title: Text('Plan New Trip', style: GoogleFonts.outfit(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: 'Trip Name', labelStyle: TextStyle(color: Colors.white60)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: destController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: 'Destination', labelStyle: TextStyle(color: Colors.white60)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: budgetController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: 'Est. Budget (₹)', labelStyle: TextStyle(color: Colors.white60)),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (nameController.text.isEmpty) return;
            final svc = SupabaseService(client);
            await svc.upsertTrip(
              name: nameController.text,
              destination: destController.text,
              startDate: DateTime.now().add(const Duration(days: 30)),
              endDate: DateTime.now().add(const Duration(days: 35)),
              estimatedBudget: num.tryParse(budgetController.text) ?? 0,
            );
            if (ctx.mounted) Navigator.pop(ctx);
          },
          child: const Text('Plan Trip'),
        ),
      ],
    ),
  );
}
