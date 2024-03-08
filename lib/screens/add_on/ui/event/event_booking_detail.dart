import 'dart:math';
import 'package:foap/components/static_map_widget.dart';
import 'package:foap/helper/imports/event_imports.dart';
import 'package:foap/helper/number_extension.dart';
import 'package:foap/screens/profile/other_user_profile.dart';
import 'package:lottie/lottie.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:foap/helper/imports/common_import.dart';

class EventBookingDetail extends StatefulWidget {
  final EventBookingModel booking;

  const EventBookingDetail({
    super.key,
    required this.booking,
  });

  @override
  EventBookingDetailState createState() => EventBookingDetailState();
}

class EventBookingDetailState extends State<EventBookingDetail> {
  final EventBookingDetailController _eventBookingDetailController =
      EventBookingDetailController();
  final UserProfileManager _userProfileManager = Get.find();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _eventBookingDetailController.setEventBooking(widget.booking);
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: GetBuilder<EventBookingDetailController>(
          init: _eventBookingDetailController,
          builder: (ctx) {
            return _eventBookingDetailController.processingBooking.value != null
                ? statusView()
                : Stack(
                    children: [
                      CustomScrollView(
                        slivers: [
                          SliverList(
                              delegate: SliverChildListDelegate([
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(
                                    height: 300,
                                    child: CachedNetworkImage(
                                      imageUrl: widget.booking.event.image,
                                      fit: BoxFit.cover,
                                    )),
                                const SizedBox(
                                  height: 30,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Heading3Text(
                                      widget.booking.event.name,
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    attendingUsersList(),
                                    divider().vp(20),
                                    eventInfo(),
                                    divider().vP25,
                                    organizerWidget(),
                                    divider().vP25,
                                    bookingInfoWidget(),
                                    divider().vP25,
                                    if (widget.booking.giftedToUser != null)
                                      giftTo().bP25,
                                    eventLocationInfoWidget(),
                                    divider().vP25,
                                    if (widget.booking.event.gallery.isNotEmpty)
                                      eventGallery(),
                                    const SizedBox(
                                      height: 150,
                                    ),
                                  ],
                                ).hp(DesignConstants.horizontalPadding),
                              ],
                            ),
                          ]))
                        ],
                      ),
                      appBar(),
                      if (widget.booking.statusType ==
                              BookingStatus.confirmed &&
                          widget.booking.event.statusType ==
                              EventStatus.upcoming)
                        buttonsWidget()
                    ],
                  );
          }),
    );
  }

  Widget giftTo() {
    return Container(
      color: AppColorConstants.cardColor.withOpacity(0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BodyLargeText(giftedToString.tr, weight: TextWeight.semiBold),
          const SizedBox(
            height: 15,
          ),
          Row(
            children: [
              UserAvatarView(
                user: widget.booking.giftedToUser!,
                size: 50,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BodyLargeText(widget.booking.giftedToUser!.userName,
                      weight: TextWeight.medium),
                  BodySmallText(
                      '${widget.booking.giftedToUser!.city} ${widget.booking.giftedToUser!.country}',
                      weight: TextWeight.regular),
                ],
              ),
              const Spacer(),
              AppThemeBorderButton(
                  width: 90,
                  height: 35,
                  text: viewProfileString.tr,
                  textStyle: TextStyle(fontSize: FontSizes.b4),
                  onPress: () {
                    Get.to(() => OtherUserProfile(
                          userId: widget.booking.giftedToUser!.id,
                          user: widget.booking.giftedToUser!,
                        ));
                  }),
            ],
          )
        ],
      ).p16,
    ).round(10);
  }

  Widget giftBy() {
    return Container(
      color: AppColorConstants.cardColor.withOpacity(0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BodyLargeText(giftedByString.tr, weight: TextWeight.semiBold),
          const SizedBox(
            height: 15,
          ),
          Row(
            children: [
              UserAvatarView(
                user: widget.booking.giftedByUser!,
                size: 50,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BodyLargeText(widget.booking.giftedByUser!.userName,
                      weight: TextWeight.medium),
                  BodySmallText(
                      '${widget.booking.giftedByUser!.city} ${widget.booking.giftedByUser!.country}',
                      weight: TextWeight.regular),
                ],
              ),
              const Spacer(),
              AppThemeBorderButton(
                  width: 90,
                  height: 35,
                  text: viewProfileString.tr,
                  textStyle: TextStyle(fontSize: FontSizes.b4),
                  onPress: () {
                    Get.to(() => OtherUserProfile(
                          userId: widget.booking.giftedToUser!.id,
                          user: widget.booking.giftedToUser!,
                        ));
                  }),
            ],
          ),
        ],
      ).p16,
    ).round(10).hp(DesignConstants.horizontalPadding);
  }

  Widget buttonsWidget() {
    return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          color: AppColorConstants.cardColor,
          height: widget.booking.giftedToUser == null ? 150 : 90,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.booking.giftedToUser == null)
                SizedBox(
                    height: 40,
                    width: Get.width * 0.8,
                    // color: ColorConstants.themeColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ThemeIconWidget(
                          ThemeIcon.gift,
                          color: AppColorConstants.themeColor,
                          size: 28,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Heading6Text(
                          giftTicketString.tr,
                          color: AppColorConstants.themeColor,
                          weight: TextWeight.bold,
                        )
                      ],
                    ).hP8.ripple(() {
                      Get.bottomSheet(SelectUserToGiftEventTicket(
                        event: widget.booking.event,
                        isAlreadyBooked: true,
                        selectUserCallback: (user) {
                          _eventBookingDetailController.giftToUser(user);
                        },
                      ).topRounded(40));
                    })).round(5),
              SizedBox(
                height: 40,
                width: Get.width * 0.8,
                child: AppThemeButton(
                  text: cancelBookingString.tr,
                  onPress: () {
                    _eventBookingDetailController.cancelBooking(context);
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              )
            ],
          ).p16,
        ).topRounded(widget.booking.giftedToUser == null ? 50 : 25));
  }

  Widget attendingUsersList() {
    return Row(
      children: [
        // SizedBox(
        //   height: 20,
        //   width: min(widget.booking.event.gallery.length, 5) * 17,
        //   child: ListView.builder(
        //     scrollDirection: Axis.horizontal,
        //     itemBuilder: (ctx, index) {
        //       return Align(
        //         widthFactor: 0.6,
        //         child: CachedNetworkImage(
        //           imageUrl: widget.booking.event.gallery[index],
        //           width: 20,
        //           height: 20,
        //           fit: BoxFit.cover,
        //         ).borderWithRadius(value: 1, radius: 10),
        //       );
        //     },
        //     itemCount: min(widget.booking.event.gallery.length, 5),
        //   ),
        // ),
        // const SizedBox(width: 10,),
        BodySmallText('${widget.booking.event.totalMembers.formatNumber}+ going', weight: TextWeight.regular),
        const Spacer()
      ],
    );
  }

  Widget eventInfo() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                    color: AppColorConstants.themeColor.withOpacity(0.2),
                    child: ThemeIconWidget(ThemeIcon.calendar,
                            color: AppColorConstants.themeColor)
                        .p8)
                .circular,
            const SizedBox(
              width: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyLargeText(widget.booking.event.startAtFullDate,
                    weight: TextWeight.medium),
                const SizedBox(
                  height: 5,
                ),
                BodySmallText(widget.booking.event.startAtTime,
                    weight: TextWeight.regular)
              ],
            )
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                    color: AppColorConstants.themeColor.withOpacity(0.2),
                    child: ThemeIconWidget(ThemeIcon.location,
                            color: AppColorConstants.themeColor)
                        .p8)
                .circular,
            const SizedBox(
              width: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyLargeText(locationString.tr, weight: TextWeight.medium),
                const SizedBox(
                  height: 5,
                ),
                BodySmallText(
                    '${widget.booking.event.placeName} ${widget.booking.event.completeAddress}',
                    weight: TextWeight.regular)
              ],
            )
          ],
        )
      ],
    );
  }

  Widget organizerWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            for (EventOrganizer sponsor in widget.booking.event.organizers)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  UserAvatarView(
                    user: _userProfileManager.user.value!,
                    size: 30,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BodyLargeText(sponsor.name, weight: TextWeight.regular),
                      BodySmallText(organizerString.tr,
                          weight: TextWeight.regular),
                    ],
                  )
                ],
              ).bP16,
          ],
        ),
        const SizedBox(height: 25),
        Heading6Text(aboutString.tr, weight: TextWeight.medium),
        const SizedBox(
          height: 20,
        ),
        BodyLargeText(widget.booking.event.description,
            weight: TextWeight.regular),
        const SizedBox(
          height: 40,
        ),
      ],
    );
  }

  Widget bookingInfoWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: AppColorConstants.themeColor.withOpacity(0.4),
          child: Heading6Text(bookingInfoString.tr, weight: TextWeight.medium)
              .setPadding(top: 5, bottom: 5, left: 10, right: 10),
        ).round(5),
        const SizedBox(
          height: 20,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                width: 120,
                child: BodyMediumText(bookingIdString.tr,
                    weight: TextWeight.medium)),
            Container(
              height: 5,
              width: 5,
              color: AppColorConstants.themeColor,
            ).circular.rP16,
            BodySmallText(
              widget.booking.id.toString(),
            )
          ],
        ),
        const SizedBox(
          height: 15,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                width: 120,
                child: BodyMediumText(bookingStatusString.tr,
                    weight: TextWeight.medium)),
            Container(
              height: 5,
              width: 5,
              color: AppColorConstants.themeColor,
            ).circular.rP16,
            Container(
              color: widget.booking.statusType == BookingStatus.cancelled
                  ? AppColorConstants.red.withOpacity(0.7)
                  : AppColorConstants.themeColor.withOpacity(0.7),
              child: BodySmallText(
                widget.booking.statusType == BookingStatus.cancelled
                    ? cancelledString.tr
                    : confirmedString.tr,
              ).p4,
            ).round(5)
          ],
        ),
        const SizedBox(
          height: 15,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                width: 120,
                child: BodyMediumText(bookingDateString.tr,
                    weight: TextWeight.medium)),
            Container(
              height: 5,
              width: 5,
              color: AppColorConstants.themeColor,
            ).circular.rP16,
            BodySmallText(
              widget.booking.bookingDatetime,
            )
          ],
        ),
        const SizedBox(
          height: 15,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 120,
              child: BodyMediumText(ticketTypeString.tr,
                  weight: TextWeight.medium),
            ),
            Container(
              height: 5,
              width: 5,
              color: AppColorConstants.themeColor,
            ).circular.rP16,
            BodySmallText(widget.booking.ticketType.name,
                weight: TextWeight.medium)
          ],
        ),
        const SizedBox(
          height: 15,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                width: 120,
                child:
                    BodyMediumText(priceString.tr, weight: TextWeight.medium)),
            Container(
              height: 5,
              width: 5,
              color: AppColorConstants.themeColor,
            ).circular.rP16,
            BodySmallText(
              '\$${widget.booking.paidAmount}',
            )
          ],
        ),
      ],
    );
  }

  Widget eventLocationInfoWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: AppColorConstants.themeColor.withOpacity(0.4),
          child: Heading6Text(locationString.tr, weight: TextWeight.medium)
              .setPadding(top: 5, bottom: 5, left: 10, right: 10),
        ).round(5),
        const SizedBox(
          height: 20,
        ),
        StaticMapWidget(
          latitude: double.parse(widget.booking.event.latitude),
          longitude: double.parse(widget.booking.event.longitude),
          height: 250,
          width: Get.width.toInt(),
        ).ripple(() {
          openDirections();
        }),
      ],
    );
  }

  Widget eventGallery() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            color: AppColorConstants.themeColor.withOpacity(0.4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Heading6Text(eventGalleryString.tr, weight: TextWeight.medium),
              ],
            ).setPadding(top: 5, bottom: 5, left: 10, right: 10),
          ).round(5),
          BodyLargeText(
            seeAllString.tr,
            color: AppColorConstants.themeColor,
          ).ripple(() {
            Get.to(() => EventGallery(event: widget.booking.event));
          })
        ],
      ),
      const SizedBox(
        height: 20,
      ),
      SizedBox(
        height: 80,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemBuilder: (ctx, index) {
            return CachedNetworkImage(
              imageUrl: widget.booking.event.gallery[index],
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ).round(10);
          },
          separatorBuilder: (ctx, index) {
            return const SizedBox(
              width: 10,
            );
          },
          itemCount: min(widget.booking.event.gallery.length, 4),
        ),
      )
    ]);
  }

  Widget appBar() {
    return Positioned(
      child: Container(
        height: 150.0,
        width: Get.width,
        decoration: BoxDecoration(
            color: Colors.white,
            gradient: LinearGradient(
                begin: FractionalOffset.topCenter,
                end: FractionalOffset.bottomCenter,
                colors: [
                  Colors.black,
                  Colors.black.withOpacity(0.5),
                  Colors.grey.withOpacity(0.0),
                ],
                stops: const [
                  0.0,
                  0.5,
                  1.0
                ])),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ThemeIconWidget(
              ThemeIcon.backArrow,
              size: 20,
              color: Colors.white,
            ).ripple(() {
              Get.back();
            }),
            if (widget.booking.statusType != BookingStatus.cancelled &&
                widget.booking.giftedToUser == null)
              Container(
                color: AppColorConstants.themeColor.withOpacity(0.7),
                child: Heading6Text(viewETicketString.tr,
                        weight: TextWeight.medium)
                    .setPadding(top: 5, bottom: 5, left: 10, right: 10),
              ).round(5).ripple(() {
                Get.to(() => ETicket(
                      booking: widget.booking,
                      autoSendTicket: false,
                    ));
              }),
          ],
        ).hp(DesignConstants.horizontalPadding),
      ),
    );
  }

  openDirections() async {
    final availableMaps = await MapLauncher.installedMaps;

    showModalBottomSheet(
      context: Get.context!,
      builder: (BuildContext context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Wrap(
              children: <Widget>[
                for (var map in availableMaps)
                  ListTile(
                    onTap: () {
                      map.showMarker(
                        coords: Coords(
                            double.parse(widget.booking.event.latitude),
                            double.parse(widget.booking.event.longitude)),
                        title: widget.booking.event.completeAddress,
                      );
                    },
                    title: Heading5Text(
                      '${openInString.tr} ${map.mapName}',
                    ),
                    // leading: SvgPicture.asset(
                    //   map.icon,
                    //   height: 30.0,
                    //   width: 30.0,
                    // ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget statusView() {
    return _eventBookingDetailController.processingBooking.value ==
            ProcessingBookingStatus.inProcess
        ? processingView()
        : _eventBookingDetailController.processingBooking.value ==
                ProcessingBookingStatus.gifted
            ? ticketGiftedView()
            : _eventBookingDetailController.processingBooking.value ==
                    ProcessingBookingStatus.cancelled
                ? bookingCancelledView()
                : errorView();
  }

  Widget processingView() {
    return SizedBox(
      height: Get.height,
      width: Get.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/lottie/loading.json'),
          const SizedBox(
            height: 40,
          ),
          Heading4Text(
            inProcessingString.tr,
            weight: TextWeight.semiBold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 10,
          ),
          BodyLargeText(
            doNotCloseAppString.tr,
            weight: TextWeight.regular,
            textAlign: TextAlign.center,
          ),
        ],
      ).hp(DesignConstants.horizontalPadding),
    );
  }

  Widget errorView() {
    return SizedBox(
      height: Get.height,
      width: Get.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/lottie/error.json'),
          const SizedBox(
            height: 40,
          ),
          Heading4Text(
            errorInBookingString.tr,
            weight: TextWeight.semiBold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 10,
          ),
          BodyLargeText(
            pleaseTryAgainString.tr,
            weight: TextWeight.regular,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 40,
          ),
          SizedBox(
              width: 100,
              height: 40,
              child: AppThemeBorderButton(
                  text: tryAgainString.tr,
                  onPress: () {
                    Get.back();
                  }))
        ],
      ).hp(DesignConstants.horizontalPadding),
    );
  }

  Widget ticketGiftedView() {
    return SizedBox(
      height: Get.height,
      width: Get.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/lottie/success.json'),
          const SizedBox(
            height: 40,
          ),
          Heading3Text(
            ticketGiftedString.tr,
            weight: TextWeight.semiBold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 40,
          ),
          SizedBox(
              width: 200,
              height: 50,
              child: AppThemeBorderButton(
                  text: bookMoreTicketsString.tr,
                  onPress: () {
                    Get.back();
                  }))
        ],
      ).hp(DesignConstants.horizontalPadding),
    );
  }

  Widget bookingCancelledView() {
    return SizedBox(
      height: Get.height,
      width: Get.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/lottie/success.json'),
          const SizedBox(
            height: 40,
          ),
          Heading3Text(
            bookingCancelledString.tr,
            weight: TextWeight.semiBold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 40,
          ),
          SizedBox(
              width: 200,
              height: 50,
              child: AppThemeBorderButton(
                  text: bookMoreTicketsString.tr,
                  onPress: () {
                    Get.back();
                  }))
        ],
      ).hp(DesignConstants.horizontalPadding),
    );
  }
}
