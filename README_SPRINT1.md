# Xpress Nepal - Sprint 1 Documentation

## Project Overview
Xpress Nepal is an instant delivery app where customers can order products and sellers can upload their products for sale.

## Sprint 1 Deliverables ✅
1. ✅ Splash Screen
2. ✅ Onboarding Screen (3 screens)
3. ✅ Login Screen
4. ✅ Register Screen
5. ✅ Home Screen

## Folder Structure

```
xpress_nepal/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── app.dart                  # Main app widget with theme configuration
│   │
│   ├── screens/                  # All app screens
│   │   ├── splash_screen.dart    # Animated splash screen with logo
│   │   ├── onboarding_screen.dart # 3-page onboarding with navigation
│   │   ├── login_screen.dart     # Login with email/password
│   │   ├── register_screen.dart  # Registration with customer/seller selection
│   │   └── home_screen.dart      # Home dashboard with bottom navigation
│   │
│   ├── utils/                    # Utility classes
│   │   ├── theme.dart            # App theme with brand colors
│   │   └── responsive.dart       # Responsive design utilities
│   │
│   └── widgets/                  # Reusable widgets
│       └── custom_text_field.dart # Custom form field widget
│
├── assets/                       # Asset files
│   └── images/
│       ├── icons/                # App icons (place your icons here)
│       └── lottie/               # Lottie animations (place animations here)
│
├── pubspec.yaml                  # Project dependencies
└── README_SPRINT1.md             # This file

```

## Theme Colors (From Logo)
- **Primary Orange**: `#F57C00` - Main brand color
- **Dark Grey**: `#424242` - Text and secondary elements
- **Light Grey**: `#F5F5F5` - Backgrounds and inputs
- **White**: `#FFFFFF` - Primary background

## How to Add Your Logo
1. Place your logo image in: `assets/images/`
2. Update the splash screen (`lib/screens/splash_screen.dart`):
   ```dart
   // Replace this:
   Icon(Icons.delivery_dining, ...)
   
   // With:
   Image.asset('assets/images/your_logo.png', width: logoSize, height: logoSize)
   ```

## Responsive Design
The app is fully responsive and works on:
- 📱 **Mobile** (< 650px width)
- 📱 **Tablet** (650px - 1100px width)  
- 🖥️ **Desktop** (> 1100px width)

All fonts, spacings, and icons automatically scale based on screen size.

## Screen Flow
```
Splash Screen (3s)
    ↓
Onboarding (3 pages)
    ↓
Login Screen ←→ Register Screen
    ↓
Home Screen (with bottom navigation)
    ├── Home Tab
    ├── Categories Tab
    ├── Cart Tab
    └── Profile Tab
```

## Key Features

### 1. Splash Screen
- Animated fade-in and scale effects
- Displays logo and app name
- Auto-navigates to onboarding after 3 seconds

### 2. Onboarding
- 3 informative pages
- Smooth page transitions
- Dot indicators
- Skip button
- Get Started button on last page

### 3. Login Screen
- Email and password fields
- Form validation
- Show/hide password toggle
- Forgot password link
- Navigate to register screen

### 4. Register Screen
- Account type selection (Customer/Seller)
- Full name, email, phone, password fields
- Password confirmation
- Form validation
- Responsive layout

### 5. Home Screen
- Bottom navigation (4 tabs)
- Welcome card with gradient
- Quick action cards
- Featured products carousel
- Responsive grid layout

## Running the App

### For Mobile/Emulator:
```bash
flutter run
```

### For Web:
```bash
flutter run -d chrome
```

### For Tablet Testing:
```bash
# Use Android Studio to create a tablet AVD
# Or use Flutter Device Preview package
```

## Next Steps for Sprint 2
- Product listing and details
- Category management
- Shopping cart functionality
- Order placement
- User profile management

## Notes
- All screens have proper form validation
- Theme colors match the Xpress Nepal brand
- Responsive design works on mobile, tablet, and desktop
- Clean folder structure for easy maintenance
- Reusable widgets for consistency

## Development Guidelines
1. **Add new screens**: Create in `lib/screens/`
2. **Add reusable widgets**: Create in `lib/widgets/`
3. **Add utilities**: Create in `lib/utils/`
4. **Add images**: Place in `assets/images/`
5. **Update theme**: Modify `lib/utils/theme.dart`

---

**Current Sprint**: Sprint 1 ✅ Completed
**Next Sprint**: Sprint 2 (Product Management)
