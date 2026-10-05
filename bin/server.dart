// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

/// Standalone REST API Backend Server for Rablo Fitness App
/// Run with: dart run bin/server.dart
void main() async {
  final server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
  print('======================================================');
  print('🚀 Rablo REST API Backend running on: http://localhost:8080');
  print('📡 Endpoints base path: http://localhost:8080/api/v1');
  print('🛑 Press Ctrl+C to stop the server');
  print('======================================================');

  // In-memory persistent database
  final Map<String, dynamic> profile = {
    'id': 'MEM-001',
    'fullName': 'Alex Morgan',
    'email': 'alex.fitness@gmail.com',
    'phoneNumber': '+91 98765 - 43210',
    'gender': 'Male',
    'role': 'Manager/Owner',
    'dob': '09 - 11 - 1998',
    'addressLine1': 'MG Road 4th Cross',
    'addressLine2': 'Indiranagar',
    'country': 'India',
    'state': 'Karnataka',
    'city': 'Bengaluru',
    'pincode': '560038',
    'preferredLanguages': ['English', 'Hindi', 'Kannada'],
    'isVerified': true,
    'photoUrl': 'assets/images/profile_avatar.png',
  };

  final List<Map<String, dynamic>> bankAccounts = [
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

  final List<Map<String, dynamic>> transactions = [
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

  final List<Map<String, dynamic>> trainers = [
    {
      'id': 'tr_1',
      'name': 'Rahul Sharma',
      'specialty': 'CrossFit & Strength Coach',
      'rating': 4.9,
      'sessionsTotal': 20,
      'sessionsRemaining': 12,
      'isActive': true,
      'schedule': 'Mon, Wed, Fri • 07:00 AM',
    },
    {
      'id': 'tr_2',
      'name': 'Priya Patel',
      'specialty': 'Yoga & Flexibility Specialist',
      'rating': 4.8,
      'sessionsTotal': 15,
      'sessionsRemaining': 8,
      'isActive': true,
      'schedule': 'Tue, Thu, Sat • 06:30 PM',
    },
  ];

  final List<Map<String, dynamic>> businessConnects = [
    {
      'id': 'biz_1',
      'name': 'PowerFit Gym & Health Centre',
      'address': 'Indiranagar, Bangalore',
      'status': 'Active',
      'plan': 'Period-Based Annual Plan',
      'planDuration': '90 Days left',
    },
    {
      'id': 'biz_2',
      'name': 'IronCore Fitness Studio',
      'address': 'Koramangala 4th Block, Bangalore',
      'status': 'Expired',
      'plan': 'Quarterly Strength Pass',
      'planDuration': 'Expired on 15 Aug',
    },
  ];

  await for (HttpRequest request in server) {
    // Enable CORS for Flutter Web (Chrome) & Mobile
    request.response.headers.add('Access-Control-Allow-Origin', '*');
    request.response.headers.add(
      'Access-Control-Allow-Methods',
      'GET, POST, PUT, PATCH, DELETE, OPTIONS',
    );
    request.response.headers.add(
      'Access-Control-Allow-Headers',
      'Origin, Content-Type, Accept, Authorization',
    );
    request.response.headers.contentType = ContentType.json;

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.ok;
      await request.response.close();
      continue;
    }

    final path = request.uri.path;
    final method = request.method;
    print('📥 [$method] $path');

    // Read JSON Body if available
    Map<String, dynamic> body = {};
    if (['POST', 'PUT', 'PATCH'].contains(method)) {
      try {
        final content = await utf8.decoder.bind(request).join();
        if (content.isNotEmpty) {
          body = jsonDecode(content) as Map<String, dynamic>;
        }
      } catch (e) {
        // Ignore body parse error
      }
    }

    Map<String, dynamic> responseData = {'status': 'success'};
    int statusCode = HttpStatus.ok;

    // 1. Profile Routes
    if (path == '/api/v1/profile' && method == 'GET') {
      responseData = {'data': profile, 'message': 'Profile retrieved'};
    } else if (path == '/api/v1/profile' && method == 'PUT') {
      profile.addAll(body);
      responseData = {'data': profile, 'message': 'Profile updated via PUT'};
    } else if (path == '/api/v1/profile/verification' && method == 'PATCH') {
      profile['isVerified'] = !(profile['isVerified'] ?? false);
      responseData = {'data': {'isVerified': profile['isVerified']}, 'message': 'Verification patched'};
    }

    // 2. Bank Accounts Routes
    else if (path == '/api/v1/bank-accounts' && method == 'GET') {
      responseData = {
        'data': {
          'accounts': bankAccounts,
          'totalBalance': '20,014.00',
        },
        'message': 'Bank accounts retrieved',
      };
    } else if (path == '/api/v1/bank-accounts' && method == 'POST') {
      final newAcc = Map<String, dynamic>.from(body);
      newAcc['id'] = 'acc_${DateTime.now().millisecondsSinceEpoch}';
      newAcc['isVerified'] = true;
      newAcc['balance'] = '20,014.00';
      newAcc['accountNumber'] = '**** **** 4892';
      bankAccounts.add(newAcc);
      statusCode = HttpStatus.created;
      responseData = {'data': newAcc, 'message': 'Account linked via POST'};
    } else if (path.startsWith('/api/v1/bank-accounts/') && path.endsWith('/visibility') && method == 'PATCH') {
      final isVis = body['isVisible'] ?? false;
      responseData = {'data': {'isBalanceVisible': isVis}, 'message': 'Visibility patched'};
    } else if (path.startsWith('/api/v1/bank-accounts/') && method == 'DELETE') {
      final id = path.split('/').last;
      bankAccounts.removeWhere((acc) => acc['id'] == id);
      responseData = {'message': 'Account deleted via DELETE'};
    }

    // 3. Transactions Routes
    else if (path == '/api/v1/transactions' && method == 'GET') {
      responseData = {'data': transactions, 'message': 'Transactions retrieved'};
    }

    // 4. Trainers Routes
    else if (path == '/api/v1/trainers' && method == 'GET') {
      responseData = {'data': trainers, 'message': 'Trainers retrieved'};
    } else if (path == '/api/v1/trainers' && method == 'POST') {
      final newTr = Map<String, dynamic>.from(body);
      newTr['id'] = 'tr_${DateTime.now().millisecondsSinceEpoch}';
      trainers.add(newTr);
      statusCode = HttpStatus.created;
      responseData = {'data': newTr, 'message': 'Trainer assigned via POST'};
    } else if (path.startsWith('/api/v1/trainers/') && method == 'DELETE') {
      final id = path.split('/').last;
      trainers.removeWhere((t) => t['id'] == id);
      responseData = {'message': 'Trainer removed via DELETE'};
    }

    // 5. Business Connects Routes
    else if (path == '/api/v1/business-connects' && method == 'GET') {
      responseData = {'data': businessConnects, 'message': 'Business connects retrieved'};
    } else if (path == '/api/v1/business-connects' && method == 'POST') {
      final newBiz = Map<String, dynamic>.from(body);
      newBiz['id'] = 'biz_${DateTime.now().millisecondsSinceEpoch}';
      businessConnects.add(newBiz);
      statusCode = HttpStatus.created;
      responseData = {'data': newBiz, 'message': 'Business connected via POST'};
    } else if (path.startsWith('/api/v1/business-connects/') && method == 'DELETE') {
      final id = path.split('/').last;
      businessConnects.removeWhere((b) => b['id'] == id);
      responseData = {'message': 'Connection cancelled via DELETE'};
    }

    // 404 Fallback
    else {
      statusCode = HttpStatus.notFound;
      responseData = {'error': 'Route not found: $method $path'};
    }

    request.response.statusCode = statusCode;
    request.response.write(jsonEncode(responseData));
    await request.response.close();
    print('   📤 Response: HTTP $statusCode');
  }
}
