import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService(this.client);

  final SupabaseClient client;

  // Auth
  Future<AuthResponse> signIn(String email, String password) {
    return client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUp(String email, String password) {
    return client.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() => client.auth.signOut();

  // Profile
  Future<void> createProfile({
    required String fullName,
    required num income,
    required num taxPercent,
    required num shortTerm,
    required num longTerm,
  }) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw const AuthException('No user');

    await client.from('profiles').upsert({
      'id': userId,
      'full_name': fullName,
      'monthly_income_target': income,
      'tax_percentage': taxPercent,
      'savings_goal_short_term': shortTerm,
      'savings_goal_long_term': longTerm,
    });

    // seed default categories
    await client.rpc(
      'seed_default_categories',
      params: {'target_user': userId},
    );
  }

  Future<Map<String, dynamic>?> fetchProfile() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return null;
    final res = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return res;
  }

  // Categories
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return [];
    final res = await client
        .from('categories')
        .select()
        .or('user_id.eq.$userId,is_system_default.eq.true');
    return List<Map<String, dynamic>>.from(res);
  }

  // Transactions
  Future<Map<String, dynamic>> addTransaction({
    required num amount,
    required String description,
    required DateTime date,
    String? paymentMethod,
    bool isPersonal = false,
    String? categoryId,
    double? confidence,
  }) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw const AuthException('No user');
    final insert = await client
        .from('transactions')
        .insert({
          'user_id': userId,
          'amount': amount,
          'description_raw': description,
          'transaction_date': date.toIso8601String(),
          'payment_method': paymentMethod,
          'is_personal': isPersonal,
          'category_id': categoryId,
          'confidence_score': confidence,
        })
        .select()
        .single();
    return insert;
  }

  Future<List<Map<String, dynamic>>> listTransactions({int limit = 50}) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return [];
    final res = await client
        .from('transactions')
        .select(
          'id,amount,description_raw,transaction_date,confidence_score,status,category_id,is_personal',
        )
        .eq('user_id', userId)
        .order('transaction_date', ascending: false)
        .limit(limit);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> updateTransactionStatus(String id, String status) async {
    await client.from('transactions').update({'status': status}).eq('id', id);
  }

  Future<void> deleteTransaction(String id) async {
    await client.from('transactions').delete().eq('id', id);
  }

  // Notifications prefs
  Future<void> updateNotificationPrefs(Map<String, dynamic> prefs) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;
    await client
        .from('profiles')
        .update({'notification_preferences': prefs})
        .eq('id', userId);
  }

  Future<List<Map<String, dynamic>>> listNotifications() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return [];
    final res = await client
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(50);
    return List<Map<String, dynamic>>.from(res);
  }

  // Savings goals
  Future<void> upsertSavingsGoal({
    String? id,
    required String name,
    required String type,
    required num targetAmount,
    num? monthlyContribution,
    DateTime? targetDate,
  }) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;
    await client.from('savings_goals').upsert({
      if (id != null) 'id': id,
      'user_id': userId,
      'goal_name': name,
      'goal_type': type,
      'target_amount': targetAmount,
      'monthly_contribution': monthlyContribution,
      'target_date': targetDate?.toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> listSavingsGoals() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return [];
    final res = await client
        .from('savings_goals')
        .select()
        .eq('user_id', userId);
    return List<Map<String, dynamic>>.from(res);
  }

  // Trips
  Future<void> upsertTrip({
    String? id,
    required String name,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    num? estimatedBudget,
  }) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;
    await client.from('trips').upsert({
      if (id != null) 'id': id,
      'user_id': userId,
      'trip_name': name,
      'destination': destination,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'estimated_budget': estimatedBudget,
    });
  }

  Future<List<Map<String, dynamic>>> listTrips() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return [];
    final res = await client
        .from('trips')
        .select()
        .eq('user_id', userId)
        .order('start_date');
    return List<Map<String, dynamic>>.from(res);
  }
}
