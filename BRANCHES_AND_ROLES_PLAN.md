# Multi-Branch + Admin/Super-Admin — Implementation Plan

**Status:** Plan approved, not yet built.
**Scope:** Add multi-branch support with branch-by-branch management, multiple
admins appointed by an owner (super_admin), and a single-org owner role.

This is the engineering blueprint. The backend contract lives in a separate
file: **`BACKEND_BRANCHES_API.md`**.

---

## 1. Decisions (locked)

| Decision | Choice |
|---|---|
| Branch ↔ data | **Branches own users.** Departments & categories stay org-wide. |
| Admins | **Multiple admins.** Only a super_admin can appoint/revoke admins & super_admins. Admins can only set accountant/requestor. |
| Super admin | **Org owner** — extra powers (manage admins + branches), but scoped to a single organization (not platform-wide). |
| Owner aggregate view | **Yes** — super_admin gets an "All Branches" view plus any single branch. |
| Branch switcher | **Global** — a branch pill in the header of every admin screen. |

---

## 2. Where the app stands today (grounding)

- Roles already exist: `admin`, `super_admin`, `accountant`, `requestor`
  (`lib/core/constants/user_roles.dart`). **`super_admin` is currently just an
  alias of `admin`** — every guard treats them identically
  (`lib/routes/route_guards.dart:47`, `lib/modules/profile/views/profile_view.dart:71`,
  `lib/modules/splash/controllers/splash_controller.dart`, `lib/core/services/fcm_service.dart`).
- Org creator becomes `admin` via `POST /auth/setup-organization`
  (`lib/data/repositories/organization_repository.dart:26`).
- Role changes are **already supported by the backend**: `PATCH /users/update/{id}`
  accepts a `role` field (`lib/data/models/user_update_request.dart:29`). The UI
  just doesn't expose it well, and uses the wrong casing (`'Admin'` vs `'admin'`).
- **No branch concept exists** — only `department` (on `User` + `/departments` CRUD).
- Proven pattern for org-scoped admin entities: **departments** (and **categories**)
  = `repository` + `controller` + `list view` + route + DI + a profile row.

---

## 3. Final role model

| Role | Can appoint | Manages |
|---|---|---|
| **super_admin** (owner) | admin, super_admin, accountant, requestor | **admins, branches** + everything admin does |
| **admin** | accountant, requestor | users, departments, categories, approvals, limits (within active/own branch) |
| **accountant** | — | payments |
| **requestor** | — | own requests |

- **Org creator becomes `super_admin`** (backend change). Safe because guards
  already treat `admin`/`super_admin` the same.
- Shared admin access stays `['admin','super_admin']`.
- **New owner-only powers** check `role == super_admin` specifically.

---

## 4. Data model changes

### 4.1 `User` (`lib/data/models/user_model.dart`)
Add, mirroring the existing `departmentId`/`departmentName`:
```dart
final int? branchId;
final String branchName;
final String branchCode; // optional
```
Parse from `/users/me` (`branch_id`, `branch_name`, `branch_code`). Keep nullable
— existing users have no branch during rollout.

### 4.2 New `Branch` entity
```
Branch { id:int, name:String, code:String?, address:String?, is_active:bool }
```
Structurally identical to a department.

---

## 5. The "active branch" context (branch-by-branch management)

### 5.1 `BranchScopeService` (new `GetxService`)
Like `AuthService` — a persisted, app-wide singleton.
```
activeBranch : Rxn<Map>      // null  = "All Branches" (owner only)
branches     : RxList<Map>   // cached branch list
setActiveBranch(branch)      // updates + persists to StorageService('active_branch_id')
loadBranches()               // fetch + restore saved selection on login
```
Rules:
- **super_admin** → may select **All Branches** (`null`) or any branch.
- **branch-admin** (an admin with a `branch_id`) → forced to their own branch;
  switcher hidden.
- Cleared on logout (alongside auth state).

### 5.2 Global header switcher (widget)
A branch pill shown in the header of every admin screen
(dashboard, approvals, users, history, reports):
```
 ┌─────────────────────────────────────────┐
 │  ☰   ▾ Downtown Branch          🔔  ⚙   │
 ├─────────────────────────────────────────┤
 │  [ All Branches            ]   (owner)   │
 │  [ Downtown Branch   ✓     ]             │
 │  [ Airport Branch          ]             │
 │  [ Warehouse Branch        ]             │
 └─────────────────────────────────────────┘
```
Tapping opens a bottom sheet → pick a branch → `BranchScopeService` updates → the
visible admin controllers refetch for that branch.

### 5.3 Wiring existing admin screens
Each admin controller (dashboard, approvals, user list, history, reports):
- reads `BranchScopeService.activeBranch` and passes `branch_id` to its repo calls;
- reacts to changes (`ever(...)`) to refetch when the branch switches.
No screen rewrites — just an extra query param on calls they already make.

---

## 6. Moving people between branches (easy shift)

- **User list quick action** → "Move to branch" → bottom sheet of branches →
  `PATCH /users/update/{id}` with `{ branch_id }`. Instant.
- **Edit-user form** → a branch picker beside the existing department picker.
- **Shifting an admin** = the same action (change a branch-admin's `branch_id`).
  Only super_admin can do it.

---

## 7. Assign / change admins + super_admin (UI)

- Add **Admin** and (super-admin-only) **Super Admin** to the role dropdowns in
  add-user (`lib/modules/admin/views/user_management/widgets/admin_add_user_form.dart:215`)
  and edit-user (`...admin_edit_user_form.dart:216`).
- **Normalize casing** to backend values (`'Admin'` → `'admin'`, etc.) — this is a
  latent bug today.
- **Gate by current role**: super_admin sees Admin/Super Admin options; a plain
  admin only sees Requestor/Accountant. Backend must enforce the same.
- Add a tiny role helper (e.g. on `AuthService` or a `RoleService`):
  `isSuperAdmin`, `isAdmin`, `canAssignRole(targetRole)`.
- **Owner section** in the admin profile (super_admin only): "Manage Branches",
  admin appointments. Visible via `role == super_admin`.

---

## 8. Frontend file map (new vs. changed)

**New (mirror departments/categories):**
- `lib/data/repositories/branch_repository.dart`
- `lib/modules/admin/controllers/branch_controller.dart`
- `lib/modules/admin/views/branch_list_view.dart` (+ `views/widgets/branch_*`)
- `lib/core/services/branch_scope_service.dart`
- `lib/modules/admin/views/widgets/branch_switcher.dart`
- `lib/core/services/role_service.dart` (or extend `AuthService`)

**Changed:**
- `lib/routes/app_routes.dart` — add `ADMIN_BRANCHES`.
- `lib/routes/app_pages.dart` — register `BranchListView` + binding.
- `lib/main.dart` — DI for `BranchRepository` + `BranchScopeService`.
- `lib/data/models/user_model.dart` — branch fields.
- `lib/data/models/user_update_request.dart` — add `branchId`.
- `lib/data/repositories/auth_repository.dart` — `addStaff` sends `branch_id`.
- `lib/modules/admin/controllers/admin_user_controller.dart` — `selectedBranchId`.
- add/edit-user forms — branch picker; role options gated + casing fixed.
- Admin profile (`profile_view.dart`) — owner section.
- Admin screen headers — embed `BranchSwitcher`; admin controllers add `branch_id`.

---

## 9. Build order

1. **`BACKEND_BRANCHES_API.md`** → hand to backend.
2. **Phase 1** — Branches CRUD module + assign branch to users + `User` branch fields.
3. **Phase 2** — `BranchScopeService` + global header switcher + `branch_id`
   filtering across admin screens + "Move to branch".
4. **Backend lands** — org-creator→super_admin + role authorization + `branch_id` filters.
5. **Role assignment UI** — Admin/Super Admin options, gating, casing fix, owner section.

---

## 10. Gotchas / guardrails

- **Casing mismatch** (`'Admin'` vs `'admin'`) must be fixed or role PATCH silently fails.
- **`branch_id` nullable** during rollout; treat "no branch" gracefully (shows under
  All Branches; pickers allow "Unassigned").
- **Last-super_admin guard** server-side — an org must never be left ownerless.
- `super_admin` keeps shared admin access (`['admin','super_admin']`); only the new
  powers check `super_admin` exclusively.
- **Server-side branch enforcement** — a branch-admin's data must be forced to their
  branch on the backend; never rely on the client filter alone.
- Phase 1 deliberately does **not** scope dashboards/approvals by branch — that's
  Phase 2, and it's the larger effort.

---

### Reference files (existing patterns to copy)
- `lib/data/repositories/department_repository.dart` — branch repo blueprint
- `lib/modules/admin/controllers/department_controller.dart` — branch controller blueprint
- `lib/modules/admin/views/category_list_view.dart` — list view blueprint
- `lib/core/services/auth_service.dart` — persisted GetxService blueprint
- `lib/routes/route_guards.dart` — where role/branch enforcement plugs in
