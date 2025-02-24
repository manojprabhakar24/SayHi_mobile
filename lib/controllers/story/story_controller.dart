import 'package:foap/api_handler/apis/misc_api.dart';
import 'package:foap/api_handler/apis/story_api.dart';
import 'package:foap/controllers/chat_and_call/chat_detail_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:async';
import 'package:foap/model/story_model.dart';
import 'package:foap/screens/chat/media.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import '../../manager/db_manager_realm.dart';
import '../../model/data_wrapper.dart';
import '../home/home_controller.dart';
import 'package:foap/helper/file_extension.dart';

class AppStoryController extends GetxController {
  final ChatDetailController _chatDetailController = Get.find();
  RxList<Media> mediaList = <Media>[].obs;
  RxList<StoryViewerModel> storyViewers = <StoryViewerModel>[].obs;
  DataWrapper storyViewerDataWrapper = DataWrapper();

  RxBool allowMultipleSelection = false.obs;
  RxInt numberOfItems = 0.obs;

  Rx<StoryMediaModel?> currentStoryMediaModel = Rx<StoryMediaModel?>(null);

  RxBool showEmoticons = false.obs;
  RxString replyText = ''.obs;

  clearStoryViewers() {
    storyViewers.clear();
    storyViewerDataWrapper = DataWrapper();
  }

  showHideEmoticons(bool show) {
    showEmoticons.value = show;
  }

  replyTextChanged(String text) {
    replyText.value = text;
  }

  mediaSelected(List<Media> media) {
    mediaList.value = media;
  }

  toggleMultiSelectionMode() {
    allowMultipleSelection.value = !allowMultipleSelection.value;
    update();
  }

  deleteStory(VoidCallback callback) {
    StoryApi.deleteStory(
        id: currentStoryMediaModel.value!.id, callback: callback);
  }

  setCurrentStoryMedia(StoryMediaModel storyMedia) {
    print('1');
    UserProfileManager userProfileManager = Get.find();
    print('2');

    clearStoryViewers();
    print('3');

    currentStoryMediaModel.value = storyMedia;
    print('4');

    getIt<RealmDBManager>().storyViewed(storyMedia);
    print('5');

    if (storyMedia.userId == userProfileManager.user.value!.id) {
      loadStoryViewer();
    } else {
      StoryApi.viewStory(storyId: storyMedia.id);
    }
    update();
  }

  loadStoryViewer() {
    if (storyViewerDataWrapper.haveMoreData.value) {
      storyViewerDataWrapper.isLoading.value = true;
      StoryApi.getStoryViewers(
          storyId: currentStoryMediaModel.value!.id,
          page: storyViewerDataWrapper.page,
          resultCallback: (result, metadata) {
            storyViewers.addAll(result);

            storyViewerDataWrapper.processCompletedWithData(metadata);
          });
    }
  }

  void uploadAllMedia({required List<Media> items}) async {
    var responses =
        await Future.wait([for (Media media in items) uploadMedia(media)])
            .whenComplete(() {});

    publishAction(galleryItems: responses);
  }

  Future<Map<String, String>> uploadMedia(Media media) async {
    Map<String, String> gallery = {};
    final completer = Completer<Map<String, String>>();

    final tempDir = await getTemporaryDirectory();
    File mainFile;
    String? videoThumbnailPath;
    int videoDuration = 0;

    if (media.mediaType == GalleryMediaType.photo) {
      Uint8List mainFileData = await media.file!.compress();
      //image media
      mainFile =
          await File('${tempDir.path}/${media.id!.replaceAll('/', '')}.png')
              .create();
      mainFile.writeAsBytesSync(mainFileData);
    } else {
      Loader.show(status: loadingString.tr);

      MediaInfo? mediaInfo = await VideoCompress.compressVideo(
        media.file!.path,
        quality: VideoQuality.DefaultQuality,
        deleteOrigin: false, // It's false by default
      );
      mainFile = mediaInfo!.file!;

      final videoInfo = FlutterVideoInfo();
      var info = await videoInfo.getVideoInfo(media.file!.path);
      videoDuration = info!.duration!.toInt();

      File videoThumbnail = await File(
              '${tempDir.path}/${media.id!.replaceAll('/', '')}_thumbnail.png')
          .create();

      videoThumbnail.writeAsBytesSync(media.thumbnail!);

      await MiscApi.uploadFile(videoThumbnail.path,
          mediaType: GalleryMediaType.photo,
          type: UploadMediaType.storyOrHighlights,
          resultCallback: (fileName, filePath) async {
        videoThumbnailPath = fileName;
        await videoThumbnail.delete();
      });
    }

    Loader.show(status: loadingString.tr);

    await MiscApi.uploadFile(mainFile.path,
        mediaType: media.mediaType!, type: UploadMediaType.storyOrHighlights,
        resultCallback: (fileName, filePath) async {
      String mainFileUploadedPath = fileName;
      await mainFile.delete();
      gallery = {
        // 'image': media.mediaType == 1 ? mainFileUploadedPath : '',
        'image': media.mediaType == GalleryMediaType.photo
            ? mainFileUploadedPath
            : videoThumbnailPath!,
        'video': media.mediaType == GalleryMediaType.photo
            ? ''
            : mainFileUploadedPath,
        'video_time': videoDuration.toString(),
        'type': media.mediaType == GalleryMediaType.photo ? '2' : '3',
        'description': '',
        'background_color': '',
      };
      completer.complete(gallery);
    });

    return completer.future;
  }

  void publishAction({
    required List<Map<String, String>> galleryItems,
  }) {
    HomeController homeController = Get.find();
    StoryApi.postStory(
        gallery: galleryItems,
        successHandler: () {
          homeController.getStories();

          AppUtil.showToast(
              message: storyPostedSuccessfullyString, isSuccess: true);
        });
    // DashboardController dashboardController = Get.find();
    // dashboardController.indexChanged(0);
    // Get.offAll(() => const DashboardScreen());
  }

  sendTextMessage(String message, StoryModel story) {
    _chatDetailController.getChatRoomWithUser(
        userId: currentStoryMediaModel.value!.userId,
        callback: (room) {
          FocusScope.of(Get.context!).requestFocus(FocusNode());
          showHideEmoticons(false);
          StoryModel storyToSend = StoryModel(
              id: story.id,
              name: story.name,
              userName: story.userName,
              userImage: story.userImage,
              media: [currentStoryMediaModel.value!]);

          _chatDetailController.sendStoryTextReplyMessage(
              messageText: message, story: storyToSend, room: room);
        });
  }

  sendReactionMessage(String emoji, StoryModel story) {
    _chatDetailController.getChatRoomWithUser(
        userId: currentStoryMediaModel.value!.userId,
        callback: (room) {
          FocusScope.of(Get.context!).requestFocus(FocusNode());
          showHideEmoticons(false);

          StoryModel storyToSend = StoryModel(
              id: story.id,
              name: story.name,
              userName: story.userName,
              userImage: story.userImage,
              media: [currentStoryMediaModel.value!]);

          _chatDetailController.sendStoryReactionReplyMessage(
              emoji: emoji, story: storyToSend, room: room);
        });
  }

  sendStoryAsMessage(int userId, StoryModel story) {
    _chatDetailController.getChatRoomWithUser(
        userId: userId,
        callback: (room) {
          FocusScope.of(Get.context!).requestFocus(FocusNode());
          showHideEmoticons(false);
          StoryModel storyToSend = StoryModel(
              id: story.id,
              name: story.name,
              userName: story.userName,
              userImage: story.userImage,
              media: [currentStoryMediaModel.value!]);
          _chatDetailController.sendStoryMessage(
              story: storyToSend, room: room);
        });
  }
}
