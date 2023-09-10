import 'package:foap/helper/enum.dart';

int postTypeValueFrom(PostType postType) {
  switch (postType) {
    case PostType.basic:
      return 1;
    case PostType.competition:
      return 2;
    case PostType.club:
      return 3;
    case PostType.reel:
      return 4;
    case PostType.reshare:
      return 5;
  }
}

int postContentTypeValueFrom(PostContentType contentType) {
  switch (contentType) {
    case PostContentType.text:
      return 1;
    case PostContentType.media:
      return 2;
    case PostContentType.location:
      return 3;
  }
}

int mediaTypeIdFromMediaType(GalleryMediaType type) {
  switch (type) {
    case GalleryMediaType.photo:
      return 1;
    case GalleryMediaType.video:
      return 2;
    case GalleryMediaType.audio:
      return 3;
    case GalleryMediaType.gif:
      return 4;
  }
  return 1;
}

int itemViewSourceToId(ItemViewSource source) {
  switch (source) {
    case ItemViewSource.normal:
      return 1;
    case ItemViewSource.promotion:
      return 2;
  }
}

int userViewSourceTypeToId(UserViewSourceType source) {
  switch (source) {
    case UserViewSourceType.post:
      return 1;
    case UserViewSourceType.reel:
      return 2;
    case UserViewSourceType.story:
      return 2;
  }
}
