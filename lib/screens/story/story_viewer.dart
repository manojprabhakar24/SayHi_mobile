import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/story_imports.dart';
import 'package:foap/screens/story/story_reaction_options.dart';
import 'package:foap/screens/story/story_view_users.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';
import 'package:story_view/utils.dart';

import '../profile/my_profile.dart';
import '../profile/other_user_profile.dart';
import '../settings_menu/settings_controller.dart';

class StoryViewer extends StatefulWidget {
  final StoryModel story;
  final VoidCallback storyDeleted;

  const StoryViewer({Key? key, required this.story, required this.storyDeleted})
      : super(key: key);

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer> {
  final controller = StoryController();
  final AppStoryController storyController = Get.find();
  final SettingsController settingsController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();
  final TextEditingController replyController = TextEditingController();

  @override
  void initState() {
    storyController.showHideEmoticons(false);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      resizeToAvoidBottomInset: false,
      body: replyWidget(),
    );
  }

  Widget storyWidget() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              StoryView(
                  storyItems: [
                    for (StoryMediaModel media in widget.story.media.reversed)
                      media.isVideoPost() == true
                          ? StoryItem.pageVideo(
                              media.video!,
                              controller: controller,
                              duration: media.videoDuration != null
                                  ? Duration(
                                      seconds: media.videoDuration! ~/ 1000)
                                  : null,
                              key: Key(media.id.toString()),
                            )
                          : StoryItem.pageImage(
                              key: Key(media.id.toString()),
                              url: media.image!,
                              controller: controller,
                            ),
                  ],
                  controller: controller,
                  // pass controller here too
                  repeat: true,
                  // should the stories be slid forever
                  onStoryShow: (s) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      storyController.setCurrentStoryMedia(widget.story.media
                          .where((element) =>
                              Key(element.id.toString()) == s.view.key)
                          .first);
                    });
                  },
                  onComplete: () {
                    Get.back();
                  },
                  onVerticalSwipeComplete: (direction) {
                    if (direction == Direction.down) {
                      Get.back();
                    }
                  } // To disable vertical swipe gestures, ignore this parameter.
                  ),
              Positioned(top: 70, left: 20, right: 0, child: userProfileView()),
              Obx(() => (storyController.currentStoryMediaModel.value?.userId ==
                      _userProfileManager.user.value!.id)
                  ? Positioned(
                      bottom: 20, left: 0, right: 0, child: storyViewCounter())
                  : Container()),
              Obx(() => (storyController.showEmoticons.value == true)
                  ? Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      top: 0,
                      child: StoryReactionOptions(
                        reactionCallbackHandler: (emoji) {
                          storyController.sendReactionMessage(emoji);
                        },
                      ))
                  : Container()),
            ],
          ),
        ),
        // replyWidget()
      ],
    );
  }

  Widget replyWidget() {
    return FooterLayout(
      footer: KeyboardAttachable(
        child: Container(
          height: 80,
          color: AppColorConstants.cardColor.darken(),
          child: Row(
            children: [
              Expanded(
                child: AppTextField(
                  hintText: replyString.tr,
                  controller: replyController,
                  maxLength: 80,
                  onChanged: (value) {
                    storyController.showHideEmoticons(value.isEmpty);
                  },
                  focusStatusChangeHandler: (status) {
                    storyController.showHideEmoticons(status);
                    if (status == true) {
                      controller.pause();
                    } else {
                      FocusScope.of(context).requestFocus(FocusNode());
                      controller.play();
                    }
                  },
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              BodyLargeText(sendString.tr).ripple(() {
                storyController.sendTextMessage(replyController.text);
              }),
            ],
          ).p16,
        ),
      ),
      child: storyWidget(),
    );
  }

  Widget userProfileView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            AvatarView(
              url: widget.story.image,
              size: 30,
            ).rP8,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BodyMediumText(widget.story.userName,
                    weight: TextWeight.medium, color: Colors.white),
                Obx(() => storyController.currentStoryMediaModel.value != null
                    ? BodyMediumText(
                        storyController.currentStoryMediaModel.value!.createdAt,
                        color: Colors.white
                        // color: AppColorConstants.subHeadingTextColor,
                        )
                    : Container())
              ],
            ),
          ],
        ).ripple(() {
          int userId = widget.story.media.first.userId;
          if (userId == _userProfileManager.user.value!.id) {
            Get.to(() => const MyProfile(showBack: true));
          } else {
            Get.to(() => OtherUserProfile(
                  userId: userId,
                ));
          }
        }),
        const SizedBox(
          width: 50,
        ),
        if (widget.story.media.first.userId ==
            _userProfileManager.user.value!.id)
          SizedBox(
            height: 25,
            width: 40,
            child: ThemeIconWidget(
              ThemeIcon.more,
              color: Colors.white,
              size: 20,
            ).ripple(() {
              openActionPopup();
            }),
          ).rP25
      ],
    );
  }

  void openActionPopup() {
    controller.pause();

    showModalBottomSheet(
        context: context,
        builder: (context) => Container(
              color: AppColorConstants.cardColor,
              child: Wrap(
                children: [
                  ListTile(
                      title: Center(child: BodyLargeText(deleteStoryString.tr)),
                      onTap: () async {
                        Get.back();
                        controller.play();

                        storyController.deleteStory(() {
                          widget.storyDeleted();
                        });
                      }),
                  divider(),
                  ListTile(
                      title: Center(child: BodyLargeText(cancelString.tr)),
                      onTap: () {
                        controller.play();
                        Get.back();
                      }),
                ],
              ),
            )).then((value) {
      controller.play();
    });
  }

  Widget storyViewCounter() {
    return Obx(() => storyController.currentStoryMediaModel.value != null
        ? Column(
            children: [
              ThemeIconWidget(
                ThemeIcon.arrowUp,
                color: Colors.white,
              ),
              const SizedBox(
                height: 5,
              ),
              BodyLargeText(
                '${storyController.currentStoryMediaModel.value!.totalView}',
                color: Colors.white,
              ),
            ],
          ).ripple(() {
            controller.pause();
            Get.bottomSheet(StoryViewUsers()).then((value) {
              controller.play();
            });
          })
        : Container());
  }
}
