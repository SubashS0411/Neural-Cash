class SavingsLogic {
  static final SavingsLogic _instance = SavingsLogic._internal();
  factory SavingsLogic() => _instance;
  SavingsLogic._internal();

  /// FR-19: Tax Calculation
  /// Simple Slab-based estimation (India 2024 New Regime approx)
  double calculateTax(double annualIncome) {
    if (annualIncome <= 300000) return 0;
    
    double taxable = annualIncome - 75000; // Standard Deduction
    double tax = 0;

    // Slabs
    if (taxable > 300000) {
      double slab = (taxable > 600000 ? 600000 : taxable) - 300000;
      tax += slab * 0.05;
    }
    if (taxable > 600000) {
      double slab = (taxable > 900000 ? 900000 : taxable) - 600000;
      tax += slab * 0.10;
    }
    if (taxable > 900000) {
      double slab = (taxable > 1200000 ? 1200000 : taxable) - 900000;
      tax += slab * 0.15;
    }
    if (taxable > 1200000) {
      double slab = (taxable > 1500000 ? 1500000 : taxable) - 1200000;
      tax += slab * 0.20;
    }
    if (taxable > 1500000) {
      tax += (taxable - 1500000) * 0.30;
    }

    return tax;
  }

  /// FR-22: Installment Plan (No Cost EMI vs Cash Down)
  /// Returns recommendation.
  String analyzeInstallment({
    required double price,
    required double downPayment,
    required int months,
    required double interestRate, // 0 for No Cost EMI
    required double savingsReturnRate, // e.g. 0.06 (6% FD)
  }) {
    // Scenario 1: Pay Full Cash
    double cashCost = price;

    // Scenario 2: EMI
    // If No Cost (interest = 0), we keep the principal in bank earning interest
    double monthlyEMI = (price - downPayment) / months;
    if (interestRate > 0) {
      // Simple Interest approximation for decision helper
      monthlyEMI += (price - downPayment) * (interestRate / 12 / 100);
    }
    
    // We hold the money and pay monthly. 
    // Average balance held over the period roughly equals (Principal / 2)
    // Interest earned = (Principal / 2) * (rate / 12) * months
    double interestEarned = ((price - downPayment) / 2) * savingsReturnRate * (months / 12);
    
    double effectiveEMICost = (monthlyEMI * months) + downPayment - interestEarned;
    
    if (effectiveEMICost < cashCost) {
      return "Go for EMI! You save approx ₹${(cashCost - effectiveEMICost).toStringAsFixed(0)} by keeping funds in savings.";
    } else {
      return "Pay Cash. EMI effective cost is higher by ₹${(effectiveEMICost - cashCost).toStringAsFixed(0)}.";
    }
  }

  /// FR-21: Savings Exceeded
  bool checkSavingsTarget(double current, double target) {
    return current >= target;
  }
}
