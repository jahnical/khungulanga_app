import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.blue, // Set the background color to blue
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              // Replace the text with a custom styled text
              Text(
                'Khungulanga', // App name
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  // Add any additional text styling as desired
                ),
              ),
              SizedBox(height: 20), // Add some vertical spacing

              // Replace the default CircularProgressIndicator with a custom designed loading indicator
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 4,
              ),

              SizedBox(height: 20), // Add some vertical spacing

              Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  // Add any additional text styling as desired
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
