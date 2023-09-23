import 'package:foap/components/thumbnail_view.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/story_imports.dart';

double storyCircleSize = 70;

class StoryUpdatesBar extends StatelessWidget {
  final List<StoryModel> stories;
  final List<UserModel> liveUsers;

  final VoidCallback addStoryCallback;
  final Function(StoryModel) viewStoryCallback;
  final Function(UserModel) joinLiveUserCallback;

  const StoryUpdatesBar({
    Key? key,
    required this.stories,
    required this.liveUsers,
    required this.addStoryCallback,
    required this.viewStoryCallback,
    required this.joinLiveUserCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(
          right: DesignConstants.horizontalPadding),
      scrollDirection: Axis.horizontal,
      itemCount: stories.length + liveUsers.length,
      itemBuilder: (BuildContext ctx, int index) {
        if (index == 0) {
          return SizedBox(
            width: storyCircleSize + 20,
            child: stories.isNotEmpty
                ? stories[index].media.isEmpty == true
                    ? Column(
                        children: [
                          SizedBox(
                            height: storyCircleSize,
                            width: storyCircleSize,
                            child: ThemeIconWidget(
                              ThemeIcon.plus,
                              size: storyCircleSize,
                              color: AppColorConstants.themeColor.darken(),
                            ),
                          )
                              .borderWithRadius(
                                  value: 2, radius: storyCircleSize / 2)
                              .ripple(() {
                            addStoryCallback();
                          }),
                          const SizedBox(
                            height: 5,
                          ),
                          BodySmallText(yourStoryString.tr,
                              weight: TextWeight.medium)
                        ],
                      )
                    : Column(
                        children: [
                          MediaThumbnailView(
                            borderColor: stories[index].isViewed == true
                                ? AppColorConstants.disabledColor
                                : AppColorConstants.themeColor,
                            media: stories[index].media.last,
                          ).ripple(() {
                            viewStoryCallback(stories[index]);
                          }),
                          const SizedBox(
                            height: 5,
                          ),
                          Expanded(
                            child: BodySmallText(yourStoryString.tr,
                                maxLines: 1, weight: TextWeight.medium),
                          )
                        ],
                      )
                : Container(),
          );
        } else {
          if (index <= liveUsers.length) {
            return SizedBox(
                width: 100,
                child: Column(
                  children: [
                    UserAvatarView(
                      size: storyCircleSize,
                      user: liveUsers[index - 1],
                      onTapHandler: () {
                        joinLiveUserCallback(liveUsers[index - 1]);
                      },
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Expanded(
                        child: BodySmallText(liveUsers[index - 1].userName,
                                maxLines: 1, weight: TextWeight.medium)
                            .hP4)
                  ],
                ));
          } else {
            return SizedBox(
                width: storyCircleSize + 20,
                child: Column(
                  children: [
                    MediaThumbnailView(
                      borderColor:
                          stories[index - liveUsers.length].isViewed == true
                              ? AppColorConstants.disabledColor
                              : AppColorConstants.themeColor,
                      media: stories[index - liveUsers.length].media.last,
                    ).ripple(() {
                      viewStoryCallback(stories[index - liveUsers.length]);
                    }).ripple(() {
                      viewStoryCallback(stories[index - liveUsers.length]);
                    }),
                    const SizedBox(
                      height: 4,
                    ),
                    Expanded(
                      child: BodySmallText(
                              stories[index - liveUsers.length].userName,
                              maxLines: 1,
                              weight: TextWeight.medium)
                          .hP4,
                    ),
                  ],
                ));
          }
        }
      },
    );
  }
}
