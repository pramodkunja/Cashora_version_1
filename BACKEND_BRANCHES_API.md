# Branches + Roles API — Backend Integration Spec

**For:** Backend team
**From:** Flutter team
**Goal:** Add **multi-branch** support to an organization, let an **owner
(super_admin)** appoint **multiple admins**, assign users to branches, and let
admins manage the app **branch by branch**.

This spec mirrors the existing `/departments` API wherever possible — if
departments works, branches is a near-copy.

---

## 0. TL;DR — the rules that make this work

1. **A branch is an org-scoped entity** (like a department). One org → many branches.
2. **Every user belongs to at most one branch** (`branch_id`, nullable).
3. **The org creator becomes `super_admin`** (the owner), not `admin`.
4. **Only `super_admin` may grant/revoke `admin` and `super_admin`.** An `admin`
   may only set `accountant`/`requestor`.
5. **Never leave an org without a super_admin** (block demoting the last one).
6. **Admin list endpoints accept an optional `branch_id` filter.** Omitted by the
   owner = all branches. For a branch-scoped admin, **force their own branch
   server-side** — never trust the client.

---

## 1. Base URL & Auth

- **Base URL:** same host the app already uses (prod `https://cashora.nxsys.in`).
  All paths below are **relative**, at the **same prefix as `/departments`**.
- **Auth:** `Authorization: Bearer <jwt>` on every request.
- **Scope:** everything is per-organization (derive org from the JWT).
- **Roles:** `super_admin`, `admin`, `accountant`, `requestor` (all **lowercase**).

---

## 2. Branches CRUD (NEW — mirror `/departments`)

Flutter will call these from a new `BranchRepository`.

| # | Method & Path | Purpose | Auth |
|---|---|---|---|
| 1 | `GET /branches` (`?include_inactive=true`) | List branches | Admin+ |
| 2 | `POST /branches` | Create a branch | Owner / Admin* |
| 3 | `PATCH /branches/{id}` | Update / reactivate | Owner / Admin* |
| 4 | `DELETE /branches/{id}` | Soft-delete (deactivate) | Owner / Admin* |
| 5 | `POST /branches/seed-defaults` | (optional) starter set | Owner / Admin* |

\* Recommended: **only super_admin manages branches** (they're an owner concern).
If you allow admins too, scope it to their own branch.

### 2.1 `GET /branches`
Active only by default; `?include_inactive=true` includes deactivated.

**Response 200** — array of objects:
```json
[
  { "id": 1, "name": "Downtown Branch", "code": "DTN", "address": "12 Main St", "is_active": true },
  { "id": 2, "name": "Airport Branch",  "code": "AIR", "address": null,         "is_active": true }
]
```
Fields the app reads: `id` (int, required), `name` (string, required),
`code` (string|null), `address` (string|null), `is_active` (bool).

### 2.2 `POST /branches`
```json
{ "name": "Warehouse Branch", "code": "WH", "address": "Plot 9, Industrial Area" }
```
- `name` required; `code`, `address` optional.
- Reject duplicate name/code in the org with **400**.
- **Response:** the created branch object.

### 2.3 `PATCH /branches/{id}`
Edit fields, or reactivate. App sends only changed fields.
```json
{ "name": "Warehouse Branch", "code": "WH" }      // edit
{ "is_active": true }                              // reactivate
```
**Response 200:** updated branch object.

### 2.4 `DELETE /branches/{id}`
**Soft delete** — set `is_active=false`. Do not hard-delete (users & historical
requests reference it). Decide and document what happens to users still assigned
to a deactivated branch (recommended: keep `branch_id`, treat as "Unassigned" in
active lists).
**Response:** 200/204.

### 2.5 `POST /branches/seed-defaults` (optional)
Idempotent default set. Response like departments:
```json
{ "created": ["Head Office"], "skipped": [], "message": "Seeded defaults" }
```

---

## 3. Users gain a `branch_id`

### 3.1 `POST /auth/add-staff` — accept `branch_id`
The admin "Add User" form already sends `department_id`; it will also send
`branch_id`.
```json
{
  "first_name": "Asha",
  "last_name": "Rao",
  "email": "asha@acme.com",
  "phone_number": "98765...",
  "role": "requestor",
  "department_id": 4,
  "branch_id": 2
}
```
`branch_id` optional/nullable.

### 3.2 `PATCH /users/update/{id}` — accept `branch_id`
Already accepts `role`, `is_active`, `department_id`. Add `branch_id`.
- **"Move user to another branch"** = `{ "branch_id": 3 }`.
- **Promote to admin** = `{ "role": "admin" }` (see §4 for authorization).

### 3.3 `GET /users/me` — return branch fields
Add to the profile payload (flat, like department fields):
```json
{
  "id": 12, "email": "...", "role": "admin",
  "department_id": 4, "department_name": "Finance", "department_code": "FIN",
  "branch_id": 2, "branch_name": "Airport Branch", "branch_code": "AIR"
}
```

### 3.4 User list — include branch + accept `?branch_id`
The admin user list should return each user's `branch_id`/`branch_name`, and accept
`?branch_id=<id>` to filter (see §6).

---

## 4. Roles: owner appoints admins (authorization)

### 4.1 Org creation → owner
`POST /auth/setup-organization` currently makes the creator `admin`. **Change the
creator's role to `super_admin`.** (Existing role checks already treat the two the
same for access, so this is safe.)

### 4.2 Role-change rules (enforce server-side on `PATCH /users/update/{id}`)
| Actor role | May set target role to |
|---|---|
| **super_admin** | super_admin, admin, accountant, requestor |
| **admin** | accountant, requestor **only** |
| accountant / requestor | (cannot change roles) |

- Reject disallowed transitions with **403**.
- **Block demoting / deactivating the last `super_admin`** in an org (**409/400**
  with a clear message) so ownership can't be lost.
- All role values are **lowercase** (`super_admin`, `admin`, …). The app sends
  lowercase; please reject/normalize anything else.

### 4.3 (Optional) atomic ownership transfer
If you want a clean "transfer ownership", expose:
`POST /admin/transfer-ownership { "to_user_id": 12 }` → promotes target to
`super_admin` (and optionally demotes the caller to `admin`) in one transaction.
Without it, the app will just `PATCH` the target's role to `super_admin`.

---

## 5. Branch-scoped admins

- An `admin` **with a `branch_id`** is a "branch admin": they manage only their
  branch. An `admin` **without** a `branch_id` (or a `super_admin`) manages the
  whole org.
- Enforce this on the backend: for a branch admin, all admin reads/writes are
  constrained to their `branch_id`, regardless of any client-supplied filter.

---

## 6. Branch filtering on admin endpoints

These list/summary endpoints must accept an **optional `branch_id` query param**:

| Endpoint (existing) | With filter |
|---|---|
| Admin dashboard | `?branch_id=<id>` |
| Approvals / pending list | `?branch_id=<id>` |
| Admin user list | `?branch_id=<id>` |
| Admin history | `?branch_id=<id>` |
| Reports / analytics | `?branch_id=<id>` |

Semantics:
- **Owner (super_admin), no `branch_id`** → whole org ("All Branches" view).
- **`branch_id` present** → only that branch's data.
- **Branch admin** → always forced to their own `branch_id` (ignore/deny others).

> The Flutter app sends `branch_id` based on the header branch switcher; the owner
> can pick "All Branches" (sends no `branch_id`).

---

## 7. Error responses (match departments)

App surfaces `detail` / `message`, with fallbacks:

| Status | Meaning |
|---|---|
| 400 | "Branch name or code already exists." / bad input |
| 401 | "Session expired. Please log in again." |
| 403 | "Admin access required." / role change not allowed |
| 404 | "Branch not found." |
| 409 | "Cannot remove the last owner." (last-super_admin guard) |

Preferred body: `{ "detail": "A branch with this name already exists." }`

---

## 8. Acceptance checklist

- [ ] `GET /branches` (+`include_inactive`) returns org branches as objects with `id`.
- [ ] `POST /branches` creates; duplicates → 400.
- [ ] `PATCH /branches/{id}` edits + supports `{ "is_active": true }`.
- [ ] `DELETE /branches/{id}` **soft-deletes**.
- [ ] `POST /auth/add-staff` and `PATCH /users/update/{id}` accept `branch_id`.
- [ ] `GET /users/me` and the admin user list return `branch_id`/`branch_name`.
- [ ] `POST /auth/setup-organization` makes the creator **`super_admin`**.
- [ ] Role changes enforced: only super_admin grants admin/super_admin; admin limited
      to accountant/requestor; **last super_admin protected**.
- [ ] Admin dashboard/approvals/users/history/reports accept `?branch_id`, and
      branch admins are **forced** to their own branch server-side.

---

## 9. Quick end-to-end test

1. **Setup org** → creator logs in → role is `super_admin`. ✅
2. **Create branches** "Downtown", "Airport". ✅
3. **Add user** Asha as `requestor` in "Airport". ✅
4. **Promote** Bob to `admin` (as super_admin) and assign branch "Downtown". ✅
5. As **owner**, header switcher shows "All Branches" + both branches; pick
   "Airport" → dashboard/users/approvals show only Airport data. ✅
6. As **Bob (branch admin)**, no switcher; he sees only Downtown data even if he
   tries to request another branch's data. ✅
7. **Move** Asha from Airport → Downtown via "Move to branch"
   (`PATCH /users/update/{id}` `{branch_id}`). ✅
8. Try to demote the **only** super_admin → blocked with 409. ✅

---

### Flutter reference files (for cross-checking shapes)
- `lib/data/repositories/department_repository.dart` — the pattern branches mirror
- `lib/data/repositories/auth_repository.dart` (`addStaff`) — user creation
- `lib/data/models/user_update_request.dart` — PATCH payload (will gain `branch_id`)
- `lib/data/models/user_model.dart` — `/users/me` shape (will gain branch fields)
- `lib/data/repositories/organization_repository.dart` — `setup-organization`
