# 🔐 Local Authentication Implementation Plan with Hive

## ✅ IMPLEMENTATION COMPLETED - CLEAN ARCHITECTURE

---

## 📁 Final Clean Architecture Structure

```
lib/
├── core/
│   └── constants/
│       └── hive_constants.dart
├── features/
│   ├── auth/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── user_entity.dart
│   │   │   │   └── entities.dart
│   │   │   ├── repositories/
│   │   │   │   ├── auth_repository.dart
│   │   │   │   └── repositories.dart
│   │   │   └── datasources/
│   │   │       ├── auth_local_datasource.dart
│   │   │       └── datasources.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── user_model.dart
│   │   │   │   ├── user_model.g.dart
│   │   │   │   └── models.dart
│   │   │   ├── datasources/
│   │   │   │   ├── auth_local_datasource_impl.dart
│   │   │   │   └── datasources.dart
│   │   │   └── repositories/
│   │   │       ├── auth_repository_impl.dart
│   │   │       └── repositories.dart
│   │   ├── presentation/
│   │   │   ├── state/
│   │   │   │   ├── auth_state.dart
│   │   │   │   └── state.dart
│   │   │   ├── view_model/
│   │   │   │   ├── auth_view_model.dart
│   │   │   │   └── view_model.dart
│   │   │   ├── providers/
│   │   │   │   ├── auth_provider.dart
│   │   │   │   └── providers.dart
│   │   │   ├── pages/
│   │   │   │   ├── login_screen.dart
│   │   │   │   ├── register_screen.dart
│   │   │   │   └── pages.dart
│   │   │   └── widgets/
│   │   │       └── widgets.dart
│   │   └── auth.dart
│   ├── home/
│   │   ├── presentation/
│   │   │   └── pages/
│   │   │       ├── home_screen.dart
│   │   │       └── pages.dart
│   │   └── home.dart
│   ├── onboarding/
│   │   ├── presentation/
│   │   │   └── pages/
│   │   │       ├── onboarding_screen.dart
│   │   │       └── pages.dart
│   │   └── onboarding.dart
│   ├── splash/
│   │   ├── presentation/
│   │   │   └── pages/
│   │   │       ├── splash_screen.dart
│   │   │       └── pages.dart
│   │   └── splash.dart
│   └── features.dart
├── widgets/
│   └── (shared widgets)
├── app.dart
└── main.dart
```

---

## ✅ TODO List

### Phase 1: Setup Dependencies
- [x] **TODO 1**: Add `hive`, `hive_flutter`, and `crypto` packages to `pubspec.yaml`
- [x] **TODO 2**: Run `flutter pub get`

### Phase 2: Create Core Constants
- [x] **TODO 3**: Create `lib/core/constants/hive_constants.dart` with box names and keys

### Phase 3: Create Data Models
- [x] **TODO 4**: Create `lib/data/models/user_model.dart` with Hive TypeAdapter

### Phase 4: Create Services
- [x] **TODO 5**: Create `lib/data/services/hive_service.dart` for Hive initialization
- [x] **TODO 6**: Create `lib/data/services/auth_service.dart` for authentication logic

### Phase 5: Modify Entry Points (Minimal Changes)
- [x] **TODO 7**: Update `lib/main.dart` to initialize Hive before running app
- [x] **TODO 8**: Update `lib/screens/splash_screen.dart` to check login status and redirect

### Phase 6: Update Existing Screens (Minimal Changes)
- [x] **TODO 9**: Update `lib/screens/login_screen.dart` to use AuthService
- [x] **TODO 10**: Update `lib/screens/register_screen.dart` to use AuthService
- [x] **TODO 11**: Add logout functionality to home screen (if applicable)

---

## 📦 Dependencies to Add

```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  crypto: ^3.0.3
```

---

## 🗄️ UserModel Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | `String` | Unique identifier (UUID) |
| `name` | `String` | User's full name |
| `email` | `String` | User's email (unique) |
| `passwordHash` | `String` | SHA-256 hashed password |

---

## 🔧 Hive Configuration

- **User Box**: Stores all registered users
- **Session Box**: Stores current logged-in user session

### Box Names
- `users` - For storing user data
- `session` - For storing current session

### Keys
- `currentUserId` - Key for storing logged-in user's ID in session box

---

## 🔒 Security Implementation

### Password Hashing
- Use SHA-256 from `crypto` package
- Never store plain text passwords
- Hash password during signup
- Compare hashed passwords during login

---

## 🔄 Authentication Flow

### Signup Flow
1. Validate form inputs
2. Check if email already exists
3. Hash the password
4. Create UserModel with unique ID
5. Store user in Hive users box
6. Auto-login after successful signup
7. Navigate to Home Screen

### Login Flow
1. Validate form inputs
2. Find user by email in Hive
3. Compare hashed passwords
4. Store user ID in session box
5. Navigate to Home Screen

### Session Check Flow (Splash Screen)
1. Initialize Hive
2. Check if `currentUserId` exists in session box
3. If exists → Navigate to Home Screen
4. If not → Navigate to Onboarding/Login Screen

### Logout Flow
1. Clear `currentUserId` from session box
2. Navigate to Login Screen

---

## 📝 Implementation Notes

1. **Minimal Changes**: Only modify existing files where absolutely necessary
2. **New Files**: Create all new functionality in new files
3. **No Breaking Changes**: Ensure existing UI and navigation remain functional
4. **Error Handling**: Add proper error handling and user feedback

---

## 🚀 Implementation Order

1. Add dependencies → Run pub get
2. Create constants file
3. Create UserModel with adapter
4. Create HiveService
5. Create AuthService
6. Update main.dart (add Hive init)
7. Update splash_screen.dart (add session check)
8. Update login_screen.dart (integrate AuthService)
9. Update register_screen.dart (integrate AuthService)
10. Test all flows

---

## ✅ Completion Checklist

After implementation, verify:
- [x] User can sign up with name, email, password
- [x] Duplicate emails are rejected
- [x] User can log in with correct credentials
- [x] Invalid credentials show error
- [x] User stays logged in after app restart
- [x] User can log out
- [x] Passwords are stored as hashes (not plain text)

---

## 📂 Files Created/Modified

### New Files Created:
| File Path | Description |
|-----------|-------------|
| `lib/core/constants/hive_constants.dart` | Hive box names and keys |
| `lib/data/models/user_model.dart` | UserModel with Hive annotations |
| `lib/data/models/user_model.g.dart` | Generated Hive TypeAdapter |
| `lib/data/services/hive_service.dart` | Hive initialization service |
| `lib/data/services/auth_service.dart` | Authentication logic |

### Modified Files:
| File Path | Changes |
|-----------|---------|
| `pubspec.yaml` | Added hive, hive_flutter, crypto dependencies |
| `lib/main.dart` | Added Hive initialization |
| `lib/screens/splash_screen.dart` | Added login check and redirect |
| `lib/screens/login_screen.dart` | Integrated AuthService |
| `lib/screens/register_screen.dart` | Integrated AuthService |
| `lib/widgets/home_app_bar.dart` | Added logout button |
