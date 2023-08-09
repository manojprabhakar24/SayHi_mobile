import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/models.dart';
import '../../screens/club/club_detail.dart';
import '../../screens/profile/my_profile.dart';
import '../../screens/profile/other_user_profile.dart';
import '../post_card_controller.dart';

class PostUserInfo extends StatelessWidget {
  final PostModel post;
  final PostCardController postCardController = Get.find();

  PostUserInfo({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
            height: 35,
            width: 35,
            child: UserAvatarView(
              size: 35,
              user: post.user,
              onTapHandler: () {
                openProfile();
              },
            )),
        const SizedBox(width: 10),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                BodyLargeText(
                  post.user.userName,
                  weight: TextWeight.medium,
                ).ripple(() {
                  openProfile();
                }),
                if (post.club != null)
                  Expanded(
                    child: BodyLargeText(
                      ' (${post.club!.name})',
                      weight: TextWeight.semiBold,
                      color: AppColorConstants.themeColor,
                      maxLines: 1,
                    ).ripple(() {
                      openClubDetail();
                    }),
                  ),
                if (post.sharedPost != null)
                  BodySmallText(
                    ' ($reSharedString) ',
                    weight: TextWeight.semiBold,
                    maxLines: 1,
                  )
              ],
            ),
            const SizedBox(
              height: 2,
            ),
            Row(
              children: [
                const ThemeIconWidget(ThemeIcon.clock, size: 12),
                const SizedBox(
                  width: 5,
                ),
                BodyExtraSmallText(post.postTime.tr),
              ],
            )
          ],
        )),
      ],
    );
  }

  void openProfile() async {
    if (post.user.isMe) {
      Get.to(() => const MyProfile(
            showBack: true,
          ));
    } else {
      // postCardController.profileViewed(
      //     sourceType: InsightSource.post, refId: widget.model.id);
      Get.to(() => OtherUserProfile(userId: post.user.id));
    }
  }

  void openClubDetail() async {
    Get.to(() => ClubDetail(
        club: post.club!,
        needRefreshCallback: () {},
        deleteCallback: (club) {}));
  }
}
