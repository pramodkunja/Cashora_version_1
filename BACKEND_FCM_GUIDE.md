# Backend — Push Notifications (FCM) Integration Guide

> Hand this to the backend team. The Flutter app is fully wired for FCM
> (Android). Device tokens already arrive at the backend. What's left is
> for the backend to (a) store them and (b) call FCM whenever a relevant
> business event fires.

---

## 1. Endpoints the frontend already calls

The Flutter app posts to these two endpoints. Both **must exist** and
**must return `{"success": true, ...}`** for the registration banner in
the app's console to flip to ✅.

### 1.1 — Register a device token

```
POST /notifications/devices/register
Authorization: Bearer <jwt>
Content-Type: application/json
```

**Request body** (sent verbatim by the frontend):
```json
{
  "token":       "<FCM registration token, ~150-200 chars>",
  "platform":    "android",          // 'android' | 'ios' | 'web'
  "app_version": "1.0.0"             // string from pubspec.yaml
}
```

**Required response** (200):
```json
{
  "success": true,
  "message": "Device token registered successfully."
}
```

**Implementation notes:**
- Store: `(user_id, token, platform, app_version, last_seen_at)` — index on `user_id` AND on `token` (for the unregister path).
- One user can have **multiple tokens** (phone + tablet + reinstall). Don't delete other tokens on insert. UPSERT on `token` — if the token already exists, just update `user_id`, `app_version`, `last_seen_at`.
- The frontend automatically re-registers when Firebase rotates the token (handled by `onTokenRefresh`).
- The Authorization header carries the JWT — use it to identify the user.

### 1.2 — Unregister (called on logout)

```
POST /notifications/devices/unregister
Authorization: Bearer <jwt>
Content-Type: application/json
```

**Body:**
```json
{ "token": "<same FCM token>" }
```

**Required response** (200):
```json
{
  "success": true,
  "message": "Device token unregistered successfully."
}
```

**Implementation:** delete the row where `token = ?` (the JWT ensures only the owning user can do this, but matching by token is fine — tokens are globally unique).

---

## 2. Triggering pushes on business events

Whenever one of these events fires server-side, the backend must:

1. Look up the **recipient user's tokens** from the table populated by §1.1.
2. Build the FCM payload (§3).
3. Call FCM (`firebase_admin.messaging.send_multicast` or equivalent).
4. Clean up stale tokens (§4).

### 2.1 — Events to push

| Event | Trigger | Recipient | `event_type` payload value |
|---|---|---|---|
| Admin approves an expense | Approver hits "Approve" | The requestor who submitted it | `expense_approved` |
| Admin rejects an expense | Approver hits "Reject" | The requestor | `expense_rejected` |
| Admin asks for clarification | Approver hits "Ask Clarification" | The requestor | `clarification_required` |
| Requestor replies to clarification | Requestor submits clarification response | The admin who asked | `clarification_responded` |
| Accountant marks expense paid | Accountant completes payout | The requestor | `expense_paid` |

The frontend handles all five — see `_handleTap` in `lib/core/services/fcm_service.dart`. The `event_type` string in the payload **must** be one of those exact lowercase values.

---

## 3. FCM payload shape (REQUIRED)

The Flutter app expects **both** a top-level `notification` block (for the OS-rendered banner / tray entry) **and** a `data` block (for in-app routing). Send both — sending only one breaks behavior.

```json
{
  "message": {
    "token": "<recipient device token>",

    "notification": {
      "title": "Expense Approved",
      "body":  "Your ₹4,500 expense for Office Supplies was approved."
    },

    "data": {
      "event_type":   "expense_approved",
      "expense_id":   "106",
      "request_id":   "EXP-0E3247D9",
      "status":       "approved"
    },

    "android": {
      "notification": {
        "channel_id": "cashora_push_channel",
        "sound":      "default",
        "click_action": "FLUTTER_NOTIFICATION_CLICK"
      },
      "priority": "high"
    }
  }
}
```

### Field-by-field requirements

| Field | Required | Notes |
|---|---|---|
| `notification.title` | ✅ | Short header shown in the tray |
| `notification.body` | ✅ | Body text — include amount + entity name if available |
| `data.event_type` | ✅ | One of the 5 values from §2.1 (exact lowercase) |
| `data.expense_id` | ✅ | Numeric DB id as a string (e.g. `"106"`) |
| `data.request_id` | ⚠ recommended | String request id (e.g. `"EXP-0E3247D9"`) |
| `data.status` | optional | Same as event_type — convenience for the in-app list |
| `android.notification.channel_id` | ✅ | Must be exactly `"cashora_push_channel"` — the channel is pre-created on the device |
| `android.priority` | ✅ | `"high"` so the notification wakes the device |

**⚠ Important — FCM data limitations:**
- All `data` values must be **strings**. Numbers must be serialized (`"106"`, not `106`).
- The total payload (`notification` + `data`) must be **under 4 KB**.

---

## 4. Handling stale/invalid tokens

FCM returns specific errors for dead tokens. The backend MUST remove these from the database — otherwise every send produces error logs.

When calling `send_multicast`, inspect each response:

```python
# Python firebase_admin example
response = messaging.send_multicast(message)
for idx, resp in enumerate(response.responses):
    if not resp.success:
        code = resp.exception.code
        if code in ("registration-token-not-registered",
                    "invalid-registration-token",
                    "invalid-argument"):
            # Delete this token from the DB
            delete_device_token(tokens[idx])
```

Equivalent codes: `UNREGISTERED`, `INVALID_ARGUMENT`. Anything else (e.g. `INTERNAL`, `UNAVAILABLE`) — retry; don't delete.

---

## 5. Firebase project credentials

The backend needs the **service account JSON** for the Firebase project the mobile app is registered against. Get it once and store it as a secret:

1. [Firebase Console](https://console.firebase.google.com) → ⚙ Project Settings → **Service accounts** tab
2. Click **Generate new private key** → downloads a JSON file
3. Store the JSON as a secret env var (e.g. `FIREBASE_SERVICE_ACCOUNT_JSON`) — never commit it to git

Initialize in your server code (Python example):

```python
import firebase_admin
from firebase_admin import credentials, messaging
import json, os

cred_json = json.loads(os.environ["FIREBASE_SERVICE_ACCOUNT_JSON"])
firebase_admin.initialize_app(credentials.Certificate(cred_json))
```

**Important:** the JSON must come from the **same Firebase project** the mobile app's `google-services.json` is configured against. Project mismatch = silent push failure.

---

## 6. End-to-end test recipe

Use this to verify the backend's FCM call works before wiring the business events:

1. User logs into the Android app → backend receives `POST /notifications/devices/register`.
2. Query the device_tokens table — confirm the row exists.
3. From a backend shell / test script, call FCM directly with that token using the payload from §3.
4. Phone should buzz within ~3 seconds with the title/body you sent.
5. Tap the notification → the app should open to the expense detail screen for the `expense_id` you passed.

If step 4 works → wire it into your business event handlers. If step 4 fails → the issue is the FCM call itself; check the service account, project id, payload shape.

---

## 7. Quick checklist (paste into the ticket)

- [ ] `POST /notifications/devices/register` exists, accepts `{token, platform, app_version}`, returns `{"success": true}`.
- [ ] `POST /notifications/devices/unregister` exists, accepts `{token}`, returns `{"success": true}`.
- [ ] Device tokens table stores `(user_id, token, platform, app_version, last_seen_at)`, with one row per (user_id, token) pair (UPSERT on token).
- [ ] Firebase service account JSON loaded from env, `firebase_admin` initialized once at startup.
- [ ] Each of the 5 business events (§2.1) triggers `messaging.send_multicast` to all of the recipient user's tokens.
- [ ] Payload includes BOTH `notification` AND `data` blocks (§3).
- [ ] `data.event_type` is one of the 5 exact lowercase values; `data.expense_id` is a string.
- [ ] `android.notification.channel_id = "cashora_push_channel"`.
- [ ] Stale-token codes (`UNREGISTERED`, `INVALID_ARGUMENT`, `registration-token-not-registered`) delete the offending row from the DB.

---

**Once these eight items are checked off, push notifications will be live end-to-end.**
