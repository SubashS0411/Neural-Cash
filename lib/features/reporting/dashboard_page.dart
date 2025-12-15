import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/supabase_service.dart';
import '../../widgets/glass_container.dart';
import '../../theme/app_theme.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.client});

  final SupabaseClient client;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _loading = true;
  List<Map<String, dynamic>> _transactions = [];
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _savings = [];
  List<Map<String, dynamic>> _trips = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final svc = SupabaseService(widget.client);
    final profile = await svc.fetchProfile();
    final tx = await svc.listTransactions(limit: 20);
    final savings = await svc.listSavingsGoals();
    final trips = await svc.listTrips();
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _transactions = tx;
      _savings = savings;
      _trips = trips;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final income = (_profile?['monthly_income_target'] ?? 0).toDouble();
    final tax = (_profile?['tax_percentage'] ?? 0).toDouble();
    final expenses = _transactions.fold<double>(
      0,
      (sum, t) => sum + (t['amount'] as num).toDouble(),
    );
    final postTaxIncome = income - (income * tax / 100);
    final safeToSpend = postTaxIncome - expenses;
    final userName = _profile?['full_name']?.split(' ').first ?? 'User';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good Morning,',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          userName,
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    GlassContainer(
                      width: 50,
                      height: 50,
                      borderRadius: BorderRadius.circular(14),
                      padding: EdgeInsets.zero,
                      child: const Center(
                        child: Icon(Icons.notifications_none_rounded, color: Colors.white),
                      ),
                      onTap: () {
                        // Navigate to notifications via shell logic if possible or direct push
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Safe to Spend Hero Card
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: GlassContainer(
                  height: 180,
                  borderRadius: BorderRadius.circular(24),
                  padding: const EdgeInsets.all(24),
                  color: AppTheme.neuralBlue.withOpacity(0.1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.neuralGreen.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Safe to Spend',
                              style: TextStyle(color: AppTheme.neuralGreen, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Icon(Icons.account_balance_wallet_outlined, color: Colors.white54),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₹${safeToSpend.toStringAsFixed(0)}',
                            style: GoogleFonts.outfit(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'of ₹${postTaxIncome.toStringAsFixed(0)} post-tax income',
                            style: TextStyle(color: Colors.white.withOpacity(0.5)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Stats Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _StatItem(
                    title: 'Spent',
                    value: '₹${expenses.toStringAsFixed(0)}',
                    color: AppTheme.neuralRed,
                    icon: Icons.trending_up_rounded,
                  ),
                  _StatItem(
                    title: 'Savings',
                    value: '₹${_savings.fold<double>(0, (sum, g) => sum + (g['current_amount'] ?? 0)).toStringAsFixed(0)}',
                    color: AppTheme.neuralPurple,
                    icon: Icons.savings_outlined,
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Behavioral Insights
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: _BehavioralInsightCard(
                  transactions: _transactions,
                  safeToSpend: safeToSpend,
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Chart Section
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: GlassContainer(
                  height: 250,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Spending Trend',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: const FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                isCurved: true,
                                color: AppTheme.neuralBlue,
                                barWidth: 4,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: AppTheme.neuralBlue.withOpacity(0.1),
                                ),
                                spots: _transactions
                                    .asMap()
                                    .entries
                                    .map(
                                      (e) => FlSpot(
                                        e.key.toDouble(),
                                        (e.value['amount'] as num).toDouble(),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Recent Transactions Header
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Activity',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    TextButton(
                      onPressed: () {
                         // Switch tab logic via parent or notification not easily possible unless passing callback.
                         // But usually "See All" just goes to transactions tab. 
                         // For now, simple text.
                      },
                      child: const Text('See All'),
                    ),
                  ],
                ),
              ),
            ),

            // Transactions List
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 120), // Bottom padding for Shell FAB
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final t = _transactions[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassContainer(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.neuralBlue.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.shopping_bag_outlined, color: AppTheme.neuralBlue, size: 20),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t['description_raw'] ?? 'Unknown',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  Text(
                                    t['transaction_date']?.toString().split(' ').first ?? '',
                                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '- ₹${t['amount']}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: _transactions.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatItem({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.white.withOpacity(0.6))),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BehavioralInsightCard extends StatelessWidget {
  const _BehavioralInsightCard({
    required this.transactions,
    required this.safeToSpend,
  });

  final List<Map<String, dynamic>> transactions;
  final double safeToSpend;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? biggest;
    for (final t in transactions) {
      if (biggest == null || (t['amount'] as num) > (biggest['amount'] as num)) {
        biggest = t;
      }
    }
    
    // Check if we have enough data
    if (biggest == null) return const SizedBox.shrink();

    return GlassContainer(
      color: AppTheme.neuralPurple.withOpacity(0.1),
      border: Border.all(color: AppTheme.neuralPurple.withOpacity(0.3)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.neuralPurple.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, color: AppTheme.neuralPurple),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Insight',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.neuralPurple),
                ),
                const SizedBox(height: 4),
                Text(
                  'High spend on ${biggest['description_raw']}. Consider reducing other budgets.',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
