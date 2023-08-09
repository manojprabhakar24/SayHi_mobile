import 'package:foap/screens/chat/media.dart';
import 'package:get/get.dart';

class SelectPostMediaController extends GetxController {
  RxList<Media> selectedMediaList = <Media>[].obs;
  RxBool allowMultipleSelection = false.obs;
  RxInt currentIndex = 0.obs;

  clear() {
    print('clear selectedMediaList');
    allowMultipleSelection.value = false;
    selectedMediaList.clear();
    update();
  }

  toggleMultiSelectionMode() {
    allowMultipleSelection.value = !allowMultipleSelection.value;
    update();
  }

  mediaSelected(List<Media> media) {
    selectedMediaList.value = media;
    selectedMediaList.refresh();
    print('mediaSelected');
    update();
  }

  updateGallerySlider(int index) {
    currentIndex.value = index;
    update();
  }
}
