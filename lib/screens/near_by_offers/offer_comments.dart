import 'dart:async';
import 'package:foap/helper/imports/common_import.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../components/comment_card.dart';
import '../../controllers/coupons/near_by_offers.dart';

class OfferCommentsScreen extends StatefulWidget {
  const OfferCommentsScreen({
    Key? key,
  }) : super(key: key);

  @override
  OfferCommentsScreenState createState() => OfferCommentsScreenState();
}

class OfferCommentsScreenState extends State<OfferCommentsScreen> {
  TextEditingController commentInputField = TextEditingController();
  final ScrollController _controller = ScrollController();
  final NearByOffersController _nearByOffersController = Get.find();

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
    _nearByOffersController.getOfferComments(() {
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
                  itemCount: _nearByOffersController.comments.length,
                  // reverse: true,
                  controller: _controller,
                  itemBuilder: (context, index) {
                    return CommentTile(
                        model: _nearByOffersController.comments[index]);
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
                      color: AppColorConstants.mainTextColor),
                ),
                textInputAction: TextInputAction.send,
                style: TextStyle(
                    fontSize: FontSizes.b2,
                    color: AppColorConstants.mainTextColor),
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
            color: AppColorConstants.mainTextColor,
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

      _nearByOffersController.postOfferComment(
        commentInputField.text.trim(),
      );
      commentInputField.text = '';
      FocusScope.of(context).requestFocus(FocusNode());

      Timer(const Duration(milliseconds: 500),
          () => _controller.jumpTo(_controller.position.maxScrollExtent));
    }
  }
}
