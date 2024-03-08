import 'dart:io';
import 'package:camera/camera.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/club_imports.dart';
import '../../api_handler/apis/club_api.dart';
import '../../api_handler/apis/misc_api.dart';
import '../../model/category_model.dart';

class CreateClubController extends GetxController {
  final ClubsController _clubsController = Get.find();

  RxInt privacyType = 1.obs;

  RxBool enableChat = false.obs;
  Rx<CategoryModel?> category = Rx<CategoryModel?>(null);
  Rx<File?> imageFile = Rx<File?>(null);

  clear() {
    privacyType.value = 1;
    enableChat.value = false;
    imageFile.value = null;
    category.value = null;
  }

  privacyTypeChange(int type) {
    privacyType.value = type;
  }

  toggleChatGroup() {
    enableChat.value = !enableChat.value;
  }

  createClub(ClubModel club, Function(int) callback) async {
    Loader.show(status: loadingString.tr);

    await MiscApi.uploadFile(imageFile.value!.path,
        mediaType: GalleryMediaType.photo,
        type: UploadMediaType.club, resultCallback: (filename, filepath) {
      ClubApi.createClub(
          categoryId: club.categoryId!,
          isOnRequestType: privacyType.value == 3 ? 1 : 0,
          privacyMode: privacyType.value == 2 ? 2 : 1,
          enableChatRoom: club.enableChat!,
          name: club.name!,
          image: filename,
          description: club.desc!,
          resultCallback: (clubId) {
            Loader.dismiss();
            _clubsController.refreshClubs();
            callback(clubId);
            clear();
          });
    });
  }

  void editClubImageAction(XFile pickedFile) async {
    imageFile.value = File(pickedFile.path);
    imageFile.refresh();
  }

  updateClubImage(ClubModel club, Function(ClubModel) callback) async {
    Loader.show(status: loadingString.tr);

    await MiscApi.uploadFile(imageFile.value!.path,
        mediaType: GalleryMediaType.photo,
        type: UploadMediaType.club, resultCallback: (fileName, filePath) {
      club.imageName = fileName;
      club.image = filePath;

      updateClubInfo(
          club: club,
          callback: () {
            callback(club);
          });
    });
  }

  updateClubInfo({required ClubModel club, required VoidCallback callback}) {
    Loader.show(status: loadingString.tr);

    ClubApi.updateClub(
        clubId: club.id!,
        categoryId: club.categoryId!,
        privacyMode: 1,
        name: club.name!,
        image: club.imageName!,
        description: club.desc!);
    Loader.dismiss();
    Get.back();
    callback();
  }
}
