import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'dart:ui';

// Theme/brand colors
const kBrandGreen = Color(0xFF27472F);
const kBrandYellow = Color(0xFFF8DE40);
const kBrandBlue = Color(0xFF284C59);
const kBrandHomeBackground = Color(0xFF343539); // New background color for WelcomeScreen
const kBottomBarBackground = Color(0xFF22495A); // bottom bar background
const kBottomBarActive = Color(0xFFCBF201); // active icon/label

void main() {
  runApp(const TMPApp());
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.asset('assets/splash.MOV');
      await _videoController.initialize();
      setState(() {
        _isVideoInitialized = true;
      });
      
      // Play the video
      _videoController.play();
      
      // Navigate to main app after video duration
      _videoController.addListener(() {
        if (_videoController.value.position >= _videoController.value.duration) {
          _navigateToMainApp();
        }
      });
      
      // Also navigate after 5 seconds as fallback
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          _navigateToMainApp();
        }
      });
    } catch (e) {
      print('Error initializing video: $e');
      // If video fails, show logo and navigate after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _navigateToMainApp();
        }
      });
    }
  }

  void _navigateToMainApp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const WebViewScreen(initialIndex: 0)),
    );
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _isVideoInitialized
            ? AspectRatio(
                aspectRatio: _videoController.value.aspectRatio,
                child: VideoPlayer(_videoController),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo.JPG',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(),
                ],
              ),
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBrandHomeBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Image.asset(
              'assets/logo.JPG',
              width: 44,
              height: 44,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(height: 6),
                  Text(
                    'Digital CO-HOST App For Vacation',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 16, height: 1),
                  ),
                  Text(
                    'Rentals Globally',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 16, height: 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 36),
              const Text(
                'EXPLORE AS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 36,
                ),
              ),
              const SizedBox(height: 36),
              ElevatedButton.icon(
                icon: const Icon(Icons.vpn_key, color: Colors.white, size: 32),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'GUEST or HOST',
                    style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22,
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBrandBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WebViewScreen(initialIndex: 1),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.menu_book_rounded, color: Colors.black, size: 32),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'GET LISTED',
                    style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22,
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBrandYellow,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WebViewScreen(initialIndex: 2),
                    ),
                  );
                },
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 0, // Home is selected
        onTap: (int idx) {
          if (idx == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => WebViewScreen(initialIndex: 1),
              ),
            );
          } else if (idx == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => WebViewScreen(initialIndex: 2),
              ),
            );
          }
          // If idx == 0, do nothing (already home)
        },
        showSelection: false,
        isHome: true,
      ),
    );
  }
}

class CustomBottomBar extends StatelessWidget {
  final int? currentIndex;
  final bool showSelection;
  final void Function(int) onTap;
  final bool isHome;
  const CustomBottomBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.showSelection = true,
    this.isHome = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: 'Host',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_business),
          label: 'Get Listed',
        ),
      ],
      currentIndex: currentIndex ?? 0,
      selectedItemColor: Colors.white, // selected icon/label is now white
      unselectedItemColor: kBottomBarActive, // unselected icons/labels are greenish
      backgroundColor: kBottomBarBackground,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      onTap: (idx) {
        if (idx == 0) {
          if (!isHome) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const WelcomeScreen()),
              (route) => false,
            );
          }
        } else {
          onTap(idx);
        }
      },
      selectedFontSize: 14,
      unselectedFontSize: 14,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      elevation: 1,
      selectedIconTheme: const IconThemeData(size: 30, color: Colors.white),
      unselectedIconTheme: const IconThemeData(size: 24, color: kBottomBarActive),
    );
  }
}

class TMPApp extends StatelessWidget {
  const TMPApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TTvSA - WebView App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: kBrandHomeBackground,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WebViewScreen extends StatefulWidget {
  final int initialIndex;
  const WebViewScreen({super.key, this.initialIndex = 0});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  String _currentUrl = 'https://www.ttvsa.com'; // Default URL
  late int _selectedIndex;
  // Update the nav urls:
  static const List<String> _navUrls = [
    'https://www.ttvsa.com/',
    'https://www.ttvsa.com/guestlogin',
    'https://www.ttvsa.com/host',
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _currentUrl = _navUrls[_selectedIndex]; // Ensure _currentUrl is set early
    print('[WebView] Initial URL (from initState): $_currentUrl');
    _initializeWebView();
    _checkPermissions();
    _loadSavedUrl();
  }

  void _initializeWebView() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);

    print('[WebView] Loading URL: $_currentUrl');
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      //..setUserAgent('Mozilla/5.0 (Linux; Android 13; Mobile; rv:109.0) Gecko/20100101 Firefox/117.0 Chrome/117.0.0.0 Mobile Safari/537.36') // commented for test
      ..enableZoom(true)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading progress
          },
          onPageStarted: (String url) {
            print('Page started loading: $url');
            setState(() {
              _isLoading = true;
              _hasError = false;
              _currentUrl = url;
            });
          },
          onPageFinished: (String url) {
            print('Page finished loading: $url');
            setState(() {
              _isLoading = false;
              _hasError = false; // Clear any previous errors
              _currentUrl = url;
            });
          },
          onWebResourceError: (WebResourceError error) {
            print('WebView Error: ${error.description}');
            print('Error Code: ${error.errorCode}');
            print('Error Type: ${error.errorType}');
            
            // Only show error for critical failures, not for resource loading issues
            if (error.errorCode == -1 && error.description.contains('ERR_FAILED')) {
              // This might be a network issue, try to continue
              print('Network error detected, continuing...');
              return;
            }
            
            setState(() {
              _hasError = true;
              _errorMessage = 'Error: ${error.description}\nError Code: ${error.errorCode}\nError Type: ${error.errorType}';
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            print('Navigation request: ${request.url}');
            
            // Handle YouTube links - open in YouTube app
            if (request.url.contains('youtube.com') || 
                request.url.contains('youtu.be') ||
                request.url.contains('m.youtube.com') ||
                request.url.contains('youtube.com/shorts')) {
              print('YouTube link detected: ${request.url}');
              _launchExternalUrl(request.url);
              return NavigationDecision.prevent;
            }
            
            // Handle phone call links - open in phone app
            if (request.url.startsWith('tel:')) {
              print('Phone call link detected: ${request.url}');
              _launchExternalUrl(request.url);
              return NavigationDecision.prevent;
            }
            
            // Handle email links - open in email app
            if (request.url.startsWith('mailto:')) {
              print('Email link detected: ${request.url}');
              _launchExternalUrl(request.url);
              return NavigationDecision.prevent;
            }
            
            // Handle Maps/Directions links - open in Maps app
            if (request.url.contains('maps.google.com') ||
                request.url.contains('goo.gl/maps') ||
                request.url.contains('maps.apple.com') ||
                request.url.contains('waze.com') ||
                request.url.contains('bing.com/maps') ||
                request.url.contains('openstreetmap.org') ||
                request.url.contains('google.com/maps') ||
                request.url.contains('directions') ||
                request.url.startsWith('geo:') ||
                request.url.startsWith('comgooglemaps://') ||
                request.url.startsWith('maps://')) {
              print('Maps link detected: ${request.url}');
              _launchExternalUrl(request.url);
              return NavigationDecision.prevent;
            }
            
            // Handle other external links (social media, etc.)
            if (request.url.startsWith('https') && 
                !request.url.contains('ttvsa.com')) {
              _launchExternalUrl(request.url);
              return NavigationDecision.prevent;
            }
            
            // Allow all navigation within ttvsa.com and other internal links
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (JavaScriptMessage message) {
          print('JavaScript message received: ${message.message}');
          // Handle external URL launches from JavaScript
          if (message.message.startsWith('launch_url:')) {
            final url = message.message.substring(11);
            _launchExternalUrl(url);
          }
        },
      )
      ..loadRequest(Uri.parse(_currentUrl));

    _controller = controller;
  }

  Future<void> _checkPermissions() async {
    // Request internet permission
    await Permission.storage.request();
    await Permission.camera.request();
    await Permission.microphone.request();
  }

  Future<void> _loadSavedUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString('last_url');
    if (savedUrl != null && savedUrl.isNotEmpty) {
      setState(() {
        _currentUrl = savedUrl;
      });
      _controller.loadRequest(Uri.parse(savedUrl));
    }
  }

  Future<void> _saveUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_url', url);
  }

  Future<void> _launchExternalUrl(String url) async {
    print('Attempting to launch external URL: $url');
    final Uri uri = Uri.parse(url);
    
    // Special handling for phone and email links
    if (url.startsWith('tel:') || url.startsWith('mailto:')) {
      try {
        print('Trying platform default for tel/mailto...');
        await launchUrl(uri, mode: LaunchMode.platformDefault);
        print('Successfully launched tel/mailto with platform default');
        return;
      } catch (e) {
        print('Platform default launch failed for tel/mailto: $e');
      }
    }
    
    // Try to launch directly without checking canLaunchUrl first
    // as it often returns false for valid URLs
    try {
      print('Trying external application launch...');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      print('Successfully launched with external application');
      return;
    } catch (e) {
      print('External application launch failed: $e');
    }
    
    // If external app fails, try platform default
    try {
      print('Trying platform default launch...');
      await launchUrl(uri, mode: LaunchMode.platformDefault);
      print('Successfully launched with platform default');
      return;
    } catch (e) {
      print('Platform default launch failed: $e');
    }
    
    // Last resort - try with inAppWebView
    try {
      print('Trying inAppWebView launch...');
      await launchUrl(uri, mode: LaunchMode.inAppWebView);
      print('Successfully launched with inAppWebView');
      return;
    } catch (e) {
      print('All launch methods failed for URL: $url, Error: $e');
    }
    
    // If all else fails, try the old launch method
    try {
      print('Trying legacy launch method...');
      await launchUrl(uri);
      print('Successfully launched with legacy method');
    } catch (e) {
      print('Legacy launch method also failed: $e');
    }
  }

  void _onBottomNavTapped(int index) {
    if (index == 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (route) => false,
      );
    } else {
      setState(() {
        _selectedIndex = index;
        _currentUrl = _navUrls[index];
        _controller.loadRequest(Uri.parse(_currentUrl));
      });
    }
  }

  void _reload() {
    _controller.reload();
  }

  Future<void> _pullToRefresh() async {
    _controller.reload();
    // Optionally, wait until loading completes before finishing refresh visually
    while (_isLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
      // It will finish once _isLoading is false.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _hasError
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading page',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _reload,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: _pullToRefresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height,
                          child: WebViewWidget(controller: _controller),
                        ),
                      ],
                    ),
                  ),
                  if (_isLoading)
                    const Positioned(
                      top: 20,
                      right: 20,
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        showSelection: true,
        isHome: false,
      ),
    );
  }

}