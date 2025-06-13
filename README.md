# Rathin - Flutter Developer Portfolio

A modern, responsive portfolio website built with Flutter that showcases my skills, projects, and experience as a Flutter developer. This portfolio is designed to work seamlessly across all platforms including Web, Android, iOS, macOS, Windows, and Linux.

## ✨ Features

- **🎨 Modern Design**: Clean, professional UI with smooth animations
- **📱 Fully Responsive**: Optimized for mobile, tablet, and desktop screens
- **🌙 Dark/Light Theme**: Toggle between themes with persistent preference
- **⚡ Cross-Platform**: Runs on Web, Android, iOS, macOS, Windows, and Linux
- **🔥 Firebase Integration**: Contact form with Firestore backend
- **🎭 Smooth Animations**: Beautiful entrance animations and transitions
- **📧 Contact Form**: Functional contact form with validation
- **🔗 Social Links**: Direct links to GitHub, LinkedIn, and other platforms
- **📄 Resume Download**: Direct download link for resume
- **🎯 SEO Optimized**: Meta tags and structured data for web

## 🏗️ Architecture

### Project Structure
```
lib/
├── models/           # Data models (Project, Certificate, Contact)
├── providers/        # State management (Theme Provider)
├── screens/          # Main portfolio screen
├── services/         # Firebase and API services
├── utils/           # Constants, themes, and utilities
└── widgets/         # Reusable UI components
    ├── hero_section.dart
    ├── about_section.dart
    ├── projects_section.dart
    ├── certificates_section.dart
    ├── contact_section.dart
    └── footer_section.dart
```

### Key Technologies
- **Flutter 3.32.2** - Cross-platform framework
- **Firebase** - Backend services (Firestore, Hosting)
- **Provider** - State management
- **Responsive Framework** - Responsive design
- **Animated Text Kit** - Text animations
- **Google Fonts** - Typography
- **Font Awesome** - Icons

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Firebase project setup
- IDE (VS Code, Android Studio, or IntelliJ)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/rathin/portfolio.git
   cd portfolio
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project
   - Enable Firestore Database
   - Download configuration files:
     - `google-services.json` for Android
     - `GoogleService-Info.plist` for iOS
     - Update `firebase_options.dart`

4. **Update Personal Information**
   - Edit `lib/utils/constants.dart` with your information
   - Replace sample projects and certificates with your own
   - Update social media links and contact information

5. **Add Assets**
   - Add your profile image to `assets/images/`
   - Add project screenshots to `assets/images/`
   - Add certificate images to `assets/certificates/`

### Running the Application

**Web Development**
```bash
flutter run -d chrome
```

**Mobile Development**
```bash
# Android
flutter run -d android

# iOS
flutter run -d ios
```

**Desktop Development**
```bash
# macOS
flutter run -d macos

# Windows
flutter run -d windows

# Linux
flutter run -d linux
```

## 🎨 Customization

### Personal Information
Update your details in `lib/utils/constants.dart`:
```dart
static const String name = "Your Name";
static const String email = "your.email@gmail.com";
static const String bio = "Your bio here...";
```

### Theme Colors
Modify colors in `lib/utils/app_theme.dart`:
```dart
static const Color primaryColor = Color(0xFF2196F3);
static const Color secondaryColor = Color(0xFF03DAC6);
```

### Projects and Certificates
Replace sample data in `lib/utils/constants.dart`:
```dart
static const List<Map<String, dynamic>> sampleProjects = [
  // Your projects here
];
```

## 🌐 Deployment

### Web Deployment (Firebase Hosting)
```bash
flutter build web
firebase deploy
```

### Mobile App Stores
```bash
# Android Play Store
flutter build appbundle

# iOS App Store
flutter build ios
```

### Desktop Distribution
```bash
# macOS
flutter build macos

# Windows
flutter build windows

# Linux
flutter build linux
```

## 📱 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| Web | ✅ | Fully responsive, SEO optimized |
| Android | ✅ | Material Design 3 |
| iOS | ✅ | Cupertino design elements |
| macOS | ✅ | Native desktop experience |
| Windows | ✅ | Windows 10/11 compatible |
| Linux | ✅ | GTK-based UI |

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Contact

**Rathin** - Flutter Developer
- Email: rathin.dev@gmail.com
- LinkedIn: [linkedin.com/in/rathin](https://linkedin.com/in/rathin)
- GitHub: [github.com/rathin](https://github.com/rathin)

---

⭐ **Star this repository if you found it helpful!**
