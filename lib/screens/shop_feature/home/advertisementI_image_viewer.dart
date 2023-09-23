// import 'package:flutter/material.dart';
// import 'package:stub/util/ColorsUtil.dart';
// import 'package:stub/util/NavigationService.dart';
// import 'package:stub/helper/commonImports.dart';
//
// class AdvertisementImageViewer extends StatelessWidget {
//   String imageUrl;
//   AdvertisementImageViewer({Key? key, required this.imageUrl}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar:PreferredSize(
//           preferredSize: Size.fromHeight(100.0),
//           child: Container(
//               height: 150,
//               child: InkWell(
//                   onTap: () => Get.back(),
//                   child:
//                   Icon(Icons.arrow_back_ios, color: AppColorConstants.themeColor)),
//       ).tp(50)
//       ),
//       body:InteractiveViewer(
//         panEnabled: false, // Set it to false
//         boundaryMargin: EdgeInsets.all(100),
//         minScale: 0.5,
//         maxScale: 2,
//         child: Image.network(
//           imageUrl,
//           width: 200,
//           height: 200,
//           fit: BoxFit.cover,
//         ),
//       ),
//     );
//   }
// }
