import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/dashboard/dashboard_screen.dart';
import 'package:foap/theme/theme.dart';
import '../../api_handler/apis/story_api.dart';

// class TextStoryMakerController extends GetxController {
//   Rx<Color> selectedStrokeColor = Colors.black.obs;
//   Rx<Color?> selectedBackgroundColor = Colors.white.obs;
//   Rx<String> fontName = 'Lato'.obs;
//   RxString inputText = ''.obs;
//   Rx<TextStyle> currentFont = const TextStyle().obs;
//
//   textChanged(String text) {
//     inputText.value = text;
//   }
//
//   setFont(Font font) {
//     switch (font) {
//       case Font.roboto:
//         fontName.value = 'Roboto';
//         break;
//       case Font.raleway:
//         fontName.value = 'Raleway';
//         break;
//       case Font.poppins:
//         fontName.value = 'Poppins';
//         break;
//       case Font.openSans:
//         fontName.value = 'OpenSans';
//         break;
//       case Font.lato:
//         fontName.value = 'Lato';
//         break;
//     }
//     update();
//   }
//
//   setStrokeColor(Color color) {
//     selectedStrokeColor.value = color;
//   }
//
//   setBackgroundColor(Color color) {
//     selectedBackgroundColor.value = color;
//   }
//
//   postTextStory({required String text, required String backgroundColor}) {
//     StoryApi.postStory(
//         gallery: [
//           {
//             'image': '',
//             'video': '',
//             'type': '1',
//             'description': text,
//             'background_color': backgroundColor,
//           }
//         ],
//         successHandler: () {
//           AppUtil.showToast(
//               message: storyPostedSuccessfullyString, isSuccess: true);
//         });
//     DashboardController dashboardController = Get.find();
//     dashboardController.indexChanged(0);
//     Get.offAll(() => const DashboardScreen());
//   }
// }
