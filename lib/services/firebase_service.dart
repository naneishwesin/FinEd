// lib/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Authentication Methods
  static User? get currentUser {
    try {
      return _auth.currentUser;
    } catch (e) {
      print('Firebase Auth not available: $e');
      return null;
    }
  }

  static bool get isLoggedIn {
    try {
      return _auth.currentUser != null;
    } catch (e) {
      print('Firebase Auth not available: $e');
      return false;
    }
  }

  // Stream for auth state changes
  static Stream<User?> get authStateChanges {
    try {
      return _auth.authStateChanges();
    } catch (e) {
      print('Firebase Auth stream not available: $e');
      return Stream.value(null);
    }
  }

  // Email/Password Authentication
  static Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } catch (e) {
      print('Sign up error: $e');
      // Handle specific Firebase errors
      if (e.toString().contains('network') ||
          e.toString().contains('reCAPTCHA')) {
        throw Exception(
          'Network error: Please check your internet connection or try again later.',
        );
      } else if (e.toString().contains('email-already-in-use')) {
        throw Exception(
          'This email is already registered. Please try signing in instead.',
        );
      } else if (e.toString().contains('weak-password')) {
        throw Exception(
          'Password is too weak. Please use at least 6 characters.',
        );
      } else if (e.toString().contains('invalid-email')) {
        throw Exception('Please enter a valid email address.');
      }
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  static Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } catch (e) {
      print('Sign in error: $e');
      // Handle specific Firebase errors
      if (e.toString().contains('network') ||
          e.toString().contains('reCAPTCHA')) {
        throw Exception(
          'Network error: Please check your internet connection or try again later.',
        );
      } else if (e.toString().contains('user-not-found')) {
        throw Exception(
          'No account found with this email. Please sign up first.',
        );
      } else if (e.toString().contains('wrong-password')) {
        throw Exception('Incorrect password. Please try again.');
      } else if (e.toString().contains('invalid-email')) {
        throw Exception('Please enter a valid email address.');
      }
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  // Test authentication for emulator (temporary bypass)
  static Future<UserCredential?> signUpWithEmailTest({
    required String email,
    required String password,
  }) async {
    try {
      // Try normal authentication first
      return await signUpWithEmail(email: email, password: password);
    } catch (e) {
      // If network error, create a mock user for testing
      if (e.toString().contains('Network error') ||
          e.toString().contains('reCAPTCHA')) {
        print('Using test mode due to network issues');
        // Create a mock user credential for testing
        // This is only for development/testing purposes
        return null; // Will be handled by the auth page
      }
      rethrow;
    }
  }

  // Google Sign In
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  // Sign Out
  static Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
  }

  // Password Reset
  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  // Firestore Data Operations
  static CollectionReference get _usersCollection =>
      _firestore.collection('users');

  static DocumentReference get _currentUserDoc =>
      _usersCollection.doc(currentUser?.uid);

  // User Profile Operations
  static Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    if (currentUser == null) throw Exception('User not authenticated');

    await _currentUserDoc.set({
      'profile': profile,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<Map<String, dynamic>?> getUserProfile() async {
    if (currentUser == null) return null;

    final doc = await _currentUserDoc.get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>?;
      return data?['profile'] as Map<String, dynamic>?;
    }
    return null;
  }

  // Transactions Operations
  static Future<void> saveTransactions(
    List<Map<String, dynamic>> transactions,
  ) async {
    if (currentUser == null) throw Exception('User not authenticated');

    await _currentUserDoc.set({
      'transactions': transactions,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<List<Map<String, dynamic>>> getTransactions() async {
    if (currentUser == null) return [];

    final doc = await _currentUserDoc.get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>?;
      final transactions = data?['transactions'] as List<dynamic>?;
      return transactions?.cast<Map<String, dynamic>>() ?? [];
    }
    return [];
  }

  // Update a single transaction
  static Future<void> updateTransaction(
    int localId,
    Map<String, dynamic> transaction,
  ) async {
    if (currentUser == null) throw Exception('User not authenticated');

    final transactions = await getTransactions();
    final index = transactions.indexWhere((t) => t['id'] == localId);

    if (index != -1) {
      transactions[index] = transaction;
      await saveTransactions(transactions);
    }
  }

  // Delete a single transaction
  static Future<void> deleteTransaction(int localId) async {
    if (currentUser == null) throw Exception('User not authenticated');

    final transactions = await getTransactions();
    transactions.removeWhere((t) => t['id'] == localId);
    await saveTransactions(transactions);
  }

  // Balance Operations
  static Future<void> saveBalance(String type, double amount) async {
    if (currentUser == null) throw Exception('User not authenticated');

    await _currentUserDoc.set({
      type: amount,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Emergency Fund Operations
  static Future<void> saveEmergencyFund(double amount) async {
    if (currentUser == null) throw Exception('User not authenticated');

    await _currentUserDoc.set({
      'emergencyFund': amount,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<double> getEmergencyFund() async {
    if (currentUser == null) return 0.0;

    final doc = await _currentUserDoc.get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>?;
      return (data?['emergencyFund'] as num?)?.toDouble() ?? 0.0;
    }
    return 0.0;
  }

  // Investments Operations
  static Future<void> saveInvestments(
    List<Map<String, dynamic>> investments,
  ) async {
    if (currentUser == null) throw Exception('User not authenticated');

    await _currentUserDoc.set({
      'investments': investments,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<List<Map<String, dynamic>>> getInvestments() async {
    if (currentUser == null) return [];

    final doc = await _currentUserDoc.get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>?;
      final investments = data?['investments'] as List<dynamic>?;
      return investments?.cast<Map<String, dynamic>>() ?? [];
    }
    return [];
  }

  // App Settings Operations
  static Future<void> saveAppSettings(Map<String, dynamic> settings) async {
    if (currentUser == null) throw Exception('User not authenticated');

    await _currentUserDoc.set({
      'settings': settings,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<Map<String, dynamic>> getAppSettings() async {
    if (currentUser == null) return _getDefaultSettings();

    final doc = await _currentUserDoc.get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>?;
      final settings = data?['settings'] as Map<String, dynamic>?;
      return settings ?? _getDefaultSettings();
    }
    return _getDefaultSettings();
  }

  // Financial Data Operations
  static Future<void> saveFinancialData({
    required double currentBalance,
    required double totalIncome,
    required double totalExpenses,
  }) async {
    if (currentUser == null) throw Exception('User not authenticated');

    await _currentUserDoc.set({
      'financialData': {
        'currentBalance': currentBalance,
        'totalIncome': totalIncome,
        'totalExpenses': totalExpenses,
      },
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<Map<String, double>> getFinancialData() async {
    if (currentUser == null) {
      return {'currentBalance': 0.0, 'totalIncome': 0.0, 'totalExpenses': 0.0};
    }

    final doc = await _currentUserDoc.get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>?;
      final financialData = data?['financialData'] as Map<String, dynamic>?;
      return {
        'currentBalance':
            (financialData?['currentBalance'] as num?)?.toDouble() ?? 0.0,
        'totalIncome':
            (financialData?['totalIncome'] as num?)?.toDouble() ?? 0.0,
        'totalExpenses':
            (financialData?['totalExpenses'] as num?)?.toDouble() ?? 0.0,
      };
    }
    return {'currentBalance': 0.0, 'totalIncome': 0.0, 'totalExpenses': 0.0};
  }

  // Real-time Listeners
  static Stream<DocumentSnapshot> getUserDataStream() {
    if (currentUser == null) throw Exception('User not authenticated');
    return _currentUserDoc.snapshots();
  }

  // Default Settings
  static Map<String, dynamic> _getDefaultSettings() {
    return {
      'theme': 'light',
      'language': 'English',
      'currency': 'Thai Baht (฿)',
      'monthly_start_date': 1,
      'daily_reminder': false,
      'spending_alerts': true,
      'goal_reminders': false,
      'budget_alerts': false,
    };
  }

  // Initialize Firebase
  static Future<void> initialize() async {
    // Firebase will be initialized in main.dart
    // This method is here for future initialization needs
  }
}
