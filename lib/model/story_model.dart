import 'package:foap/model/user_model.dart';
import 'package:foap/util/time_convertor.dart';

class StoryModel {
  int id;

  String name;
  String userName;

  String? userImage;
  List<StoryMediaModel> media;
  bool isViewed = false;
  bool isLive = false;
  UserModel? user;

  StoryModel({
    required this.id,
    required this.name,
    required this.userName,
    this.userImage,
    required this.media,
    this.user
  });

  factory StoryModel.fromJson(dynamic json) {
    StoryModel model = StoryModel(
      id: json['id'],
      name: json['name'],
      userName: json['username'],
      userImage: json['picture'],
      media: (json['userStory'] as List<dynamic>)
          .map((e) => StoryMediaModel.fromJson(e))
          .toList(),
    );

    return model;
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "username": userName,
        "picture": userImage,
        "userStory": media.map((e) => e.toJson()).toList()
      };
}

class StoryMediaModel {
  int id;
  int userId;

  String? description;

  String? bgColor;
  String? video;
  String? image;
  String? imageName;
  int createdAtDate;
  int? videoDuration;
  String createdAt;
  int type;
  UserModel? user;
  int totalView;

  StoryMediaModel(
      {required this.id,
      required this.userId,
      required this.description,
      required this.bgColor,
      required this.video,
      required this.image,
      required this.imageName,
      required this.createdAtDate,
      required this.createdAt,
      required this.type,
      required this.user,
      required this.totalView,
      this.videoDuration});

  factory StoryMediaModel.fromJson(dynamic json) {
    StoryMediaModel model = StoryMediaModel(
        id: json['id'],
        userId: json['user_id'],
        description: json['description'],
        bgColor: json['background_color'],
        video: json['videoUrl'],
        videoDuration: json['video_time'],
        imageName: json['image'],
        image: json['imageUrl'],
        createdAtDate: json['created_at'] * 1000,
        createdAt: TimeAgo.timeAgoSinceDate(
            DateTime.fromMillisecondsSinceEpoch(json['created_at'] * 1000)
                .toUtc()),
        type: json['type'],
        totalView: json['totalView'],
        user: json['user'] == null ? null : UserModel.fromJson(json['user']));

    return model;
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "description": description,
        "background_color": bgColor,
        "videoUrl": video,
        "video_time": videoDuration,
        "image": imageName,
        "imageUrl": image,
        "created_at": createdAtDate,
        "type": type,
        "totalView": totalView,
        // "user": user!.toJson(),
      };

  isVideoPost() {
    return type == 3;
  }
}

class StoryViewerModel {
  String viewedAt = '';
  UserModel? user;

  StoryViewerModel();

  factory StoryViewerModel.fromJson(dynamic json) {
    StoryViewerModel model = StoryViewerModel();
    model.user = UserModel.fromJson(json['user']);
    model.viewedAt = TimeAgo.timeAgoSinceDate(
        DateTime.fromMillisecondsSinceEpoch(json['created_at'] * 1000).toUtc());

    return model;
  }
}
