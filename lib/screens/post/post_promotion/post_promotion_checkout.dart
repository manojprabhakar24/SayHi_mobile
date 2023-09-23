// import 'dart:io';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:foap/components/payment_method_tile.dart';
// import 'package:foap/helper/imports/common_import.dart';
// import 'package:foap/model/post_promotion_model.dart';
// import 'package:foap/screens/settings_menu/settings_controller.dart';
// import 'package:lottie/lottie.dart';
//
// import '../../../controllers/profile/profile_controller.dart';
// import '../../add_on/controller/event/checkout_controller.dart';
//
// class PostPromotionCheckout extends StatefulWidget {
//   final PostPromotionOrderRequest order;
//
//   const PostPromotionCheckout({Key? key, required this.order})
//       : super(key: key);
//
//   @override
//   State<PostPromotionCheckout> createState() => _PostPromotionCheckoutState();
// }
//
// class _PostPromotionCheckoutState extends State<PostPromotionCheckout> {
//   final CheckoutController _checkoutController = CheckoutController();
//   final ProfileController _profileController = Get.find();
//   final SettingsController _settingsController = Get.find();
//   final UserProfileManager _userProfileManager = Get.find();
//
//   TextEditingController textController = TextEditingController();
//
//   @override
//   void initState() {
//     _profileController.getMyProfile();
//     _settingsController.loadSettings();
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _checkoutController.useWalletSwitchChange(false, widget.order);
//     });
//
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AppScaffold(
//       backgroundColor: AppColorConstants.backgroundColor,
//       body: Obx(() => _checkoutController.processingPayment.value != null
//           ? statusView()
//           : SizedBox(
//               height: Get.height,
//               child: Column(
//                 children: [
//                   backNavigationBar(title: buyTicketString.tr),
//                   divider().tP8,
//                   Expanded(
//                     child: Stack(
//                       children: [
//                         SingleChildScrollView(
//                           child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   children: [
//                                     BodyLargeText(payableAmountString.tr,
//                                         weight: TextWeight.bold),
//                                     BodyLargeText(
//                                       ' (\$${widget.order.grandTotalAmount})',
//                                       weight: TextWeight.bold,
//                                       color: AppColorConstants.themeColor,
//                                     ),
//                                   ],
//                                 ).setPadding(top: 16, left: 16, right: 16),
//                                 // divider().vP16,
//                                 // walletView(),
//                                 paymentGateways().hP16,
//                                 const SizedBox(
//                                   height: 25,
//                                 ),
//                               ]),
//                         ),
//                         // Positioned(
//                         //     bottom: 20,
//                         //     left: 25,
//                         //     right: 25,
//                         //     child: checkoutButton())
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             )),
//     );
//   }
//
//   Widget statusView() {
//     return _checkoutController.processingPayment.value ==
//             ProcessingPaymentStatus.inProcess
//         ? processingView()
//         : _checkoutController.processingPayment.value ==
//                 ProcessingPaymentStatus.completed
//             ? orderPlacedView()
//             : errorView();
//   }
//
//   Widget walletView() {
//     return Obx(() => _profileController.user.value == null
//         ? Container()
//         : Column(
//             children: [
//               if (double.parse(_profileController.user.value!.balance) > 0)
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // divider().vP25,
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         BodyMediumText(
//                           '${walletString.tr} (\$${_userProfileManager.user.value!.balance})',
//                           weight: TextWeight.medium,
//                           color: AppColorConstants.themeColor,
//                         ),
//                         const SizedBox(
//                           height: 5,
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 BodyLargeText(useBalanceString.tr,
//                                     weight: TextWeight.medium),
//                                 BodyLargeText(
//                                   ' (\$${widget.order.grandTotalAmount > double.parse(_userProfileManager.user.value!.balance) ? _userProfileManager.user.value!.balance : widget.order.grandTotalAmount})',
//                                   weight: TextWeight.medium,
//                                   color: AppColorConstants.themeColor,
//                                 ),
//                               ],
//                             ),
//                             Obx(() => Switch(
//                                 activeColor: AppColorConstants.themeColor,
//                                 value: _checkoutController.useWallet.value,
//                                 onChanged: (value) {
//                                   _checkoutController.useWalletSwitchChange(
//                                       value, widget.order);
//                                 }))
//                           ],
//                         )
//                       ],
//                     ).hP16,
//                   ],
//                 ),
//               const SizedBox(
//                 height: 10,
//               ),
//               if (double.parse(_profileController.user.value!.balance) > 0)
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         BodyMediumText(
//                           coinsString.tr,
//                           weight: TextWeight.medium,
//                           color: AppColorConstants.themeColor,
//                         ),
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 BodyLargeText(availableCoinsString.tr,
//                                     weight: TextWeight.medium),
//                                 BodyLargeText(
//                                   ' (${_userProfileManager.user.value!.coins})',
//                                   weight: TextWeight.medium,
//                                   color: AppColorConstants.themeColor,
//                                 ),
//                               ],
//                             ),
//                             // redeemBtn()
//                           ],
//                         )
//                       ],
//                     ).hP16,
//                     divider().vP25,
//                   ],
//                 ),
//             ],
//           ));
//   }
//
//   Widget paymentGateways() {
//     return Obx(() => _checkoutController.balanceToPay.value > 0 ||
//             _checkoutController.useWallet.value == false
//         ? Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // const SizedBox(
//               //   height: 20,
//               // ),
//               // Row(
//               //   children: [
//               //     Heading6Text(
//               //       payUsingString.tr,
//               //       weight: TextWeight.bold,
//               //     ),
//               //     const SizedBox(
//               //       width: 10,
//               //     ),
//               //     Container(
//               //       color: AppColorConstants.cardColor,
//               //       child: Heading6Text(
//               //         '\$${_checkoutController.balanceToPay.value}',
//               //         weight: TextWeight.medium,
//               //         color: AppColorConstants.themeColor,
//               //       ).p4,
//               //     ).round(5)
//               //   ],
//               // ),
//               const SizedBox(
//                 height: 20,
//               ),
//               // PaymentMethodTile(
//               //   text: creditCard,
//               //   icon: "assets/credit-card.png",
//               //   price: '\$${_checkoutController.balanceToPay.value}',
//               //   isSelected: _checkoutController.selectedPaymentGateway.value ==
//               //       PaymentGateway.creditCard,
//               //   press: () {
//               //     _checkoutController
//               //         .selectPaymentGateway(PaymentGateway.creditCard);
//               //     // Get.to(() => NewCreditCardPayment(booking: booking));
//               //   },
//               // ),
//               if (Stripe.instance.isPlatformPaySupportedListenable.value &&
//                   Platform.isIOS)
//                 PaymentMethodTile(
//                   text: applePayString.tr,
//                   icon: _settingsController.darkMode.value
//                       ? "assets/apple_pay.png"
//                       : "assets/apple_pay_light.png",
//                   price: '\$${_checkoutController.balanceToPay.value}',
//                   isSelected:
//                       _checkoutController.selectedPaymentGateway.value ==
//                           PaymentGateway.applePay,
//                   press: () {
//                     // _checkoutController.applePay();
//                     _checkoutController
//                         .selectPaymentGateway(PaymentGateway.applePay);
//                     checkout();
//                   },
//                 ),
//
//               PaymentMethodTile(
//                 text: flutterWaveString.tr,
//                 icon: "assets/flutterwave.png",
//                 price: '\$${_checkoutController.balanceToPay.value}',
//                 isSelected: _checkoutController.selectedPaymentGateway.value ==
//                     PaymentGateway.applePay,
//                 press: () {
//                   // _checkoutController.applePay();
//                   _checkoutController
//                       .selectPaymentGateway(PaymentGateway.flutterWave);
//                   checkout();
//                 },
//               ),
//
//               if (Stripe.instance.isPlatformPaySupportedListenable.value &&
//                   Platform.isAndroid)
//                 PaymentMethodTile(
//                   text: googlePayString.tr,
//                   icon: "assets/google-pay.png",
//                   price: '\$${_checkoutController.balanceToPay.value}',
//                   isSelected:
//                       _checkoutController.selectedPaymentGateway.value ==
//                           PaymentGateway.googlePay,
//                   press: () {
//                     // _checkoutController.applePay();
//                     _checkoutController
//                         .selectPaymentGateway(PaymentGateway.googlePay);
//                     checkout();
//                   },
//                 ),
//               // PaymentMethodTile(
//               //   text: paypal,
//               //   icon: "assets/paypal.png",
//               //   price: '\$${_checkoutController.balanceToPay.value}',
//               //   isSelected: _checkoutController.selectedPaymentGateway.value ==
//               //       PaymentGateway.paypal,
//               //   press: () {
//               //     // _checkoutController.launchBrainTree();
//               //     _checkoutController
//               //         .selectPaymentGateway(PaymentGateway.paypal);
//               //   },
//               // ),
//               PaymentMethodTile(
//                 text: stripeString.tr,
//                 icon: "assets/stripe.png",
//                 price: '\$${_checkoutController.balanceToPay.value}',
//                 isSelected: _checkoutController.selectedPaymentGateway.value ==
//                     PaymentGateway.stripe,
//                 press: () {
//                   // _checkoutController.launchRazorpayPayment();
//                   _checkoutController
//                       .selectPaymentGateway(PaymentGateway.stripe);
//                   checkout();
//                 },
//               ),
//               // PaymentMethodTile(
//               //   text: razorPayString.tr,
//               //   icon: "assets/razorpay.png",
//               //   price: '\$${_checkoutController.balanceToPay.value}',
//               //   isSelected: _checkoutController.selectedPaymentGateway.value ==
//               //       PaymentGateway.razorpay,
//               //   press: () {
//               //     _checkoutController
//               //         .selectPaymentGateway(PaymentGateway.razorpay);
//               //     checkout();
//               //   },
//               // ),
//               // PaymentMethodTile(
//               //   text: inAppPurchase,
//               //   icon: "assets/in_app_purchases.png",
//               //   price: '\$${_checkoutController.balanceToPay.value}',
//               //   isSelected: _checkoutController.selectedPaymentGateway.value ==
//               //       PaymentGateway.razorpay,
//               //   press: () {
//               //     // _checkoutController.launchRazorpayPayment();
//               //     _checkoutController
//               //         .selectPaymentGateway(PaymentGateway.inAppPurchse);
//               //   },
//               // ),
//               // PaymentMethodTile(
//               //   text: cash,
//               //   icon: "assets/cash.png",
//               //   price: _checkoutController.useWallet.value
//               //       ? '${widget.ticketOrder.ticketAmount! - double.parse(_userProfileManager.user.value!.balance)}'
//               //       : '\$${widget.ticketOrder.ticketAmount!}',
//               //   press: () {
//               //     // PaymentModel payment = PaymentModel();
//               //     // payment.id = getRandString(20);
//               //     // payment.mode = 'cash';
//               //     // payment.amount = booking.bookingTotalDoubleValue();
//               //     // placeOrder(payment);
//               //   },
//               // ),
//             ],
//           )
//         : Container());
//   }
//
//   // widget.ticketOrder.amountToBePaid! -
//   // double.parse(_userProfileManager.user.value!.balance) >
//   // 0
//
//   Widget checkoutButton() {
//     return AppThemeButton(
//         text: payAndBuyString.tr,
//         onPress: () {
//           checkout();
//         });
//   }
//
//   checkout() {
//     // if (_checkoutController.useWallet.value) {
//     //   if (widget.order.amountToBePaid! <
//     //       double.parse(_userProfileManager.user.value!.balance)) {
//     //     _checkoutController.payAndBuy(
//     //         ticketOrder: widget.ticketOrder,
//     //         paymentGateway: PaymentGateway.wallet);
//     //   } else {
//     //     _checkoutController.payAndBuy(
//     //         ticketOrder: widget.ticketOrder,
//     //         paymentGateway: _checkoutController.selectedPaymentGateway.value);
//     //   }
//     // } else {
//     _checkoutController.payAndBuy(
//         itemName: postPromotionString.tr,
//         totalAmount: widget.order.grandTotalAmount,
//         paymentGateway: _checkoutController.selectedPaymentGateway.value,
//         transactionHandler: (paymentTransactions) {});
//     // }
//   }
//
//   Widget processingView() {
//     return SizedBox(
//       height: Get.height,
//       width: Get.width,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Lottie.asset('assets/lottie/loading.json'),
//           const SizedBox(
//             height: 40,
//           ),
//           Heading3Text(
//             placingOrderString.tr,
//             weight: TextWeight.semiBold,
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(
//             height: 10,
//           ),
//           BodyLargeText(
//             doNotCloseAppString.tr,
//             weight: TextWeight.regular,
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ).hP16,
//     );
//   }
//
//   Widget orderPlacedView() {
//     return SizedBox(
//       height: Get.height,
//       width: Get.width,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Lottie.asset('assets/lottie/success.json'),
//           const SizedBox(
//             height: 40,
//           ),
//           Heading3Text(
//             postPromotedString.tr,
//             weight: TextWeight.semiBold,
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(
//             height: 40,
//           ),
//           SizedBox(
//               width: 200,
//               height: 50,
//               child: AppThemeBorderButton(
//                   text: promoteMorePostsString.tr,
//                   onPress: () {
//                     Get.close(2);
//                   }))
//         ],
//       ).hP16,
//     );
//   }
//
//   Widget errorView() {
//     return SizedBox(
//       height: Get.height,
//       width: Get.width,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Lottie.asset('assets/lottie/error.json'),
//           const SizedBox(
//             height: 40,
//           ),
//           Heading3Text(
//             errorInPromotionString.tr,
//             weight: TextWeight.semiBold,
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(
//             height: 10,
//           ),
//           BodyLargeText(
//             pleaseTryAgainString.tr,
//             weight: TextWeight.regular,
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(
//             height: 40,
//           ),
//           SizedBox(
//               width: 100,
//               height: 40,
//               child: AppThemeBorderButton(
//                   text: tryAgainString.tr,
//                   onPress: () {
//                     Get.back();
//                   }))
//         ],
//       ).hP16,
//     );
//   }
// }
