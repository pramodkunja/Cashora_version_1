# Categories API — Backend Integration Spec

**For:** Backend team
**From:** Flutter team
**Goal:** Let an **Admin** create / edit / deactivate expense **categories**, and have those
categories **immediately appear for Requestors** when they create a new request.

This document describes exactly what the Flutter app calls, the request/response
shapes it expects, and the **one rule that makes the whole thing work**.

---

## 0. TL;DR — the single most important requirement

> **The admin `/categories` endpoints and the requestor `GET /requestor/categories`
> endpoint MUST read/write the same underlying `categories` table (scoped per
> organization).**

When an admin creates "Client Gifts", the requestor's category picker must show
"Client Gifts" on its next load — because both endpoints hit the same table.

```
 ┌─────────────┐    POST /categories          ┌──────────────────┐
 │   ADMIN     │ ───────────────────────────► │                  │
 │  (app)      │    PATCH /categories/{id}     │   categories     │
 │             │    DELETE /categories/{id}    │   table          │
 └─────────────┘                               │  (per-org)       │
                                               │                  │
 ┌─────────────┐    GET /requestor/categories  │                  │
 │ REQUESTOR   │ ◄─────────────────────────── │                  │
 │  (app)      │   returns ACTIVE categories   └──────────────────┘
 └─────────────┘
```

If they read from different sources, the admin screen and the requestor screen
will disagree, and this feature is broken.

---

## 1. Base URL & Auth

- **Base URL:** the same host the app already uses (configured in
  `lib/core/config/app_config.dart`). Prod = `https://cashora.nxsys.in`.
- **All paths below are relative to that base URL**, exactly like the existing
  endpoints. The category endpoints must live at the **same prefix as the
  already-working `/departments` endpoints** — the app calls them identically.
- **Auth:** every request sends `Authorization: Bearer <jwt>`.
  - `/categories` mutations (POST/PATCH/DELETE/seed) → **admin / super_admin only** (403 otherwise).
  - `GET /requestor/categories` → any authenticated user (used by requestors).
- **Scope:** everything is **per-organization** (derive org from the JWT, same as
  `/departments`).

> This spec mirrors your existing `/departments` API 1:1. If departments already
> works, copying it for categories is the fastest path — same auth, same
> multi-tenancy, same soft-delete, same response shapes.

---

## 2. Admin endpoints (NEW — please implement)

These power the new **Admin → Profile → Manage Categories** screen.
Flutter source: `lib/data/repositories/category_repository.dart`.

| # | Method & Path | Purpose | Auth |
|---|---|---|---|
| 1 | `GET /categories` | List categories | Admin |
| 2 | `POST /categories` | Create a category | Admin |
| 3 | `PATCH /categories/{id}` | Update name/code, or reactivate | Admin |
| 4 | `DELETE /categories/{id}` | Soft-delete (deactivate) | Admin |
| 5 | `POST /categories/seed-defaults` | Create a default starter set | Admin |
| 6 | `GET /categories/{id}` | (optional) Fetch one | Admin |

### 2.1 `GET /categories`

Lists the org's categories. By default returns **only active** ones.

**Query params**
- `include_inactive` (bool, optional) — when `true`, also return deactivated categories.

**Request**
```
GET /categories
GET /categories?include_inactive=true
Authorization: Bearer <jwt>
```

**Response 200** — JSON **array of objects**:
```json
[
  {
    "id": 1,
    "name": "Travel",
    "code": "TRV",
    "slug": "travel",
    "is_active": true
  },
  {
    "id": 2,
    "name": "Office Supplies",
    "code": null,
    "slug": "office_supplies",
    "is_active": true
  }
]
```

Field notes (what the app reads):
- `id` (int) — used for PATCH/DELETE. **Required.**
- `name` (string) — display name shown in the card. **Required.**
- `code` (string|null) — optional short code, shown as a chip.
- `is_active` (bool) — drives the "INACTIVE" badge + deactivate/reactivate menu.
- `slug` (string) — **the machine value** (see §4). Strongly recommended.

> The app is tolerant: if you ever return a bare array of strings instead of
> objects, it still renders (treats each string as `name`, `is_active=true`).
> But for the admin screen to support edit/deactivate, **return objects with `id`**.

### 2.2 `POST /categories`

**Request body**
```json
{ "name": "Client Gifts", "code": "GIFT" }
```
- `name` (string) — **required.**
- `code` (string|null) — optional.

**Response 200/201** — the created category object (same shape as §2.1 items).

**Behavior:** derive and persist a `slug` from `name` (see §4). Reject duplicates
(same name/slug already exists in the org) with **400**.

### 2.3 `PATCH /categories/{id}`

Used for **edit** and for **reactivate**. The app sends only the changed fields.

**Edit body**
```json
{ "name": "Client Gifts", "code": "GIFT" }
```

**Reactivate body** (sent by the "Reactivate" menu action)
```json
{ "is_active": true }
```

- `name` (string, optional)
- `code` (string|null, optional)
- `is_active` (bool, optional)

**Response 200** — the updated category object.

### 2.4 `DELETE /categories/{id}`

**Soft delete** (deactivate) — do **not** hard-delete. Set `is_active=false` so it
disappears from requestors but can be reactivated later and historical requests
keep their category.

**Response:** 200/204 (no body required).

### 2.5 `POST /categories/seed-defaults`

Creates a sensible default set for a fresh org (idempotent — skip ones that exist).
Suggested defaults (slugs the app already has icons for): `travel`, `meals`,
`software`, `office_supplies`, `transport`, `accommodation`, `entertainment`,
`others`.

**Response 200** — summary the app shows in a snackbar:
```json
{
  "created": ["travel", "meals", "software"],
  "skipped": ["office_supplies"],
  "message": "Seeded defaults"
}
```
(`created` / `skipped` are arrays of names or slugs; `message` is a fallback string.)

---

## 3. Requestor endpoint (EXISTING — must reflect admin categories)

Flutter source: `lib/data/repositories/request_repository.dart` → `getCategories()`,
consumed in `lib/modules/requestor/controllers/create_request_controller.dart`.

### 3.1 `GET /requestor/categories`

**Request**
```
GET /requestor/categories
Authorization: Bearer <jwt>
```

**Response 200 — current contract the app expects: a JSON array of slug STRINGS:**
```json
["travel", "office_supplies", "client_gifts"]
```

How the app uses each string (e.g. `office_supplies`):
1. Splits on `_` and title-cases → displays **"Office Supplies"** in the picker.
2. Keeps the raw string as the category **id** to send back on submit.

**✅ The requirement:** this array must contain the **slugs of all ACTIVE categories
for the org** — including ones the admin just created. So after the admin creates
"Client Gifts" (slug `client_gifts`), this endpoint must include `client_gifts`.

- Return **active only** (deactivated categories must NOT appear here).
- Return **lowercase `snake_case` slugs** so the app's title-casing produces a nice
  label and the icon map matches (see §4).

> **Do not change this to return objects without telling us** — the current Flutter
> code does `List<String>.from(response.data)` and will break on a list of objects.
> If you'd prefer to return rich objects (`[{ "slug": "...", "name": "..." }]`),
> that's fine and arguably cleaner — just tell us and we'll update the one parsing
> line. Until then, **keep returning a string array.**

---

## 4. Slug ↔ name (the field that ties admin and requestor together)

The admin types a **display name** ("Client Gifts"). The requestor flow works in
**slugs** ("client_gifts"). The backend is responsible for the mapping:

- On **create**, derive `slug = lower(name).trim()` with spaces/`&` → `_`
  (e.g. `"Client Gifts"` → `client_gifts`, `"Food & Beverage"` → `food_beverage`).
- Store both `name` (display) and `slug` (machine), `slug` unique per org.
- `GET /categories` returns both `name` and `slug`.
- `GET /requestor/categories` returns the **`slug`** values of active categories.
- On request submit (see §5) the app sends that **`slug`** back as `category`.

This is exactly the transform the app already applies as a fallback
(`create_request_controller.dart`):
```dart
name.toLowerCase().replaceAll(' & ', '_').replaceAll(' ', '_')
```
Matching it on the backend keeps everything consistent.

Icons: the requestor picker has built-in icons for these slugs — `travel`, `meals`,
`software`, `office_supplies`, `others`, `transport`, `accommodation`,
`entertainment`. Any other slug gets a generic icon (still works fine).

---

## 5. How the submitted request stores the category (FYI)

When a requestor submits, the app sends `multipart/form-data` to
`POST /requestor/submit` with a field:

```
category = "<slug>"     // e.g. "client_gifts"
```

So the submit endpoint must **accept any slug that is an active category** for the
org. If you validate the `category` field, validate it against the same active
categories table — otherwise newly created admin categories would be rejected on
submit even though they show in the picker.

---

## 6. Error responses (match departments)

The app surfaces `detail` or `message` from the body, with these fallbacks:

| Status | Meaning shown to user |
|---|---|
| 400 | "Category name or code already exists." (duplicate) |
| 401 | "Session expired. Please log in again." |
| 403 | "Admin access required." |
| 404 | "Category not found." |

Preferred error body:
```json
{ "detail": "A category with this name already exists." }
```

---

## 7. Acceptance checklist

- [ ] `GET /categories` returns the org's active categories as objects with `id`,
      `name`, `code`, `slug`, `is_active`.
- [ ] `GET /categories?include_inactive=true` also returns deactivated ones.
- [ ] `POST /categories` creates one, derives a unique `slug`, returns the object.
- [ ] `PATCH /categories/{id}` updates name/code and supports `{ "is_active": true }`.
- [ ] `DELETE /categories/{id}` **soft-deletes** (sets `is_active=false`).
- [ ] `POST /categories/seed-defaults` seeds defaults idempotently.
- [ ] **`GET /requestor/categories` returns the slugs of the SAME active categories**
      (string array), so a category the admin creates appears in the requestor
      picker on next load.
- [ ] `POST /requestor/submit` accepts any active category slug in its `category` field.
- [ ] All endpoints are org-scoped and enforce admin auth on mutations.

---

## 8. Quick end-to-end test

1. **Admin** → Profile → Manage Categories → **+ Add Category** → name "Client Gifts" → Create.
   - Expect `POST /categories` → 200, card appears in the list.
2. **Requestor** → New Request → open the **Category** picker (triggers `GET /requestor/categories`).
   - Expect "Client Gifts" to appear in the list.
3. Submit a request with category "Client Gifts".
   - Expect `POST /requestor/submit` with `category=client_gifts` → 200.
4. **Admin** → deactivate "Client Gifts".
   - Expect it to disappear from the requestor picker on next load, while past
     requests keep showing it.

---

### Flutter reference files (for cross-checking shapes)
- `lib/data/repositories/category_repository.dart` — admin `/categories` calls
- `lib/modules/admin/controllers/category_controller.dart` — admin screen logic
- `lib/data/repositories/request_repository.dart` (`getCategories`) — `/requestor/categories`
- `lib/modules/requestor/controllers/create_request_controller.dart` — picker + submit
- `lib/data/repositories/department_repository.dart` — the existing pattern this mirrors
