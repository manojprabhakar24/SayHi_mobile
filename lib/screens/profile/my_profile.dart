import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/reel_imports.dart';
import 'package:foap/helper/number_extension.dart';
import 'package:foap/screens/profile/update_profile.dart';
import 'package:foap/screens/profile/users_club_listing.dart';
import 'package:foap/screens/settings_menu/settings.dart';
import '../../controllers/post/post_controller.dart';
import '../../controllers/story/highlights_controller.dart';
import '../../controllers/profile/profile_controller.dart';
import '../dashboard/mentions.dart';
import '../dashboard/posts.dart';
import '../settings_menu/settings_controller.dart';
import 'follower_following_list.dart';

class MyProfile extends StatefulWidget {
  final bool showBack;

  const MyProfile({Key? key, required this.showBack}) : super(key: key);

  @override
  MyProfileState createState() => MyProfileState();
}

class MyProfileState extends State<MyProfile>
    with SingleTickerProviderStateMixin {
  final ProfileController _profileController = Get.find();
  final HighlightsController _highlightsController = HighlightsController();
  final SettingsController _settingsController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();
  final PostController _postController = Get.find();

  List<String> tabs = [postsString, reelsString, mentionsString];

  TabController? controller;

  @override
  void initState() {
    super.initState();

    controller = TabController(vsync: this, length: tabs.length)
      ..addListener(() {});
    initialLoad();
  }

  initialLoad() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _profileController.clear();
      loadData();
    });
  }

  @override
  void didUpdateWidget(covariant MyProfile oldWidget) {
    super.didUpdateWidget(oldWidget);
    loadData();
  }

  @override
  void dispose() {
    _profileController.clear();
    _postController.clear();
    super.dispose();
  }

  loadData() {
    _profileController.getMyProfile();
    _profileController.getMentionPosts(_userProfileManager.user.value!.id);
    PostSearchQuery query = PostSearchQuery();
    query.userId = _userProfileManager.user.value!.id;
    _postController.setPostSearchQuery(query: query, callback: () {});
    _profileController.getReels(_userProfileManager.user.value!.id);

    _highlightsController.getHighlights(
        userId: _userProfileManager.user.value!.id);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          backgroundColor: AppColorConstants.backgroundColor,
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(children: [
                  if (_settingsController.appearanceChanged!.value) Container(),
                  addProfileView(),
                  contentWidget(),
                ]),
              ),
              Positioned(top: 0, left: 0, right: 0, child: appBar())
            ],
          ),
        ));
  }

  Widget addProfileView() {
    return SizedBox(
      height: 480,
      child: GetBuilder<ProfileController>(
          init: _profileController,
          builder: (ctx) {
            return _profileController.user.value != null
                ? Stack(
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 100,
                        child: Column(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              UserAvatarView(
                                  user: _profileController.user.value!,
                                  size: 85,
                                  onTapHandler: () {}),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Heading6Text(
                                    _profileController.user.value!.userName,
                                    weight: TextWeight.bold,
                                  ),
                                  if (_profileController.user.value!.isVerified)
                                    Row(
                                      children: [
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Image.asset(
                                          'assets/verified.png',
                                          height: 15,
                                          width: 15,
                                        )
                                      ],
                                    ),
                                ],
                              ).bP4,
                              if (_profileController
                                      .user.value!.profileCategoryTypeId !=
                                  0)
                                BodyLargeText(
                                  _profileController
                                      .user.value!.profileCategoryTypeName,
                                  weight: TextWeight.medium,
                                  color: AppColorConstants.grayscale700,
                                ).bP4,
                              _profileController.user.value!.country != null
                                  ? BodyMediumText(
                                      '${_profileController.user.value!.country}, ${_profileController.user.value!.city}',
                                      color: AppColorConstants.grayscale700,
                                    )
                                  : Container(),
                              const SizedBox(
                                height: 40,
                              ),
                              Container(
                                color: AppColorConstants.cardColor.darken(),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Heading4Text(
                                          _profileController
                                              .user.value!.totalPost
                                              .toString(),
                                          weight: TextWeight.medium,
                                        ).bP8,
                                        BodySmallText(
                                          postsString.tr,
                                        ),
                                      ],
                                    ),
                                    // const Spacer(),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Heading4Text(
                                          '${_profileController.user.value!.totalFollower}',
                                          weight: TextWeight.medium,
                                        ).bP8,
                                        BodySmallText(
                                          followersString.tr,
                                        ),
                                      ],
                                    ).ripple(() {
                                      if (_profileController
                                              .user.value!.totalFollower >
                                          0) {
                                        Get.to(() => FollowerFollowingList(
                                                  isFollowersList: true,
                                                  userId: _userProfileManager
                                                      .user.value!.id,
                                                ))!
                                            .then((value) {
                                          loadData();
                                        });
                                      }
                                    }),
                                    // const Spacer(),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Heading4Text(
                                          '${_profileController.user.value!.totalFollowing}',
                                          weight: TextWeight.medium,
                                        ).bP8,
                                        BodySmallText(
                                          followingString.tr,
                                        ),
                                      ],
                                    ).ripple(() {
                                      if (_profileController
                                              .user.value!.totalFollowing >
                                          0) {
                                        Get.to(() => FollowerFollowingList(
                                                isFollowersList: false,
                                                userId: _userProfileManager
                                                    .user.value!.id))!
                                            .then((value) {
                                          loadData();
                                        });
                                      }
                                    }),
                                  ],
                                ).p16,
                              ).round(15),
                              const SizedBox(
                                height: 20,
                              ),
                              AppThemeButton(
                                  height: 40,
                                  text: editProfileString.tr,
                                  onPress: () {
                                    Get.to(() => const UpdateProfile())!
                                        .then((value) {
                                      loadData();
                                    });
                                  })
                            ]).p16,
                      ),
                    ],
                  )
                : Container();
          }),
    );
  }

  Widget appBar() {
    return Container(
      color: Colors.black26,
      height: 100,
      child: widget.showBack == true
          ? backNavigationBarWithTrailingWidget(
              title: '',
              widget: const ThemeIconWidget(
                ThemeIcon.setting,
                color: Colors.white,
              ).ripple(() {
                Get.to(() => const Settings());
              }),
            ).tp(40)
          : titleNavigationBarWithIcon(
              title: '',
              icon: ThemeIcon.setting,
              iconColor: Colors.white,
              completion: () {
                Get.to(() => const Settings());
              }).tp(40),
    );
  }

  Widget contentWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: Get.width / 2.1,
              color: AppColorConstants.themeColor.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ThemeIconWidget(
                    ThemeIcon.gallery,
                    size: 40,
                    color: AppColorConstants.themeColor,
                  ),
                  Column(
                    children: [
                      BodyLargeText(
                        postsString,
                        weight: TextWeight.bold,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      BodyLargeText(
                        _userProfileManager.user.value!.totalPost.formatNumber,
                        weight: TextWeight.bold,
                      ),
                    ],
                  ).p25,
                ],
              ),
            ).round(20).ripple(() {
              Get.to(() => Posts(
                    userId: _userProfileManager.user.value!.id,
                  ));
            }),
            const SizedBox(
              width: 5,
            ),
            Container(
              width: Get.width / 2.1,
              color: AppColorConstants.themeColor.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ThemeIconWidget(
                    ThemeIcon.videoCamera,
                    size: 40,
                    color: AppColorConstants.themeColor,
                  ),
                  Column(
                    children: [
                      BodyLargeText(
                        reelsString,
                        weight: TextWeight.bold,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      BodyLargeText(
                        _userProfileManager.user.value!.totalReels.formatNumber,
                        weight: TextWeight.bold,
                      ),
                    ],
                  ).p25,
                ],
              ),
            ).round(20).ripple(() {
              ReelsController reelsController = Get.find();

              PostSearchQuery query = PostSearchQuery();
              query.userId = _userProfileManager.user.value!.id;
              reelsController.setReelsSearchQuery(query);
              Get.to(() => const Reels(needBackBtn: true,));
            }),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: Get.width / 2.1,
              color: AppColorConstants.themeColor.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ThemeIconWidget(
                    ThemeIcon.mention,
                    size: 40,
                    color: AppColorConstants.themeColor,
                  ),
                  Column(
                    children: [
                      BodyLargeText(
                        mentionsString,
                        weight: TextWeight.bold,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      BodyLargeText(
                        _userProfileManager.user.value!.totalMentions.formatNumber,
                        weight: TextWeight.bold,
                      ),
                    ],
                  ).p25,
                ],
              ),
            ).round(20).ripple(() {
              Get.to(() => Mentions(userId: _profileController.user.value!.id));
            }),
            const SizedBox(
              width: 5,
            ),
            Container(
              width: Get.width / 2.1,
              color: AppColorConstants.themeColor.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ThemeIconWidget(
                    ThemeIcon.group,
                    size: 40,
                    color: AppColorConstants.themeColor,
                  ),
                  Column(
                    children: [
                      BodyLargeText(
                        clubsString,
                        weight: TextWeight.bold,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      BodyLargeText(
                        _userProfileManager.user.value!.totalClubs.formatNumber,
                        weight: TextWeight.bold,
                      ),
                    ],
                  ).p25,
                ],
              ),
            ).round(20).ripple(() {
              Get.to(() => UsersClubs(
                    user: _userProfileManager.user.value!,
                  ));
            }),
          ],
        ),
      ],
    );
  }
}
