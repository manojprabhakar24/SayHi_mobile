import 'package:foap/helper/file_extension.dart';
import 'package:foap/helper/imports/chat_imports.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/story_imports.dart';
import 'package:foap/screens/home_feed/story_uploader.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_polls/flutter_polls.dart';
import '../../components/post_card/post_card.dart';
import '../../controllers/post/add_post_controller.dart';
import '../../controllers/live/agora_live_controller.dart';
import '../../controllers/home/home_controller.dart';
import '../../model/call_model.dart';
import '../../model/post_model.dart';
import '../dashboard/dashboard_screen.dart';
import '../post/add_post_screen.dart';
import '../settings_menu/settings_controller.dart';


class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({Key? key}) : super(key: key);

  @override
  HomeFeedState createState() => HomeFeedState();
}

class HomeFeedState extends State<HomeFeedScreen> {
  final HomeController _homeController = Get.find();
  final AddPostController _addPostController = Get.find();
  final AgoraLiveController _agoraLiveController = Get.find();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final SettingsController _settingsController = Get.find();
  final DashboardController _dashboardController = Get.find();
  final _controller = ScrollController();

  String? selectedValue;
  int pollFrequencyIndex = 10;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();
      _homeController.loadQuickLinksAccordingToSettings();
    });
  }

  loadMore() {
    loadPosts();
  }

  refreshData() {
    _homeController.clearPosts();
    loadData();
  }

  @override
  void dispose() {
    super.dispose();
    _homeController.clear();
    _homeController.closeQuickLinks();
  }

  loadPosts() {
    _homeController.getPosts(callback: () {
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
    });

    _homeController.getPromotionalPosts();
  }

  void loadData() {
    loadPosts();
    _homeController.getPolls();
    _homeController.getStories();
  }

  @override
  void didUpdateWidget(covariant HomeFeedScreen oldWidget) {
    loadData();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // menuView(),
            const SizedBox(
              height: 55,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Heading3Text(
                  AppConfigConstants.appName,
                  weight: TextWeight.semiBold,
                  color: AppColorConstants.themeColor,
                ),
                const Spacer(),
                const SizedBox(
                    height: 35,
                    width: 35,
                    child: ThemeIconWidget(
                      ThemeIcon.plus,
                      size: 25,
                    )).ripple(() {
                  Future.delayed(
                    Duration.zero,
                    () => showGeneralDialog(
                        context: context,
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const AddPostScreen(
                              postType: PostType.basic,
                            )),
                  );
                }),
                const SizedBox(
                  width: 20,
                ),
                SizedBox(
                  height: 35,
                  width: 35,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const ThemeIconWidget(
                        ThemeIcon.chat,
                        size: 25,
                      ).ripple(() {
                        Get.to(() => const ChatHistory());
                      }),
                      Obx(() => _dashboardController.unreadMsgCount.value == 0
                          ? Container()
                          : Positioned(
                              top: 0,
                              right: 5,
                              child: Container(
                                color: AppColorConstants.red,
                                height: 10,
                                width: 10,
                              ).circular,
                            ))
                    ],
                  ),
                ),
              ],
            ).hp(20),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: postsView(),
            ),
          ],
        ));
  }

  Widget postingView() {
    return Obx(() => _addPostController.isPosting.value
        ? Container(
            height: 55,
            color: AppColorConstants.cardColor,
            child: Row(
              children: [
                _addPostController.postingMedia.isNotEmpty &&
                        _addPostController.postingMedia.first.mediaType !=
                            GalleryMediaType.gif
                    ? _addPostController.postingMedia.first.thumbnail != null
                        ? Image.memory(
                            _addPostController.postingMedia.first.thumbnail!,
                            fit: BoxFit.cover,
                            width: 40,
                            height: 40,
                          ).round(5)
                        : _addPostController.postingMedia.first.mediaType ==
                                GalleryMediaType.photo
                            ? Image.file(
                                _addPostController.postingMedia.first.file!,
                                fit: BoxFit.cover,
                                width: 40,
                                height: 40,
                              ).round(5)
                            // : BodyLargeText(_addPostController.postingTitle)
                            : Container()
                    // : BodyLargeText(_addPostController.postingTitle),
                    : Container(),
                const SizedBox(
                  width: 10,
                ),
                Heading5Text(
                  _addPostController.isErrorInPosting.value
                      ? postFailedString.tr
                      : postingString.tr,
                ),
                const Spacer(),
                _addPostController.isErrorInPosting.value
                    ? Row(
                        children: [
                          Heading5Text(
                            discardString.tr,
                            weight: TextWeight.medium,
                          ).ripple(() {
                            _addPostController.discardFailedPost();
                          }),
                          const SizedBox(
                            width: 20,
                          ),
                          Heading5Text(
                            retryString.tr,
                            weight: TextWeight.medium,
                          ).ripple(() {
                            _addPostController.retryPublish();
                          }),
                        ],
                      )
                    : Container()
              ],
            ).hP8,
          ).backgroundCard(radius: 10).bp(20)
        : Container());
  }

  Widget storiesView() {
    return Container(
      height: storyCircleSize + 30 + 2 * DesignConstants.horizontalPadding,
      color: AppColorConstants.themeColor.withOpacity(0.05),
      child: GetBuilder<HomeController>(
          init: _homeController,
          builder: (ctx) {
            return StoryUpdatesBar(
              stories: _homeController.stories,
              liveUsers: _homeController.liveUsers,
              addStoryCallback: () {
                openStoryUploader();
              },
              viewStoryCallback: (story) {
                Get.to(() => StoryViewer(
                      story: story,
                      storyDeleted: () {
                        _homeController.getStories();
                      },
                    ));
              },
              joinLiveUserCallback: (user) {
                Live live = Live(
                    channelName: user.liveCallDetail!.channelName,
                    // isHosting: false,
                    mainHostUserDetail: user,
                    // battleUsers: [],
                    token: user.liveCallDetail!.token,
                    id: user.liveCallDetail!.id);
                _agoraLiveController.joinAsAudience(
                  live: live,
                );
              },
            ).p(DesignConstants.horizontalPadding);
          }),
    ).round(20).hp(DesignConstants.horizontalPadding);
  }

  postsView() {
    return Obx(() {
      return ListView.separated(
              controller: _controller,
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: _homeController.posts.length + 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Obx(() =>
                      _homeController.isRefreshingStories.value == true
                          ? const StoryAndHighlightsShimmer()
                          : storiesView());
                } else if (index == 1) {
                  return postingView().hP16;
                } else {
                  PostModel model = _homeController.posts[index - 2];
                  return PostCard(
                    model: model,
                    removePostHandler: () {
                      _homeController.removePostFromList(model);
                    },
                    blockUserHandler: () {
                      _homeController.removeUsersAllPostFromList(model);
                    },
                  );
                }
              },
              separatorBuilder: (context, index) {
                int separatorIndex = index - 2;
                if (_homeController.positions.contains(separatorIndex)) {
                  int positionIndex =
                      _homeController.positions.indexOf(separatorIndex);
                  return PostCard(
                    model: _homeController.sponsoredPosts[positionIndex],
                    removePostHandler: () {
                      _homeController.removePostFromList(
                          _homeController.sponsoredPosts[positionIndex]);
                    },
                    blockUserHandler: () {
                      _homeController.removeUsersAllPostFromList(
                          _homeController.sponsoredPosts[positionIndex]);
                    },
                  );
                } else {
                  if (_settingsController.setting.value?.enablePolls == true) {
                    return polls(index);
                  } else {
                    if (index == 1) {
                      return divider(height: 0.2).vP16;
                    }
                    return const SizedBox(
                      height: 0,
                    );
                  }
                }
              })
          .addPullToRefresh(
              refreshController: _refreshController,
              enablePullUp: false,
              onRefresh: refreshData,
              onLoading: () {},
              enablePullDown: true);
    });
  }

  polls(int index) {
    int postIndex = index > 1 ? index - 2 : 0;
    if (postIndex % pollFrequencyIndex == 0 && postIndex != 0) {
      int pollIndex = (postIndex ~/ pollFrequencyIndex) - 1;
      if (_homeController.polls.length > pollIndex) {
        return Container(
          color: AppColorConstants.cardColor,
          child: FlutterPolls(
            pollId: _homeController.polls[pollIndex].id.toString(),
            hasVoted: _homeController.polls[pollIndex].isVote! > 0,
            userVotedOptionId: _homeController.polls[pollIndex].isVote! > 0
                ? _homeController.polls[pollIndex].isVote
                : null,
            onVoted: (PollOption pollOption, int newTotalVotes) async {
              await Future.delayed(const Duration(seconds: 1));
              _homeController.postPollAnswer(
                  _homeController.polls[pollIndex].id!,
                  // _homeController.polls[pollIndex].id!,
                  pollOption.id!);

              /// If HTTP status is success, return true else false
              return true;
            },
            pollEnded: false,
            pollOptionsSplashColor: Colors.white,
            votedProgressColor: Colors.grey.withOpacity(0.3),
            votedBackgroundColor: Colors.grey.withOpacity(0.2),
            votesTextStyle: TextStyle(fontSize: FontSizes.b2),
            votedPercentageTextStyle:
                TextStyle(fontSize: FontSizes.b2).copyWith(
              color: Colors.black,
            ),
            votedCheckmark: const Icon(
              Icons.check_circle,
              color: Colors.black,
            ),
            pollTitle: Align(
              alignment: Alignment.centerLeft,
              child: BodyLargeText(
                _homeController.polls[pollIndex].title ?? "",
                weight: TextWeight.medium,
              ),
            ),
            pollOptions: List<PollOption>.from(
              (_homeController.polls[pollIndex].pollOptions ?? []).map(
                (option) {
                  var a = PollOption(
                    id: option.id,
                    title: BodyLargeText(option.title ?? '',
                        weight: TextWeight.medium),
                    votes: option.totalOptionVoteCount ?? 0,
                  );
                  return a;
                },
              ),
            ),
          ).p16,
        ).round(15).p16;
      } else {
        if (index == 1) {
          return divider(height: 0.2).vP16;
        }
        if (index > 1) {
          return divider(height: 10).vP16;
        }
        return Container();
      }
    } else {
      if (index == 1) {
        return divider(height: 0.2).vP16;
      }
      if (index > 1) {
        return divider(height: 10).vP16;
      }
      return Container();
    }
  }
}
