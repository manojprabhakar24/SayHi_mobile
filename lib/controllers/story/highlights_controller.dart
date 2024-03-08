import 'dart:io';
import 'dart:typed_data';
import 'package:foap/api_handler/apis/highlights_api.dart';
import 'package:foap/api_handler/apis/misc_api.dart';
import 'package:foap/api_handler/apis/story_api.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/highlights_imports.dart';
import 'package:foap/util/constant_util.dart';
import '../../model/story_model.dart';
import 'package:foap/helper/file_extension.dart';
import 'package:path_provider/path_provider.dart';

class HighlightsController extends GetxController {
  final UserProfileManager _userProfileManager = Get.find();

  RxList<HighlightsModel> highlights = <HighlightsModel>[].obs;
  RxList<StoryMediaModel> selectedStoriesMedia = <StoryMediaModel>[].obs;
  RxList<StoryMediaModel> stories = <StoryMediaModel>[].obs;

  Rx<HighlightMediaModel?> storyMediaModel = Rx<HighlightMediaModel?>(null);
  Rx<HighlightsModel?> currentHighlight = Rx<HighlightsModel?>(null);
  List<HighlightMediaModel> currentHighlightStories = [];

  String coverImage = '';
  String coverImageName = '';

  Rx<File?> pickedImage = Rx<File?>(null);
  String? picture;
  UserModel? model;

  RxBool isLoading = true.obs;

  clear() {
    selectedStoriesMedia.clear();
  }

  setCurrentHighlight(HighlightsModel highlight) {
    currentHighlight.value = highlight;
    currentHighlightStories.addAll(highlight.medias);
  }

  setCurrentStoryMedia(HighlightMediaModel storyMedia) {
    storyMediaModel.value = storyMedia;
    update();
  }

  updateCoverImage(File? image) {
    pickedImage.value = image;
  }

  updateCoverImagePath() {
    for (StoryMediaModel media in selectedStoriesMedia) {
      if (media.image != null) {
        coverImage = media.image!;
        coverImageName = media.imageName!;
        break;
      }
    }
  }

  void getHighlights({required int userId}) {
    isLoading.value = true;
    update();

    HighlightsApi.getHighlights(
        userId: userId,
        resultCallback: (result) {
          isLoading.value = false;
          highlights.value = result;
          update();
        });
  }

  getAllStories() {
    isLoading.value = true;
    update();
    StoryApi.getMyStories(resultCallback: (result) {
      isLoading.value = false;
      stories.value = result;
      update();
    });
  }

  createHighlights({required String name}) async {
    if (pickedImage.value != null) {
      await uploadCoverImage();
    }

    HighlightsApi.createHighlights(
        name: name,
        image: coverImageName,
        stories: selectedStoriesMedia
            .map((element) => element.id.toString())
            .toList()
            .join(','),
        resultCallback: () {
          getHighlights(userId: _userProfileManager.user.value!.id);

          Get.close(2);
        });
  }

  Future uploadCoverImage() async {
    Uint8List compressedData = await pickedImage.value!.compress();
    final tempDir = await getTemporaryDirectory();
    File file = await File('${tempDir.path}/${randomId()}.png').create();
    file.writeAsBytesSync(compressedData);
    await MiscApi.uploadFile(file.path,
        mediaType: GalleryMediaType.photo,
        type: UploadMediaType.storyOrHighlights,
        resultCallback: (fileName, filePath) {
      coverImageName = fileName;
    });
  }

  deleteStoryFromHighlight() async {
    currentHighlightStories
        .removeWhere((element) => element.id == storyMediaModel.value!.id);
    await HighlightsApi.deleteStoryFromHighlights(storyMediaModel.value!.id);

    if (currentHighlightStories.isEmpty) {
      await HighlightsApi.deleteHighlight(currentHighlight.value!.id);
    }
  }
}
