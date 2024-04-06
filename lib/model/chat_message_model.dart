import 'dart:convert';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:foap/helper/date_extension.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/models.dart';
import 'package:foap/helper/string_extension.dart';
import 'package:foap/screens/chat/media.dart';
import 'package:intl/intl.dart';

class ChatMessageModel {
  int id = 0;
  bool isDateSeparator = false;

  String localMessageId = "";
  GlobalKey? globalKey;

  int roomId = 0;
  String liveTvId = '';
  int isEncrypted = 0;

  String messageContent = "";
  String? repliedOnMessageContent;

  int senderId = 0;
  int createdAt = 0;
  int? viewedAt;
  int deleteAfter = AppConfigConstants.secondsInADay;

  String lastMessageSenderName = '';

  int opponentId = 0;
  String userName = '';
  String? userPicture;
  int messageType = 0;
  int status = 0;

  bool isDeleted = false;
  int isStar = 0;

  Media? media;
  Contact? contact;

  ChatMessageModel? cachedReplyMessage;
  List<ChatMessageUser> chatMessageUser = [];
  UserModel? sender;

  int? chatVersion;

  ChatMessageModel();

  factory ChatMessageModel.fromJson(dynamic jsonObj) {
    final UserProfileManager userProfileManager = Get.find();

    Map<dynamic, dynamic> jsonMap;
    if (jsonObj is String) {
      jsonMap = json.decode(jsonObj);
    } else {
      jsonMap = jsonObj;
    }
    ChatMessageModel model = ChatMessageModel();
    model.id = jsonMap['id'] ?? 0;
    model.sender =
        jsonMap['user'] == null ? null : UserModel.fromJson(jsonMap['user']);
    model.localMessageId =
        jsonMap['local_message_id'] ?? jsonMap['localMessageId'];
    model.roomId =
        jsonMap['room'] ?? jsonMap['room_id'] ?? jsonMap['liveCallId'] ?? 0;
    model.liveTvId = jsonMap['liveTvId'] ?? '';
    model.isEncrypted = jsonMap['is_encrypted'] ?? jsonMap['isEncrypted'] ?? 0;
    model.chatVersion =
        jsonMap['chat_version'] is String? ? 0 : jsonMap['chat_version'];
    model.messageContent = jsonMap['message'].replaceAll('\\', '');
    model.repliedOnMessageContent =
        jsonMap['replied_on_message'] ?? jsonMap['repliedOnMessage'];
    model.messageType = jsonMap['messageType'] ?? jsonMap['type'];
    model.senderId = jsonMap['created_by'] ?? jsonMap['createdBy'];
    model.createdAt = jsonMap['created_at'] ?? jsonMap['createdAt'];
    model.viewedAt = jsonMap['viewed_at'] ?? jsonMap['viewedAt'];
    model.deleteAfter =
        jsonMap['deleteAfter'] ?? userProfileManager.user.value!.chatDeleteTime;
    model.isDeleted = jsonMap['isDeleted'] == 1;
    model.isStar = jsonMap['isStar'] ?? 0;
    model.opponentId = jsonMap['opponent_id'] ?? 0;
    model.userName = jsonMap['username'] ?? '';
    model.userPicture = jsonMap['picture'] ?? '';
    model.status = jsonMap['current_status'] ?? 0;
    model.isDateSeparator = false;
    model.chatMessageUser = jsonMap['chatMessageUser'] == null
        ? []
        : List<ChatMessageUser>.from(
            jsonMap['chatMessageUser'].map((x) => ChatMessageUser.fromJson(x)));

    return model;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'local_message_id': localMessageId,
        'room_id': roomId,
        'messageType': messageType,
        'message': messageContent,
        'replied_on_message': repliedOnMessageContent,
        'created_by': senderId,
        'created_at': createdAt,
        'username': userName,
        'is_encrypted': isEncrypted,
        'isStar': isStar,
        'chat_version': chatVersion
      };

  int get originalMessageId {
    return ChatContentJson.fromJson(decrypt).originalMessageId;
  }

  ChatMedia get mediaContent {
    return ChatMedia.fromJson(json.decode(messageContent.decrypted()));
  }

  TextContent get textContent {
    if (chatVersion == 0) {
      TextContent content = TextContent();
      content.message = messageContent.decrypted();
      return content;
    }
    return TextContent.fromJson(json.decode(messageContent.decrypted()));
  }

  String get textMessage {
    return textContent.message.decrypted();
  }

  ChatPost get postContent {
    return ChatPost.fromJson(json.decode(messageContent.decrypted()));
  }

  StoryModel get storyContent {
    var jsonData = json.decode(messageContent.decrypted());
    return StoryModel.fromJson(jsonData['story']);
  }

  StoryModel get repliedOnStory {
    var jsonData = json.decode(repliedOnMessageDecrypt);
    return StoryModel.fromJson(jsonData);
  }

  GiftContent get giftContent {
    return GiftContent.fromJson(json.decode(decrypt));
  }

  ProfileMinimumContent get profileContent {
    return ProfileMinimumContent.fromJson(
        json.decode(messageContent.decrypted()));
  }

  String? get copyContent {
    return messageContent;
  }

  ChatMessageUser get myUserDataInMessage {
    UserProfileManager userProfileManager = Get.find();
    // print('chatMessageUser ${chatMessageUser.length} ');
    // print('message $textMessage ');

    return chatMessageUser
        .where((element) => element.userId == userProfileManager.user.value!.id)
        .first;
  }

  List<ChatMessageUser> get usersInMessageWithPendingRead {
    UserProfileManager userProfileManager = Get.find();

    return chatMessageUser
        .where((element) =>
            element.status != 3 &&
            element.userId != userProfileManager.user.value!.id)
        .toList();
  }

  List<ChatMessageUser> get usersInMessageWithPendingDelivery {
    UserProfileManager userProfileManager = Get.find();

    return chatMessageUser
        .where((element) =>
            element.status != 2 &&
            element.userId != userProfileManager.user.value!.id)
        .toList();
  }

  MessageStatus get messageStatusType {
    if (chatMessageUser.isEmpty) {
      return MessageStatus.sending;
    }
    if (usersInMessageWithPendingRead.isEmpty) {
      return MessageStatus.read;
    } else if (usersInMessageWithPendingDelivery.isEmpty) {
      return MessageStatus.delivered;
    } else if (myUserDataInMessage.status == 1) {
      return MessageStatus.sent;
    }
    return MessageStatus.sending;
  }

  bool get isMessageReadyByMe {
    return myUserDataInMessage.status == 3;
  }

  bool get isReply {
    return messageContentType == MessageContentType.reply;
  }

  bool get isFwd {
    return messageContentType == MessageContentType.forward;
  }

  ChatMessageModel get repliedOnMessage {
    if ((chatVersion ?? 0) < AppConfigConstants.chatVersion) {
      return ChatMessageModel.fromJson(json.decode(decrypt)['reply']);
    }

    return ChatMessageModel.fromJson(json.decode(repliedOnMessageDecrypt));
  }

  ChatMessageModel get originalMessage {
    var formattedString = decrypt;
    return ChatMessageModel.fromJson(
        json.decode(formattedString)['originalMessage']);
  }

  MessageContentType get messageContentType {
    if (messageType == 1) {
      return MessageContentType.text;
    } else if (messageType == 2) {
      return MessageContentType.photo;
    } else if (messageType == 3) {
      return MessageContentType.video;
    } else if (messageType == 4) {
      return MessageContentType.audio;
    } else if (messageType == 5) {
      return MessageContentType.gif;
    } else if (messageType == 6) {
      return MessageContentType.sticker;
    } else if (messageType == 7) {
      return MessageContentType.contact;
    } else if (messageType == 8) {
      return MessageContentType.location;
    } else if (messageType == 9) {
      return MessageContentType.reply;
    } else if (messageType == 10) {
      return MessageContentType.forward;
    } else if (messageType == 11) {
      return MessageContentType.post;
    } else if (messageType == 12) {
      return MessageContentType.story;
    } else if (messageType == 13) {
      return MessageContentType.drawing;
    } else if (messageType == 14) {
      return MessageContentType.profile;
    } else if (messageType == 15) {
      return MessageContentType.group;
    } else if (messageType == 16) {
      return MessageContentType.file;
    } else if (messageType == 17) {
      return MessageContentType.textReplyOnStory;
    } else if (messageType == 18) {
      return MessageContentType.reactedOnStory;
    } else if (messageType == 100) {
      return MessageContentType.groupAction;
    } else if (messageType == 200) {
      return MessageContentType.gift;
    }
    return MessageContentType.text;
  }

  MessageContentType get messageReplyContentType {
    Map data = json.decode(decrypt);
    int messageType = data['messageType'];

    if (messageType == 1) {
      return MessageContentType.text;
    } else if (messageType == 2) {
      return MessageContentType.photo;
    } else if (messageType == 3) {
      return MessageContentType.video;
    } else if (messageType == 4) {
      return MessageContentType.audio;
    } else if (messageType == 5) {
      return MessageContentType.gif;
    } else if (messageType == 6) {
      return MessageContentType.sticker;
    } else if (messageType == 7) {
      return MessageContentType.contact;
    } else if (messageType == 8) {
      return MessageContentType.location;
    } else if (messageType == 9) {
      return MessageContentType.reply;
    } else if (messageType == 10) {
      return MessageContentType.forward;
    } else if (messageType == 11) {
      return MessageContentType.post;
    } else if (messageType == 12) {
      return MessageContentType.story;
    } else if (messageType == 13) {
      return MessageContentType.drawing;
    } else if (messageType == 14) {
      return MessageContentType.profile;
    } else if (messageType == 15) {
      return MessageContentType.group;
    } else if (messageType == 16) {
      return MessageContentType.file;
    } else if (messageType == 17) {
      return MessageContentType.textReplyOnStory;
    } else if (messageType == 18) {
      return MessageContentType.reactedOnStory;
    } else if (messageType == 100) {
      return MessageContentType.groupAction;
    } else if (messageType == 200) {
      return MessageContentType.gift;
    }
    return MessageContentType.text;
  }

  bool get isMediaMessage {
    if (messageContentType == MessageContentType.text) {
      return false;
    } else if (messageContentType == MessageContentType.photo) {
      return true;
    } else if (messageContentType == MessageContentType.video) {
      return true;
    } else if (messageContentType == MessageContentType.audio) {
      return true;
    } else if (messageContentType == MessageContentType.gift) {
      return false;
    } else if (messageContentType == MessageContentType.sticker) {
      return false;
    } else if (messageContentType == MessageContentType.contact) {
      return false;
    } else if (messageContentType == MessageContentType.location) {
      return false;
    } else if (messageContentType == MessageContentType.reply) {
      // return isMediaMessage;
    } else if (messageContentType == MessageContentType.forward) {
      return originalMessage.isMediaMessage;
    } else if (messageContentType == MessageContentType.post) {
      return false;
    } else if (messageContentType == MessageContentType.story) {
      return false;
    } else if (messageContentType == MessageContentType.drawing) {
      return true;
    } else if (messageContentType == MessageContentType.profile) {
      return false;
    } else if (messageContentType == MessageContentType.group) {
      return false;
    } else if (messageContentType == MessageContentType.file) {
      return true;
    } else if (messageContentType == MessageContentType.textReplyOnStory) {
      return false;
    } else if (messageContentType == MessageContentType.reactedOnStory) {
      return false;
    } else if (messageContentType == MessageContentType.groupAction) {
      return false;
    } else if (messageContentType == MessageContentType.gift) {
      return false;
    }
    return false;
  }

  bool get isMineMessage {
    final UserProfileManager userProfileManager = Get.find();

    return senderId == userProfileManager.user.value!.id;
  }

  int get chatDay {
    DateTime createDate = DateTime.fromMillisecondsSinceEpoch(createdAt * 1000);
    return int.parse(DateFormat('d').format(createDate));
  }

  String get dateString {
    DateTime createDate = DateTime.fromMillisecondsSinceEpoch(createdAt * 1000);
    return DateFormat('dd-MMM-yyyy').format(createDate);
  }

  DateTime get date {
    return DateTime.fromMillisecondsSinceEpoch(createdAt * 1000);
  }

  String get messageTime {
    DateTime createDate = DateTime.fromMillisecondsSinceEpoch(createdAt * 1000);

    final difference = DateTime.now().difference(createDate).inDays;

    if (createDate.isToday) {
      return DateFormat('hh:mm a').format(createDate);
    } else if (createDate.isYesterday) {
      return yesterdayString.tr;
    } else if (difference < 7) {
      return DateFormat('EEEE').format(createDate);
    }
    return DateFormat('dd-MMM-yyyy').format(createDate);
  }

  String get shortInfoForNotification {
    if (messageContentType == MessageContentType.text) {
      return textMessage;
    } else if (messageContentType == MessageContentType.photo) {
      return sentAPhotoString.tr;
    } else if (messageContentType == MessageContentType.video) {
      return sentAVideoString.tr;
    } else if (messageContentType == MessageContentType.audio) {
      return sentAnAudioString.tr;
    } else if (messageContentType == MessageContentType.gif) {
      return sentAGifString.tr;
    } else if (messageContentType == MessageContentType.sticker) {
      return sentAStickerString.tr;
    } else if (messageContentType == MessageContentType.contact) {
      return sentAContactString.tr;
    } else if (messageContentType == MessageContentType.location) {
      return sentALocationString.tr;
    } else if (messageContentType == MessageContentType.reply) {
      return '';
    } else if (messageContentType == MessageContentType.forward) {
      return originalMessage.shortInfoForNotification;
    } else if (messageContentType == MessageContentType.post) {
      return sentAPostString.tr;
    } else if (messageContentType == MessageContentType.story) {
      return sentAStoryString.tr;
    } else if (messageContentType == MessageContentType.drawing) {
      return sentADrawingString.tr;
    } else if (messageContentType == MessageContentType.profile) {
      return sentAProfileString.tr;
    } else if (messageContentType == MessageContentType.textReplyOnStory) {
      return repliedToYourStory.tr;
    } else if (messageContentType == MessageContentType.reactedOnStory) {
      return reactedToYourStory.tr;
    } else if (messageContentType == MessageContentType.groupAction) {
      Map<String, dynamic> actionMessage =
          json.decode(messageContent.decrypted());
      int action = actionMessage['action'] as int;

      if (action == 1) {
        String userName = actionMessage['username'] as String;
        return '$userName ${addedToGroupString.tr}';
      } else if (action == 2) {
        String userName = actionMessage['username'] as String;
        return '$userName ${removedFromGroupString.tr}';
      } else if (action == 3) {
        String userName = actionMessage['username'] as String;
        return '$userName ${madeAdminString.tr}';
      } else if (action == 4) {
        String userName = actionMessage['username'] as String;
        return '$userName ${removedFromAdminsString.tr}';
      } else if (action == 5) {
        String userName = actionMessage['username'] as String;
        return '$userName ${leftTheGroupString.tr}';
      }
    }
    return decrypt;
  }

  String get filePath {
    if (messageContentType == MessageContentType.photo) {
      return mediaContent.image!;
    }
    if (messageContentType == MessageContentType.video) {
      return mediaContent.video!;
    }
    if (messageContentType == MessageContentType.audio) {
      return mediaContent.audio!;
    }
    return mediaContent.file!.path;
  }

  String get decrypt {
    if (isEncrypted == 1) {
      return messageContent.decrypted();
    }
    return messageContent;
  }

  String get repliedOnMessageDecrypt {
    if (isEncrypted == 1) {
      return repliedOnMessageContent!.decrypted();
    }
    return repliedOnMessageContent!.decrypted();
  }




}

class ChatContentJson {
  int originalMessageId = 0;

  ChatContentJson();

  factory ChatContentJson.fromJson(dynamic json) {
    ChatContentJson model = ChatContentJson();
    model.originalMessageId = json['originalMessageId'] as int;
    return model;
  }
}

class FileModel {
  String path;
  int type;
  String name;
  int size;

  FileModel(
      {required this.path,
      required this.type,
      required this.name,
      required this.size});
}

class ChatMedia {
  String? image;
  String? gif;
  String? video;
  String? audio;
  Contact? contact;
  LocationModel? location;
  FileModel? file;

  ChatMedia();

  factory ChatMedia.fromJson(Map<String, dynamic> data) {
    ChatMedia model = ChatMedia();
    model.image = data["image"] as String?;
    model.gif = data["image"] as String?;
    model.video = data["video"] as String?;
    model.audio = data["audio"] as String?;
    if ((data["location"] is Map<String, dynamic>)) {
      model.location = (data["location"] as Map<String, dynamic>?) != null
          ? LocationModel.fromJson(data["location"])
          : null;
    }

    model.file = (data["file"] as Map<String, dynamic>?) != null
        ? FileModel(
            path: data["file"]["path"],
            type: data["file"]["type"],
            name: data["file"]["name"],
            size: data["file"]["size"] ?? 0)
        : null;
    model.contact = (data["contactCard"] as String?) != null
        ? Contact.fromVCard(data["contactCard"] as String)
        : null;

    return model;
  }

  Map<String, dynamic> toJson() => {
        'image': image,
        'video': video,
        'audio': audio,
        'location': location?.toJson(),
      };
}

class ChatPost {
  int postId = 0;
  String image = "";
  String video = "";
  String title = "";
  String postOwnerName = "";
  String postOwnerImage = "";

  ChatPost();

  factory ChatPost.fromJson(dynamic json) {
    ChatPost model = ChatPost();
    model.postId = json['postId'];
    model.title = "Title";
    model.postOwnerName = "Adam";
    model.postOwnerImage =
        "https://images.unsplash.com/photo-1656528049647-c82eb8174d04?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHw3fHx8ZW58MHx8fHw%3D&auto=format&fit=crop&w=800&q=60";
    model.image =
        "https://images.unsplash.com/photo-1656533819629-2e386fafb6d5?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHwzfHx8ZW58MHx8fHw%3D&auto=format&fit=crop&w=800&q=60";
    model.video =
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4";
    return model;
  }
}

class GiftContent {
  String image = "";
  int coins = 0;

  GiftContent();

  factory GiftContent.fromJson(dynamic json) {
    GiftContent model = GiftContent();
    model.image = json['giftImage'];
    model.coins = int.parse(json['coins']);

    return model;
  }
}

class TextContent {
  String message = "";

  TextContent();

  factory TextContent.fromJson(dynamic json) {
    TextContent model = TextContent();
    model.message = json['text'];

    return model;
  }
}

class ProfileMinimumContent {
  int userId = 0;
  String? userPicture;
  String userName = "";
  String location = "";

  ProfileMinimumContent();

  factory ProfileMinimumContent.fromJson(dynamic json) {
    ProfileMinimumContent model = ProfileMinimumContent();
    model.userId = json['userId'];
    model.userPicture = json['userPicture'];
    model.userName = json['userName'];
    model.location = json['location'] ?? '';

    return model;
  }
}

class ChatMessageUser {
  int id = 0;
  int messageId = 0;
  int userId = 0;
  int status = 0;

  ChatMessageUser();

  factory ChatMessageUser.fromJson(dynamic json) {
    ChatMessageUser model = ChatMessageUser();
    model.id = json['id'] ?? 0;
    model.messageId = json['chat_message_id'] ?? json['chatMessageId'] ?? 0;
    model.userId = json['user_id'] ?? json['userId'] ?? 0;
    model.status = json['status'] ?? 0;

    return model;
  }
}
