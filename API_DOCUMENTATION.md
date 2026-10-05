# 📘 Rablo Fitness – API Integration & Dynamic Data Documentation (DAY 9 & 10)

## 📌 Executive Overview
This document specifies the end-to-end REST API architecture, Cloud Firestore real-time synchronization, data serialization models, centralized state handling (Loading, Success, Empty, Error + Retry), and rigorous form input validation and error handling for the Rablo Fitness application.

---

## 🏗️ 1. Architecture & Service Layer
The application implements a layered architecture:
1. **Network Layer**: `ApiClient` (`lib/api/api_client.dart`) built on `GetConnect` with automatic JSON request/response modifiers, logging, and in-memory mock REST engine fallback (`MockRestBackend`).
2. **Security & Token Layer**: `AuthTokenManager` (`lib/api/auth_token_manager.dart`) injecting `Authorization: Bearer <JWT>` on all requests, tracking token expiration, and dispatching session invalidation upon HTTP 401.
3. **Reactive State Layer**: `DynamicStateView<T>` (`lib/api/api_state.dart`) managing the 4 canonical view states:
   - **Loading State**: Glowing pulse indicator with animated progress spinner and status caption.
   - **Success State**: Reactive dynamic data rendering with smooth UI builders.
   - **Empty State**: Tailored empty illustrations with contextual guidance and actionable CTA buttons (e.g. "Add Bank Account", "Assign New Trainer").
   - **Error State**: Coral-accented error cards presenting the HTTP status code, descriptive error message, connection troubleshooting tips, and an interactive **Retry Request** button.
4. **Form Validation & Error Layer**: `Validators` (`lib/utils/validators.dart`) and `FormFeedbackWidgets` (`lib/widgets/form_feedback_widgets.dart`) providing inline field validation, duplicate submission protection (`FormSubmitButton`), and server validation banners (`ApiValidationBanner`).
5. **Persistence & Cloud Sync**: `CustomerFirebaseService` (`lib/services/firebase/customer_firebase_service.dart`) providing bi-directional synchronization between Cloud Firestore collections and local reactive state.

---

## 🔐 2. Authentication & Authorization Headers
All secured endpoints require a valid Bearer JWT token in the HTTP `Authorization` request header:
```http
Authorization: Bearer <jwt_access_token>
Accept: application/json
Content-Type: application/json
```

### Token Lifecycle & Expiration:
- If an API returns **HTTP 401 (Unauthorized)**, `ApiClient` automatically alerts `AuthTokenManager` to purge the expired token and directs the user to re-authenticate.
- During development or offline execution, `AuthTokenManager` supplies a simulated JWT session token.

---

## 📡 3. REST API Endpoints Specification

### 3.1 Bank Accounts & Financial Transactions
#### `GET /api/bank-accounts`
- **Description**: Retrieves linked bank payout accounts for the authenticated customer/manager.
- **Request Headers**: `Authorization: Bearer <token>`
- **Response `200 OK`**:
```json
{
  "statusCode": 200,
  "message": "Bank accounts retrieved successfully",
  "data": {
    "totalBalance": "20,014.00",
    "accounts": [
      {
        "id": "acc_1",
        "bankName": "HDFC Bank",
        "accountHolderName": "Alex Morgan",
        "accountNumber": "**** **** 4892",
        "fullAccountNumber": "50100234564892",
        "ifscCode": "HDFC0001234",
        "branch": "Indiranagar, Bengaluru",
        "isPrimary": true,
        "isVerified": true,
        "balance": "20,014.00",
        "isBalanceVisible": false
      }
    ]
  }
}
```

#### `POST /api/bank-accounts`
- **Description**: Links a new verified bank account.
- **Request Body**:
```json
{
  "bankName": "State Bank of India",
  "accountHolderName": "Alex Morgan",
  "fullAccountNumber": "50100492837192",
  "ifscCode": "SBIN0001824",
  "branch": "Indiranagar Branch"
}
```
- **Response `201 Created`**:
```json
{
  "statusCode": 201,
  "message": "Bank account linked successfully",
  "data": {
    "id": "acc_1712345678",
    "bankName": "State Bank of India",
    "accountNumber": "**** **** 7192",
    "status": "Active"
  }
}
```
- **Response `400 Bad Request` (Validation Failure)**:
```json
{
  "statusCode": 400,
  "message": "Bank account validation failed",
  "errors": {
    "ifscCode": "Invalid IFSC code format",
    "fullAccountNumber": "Account number must be between 9 and 18 digits"
  }
}
```

#### `GET /api/transactions`
- **Description**: Fetches transactional history with time-range filtering.
- **Query Parameters**: `?filter=today` | `?filter=thisWeek` | `?filter=thisMonth`
- **Response `200 OK`**:
```json
{
  "statusCode": 200,
  "message": "Transactions retrieved",
  "data": [
    {
      "id": "122354",
      "productName": "Gold Monthly Pass",
      "planType": "Period-Based Plan",
      "status": "success",
      "amount": "1514.00",
      "date": "26/11/2024",
      "validity": "30 Mar 2024",
      "transactionalId": "123454878"
    }
  ]
}
```

---

### 3.2 Trainers & Coaching
#### `GET /api/trainers`
- **Description**: Fetches assigned personal fitness coaches.
- **Response `200 OK`**:
```json
{
  "statusCode": 200,
  "message": "Trainers retrieved",
  "data": [
    {
      "id": "t1",
      "name": "Rahul Sharma",
      "role": "Master Trainer & Strength Coach",
      "specialty": "CrossFit, Powerlifting & Muscle Gain",
      "rating": "4.9",
      "reviewsCount": "128",
      "sessionsCompleted": 48,
      "timing": "Mon, Wed, Fri • 07:00 AM - 08:30 AM",
      "status": "Assigned"
    }
  ]
}
```

#### `POST /api/trainers`
- **Description**: Assigns a new coach to the user schedule.
- **Request Body**:
```json
{
  "name": "Sneha Rao",
  "role": "Certified Coach",
  "specialty": "Yoga & Core Pilates",
  "timing": "Morning (07:00 AM - 08:30 AM)",
  "rating": "4.9",
  "sessionsCompleted": 0
}
```

---

### 3.3 Membership Plans
#### `GET /api/membership-plans`
- **Description**: Lists all available gym memberships, passes, and session bundles.
- **Response `200 OK`**:
```json
{
  "statusCode": 200,
  "data": [
    {
      "id": "p1",
      "name": "Session Pass (30 Count)",
      "type": "Session-Based Plan",
      "price": 100.0,
      "durationMonths": 3,
      "features": ["30 Full Access Training Sessions", "Shower & Locker Access"]
    }
  ]
}
```

#### `POST /api/membership-plans/subscribe`
- **Description**: Subscribes or renews a membership package.
- **Request Body**: `{ "planId": "p1" }`
- **Response `200 OK`**: `{ "statusCode": 200, "message": "Subscription activated successfully" }`

---

### 3.4 Attendance & Turnstile Check-Ins
#### `POST /api/attendance/check-in`
- **Description**: Records entry turnstile access verification.
- **Request Body**:
```json
{
  "memberId": "MBR-1001",
  "accessMethod": "Manual Entry"
}
```

---

## 📊 4. Dynamic Data States Implementation (DAY 9)

| State | User Experience | UI Component |
|---|---|---|
| **Loading State** | Glowing pulse spinner with "Loading dynamic records..." caption. Action buttons enter busy state with disabled click events. | `DynamicStateView` (default loading widget) |
| **Success State** | Dynamic list cards rendered with smooth fade-in animations and reactive data binding. | `DynamicStateView.successBuilder` |
| **Empty State** | Illustrated empty card with descriptive text and actionable button (e.g. "Link Bank Account", "Assign Coach"). | `DynamicStateView.emptyBuilder` |
| **Error State** | Warning container displaying HTTP error code, reason, and **Retry Request** button to re-trigger API execution. | `DynamicStateView.errorBuilder` |

---

## 🛡️ 5. Forms, Validation & Error Handling (DAY 10)

### 5.1 Validation Test Suite Matrix
| Field / Test Case | Validation Rule | Error Message Output |
|---|---|---|
| **Required Field** | Non-null, non-empty, trimmed length > 0 | `"<Field Name> is required"` |
| **Email Format** | RFC 5322 regex: `^[a-zA-Z0-9.!#$%&’*+/=?^_...]+@...` | `"Please enter a valid email address (e.g. user@domain.com)"` |
| **Phone Number** | Exactly 10 digits, starts with 6, 7, 8, or 9 (Indian mobile) | `"Phone number must start with 6, 7, 8, or 9 and be exactly 10 digits"` |
| **IFSC Code** | RBI standard: 4 alphabetic chars + '0' + 6 alphanumeric chars | `"Invalid IFSC format (e.g. HDFC0001234)"` |
| **Bank Account** | Numeric only, length between 9 and 18 digits | `"Account number must be between 9 and 18 digits"` |
| **Confirmation Match** | `value.trim() == originalValue.trim()` | `"Account numbers / Passwords do not match"` |
| **PIN Code** | Exactly 6 numeric digits | `"Enter a valid 6-digit PIN code"` |
| **Age Requirement** | Calculated age >= 18 years | `"User must be at least 18 years old"` |
| **Password Strength** | Length >= 8, at least one letter and one number | `"Password must be at least 8 characters long and contain letters & numbers"` |
| **Duplicate Submission** | Debounce guard locking button until request completes | Button displays spinner; subsequent clicks ignored |
| **Network Failure** | HTTP 503 / SocketTimeout / Connection refused | Bottom snackbar with actionable `RETRY` button |
| **API Validation Errors** | Maps server-side `errors` map to banner | Displays field-specific bullets in `ApiValidationBanner` |

---

## 🧪 6. TL Checkpoint & Testing Guide

### How to test:
1. **Testing Dynamic States (Loading, Empty, Error, Success)**:
   - Navigate to **My Profiles > Bank Account**.
   - Observe real-time dynamic loading.
   - Switch between **Transactions** and **Bank Account** tabs to view live dynamic data.
   - Toggle filters (**Today**, **This Week**, **This Month**) to verify dynamic querying.
2. **Testing Simulated Network Error & Retry**:
   - Set `ApiClient.to.simulateNetworkFailure = true;` or disconnect Wi-Fi.
   - Tap "Reload Transactions" or "Refresh Data".
   - The application displays the red **Error State** card with `"Simulated Network Failure: Host unreachable (503)"` and the glowing **Retry Request** button.
   - Reset `simulateNetworkFailure = false` and tap **Retry Request**; the screen recovers and displays data.
3. **Testing Form Validation & Duplicate Submission**:
   - Tap **"Add New"** in Bank Account screen.
   - Try submitting with empty fields -> Inline red validation errors appear.
   - Enter invalid IFSC (e.g. `12345`) -> Inline error: `"Invalid IFSC format (e.g. HDFC0001234)"`.
   - Enter invalid Account Number (< 9 digits) -> Inline error: `"Account number must be between 9 and 18 digits"`.
   - Enter mismatched account confirmation numbers -> Inline error: `"Account numbers do not match"`.
   - Submit valid details: Notice `FormSubmitButton` disables duplicate taps and shows a progress spinner.
   - Once linked, a green success snackbar confirms link completion.
