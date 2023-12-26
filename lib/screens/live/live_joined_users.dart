import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/live_imports.dart';
import '../../components/user_card.dart';

class LiveJoinedUsers extends StatefulWidget {
  const LiveJoinedUsers({Key? key}) : super(key: key);

  @override
  State<LiveJoinedUsers> createState() => _LiveJoinedUsersState();
}

class _LiveJoinedUsersState extends State<LiveJoinedUsers> {
  final AgoraLiveController agoraLiveController = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColorConstants.cardColor,
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Heading6Text(joinedUsersString.tr, weight: TextWeight.bold),
          const SizedBox(
            height: 20,
          ),
          divider(),
          Expanded(
            child: GetBuilder<AgoraLiveController>(
                init: agoraLiveController,
                builder: (ctx) {
                  return ListView.separated(
                      padding: const EdgeInsets.only(top: 20),
                      itemBuilder: (ctx, index) {
                        UserModel user =
                            agoraLiveController.currentJoinedUsers[index];
                        return UserTile(
                          profile: user,
                          viewCallback: () {
                            if (!user.isMe) {
                              openActionSheetForUser(user);
                            }
                          },
                        );
                      },
                      separatorBuilder: (ctx, index) {
                        return const SizedBox(
                          height: 20,
                        );
                      },
                      itemCount: agoraLiveController.currentJoinedUsers.length);
                }),
          ),
        ],
      ).hp(DesignConstants.horizontalPadding),
    ).topRounded(40);
  }

  void openActionSheetForUser(UserModel user) {
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return FractionallySizedBox(
              heightFactor: 0.6,
              child: Container(
                color: AppColorConstants.cardColor,
                width: Get.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                            height: 55,
                            width: double.infinity,
                            child: BodyLargeText('Ban'))
                        .ripple(() {
                      print('Ban');
                      banUser(user);
                    }),
                    Container(
                            height: 55,
                            width: double.infinity,
                            child: BodyLargeText('Remove Ban'))
                        .ripple(() {
                      print('Remove Ban');
                      unbanUser(user);
                    }),
                    Container(
                        height: 55,
                        width: double.infinity,
                        child: BodyLargeText('Make moderator').ripple(() {
                          makeModerator(user);
                        })),
                    Container(
                        height: 55,
                        width: double.infinity,
                        child:
                            BodyLargeText('Remove from moderator').ripple(() {
                          makeModerator(user);
                        })),
                  ],
                ).p(DesignConstants.horizontalPadding),
              ).topRounded(40));
        });
  }

  banUser(UserModel user) {
    Get.back();

    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return FractionallySizedBox(
              heightFactor: 0.6,
              child: Container(
                color: AppColorConstants.cardColor,
                width: Get.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                            height: 55,
                            width: double.infinity,
                            child: BodyLargeText('Ban for 10 minute'))
                        .ripple(() {
                      banUserForTime(user, 600);
                    }),
                    Container(
                            height: 55,
                            width: double.infinity,
                            child: BodyLargeText('Ban for 15 minute'))
                        .ripple(() {
                      banUserForTime(user, 900);
                    }),
                    Container(
                        height: 55,
                        width: double.infinity,
                        child: BodyLargeText('Ban for 30 minute').ripple(() {
                          banUserForTime(user, 1800);
                        })),
                    Container(
                        height: 55,
                        width: double.infinity,
                        child:
                            BodyLargeText('Permanent ban from live').ripple(() {
                          banUserForTime(user, null);
                        })),
                  ],
                ).p(DesignConstants.horizontalPadding),
              ).topRounded(40));
        });
  }

  banUserForTime(UserModel user, int? time) {
    agoraLiveController.banUser(user, time);
  }

  unbanUser(UserModel user) {
    agoraLiveController.unbanUser(user);
  }

  makeModerator(UserModel user) {
    agoraLiveController.makeModerator(user);
  }

  removeAsModerator(UserModel user) {
    agoraLiveController.removeAsModerator(user);
  }
}
