import 'dart:async';
import 'package:foap/controllers/fund_raising/fund_raising_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../components/comment_card.dart';

class CampaignCommentsScreen extends StatefulWidget {
  const CampaignCommentsScreen({
    Key? key,
  }) : super(key: key);

  @override
  CampaignCommentsScreenState createState() => CampaignCommentsScreenState();
}

class CampaignCommentsScreenState extends State<CampaignCommentsScreen> {
  TextEditingController commentInputField = TextEditingController();
  final ScrollController _controller = ScrollController();
  final FundRaisingController _fundraisingController = Get.find();

  final RefreshController _commentsRefreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  dispose() {
    super.dispose();
  }

  loadData() {
    _fundraisingController.getComments(() {
      _commentsRefreshController.loadComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: AppColorConstants.backgroundColor.lighten(0.02),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Obx(() {
                return ListView.separated(
                  padding: EdgeInsets.only(
                      top: 20,
                      left: DesignConstants.horizontalPadding,
                      right: DesignConstants.horizontalPadding),
                  itemCount: _fundraisingController.comments.length,
                  // reverse: true,
                  controller: _controller,
                  itemBuilder: (context, index) {
                    return CommentTile(
                        model: _fundraisingController.comments[index]);
                  },
                  separatorBuilder: (ctx, index) {
                    return const SizedBox(
                      height: 20,
                    );
                  },
                ).addPullToRefresh(
                    refreshController: _commentsRefreshController,
                    onRefresh: () {},
                    onLoading: () {
                      loadData();
                    },
                    enablePullUp: true,
                    enablePullDown: false);
              }),
            ),
            buildMessageTextField(),
            const SizedBox(height: 20)
          ],
        ));
  }

  Widget buildMessageTextField() {
    return Container(
      height: 50.0,
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              color: AppColorConstants.cardColor.withOpacity(0.5),
              child: TextField(
                controller: commentInputField,
                onChanged: (text) {},
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: writeCommentString.tr,
                  hintStyle: TextStyle(
                      fontSize: FontSizes.b2,
                      color: AppColorConstants.grayscale700),
                ),
                textInputAction: TextInputAction.send,
                style: TextStyle(
                    fontSize: FontSizes.b2,
                    color: AppColorConstants.grayscale900),
                onSubmitted: (_) {
                  addNewMessage();
                },
                onTap: () {
                  Timer(
                      const Duration(milliseconds: 300),
                      () => _controller
                          .jumpTo(_controller.position.maxScrollExtent));
                },
              ),
            ).hP8.borderWithRadius(value: 0.5, radius: 15),
          ),
          const SizedBox(width: 20),
          Container(
            width: 45,
            height: 45,
            color: AppColorConstants.grayscale900,
            child: InkWell(
              onTap: addNewMessage,
              child: Icon(
                Icons.send,
                color: AppColorConstants.themeColor,
              ),
            ),
          ).circular
        ],
      ),
    );
  }

  void addNewMessage() {
    if (commentInputField.text.trim().isNotEmpty) {
      final filter = ProfanityFilter();
      bool hasProfanity = filter.hasProfanity(commentInputField.text);
      if (hasProfanity) {
        AppUtil.showToast(message: notAllowedMessageString.tr, isSuccess: true);
        return;
      }

      _fundraisingController.postComment(
        commentInputField.text.trim(),
      );
      commentInputField.text = '';
      FocusScope.of(context).requestFocus(FocusNode());

      Timer(const Duration(milliseconds: 500),
          () => _controller.jumpTo(_controller.position.maxScrollExtent));
    }
  }
}
