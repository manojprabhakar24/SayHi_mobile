import 'package:foap/screens/reuseable_widgets/post_list.dart';

import '../../controllers/post/post_controller.dart';
import '../../helper/imports/common_import.dart';

class WatchVideos extends StatefulWidget {
  const WatchVideos({Key? key}) : super(key: key);

  @override
  State<WatchVideos> createState() => _WatchVideosState();
}

class _WatchVideosState extends State<WatchVideos> {
  final PostController postController = Get.find();

  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: PostList(),
    );
  }
}
