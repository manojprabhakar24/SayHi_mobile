import 'dart:ui';
import 'package:foap/api_handler/api_wrapper.dart';
import '../../model/highlights.dart';

class HighlightsApi {
  static createHighlights(
      {required String name,
      required String image,
      required String stories,
      required VoidCallback resultCallback}) async {
    var url = NetworkConstantsUtil.addHighlight;

    var param = {
      "name": name,
      "image": image,
      "story_ids": stories,
    };

    await ApiWrapper().postApi(url: url, param: param).then((result) {
      if (result?.success == true) {
        resultCallback();
      }
    });
  }

  static addSToryToHighlight({
    required int collectionId,
    required int postId,
  }) async {
    var url = NetworkConstantsUtil.addStoryToHighlight;

    var param = {
      "collection_id": collectionId.toString(),
      "post_id": postId.toString(),
    };

    await ApiWrapper().postApi(url: url, param: param).then((result) {});
  }

  static getHighlights(
      {required int userId,
      required Function(List<HighlightsModel>) resultCallback}) async {
    var url = NetworkConstantsUtil.highlights + userId.toString();

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['highlight'];
        List<HighlightsModel> highlights = List<HighlightsModel>.from(
            items.map((x) => HighlightsModel.fromJson(x)));
        highlights.removeWhere((element) => element.medias.isEmpty);
        resultCallback(highlights);
      }
    });
  }

  static Future<void> deleteStoryFromHighlights(int id) async {
    var url = NetworkConstantsUtil.removeStoryFromHighlight;

    var param = {
      "id": id.toString(),
    };

    await ApiWrapper().postApi(url: url, param: param).then((result) {});
    return;
  }

  static Future<void> deleteHighlight(int id) async {
    var url = '${NetworkConstantsUtil.deleteHighlight}$id';

    await ApiWrapper().deleteApi(url: url).then((result) {});
    return;
  }
}
