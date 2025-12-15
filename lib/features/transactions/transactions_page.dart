import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../services/supabase_service.dart';
import '../../widgets/glass_container.dart';
import '../../theme/app_theme.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key, required this.client});

  final SupabaseClient client;

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  List<Map<String, dynamic>> _transactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final svc = SupabaseService(widget.client);
    final data = await svc.listTransactions(limit: 100);
    if (!mounted) return;
    setState(() {
      _transactions = data;
      _loading = false;
    });
  }

  Future<void> _updateStatus(String id, String status) async {
    final svc = SupabaseService(widget.client);
    await svc.updateTransactionStatus(id, status);
    await _load();
  }

  Future<void> _delete(String id) async {
    final svc = SupabaseService(widget.client);
    await svc.deleteTransaction(id);
    await _load();
  }

  Map<String, List<Map<String, dynamic>>> _groupTransactions() {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final t in _transactions) {
      final date = t['transaction_date'] != null
          ? DateTime.parse(t['transaction_date']).toLocal()
          : DateTime.now();
      final key = DateFormat('MMMM d, y').format(date);
      grouped.putIfAbsent(key, () => []).add(t);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final grouped = _groupTransactions();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 60, 16, 120),
          itemCount: grouped.keys.length + 1, // +1 for header
          separatorBuilder: (_, __) => const SizedBox(height: 20),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Activity',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Your financial timeline',
                    style: TextStyle(color: Colors.white.withOpacity(0.6)),
                  ),
                ],
              );
            }

            final dateKey = grouped.keys.elementAt(index - 1);
            final dayTx = grouped[dateKey]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    dateKey,
                    style: TextStyle(
                      color: AppTheme.neuralBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                ...dayTx.map((t) {
                  final confidence = t['confidence_score'] as num?;
                  final isLow = confidence != null && confidence < 0.6;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Slidable(
                      key: ValueKey(t['id']),
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (_) => _updateStatus(t['id'], 'approved'),
                            backgroundColor: AppTheme.neuralGreen,
                            foregroundColor: Colors.white,
                            icon: Icons.check,
                            label: 'Approve',
                            borderRadius: BorderRadius.circular(12),
                          ),
                          const SizedBox(width: 4),
                          SlidableAction(
                            onPressed: (_) => _delete(t['id']),
                            backgroundColor: AppTheme.neuralRed,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Delete',
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ],
                      ),
                      child: GlassContainer(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: (t['amount'] as num) > 0 // Heuristic: usually strictly positive in this app, need 'type' to distinguish income/expense properly, assuming expense for now
                                    ? AppTheme.neuralRed.withOpacity(0.1)
                                    : AppTheme.neuralGreen.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                (t['amount'] as num) > 0
                                    ? Icons.arrow_upward_rounded
                                    : Icons.arrow_downward_rounded,
                                color: (t['amount'] as num) > 0
                                    ? AppTheme.neuralRed
                                    : AppTheme.neuralGreen,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t['description_raw'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (isLow)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.warning_amber_rounded,
                                              color: AppTheme.neuralOrange, size: 12),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Review needed',
                                            style: TextStyle(
                                              color: AppTheme.neuralOrange,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${t['amount']}',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  t['category_id'] != null ? 'Categorized' : 'Uncategorized',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.4),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}
