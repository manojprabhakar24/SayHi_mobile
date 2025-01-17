import 'package:flutter/material.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/chat/voice_record.dart';
import 'package:foap/screens/post/watch_videos.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../components/force_update_view.dart';
import '../../main.dart';
import '../add_on/ui/reel/reels.dart';
import '../home_feed/home_feed_screen.dart';
import '../profile/my_profile.dart';
import '../settings_menu/settings_controller.dart';
import 'explore.dart';

class DashboardController extends GetxController {
  RxInt currentIndex = 0.obs;
  RxInt unreadMsgCount = 0.obs;
  RxBool isLoading = false.obs;

  indexChanged(int index) {
    currentIndex.value = index;
  }

  updateUnreadMessageCount(int count) {
    unreadMsgCount.value = count;
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<DashboardScreen> {
  final DashboardController _dashboardController = Get.find();
  final SettingsController _settingsController = Get.find();

  late PersistentTabController _tabController;

  List<Widget> widgets = [];

  @override
  void initState() {
    super.initState();
    isAnyPageInStack = true;

    _tabController = PersistentTabController(initialIndex: 0);

    widgets = [
      const HomeFeedScreen(),
      const Explore(),
      Container(),
      const WatchVideos(),
      const MyProfile(
        showBack: false,
      ),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home_outlined),
        title: "Home",
        activeColorPrimary: AppColorConstants.themeColor,
        inactiveColorPrimary: AppColorConstants.iconColor,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.search_sharp),
        title: "Explore",
        activeColorPrimary: AppColorConstants.themeColor,
        inactiveColorPrimary: AppColorConstants.iconColor,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.mic,color: Colors.white,),
        title: "Voice",
        activeColorPrimary: AppColorConstants.themeColor,
        inactiveColorPrimary: AppColorConstants.iconColor,
        onPressed: (context) {
//_showBottomSheet(context!);
        },
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.videocam_outlined),
        title: "Videos",
        activeColorPrimary: AppColorConstants.themeColor,
        inactiveColorPrimary: AppColorConstants.iconColor,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.account_circle_outlined),
        title: "Profile",
        activeColorPrimary: AppColorConstants.themeColor,
        inactiveColorPrimary: AppColorConstants.iconColor,
      ),
    ];
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.7,
          child: Container(
            color: Colors.black.withOpacity(0.8), // Background color
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Pulsating circles for Siri animation
                  _buildAnimatedCircle(100, Colors.blue.withOpacity(0.5)),
                  _buildAnimatedCircle(150, Colors.purple.withOpacity(0.5)),
                  _buildAnimatedCircle(200, Colors.red.withOpacity(0.3)),
                  // Mic icon at the center
                  Container(
                    height: 60,
                    width: 60,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mic,
                      color: Colors.black,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedCircle(double radius, Color color) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.8, end: 1.2),
      duration: const Duration(seconds: 2),
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.scale(
          scale: value,
          child: Container(
            height: radius,
            width: radius,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
        );
      },
      onEnd: () {
        // Loop the animation
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            _showBottomSheet(context);
          }
        });
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Obx(() => _dashboardController.isLoading.value == true
        ? Center(
      child: CircularProgressIndicator(
        color: AppColorConstants.themeColor,
      ),
    )
        : _settingsController.forceUpdate.value == true
        ? ForceUpdateView()
        : _settingsController.appearanceChanged?.value == null
        ? Container()
        : PersistentTabView(
      context,
      controller: _tabController,
      screens: widgets,
      items: _navBarsItems(),
      backgroundColor: AppColorConstants.cardColor,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      navBarStyle: NavBarStyle.style15,
    ));
  }
}
