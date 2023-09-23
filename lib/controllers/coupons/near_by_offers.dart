import 'package:foap/api_handler/apis/offers_api.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/models.dart';
import 'package:foap/helper/list_extension.dart';
import 'package:foap/model/business_model.dart';
import '../../model/offer_model.dart';

class NearByOffersController extends GetxController {
  final UserProfileManager _userProfileManager = Get.find();
  RxList<OffersCategoryModel> categories = <OffersCategoryModel>[].obs;
  RxList<BusinessModel> businessList = <BusinessModel>[].obs;
  RxList<OfferModel> offers = <OfferModel>[].obs;
  RxList<OfferModel> favOffers = <OfferModel>[].obs;
  RxList<CommentModel> comments = <CommentModel>[].obs;

  RxBool isLoadingCategories = false.obs;

  Rx<BusinessModel?> currentBusiness = Rx<BusinessModel?>(null);
  Rx<OfferModel?> currentOffer = Rx<OfferModel?>(null);

  int businessPage = 1;
  bool canLoadMoreBusiness = true;
  RxBool isLoadingBusiness = false.obs;

  int offerPage = 1;
  bool canLoadMoreOffers = true;
  RxBool isLoadingOffers = false.obs;

  int favOfferPage = 1;
  bool canLoadMoreFavOffers = true;
  RxBool isLoadingFavOffer = false.obs;

  int commentPage = 1;
  bool canLoadMoreComment = true;
  RxBool isLoadingComments = false.obs;

  RxInt currentIndex = 0.obs;

  RxInt totalOffersFound = 0.obs;
  RxInt totalFavOffersFound = 0.obs;

  RxInt totalBusinessFound = 0.obs;

  OfferSearchModel offerSearchModel = OfferSearchModel();
  OfferSearchModel favOfferSearchModel = OfferSearchModel();

  BusinessSearchModel businessSearchModel = BusinessSearchModel();

  clear() {
    categories.clear();
    businessList.clear();
    offers.clear();
    favOffers.clear();

    isLoadingCategories.value = false;
    currentBusiness.value = null;
    currentOffer.value = null;

    favOfferPage = 1;
    canLoadMoreFavOffers = true;
    isLoadingFavOffer.value = false;

    businessPage = 1;
    canLoadMoreBusiness = true;
    isLoadingBusiness.value = false;
    currentIndex.value = 0;

    offerPage = 1;
    canLoadMoreOffers = true;
    isLoadingOffers.value = false;

    commentPage = 1;
    canLoadMoreComment = true;
    isLoadingComments.value = false;

    totalOffersFound.value = 0;
    totalFavOffersFound.value = 0;
    totalBusinessFound.value = 0;

    offerSearchModel = OfferSearchModel();
    businessSearchModel = BusinessSearchModel();
    favOfferSearchModel = OfferSearchModel();
  }

  clearBusinesses() {
    businessList.clear();
    businessPage = 1;
    canLoadMoreBusiness = true;
    isLoadingBusiness.value = false;
  }

  clearOffers() {
    offers.clear();
    offerPage = 1;
    canLoadMoreOffers = true;
    isLoadingOffers.value = false;
  }

  clearFavOffers() {
    favOffers.clear();
    favOfferPage = 1;
    canLoadMoreFavOffers = true;
    isLoadingFavOffer.value = false;
  }

  clearComments() {
    comments.clear();
    commentPage = 1;
    canLoadMoreComment = true;
    isLoadingComments.value = false;
  }

  initiate() {
    getCategories();
    getBusinesses(() {});
    getOffers(() {});
  }

  setCurrentBusiness(BusinessModel business) {
    currentBusiness.value = business;
    clearComments();
    clearOffers();
    setOfferBusinessId(business.id);
    // getBusinessComments(() {});
    getOffers(() {});
  }

  setCurrentOffer(OfferModel offer) {
    currentOffer.value = offer;
    clearComments();
    getOfferComments(() {});
  }

  updateGallerySlider(int index) {
    currentIndex.value = index;
  }

  setOfferBusinessId(int? id) {
    clearOffers();
    offerSearchModel.businessId = id;
    getOffers(() {});
  }

  setOfferCategoryId(int? id) {
    clearOffers();
    offerSearchModel.categoryId = id;
    getOffers(() {});
  }

  setFavOfferBusinessId(int? id) {
    clearFavOffers();
    favOfferSearchModel.businessId = id;
    getFavOffers(() {});
  }

  setFavOfferCategoryId(int? id) {
    clearFavOffers();
    favOfferSearchModel.categoryId = id;
    getFavOffers(() {});
  }

  setFavOfferName(String? name) {
    clearFavOffers();
    favOfferSearchModel.name = name;
    getFavOffers(() {});
  }

  setOfferName(String? name) {
    clearOffers();
    offerSearchModel.name = name;
    getOffers(() {});
  }

  setBusinessCategoryId(int? id) {
    clearBusinesses();
    businessSearchModel.categoryId = id;
    getBusinesses(() {});
  }

  setBusinessName(String? name) {
    clearBusinesses();
    businessSearchModel.name = name;
    getBusinesses(() {});
  }

  getCategories() {
    isLoadingCategories.value = true;
    OffersApi.getCategories(resultCallback: (result) {
      categories.value = result;
      isLoadingCategories.value = false;

      update();
    });
  }

  getBusinesses(VoidCallback callback) {
    print('canLoadMoreBusiness $canLoadMoreBusiness');
    if (canLoadMoreBusiness) {
      OffersApi.getBusinesses(
          page: businessPage,
          searchModel: businessSearchModel,
          resultCallback: (result, metadata) {
            businessList.addAll(result);
            businessList.unique((e) => e.id);
            print('businessList ${businessList.length}');

            isLoadingBusiness.value = false;

            canLoadMoreBusiness = result.length >= metadata.perPage;
            totalBusinessFound.value = metadata.totalCount;

            businessPage += 1;
            update();
            callback();
          });
    } else {
      callback();
    }
  }

  favUnFavBusiness(BusinessModel business) {
    bool isFav = !business.isFavourite;
    currentBusiness.value?.isFavourite = isFav;
    currentBusiness.refresh();
    businessList.value = businessList.map((currentItem) {
      if (currentBusiness.value!.id == currentItem.id) {
        currentItem.isFavourite = isFav;
      }
      return currentItem;
    }).toList();

    // update();

    OffersApi.favUnfavBusiness(isFav, business.id);
  }

  getOffers(VoidCallback callback) {
    if (canLoadMoreOffers) {
      OffersApi.getOffers(
          page: offerPage,
          searchModel: offerSearchModel,
          resultCallback: (result, metadata) {
            offers.addAll(result);
            offers.unique((e) => e.id);
            isLoadingOffers.value = false;

            canLoadMoreOffers = result.length >= metadata.perPage;
            totalOffersFound.value = metadata.totalCount;
            offerPage += 1;
            update();
            callback();
          });
    } else {
      callback();
    }
  }

  favUnFavOffer(OfferModel offer) {
    bool isFav = !offer.isFavourite;
    currentOffer.value?.isFavourite = isFav;
    currentOffer.refresh();
    offers.value = offers.map((currentItem) {
      if (currentOffer.value!.id == currentItem.id) {
        currentItem.isFavourite = isFav;
      }
      return currentItem;
    }).toList();

    // update();

    OffersApi.favUnfavOffer(isFav, offer.id);
  }

  // postBusinessComment(String comment) {
  //   comments.add(CommentModel.fromNewMessage(
  //       CommentType.text, _userProfileManager.user.value!,
  //       comment: comment));
  //   OffersApi.postComment(comment: comment, offerId: currentOffer.value!.id);
  // }
  //
  // getBusinessComments(VoidCallback callback) {
  //   if (canLoadMoreComment) {
  //     OffersApi.getComments(
  //         page: commentPage,
  //         offerId: currentBusiness.value!.id,
  //         resultCallback: (result, metadata) {
  //           comments.addAll(result);
  //           comments.unique((e) => e.id);
  //           isLoadingComments.value = false;
  //
  //           canLoadMoreComment = result.length >= metadata.perPage;
  //           commentPage += 1;
  //           update();
  //           callback();
  //         });
  //   } else {
  //     callback();
  //   }
  // }

  postOfferComment(String comment) {
    comments.add(CommentModel.fromNewMessage(
        CommentType.text, _userProfileManager.user.value!,
        comment: comment));
    OffersApi.postComment(comment: comment, offerId: currentOffer.value!.id);
  }

  getOfferComments(VoidCallback callback) {
    if (canLoadMoreComment) {
      OffersApi.getComments(
          page: commentPage,
          offerId: currentOffer.value!.id,
          resultCallback: (result, metadata) {
            comments.addAll(result);
            comments.unique((e) => e.id);
            isLoadingComments.value = false;

            canLoadMoreComment = result.length >= metadata.perPage;
            commentPage += 1;
            update();
            callback();
          });
    } else {
      callback();
    }
  }

  getFavOffers(VoidCallback callback) {
    if (canLoadMoreFavOffers) {
      OffersApi.getFavOffers(
          page: favOfferPage,
          searchModel: favOfferSearchModel,
          resultCallback: (result, metadata) {
            favOffers.addAll(result);
            favOffers.unique((e) => e.id);
            isLoadingFavOffer.value = false;

            canLoadMoreFavOffers = result.length >= metadata.perPage;
            totalFavOffersFound.value = metadata.totalCount;

            favOfferPage += 1;
            update();
            callback();
          });
    } else {
      callback();
    }
  }
}
