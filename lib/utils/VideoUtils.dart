import 'package:video_thumbnail/video_thumbnail.dart';

class VideoUtils {
  static Future<String?> extractFrameThumbnail(String videoPath) async {
    return await VideoThumbnail.thumbnailFile(
      video: videoPath,
      imageFormat: ImageFormat.PNG,
      maxHeight: 120,
      quality: 75,
    );
  }
}
