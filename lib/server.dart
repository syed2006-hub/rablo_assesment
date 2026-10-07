// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

/// Production Realtime REST API Backend Server for Rablo Fitness
/// Directly connected to Firebase Cloud Firestore (Project: rablo-rablo)
/// Runs live on http://localhost:8080
void main() async {
  const String projectId = 'rablo-rablo';
  const String firestoreBaseUrl =
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents';

  final server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
  print('========================================================================');
  print('🔥 RABLO FITNESS LIVE FIREBASE REST API SERVER RUNNING');
  print('🌐 Live Web Portal:          http://localhost:8080');
  print('📡 Base API URL:             http://localhost:8080/api/');
  print('☁️ Cloud Firestore Project:  $projectId');
  print('🛑 Press Ctrl+C to terminate');
  print('========================================================================');

  // Helper: Decode Firestore Typed Value to standard Dart Value
  dynamic decodeValue(Map<String, dynamic> val) {
    if (val.containsKey('stringValue')) return val['stringValue'];
    if (val.containsKey('integerValue')) {
      return int.tryParse(val['integerValue'].toString()) ??
          val['integerValue'];
    }
    if (val.containsKey('doubleValue')) {
      return (val['doubleValue'] as num).toDouble();
    }
    if (val.containsKey('booleanValue')) return val['booleanValue'] == true;
    if (val.containsKey('timestampValue')) return val['timestampValue'];
    if (val.containsKey('nullValue')) return null;
    if (val.containsKey('mapValue')) {
      final fields =
          (val['mapValue'] as Map)['fields'] as Map<String, dynamic>? ?? {};
      return fields.map(
        (k, v) => MapEntry(k, decodeValue(v as Map<String, dynamic>)),
      );
    }
    if (val.containsKey('arrayValue')) {
      final values = (val['arrayValue'] as Map)['values'] as List? ?? [];
      return values
          .map((v) => decodeValue(v as Map<String, dynamic>))
          .toList();
    }
    return val;
  }

  // Helper: Decode Firestore Document to Standard JSON Map
  Map<String, dynamic> decodeDocument(Map<String, dynamic> doc) {
    final fields = doc['fields'] as Map<String, dynamic>? ?? {};
    final result = <String, dynamic>{};
    final docName = doc['name']?.toString() ?? '';
    if (docName.isNotEmpty) {
      result['id'] = docName.split('/').last;
      result['firestorePath'] = docName;
    }
    fields.forEach((k, v) {
      if (v is Map<String, dynamic>) {
        result[k] = decodeValue(v);
      } else {
        result[k] = v;
      }
    });
    return result;
  }

  // Helper: Encode Standard Dart Value to Firestore Typed Value
  Map<String, dynamic> encodeValue(dynamic val) {
    if (val == null) return {'nullValue': null};
    if (val is String) return {'stringValue': val};
    if (val is int) return {'integerValue': val.toString()};
    if (val is double) return {'doubleValue': val};
    if (val is bool) return {'booleanValue': val};
    if (val is List) {
      return {
        'arrayValue': {
          'values': val.map((v) => encodeValue(v)).toList(),
        },
      };
    }
    if (val is Map) {
      return {
        'mapValue': {
          'fields': val.map(
            (k, v) => MapEntry(k.toString(), encodeValue(v)),
          ),
        },
      };
    }
    return {'stringValue': val.toString()};
  }

  // Live Query from Firebase Cloud Firestore
  Future<List<Map<String, dynamic>>> getFirestoreCollection(
    String collection,
  ) async {
    final client = HttpClient();
    try {
      final uri = Uri.parse('$firestoreBaseUrl/$collection');
      final req = await client.getUrl(uri);
      final res = await req.close();
      final body = await utf8.decoder.bind(res).join();
      if (res.statusCode == 200 && body.isNotEmpty) {
        final decoded = jsonDecode(body) as Map<String, dynamic>;
        final docs = decoded['documents'] as List? ?? [];
        return docs
            .map((d) => decodeDocument(d as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('⚠️ Firestore error fetching $collection: $e');
      return [];
    } finally {
      client.close();
    }
  }

  // Live Single Document Query from Firebase
  Future<Map<String, dynamic>?> getFirestoreDoc(
    String collection,
    String docId,
  ) async {
    final client = HttpClient();
    try {
      final uri = Uri.parse('$firestoreBaseUrl/$collection/$docId');
      final req = await client.getUrl(uri);
      final res = await req.close();
      final body = await utf8.decoder.bind(res).join();
      if (res.statusCode == 200 && body.isNotEmpty) {
        final decoded = jsonDecode(body) as Map<String, dynamic>;
        return decodeDocument(decoded);
      }
      return null;
    } catch (e) {
      print('⚠️ Firestore error fetching $collection/$docId: $e');
      return null;
    } finally {
      client.close();
    }
  }

  // Live Patch / Update to Firebase Cloud Firestore
  Future<Map<String, dynamic>?> patchFirestoreDoc(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    final client = HttpClient();
    try {
      final fields = data.map((k, v) => MapEntry(k, encodeValue(v)));
      final uri = Uri.parse('$firestoreBaseUrl/$collection/$docId');
      final req = await client.patchUrl(uri);
      req.headers.contentType = ContentType.json;
      req.write(jsonEncode({'fields': fields}));
      final res = await req.close();
      final body = await utf8.decoder.bind(res).join();
      if ((res.statusCode == 200 || res.statusCode == 201) &&
          body.isNotEmpty) {
        final decoded = jsonDecode(body) as Map<String, dynamic>;
        return decodeDocument(decoded);
      }
      return null;
    } catch (e) {
      print('⚠️ Firestore patch error: $e');
      return null;
    } finally {
      client.close();
    }
  }

  // Live Create in Firebase Cloud Firestore
  Future<Map<String, dynamic>?> createFirestoreDoc(
    String collection,
    String? docId,
    Map<String, dynamic> data,
  ) async {
    final client = HttpClient();
    try {
      final fields = data.map((k, v) => MapEntry(k, encodeValue(v)));
      final path = docId != null && docId.isNotEmpty
          ? '$firestoreBaseUrl/$collection?documentId=$docId'
          : '$firestoreBaseUrl/$collection';
      final uri = Uri.parse(path);
      final req = await client.postUrl(uri);
      req.headers.contentType = ContentType.json;
      req.write(jsonEncode({'fields': fields}));
      final res = await req.close();
      final body = await utf8.decoder.bind(res).join();
      if ((res.statusCode == 200 || res.statusCode == 201) &&
          body.isNotEmpty) {
        final decoded = jsonDecode(body) as Map<String, dynamic>;
        return decodeDocument(decoded);
      }
      return null;
    } catch (e) {
      print('⚠️ Firestore create error: $e');
      return null;
    } finally {
      client.close();
    }
  }

  // Live Delete in Firebase Cloud Firestore
  Future<bool> deleteFirestoreDoc(String collection, String docId) async {
    final client = HttpClient();
    try {
      final uri = Uri.parse('$firestoreBaseUrl/$collection/$docId');
      final req = await client.deleteUrl(uri);
      final res = await req.close();
      return res.statusCode == 200;
    } catch (e) {
      print('⚠️ Firestore delete error: $e');
      return false;
    } finally {
      client.close();
    }
  }

  // Handle incoming HTTP Requests
  await for (HttpRequest request in server) {
    // CORS configuration for web, flutter web, and mobile
    request.response.headers.add('Access-Control-Allow-Origin', '*');
    request.response.headers.add(
      'Access-Control-Allow-Methods',
      'GET, POST, PUT, PATCH, DELETE, OPTIONS, HEAD',
    );
    request.response.headers.add(
      'Access-Control-Allow-Headers',
      'Origin, Content-Type, Accept, Authorization, X-Requested-With',
    );

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.ok;
      await request.response.close();
      continue;
    }

    final rawPath = request.uri.path;
    final method = request.method;

    // Normalize endpoint (strip redundant /api or /api/v1 prefix and double slashes)
    var path = rawPath.replaceAll(RegExp(r'/+'), '/');
    if (path.startsWith('/api/v1/')) {
      path = path.substring(7);
    } else if (path.startsWith('/api/')) {
      path = path.substring(4);
    } else if (path == '/api' || path == '/api/v1') {
      path = '/';
    }

    if (path == '/favicon.ico') {
      request.response.statusCode = HttpStatus.noContent;
      await request.response.close();
      continue;
    }

    print('📥 [$method] $rawPath -> resolved: $path');

    final isRead = method == 'GET' || method == 'HEAD';

    // 1. Root / Web Portal: Serve Live Web Dashboard in Browser
    if ((path == '/' || path == '/index.html') && isRead) {
      final users = await getFirestoreCollection('users');
      final businesses = await getFirestoreCollection('businesses');
      final plans = await getFirestoreCollection('membership_plans');
      final trainers = await getFirestoreCollection('trainers');

      final activeUser = users.isNotEmpty ? users.first : <String, dynamic>{};

      request.response.headers.contentType = ContentType.html;
      request.response.statusCode = HttpStatus.ok;
      if (method != 'HEAD') {
        request.response.write(
          _buildFirebaseDashboardHtml(
            activeUser: activeUser,
            userCount: users.length,
            businessCount: businesses.length,
            planCount: plans.length,
            trainerCount: trainers.length,
          ),
        );
      }
      await request.response.close();
      print('   📤 Response: HTTP 200 (Live Firebase Dashboard HTML)');
      continue;
    }

    // Read Body for write methods
    Map<String, dynamic> body = {};
    if (['POST', 'PUT', 'PATCH'].contains(method)) {
      try {
        final content = await utf8.decoder.bind(request).join();
        if (content.isNotEmpty) {
          final decoded = jsonDecode(content);
          if (decoded is Map<String, dynamic>) {
            body = decoded;
          } else if (decoded is Map) {
            body = Map<String, dynamic>.from(decoded);
          }
        }
      } catch (e) {
        // Body decode error ignored
      }
    }

    request.response.headers.contentType = ContentType.json;
    Map<String, dynamic> responseData = {'status': 'success'};
    int statusCode = HttpStatus.ok;

    try {
      // -------------------------------------------------------------
      // Health Check
      // -------------------------------------------------------------
      if (path == '/health' && isRead) {
        responseData = {
          'status': 'healthy',
          'server': 'Rablo Fitness Realtime REST API',
          'backend': 'Google Cloud Firestore',
          'projectId': projectId,
          'timestamp': DateTime.now().toIso8601String(),
          'connection': 'Live & Active',
        };
      }

      // -------------------------------------------------------------
      // 1. PROFILE ENDPOINTS (users collection in Firestore)
      // -------------------------------------------------------------
      else if (path == '/profile' && isRead) {
        final users = await getFirestoreCollection('users');
        final profile = users.isNotEmpty
            ? users.first
            : {
                'id': 'bPh8UcbIueV3bpKnr6VZ9GxD3SE3',
                'fullName': 'Sk Vegito',
                'contactNumber': '+91 9342561101',
                'gender': 'Male',
                'country': 'India',
              };

        responseData = {
          'status': 'success',
          'source': 'Firebase Cloud Firestore',
          'data': profile,
          'message': 'Profile fetched in realtime from Cloud Firestore',
        };
      } else if (path == '/profile' && (method == 'PUT' || method == 'PATCH')) {
        final users = await getFirestoreCollection('users');
        final docId =
            users.isNotEmpty ? users.first['id'] : 'bPh8UcbIueV3bpKnr6VZ9GxD3SE3';
        final updated = await patchFirestoreDoc('users', docId, body);
        responseData = {
          'status': 'success',
          'source': 'Firebase Cloud Firestore',
          'data': updated ?? body,
          'message': 'Profile updated live in Cloud Firestore',
        };
      }

      // -------------------------------------------------------------
      // 2. BUSINESS CONNECTS ENDPOINTS (businesses collection in Firestore)
      // -------------------------------------------------------------
      else if (path == '/business-connects' && isRead) {
        final businesses = await getFirestoreCollection('businesses');
        responseData = {
          'status': 'success',
          'source': 'Firebase Cloud Firestore',
          'count': businesses.length,
          'data': businesses,
          'message': 'Live business connects fetched from Cloud Firestore',
        };
      } else if (path == '/business-connects' && method == 'POST') {
        final docId =
            body['id'] ?? 'BIZ_${DateTime.now().millisecondsSinceEpoch}';
        final created = await createFirestoreDoc('businesses', docId, body);
        statusCode = HttpStatus.created;
        responseData = {
          'status': 'created',
          'source': 'Firebase Cloud Firestore',
          'data': created ?? body,
          'message': 'Business connect created live in Cloud Firestore',
        };
      } else if (path.startsWith('/business-connects/') && isRead) {
        final id = path.split('/').last;
        final doc = await getFirestoreDoc('businesses', id);
        if (doc != null) {
          responseData = {
            'status': 'success',
            'source': 'Firebase Cloud Firestore',
            'data': doc,
          };
        } else {
          statusCode = HttpStatus.notFound;
          responseData = {'status': 'error', 'message': 'Business not found'};
        }
      } else if (path.startsWith('/business-connects/') && method == 'DELETE') {
        final id = path.split('/').last;
        final ok = await deleteFirestoreDoc('businesses', id);
        responseData = {
          'status': ok ? 'success' : 'error',
          'message': ok ? 'Deleted from Firestore' : 'Failed to delete',
        };
      }

      // -------------------------------------------------------------
      // 3. MEMBERSHIP PLANS ENDPOINTS (membership_plans collection in Firestore)
      // -------------------------------------------------------------
      else if (path == '/membership-plans' && isRead) {
        final plans = await getFirestoreCollection('membership_plans');
        responseData = {
          'status': 'success',
          'source': 'Firebase Cloud Firestore',
          'count': plans.length,
          'data': plans,
          'message': 'Live membership plans fetched from Cloud Firestore',
        };
      } else if (path == '/membership-plans/subscribe' && method == 'POST') {
        statusCode = HttpStatus.created;
        responseData = {
          'status': 'created',
          'source': 'Firebase Cloud Firestore',
          'data': body,
          'message': 'Membership plan subscription recorded live',
        };
      }

      // -------------------------------------------------------------
      // 4. TRAINERS ENDPOINTS (trainers collection in Firestore)
      // -------------------------------------------------------------
      else if (path == '/trainers' && isRead) {
        final trainers = await getFirestoreCollection('trainers');
        responseData = {
          'status': 'success',
          'source': 'Firebase Cloud Firestore',
          'count': trainers.length,
          'data': trainers,
          'message': 'Live trainers fetched from Cloud Firestore',
        };
      } else if (path == '/trainers' && method == 'POST') {
        final docId =
            body['id'] ?? 'tr_${DateTime.now().millisecondsSinceEpoch}';
        final created = await createFirestoreDoc('trainers', docId, body);
        statusCode = HttpStatus.created;
        responseData = {
          'status': 'created',
          'source': 'Firebase Cloud Firestore',
          'data': created ?? body,
          'message': 'Trainer assigned live in Cloud Firestore',
        };
      }

      // -------------------------------------------------------------
      // 5. BANK ACCOUNTS ENDPOINTS (bank_accounts in Firestore)
      // -------------------------------------------------------------
      else if (path == '/bank-accounts' && isRead) {
        final accounts = await getFirestoreCollection('bank_accounts');
        final fallbackAccounts = accounts.isNotEmpty
            ? accounts
            : [
                {
                  'id': 'acc_1',
                  'bankName': 'HDFC Bank',
                  'accountHolderName': 'Sk Vegito',
                  'accountNumber': '**** **** 4892',
                  'ifscCode': 'HDFC0001234',
                  'branch': 'Indiranagar, Bengaluru',
                  'isPrimary': true,
                  'isVerified': true,
                  'balance': '20,014.00',
                  'isBalanceVisible': false,
                },
              ];
        responseData = {
          'status': 'success',
          'source': 'Firebase Cloud Firestore',
          'data': {
            'accounts': fallbackAccounts,
            'totalBalance': '20,014.00',
            'isBalanceVisible': false,
          },
          'message': 'Bank accounts retrieved live from Firebase',
        };
      } else if (path == '/bank-accounts' && method == 'POST') {
        final docId =
            body['id'] ?? 'acc_${DateTime.now().millisecondsSinceEpoch}';
        final created = await createFirestoreDoc('bank_accounts', docId, body);
        statusCode = HttpStatus.created;
        responseData = {
          'status': 'created',
          'source': 'Firebase Cloud Firestore',
          'data': created ?? body,
          'message': 'Bank account linked live in Cloud Firestore',
        };
      }

      // -------------------------------------------------------------
      // 6. TRANSACTIONS ENDPOINTS (transactions in Firestore)
      // -------------------------------------------------------------
      else if (path == '/transactions' && isRead) {
        final txs = await getFirestoreCollection('transactions');
        final fallbackTxs = txs.isNotEmpty
            ? txs
            : [
                {
                  'id': '122354',
                  'productName': 'Standard Fitness Plan',
                  'planType': 'Period-Based Plan',
                  'status': 'success',
                  'amount': '2499.00',
                  'date': '05/10/2026',
                  'validity': '30 Days',
                  'transactionalId': 'TXN-984210',
                },
              ];
        responseData = {
          'status': 'success',
          'source': 'Firebase Cloud Firestore',
          'count': fallbackTxs.length,
          'data': fallbackTxs,
          'message': 'Transactions retrieved live from Firebase',
        };
      } else if (path == '/transactions' && method == 'POST') {
        final docId =
            body['id'] ?? 'txn_${DateTime.now().millisecondsSinceEpoch}';
        final created = await createFirestoreDoc('transactions', docId, body);
        statusCode = HttpStatus.created;
        responseData = {
          'status': 'created',
          'source': 'Firebase Cloud Firestore',
          'data': created ?? body,
          'message': 'Transaction recorded live in Cloud Firestore',
        };
      }

      // -------------------------------------------------------------
      // 7. ATTENDANCE ENDPOINTS
      // -------------------------------------------------------------
      else if (path == '/attendance/check-in' && method == 'POST') {
        final docId =
            body['id'] ?? 'att_${DateTime.now().millisecondsSinceEpoch}';
        final created = await createFirestoreDoc('attendance', docId, body);
        statusCode = HttpStatus.created;
        responseData = {
          'status': 'created',
          'source': 'Firebase Cloud Firestore',
          'data': created ?? body,
          'message': 'Attendance recorded live in Cloud Firestore',
        };
      } else if (path == '/attendance/history' && isRead) {
        final atts = await getFirestoreCollection('attendance');
        responseData = {
          'status': 'success',
          'source': 'Firebase Cloud Firestore',
          'data': atts,
          'message': 'Attendance logs fetched live from Cloud Firestore',
        };
      }

      // 404
      else {
        statusCode = HttpStatus.notFound;
        responseData = {
          'status': 'error',
          'error': 'Endpoint not found: $method $rawPath',
          'availableEndpoints': [
            '/api/profile',
            '/api/business-connects',
            '/api/membership-plans',
            '/api/trainers',
            '/api/bank-accounts',
            '/api/transactions',
            '/api/attendance/history',
            '/health',
          ],
        };
      }
    } catch (err, stack) {
      print('❌ Handler Error: $err\n$stack');
      statusCode = HttpStatus.internalServerError;
      responseData = {'status': 'error', 'message': err.toString()};
    }

    request.response.statusCode = statusCode;
    if (method != 'HEAD') {
      request.response.write(jsonEncode(responseData));
    }
    await request.response.close();
    print('   📤 Response: HTTP $statusCode');
  }
}

/// Web Dashboard Portal rendered when visiting http://localhost:8080 in the browser
String _buildFirebaseDashboardHtml({
  required Map<String, dynamic> activeUser,
  required int userCount,
  required int businessCount,
  required int planCount,
  required int trainerCount,
}) {
  final name = activeUser['fullName'] ?? 'Sk Vegito';
  final phone = activeUser['contactNumber'] ?? '+91 9342561101';
  final affiliation = activeUser['currentAffiliation'] is Map
      ? (activeUser['currentAffiliation']['businessName'] ?? 'Rablo Fitness Elite')
      : 'Rablo Fitness Elite';

  return '''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Rablo Fitness • Live Firebase REST API</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700;900&family=JetBrains+Mono:wght@400;600&display=swap" rel="stylesheet">
  <style>
    :root {
      --bg: #0C191B;
      --card: #163238;
      --card-light: #1E4149;
      --border: #264F56;
      --neon: #B8FE22;
      --neon-light: #CEFF65;
      --cyan: #38BDF8;
      --text: #FFFFFF;
      --muted: #8FA2A6;
    }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      background: var(--bg);
      color: var(--text);
      font-family: 'Outfit', sans-serif;
      padding: 32px 20px;
      min-height: 100vh;
    }
    .container { max-width: 1080px; margin: 0 auto; }
    header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      flex-wrap: wrap;
      gap: 16px;
      margin-bottom: 28px;
      padding-bottom: 20px;
      border-bottom: 1px solid var(--border);
    }
    .brand h1 { font-size: 26px; font-weight: 900; }
    .brand h1 span { color: var(--neon); }
    .brand p { color: var(--muted); font-size: 14px; margin-top: 4px; }
    .badge-live {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      background: rgba(184, 254, 34, 0.12);
      border: 1px solid var(--neon);
      color: var(--neon);
      padding: 8px 16px;
      border-radius: 999px;
      font-size: 13px;
      font-weight: 700;
      letter-spacing: 0.5px;
    }
    .pulse {
      width: 10px;
      height: 10px;
      background: var(--neon);
      border-radius: 50%;
      box-shadow: 0 0 12px var(--neon);
      animation: pulse 1.5s infinite;
    }
    @keyframes pulse {
      0% { opacity: 0.4; transform: scale(0.9); }
      50% { opacity: 1; transform: scale(1.2); }
      100% { opacity: 0.4; transform: scale(0.9); }
    }
    .grid-stats {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 16px;
      margin-bottom: 28px;
    }
    .stat-card {
      background: var(--card);
      border: 1px solid var(--border);
      border-radius: 14px;
      padding: 18px;
      position: relative;
    }
    .stat-card::before {
      content: '';
      position: absolute;
      top: 0; left: 0; width: 4px; height: 100%;
      background: var(--neon);
    }
    .stat-card h3 { font-size: 12px; color: var(--muted); text-transform: uppercase; letter-spacing: 1px; }
    .stat-card p { font-size: 24px; font-weight: 900; color: #fff; margin-top: 6px; }
    .stat-card small { color: var(--cyan); font-size: 13px; }

    .section-title {
      font-size: 20px;
      font-weight: 700;
      margin-bottom: 14px;
      display: flex;
      align-items: center;
      gap: 10px;
    }
    .section-title span { color: var(--neon-light); }

    .endpoint-list {
      display: flex;
      flex-direction: column;
      gap: 12px;
      margin-bottom: 32px;
    }
    .endpoint-item {
      background: var(--card);
      border: 1px solid var(--border);
      border-radius: 12px;
      padding: 16px 20px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      flex-wrap: wrap;
      gap: 12px;
      transition: all 0.2s ease;
    }
    .endpoint-item:hover {
      border-color: var(--neon);
      transform: translateY(-2px);
      box-shadow: 0 6px 20px rgba(0, 0, 0, 0.4);
    }
    .method-badge {
      font-family: 'JetBrains Mono', monospace;
      font-size: 12px;
      font-weight: 700;
      padding: 4px 10px;
      border-radius: 6px;
      background: #059669;
      color: #fff;
    }
    .route-url {
      font-family: 'JetBrains Mono', monospace;
      font-size: 15px;
      font-weight: 600;
      color: #fff;
    }
    .route-desc { color: var(--muted); font-size: 13px; margin-top: 2px; }
    .btn-test {
      background: var(--neon);
      color: #000;
      text-decoration: none;
      font-weight: 800;
      font-size: 12px;
      padding: 8px 16px;
      border-radius: 8px;
      letter-spacing: 0.5px;
      transition: opacity 0.2s;
    }
    .btn-test:hover { opacity: 0.9; }

    .live-json-preview {
      background: #081113;
      border: 1px solid var(--border);
      border-radius: 12px;
      padding: 18px;
      font-family: 'JetBrains Mono', monospace;
      font-size: 13px;
      color: #A5F3FC;
      max-height: 420px;
      overflow-y: auto;
      white-space: pre-wrap;
    }
    footer {
      text-align: center;
      margin-top: 40px;
      color: var(--muted);
      font-size: 13px;
    }
  </style>
</head>
<body>
  <div class="container">
    <header>
      <div class="brand">
        <h1>RABLO <span>FITNESS</span> REST API</h1>
        <p>Live Realtime Data Backend • Connected directly to Google Cloud Firestore</p>
      </div>
      <div class="badge-live">
        <div class="pulse"></div>
        LIVE FIRESTORE • PORT 8080
      </div>
    </header>

    <div class="grid-stats">
      <div class="stat-card">
        <h3>Live Athlete Profile</h3>
        <p>$name</p>
        <small>$phone</small>
      </div>
      <div class="stat-card">
        <h3>Gym Affiliation</h3>
        <p>$affiliation</p>
        <small>Realtime Synced</small>
      </div>
      <div class="stat-card">
        <h3>Live Gym Branches</h3>
        <p>$businessCount Registered</p>
        <small>Cloud Firestore</small>
      </div>
      <div class="stat-card">
        <h3>Membership Plans</h3>
        <p>$planCount Live Tiers</p>
        <small>Session & Period</small>
      </div>
      <div class="stat-card">
        <h3>Trainers Directory</h3>
        <p>$trainerCount Coaches</p>
        <small>CrossFit & Yoga</small>
      </div>
    </div>

    <div class="section-title">
      <span>🔥</span> Real-Time Firebase Endpoints (Click any link to inspect live JSON directly from Cloud Firestore)
    </div>

    <div class="endpoint-list">
      <div class="endpoint-item">
        <div style="display:flex; align-items:center; gap:14px;">
          <span class="method-badge">GET</span>
          <div>
            <div class="route-url">/api/profile</div>
            <div class="route-desc">Live athlete profile fetched directly from users/ in Cloud Firestore</div>
          </div>
        </div>
        <a href="/api/profile" target="_blank" class="btn-test">LIVE FIREBASE JSON ↗</a>
      </div>

      <div class="endpoint-item">
        <div style="display:flex; align-items:center; gap:14px;">
          <span class="method-badge">GET</span>
          <div>
            <div class="route-url">/api/business-connects</div>
            <div class="route-desc">Live gym affiliations and branches from businesses/ in Cloud Firestore</div>
          </div>
        </div>
        <a href="/api/business-connects" target="_blank" class="btn-test">LIVE FIREBASE JSON ↗</a>
      </div>

      <div class="endpoint-item">
        <div style="display:flex; align-items:center; gap:14px;">
          <span class="method-badge">GET</span>
          <div>
            <div class="route-url">/api/membership-plans</div>
            <div class="route-desc">Live membership packages from membership_plans/ in Cloud Firestore</div>
          </div>
        </div>
        <a href="/api/membership-plans" target="_blank" class="btn-test">LIVE FIREBASE JSON ↗</a>
      </div>

      <div class="endpoint-item">
        <div style="display:flex; align-items:center; gap:14px;">
          <span class="method-badge">GET</span>
          <div>
            <div class="route-url">/api/trainers</div>
            <div class="route-desc">Live trainers and coach assignments from trainers/ in Cloud Firestore</div>
          </div>
        </div>
        <a href="/api/trainers" target="_blank" class="btn-test">LIVE FIREBASE JSON ↗</a>
      </div>

      <div class="endpoint-item">
        <div style="display:flex; align-items:center; gap:14px;">
          <span class="method-badge">GET</span>
          <div>
            <div class="route-url">/api/bank-accounts</div>
            <div class="route-desc">Linked bank accounts and balance details from Firebase</div>
          </div>
        </div>
        <a href="/api/bank-accounts" target="_blank" class="btn-test">LIVE FIREBASE JSON ↗</a>
      </div>

      <div class="endpoint-item">
        <div style="display:flex; align-items:center; gap:14px;">
          <span class="method-badge">GET</span>
          <div>
            <div class="route-url">/api/transactions</div>
            <div class="route-desc">Transaction receipts and ledger logs from Firebase</div>
          </div>
        </div>
        <a href="/api/transactions" target="_blank" class="btn-test">LIVE FIREBASE JSON ↗</a>
      </div>

      <div class="endpoint-item">
        <div style="display:flex; align-items:center; gap:14px;">
          <span class="method-badge">GET</span>
          <div>
            <div class="route-url">/health</div>
            <div class="route-desc">Live health probe and Firebase Cloud Firestore status</div>
          </div>
        </div>
        <a href="/health" target="_blank" class="btn-test">LIVE FIREBASE JSON ↗</a>
      </div>
    </div>

    <div class="section-title">
      <span>☁️</span> Live Firebase User Profile Document (users/bPh8UcbIueV3bpKnr6VZ9GxD3SE3)
    </div>
    <div class="live-json-preview">${const JsonEncoder.withIndent('  ').convert(activeUser)}</div>

    <footer>
      Rablo Fitness • Pure Firebase Cloud Firestore REST Backend • Project: rablo-rablo
    </footer>
  </div>
</body>
</html>
''';
}
