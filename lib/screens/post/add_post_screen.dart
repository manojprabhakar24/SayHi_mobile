import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/post/post_option_popup.dart';
import 'package:video_editor_sdk/video_editor_sdk.dart';
import '../../components/video_widget.dart';
import '../../controllers/post/add_post_controller.dart';
import '../../controllers/post/select_post_media_controller.dart';
import 'tag_hashtag_view.dart';
import 'tag_users_view.dart';
import '../chat/media.dart';
import 'audio_file_player.dart';
import 'package:photo_editor_sdk/photo_editor_sdk.dart';

class AddPostScreen extends StatefulWidget {
  final PostType postType;

  final List<Media>? items;
  final int? competitionId;
  final int? clubId;
  final bool? isReel;
  final int? audioId;
  final double? audioStartTime;
  final double? audioEndTime;

  const AddPostScreen(
      {Key? key,
      required this.postType,
      this.items,
      this.competitionId,
      this.clubId,
      this.isReel,
      this.audioId,
      this.audioStartTime,
      this.audioEndTime})
      : super(key: key);

  @override
  AddPostState createState() => AddPostState();
}

class AddPostState extends State<AddPostScreen> {
  TextEditingController descriptionText = TextEditingController();
  final SelectPostMediaController _selectPostMediaController =
      SelectPostMediaController();

  final AddPostController addPostController = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    descriptionText.text = '';
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: GetBuilder<AddPostController>(
          init: addPostController,
          builder: (ctx) {
            return Stack(
              children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(
                        height: 55,
                      ),
                      Row(
                        children: [
                          InkWell(
                              onTap: () {
                                Get.back();
                                addPostController.clear();
                              },
                              child:
                                  const ThemeIconWidget(ThemeIcon.backArrow)),
                          const Spacer(),
                          Container(
                                  color: AppColorConstants.themeColor,
                                  child: BodyLargeText(
                                    widget.competitionId == null
                                        ? postString.tr
                                        : submitString.tr,
                                    weight: TextWeight.medium,
                                    color: Colors.white,
                                  ).setPadding(
                                      left: 8, right: 8, top: 5, bottom: 5))
                              .round(10)
                              .ripple(() {
                            if ((widget.items ??
                                        _selectPostMediaController
                                            .selectedMediaList)
                                    .isNotEmpty ||
                                descriptionText.text.isNotEmpty) {
                              addPostController.uploadAllPostFiles(
                                  allowComments:
                                      addPostController.enableComments.value,
                                  postType: widget.postType,
                                  isReel: widget.isReel ?? false,
                                  audioId: widget.audioId,
                                  audioStartTime: widget.audioStartTime,
                                  audioEndTime: widget.audioEndTime,
                                  items: widget.items ??
                                      _selectPostMediaController
                                          .selectedMediaList,
                                  title: descriptionText.text,
                                  competitionId: widget.competitionId,
                                  clubId: widget.clubId);
                            }
                          }),
                        ],
                      ).hp(DesignConstants.horizontalPadding),
                      const SizedBox(
                        height: 30,
                      ),
                      addDescriptionView()
                          .hp(DesignConstants.horizontalPadding),
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        children: [
                          BodyMediumText(
                            allowCommentsString.tr,
                            weight: TextWeight.semiBold,
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Obx(() => ThemeIconWidget(
                                      addPostController.enableComments.value
                                          ? ThemeIcon.selectedCheckbox
                                          : ThemeIcon.emptyCheckbox)
                                  .ripple(() {
                                addPostController.toggleEnableComments();
                              })),
                        ],
                      ).hp(DesignConstants.horizontalPadding),
                      const SizedBox(
                        height: 10,
                      ),
                      Obx(() {
                        return addPostController.isEditing.value == 1
                            ? Expanded(
                                child: Container(
                                  // height: 500,
                                  width: double.infinity,
                                  color: AppColorConstants.disabledColor
                                      .withOpacity(0.1),
                                  child: addPostController
                                          .currentHashtag.isNotEmpty
                                      ? TagHashtagView()
                                      : addPostController
                                              .currentUserTag.isNotEmpty
                                          ? TagUsersView()
                                          : Container().ripple(() {
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                            }),
                                ),
                              )
                            : mediaList();
                      }),
                      Obx(() => addPostController.isEditing.value == 0
                          ? const Spacer()
                          : Container()),
                      Obx(() => addPostController.isEditing.value == 0
                          ? PostOptionsPopup(
                              selectedMediaList: (medias) {
                                _selectPostMediaController
                                    .mediaSelected(medias);
                              },
                              selectGif: (gifMedia) {
                                _selectPostMediaController
                                    .mediaSelected([gifMedia]);
                              },
                              recordedAudio: (audioMedia) {
                                _selectPostMediaController
                                    .mediaSelected([audioMedia]);
                              },
                            )
                          : Container())
                    ]),
              ],
            );
          }),
    );
  }

  Widget mediaList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: Get.height * 0.4,
          child: Stack(
            children: [
              Obx(() {
                print('reload');

                return CarouselSlider(
                  items: [
                    for (Media media
                        in _selectPostMediaController.selectedMediaList)
                      media.mediaType == GalleryMediaType.photo
                          ? Image.file(
                              media.file!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ).ripple(() {
                              openImageEditor(media);
                            })
                          : media.mediaType == GalleryMediaType.gif
                              ? CachedNetworkImage(
                                  fit: BoxFit.cover, imageUrl: media.filePath!)
                              : media.mediaType == GalleryMediaType.video
                                  ? VideoPostTile(
                                      url: media.file!.path,
                                      isLocalFile: true,
                                      play: true,
                                    ).ripple(() {
                                      openVideoEditor(media);
                                    })
                                  : audioPostTile(media)
                  ],
                  options: CarouselOptions(
                    aspectRatio: 1,
                    enlargeCenterPage: false,
                    enableInfiniteScroll: false,
                    height: double.infinity,
                    viewportFraction: 1,
                    onPageChanged: (index, reason) {
                      _selectPostMediaController.updateGallerySlider(index);
                    },
                  ),
                );
              }),
              Obx(() {
                return _selectPostMediaController.selectedMediaList.length > 1
                    ? Positioned(
                        bottom: 10,
                        left: 0,
                        right: 0,
                        child: Align(
                            alignment: Alignment.center,
                            child: Container(
                                    height: 25,
                                    color: AppColorConstants.cardColor,
                                    child: DotsIndicator(
                                      dotsCount: _selectPostMediaController
                                          .selectedMediaList.length,
                                      position: _selectPostMediaController
                                          .currentIndex.value,
                                      decorator: DotsDecorator(
                                          activeColor:
                                              AppColorConstants.themeColor),
                                    ).hP8)
                                .round(20)),
                      )
                    : Container();
              })
            ],
          ).p16,
        ),
        const SizedBox(
          height: 20,
        ),
        if (_selectPostMediaController.selectedMediaList.isNotEmpty)
          Heading2Text(
            'Tap to edit',
            weight: TextWeight.bold,
          ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Widget audioPostTile(Media media) {
    return AudioFilePlayer(
      path: media.filePath!,
    );
  }

  Widget addDescriptionView() {
    return SizedBox(
      height: 100,
      child: Obx(() {
        descriptionText.value = TextEditingValue(
            text: addPostController.searchText.value,
            selection: TextSelection.fromPosition(
                TextPosition(offset: addPostController.position.value)));

        return Focus(
          child: Container(
            color: AppColorConstants.cardColor,
            child: TextField(
              controller: descriptionText,
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: FontSizes.h5,
                  color: AppColorConstants.grayscale900),
              maxLines: 5,
              onChanged: (text) {
                addPostController.textChanged(
                    text, descriptionText.selection.baseOffset);
              },
              decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.only(top: 10, left: 10, right: 10),
                  counterText: "",
                  hintStyle: TextStyle(
                      fontSize: FontSizes.h5,
                      color: AppColorConstants.grayscale500),
                  hintText: addSomethingAboutPostString.tr),
            ),
          ).round(10),
          onFocusChange: (hasFocus) {
            if (hasFocus == true) {
              addPostController.startedEditing();
            } else {
              addPostController.stoppedEditing();
            }
          },
        );
      }),
    );
  }

  openImageEditor(Media media) async {
    final result = await PESDK.openEditor(image: media.file!.path);

    if (result != null) {
      // The user exported a new photo successfully and the newly generated photo is located at `result.image`.
      Media editedMedia = media.copy;
      editedMedia.file = File(result.image.replaceAll('file://', ''));
      _selectPostMediaController.replaceMediaWithEditedMedia(
          originalMedia: media, editedMedia: editedMedia);
    } else {
      // The user exported a new photo successfully and the newly generated photo is located at `result.image`.
      return;
    }
  }

  openVideoEditor(Media media) async {
    final video = Video(media.file!.path);
    final result = await VESDK.openEditor(video);

    if (result != null) {
      // The user exported a new photo successfully and the newly generated photo is located at `result.image`.
      Media editedMedia = media.copy;
      print('result.image ${result.video}');
      editedMedia.file = File(result.video.replaceAll('file://', ''));
      _selectPostMediaController.replaceMediaWithEditedMedia(
          originalMedia: media, editedMedia: editedMedia);
    } else {
      // The user exported a new photo successfully and the newly generated photo is located at `result.image`.
      return;
    }
  }
}
