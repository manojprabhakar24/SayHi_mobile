import 'package:flutter/material.dart';
import 'package:get/get.dart'; // For navigation if using GetX

import '../../main.dart';
import '../dashboard/loading.dart';
import '../popups/ask_location_permission.dart';

class AskToFollow extends StatefulWidget {
  const AskToFollow({super.key});

  @override
  _AskToFollowState createState() => _AskToFollowState();
}

class _AskToFollowState extends State<AskToFollow> {
  final PageController _pageController = PageController(); // Controller for PageView

  @override
  void initState() {
    super.initState();

    // Automatically move to the second slide after 2 seconds
    Future.delayed(const Duration(seconds: 3), () {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });
  }

  void _navigateToNextStep() {
    if (isPermissionsAsked == false) {
      Get.offAll(() => const AskPermissions());
    } else {
      Get.offAll(() => const LoadingScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Prevent manual swiping
        children: [
          // First Slide
          Stack(
            children: [
              // Background image
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/bg logo.jpg'), // Replace with your background image path
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Foreground content
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Ensures the column takes only the space it needs
                  children: [
                    // Image with increased size
                    Image.asset(
                      'assets/IMG_2499.PNG', // Replace with your image path
                      width: 150, // Increased width
                      height: 200, // Increased height
                      fit: BoxFit.cover, // Adjust the image fit
                    ),
                    const SizedBox(height: 8), // Adjusted spacing between image and text
                    // Tagline text
                    const Text(
                      'Where Voices Connect People',
                      style: TextStyle(
                        fontSize: 16, // Slightly larger font size for formality
                        fontWeight: FontWeight.bold, // Bold text for formal appearance
                        color: Colors.black, // Neutral black for professional look
                        letterSpacing: 0.8, // Subtle letter spacing
                      ),
                      textAlign: TextAlign.center, // Ensures the text is centered below the image
                    ),
                  ],
                ),
              )




            ],
          ),


          // Second Slide
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Centering the content vertically
              children: [
                Spacer(),
                // First Row: Conversation on the left, Girl image on the right
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(2, 4),
                              ),
                            ],
                          ),
                          child: const Text(
                            'I have many questions in my head, but I don’t know whom to ask to gain knowledge.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage('assets/girlconvo.gif'),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(2, 4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage('assets/boyconvo.gif'),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(2, 4),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(2, 4),
                            ),
                          ],
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                            children: [
                              const TextSpan(text: 'You can ask questions to experts in specific fields through voice locally & nationally in all Languages using '),
                              TextSpan(
                                text: 'FonyBox',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                              const TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(), // This will push the "Next" button to the bottom
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _navigateToNextStep,
                    child: const Text('Next'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          )

        ],
      ),
    );
  }
}
