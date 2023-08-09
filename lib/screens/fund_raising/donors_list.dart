import 'package:flutter/material.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/fund_raising/fund_raising_dashboard.dart';
import 'package:get/get.dart';
import '../../components/empty_states.dart';
import '../../components/shimmer_widgets.dart';
import '../../components/user_card.dart';
import '../../controllers/fund_raising/fund_raising_controller.dart';
import '../../controllers/misc/users_controller.dart';
import '../../helper/localization_strings.dart';

class DonorsList extends StatelessWidget {
  final FundRaisingController fundRaisingController = Get.find();

  DonorsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return usersView();
  }

  Widget usersView() {
    ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.position.pixels) {
        if (!fundRaisingController.isLoadingDonor.value) {
          fundRaisingController.getCampaignDonors(() {});
        }
      }
    });

    return Obx(() => fundRaisingController.isLoadingDonor.value
        ? const ShimmerUsers()
        : fundRaisingController.donors.isNotEmpty
            ? GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15.0,
                    mainAxisSpacing: 15.0,
                    childAspectRatio: 0.7),
                controller: scrollController,
                padding: EdgeInsets.only(
                    top: 20,
                    left: DesignConstants.horizontalPadding,
                    right: DesignConstants.horizontalPadding,
                    bottom: 100),
                itemCount: fundRaisingController.donors.length,
                itemBuilder: (BuildContext ctx, int index) {
                  return UserCard(
                    profile: fundRaisingController.donors[index],
                    followCallback: () {
                      fundRaisingController
                          .followDonor(fundRaisingController.donors[index]);
                    },
                    unFollowCallback: () {
                      fundRaisingController
                          .unFollowDonor(fundRaisingController.donors[index]);
                    },
                  );
                },
              )
            : SizedBox(
                height: Get.size.height * 0.5,
                child: emptyUser(title: noUserFoundString.tr, subTitle: ''),
              ));
  }
}
