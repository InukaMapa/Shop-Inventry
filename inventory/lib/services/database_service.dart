import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // --- CATEGORIES ---
  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await _supabase.from('categories').select().order('title');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addCategory(String title, {String? iconName, String? colorHex}) async {
    await _supabase.from('categories').insert({
      'title': title,
      'icon_name': iconName,
      'color_hex': colorHex,
    });
  }

  // --- COMPUTERS / INVENTORY ---
  Future<List<Map<String, dynamic>>> getComputers({String? category}) async {
    var query = _supabase.from('computers').select();
    
    if (category != null && category.isNotEmpty) {
      query = query.eq('storage', category); 
    }

    final response = await query.order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> upsertComputer(Map<String, dynamic> data, {String? id}) async {
    if (id != null) {
      await _supabase.from('computers').update(data).eq('id', id);
    } else {
      await _supabase.from('computers').insert(data);
    }
  }

  Future<void> deleteComputer(String id) async {
    await _supabase.from('computers').delete().eq('id', id);
  }

  // --- ORDERS ---
  Future<List<Map<String, dynamic>>> getOrders() async {
    final response = await _supabase.from('orders').select().order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> placeOrder(double total, List<Map<String, dynamic>> items) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw 'User not authenticated';

    await _supabase.from('orders').insert({
      'user_id': user.id,
      'total_amount': total,
      'items': items,
      'status': 'Pending',
    });
  }
}
