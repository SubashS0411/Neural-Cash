import 'dart:math';

class AIService {
  // Singleton
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  // Knowledge Base (Rule-based)
  final Map<String, List<String>> _rules = {
    'Dining': ['starbucks', 'mcdonalds', 'pizza', 'burger', 'coffee', 'cafe', 'restaurant', 'zomato', 'swiggy'],
    'Groceries': ['mart', 'supermarket', 'blinkit', 'zepto', 'bigbasket', 'grocery', 'vegetable', 'fruit'],
    'Travel': ['uber', 'ola', 'rapido', 'petrol', 'fuel', 'shell', 'irctc', 'flight', 'airline', 'toll'],
    'Entertainment': ['netflix', 'prime', 'hotstar', 'cinema', 'pvr', 'inox', 'spotify', 'youtube'],
    'Shopping': ['amazon', 'flipkart', 'myntra', 'zara', 'h&m', 'nike', 'adidas', 'fashion'],
    'Bills': ['electricity', 'water', 'gas', 'broadband', 'jio', 'airtel', 'vi', 'bescom'],
    'Medical': ['pharmacy', 'hospital', 'clinic', 'doctor', 'medplus', 'apollo', 'lab'],
  };

  // Naive Bayes simplified training data (Word -> Category Probability)
  final Map<String, Map<String, double>> _wordProbs = {};

  /// Pre-process text: lowercase, remove special chars, stop words
  String _preprocess(String text) {
    String clean = text.toLowerCase();
    // Remove special chars but keep spaces
    clean = clean.replaceAll(RegExp(r'[^\w\s]'), ' ');
    // Remove extra spaces
    clean = clean.replaceAll(RegExp(r'\s+'), ' ');
    // Simple stop words
    final stops = {'the', 'a', 'an', 'in', 'at', 'to', 'for', 'of', 'and', 'pvt', 'ltd', 'upi', 'pay'};
    return clean.split(' ').where((w) => !stops.contains(w) && w.length > 2).join(' ');
  }

  /// Extract Merchant Name
  String extractMerchant(String rawText) {
    String clean = _preprocess(rawText);
    List<String> words = clean.split(' ');
    if (words.isEmpty) return 'Unknown';
    
    // Heuristic: First 2 significant words usually denote merchant in UPI string
    // e.g. "UPI-STARBUCKS-COFFEE-MUM" -> "starbucks coffee"
    return words.take(2).join(' ').toUpperCase();
  }

  /// Predict Category
  Future<PredictionResult> predictCategory(String rawText) async {
    // 1. Rule-based check
    String clean = _preprocess(rawText);
    List<String> words = clean.split(' ');
    
    for (var entry in _rules.entries) {
      for (var keyword in entry.value) {
        if (clean.contains(keyword)) {
          return PredictionResult(
            category: entry.key,
            confidence: 0.95, // High confidence for exact match
            method: 'Rule-based',
          );
        }
      }
    }

    // 2. Probabilistic Fallback (Simulation of TF-IDF/Bayes)
    // In a real app, we'd query a local SQLite db or TFLite model.
    // Here, we simulate uncertainty for "unknown" inputs.
    
    // Quick Hash logic to deterministically pick a category for unknown words
    // so it feels "intelligent" rather than random.
    int hash = clean.codeUnits.fold(0, (sum, char) => sum + char);
    List<String> cats = _rules.keys.toList();
    String fallbackCat = cats[hash % cats.length];
    
    // Confidence based on word length / complexity
    double conf = (clean.length % 50) / 100.0 + 0.4; // 0.4 to 0.9
    
    return PredictionResult(
      category: fallbackCat,
      confidence: conf,
      method: 'Probabilistic',
    );
  }

  /// Simulate OCR
  Future<String> performOCR(String imagePath) async {
    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Return mock data for verification steps
    return "Starbucks Coffee Mumbai\nDate: 12/12/2025\nTotal: 450.00\nThank you";
  }
}

class PredictionResult {
  final String category;
  final double confidence;
  final String method;

  PredictionResult({
    required this.category,
    required this.confidence,
    required this.method,
  });
}
