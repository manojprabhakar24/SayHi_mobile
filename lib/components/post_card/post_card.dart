import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:foap/components/post_card/post_user_info.dart';
import 'package:foap/components/post_card/reshare_post.dart';
import 'package:foap/components/post_card/reshared_post_card.dart';
import 'package:foap/components/post_card_controller.dart';
import 'package:foap/components/post_card/post_text_widget.dart';
import 'package:foap/controllers/post/post_gift_controller.dart';
import 'package:foap/components/video_widget.dart';
import 'package:foap/controllers/profile/profile_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../controllers/chat_and_call/chat_detail_controller.dart';
import '../../controllers/chat_and_call/select_user_for_chat_controller.dart';
import '../../controllers/home/home_controller.dart';
import '../../controllers/post/comments_controller.dart';
import '../../model/post_gallery.dart';
import '../../model/post_model.dart';
import '../../screens/chat/select_users.dart';
import '../../screens/club/club_detail.dart';
import '../../screens/home_feed/comments_screen.dart';
import '../../screens/home_feed/post_media_full_screen.dart';
import '../../screens/live/gifts_list.dart';
import '../../screens/post/received_gifts.dart';
import '../../screens/post/view_post_insight.dart';
import '../../screens/profile/my_profile.dart';
import '../../screens/profile/other_user_profile.dart';
import '../audio_tile.dart';

class PostMediaTile extends StatelessWidget {
  final PostCardController postCardController = Get.find();
  final HomeController homeController = Get.find();

  final PostModel model;

  PostMediaTile({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return mediaTile();
  }

  Widget mediaTile() {
    if (model.gallery.length > 1) {
      return SizedBox(
        height: 350,
        child: Stack(
          children: [
            CarouselSlider(
              items: mediaList(),
              options: CarouselOptions(
                aspectRatio: 1,
                enlargeCenterPage: false,
                enableInfiniteScroll: false,
                height: double.infinity,
                viewportFraction: 1,
                onPageChanged: (index, reason) {
                  postCardController.updateGallerySlider(index, model.id);
                },
              ),
            ),
            Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.center,
                  child: Obx(
                    () {
                      return DotsIndicator(
                        dotsCount: model.gallery.length,
                        position: (postCardController
                                .postScrollIndexMapping[model.id] ??
                            0),
                        decorator: DotsDecorator(
                            activeColor: Theme.of(Get.context!).primaryColor),
                      );
                    },
                  ),
                ))
          ],
        ),
      );
    } else {
      return model.gallery.first.isVideoPost == true
          ? videoPostTile(model.gallery.first)
          : model.gallery.first.isAudioPost
              ? AudioPostTile(
                  post: model,
                )
              : SizedBox(
                  height: 350, child: photoPostTile(model.gallery.first));
    }
  }

  List<Widget> mediaList() {
    return model.gallery.map((item) {
      if (item.isVideoPost == true) {
        return videoPostTile(item);
      } else {
        return photoPostTile(item);
      }
    }).toList();
  }

  Widget videoPostTile(PostGallery media) {
    return VisibilityDetector(
      key: Key(media.id.toString()),
      onVisibilityChanged: (visibilityInfo) {
        var visiblePercentage = visibilityInfo.visibleFraction * 100;
        // if (visiblePercentage > 80) {
        homeController.setCurrentVisibleVideo(
            media: media, visibility: visiblePercentage);
        // }
      },
      child: Obx(() => VideoPostTile(
            url: media.filePath,
            isLocalFile: false,
            play: homeController.currentVisibleVideoId.value == media.id,
          )),
    );
  }

  Widget photoPostTile(PostGallery media) {
    return CachedNetworkImage(
      imageUrl: media.filePath,
      fit: BoxFit.cover,
      width: Get.width,
      placeholder: (context, url) => AppUtil.addProgressIndicator(size: 100),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }
}

class PostContent extends StatelessWidget {
  final PostModel model;
  final PostCardController postCardController = Get.find();
  final ProfileController _profileController = Get.find();
  final FlareControls flareControls = FlareControls();
  final VoidCallback removePostHandler;
  final VoidCallback blockUserHandler;

  PostContent(
      {Key? key,
      required this.model,
      required this.removePostHandler,
      required this.blockUserHandler})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: PostUserInfo(post: model)),
            SizedBox(
              height: 20,
              width: 20,
              child: ThemeIconWidget(
                ThemeIcon.more,
                color: AppColorConstants.iconColor,
                size: 15,
              ),
            ).borderWithRadius(value: 1, radius: 15).ripple(() {
              openActionPopup();
            })
          ],
        ).setPadding(
            left: DesignConstants.horizontalPadding,
            right: DesignConstants.horizontalPadding,
            bottom: 16),
        GestureDetector(
            onDoubleTap: () {
              //   widget.model.isLike = !widget.model.isLike;
              postCardController.likeUnlikePost(post: model);
              // widget.likeTapHandler();
              flareControls.play("like");
            },
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      PostMediaFullScreen(gallery: model.gallery),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (model.title.isNotEmpty)
                      RichTextPostTitle(model: model).setPadding(
                          left: DesignConstants.horizontalPadding,
                          right: DesignConstants.horizontalPadding,
                          bottom: 25),
                    if (model.gallery.isNotEmpty) PostMediaTile(model: model),
                    if (model.sharedPost != null)
                      ResharedPostCard(model: model.sharedPost!)
                          .setPadding(left: 57, right: 5, top: 5, bottom: 15),
                  ],
                ),
                Obx(() => Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: Center(
                            child: SizedBox(
                              width: 80,
                              height: 80,
                              child: FlareActor(
                                'assets/like.flr',
                                controller: flareControls,
                                animation: 'idle',
                                color: postCardController.likedPosts
                                            .contains(model) ||
                                        model.isLike
                                    ? Colors.red
                                    : Colors.white,
                              ),
                            ),
                          )),
                    ))
              ],
            )),
        // const SizedBox(
        //   height: 16,
        // ),
      ],
    );
  }

  void openActionPopup() {
    Get.bottomSheet(Container(
      color: AppColorConstants.cardColor.darken(),
      child: model.user.isMe
          ? Wrap(
              children: [
                ListTile(
                    title: Center(
                        child: Heading6Text(
                      deletePostString.tr,
                      weight: TextWeight.bold,
                    )),
                    onTap: () async {
                      Get.back();
                      postCardController.deletePost(
                          post: model,
                          callback: () {
                            removePostHandler();
                          });
                    }),
                divider(),
                ListTile(
                    title: Center(
                        child: Heading6Text(
                      shareString.tr,
                      weight: TextWeight.bold,
                    )),
                    onTap: () async {
                      Get.back();
                      postCardController.sharePost(
                        post: model,
                      );
                    }),
                divider(),
                ListTile(
                    title: Center(child: BodyLargeText(cancelString.tr)),
                    onTap: () => Get.back()),
                const SizedBox(
                  height: 25,
                )
              ],
            )
          : Wrap(
              children: [
                ListTile(
                    title: Center(
                        child: Heading6Text(
                      reportString.tr,
                      weight: TextWeight.bold,
                    )),
                    onTap: () async {
                      Get.back();

                      AppUtil.showConfirmationAlert(
                          title: reportString.tr,
                          subTitle: areYouSureToReportPostString.tr,
                          okHandler: () {
                            postCardController.reportPost(
                                post: model,
                                callback: () {
                                  removePostHandler();
                                });
                          });
                    }),
                divider(),
                ListTile(
                    title: Center(
                        child: Heading6Text(blockUserString.tr,
                            weight: TextWeight.bold)),
                    onTap: () async {
                      Get.back();
                      AppUtil.showConfirmationAlert(
                          title: blockString.tr,
                          subTitle: areYouSureToBlockUserString.tr,
                          okHandler: () {
                            postCardController.blockUser(
                                userId: model.user.id,
                                callback: () {
                                  blockUserHandler();
                                });
                          });
                    }),
                divider(),
                ListTile(
                    title: Center(
                        child: Heading6Text(
                      shareString.tr,
                      weight: TextWeight.bold,
                    )),
                    onTap: () async {
                      Get.back();
                      postCardController.sharePost(
                        post: model,
                      );
                    }),
                divider(),
                ListTile(
                    title: Center(
                      child: Heading6Text(
                        cancelString.tr,
                        weight: TextWeight.regular,
                        color: AppColorConstants.red,
                      ),
                    ),
                    onTap: () => Get.back()),
                const SizedBox(
                  height: 25,
                )
              ],
            ),
    ).round(40));
  }

  void openProfile() async {
    if (model.user.isMe) {
      Get.to(() => const MyProfile(
            showBack: true,
          ));
    } else {
      _profileController.otherUserProfileView(refId: model.id, sourceType: 1);
      Get.to(() => OtherUserProfile(userId: model.user.id));
    }
  }

  void openClubDetail() async {
    Get.to(() => ClubDetail(
        club: model.club!,
        needRefreshCallback: () {},
        deleteCallback: (club) {}));
  }
}

class PostCard extends StatefulWidget {
  final PostModel model;

  final VoidCallback removePostHandler;
  final VoidCallback blockUserHandler;

  const PostCard({
    Key? key,
    required this.model,
    required this.removePostHandler,
    required this.blockUserHandler,
  }) : super(key: key);

  @override
  PostCardState createState() => PostCardState();
}

class PostCardState extends State<PostCard> {
  final HomeController homeController = Get.find();
  final PostCardController postCardController = Get.find();
  final ChatDetailController chatDetailController = Get.find();
  final SelectUserForChatController selectUserForChatController =
      SelectUserForChatController();
  final PostGiftController _postGiftController = Get.find();

  TextEditingController commentInputField = TextEditingController();
  final CommentsController _commentsController = CommentsController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      PostContent(
        model: widget.model,
        removePostHandler: widget.removePostHandler,
        blockUserHandler: widget.blockUserHandler,
      ),
      if (widget.model.isMyPost)
        Container(
          color: AppColorConstants.cardColor.darken(),
          height: 50,
          width: double.infinity,
          child: Align(
            alignment: Alignment.centerLeft,
            child: BodyLargeText(
              viewInsightsString.tr,
              weight: TextWeight.semiBold,
            ).lp(DesignConstants.horizontalPadding),
          ),
        ).ripple(() {
          Get.to(() => ViewPostInsights(post: widget.model));
        }),
      const SizedBox(
        height: 20,
      ),
      commentsCountWidget().hp(DesignConstants.horizontalPadding),
      divider(height: 0.8).vP16,
      commentAndLikeWidget().hp(DesignConstants.horizontalPadding),
    ]).vP16;
  }

  Widget viewGifts() {
    return Column(
      children: [
        widget.model.isMyPost
            ? BodyLargeText(
                viewGiftString.tr,
                // weight: TextWeight.regular,
              ).ripple(() {
                showModalBottomSheet<void>(
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (context) {
                      _postGiftController
                          .fetchReceivedTimelineStickerGift(widget.model.id);
                      return FractionallySizedBox(
                          heightFactor: 1.5,
                          child: ReceivedGiftsList(
                            postId: widget.model.id,
                          ));
                    });
              })
            : Container(),
      ],
    ).setPadding(left: DesignConstants.horizontalPadding);
  }

  Widget commentsCountWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Obx(() {
          int totalLikes = 0;
          if (postCardController.likedPosts.contains(widget.model)) {
            PostModel post = postCardController.likedPosts
                .where((e) => e.id == widget.model.id)
                .first;
            totalLikes = post.totalLike;
          } else {
            totalLikes = widget.model.totalLike;
          }
          return BodyMediumText(
            '$totalLikes $likesString',
            // weight: TextWeight.semiBold,
            color: AppColorConstants.grayscale700,
          );
        }),
        BodyMediumText(
          '${widget.model.totalComment} $commentsString',
          // weight: TextWeight.semiBold,
          color: AppColorConstants.grayscale700,
        ),
        BodyMediumText(
          '${widget.model.totalView} $viewsString',
          // weight: TextWeight.semiBold,
          color: AppColorConstants.grayscale700,
        ),
        BodyMediumText(
          '${widget.model.totalShare} $sharesString',
          // weight: TextWeight.semiBold,
          color: AppColorConstants.grayscale700,
        ),
      ],
    );
  }

  Widget commentAndLikeWidget() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(
        children: [
          Obx(() => ThemeIconWidget(
                postCardController.likedPosts.contains(widget.model) ||
                        widget.model.isLike
                    ? ThemeIcon.favFilled
                    : ThemeIcon.fav,
                color: postCardController.likedPosts.contains(widget.model) ||
                        widget.model.isLike
                    ? AppColorConstants.red
                    : AppColorConstants.iconColor,
                size: 15,
              )),
          const SizedBox(
            width: 10,
          ),
          BodyMediumText(likeString)
        ],
      ).ripple(() {
        postCardController.likeUnlikePost(
          post: widget.model,
        );
      }),

      Row(
        children: [
          const ThemeIconWidget(
            ThemeIcon.message,
            size: 15,
          ),
          const SizedBox(
            width: 10,
          ),
          BodyMediumText(commentString)
        ],
      ).ripple(() {
        openComments();
      }),

      Row(
        children: [
          const ThemeIconWidget(
            ThemeIcon.share,
            size: 15,
          ),
          const SizedBox(
            width: 10,
          ),
          BodyMediumText(
            shareString,
          )
        ],
      ).ripple(() {
        showModalBottomSheet(
            backgroundColor: Colors.transparent,
            context: context,
            isScrollControlled: true,
            builder: (context) =>
                FractionallySizedBox(heightFactor: 0.8, child: sharePost()));
      }),
      if (!widget.model.isMyPost)
        Row(
          children: [
            const ThemeIconWidget(
              ThemeIcon.gift,
              size: 15,
            ),
            const SizedBox(
              width: 10,
            ),
            BodyMediumText(giftString)
          ],
        ).ripple(() {
          showModalBottomSheet<void>(
              context: context,
              builder: (BuildContext context) {
                return FractionallySizedBox(
                    heightFactor: 0.8,
                    child: GiftsPageView(giftSelectedCompletion: (gift) {
                      Get.back();
                      homeController.sendPostGift(
                          gift, widget.model.user.id, widget.model.id);
                      Get.back();
                    }));
              });
        })

      // const Spacer(),
      // viewGifts(),
    ]);
  }

  void addNewMessage() {
    if (commentInputField.text.trim().isNotEmpty) {
      final filter = ProfanityFilter();
      bool hasProfanity = filter.hasProfanity(commentInputField.text);
      if (hasProfanity) {
        AppUtil.showToast(message: notAllowedMessageString.tr, isSuccess: true);
        return;
      }

      _commentsController.postCommentsApiCall(
          comment: commentInputField.text.trim(),
          postId: widget.model.id,
          commentPosted: () {
            setState(() {
              widget.model.totalComment += 1;
            });
          });
      commentInputField.text = '';
    }
  }

  void openComments() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: Get.context!,
        isScrollControlled: true,
        builder: (context) => FractionallySizedBox(
            heightFactor: 0.8,
            child: CommentsScreen(
              isPopup: true,
              model: widget.model,
              commentPostedCallback: () {
                setState(() {
                  widget.model.totalComment += 1;
                });
              },
            ).round(40)));
  }

  Widget sharePost() {
    return Container(
      color: AppColorConstants.cardColor,
      child: Column(
        children: [
          BodyLargeText(
            shareToFeed.tr,
            weight: TextWeight.semiBold,
          ),
          const SizedBox(
            height: 20,
          ),
          ReSharePost(
            post: widget.model,
          ),
          divider(height: 0.5).vP16,
          BodyLargeText(
            sendSeparatelyToFriends.tr,
            weight: TextWeight.semiBold,
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(child: SelectFollowingUserForMessageSending(
              // post: widget.model,
              sendToUserCallback: (user) {
            selectUserForChatController.sendMessage(
                toUser: user, post: widget.model);
          }))
        ],
      ).p(DesignConstants.horizontalPadding),
    ).topRounded(40);
  }
}
