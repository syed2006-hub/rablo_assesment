import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../D1CM1_login/firebase_auth_service.dart';

/// CustomerFirebaseService
/// Central Firebase Firestore & persistent session manager for Customer Modules (D1CM).
/// Provides real-time synchronization for:
/// - User Profiles (users/{uid})
/// - Login Credentials & Session state (SharedPreferences + Firebase Auth)
/// - Onboarding Details
/// - Gym Businesses & Affiliation Scanning (businesses/{id})
/// - Membership Plans & Active Subscriptions (membership_plans/{id})
/// - Session Redemptions & Daily Scan Logs (users/{uid}/redemptions)
/// - Customer Reviews & Ratings (reviews/{id})
class CustomerFirebaseService extends GetxService {
  static CustomerFirebaseService get to => Get.find<CustomerFirebaseService>();

  FirebaseFirestore? _firestore;
  SharedPreferences? _prefs;

  // Real-time observable state
  final Rx<Map<String, dynamic>?> currentUserProfile = Rx<Map<String, dynamic>?>(null);
  final Rx<Map<String, dynamic>?> currentAffiliation = Rx<Map<String, dynamic>?>(null);
  final Rx<Map<String, dynamic>?> activePlan = Rx<Map<String, dynamic>?>(null);
  final RxBool isLoggedIn = false.obs;
  final RxBool isOnboarded = false.obs;
  final RxString currentUid = ''.obs;
  final RxBool hasScannedFirstSession = false.obs;
  final RxBool isDashboardV2Active = false.obs;

  final List<Map<String, dynamic>> _mockBankAccounts = <Map<String, dynamic>>[
    {
      'id': 'acc_1',
      'bankName': 'HDFC Bank',
      'accountHolderName': 'Alex Morgan',
      'accountNumber': '**** **** 4892',
      'fullAccountNumber': '50100234564892',
      'ifscCode': 'HDFC0001234',
      'branch': 'Indiranagar, Bengaluru',
      'isPrimary': true,
      'isVerified': true,
      'balance': '20,014.00',
      'isBalanceVisible': false,
    },
  ];
  final List<Map<String, dynamic>> _mockTransactions = <Map<String, dynamic>>[];
  final List<Map<String, dynamic>> _mockTrainers = <Map<String, dynamic>>[];
  final List<Map<String, dynamic>> _mockBusinessConnects = <Map<String, dynamic>>[];

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _profileSub;

  bool get _isTestEnvironment {
    try {
      return WidgetsBinding.instance.runtimeType.toString().contains('Test');
    } catch (_) {
      return false;
    }
  }

  FirebaseFirestore? get firestore {
    if (_isTestEnvironment) return null;
    try {
      _firestore ??= FirebaseFirestore.instance;
      return _firestore;
    } catch (e) {
      debugPrint('FirebaseFirestore initialization notice: $e');
      return null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    initService();
  }

  @override
  void onClose() {
    _profileSub?.cancel();
    super.onClose();
  }

  /// Initialize persistent storage and check active Firebase Auth session
  Future<void> initService() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await restoreSession();
      await _seedDefaultFirestoreData();
    } catch (e) {
      debugPrint('CustomerFirebaseService init error: $e');
    }
  }

  // =========================================================================
  // 1. LOGIN CREDENTIALS & SESSION STORAGE
  // =========================================================================

  /// Save login credentials and session tokens to SharedPreferences
  Future<void> saveLoginCredentials({
    required String uid,
    required String email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    String? token,
    bool rememberMe = true,
  }) async {
    _prefs ??= await SharedPreferences.getInstance();
    currentUid.value = uid;
    isLoggedIn.value = true;

    await _prefs!.setString('customer_uid', uid);
    await _prefs!.setString('customer_email', email);
    if (displayName != null) await _prefs!.setString('customer_name', displayName);
    if (photoUrl != null) await _prefs!.setString('customer_photo', photoUrl);
    if (phoneNumber != null) await _prefs!.setString('customer_phone', phoneNumber);
    if (token != null) await _prefs!.setString('customer_token', token);
    await _prefs!.setBool('is_logged_in', true);
    await _prefs!.setString('last_login_timestamp', DateTime.now().toIso8601String());

    // Listen to real-time updates for this user in Firestore
    startListeningToUserProfile(uid);
  }

  /// Restore user session directly from Cloud Firestore
  Future<void> restoreSession() async {
    _prefs ??= await SharedPreferences.getInstance();

    final fbUser = FirebaseAuthService.instance.currentFirebaseUser;
    final savedUid = _prefs?.getString('customer_uid') ?? fbUser?.uid ?? '';
    final savedEmail = _prefs?.getString('customer_email') ?? fbUser?.email ?? '';
    final loggedIn = _prefs?.getBool('is_logged_in') ?? (fbUser != null);

    if (savedUid.isNotEmpty && loggedIn) {
      debugPrint('Restoring active session from Cloud Firestore for: $savedEmail ($savedUid)');
      currentUid.value = savedUid;
      isLoggedIn.value = true;

      // 1. Retrieve directly from Cloud Firestore
      final profileData = await fetchUserProfile(savedUid);
      if (profileData != null && profileData.isNotEmpty) {
        currentUserProfile.value = profileData;
        currentAffiliation.value = profileData['currentAffiliation'] as Map<String, dynamic>?;
        activePlan.value = profileData['activePlan'] as Map<String, dynamic>?;
        isOnboarded.value = profileData['isOnboarded'] == true;
        if (profileData['isDashboardV2Active'] == true) {
          isDashboardV2Active.value = true;
        }
        if (profileData['hasScannedFirstSession'] == true) {
          hasScannedFirstSession.value = true;
        }
      } else {
        // Fallback to local cache if offline
        final cachedProfileStr = _prefs?.getString('profile_$savedUid');
        if (cachedProfileStr != null) {
          try {
            final cached = jsonDecode(cachedProfileStr) as Map<String, dynamic>;
            currentUserProfile.value = cached;
            currentAffiliation.value = cached['currentAffiliation'] as Map<String, dynamic>?;
            activePlan.value = cached['activePlan'] as Map<String, dynamic>?;
            if (cached['isOnboarded'] == true) {
              isOnboarded.value = true;
            }
            if (cached['isDashboardV2Active'] == true) {
              isDashboardV2Active.value = true;
            }
            if (cached['hasScannedFirstSession'] == true) {
              hasScannedFirstSession.value = true;
            }
          } catch (_) {}
        }
      }

      final prefV2Active = _prefs?.getBool('is_dashboard_v2_active_$savedUid') ?? false;
      if (prefV2Active) {
        isDashboardV2Active.value = true;
      }

      startListeningToUserProfile(savedUid);
    } else {
      isLoggedIn.value = false;
      isOnboarded.value = false;
      isDashboardV2Active.value = false;
    }
  }

  /// Persist Dashboard V2 activation status to Cloud Firestore & local storage
  Future<void> setDashboardV2Active(String uid, bool active) async {
    isDashboardV2Active.value = active;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setBool('is_dashboard_v2_active_$uid', active);
    await updateUserFields(uid, {'isDashboardV2Active': active});
  }

  /// Clear session credentials on logout
  Future<void> clearLoginCredentials() async {
    _profileSub?.cancel();
    _prefs ??= await SharedPreferences.getInstance();

    await _prefs!.remove('customer_uid');
    await _prefs!.remove('customer_email');
    await _prefs!.remove('customer_token');
    await _prefs!.setBool('is_logged_in', false);

    currentUid.value = '';
    isLoggedIn.value = false;
    currentUserProfile.value = null;
    currentAffiliation.value = null;
    activePlan.value = null;
    isDashboardV2Active.value = false;
    hasScannedFirstSession.value = false;
  }

  // =========================================================================
  // 2. REALTIME USER PROFILE (users/{uid})
  // =========================================================================

  /// Listen to real-time profile updates from Cloud Firestore
  void startListeningToUserProfile(String uid) {
    _profileSub?.cancel();

    final fs = firestore;
    if (fs == null) return;

    try {
      _profileSub = fs.collection('users').doc(uid).snapshots().listen(
        (snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            final data = snapshot.data()!;
            currentUserProfile.value = data;
            currentAffiliation.value = data['currentAffiliation'] as Map<String, dynamic>?;
            activePlan.value = data['activePlan'] as Map<String, dynamic>?;

            final onboarded = data['isOnboarded'] == true;
            isOnboarded.value = onboarded;

            // Cache locally
            _prefs?.setString('profile_$uid', jsonEncode(data));
            _prefs?.setBool('onboarded_$uid', onboarded);
          }
        },
        onError: (err) {
          debugPrint('Firestore profile listen error: $err');
        },
      );
    } catch (e) {
      debugPrint('Could not bind Firestore listener: $e');
    }
  }

  /// Fetch user profile directly from Cloud Firestore (users/{uid})
  Future<Map<String, dynamic>?> fetchUserProfile(String uid) async {
    final effectiveUid = uid.isNotEmpty ? uid : currentUid.value;
    if (effectiveUid.isEmpty) {
      isOnboarded.value = false;
      return null;
    }

    final fs = firestore;
    if (fs != null) {
      try {
        final doc = await fs.collection('users').doc(effectiveUid).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          currentUserProfile.value = data;
          if (data['currentAffiliation'] != null) {
            currentAffiliation.value = data['currentAffiliation'] as Map<String, dynamic>?;
          }
          if (data['activePlan'] != null) {
            activePlan.value = data['activePlan'] as Map<String, dynamic>?;
          }
          final bool onboarded = (data['isOnboarded'] == true);
          isOnboarded.value = onboarded;

          // Update local cache for this specific user
          _prefs ??= await SharedPreferences.getInstance();
          await _prefs?.setString('profile_$effectiveUid', jsonEncode(data));
          await _prefs?.setBool('onboarded_$effectiveUid', onboarded);

          return data;
        } else {
          // Document does not exist in Firestore! User has not completed onboarding
          debugPrint('User profile document does not exist in Cloud Firestore for: $effectiveUid');
          isOnboarded.value = false;
          currentUserProfile.value = null;
          return null;
        }
      } catch (e) {
        debugPrint('Firestore fetchUserProfile notice: $e');
      }
    }

    // Offline cache fallback ONLY for this specific user
    _prefs ??= await SharedPreferences.getInstance();
    final cachedStr = _prefs?.getString('profile_$effectiveUid');
    if (cachedStr != null && cachedStr.isNotEmpty) {
      try {
        final cached = jsonDecode(cachedStr) as Map<String, dynamic>;
        currentUserProfile.value = cached;
        final bool onboarded = (cached['isOnboarded'] == true);
        isOnboarded.value = onboarded;
        return cached;
      } catch (_) {}
    }

    isOnboarded.value = false;
    currentUserProfile.value = null;
    return null;
  }

  /// Real-time stream of user profile
  Stream<DocumentSnapshot<Map<String, dynamic>>>? streamUserProfile(String uid) {
    final fs = firestore;
    if (fs == null) return null;
    return fs.collection('users').doc(uid).snapshots();
  }

  /// Save or update user profile document in Firestore and local storage
  Future<void> saveUserProfile(String uid, Map<String, dynamic> data) async {
    currentUid.value = uid;
    final now = DateTime.now().toIso8601String();

    final fullData = {
      ...data,
      'uid': uid,
      'updatedAt': now,
    };

    // Update local state immediately for instant responsive UI
    currentUserProfile.value = fullData;
    if (fullData['currentAffiliation'] != null) {
      currentAffiliation.value = fullData['currentAffiliation'] as Map<String, dynamic>?;
    }
    if (fullData['activePlan'] != null) {
      activePlan.value = fullData['activePlan'] as Map<String, dynamic>?;
    }
    if (fullData['isOnboarded'] == true) {
      isOnboarded.value = true;
    }

    // Persist locally
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString('profile_$uid', jsonEncode(fullData));
    if (fullData['isOnboarded'] == true) {
      await _prefs!.setBool('onboarded_$uid', true);
    }

    // Sync to Cloud Firestore in real time
    final fs = firestore;
    if (fs != null) {
      try {
        await fs.collection('users').doc(uid).set(fullData, SetOptions(merge: true));
        debugPrint('Saved user profile to Cloud Firestore: $uid');
      } catch (e) {
        debugPrint('Firestore saveUserProfile warning: $e');
      }
    }
  }

  /// Partial update of specific fields in user profile
  Future<void> updateUserFields(String uid, Map<String, dynamic> fields) async {
    final updated = {
      ...currentUserProfile.value ?? {},
      ...fields,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    currentUserProfile.value = updated;

    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString('profile_$uid', jsonEncode(updated));

    final fs = firestore;
    if (fs != null) {
      try {
        await fs.collection('users').doc(uid).update(fields);
      } catch (e) {
        // Fallback to set merge
        try {
          await fs.collection('users').doc(uid).set(fields, SetOptions(merge: true));
        } catch (_) {}
      }
    }
  }

  // =========================================================================
  // 3. BUSINESS AFFILIATION (D1CM3 & D1CM6)
  // =========================================================================

  /// Stream list of registered businesses in real-time
  Stream<QuerySnapshot<Map<String, dynamic>>>? streamBusinesses() {
    final fs = firestore;
    if (fs == null) return null;
    return fs.collection('businesses').snapshots();
  }

  /// Verify a PIN or QR code against registered businesses
  Future<Map<String, dynamic>?> verifyBusinessCodeOrPin(String code) async {
    final normalized = code.trim().toUpperCase();

    // 1. Check Cloud Firestore businesses collection
    final fs = firestore;
    if (fs != null) {
      try {
        // Query by PIN
        final pinSnap = await fs
            .collection('businesses')
            .where('pin', isEqualTo: normalized)
            .limit(1)
            .get();
        if (pinSnap.docs.isNotEmpty) {
          return {'id': pinSnap.docs.first.id, ...pinSnap.docs.first.data()};
        }

        // Query by QR code content
        final qrSnap = await fs
            .collection('businesses')
            .where('qrCode', isEqualTo: normalized)
            .limit(1)
            .get();
        if (qrSnap.docs.isNotEmpty) {
          return {'id': qrSnap.docs.first.id, ...qrSnap.docs.first.data()};
        }
      } catch (e) {
        debugPrint('Firestore business lookup notice: $e');
      }
    }

    // 2. Fallback to registered default gyms
    for (final b in _defaultBusinesses) {
      if (b['pin'] == normalized ||
          b['qrCode'] == normalized ||
          b['id'] == normalized ||
          b['id'].toString().replaceAll('-', '') == normalized) {
        return b;
      }
    }
    return null;
  }

  /// Connect customer to a business by PIN or business data
  Future<bool> connectBusiness({required String pin, required Map<String, dynamic> businessData}) async {
    final uid = currentUid.value.isNotEmpty ? currentUid.value : 'USER-CURRENT';
    return await affiliateUserToBusiness(uid, businessData);
  }

  /// Affiliate customer to a business
  Future<bool> affiliateUserToBusiness(String uid, Map<String, dynamic> business) async {
    final affiliationData = {
      'businessId': business['id'] ?? 'BIZ-101',
      'businessName': business['name'] ?? 'Rablo Fitness Elite',
      'branch': business['branch'] ?? 'Koramangala, Bengaluru',
      'phone': business['phone'] ?? '+91 98765 43210',
      'managerName': business['managerName'] ?? 'Rajesh Sharma',
      'operatingHours': business['operatingHours'] ?? '06:00 AM - 10:00 PM',
      'affiliatedAt': DateTime.now().toIso8601String(),
      'status': 'Active',
    };

    currentAffiliation.value = affiliationData;

    await updateUserFields(uid, {
      'currentAffiliation': affiliationData,
    });

    // Also record in affiliations history subcollection
    final fs = firestore;
    if (fs != null) {
      try {
        await fs
            .collection('users')
            .doc(uid)
            .collection('affiliation_history')
            .add({
          ...affiliationData,
          'action': 'AFFILIATED',
          'timestamp': FieldValue.serverTimestamp(),
        });
      } catch (_) {}
    }
    return true;
  }

  /// Remove affiliation with DRD D1CM6 4-step reason tracking
  Future<bool> removeAffiliation(
    String uid, {
    required String reason,
    String? customNotes,
  }) async {
    final prevAffiliation = currentAffiliation.value;
    currentAffiliation.value = null;

    await updateUserFields(uid, {
      'currentAffiliation': null,
    });

    final fs = firestore;
    if (fs != null) {
      try {
        await fs
            .collection('users')
            .doc(uid)
            .collection('affiliation_history')
            .add({
          'action': 'DELETED',
          'reason': reason,
          'notes': customNotes ?? '',
          'previousBusiness': prevAffiliation,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } catch (_) {}
    }
    return true;
  }

  // =========================================================================
  // 4. MEMBERSHIP PLANS & JOINING (D1CM4)
  // =========================================================================

  /// Stream membership plans in real time
  Stream<QuerySnapshot<Map<String, dynamic>>>? streamPlans() {
    final fs = firestore;
    if (fs == null) return null;
    return fs.collection('membership_plans').snapshots();
  }

  /// Join or update membership plan in real time
  Future<bool> joinMembershipPlan(
    String uid, {
    required Map<String, dynamic> plan,
    required String timeSlot,
    required String paymentMethod,
    required double totalAmount,
    List<String>? addOns,
  }) async {
    final now = DateTime.now();
    final durationMonths = (plan['durationMonths'] as num?)?.toInt() ?? 3;
    final validityDate = now.add(Duration(days: durationMonths * 30));
    final sessionCount = (plan['sessionCount'] as num?)?.toInt() ?? 90;

    final planData = {
      'planId': plan['id'] ?? 'PLAN-001',
      'planName': plan['name'] ?? 'Gold Quarterly Plan',
      'planType': plan['type'] ?? 'Period Based',
      'amount': totalAmount,
      'durationMonths': durationMonths,
      'validity': '${validityDate.day} - ${validityDate.month} - ${validityDate.year}',
      'validityIso': validityDate.toIso8601String(),
      'sessionsLeft': sessionCount,
      'totalSessions': sessionCount,
      'preferredTimeSlot': timeSlot,
      'paymentMethod': paymentMethod, // 'Online Card' or 'Front Desk Cash'
      'paymentStatus': paymentMethod == 'Front Desk Cash' ? 'Pending Cash' : 'Paid',
      'status': 'Active',
      'subscribedAt': now.toIso8601String(),
      'addOns': addOns ?? [],
    };

    activePlan.value = planData;
    isDashboardV2Active.value = true;

    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setBool('is_dashboard_v2_active_$uid', true);

    await updateUserFields(uid, {
      'activePlan': planData,
      'isDashboardV2Active': true,
    });

    // Record transaction
    final transactionData = {
      'transactionId': 'TXN-${DateTime.now().millisecondsSinceEpoch}',
      'planName': planData['planName'],
      'amount': totalAmount,
      'date': now.toIso8601String(),
      'paymentMethod': paymentMethod,
      'status': planData['paymentStatus'],
    };

    final fs = firestore;
    if (fs != null) {
      try {
        await fs
            .collection('users')
            .doc(uid)
            .collection('transactions')
            .add(transactionData);
      } catch (_) {}
    }
    return true;
  }

  // =========================================================================
  // 5. ATTENDANCE & REDEMPTIONS (D1CM9 24h limit)
  // =========================================================================

  /// Stream redemptions history for active user
  Stream<QuerySnapshot<Map<String, dynamic>>>? streamRedemptions(String uid) {
    final fs = firestore;
    if (fs == null) return null;
    return fs
        .collection('users')
        .doc(uid)
        .collection('redemptions')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Mark daily session redemption enforcing the 1-scan-per-24-hours limit
  Future<Map<String, dynamic>> redeemDailySession(String uid) async {
    final plan = activePlan.value;
    if (plan == null) {
      return {'success': false, 'message': 'No active membership plan found.'};
    }

    final int sessionsLeft = (plan['sessionsLeft'] as num?)?.toInt() ?? 0;
    if (sessionsLeft <= 0) {
      return {'success': false, 'message': 'Insufficient sessions left in your plan.'};
    }

    final now = DateTime.now();

    // Check last redemption timestamp from local cache or Firestore
    _prefs ??= await SharedPreferences.getInstance();
    final lastRedeemIso = _prefs?.getString('last_redeem_$uid');
    if (lastRedeemIso != null) {
      final lastDate = DateTime.tryParse(lastRedeemIso);
      if (lastDate != null) {
        final hoursDiff = now.difference(lastDate).inHours;
        if (hoursDiff < 24) {
          final hoursRemaining = 24 - hoursDiff;
          return {
            'success': false,
            'message': 'Scan is only valid once per day. Please retry in $hoursRemaining hours.',
            'isBlocked24h': true,
          };
        }
      }
    }

    // Deduct 1 session
    final updatedSessions = sessionsLeft - 1;
    final updatedPlan = Map<String, dynamic>.from(plan);
    updatedPlan['sessionsLeft'] = updatedSessions;
    activePlan.value = updatedPlan;

    await _prefs!.setString('last_redeem_$uid', now.toIso8601String());
    await updateUserFields(uid, {'activePlan': updatedPlan});

    // Record redemption in Firestore
    final record = {
      'membershipId': plan['planId'],
      'planName': plan['planName'],
      'sessionsRemaining': updatedSessions,
      'timestamp': now.toIso8601String(),
      'status': 'Verified Pass',
    };

    final fs = firestore;
    if (fs != null) {
      try {
        await fs
            .collection('users')
            .doc(uid)
            .collection('redemptions')
            .add(record);
      } catch (_) {}
    }

    return {
      'success': true,
      'message': 'Attendance marked! 1 session redeemed.',
      'sessionsLeft': updatedSessions,
    };
  }

  // =========================================================================
  // 6. REVIEWS & RATINGS (Realtime Firestore)
  // =========================================================================

  /// Submit customer review to Firestore reviews collection
  Future<bool> submitCustomerReview({
    required String uid,
    required double rating,
    required String reviewText,
    List<String>? issueCategories,
    Map<String, String>? categoryNotes,
  }) async {
    final reviewData = {
      'uid': uid,
      'userName': currentUserProfile.value?['fullName'] ?? 'Gym Member',
      'userEmail': currentUserProfile.value?['email'] ?? '',
      'rating': rating,
      'review': reviewText,
      'issueCategories': issueCategories ?? [],
      'categoryNotes': categoryNotes ?? {},
      'submittedAt': DateTime.now().toIso8601String(),
    };

    final fs = firestore;
    if (fs != null) {
      try {
        await fs.collection('reviews').add(reviewData);
      } catch (e) {
        debugPrint('Firestore submit review notice: $e');
      }
    }
    return true;
  }

  // =========================================================================
  // 7. BANK ACCOUNTS & TRANSACTIONS (FIREBASE FIRESTORE)
  // =========================================================================

  Future<List<Map<String, dynamic>>> getBankAccountsFromFirestore(String uid) async {
    final effectiveUid = uid.isNotEmpty ? uid : (currentUid.value.isNotEmpty ? currentUid.value : 'USER-CURRENT');
    final fs = firestore;
    if (fs != null) {
      try {
        final snap = await fs.collection('users').doc(effectiveUid).collection('bank_accounts').get();
        if (snap.docs.isNotEmpty) {
          final list = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
          _mockBankAccounts.clear();
          _mockBankAccounts.addAll(list);
          return list;
        }
        // Seed default bank account to Firestore for this user
        final defaultAcc = {
          'id': 'acc_1',
          'bankName': 'HDFC Bank',
          'accountHolderName': 'Alex Morgan',
          'accountNumber': '**** **** 4892',
          'fullAccountNumber': '50100234564892',
          'ifscCode': 'HDFC0001234',
          'branch': 'Indiranagar, Bengaluru',
          'isPrimary': true,
          'isVerified': true,
          'balance': '20,014.00',
          'isBalanceVisible': false,
        };
        await fs.collection('users').doc(effectiveUid).collection('bank_accounts').doc('acc_1').set(defaultAcc);
        _mockBankAccounts.clear();
        _mockBankAccounts.add(defaultAcc);
        return [defaultAcc];
      } catch (e) {
        debugPrint('Firestore getBankAccounts error: $e');
      }
    }
    return _mockBankAccounts;
  }

  Future<bool> saveBankAccountToFirestore(String uid, Map<String, dynamic> data) async {
    final effectiveUid = uid.isNotEmpty ? uid : (currentUid.value.isNotEmpty ? currentUid.value : 'USER-CURRENT');
    final accId = data['id'] ?? 'acc_${DateTime.now().millisecondsSinceEpoch}';
    final fullData = {...data, 'id': accId};
    final idx = _mockBankAccounts.indexWhere((a) => a['id'] == accId);
    if (idx >= 0) {
      _mockBankAccounts[idx] = fullData;
    } else {
      _mockBankAccounts.add(fullData);
    }

    final fs = firestore;
    if (fs != null) {
      try {
        await fs.collection('users').doc(effectiveUid).collection('bank_accounts').doc(accId).set({
          ...data,
          'id': accId,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        return true;
      } catch (e) {
        debugPrint('Firestore saveBankAccount error: $e');
      }
    }
    return true;
  }

  Future<bool> updateBankAccountInFirestore(String uid, String accId, Map<String, dynamic> data) async {
    final effectiveUid = uid.isNotEmpty ? uid : (currentUid.value.isNotEmpty ? currentUid.value : 'USER-CURRENT');
    final idx = _mockBankAccounts.indexWhere((a) => a['id'] == accId);
    if (idx >= 0) {
      _mockBankAccounts[idx] = {..._mockBankAccounts[idx], ...data};
    }

    final fs = firestore;
    if (fs != null) {
      try {
        await fs.collection('users').doc(effectiveUid).collection('bank_accounts').doc(accId).set({
          ...data,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        return true;
      } catch (e) {
        debugPrint('Firestore updateBankAccount error: $e');
      }
    }
    return true;
  }

  Future<bool> patchBalanceVisibilityInFirestore(String uid, String accId, bool isVisible) async {
    final effectiveUid = uid.isNotEmpty ? uid : (currentUid.value.isNotEmpty ? currentUid.value : 'USER-CURRENT');
    final idx = _mockBankAccounts.indexWhere((a) => a['id'] == accId);
    if (idx >= 0) {
      _mockBankAccounts[idx]['isBalanceVisible'] = isVisible;
    }

    final fs = firestore;
    if (fs != null) {
      try {
        await fs.collection('users').doc(effectiveUid).collection('bank_accounts').doc(accId).set({
          'isBalanceVisible': isVisible,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        return true;
      } catch (e) {
        debugPrint('Firestore patchBalanceVisibility error: $e');
      }
    }
    return true;
  }

  Future<bool> deleteBankAccountFromFirestore(String uid, String accId) async {
    final effectiveUid = uid.isNotEmpty ? uid : (currentUid.value.isNotEmpty ? currentUid.value : 'USER-CURRENT');
    _mockBankAccounts.removeWhere((a) => a['id'] == accId);

    final fs = firestore;
    if (fs != null) {
      try {
        await fs.collection('users').doc(effectiveUid).collection('bank_accounts').doc(accId).delete();
        return true;
      } catch (e) {
        debugPrint('Firestore deleteBankAccount error: $e');
      }
    }
    return true;
  }

  Future<List<Map<String, dynamic>>> getTransactionsFromFirestore(String uid, {String? filter}) async {
    final effectiveUid = uid.isNotEmpty ? uid : (currentUid.value.isNotEmpty ? currentUid.value : 'USER-CURRENT');
    final fs = firestore;
    if (fs != null) {
      try {
        final snap = await fs.collection('users').doc(effectiveUid).collection('transactions').get();
        if (snap.docs.isNotEmpty) {
          final list = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
          _mockTransactions.clear();
          _mockTransactions.addAll(list);
          return list;
        }
        // Seed default transactions to Firestore
        for (final t in _defaultTransactions) {
          await fs.collection('users').doc(effectiveUid).collection('transactions').doc(t['id']).set(t);
        }
        _mockTransactions.clear();
        _mockTransactions.addAll(_defaultTransactions);
        return _defaultTransactions;
      } catch (e) {
        debugPrint('Firestore getTransactions error: $e');
      }
    }
    if (_mockTransactions.isEmpty) {
      _mockTransactions.addAll(_defaultTransactions);
    }
    return _mockTransactions;
  }

  Future<bool> saveTransactionToFirestore(String uid, Map<String, dynamic> txData) async {
    final effectiveUid = uid.isNotEmpty ? uid : (currentUid.value.isNotEmpty ? currentUid.value : 'USER-CURRENT');
    final txId = txData['id'] ?? 'tx_${DateTime.now().millisecondsSinceEpoch}';
    final fullData = {...txData, 'id': txId};
    _mockTransactions.insert(0, fullData);

    final fs = firestore;
    if (fs != null) {
      try {
        await fs.collection('users').doc(effectiveUid).collection('transactions').doc(txId).set({
          ...txData,
          'id': txId,
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        return true;
      } catch (e) {
        debugPrint('Firestore saveTransaction error: $e');
      }
    }
    return true;
  }

  // =========================================================================
  // 8. TRAINERS MANAGEMENT (FIREBASE FIRESTORE)
  // =========================================================================

  Future<List<Map<String, dynamic>>> getTrainersFromFirestore() async {
    final fs = firestore;
    if (fs != null) {
      try {
        final snap = await fs.collection('trainers').get();
        if (snap.docs.isNotEmpty) {
          final list = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
          _mockTrainers.clear();
          _mockTrainers.addAll(list);
          return list;
        }
        // Seed default trainers to Firestore
        for (final t in _defaultTrainers) {
          await fs.collection('trainers').doc(t['id']).set(t);
        }
        _mockTrainers.clear();
        _mockTrainers.addAll(_defaultTrainers);
        return _defaultTrainers;
      } catch (e) {
        debugPrint('Firestore getTrainers error: $e');
      }
    }
    if (_mockTrainers.isEmpty) {
      _mockTrainers.addAll(_defaultTrainers);
    }
    return _mockTrainers;
  }

  Future<bool> saveTrainerToFirestore(Map<String, dynamic> trainerData) async {
    final id = trainerData['id'] ?? 't_${DateTime.now().millisecondsSinceEpoch}';
    final fullData = {...trainerData, 'id': id};
    final idx = _mockTrainers.indexWhere((t) => t['id'] == id);
    if (idx >= 0) {
      _mockTrainers[idx] = fullData;
    } else {
      _mockTrainers.add(fullData);
    }

    final fs = firestore;
    if (fs != null) {
      try {
        await fs.collection('trainers').doc(id).set({
          ...trainerData,
          'id': id,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        return true;
      } catch (e) {
        debugPrint('Firestore saveTrainer error: $e');
      }
    }
    return true;
  }

  Future<bool> updateTrainerInFirestore(String trainerId, Map<String, dynamic> data) async {
    final idx = _mockTrainers.indexWhere((t) => t['id'] == trainerId);
    if (idx >= 0) {
      _mockTrainers[idx] = {..._mockTrainers[idx], ...data};
    }

    final fs = firestore;
    if (fs != null) {
      try {
        await fs.collection('trainers').doc(trainerId).set({
          ...data,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        return true;
      } catch (e) {
        debugPrint('Firestore updateTrainer error: $e');
      }
    }
    return true;
  }

  Future<bool> deleteTrainerFromFirestore(String trainerId) async {
    _mockTrainers.removeWhere((t) => t['id'] == trainerId);

    final fs = firestore;
    if (fs != null) {
      try {
        await fs.collection('trainers').doc(trainerId).delete();
        return true;
      } catch (e) {
        debugPrint('Firestore deleteTrainer error: $e');
      }
    }
    return true;
  }

  // =========================================================================
  // 9. BUSINESS CONNECTS (FIREBASE FIRESTORE)
  // =========================================================================

  Future<List<Map<String, dynamic>>> getBusinessConnectsFromFirestore(String uid) async {
    final effectiveUid = uid.isNotEmpty ? uid : (currentUid.value.isNotEmpty ? currentUid.value : 'USER-CURRENT');
    final fs = firestore;
    if (fs != null) {
      try {
        final snap = await fs.collection('users').doc(effectiveUid).collection('business_connects').get();
        if (snap.docs.isNotEmpty) {
          final list = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
          _mockBusinessConnects.clear();
          _mockBusinessConnects.addAll(list);
          return list;
        }
        // Seed default connected businesses to Firestore
        for (final b in _defaultConnectedBusinesses) {
          await fs.collection('users').doc(effectiveUid).collection('business_connects').doc(b['id']).set(b);
        }
        _mockBusinessConnects.clear();
        _mockBusinessConnects.addAll(_defaultConnectedBusinesses);
        return _defaultConnectedBusinesses;
      } catch (e) {
        debugPrint('Firestore getBusinessConnects error: $e');
      }
    }
    if (_mockBusinessConnects.isEmpty) {
      _mockBusinessConnects.addAll(_defaultConnectedBusinesses);
    }
    return _mockBusinessConnects;
  }

  Future<bool> saveBusinessConnectToFirestore(String uid, Map<String, dynamic> data) async {
    final effectiveUid = uid.isNotEmpty ? uid : (currentUid.value.isNotEmpty ? currentUid.value : 'USER-CURRENT');
    final id = data['id'] ?? 'biz_${DateTime.now().millisecondsSinceEpoch}';
    final fullData = {...data, 'id': id};
    final idx = _mockBusinessConnects.indexWhere((b) => b['id'] == id);
    if (idx >= 0) {
      _mockBusinessConnects[idx] = fullData;
    } else {
      _mockBusinessConnects.add(fullData);
    }

    final fs = firestore;
    if (fs != null) {
      try {
        await fs.collection('users').doc(effectiveUid).collection('business_connects').doc(id).set({
          ...data,
          'id': id,
          'connectedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        return true;
      } catch (e) {
        debugPrint('Firestore saveBusinessConnect error: $e');
      }
    }
    return true;
  }

  Future<bool> deleteBusinessConnectFromFirestore(String uid, String bizId) async {
    final effectiveUid = uid.isNotEmpty ? uid : (currentUid.value.isNotEmpty ? currentUid.value : 'USER-CURRENT');
    _mockBusinessConnects.removeWhere((b) => b['id'] == bizId);

    final fs = firestore;
    if (fs != null) {
      try {
        await fs.collection('users').doc(effectiveUid).collection('business_connects').doc(bizId).delete();
        return true;
      } catch (e) {
        debugPrint('Firestore deleteBusinessConnect error: $e');
      }
    }
    return true;
  }

  // =========================================================================
  // 10. SEEDING DEFAULT DATA FOR FIRESTORE
  // =========================================================================

  Future<void> _seedDefaultFirestoreData() async {
    final fs = firestore;
    if (fs == null) return;

    try {
      // Check if businesses exist
      final bSnap = await fs.collection('businesses').limit(1).get();
      if (bSnap.docs.isEmpty) {
        for (final b in _defaultBusinesses) {
          await fs.collection('businesses').doc(b['id']).set(b);
        }
      }

      // Check if plans exist
      final pSnap = await fs.collection('membership_plans').limit(1).get();
      if (pSnap.docs.isEmpty) {
        for (final p in _defaultPlans) {
          await fs.collection('membership_plans').doc(p['id']).set(p);
        }
      }

      // Check if trainers exist
      final tSnap = await fs.collection('trainers').limit(1).get();
      if (tSnap.docs.isEmpty) {
        for (final t in _defaultTrainers) {
          await fs.collection('trainers').doc(t['id']).set(t);
        }
      }
    } catch (_) {}
  }

  static const List<Map<String, dynamic>> _defaultTransactions = [
    {
      'id': '122354',
      'productName': 'Product Name',
      'planType': 'Period-Based Plan',
      'status': 'success',
      'amount': '1514.00',
      'date': '26/11/2024',
      'validity': '30 Mar 2024',
      'transactionalId': '123454878',
    },
    {
      'id': '122355',
      'productName': 'Product Name',
      'planType': 'Session-Based Plan',
      'status': 'pending',
      'amount': '1514.00',
      'date': '25/11/2024',
      'validity': '30 Mar 2024',
      'transactionalId': '123454879',
    },
    {
      'id': '122356',
      'productName': 'Product Name',
      'planType': 'Session-Based Plan',
      'status': 'failed',
      'amount': '1514.00',
      'date': '24/11/2024',
      'validity': '30 Mar 2024',
      'transactionalId': '123454880',
    },
  ];

  static const List<Map<String, dynamic>> _defaultTrainers = [
    {
      'id': 'tr_1',
      'name': 'Rahul Sharma',
      'role': 'Master Trainer & Strength Coach',
      'specialty': 'CrossFit & Strength Coach',
      'rating': 4.9,
      'reviewsCount': '128',
      'sessionsTotal': 20,
      'sessionsRemaining': 12,
      'sessionsCompleted': 48,
      'timing': 'Mon, Wed, Fri • 07:00 AM - 08:30 AM',
      'avatarChar': 'R',
      'status': 'Assigned',
      'isActive': true,
      'schedule': 'Mon, Wed, Fri • 07:00 AM',
    },
    {
      'id': 'tr_2',
      'name': 'Priya Patel',
      'role': 'Mobility & Conditioning Coach',
      'specialty': 'Yoga & Flexibility Specialist',
      'rating': 4.8,
      'reviewsCount': '94',
      'sessionsTotal': 15,
      'sessionsRemaining': 8,
      'sessionsCompleted': 24,
      'timing': 'Tue, Thu, Sat • 06:00 PM - 07:30 PM',
      'avatarChar': 'P',
      'status': 'Assigned',
      'isActive': true,
      'schedule': 'Tue, Thu, Sat • 06:00 PM',
    },
  ];

  static const List<Map<String, dynamic>> _defaultConnectedBusinesses = [
    {
      'id': 'b1',
      'name': 'PowerFit Gym & Health Club',
      'branch': 'Indiranagar, Bangalore',
      'status': 'Active',
      'planName': 'Period-Based Annual Plan',
      'validity': '90 Days left',
      'amount': '5,000 INR',
      'phone': '+91 98765 43210',
      'manager': 'Vikram Malhotra',
      'timings': '6:00 AM - 10:00 PM',
      'address': '#102, 100 Feet Rd, Indiranagar, Bangalore',
    },
    {
      'id': 'b2',
      'name': 'IronCore Fitness Studio',
      'branch': 'Koramangala 4th Block, Bangalore',
      'status': 'Expired',
      'planName': 'Quarterly Strength Pass',
      'validity': 'Expired on 15 Aug',
      'amount': '2,400 INR',
      'phone': '+91 98450 12345',
      'manager': 'Ramesh Kumar',
      'timings': '5:30 AM - 10:30 PM',
      'address': '80 Feet Rd, Koramangala 4th Block, Bangalore',
    },
  ];

  static const List<Map<String, dynamic>> _defaultBusinesses = [
    {
      'id': 'RABLO-101',
      'name': 'Rablo Fitness Elite',
      'branch': 'Koramangala 5th Block, Bengaluru',
      'pin': 'RABLO101',
      'qrCode': 'RABLO-101',
      'phone': '+91 98765 43210',
      'managerName': 'Rajesh Sharma',
      'operatingHours': '06:00 AM - 10:00 PM',
      'rating': 4.9,
    },
    {
      'id': 'FIT-202',
      'name': 'Powerhouse Gym & Spa',
      'branch': 'Indiranagar 100ft Road, Bengaluru',
      'pin': 'FIT202',
      'qrCode': 'FIT-202',
      'phone': '+91 98451 22334',
      'managerName': 'Ananya Verma',
      'operatingHours': '05:30 AM - 10:30 PM',
      'rating': 4.8,
    },
    {
      'id': 'IRON-303',
      'name': 'Iron & Gold Health Club',
      'branch': 'HSR Layout Sector 4, Bengaluru',
      'pin': 'IRON303',
      'qrCode': 'IRON-303',
      'phone': '+91 91234 56789',
      'managerName': 'Vikram Singh',
      'operatingHours': '06:00 AM - 10:00 PM',
      'rating': 4.7,
    },
  ];

  static const List<Map<String, dynamic>> _defaultPlans = [
    {
      'id': 'PLAN-001',
      'name': 'Standard Fitness Plan',
      'type': 'Period Based',
      'price': 2499.0,
      'durationMonths': 1,
      'sessionCount': 30,
      'description': 'Daily gym floor access, locker access, and general wellness consultation.',
      'rating': 4.8,
      'reviewCount': 124,
      'trainers': ['Kiran Rao (Strength Coach)', 'Sneha Nair (HIIT Trainer)'],
      'features': ['General gym access', 'Lockers & shower access', 'Weekly fitness assessment'],
      'objective': 'General Fitness & Wellness',
    },
    {
      'id': 'PLAN-002',
      'name': 'Gold Quarterly Plan',
      'type': 'Period Based',
      'price': 6999.0,
      'durationMonths': 3,
      'sessionCount': 90,
      'description': 'All-access pass with personalized workout plans, diet chart, and rush-hour priority.',
      'rating': 4.9,
      'reviewCount': 342,
      'trainers': ['Rajesh Coach (Master Trainer)', 'Priya Mehta (Yoga & Mobility)'],
      'features': ['Unlimited floor access', 'Personal Diet consultation', 'Steam & Sauna 2x/month'],
      'objective': 'Fat Loss & Muscle Toning',
    },
    {
      'id': 'PLAN-003',
      'name': 'Platinum Annual Plan',
      'type': 'Period Based',
      'price': 19999.0,
      'durationMonths': 12,
      'sessionCount': 365,
      'description': 'VIP membership including 1-on-1 personal trainer sessions, towel service, and guest passes.',
      'rating': 5.0,
      'reviewCount': 510,
      'trainers': ['Vikram Singh (Head Coach)', 'Arjun Kapoor (Sports Rehab)'],
      'features': ['Full VIP Access', '12 Free Personal Training Sessions', 'Guest Passes', 'Locker Reserved'],
      'objective': 'Strength Building & Athletic Performance',
    },
  ];
}
