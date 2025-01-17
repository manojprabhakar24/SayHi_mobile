import 'package:foap/helper/imports/common_import.dart';
import 'package:permission_handler/permission_handler.dart';

import '../dashboard/loading.dart';

class AskMicPermission extends StatelessWidget {
  const AskMicPermission({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,  // Start aligning the top content
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Spacer at the top to give space from the top edge
          const Spacer(), // Adjusted space at the top

          // Icons Row (GIFs for Mic and Gallery)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Mic Icon
              Container(
                height: 100,
                width: 100,
                color: AppColorConstants.themeColor.withOpacity(0.1),
                child: Image.asset(
                  'assets/microphone.gif', // Your GIF path for Mic
                  fit: BoxFit.contain,
                ),
              ).circular,
              const SizedBox(width: 20),

              // Gallery Icon
              Container(
                height: 100,
                width: 100,
                color: AppColorConstants.themeColor.withOpacity(0.1),
                child: Image.asset(
                  'assets/picture.gif', // Your GIF path for Gallery
                  fit: BoxFit.contain,
                ),
              ).circular,
            ],
          ),

          // Combined Text for Permissions
          const SizedBox(height: 40),  // Space between images and text
          BodyLargeText(
            'We will access your Mic for recording audio and with friends in chat and create posts.',
            textAlign: TextAlign.center,
            weight: TextWeight.semiBold,
          ),

          // Expanded space between text and button to push button to bottom
          const Spacer(),  // This pushes the button to the bottom

          // Next Button with updated color for consistency
          AppThemeButton(
            text: nextString.tr,
            onPress: () async {
              // Request Mic permission
              var micStatus = await Permission.microphone.request();
              print(micStatus);

              // Request Gallery permission
              var galleryStatus = await Permission.photos.request();
              print(galleryStatus);

              if (micStatus.isGranted && galleryStatus.isGranted) {
                // Permissions granted, continue with your flow
                Get.offAll(() => LoadingScreen()); // Navigate to loading screen or your next screen
              } else {
                // Handle denial of permissions if needed
                Get.snackbar(
                  'Permission Denied',
                  'Please allow all permissions to continue.',
                  backgroundColor: AppColorConstants.themeColor,
                  colorText: Colors.white,
                );
              }
            },
          ),

          const SizedBox(height: 20), // Space after the button to ensure visibility
        ],
      ).hp(DesignConstants.horizontalPadding),
    );
  }
}
