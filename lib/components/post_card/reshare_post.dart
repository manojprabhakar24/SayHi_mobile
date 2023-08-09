import 'package:foap/components/post_card_controller.dart';
import 'package:foap/components/user_card.dart';
import '../../helper/imports/common_import.dart';
import '../../model/post_model.dart';

class ReSharePost extends StatefulWidget {
  final PostModel post;

  const ReSharePost({Key? key, required this.post}) : super(key: key);

  @override
  ReSharePostState createState() => ReSharePostState();
}

class ReSharePostState extends State<ReSharePost> {
  TextEditingController commentInputField = TextEditingController();
  final PostCardController postCardController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
            color: AppColorConstants.cardColor,
            child: Column(
              children: <Widget>[
                UserInfo(model: _userProfileManager.user.value!),
                const SizedBox(height: 10),
                AppTextField(
                  controller: commentInputField,
                  maxLines: 3,
                  hintText: pleaseEnterMessageString,
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: AppThemeButton(
                      width: 100,
                      text: shareString,
                      onPress: () {
                        postCardController.reSharePost(
                            widget.post.id, commentInputField.text);
                        Get.back();
                      }),
                ),
                const SizedBox(height: 20),
              ],
            ))
      ],
    );
  }
}
