import 'package:any_link_preview/any_link_preview.dart';
import '../helper/imports/common_import.dart';

Widget linkPreview(String message) {
  return AnyLinkPreview(
    link: message,
    displayDirection: UIDirection.uiDirectionHorizontal,
    showMultimedia: false,
    bodyMaxLines: 5,
    bodyTextOverflow: TextOverflow.ellipsis,
    titleStyle: TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 15,
    ),
    bodyStyle: TextStyle(color: Colors.grey, fontSize: 12),
    errorBody: 'Show my custom error body',
    errorTitle: 'Show my custom error title',
    errorWidget: Container(
      color: Colors.grey[300],
      child: Text('Oops!'),
    ),
    errorImage: "https://google.com/",
    cache: Duration(days: 7),
    backgroundColor: Colors.grey[300],
    borderRadius: 12,
    removeElevation: false,
    boxShadow: [BoxShadow(blurRadius: 3, color: Colors.grey)],
    onTap: () {}, // This disables tap event
  );
}
