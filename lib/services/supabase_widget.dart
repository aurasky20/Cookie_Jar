import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cookies.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Get all products
  static Future<List<Cookies>> getAllCookies() async {
    try {
      final response = await _client
          .from('produk')
          .select('*')
          .order('created_at', ascending: false);
      
      return response.map((item) => Cookies.fromJson(item)).toList();
    } catch (e) {
      print('Error fetching cookies: $e');
      throw Exception('Failed to fetch cookies: $e');
    }
  }

  // Get popular cookies (limit 10)
  static Future<List<Cookies>> getPopularCookies() async {
    try {
      final response = await _client
          .from('produk')
          .select('*')
          .order('stok', ascending: false) // Assuming popular = high stock
          .limit(10);
      
      return response.map((item) => Cookies.fromJson(item)).toList();
    } catch (e) {
      print('Error fetching popular cookies: $e');
      throw Exception('Failed to fetch popular cookies: $e');
    }
  }

  // Get recommended cookies (random selection)
  static Future<List<Cookies>> getRecommendedCookies() async {
    try {
      final response = await _client
          .from('produk')
          .select('*')
          .limit(5);
      
      return response.map((item) => Cookies.fromJson(item)).toList();
    } catch (e) {
      print('Error fetching recommended cookies: $e');
      throw Exception('Failed to fetch recommended cookies: $e');
    }
  }

  // Get cookie by ID
  static Future<Cookies?> getCookieById(int id) async {
    try {
      final response = await _client
          .from('produk')
          .select('*')
          .eq('id', id)
          .single();
      
      return Cookies.fromJson(response);
    } catch (e) {
      print('Error fetching cookie by ID: $e');
      return null;
    }
  }

  // Search cookies by name
  static Future<List<Cookies>> searchCookies(String query) async {
    try {
      final response = await _client
          .from('produk')
          .select('*')
          .ilike('nama_produk', '%$query%');
      
      return response.map((item) => Cookies.fromJson(item)).toList();
    } catch (e) {
      print('Error searching cookies: $e');
      throw Exception('Failed to search cookies: $e');
    }
  }

  // Insert new cookie (for admin)
  static Future<Cookies?> insertCookie(Cookies cookie) async {
    try {
      final response = await _client
          .from('produk')
          .insert(cookie.toInsert())
          .select()
          .single();
      
      return Cookies.fromJson(response);
    } catch (e) {
      print('Error inserting cookie: $e');
      throw Exception('Failed to insert cookie: $e');
    }
  }

  // Update cookie (for admin)
  static Future<Cookies?> updateCookie(int id, Cookies cookie) async {
    try {
      final response = await _client
          .from('produk')
          .update(cookie.toUpdate())
          .eq('id', id)
          .select()
          .single();
      
      return Cookies.fromJson(response);
    } catch (e) {
      print('Error updating cookie: $e');
      throw Exception('Failed to update cookie: $e');
    }
  }

  // Delete cookie (for admin)
  static Future<bool> deleteCookie(int id) async {
    try {
      await _client
          .from('produk')
          .delete()
          .eq('id', id);
      
      return true;
    } catch (e) {
      print('Error deleting cookie: $e');
      return false;
    }
  }

  // Update stock
  static Future<bool> updateStock(int id, int newStock) async {
    try {
      await _client
          .from('produk')
          .update({'stok': newStock, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', id);
      
      return true;
    } catch (e) {
      print('Error updating stock: $e');
      return false;
    }
  }
}