import 'dart:math';
import 'package:foap/components/post_card/post_card.dart';
import 'package:foap/components/sm_tab_bar.dart';
import 'package:foap/components/static_map_widget.dart';
import 'package:foap/helper/imports/event_imports.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../post/add_post_screen.dart';

class EventDetail extends StatefulWidget {
  final EventModel event;
  final VoidCallback needRefreshCallback;

  const EventDetail({
    super.key,
    required this.event,
    required this.needRefreshCallback,
  });

  @override
  EventDetailState createState() => EventDetailState();
}

class EventDetailState extends State<EventDetail> {
  final EventDetailController _eventDetailController = EventDetailController();
  final UserProfileManager _userProfileManager = Get.find();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<String> tabs = [aboutString.tr, postsString.tr];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _eventDetailController.setEvent(widget.event);
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
      body: DefaultTabController(
          length: tabs.length,
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                      height: 280,
                      width: Get.width,
                      child: CachedNetworkImage(
                        imageUrl: widget.event.image,
                        fit: BoxFit.cover,
                      )),
                  appBar(),
                ],
              ),
              SMTabBar(tabs: tabs, canScroll: false),
              Expanded(
                child: TabBarView(children: [about(), postsView()]),
              )
            ],
          )),
    );
  }

  Widget about() {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              Heading4Text(
                widget.event.name,
                weight: TextWeight.semiBold,
              ),
              const SizedBox(
                height: 20,
              ),
              attendingUsersList(),
              divider().vp(20),
              eventInfo(),
              divider().vp(20),
              eventOrganiserWidget(),
              divider().vp(20),
              eventGallery(),
              const SizedBox(
                height: 24,
              ),
              if (widget.event.latitude.isNotEmpty &&
                  widget.event.longitude.isNotEmpty)
                eventLocation(),
              const SizedBox(
                height: 150,
              ),
            ],
          ).hp(DesignConstants.horizontalPadding),
        ),
        if (!widget.event.isFree)
          Obx(() => _eventDetailController.isLoading.value == true
              ? Container()
              : _eventDetailController.event.value?.isCompleted == true
                  ? eventClosedWidget()
                  : _eventDetailController.event.value?.ticketsAdded == true
                      ? _eventDetailController.event.value?.isSoldOut == true
                          ? soldOutWidget()
                          : buyTicketWidget()
                      : ticketNotAddedWidget())
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
                BodyLargeText(widget.event.startAtFullDate,
                    weight: TextWeight.medium),
                const SizedBox(
                  height: 5,
                ),
                BodySmallText(widget.event.startAtTime,
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BodyLargeText(locationString.tr, weight: TextWeight.medium),
                  const SizedBox(
                    height: 5,
                  ),
                  BodySmallText(
                      '${widget.event.placeName} ${widget.event.completeAddress}',
                      weight: TextWeight.regular)
                ],
              ),
            )
          ],
        ),
        if (!widget.event.isFree)
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
                  BodyLargeText(priceString.tr, weight: TextWeight.medium),
                  const SizedBox(
                    height: 5,
                  ),
                  BodySmallText(
                      '\$${_eventDetailController.minTicketPrice} - \$${_eventDetailController.maxTicketPrice} ',
                      weight: TextWeight.regular)
                ],
              )
            ],
          ).tp(20),
      ],
    );
  }

  Widget postsView() {
    return Obx(() => ListView.separated(
            padding: const EdgeInsets.only(top: 25, bottom: 100),
            itemBuilder: (BuildContext context, index) {
              return PostCard(
                model: _eventDetailController.posts[index],
                removePostHandler: () {},
                blockUserHandler: () {},
              );
            },
            separatorBuilder: (BuildContext context, index) {
              return const SizedBox(
                height: 40,
              );
            },
            itemCount: _eventDetailController.posts.length)
        .addPullToRefresh(
            refreshController: _refreshController,
            onRefresh: () {
              _eventDetailController.refreshPosts(
                  id: widget.event.id,
                  callback: () {
                    _refreshController.refreshCompleted();
                  });
            },
            onLoading: () {
              _eventDetailController.loadMorePosts(
                  id: widget.event.id,
                  callback: () {
                    _refreshController.loadComplete();
                  });
            },
            enablePullUp: true,
            enablePullDown: true));
  }

  Widget eventOrganiserWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          return _eventDetailController.event.value?.organizers.isNotEmpty ==
                  true
              ? Column(
                  children: [
                    for (EventOrganizer sponsor
                        in _eventDetailController.event.value?.organizers ?? [])
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          UserAvatarView(
                            user: _userProfileManager.user.value!,
                            size: 30,
                            hideLiveIndicator: true,
                            hideOnlineIndicator: true,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BodyLargeText(sponsor.name,
                                  weight: TextWeight.regular),
                              BodySmallText(organizerString.tr,
                                  weight: TextWeight.regular),
                            ],
                          )
                        ],
                      ).bP16,
                  ],
                )
              : Container();
        }),
        const SizedBox(
          height: 25,
        ),
        Heading6Text(aboutString.tr, weight: TextWeight.medium),
        const SizedBox(
          height: 10,
        ),
        BodyLargeText(widget.event.description, weight: TextWeight.regular),
        const SizedBox(
          height: 40,
        ),
      ],
    );
  }

  Widget eventLocation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Heading6Text(locationString.tr, weight: TextWeight.medium),
        const SizedBox(
          height: 10,
        ),
        StaticMapWidget(
          latitude: double.parse(widget.event.latitude),
          longitude: double.parse(widget.event.longitude),
          height: 250,
          width: Get.width.toInt(),
        ).ripple(() {
          openDirections();
        }),
        const SizedBox(
          height: 40,
        ),
      ],
    );
  }

  Widget soldOutWidget() {
    return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          color: AppColorConstants.cardColor,
          height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/out_of_stock.png',
                height: 20,
                width: 20,
                color: AppColorConstants.themeColor,
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                  child: BodyLargeText(
                eventIsSoldOutString.tr,
              )),
            ],
          ).hp(DesignConstants.horizontalPadding),
        ));
  }

  Widget eventClosedWidget() {
    return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          color: AppColorConstants.cardColor,
          height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/out_of_stock.png',
                height: 20,
                width: 20,
                color: AppColorConstants.themeColor,
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                  child: BodyLargeText(
                eventClosedString.tr,
              )),
            ],
          ).hp(DesignConstants.horizontalPadding),
        ));
  }

  Widget attendingUsersList() {
    return Row(
      children: [
        // SizedBox(
        //   height: 20,
        //   width: min(widget.event.gallery.length, 5) * 17,
        //   child: ListView.builder(
        //     scrollDirection: Axis.horizontal,
        //     itemBuilder: (ctx, index) {
        //       return Align(
        //         widthFactor: 0.6,
        //         child: CachedNetworkImage(
        //           imageUrl: widget.event.gallery[index],
        //           width: 20,
        //           height: 20,
        //           fit: BoxFit.cover,
        //         ).borderWithRadius( value: 1, radius: 10),
        //       );
        //     },
        //     itemCount: min(widget.event.gallery.length, 5),
        //   ),
        // ),
        BodySmallText(
            '${widget.event.totalMembers} ${goingString.tr.toLowerCase()}',
            weight: TextWeight.regular),
        const Spacer()
      ],
    );
  }

  Widget ticketNotAddedWidget() {
    return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          color: AppColorConstants.cardColor,
          height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/tickets.png',
                height: 20,
                width: 20,
                color: AppColorConstants.themeColor,
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  ticketWillBeAvailableSoonString.tr,
                  style: TextStyle(fontSize: FontSizes.b2),
                ),
              ),
            ],
          ).hp(DesignConstants.horizontalPadding),
        ));
  }

  Widget buyTicketWidget() {
    return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          color: AppColorConstants.cardColor,
          height: 90,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                  height: 40,
                  width: Get.width * 0.4,
                  // color: ColorConstants.themeColor,
                  child: Row(
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
                      )
                    ],
                  ).hP8.ripple(() {
                    Get.bottomSheet(SelectUserToGiftEventTicket(
                      event: _eventDetailController.event.value!,
                      isAlreadyBooked: false,
                    ).topRounded(40));
                  })).round(5),
              BodyLargeText(
                orString.tr,
                // style: TextStyle(fontSize: FontSizes.b2),
              ).hp(DesignConstants.horizontalPadding),
              SizedBox(
                height: 40,
                width: Get.width * 0.3,
                child: AppThemeButton(
                  text: buyTicketString.tr,
                  onPress: () {
                    Get.to(() => BuyTicket(
                          event: _eventDetailController.event.value!,
                        ));
                  },
                ),
              )
            ],
          ).p16,
        ));
  }

  Widget eventGallery() {
    return widget.event.gallery.isNotEmpty
        ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Heading6Text(eventGalleryString.tr, weight: TextWeight.medium),
                BodyLargeText(
                  seeAllString.tr,
                  color: AppColorConstants.themeColor,
                ).ripple(() {
                  Get.to(() => EventGallery(event: widget.event));
                }),
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
                    imageUrl: widget.event.gallery[index],
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
                itemCount: min(widget.event.gallery.length, 4),
              ),
            )
          ])
        : Container();
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
                        coords: Coords(double.parse(widget.event.latitude),
                            double.parse(widget.event.longitude)),
                        title: widget.event.completeAddress,
                      );
                    },
                    title: Heading5Text(
                      '${openInString.tr} ${map.mapName}',
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
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
            if (widget.event.isTicketBooked || widget.event.isFree)
              ThemeIconWidget(
                ThemeIcon.plus,
                size: 25,
                color: Colors.white,
              ).ripple(() {
                Future.delayed(
                  Duration.zero,
                  () => showGeneralDialog(
                      context: context,
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          AddPostScreen(
                            postType: PostType.event,
                            event: widget.event,
                            postCompletionHandler: () {
                              _eventDetailController.refreshPosts(
                                  id: widget.event.id, callback: () {});
                            },
                          )),
                );
              }),
          ],
        ).hp(DesignConstants.horizontalPadding),
      ),
    );
  }
}
