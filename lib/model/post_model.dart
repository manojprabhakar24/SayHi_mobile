import 'package:foap/helper/date_extension.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/models.dart';
import 'package:foap/model/fund_raising_campaign.dart';
import 'package:foap/model/offer_model.dart';
import 'package:foap/model/post_gallery.dart';
import 'package:foap/model/post_promotion_model.dart';
import 'package:foap/model/shop_model/ad_model.dart';
import 'package:foap/screens/add_on/model/reel_music_model.dart';
import '../helper/enum_linking.dart';
import 'club_model.dart';
import 'job_model.dart';

class PostModel {
  int id = 0;
  String? title;

  late UserModel user;
  int? competitionId = 0;

  int totalView = 0;
  int totalLike = 0;
  int totalComment = 0;
  int totalShare = 0;
  int isWinning = 0;
  bool isLike = false;
  bool isSaved = false;
  bool commentsEnabled = true;

  bool isReported = false;
  bool isSharePost = false;

  List<PostGallery> gallery = [];
  List<String> tags = [];
  List<MentionedUsers> mentionedUsers = [];

  ReelMusicModel? audio;
  ClubModel? postedInClub;
  String shareLink = '';

  String postTime = '';
  DateTime? createDate;
  PostModel? sharedPost;
  PostPromotionModel? postPromotionData;

  EventModel? event;
  CompetitionModel? competition;
  FundRaisingCampaign? fundRaisingCampaign;
  JobModel? job;
  OfferModel? offer;
  AdModel? product;
  ClubModel? createdClub;
  PollModel? poll;

  PostContentType contentType = PostContentType.text;

  Map? contentRefrence;

  PostModel();

  factory PostModel.fromJson(dynamic json) {
    PostModel model = PostModel();
    model.id = json['id'];
    model.title = json['title'];
    model.user =
        json['user'] == null ? UserModel() : UserModel.fromJson(json['user']);
    model.competitionId = json['competition_id'];
    model.totalView = json['total_view'] ?? 0;
    model.totalLike = json['total_like'] ?? 0;
    model.totalComment = json['total_comment'] ?? 0;
    model.totalShare = json['total_share'] ?? 0;
    model.isWinning = json['is_winning'] ?? 0;

    model.isLike = json['is_like'] == 1;
    model.isReported = json['is_reported'] == 1;
    model.isSharePost = json['is_share_post'] == 1;
    model.isSaved = json['isFavorite'] == 1;
    model.commentsEnabled = json['is_comment_enable'] == 1;
    model.shareLink = json['share_link'];
    model.contentType = json['post_content_type'] == null
        ? PostContentType.text
        : postContentTypeValueFrom(json['post_content_type']);
    model.contentRefrence = json['contentReferenceDetail'];

    if(model.contentRefrence != null){
      if (model.contentType == PostContentType.event) {
        model.event = EventModel.fromJson(json['contentReferenceDetail']);
      }
      if (model.contentType == PostContentType.competitionAdded ||
          model.contentType == PostContentType.competitionResultDeclared) {
        model.competition =
            CompetitionModel.fromJson(json['contentReferenceDetail']);
      }
      if (model.contentType == PostContentType.fundRaising ||
          model.contentType == PostContentType.donation) {
        model.fundRaisingCampaign =
            FundRaisingCampaign.fromJson(json['contentReferenceDetail']);
      }
      if (model.contentType == PostContentType.job) {
        model.job = JobModel.fromJson(json['contentReferenceDetail']);
      }
      if (model.contentType == PostContentType.offer) {
        model.offer = OfferModel.fromJson(json['contentReferenceDetail']);
      }
      if (model.contentType == PostContentType.classified) {
        json['contentReferenceDetail']['user'] = json['user'];
        model.product = AdModel.fromJson(json['contentReferenceDetail']);
      }
      if (model.contentType == PostContentType.club) {
        print('vahjdbv ${json['contentReferenceDetail']}');
        print('postid  ${model.id}');

        json['contentReferenceDetail']['createdByUser'] = json['user'];
        model.createdClub = ClubModel.fromJson(json['contentReferenceDetail']);
      }
      if (model.contentType == PostContentType.poll) {
        model.poll = PollModel.fromJson(json['contentReferenceDetail']);
      }
    }

    model.postedInClub = json['clubDetail'] == null
        ? null
        : ClubModel.fromJson(json['clubDetail']);
    model.tags = [];
    if (json['hashtags'] != null && json['hashtags'].length > 0) {
      model.tags = List<String>.from(json['hashtags'].map((x) => '#$x'));
    }

    if (json['postGallary'] != null && json['postGallary'].length > 0) {
      model.gallery = List<PostGallery>.from(
          json['postGallary'].map((x) => PostGallery.fromJson(x)));
    }

    if (json['mentionUsers'] != null && json['mentionUsers'].length > 0) {
      model.mentionedUsers = List<MentionedUsers>.from(
          json['mentionUsers'].map((x) => MentionedUsers.fromJson(x)));
    }

    model.createDate = json['created_at'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(json['created_at'] * 1000)
            .toUtc();

    model.postTime = model.createDate != null
        ? model.createDate!.getTimeAgo
        : justNowString.tr;
    model.audio =
        json['audio'] == null ? null : ReelMusicModel.fromJson(json['audio']);

    model.sharedPost = json['originPost'] == null
        ? null
        : PostModel.fromJson(json['originPost']);
    if (json['postPromotionData'] != null) {
      model.postPromotionData =
          PostPromotionModel.fromJson(json['postPromotionData']);
    }

    return model;
  }

  bool get containVideoPost {
    return gallery.where((element) => element.isVideoPost).isNotEmpty;
  }

  bool get isMyPost {
    final UserProfileManager userProfileManager = Get.find();

    return user.id == userProfileManager.user.value!.id;
  }

  String get postTitle {
    if (contentType == PostContentType.text ||
        contentType == PostContentType.media ||
        contentType == PostContentType.location ||
        contentType == PostContentType.poll) {
      return title ?? '';
    } else if (contentType == PostContentType.event && event != null) {
      return '${user.name!} ${addedNewEventString.tr} : ${event!.name}';
    } else if (contentType == PostContentType.competitionAdded &&
        competition != null) {
      return '${user.name!} ${addedNewCompetitionString.tr} ${competition!.title}';
    } else if (contentType == PostContentType.fundRaising && fundRaisingCampaign != null) {
      return '${user.name!} ${addedNewFundRaisingCampaignString.tr} ${fundRaisingCampaign!.title}';
    } else if (contentType == PostContentType.job && job != null) {
      return '${user.name!} ${addedNewJobOpeningString.tr} ${job!.title}';
    } else if (contentType == PostContentType.offer && offer != null) {
      return '${user.name!} ${addedNewOfferString.tr} ${offer!.name} , ${couponCodeString.tr} : ${offer!.code}';
    } else if (contentType == PostContentType.classified && product != null) {
      return '${user.name!} ${addedNewProductString.tr} ${product!.title!}';
    } else if (contentType == PostContentType.donation && fundRaisingCampaign != null) {
      return '${user.name!} ${donatedToString.tr} ${fundRaisingCampaign!.title}';
    } else if (contentType == PostContentType.club && createdClub != null) {
      return '${user.name!} ${createdAClubString.tr} ${createdClub!.name!}';
    }
    return '';
  }
}

class MentionedUsers {
  int id = 0;
  String userName = '';

  MentionedUsers();

  factory MentionedUsers.fromJson(dynamic json) {
    MentionedUsers model = MentionedUsers();
    model.id = json['user_id'];
    model.userName = json['username'].toString().toLowerCase();
    return model;
  }
}

class PostInsight {
  int totalView;
  int totalImpression;
  int totalShare;

  int viewFromFollowers;
  int viewFromNonFollowers;
  int viewFromMale;
  int viewFromFemale;
  int viewFromOther;
  int viewFromGenderNotDisclosed;
  int viewFromCountryNotDisclosed;
  int viewFromProfileCategoryNotDisclosed;
  int viewFromAgeNotDisclosed;
  int profileViewFromPost;
  int followFromPost;

  PostInsight({
    required this.totalView,
    required this.totalImpression,
    required this.totalShare,
    required this.viewFromFollowers,
    required this.viewFromNonFollowers,
    required this.viewFromMale,
    required this.viewFromFemale,
    required this.viewFromOther,
    required this.viewFromGenderNotDisclosed,
    required this.viewFromCountryNotDisclosed,
    required this.viewFromProfileCategoryNotDisclosed,
    required this.viewFromAgeNotDisclosed,
    required this.profileViewFromPost,
    required this.followFromPost,
  });

  factory PostInsight.fromJson(dynamic json) => PostInsight(
      totalView: json['total_view'],
      totalImpression: json['total_impression'],
      totalShare: json['total_share'] ?? 0,
      viewFromFollowers: json['follower'],
      viewFromNonFollowers: json['nonfollower'],
      viewFromMale: json['male'],
      viewFromFemale: json['female'],
      viewFromOther: json['other'],
      viewFromGenderNotDisclosed: json['gender_not_disclose'],
      viewFromCountryNotDisclosed: json['country_not_disclose'],
      viewFromProfileCategoryNotDisclosed:
          json['profile_category_type_not_disclose'],
      viewFromAgeNotDisclosed: json['age_not_disclose'],
      profileViewFromPost: json['profile_view'],
      followFromPost: json['follow_by_post']);
}
