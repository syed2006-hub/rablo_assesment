import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get_connect/http/src/response/response.dart';

/// Embedded In-Memory REST API Backend Engine
/// Simulates a real REST server handling GET, POST, PUT, PATCH, DELETE operations.
class MockRestBackend {
  MockRestBackend._();
  static final MockRestBackend instance = MockRestBackend._();

  // In-memory persistent database tables
  final Map<String, dynamic> _profileTable = {
    'id': 'MEM-001',
    'fullName': 'Manager Name',
    'email': 'member@fitness.com',
    'phoneNumber': '+91 98765 - 43210',
    'gender': 'Male',
    'role': 'Manager/Owner',
    'dob': '09 - 11 - 2024',
    'addressLine1': 'User input, Sample text',
    'addressLine2': 'Enter your colony or locality',
    'country': 'India',
    'state': 'Karnataka',
    'city': 'Bengaluru',
    'pincode': '560038',
    'preferredLanguages': ['English', 'Hindi', 'Kannada'],
    'isVerified': false,
    'photoUrl': 'assets/images/profile_avatar.png',
    'gymBranch': 'Koramangala Prime Club, Bengaluru',
    'bio': 'Fitness and gym management profile.',
    'totalWorkoutsSupervised': 1420,
    'rating': 4.9,
  };

  final List<Map<String, dynamic>> _bankAccountsTable = [
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

  final List<Map<String, dynamic>> _transactionsTable = [
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
    {
      'id': '122357',
      'productName': 'Product Name',
      'planType': 'Period-Based Plan',
      'status': 'pending',
      'amount': '1514.00',
      'date': '23/11/2024',
      'validity': '30 Mar 2024',
      'transactionalId': '123454881',
    },
    {
      'id': '122358',
      'productName': 'Product Name',
      'planType': 'Session-Based Plan',
      'status': 'success',
      'amount': '1514.00',
      'date': '22/11/2024',
      'validity': '30 Mar 2024',
      'transactionalId': '123454882',
    },
    {
      'id': '122359',
      'productName': 'Product Name',
      'planType': 'Session-Based Plan',
      'status': 'failed',
      'amount': '1514.00',
      'date': '21/11/2024',
      'validity': '30 Mar 2024',
      'transactionalId': '123454883',
    },
  ];

  final List<Map<String, dynamic>> _trainersTable = [
    {
      'id': 'tr_1',
      'name': 'Rahul Sharma',
      'specialty': 'CrossFit & Strength Coach',
      'rating': 4.9,
      'sessionsTotal': 20,
      'sessionsRemaining': 12,
      'isActive': true,
      'photoUrl': 'assets/images/profile_avatar.png',
      'schedule': 'Mon, Wed, Fri (07:00 AM)',
    },
    {
      'id': 'tr_2',
      'name': 'Priya Patel',
      'specialty': 'Yoga & Flexibility Specialist',
      'rating': 4.8,
      'sessionsTotal': 15,
      'sessionsRemaining': 8,
      'isActive': true,
      'photoUrl': 'assets/images/profile_avatar.png',
      'schedule': 'Tue, Thu, Sat (06:30 PM)',
    },
  ];

  final List<Map<String, dynamic>> _businessConnectsTable = [
    {
      'id': 'biz_1',
      'name': 'PowerFit Gym & Health Centre',
      'address': 'Indiranagar, Bangalore',
      'status': 'Active',
      'plan': 'Period-Based Annual Plan',
      'planDuration': '90 Days left',
      'joiningDate': '12 Jan 2024',
      'expiryDate': '12 Jan 2025',
      'totalVisits': 142,
      'ptSessions': 24,
      'phone': '+91 80 4123 4567',
    },
    {
      'id': 'biz_2',
      'name': 'IronCore Fitness Studio',
      'address': 'Koramangala 4th Block, Bangalore',
      'status': 'Expired',
      'plan': 'Quarterly Strength Pass',
      'planDuration': 'Expired on 15 Aug',
      'joiningDate': '15 May 2024',
      'expiryDate': '15 Aug 2024',
      'totalVisits': 64,
      'ptSessions': 8,
      'phone': '+91 80 4987 6543',
    },
    {
      'id': 'biz_3',
      'name': 'Urban Pulse CrossFit Arena',
      'address': 'HSR Layout Sector 2, Bangalore',
      'status': 'Pending',
      'plan': 'Trial Weekly Membership',
      'planDuration': 'Approval pending',
      'joiningDate': 'Pending Review',
      'expiryDate': '--',
      'totalVisits': 0,
      'ptSessions': 0,
      'phone': '+91 80 4321 8765',
    },
  ];

  final List<Map<String, dynamic>> _membershipPlansTable = [
    {
      'id': 'plan_1',
      'title': 'Session-Based Pro',
      'type': 'Session-Based',
      'price': '₹4,999',
      'validity': '60 Days',
      'sessions': 35,
      'rating': 4.9,
      'isActive': true,
      'perks': [
        '35 Any-time gym sessions',
        'Locker room & Sauna access',
        '2 Free Personal Trainer Consultations',
        'Free Diet & Nutrition assessment',
      ],
    },
    {
      'id': 'plan_2',
      'title': 'Annual All-Access VIP',
      'type': 'Period-Based',
      'price': '₹14,999',
      'validity': '365 Days',
      'sessions': 365,
      'rating': 5.0,
      'isActive': false,
      'perks': [
        'Unlimited access across all city branches',
        'Free towel & laundry service',
        '12 Complimentary 1-on-1 PT sessions',
        'Priority booking for rush hour slots',
      ],
    },
    {
      'id': 'plan_3',
      'title': 'Monthly Flexi Pass',
      'type': 'Period-Based',
      'price': '₹2,499',
      'validity': '30 Days',
      'sessions': 30,
      'rating': 4.7,
      'isActive': false,
      'perks': [
        '30 Days unrestricted gym floor access',
        'Standard equipment & cardio zone',
        'Group aerobics & Zumba sessions',
      ],
    },
  ];

  /// Main HTTP Request Dispatcher handling GET, POST, PUT, PATCH, DELETE
  Future<Response> dispatch({
    required String method,
    required String endpoint,
    dynamic body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
  }) async {
    // Simulate real microsecond network latency
    await Future.delayed(const Duration(milliseconds: 60));

    debugPrint('➡️ [REST API BACKEND] $method $endpoint');
    if (body != null) {
      debugPrint('   Payload: ${jsonEncode(body)}');
    }

    final normalizedPath = endpoint.startsWith('/') ? endpoint : '/$endpoint';

    try {
      // -------------------------------------------------------------
      // 1. PROFILE ENDPOINTS
      // -------------------------------------------------------------
      if (normalizedPath == '/profile' && method == 'GET') {
        return _jsonResponse(200, {
          'status': 'success',
          'data': _profileTable,
          'message': 'Profile fetched successfully',
        });
      }

      if (normalizedPath == '/profile' && method == 'PUT') {
        if (body is Map<String, dynamic>) {
          _profileTable.addAll(body);
        }
        return _jsonResponse(200, {
          'status': 'success',
          'data': _profileTable,
          'message': 'Profile updated successfully via PUT',
        });
      }

      if (normalizedPath == '/profile/verification' && method == 'PATCH') {
        final current = _profileTable['isVerified'] as bool? ?? false;
        _profileTable['isVerified'] = !current;
        return _jsonResponse(200, {
          'status': 'success',
          'data': {'isVerified': _profileTable['isVerified']},
          'message': 'Profile verification status patched',
        });
      }

      if (normalizedPath == '/profile/photo' && method == 'PATCH') {
        if (body is Map && body.containsKey('photoUrl')) {
          _profileTable['photoUrl'] = body['photoUrl'];
        }
        return _jsonResponse(200, {
          'status': 'success',
          'data': {'photoUrl': _profileTable['photoUrl']},
          'message': 'Profile photo patched successfully',
        });
      }

      if (normalizedPath.startsWith('/profile/') && method == 'DELETE') {
        return _jsonResponse(200, {
          'status': 'success',
          'message': 'User profile deactivated successfully via DELETE',
        });
      }

      // -------------------------------------------------------------
      // 2. BANK ACCOUNTS ENDPOINTS
      // -------------------------------------------------------------
      if (normalizedPath == '/bank-accounts' && method == 'GET') {
        return _jsonResponse(200, {
          'status': 'success',
          'data': {
            'accounts': _bankAccountsTable,
            'totalBalance': '20,014.00',
            'isBalanceVisible': _bankAccountsTable.isNotEmpty
                ? (_bankAccountsTable.first['isBalanceVisible'] ?? false)
                : false,
          },
          'message': 'Bank accounts retrieved',
        });
      }

      if (normalizedPath == '/bank-accounts' && method == 'POST') {
        final newAccount = Map<String, dynamic>.from(body as Map? ?? {});
        newAccount['id'] = 'acc_${DateTime.now().millisecondsSinceEpoch}';
        newAccount['isVerified'] = true;
        newAccount['balance'] = '20,014.00';
        newAccount['isBalanceVisible'] = false;
        if (!newAccount.containsKey('accountNumber') &&
            newAccount.containsKey('fullAccountNumber')) {
          final full = newAccount['fullAccountNumber'].toString();
          newAccount['accountNumber'] = full.length > 4
              ? '**** **** ${full.substring(full.length - 4)}'
              : full;
        }
        _bankAccountsTable.add(newAccount);

        return _jsonResponse(201, {
          'status': 'created',
          'data': newAccount,
          'message': 'Bank account linked successfully via POST',
        });
      }

      if (normalizedPath.startsWith('/bank-accounts/') &&
          normalizedPath.endsWith('/visibility') &&
          method == 'PATCH') {
        final isVis = body is Map ? (body['isVisible'] ?? false) : false;
        if (_bankAccountsTable.isNotEmpty) {
          _bankAccountsTable.first['isBalanceVisible'] = isVis;
        }
        return _jsonResponse(200, {
          'status': 'success',
          'data': {'isBalanceVisible': isVis},
          'message': 'Balance visibility updated via PATCH',
        });
      }

      if (normalizedPath.startsWith('/bank-accounts/') && method == 'PUT') {
        final id = normalizedPath.split('/')[2];
        final index = _bankAccountsTable.indexWhere((acc) => acc['id'] == id);
        if (index != -1 && body is Map<String, dynamic>) {
          _bankAccountsTable[index].addAll(body);
          return _jsonResponse(200, {
            'status': 'success',
            'data': _bankAccountsTable[index],
            'message': 'Bank account updated via PUT',
          });
        }
        return _jsonResponse(404, {'status': 'error', 'message': 'Account not found'});
      }

      if (normalizedPath.startsWith('/bank-accounts/') && method == 'DELETE') {
        final id = normalizedPath.split('/')[2];
        _bankAccountsTable.removeWhere((acc) => acc['id'] == id);
        return _jsonResponse(200, {
          'status': 'success',
          'message': 'Bank account deleted successfully via DELETE',
        });
      }

      // -------------------------------------------------------------
      // 3. TRANSACTIONS ENDPOINTS
      // -------------------------------------------------------------
      if (normalizedPath == '/transactions' && method == 'GET') {
        return _jsonResponse(200, {
          'status': 'success',
          'data': _transactionsTable,
          'count': _transactionsTable.length,
          'message': 'Transactions fetched via GET',
        });
      }

      if (normalizedPath == '/transactions' && method == 'POST') {
        final newTx = Map<String, dynamic>.from(body as Map? ?? {});
        newTx['id'] = (122360 + _transactionsTable.length).toString();
        _transactionsTable.insert(0, newTx);
        return _jsonResponse(201, {
          'status': 'created',
          'data': newTx,
          'message': 'Transaction created via POST',
        });
      }

      // -------------------------------------------------------------
      // 4. TRAINERS ENDPOINTS
      // -------------------------------------------------------------
      if (normalizedPath == '/trainers' && method == 'GET') {
        return _jsonResponse(200, {
          'status': 'success',
          'data': _trainersTable,
          'message': 'Trainers fetched via GET',
        });
      }

      if (normalizedPath == '/trainers' && method == 'POST') {
        final newTrainer = Map<String, dynamic>.from(body as Map? ?? {});
        newTrainer['id'] = 'tr_${DateTime.now().millisecondsSinceEpoch}';
        newTrainer['rating'] = 5.0;
        newTrainer['isActive'] = true;
        _trainersTable.add(newTrainer);
        return _jsonResponse(201, {
          'status': 'created',
          'data': newTrainer,
          'message': 'Trainer assigned successfully via POST',
        });
      }

      if (normalizedPath.startsWith('/trainers/') &&
          normalizedPath.endsWith('/sessions') &&
          method == 'PATCH') {
        final id = normalizedPath.split('/')[2];
        final trainer = _trainersTable.firstWhereOrNull((t) => t['id'] == id);
        if (trainer != null && body is Map && body.containsKey('sessions')) {
          trainer['sessionsRemaining'] = body['sessions'];
          return _jsonResponse(200, {
            'status': 'success',
            'data': trainer,
            'message': 'Trainer sessions patched via PATCH',
          });
        }
      }

      if (normalizedPath.startsWith('/trainers/') && method == 'PUT') {
        final id = normalizedPath.split('/')[2];
        final index = _trainersTable.indexWhere((t) => t['id'] == id);
        if (index != -1 && body is Map<String, dynamic>) {
          _trainersTable[index].addAll(body);
          return _jsonResponse(200, {
            'status': 'success',
            'data': _trainersTable[index],
            'message': 'Trainer updated via PUT',
          });
        }
        return _jsonResponse(404, {'status': 'error', 'message': 'Trainer not found'});
      }

      if (normalizedPath.startsWith('/trainers/') && method == 'DELETE') {
        final id = normalizedPath.split('/')[2];
        _trainersTable.removeWhere((t) => t['id'] == id);
        return _jsonResponse(200, {
          'status': 'success',
          'message': 'Trainer removed successfully via DELETE',
        });
      }

      // -------------------------------------------------------------
      // 5. BUSINESS CONNECTS ENDPOINTS
      // -------------------------------------------------------------
      if (normalizedPath == '/business-connects' && method == 'GET') {
        return _jsonResponse(200, {
          'status': 'success',
          'data': _businessConnectsTable,
          'message': 'Business connects fetched via GET',
        });
      }

      if (normalizedPath == '/business-connects' && method == 'POST') {
        final newBiz = Map<String, dynamic>.from(body as Map? ?? {});
        newBiz['id'] = 'biz_${DateTime.now().millisecondsSinceEpoch}';
        newBiz['status'] = 'Pending';
        _businessConnectsTable.add(newBiz);
        return _jsonResponse(201, {
          'status': 'created',
          'data': newBiz,
          'message': 'Business affiliation requested via POST',
        });
      }

      if (normalizedPath.startsWith('/business-connects/') &&
          normalizedPath.endsWith('/status') &&
          method == 'PATCH') {
        final id = normalizedPath.split('/')[2];
        final biz = _businessConnectsTable.firstWhereOrNull((b) => b['id'] == id);
        if (biz != null && body is Map && body.containsKey('status')) {
          biz['status'] = body['status'];
          return _jsonResponse(200, {
            'status': 'success',
            'data': biz,
            'message': 'Business status patched via PATCH',
          });
        }
      }

      if (normalizedPath.startsWith('/business-connects/') && method == 'DELETE') {
        final id = normalizedPath.split('/')[2];
        _businessConnectsTable.removeWhere((b) => b['id'] == id);
        return _jsonResponse(200, {
          'status': 'success',
          'message': 'Business connect removed via DELETE',
        });
      }

      // -------------------------------------------------------------
      // 6. MEMBERSHIP PLANS ENDPOINTS
      // -------------------------------------------------------------
      if (normalizedPath == '/membership-plans' && method == 'GET') {
        return _jsonResponse(200, {
          'status': 'success',
          'data': _membershipPlansTable,
          'message': 'Membership plans fetched via GET',
        });
      }

      if (normalizedPath == '/membership-plans/subscribe' && method == 'POST') {
        return _jsonResponse(200, {
          'status': 'success',
          'message': 'Plan subscribed successfully via POST',
        });
      }

      // -------------------------------------------------------------
      // 7. ATTENDANCE CHECK-IN
      // -------------------------------------------------------------
      if (normalizedPath == '/attendance/check-in' && method == 'POST') {
        return _jsonResponse(200, {
          'status': 'success',
          'data': {
            'timestamp': DateTime.now().toIso8601String(),
            'branch': 'Indiranagar',
            'status': 'Checked-in',
          },
          'message': 'Check-in processed via POST',
        });
      }

      // Fallback 404
      return _jsonResponse(404, {
        'status': 'not_found',
        'message': 'Endpoint $method $endpoint not found',
      });
    } catch (e, st) {
      debugPrint('❌ [REST API BACKEND ERROR] $e\n$st');
      return _jsonResponse(500, {
        'status': 'error',
        'message': 'Internal Server Error: $e',
      });
    }
  }

  Response _jsonResponse(int code, Map<String, dynamic> body) {
    debugPrint('⬅️ [REST API BACKEND] HTTP $code: ${body['message'] ?? ''}');
    return Response(
      statusCode: code,
      body: body,
      bodyString: jsonEncode(body),
      headers: {'content-type': 'application/json'},
    );
  }
}

extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
