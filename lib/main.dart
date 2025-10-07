import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

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
      MaterialPageRoute(builder: (context) => const WebViewScreen()),
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

class TMPApp extends StatelessWidget {
  const TMPApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TTvSA - WebView App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  String _currentUrl = 'https://www.ttvsa.com'; // Default URL

  @override
  void initState() {
    super.initState();
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

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent('Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36')
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
            if (request.url.startsWith('http') && 
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


  void _reload() {
    _controller.reload();
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
                  WebViewWidget(controller: _controller),
                  if (_isLoading)
                    const Positioned(
                      top: 20,
                      right: 20,
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
      ),
    );
  }

}