import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'loading_screen.dart';

/// Splash screen that shows the loading animation and then navigates to home
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return LoadingScreen(
        loadingDuration: const Duration(seconds: 4),
        onLoadingComplete: () {
          setState(() {
            _isLoading = false;
          });
          
          // Navigate to home page after a brief delay
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              final navigator = GoRouter.of(context);
              navigator.go('/');
            }
          });
        },
      );
    }
    
    // This should not be reached, but just in case
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
