import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:permission_handler/permission_handler.dart';

import 'ask_mic_permission.dart';

class AskPermissions extends StatelessWidget {
  const AskPermissions({super.key});

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

          // Icons Row (GIFs for Location, Contacts)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Location Icon
              Container(
                height: 100,
                width: 100,
                color: AppColorConstants.themeColor.withOpacity(0.1),
                child: Image.asset(
                  'assets/location.gif', // Your GIF path for Location
                  fit: BoxFit.contain,
                ),
              ).circular,
              const SizedBox(width: 20),

              // Contact Icon
              Container(
                height: 100,
                width: 100,
                color: AppColorConstants.themeColor.withOpacity(0.1),
                child: Image.asset(
                  'assets/contact-book.gif', // Your GIF path for Contacts
                  fit: BoxFit.contain,
                ),
              ).circular,
            ],
          ),

          // Combined Text for Permissions
          const SizedBox(height: 40),  // Space between images and text
          BodyLargeText(
            'To enhance your experience, we will need access to your location and contacts to share content with your friends and create posts.',
            textAlign: TextAlign.center,
            weight: TextWeight.semiBold,
          ),

          // Expanded space between text and button to push button to bottom
          const Spacer(),  // This pushes the button to the bottom

          // Next Button with updated color for consistency
          AppThemeButton(
            text: nextString.tr,
            onPress: () async {
              // Request permissions sequentially
              bool locationPermissionGranted =
              await Permission.location.request().isGranted;
              bool contactPermissionGranted =
              await FlutterContacts.requestPermission();

              // Handle navigation or permission denial
              if (locationPermissionGranted && contactPermissionGranted) {
                Get.to(() => AskMicPermission());
              } else {
                // Show error or guidance for missing permissions
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
