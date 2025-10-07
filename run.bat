@echo off
echo Starting TMP WebView App...
echo.
echo Available commands:
echo 1. Run on Android
echo 2. Run on iOS (macOS only)
echo 3. Run on Web
echo 4. Build APK
echo 5. Clean and get dependencies
echo.
set /p choice="Enter your choice (1-5): "

if "%choice%"=="1" (
    echo Running on Android...
    flutter run
) else if "%choice%"=="2" (
    echo Running on iOS...
    flutter run -d ios
) else if "%choice%"=="3" (
    echo Running on Web...
    flutter run -d web-server --web-port 8080
) else if "%choice%"=="4" (
    echo Building APK...
    flutter build apk --release
) else if "%choice%"=="5" (
    echo Cleaning and getting dependencies...
    flutter clean
    flutter pub get
) else (
    echo Invalid choice. Please run the script again.
)

pause
