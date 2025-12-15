class BrainService {
  // Singleton
  static final BrainService _instance = BrainService._internal();
  factory BrainService() => _instance;
  BrainService._internal();

  /// FR-14: Cross-Cut Logic
  /// Suggests budget cuts in flexible categories if a high expense is detected.
  BrainInsight? analyzeCrossCut({
    required double safeToSpend,
    required List<Map<String, dynamic>> transactions,
    required double monthlyIncome,
  }) {
    // 1. Detect anomalous high spending (e.g., > 20% of income)
    final highTxs = transactions.where((t) {
      final amt = (t['amount'] as num).toDouble();
      return amt > (monthlyIncome * 0.15); // Threshold 15%
    }).toList();

    if (highTxs.isEmpty) return null;

    // Pick the most recent big purchase
    final trigger = highTxs.first;
    final triggerAmt = (trigger['amount'] as num).toDouble();
    final remainingSafe = safeToSpend;

    if (remainingSafe < 0) {
      // Danger zone! Suggest cuts.
      // Mock flexible categories (in real app, query 'categories' table where is_flexible=true)
      final flexible = ['Dining', 'Entertainment', 'Shopping']; 
      
      return BrainInsight(
        title: 'Budget Alert',
        message: 'High spend on "${trigger['description_raw']}" (₹$triggerAmt). To recover, consider reducing Dining & Entertainment by 20% this week.',
        type: InsightType.crossCut,
        severity: InsightSeverity.critical,
      );
    }
    
    return null;
  }

  /// FR-15: Loop Detection
  /// Identify transfer loops (Me -> A -> Me) to avoid double counting.
  List<String> detectLoops(List<Map<String, dynamic>> transactions) {
    // Naive implementation: Look for +/- same amount within 24 hours
    // This requires access to Inflow/Outflow which our basic schema simplifies to amount signedness or 'type'
    // Assuming transactions have signed amounts or 'type' field.
    // For this prototype, we'll return IDs of suspected loops.
    return [];
  }

  /// FR-16: Recurring Prediction
  /// Predicts next bill based on patterns.
  List<BrainPrediction> predictRecurring(List<Map<String, dynamic>> transactions) {
    // Group by description (approx)
    // If frequency is regular (approx 30 days gap), predict next.
    
    // Stub logic
    return [
      BrainPrediction(
        title: 'Subscription',
        description: 'Netflix due in 3 days',
        amount: 499,
        date: DateTime.now().add(const Duration(days: 3)),
        confidence: 0.9,
      ),
      BrainPrediction(
        title: 'Utility',
        description: 'Electricity Bill Estimate',
        amount: 1500,
        date: DateTime.now().add(const Duration(days: 10)),
        confidence: 0.75,
      ),
    ];
  }
}

enum InsightType { crossCut, budget, outlier, loop }
enum InsightSeverity { info, warning, critical }

class BrainInsight {
  final String title;
  final String message;
  final InsightType type;
  final InsightSeverity severity;

  BrainInsight({required this.title, required this.message, required this.type, required this.severity});
}

class BrainPrediction {
  final String title;
  final String description;
  final double amount;
  final DateTime date;
  final double confidence;

  BrainPrediction({required this.title, required this.description, required this.amount, required this.date, required this.confidence});
}
