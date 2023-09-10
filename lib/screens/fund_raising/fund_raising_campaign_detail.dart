import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:foap/screens/fund_raising/donors_list.dart';
import '../../components/sm_tab_bar.dart';
import '../../controllers/fund_raising/fund_raising_controller.dart';
import '../../helper/imports/common_import.dart';
import '../../model/fund_raising_campaign.dart';
import 'about_campaign.dart';
import 'campaign_comment_screens.dart';

class FundRaisingCampaignDetail extends StatelessWidget {
  final FundRaisingController fundRaisingController = Get.find();
  final FundRaisingCampaign campaign;

  FundRaisingCampaignDetail({Key? key, required this.campaign})
      : super(key: key);

  final List<String> tabs = [
    aboutString.tr,
    commentsString.tr,
    donorsString.tr
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: Get.height * 0.4,
                child: Stack(
                  children: [
                    CarouselSlider(
                      items: mediaList(),
                      options: CarouselOptions(
                        aspectRatio: 1,
                        enlargeCenterPage: false,
                        enableInfiniteScroll: false,
                        height: double.infinity,
                        viewportFraction: 1,
                        onPageChanged: (index, reason) {
                          fundRaisingController.updateGallerySlider(index);
                        },
                      ),
                    ),
                    if (mediaList().length > 1)
                      Positioned(
                          bottom: 10,
                          left: 0,
                          right: 0,
                          child: Align(
                            alignment: Alignment.center,
                            child: Obx(
                              () {
                                return DotsIndicator(
                                  dotsCount: mediaList().length,
                                  position:
                                      fundRaisingController.currentIndex.value,
                                  decorator: DotsDecorator(
                                      activeColor:
                                          Theme.of(Get.context!).primaryColor),
                                );
                              },
                            ),
                          )),
                  ],
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: Get.height - (Get.height * 0.4),
                  child: DefaultTabController(
                      length: tabs.length,
                      initialIndex: 0,
                      child: Column(
                        children: [
                          SMTabBar(tabs: tabs,canScroll: false),
                          const SizedBox(
                            height: 20,
                          ),
                          Expanded(
                            child: TabBarView(children: [
                              AboutCampaign(
                                campaign: campaign,
                              ).hp(DesignConstants.horizontalPadding),
                              const CampaignCommentsScreen(),
                              DonorsList()
                            ]),
                          ),
                        ],
                      )),
                ),
              ),
            ],
          ),
          backNavigationBarWithTrailingWidget(
              title: '',
              widget: Obx(() => Container(
                    height: 40,
                    width: 40,
                    color: AppColorConstants.themeColor.withOpacity(0.2),
                    child: ThemeIconWidget(
                        fundRaisingController.currentCampaign.value!.isFavourite
                            ? ThemeIcon.favFilled
                            : ThemeIcon.fav,
                        color: fundRaisingController
                                .currentCampaign.value!.isFavourite
                            ? AppColorConstants.red
                            : AppColorConstants.iconColor),
                  ).round(10).ripple(() {
                    fundRaisingController.favUnFavCampaign(
                        fundRaisingController.currentCampaign.value!);
                  }))),
        ],
      ),
    );
  }

  List<Widget> mediaList() {
    List<CachedNetworkImage> images = [];
    images.add(CachedNetworkImage(
      imageUrl: campaign.coverImage,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
    ));

    for (String image in campaign.allImages) {
      images.add(CachedNetworkImage(imageUrl: image));
    }

    return images;
  }
}
