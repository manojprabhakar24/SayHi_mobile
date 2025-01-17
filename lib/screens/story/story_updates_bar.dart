import 'package:foap/components/thumbnail_view.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/story_imports.dart';

double storyCircleSize = 50;

class StoryUpdatesBar extends StatelessWidget {
  final List<StoryModel> stories;

  final VoidCallback addStoryCallback;
  final Function(StoryModel) viewStoryCallback;

  const StoryUpdatesBar({
    super.key,
    required this.stories,
    required this.addStoryCallback,
    required this.viewStoryCallback,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(right: DesignConstants.horizontalPadding),
      scrollDirection: Axis.horizontal,
      itemCount: stories.length  + 1,
      itemBuilder: (BuildContext ctx, int index) {
        if (index == 0) {
          return SizedBox(
            width: storyCircleSize + 20,
            child: Column(
              children: [
                SizedBox(
                  height: storyCircleSize,
                  width: storyCircleSize,
                  child: ThemeIconWidget(
                    ThemeIcon.plusSymbol,
                    size: 28,
                    color: AppColorConstants.themeColor.darken(),
                  ),
                ).borderWithRadius(value: 2, radius: 50).ripple(() {
                  addStoryCallback();
                }),
                const SizedBox(
                  height: 2,
                ),
                BodySmallText(yourStoryString.tr, weight: TextWeight.medium)
              ],
            ),
          );
        } else {
          return SizedBox(
              width: storyCircleSize + 20,
              child: Column(
                children: [
                  MediaThumbnailView(
                    borderColor:
                    stories[index  - 1].isViewed == true
                        ? AppColorConstants.disabledColor
                        : AppColorConstants.themeColor,
                    media: stories[index  - 1].media.last,
                  ).ripple(() {
                    viewStoryCallback(stories[index  - 1]);
                  }),
                  const SizedBox(
                    height: 4,
                  ),
                  Expanded(
                    child: BodySmallText(
                        stories[index  - 1].userName,
                        maxLines: 1,
                        weight: TextWeight.medium)
                        .hP4,
                  ),
                ],
              ));
        }
      },
    );
  }
}
