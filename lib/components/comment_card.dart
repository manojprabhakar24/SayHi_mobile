import 'package:detectable_text_field/detector/sample_regular_expressions.dart';
import 'package:detectable_text_field/widgets/detectable_text.dart';
import 'package:foap/api_handler/apis/users_api.dart';
import 'package:foap/helper/imports/common_import.dart';
import '../model/comment_model.dart';
import '../model/post_gallery.dart';
import '../model/search_model.dart';
import '../screens/dashboard/posts.dart';
import '../screens/home_feed/post_media_full_screen.dart';
import '../screens/profile/other_user_profile.dart';

class CommentTile extends StatelessWidget {
  final CommentModel model;
  final Function(CommentModel) replyActionHandler;
  final Function(CommentModel) deleteActionHandler;
  final Function(CommentModel) favActionHandler;
  final Function(CommentModel) reportActionHandler;
  final Function(CommentModel) loadMoreChildCommentsActionHandler;

  const CommentTile({
    Key? key,
    required this.model,
    required this.replyActionHandler,
    required this.deleteActionHandler,
    required this.favActionHandler,
    required this.reportActionHandler,
    required this.loadMoreChildCommentsActionHandler,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AvatarView(
                url: model.userPicture,
                name: model.user!.userName.isEmpty
                    ? model.user!.name
                    : model.user!.userName,
                size: model.level == 1 ? 35 : 20,
              ).ripple(() {
                Get.to(() =>
                    OtherUserProfile(userId: model.userId, user: model.user));
              }),
              const SizedBox(width: 10),
              Flexible(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      BodyMediumText(
                        model.userName,
                        weight: TextWeight.medium,
                      ).rP8,
                      if (model.user?.isVerified == true) verifiedUserTag().rP4,
                      BodySmallText(
                        model.commentTime,
                        weight: TextWeight.semiBold,
                        color: AppColorConstants.subHeadingTextColor
                            .withOpacity(0.5),
                      ),
                      const Spacer(),
                      ThemeIconWidget(
                        model.isFavourite ? ThemeIcon.favFilled : ThemeIcon.fav,
                        color: model.isFavourite
                            ? AppColorConstants.red
                            : AppColorConstants.iconColor,
                      ).ripple(() {
                        favActionHandler(model);
                      }),
                    ],
                  ).ripple(() {
                    Get.to(() => OtherUserProfile(
                        userId: model.userId, user: model.user));
                  }),
                  model.type == CommentType.text
                      ? showCommentText()
                      : showCommentMedia(),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      if (model.canReply)
                        BodySmallText(
                          replyString.tr,
                          weight: TextWeight.semiBold,
                        ).rp(20).ripple(() {
                          replyActionHandler(model);
                        }),
                      if (model.user?.isMe == true)
                        BodySmallText(
                          deleteString.tr,
                          weight: TextWeight.semiBold,
                          color: Colors.red,
                        ).ripple(() {
                          deleteActionHandler(model);
                        }),
                      if (model.user?.isMe == false)
                        BodySmallText(
                          reportString.tr,
                          weight: TextWeight.semiBold,
                          color: Colors.red,
                        ).ripple(() {
                          reportActionHandler(model);
                        }),
                    ],
                  )
                ],
              ))
            ],
          ),
          Column(
            children: [
              for (CommentModel comment in model.replies)
                CommentTile(
                    model: comment,
                    replyActionHandler: (comment) {
                      reportActionHandler(comment);
                    },
                    deleteActionHandler: (comment) {
                      deleteActionHandler(comment);
                    },
                    favActionHandler: (comment) {
                      favActionHandler(comment);
                    },
                    reportActionHandler: (comment) {
                      reportActionHandler(comment);
                    },
                    loadMoreChildCommentsActionHandler: (comment) {
                      loadMoreChildCommentsActionHandler(comment);
                    }).setPadding(left: 50, top: 15)
            ],
          ),
          if (model.pendingReplies > 0)
            BodySmallText(
              '${viewString.tr} ${model.pendingReplies} ${moreRepliesString.tr}',
              weight: TextWeight.bold,
              color: AppColorConstants.subHeadingTextColor,
            ).setPadding(top: 25, left: 50).ripple(() {
              loadMoreChildCommentsActionHandler(model);
            }),
        ]);
  }

  showCommentText() {
    return DetectableText(
      text: model.comment,
      detectionRegExp: RegExp(
        "(?!\\n)(?:^|\\s)([#@]([$detectionContentLetters]+))|$urlRegexContent",
        multiLine: true,
      ),
      detectedStyle: TextStyle(
          fontSize: FontSizes.b3,
          fontWeight: TextWeight.semiBold,
          color: AppColorConstants.mainTextColor),
      basicStyle: TextStyle(
          fontSize: FontSizes.b3, color: AppColorConstants.mainTextColor),
      onTap: (tappedText) {
        commentTextTapHandler(text: tappedText);
      },
    );
  }

  showCommentMedia() {
    return CachedNetworkImage(
      imageUrl: model.filename,
      height: 150,
      width: 150,
      fit: BoxFit.cover,
    ).round(10).tP16.ripple(() {
      Navigator.push(
        Get.context!,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) =>
              PostMediaFullScreen(gallery: [
            PostGallery(
              id: 0,
              postId: 0,
              fileName: "",
              filePath: model.filename,
              height: 0,
              width: 0,
              mediaType: 1, //  image=1, video=2, audio=3
            )
          ]),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    });
  }

  commentTextTapHandler({required String text}) {
    if (text.startsWith('#')) {
      Get.to(() => Posts(
            hashTag: text.replaceAll('#', ''),
            title: text,
          ));
    } else {
      String userTag = text.replaceAll('@', '');

      UserSearchModel searchModel = UserSearchModel();
      searchModel.isExactMatch = 1;
      searchModel.searchText = userTag;
      UsersApi.searchUsers(
          searchModel: searchModel,
          page: 1,
          resultCallback: (result, metadata) {
            if (result.isNotEmpty) {
              Get.to(() => OtherUserProfile(
                  userId: result.first.id, user: result.first));
            }
          });
    }
  }
}
