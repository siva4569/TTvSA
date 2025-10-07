# TMP - WebView Mobile App

A Flutter-based mobile application that provides a full-featured WebView experience with navigation controls, URL management, and cross-platform support.

## Features

- 🌐 **Full WebView Support**: Browse any website with a native app experience
- 📱 **Cross-Platform**: Works on both Android and iOS
- 🧭 **Navigation Controls**: Back, forward, reload, and home buttons
- 🔗 **URL Management**: Enter custom URLs and save last visited page
- 📷 **Media Support**: Camera and microphone access for web content
- 🔒 **Security**: Proper permissions and network security configuration
- 💾 **Persistence**: Remembers last visited URL
- 🎨 **Modern UI**: Clean and intuitive user interface

## Dependencies

The app includes the following key dependencies:

- `webview_flutter`: Core WebView functionality
- `webview_flutter_android`: Android-specific WebView implementation
- `webview_flutter_wkwebview`: iOS-specific WebView implementation
- `permission_handler`: Handle device permissions
- `connectivity_plus`: Network connectivity monitoring
- `shared_preferences`: Local data storage
- `url_launcher`: External URL handling
- `flutter_screenutil`: Responsive UI design
- `provider`: State management
- `dio`: HTTP client for network requests
- `device_info_plus`: Device information
- `package_info_plus`: App information

## Installation & Setup

### Prerequisites

- Flutter SDK (>=3.10.0)
- Dart SDK (>=3.0.0)
- Android Studio (for Android development)
- Xcode (for iOS development, macOS only)

### Getting Started

1. **Clone or navigate to the project directory:**
   ```bash
   cd tmp
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   # For Android
   flutter run
   
   # For iOS (macOS only)
   flutter run -d ios
   
   # For specific device
   flutter devices
   flutter run -d <device-id>
   ```

### Building for Production

#### Android
```bash
# Debug APK
flutter build apk

# Release APK
flutter build apk --release

# App Bundle (recommended for Play Store)
flutter build appbundle --release
```

#### iOS
```bash
# Build for iOS (requires macOS and Xcode)
flutter build ios --release
```

## Configuration

### Android Configuration

The app includes the following Android configurations:

- **Permissions**: Internet, network state, camera, microphone, storage
- **Network Security**: Allows cleartext traffic for development
- **WebView**: Hardware acceleration enabled

### iOS Configuration

The app includes the following iOS configurations:

- **App Transport Security**: Allows arbitrary loads for development
- **Permissions**: Camera, microphone, photo library access
- **WebView**: WKWebView with media playback support

## Usage

1. **Launch the app** - It will open with Google as the default page
2. **Navigate** - Use the back/forward buttons to navigate web history
3. **Enter URL** - Tap the language icon or floating action button to enter a custom URL
4. **Reload** - Use the refresh button to reload the current page
5. **Home** - Use the home button to return to Google
6. **External Links** - External links will open in the device's default browser

## Customization

### Changing Default URL

To change the default URL that loads when the app starts:

1. Open `lib/main.dart`
2. Find the line: `String _currentUrl = 'https://www.google.com';`
3. Replace with your desired URL

### Adding Custom Features

The app is structured to easily add new features:

- **WebView Controller**: Access via `_controller` for advanced WebView operations
- **JavaScript Channels**: Add custom JavaScript communication
- **Navigation**: Extend the navigation bar with additional buttons
- **Theming**: Customize colors and styles in the MaterialApp theme

## Troubleshooting

### Common Issues

1. **WebView not loading content:**
   - Check internet connection
   - Verify URL is correct and accessible
   - Check Android network security configuration

2. **Permissions denied:**
   - Ensure all required permissions are granted
   - Check platform-specific permission configurations

3. **Build errors:**
   - Run `flutter clean` and `flutter pub get`
   - Ensure Flutter and Dart SDK versions are compatible
   - Check platform-specific build requirements

### Debug Mode

Run the app in debug mode for detailed logging:
```bash
flutter run --debug
```

## Platform-Specific Notes

### Android
- Minimum SDK version: 21 (Android 5.0)
- Target SDK version: 34 (Android 14)
- Requires internet permission for WebView functionality

### iOS
- Minimum iOS version: 12.0
- Requires proper signing and provisioning for device testing
- WebView uses WKWebView for better performance and security

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on both Android and iOS
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and questions:
- Check the Flutter documentation: https://docs.flutter.dev/
- WebView Flutter plugin docs: https://pub.dev/packages/webview_flutter
- Create an issue in the project repository

---

**TMP WebView App** - Built with Flutter ❤️