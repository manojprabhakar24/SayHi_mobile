import 'package:foap/api_handler/apis/post_api.dart';
import 'package:foap/api_handler/apis/users_api.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:share_plus/share_plus.dart';
import '../controllers/post/post_controller.dart';
import '../helper/enum_linking.dart';
import '../model/post_model.dart';

class PostCardController extends GetxController {
  final PostController postController = Get.find();
  RxMap<int, int> postScrollIndexMapping = <int, int>{}.obs;
  RxInt currentIndex = 0.obs;
  int currentPostId = 0;
  RxList<PostModel> likedPosts = <PostModel>[].obs;
  RxList<PostModel> savedPosts = <PostModel>[].obs;
  RxBool enableComments = true.obs;

  toggleEnableComments() {
    enableComments.value = !enableComments.value;
    update();
  }

  updateGallerySlider(int index, int postId) {
    postScrollIndexMapping[postId] = index;
    currentIndex.value = index;
    currentPostId = postId;
  }

  reportPost({required PostModel post, required VoidCallback callback}) {
    PostApi.reportPost(postId: post.id, resultCallback: callback);
  }

  deletePost({required PostModel post, required VoidCallback callback}) {
    PostApi.deletePost(postId: post.id, resultCallback: callback);
  }

  sharePost({required PostModel post}) {
    Share.share(post.shareLink);

    // downloadAndShareMedia(post);
  }

  void blockUser({required int userId, required VoidCallback callback}) {
    UsersApi.blockUser(userId: userId, resultCallback: callback);
  }

  void likeUnlikePost({
    required PostModel post,
  }) {
    post.isLike = !post.isLike;
    if (post.isLike) {
      likedPosts.add(post);
    } else {
      likedPosts.remove(post);
    }
    likedPosts.refresh();
    post.totalLike =
        post.isLike ? (post.totalLike) + 1 : (post.totalLike) - 1;

    PostApi.likeUnlikePost(like: post.isLike, postId: post.id);
  }

  void saveUnSavePost({
    required PostModel post,
  }) {
    post.isSaved = !post.isSaved;
    if (post.isSaved) {
      savedPosts.add(post);
    } else {
      savedPosts.remove(post);
    }
    savedPosts.refresh();

    PostApi.saveUnSavePost(save: post.isSaved, postId: post.id);
  }

  reSharePost(
      {required int postId,
      required String comment,
      required bool enableComments}) {
    Loader.show(status: loadingString.tr);
    PostApi.addPost(
        sharingPostId: postId,
        allowComments: enableComments,
        isPaidContent: false,
        postType: PostType.reshare,
        postContentType: PostContentType.text,
        gallery: [],
        title: comment,
        resultCallback: (value) {
          Loader.dismiss();
          update();
        });
  }

  postView(
      {required int postId,
      required ItemViewSource source,
      int? postPromotionId}) {
    PostApi.postView(
        postId: postId,
        sourceType: itemViewSourceToId(source),
        postPromotionId: postPromotionId);
  }
}
