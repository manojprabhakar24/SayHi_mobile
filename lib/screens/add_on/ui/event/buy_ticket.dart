import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/settings_menu/settings_controller.dart';
import 'package:foap/helper/imports/event_imports.dart';

class BuyTicket extends StatefulWidget {
  final EventModel event;
  final UserModel? giftToUser;

  const BuyTicket({super.key, required this.event, this.giftToUser});

  @override
  State<BuyTicket> createState() => _BuyTicketState();
}

class _BuyTicketState extends State<BuyTicket> {
  final BuyTicketController _buyTicketController = BuyTicketController();
  final EventDetailController _eventDetailController = EventDetailController();
  final SettingsController _settingsController = Get.find();

  TextEditingController couponCode = TextEditingController();

  @override
  void initState() {
    _buyTicketController.setData(
        event: widget.event, giftToUser: widget.giftToUser);
    _eventDetailController.loadEventCoupons(widget.event.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: SizedBox(
        height: Get.height,
        child: Column(
          children: [
            backNavigationBar(title: buyTicketString.tr),
            Expanded(
              child: Obx(() => Stack(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 25,
                              ),
                              if (widget.giftToUser != null) giftTo().bP25,
                              ticketType(),
                              const SizedBox(
                                height: 25,
                              ),
                              _buyTicketController.selectedTicketType.value !=
                                      null
                                  ? Column(
                                      children: [
                                        eventDetail().hp(
                                            DesignConstants.horizontalPadding),
                                        const SizedBox(
                                          height: 25,
                                        ),
                                        couponsList(),
                                        // const SizedBox(
                                        //   height: 25,
                                        // ),
                                        divider().tP8,
                                        const SizedBox(
                                          height: 25,
                                        ),
                                        orderSummary().hp(
                                            DesignConstants.horizontalPadding),
                                        const SizedBox(
                                          height: 150,
                                        ),
                                      ],
                                    )
                                  : Container(),
                            ]),
                      ),
                      Obx(() =>
                          _buyTicketController.ticketOrder.eventTicketTypeId !=
                                  null
                              ? Positioned(
                                  bottom: 20,
                                  left: 25,
                                  right: 25,
                                  child: checkoutButton())
                              : Container())
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget eventDetail() {
    return Container(
      height: 120,
      color: AppColorConstants.cardColor.withOpacity(0.4),
      child: Row(
        children: [
          CachedNetworkImage(
            imageUrl: widget.event.image,
            fit: BoxFit.cover,
            width: 80,
            height: 80,
          ).round(15),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BodySmallText(widget.event.startAtFullDate.toUpperCase(),
                        maxLines: 1, weight: TextWeight.regular),
                    const SizedBox(
                      height: 5,
                    ),
                    BodyLargeText(widget.event.name,
                        maxLines: 1, weight: TextWeight.bold),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          height: 30,
                          width: 30,
                          color: AppColorConstants.cardColor.darken(),
                          child: ThemeIconWidget(ThemeIcon.minus),
                        ).round(5).ripple(() {
                          _buyTicketController.removeTicket();
                        }),
                        Obx(() => SizedBox(
                              width: 25,
                              child: Center(
                                child: BodyMediumText(_buyTicketController
                                    .numberOfTickets
                                    .toString()),
                              ),
                            )).hp(DesignConstants.horizontalPadding),
                        Container(
                          height: 30,
                          width: 30,
                          color: AppColorConstants.cardColor.darken(),
                          child: ThemeIconWidget(ThemeIcon.plusSymbol),
                        ).round(5).ripple(() {
                          _buyTicketController.addTicket();
                        }),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ).p8,
    ).round(15);
  }

  Widget giftTo() {
    return Container(
      color: AppColorConstants.cardColor.withOpacity(0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BodyLargeText(
            giftingToString.tr,
            weight: TextWeight.semiBold,
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            children: [
              UserAvatarView(
                user: widget.giftToUser!,
                size: 50,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BodyLargeText(widget.giftToUser!.userName,
                      weight: TextWeight.medium),
                  BodySmallText(
                      '${widget.giftToUser!.city ?? ''} ${widget.giftToUser!.country ?? ''}',
                      weight: TextWeight.regular),
                ],
              )
            ],
          )
        ],
      ).p16,
    ).round(10).hp(DesignConstants.horizontalPadding);
  }

  Widget ticketType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BodyLargeText(ticketTypeString.tr, weight: TextWeight.semiBold)
            .hp(DesignConstants.horizontalPadding),
        const SizedBox(
          height: 25,
        ),
        SizedBox(
          height: 170,
          child: ListView.separated(
            padding: EdgeInsets.only(
                left: DesignConstants.horizontalPadding,
                right: DesignConstants.horizontalPadding),
            scrollDirection: Axis.horizontal,
            itemCount: widget.event.ticketType.length,
            itemBuilder: (context, index) {
              return Obx(() => ticketTypeWidget(
                          ticket: widget.event.ticketType[index],
                          isSelected: _buyTicketController
                                  .selectedTicketType.value?.id ==
                              widget.event.ticketType[index].id)
                      .ripple(() {
                    if (widget.event.ticketType[index].availableTicket > 0) {
                      _buyTicketController
                          .selectTicketType(widget.event.ticketType[index]);
                    }
                  }));
            },
            separatorBuilder: (context, index) {
              return const SizedBox(
                width: 20,
              );
            },
          ),
        )
      ],
    );
  }

  Widget ticketTypeWidget(
      {required EventTicketType ticket, required bool isSelected}) {
    return Container(
      color: AppColorConstants.cardColor,
      width: Get.width * 0.6,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                      color: Theme.of(context)
                          .primaryColor
                          .darken()
                          .withOpacity(0.2),
                      child:
                          Heading4Text(ticket.name, weight: TextWeight.medium)
                              .setPadding(
                                  left: DesignConstants.horizontalPadding,
                                  right: DesignConstants.horizontalPadding,
                                  top: 4,
                                  bottom: 4))
                  .round(5),
              const SizedBox(
                height: 10,
              ),
              BodyLargeText('\$${ticket.price}', weight: TextWeight.bold),
              const SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  BodyLargeText(
                    totalSeatsString.tr,
                    color: AppColorConstants.themeColor,
                    weight: TextWeight.bold,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  BodyLargeText('${ticket.limit}', weight: TextWeight.regular),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  BodyLargeText(
                    availableSeatsString.tr,
                    color: AppColorConstants.themeColor,
                    weight: TextWeight.bold,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  BodyLargeText('${ticket.availableTicket}',
                      weight: TextWeight.regular),
                ],
              )
            ],
          ),
        ],
      ).p16,
    ).borderWithRadius(
        value: isSelected == true ? 2 : 1,
        radius: 20,
        color: isSelected == true ? AppColorConstants.themeColor : null);
  }

  Widget couponsList() {
    return Obx(() => _eventDetailController.coupons.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Heading5Text(applyCouponString.tr, weight: TextWeight.medium)
                  .hp(DesignConstants.horizontalPadding),
              const SizedBox(
                height: 40,
              ),
              SizedBox(
                height: 150,
                child: ListView.separated(
                  padding: EdgeInsets.only(
                      left: DesignConstants.horizontalPadding,
                      right: DesignConstants.horizontalPadding),
                  scrollDirection: Axis.horizontal,
                  itemCount: _eventDetailController.coupons.length,
                  itemBuilder: (context, index) {
                    return Obx(() => couponWidget(
                                coupon: _eventDetailController.coupons[index],
                                isSelected: _buyTicketController
                                        .selectedCoupon.value?.id ==
                                    _eventDetailController.coupons[index].id)
                            .ripple(() {
                          if (_buyTicketController
                                  .selectedTicketType.value!.availableTicket >
                              0) {
                            _buyTicketController.selectEventCoupon(
                                _eventDetailController.coupons[index]);
                          }
                        }));
                  },
                  separatorBuilder: (context, index) {
                    return const SizedBox(
                      width: 20,
                    );
                  },
                ),
              )
            ],
          )
        : Container());
  }

  Widget couponWidget({required EventCoupon coupon, required bool isSelected}) {
    return Container(
      color: AppColorConstants.cardColor,
      width: Get.width * 0.7,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Heading4Text('${codeString.tr} :', weight: TextWeight.medium),
                  const SizedBox(
                    width: 5,
                  ),
                  Heading4Text(
                    coupon.code,
                    weight: TextWeight.medium,
                    color: AppColorConstants.themeColor,
                  ),
                ],
              ),
              divider(color: AppColorConstants.themeColor).vP8,
              Row(
                children: [
                  BodyMediumText('${discountString.tr} :',
                      weight: TextWeight.medium),
                  const SizedBox(
                    width: 5,
                  ),
                  BodyMediumText(
                    '\$${coupon.discount}',
                    weight: TextWeight.medium,
                    color: AppColorConstants.themeColor,
                  ),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  BodyMediumText('${minimumOrderPriceString.tr} :',
                      weight: TextWeight.medium),
                  const SizedBox(
                    width: 5,
                  ),
                  BodyMediumText(
                    '\$${coupon.minimumOrderPrice}',
                    weight: TextWeight.medium,
                    color: AppColorConstants.themeColor,
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          // ThemeIconWidget(ThemeIcon.checkMarkWithCircle, size: 28),
        ],
      ).p25,
    ).borderWithRadius(
        value: isSelected == true ? 4 : 1,
        radius: 20,
        color: isSelected == true ? AppColorConstants.themeColor : null);
  }

  Widget orderSummary() {
    return Container(
      color: AppColorConstants.cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Heading5Text(orderSummaryString.tr, weight: TextWeight.medium),
          const SizedBox(
            height: 10,
          ),
          divider().tP8,
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              BodySmallText(subTotalString.tr, weight: TextWeight.regular),
              const Spacer(),
              BodySmallText(
                  '\$${_buyTicketController.selectedTicketType.value!.price * _buyTicketController.numberOfTickets.value}',
                  weight: TextWeight.medium),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              BodySmallText(serviceFeeString.tr, weight: TextWeight.regular),
              const Spacer(),
              BodySmallText(
                  '\$${_settingsController.setting.value!.serviceFee}',
                  weight: TextWeight.medium),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          if (_buyTicketController.selectedCoupon.value != null)
            Row(
              children: [
                BodySmallText(
                  '${couponCodeString.tr} (${_buyTicketController.selectedCoupon.value!.code})',
                  weight: TextWeight.semiBold,
                  color: AppColorConstants.themeColor,
                ),
                const Spacer(),
                BodySmallText(
                    '-\$${_buyTicketController.selectedCoupon.value!.discount}',
                    weight: TextWeight.medium),
              ],
            ),
          divider(height: 1, color: AppColorConstants.themeColor).vP16,
          Row(
            children: [
              BodyLargeText(totalString.tr, weight: TextWeight.regular),
              const Spacer(),
              BodyLargeText('\$${_buyTicketController.amountToBePaid}',
                  weight: TextWeight.medium),
            ],
          )
        ],
      ).p16,
    ).round(20);
  }

  Widget checkoutButton() {
    return AppThemeButton(
        text: checkoutString.tr,
        onPress: () {
          EventTicketOrderRequest order = _buyTicketController.ticketOrder;

          Get.to(() => Checkout(
                itemName: order.itemName!,
                amountToPay: order.amountToBePaid!,
                transactionCallbackHandler: (paymentTransactions) {
                  order.payments = paymentTransactions;

                  _eventDetailController.buyEventTicket(order);
                },
              ));
        });
  }
}
