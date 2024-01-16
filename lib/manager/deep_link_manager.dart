import 'package:app_links/app_links.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/post_imports.dart';
import 'package:get/get.dart';

class DeepLinkManager {
  static init() {
    final appLinks = AppLinks();

// Subscribe to all events when app is started.
// (Use allStringLinkStream to get it as [String])
    appLinks.allUriLinkStream.listen((uri) {
      // Do something (navigation, ...)
      print('allUriLinkStream $uri');
      handleLink(uri);
    });
  }

  static handleLink(Uri uri) {
    String? postUniqueId = uri.queryParameters['pid'];

    if (postUniqueId != null) {
      Get.to(() => SinglePostDetail(postUniqueId: postUniqueId));
    }
  }
}
