import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../data/constants/app_colors.dart';
import 'app_spacing.dart';

class Utils {
  Utils(this.context);

  final BuildContext context;

  // Get the width of the screen
  double get screenWidth => MediaQuery.of(context).size.width;

  // Get the height of the screen
  double get screenHeight => MediaQuery.of(context).size.height;

  // Get the orientation of the screen
  Orientation get orientation => MediaQuery.of(context).orientation;

  // Check if the device is in portrait mode
  bool get isPortrait => orientation == Orientation.portrait;

  // Check if the device is in landscape mode
  bool get isLandscape => orientation == Orientation.landscape;

  // Example: Get a percentage of screen width
  double widthPercentage(double percentage) => screenWidth * (percentage / 100);

  // Example: Get a percentage of screen height
  double heightPercentage(double percentage) =>
      screenHeight * (percentage / 100);

  static const int childAge = 12;

  static bool isEmpty(String? value) {
    if (value == null) {
      return true;
    }
    return value.isEmpty;
  }

  static bool isEmptyList(List<dynamic>? value) {
    if (value == null) {
      return true;
    }
    return value.isEmpty;
  }

  static List<String> nonNullableList(List<String?> nullableList) {
    return nullableList.where((item) => item != null).cast<String>().toList();
  }

  static Widget getButtonLoader() {
    return SizedBox(
      height: 22,
      width: 22,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        strokeWidth: 1,
      ),
    );
  }

  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  // Function to hide the loading dialog
  static void hideLoadingDialog(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  static String removeHtmlTags(String htmlString) {
    final RegExp regex = RegExp(r'<[^>]*>');
    return htmlString.replaceAll(regex, '');
  }

  static String convertToISOFormat(String dateString) {
    try {
      DateTime dateTime = DateFormat('dd MMM yyyy').parse(dateString);
      String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
      return formattedDate;
    } catch (e) {
      print("Date conversion error: $e");
      return "";
    }
  }

  static DateTime stringToDate(String dateString, String format) {
    final formatter = DateFormat(format);
    return formatter.parse(dateString);
  }

  static String formatDate02(DateTime dateTime, String format) {
    final formatter = DateFormat(format);
    return formatter.format(dateTime);
  }

  static String? convertDateFormatIOS(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;

    try {
      DateTime parsedDate = DateTime.parse(dateStr.trim());
      return parsedDate.toIso8601String();
    } catch (e) {
      print('Error parsing date: $e');
      return null;
    }
  }

  static String changeDateFormat(String dateStr, String fromFormat, String toFormat) {
    DateFormat originalFormat = DateFormat(fromFormat);
    DateTime dateTime = originalFormat.parse(dateStr);
    DateFormat newFormat = DateFormat(toFormat);
    String newDateStr = newFormat.format(dateTime);
    return newDateStr;
  }

  static String formatTimestamp(int timestamp) {
    // Convert the timestamp to a DateTime object in the local timezone
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: false);
    String outputFormat = Utils.isToday(dateTime) ? "HH:mm" : "d MMM, HH:mm";
    DateFormat format = DateFormat(outputFormat);
    return format.format(dateTime);
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  static bool isValidEmail(String email) {
    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }


  static bool isValidPhoneNumber(String? countryCode, String phone) {
    if (countryCode == null || countryCode.isEmpty) {
      return false;
    }
    RegExp phoneRegex = RegExp(r'^\+\d{1,3}\d{10}$');
    return phoneRegex.hasMatch('$countryCode$phone');
  }


  static bool isVideo(String url) {
    final videoExtensions = ['.mp4', '.mov', '.avi', '.mkv'];
    return videoExtensions.any((ext) => url.toLowerCase().endsWith(ext));
  }

  /// Cache for generated video thumbnails to avoid duplicate work.
  static final Map<String, String?> _videoThumbnailCache = {};
  static final Map<String, Future<String?>> _videoThumbnailInFlight = {};

  /// Generates (and caches) a thumbnail for the provided [videoUrl].
  /// Falls back to downloading the video to a temp file if the direct
  /// remote generation fails.
  static Future<String?> generateVideoThumbnail({
    required String videoUrl,
    int maxHeight = 0,
    int maxWidth = 0,
    int quality = 90,
  }) {
    final cacheKey = _thumbnailCacheKey(
      videoUrl: videoUrl,
      height: maxHeight,
      width: maxWidth,
      quality: quality,
    );

    if (_videoThumbnailCache.containsKey(cacheKey)) {
      return Future.value(_videoThumbnailCache[cacheKey]);
    }

    if (_videoThumbnailInFlight.containsKey(cacheKey)) {
      return _videoThumbnailInFlight[cacheKey]!;
    }

    final future = _createVideoThumbnail(
      cacheKey: cacheKey,
      videoUrl: videoUrl,
      maxHeight: maxHeight,
      maxWidth: maxWidth,
      quality: quality,
    );

    _videoThumbnailInFlight[cacheKey] = future;
    future.whenComplete(() => _videoThumbnailInFlight.remove(cacheKey));
    return future;
  }

  static Future<String?> _createVideoThumbnail({
    required String cacheKey,
    required String videoUrl,
    required int maxHeight,
    required int maxWidth,
    required int quality,
  }) async {
    try {
      final thumbnailPath = await _getThumbnailPath(cacheKey);
      final existingFile = File(thumbnailPath);
      if (await existingFile.exists() && await existingFile.length() > 0) {
        _videoThumbnailCache[cacheKey] = thumbnailPath;
        return thumbnailPath;
      }

      /// Attempt to let `video_thumbnail` handle the remote URL directly first.
      final generated = await _generateWithVideoThumbnail(
        source: videoUrl,
        destinationPath: thumbnailPath,
        maxHeight: maxHeight,
        maxWidth: maxWidth,
        quality: quality,
      );

      if (generated != null) {
        _videoThumbnailCache[cacheKey] = generated;
        return generated;
      }

      /// Fallback: Download to a local temp file and retry.
      final localVideoPath = await _downloadVideoToTemp(videoUrl);
      if (localVideoPath == null) {
        return null;
      }

      final localGenerated = await _generateWithVideoThumbnail(
        source: localVideoPath,
        destinationPath: thumbnailPath,
        maxHeight: maxHeight,
        maxWidth: maxWidth,
        quality: quality,
      );

      if (localGenerated != null) {
        _videoThumbnailCache[cacheKey] = localGenerated;
      }

      return localGenerated;
    } catch (error) {
      debugPrint('Utils.generateVideoThumbnail error: $error');
      return null;
    }
  }

  static Future<String?> _generateWithVideoThumbnail({
    required String source,
    required String destinationPath,
    required int maxHeight,
    required int maxWidth,
    required int quality,
  }) async {
    try {
      final path = await VideoThumbnail.thumbnailFile(
        video: source,
        thumbnailPath: destinationPath,
        imageFormat: ImageFormat.PNG,
        quality: quality.clamp(0, 100),
        maxHeight: AppSpacing.md.toInt(),
        maxWidth: AppSpacing.md.toInt(),
      );
      if (path != null) {
        return path;
      }
    } catch (error) {
      debugPrint('Utils._generateWithVideoThumbnail error: $error');
    }
    return null;
  }


  static Future<String?> _downloadVideoToTemp(String videoUrl) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/video_cache_${_stableHash(videoUrl)}.mp4';
      final file = File(filePath);
      if (await file.exists() && await file.length() > 0) {
        return filePath;
      }

      final uri = Uri.tryParse(videoUrl);
      if (uri == null) return null;

      final client = http.Client();
      try {
        final request = http.Request('GET', uri);
        final response = await client.send(request);
        if (response.statusCode >= 400) {
          return null;
        }

        final sink = file.openWrite();
        await response.stream.pipe(sink);
        await sink.close();
        return filePath;
      } finally {
        client.close();
      }
    } catch (error) {
      debugPrint('Utils._downloadVideoToTemp error: $error');
      return null;
    }
  }

  static Future<String> _getThumbnailPath(String cacheKey) async {
    final tempDir = await getTemporaryDirectory();
    final safeHash = _stableHash(cacheKey);
    return '${tempDir.path}/video_thumb_$safeHash.png';
  }

  static int _stableHash(String input) {
    return input.hashCode.abs();
  }

  static String _thumbnailCacheKey({
    required String videoUrl,
    required int height,
    required int width,
    required int quality,
  }) {
    return '$videoUrl|h:${height.clamp(0, 4000)}|w:${width.clamp(0, 4000)}|q:${quality.clamp(0, 100)}';
  }

  static String getTimeAgo(String dateTimeString) {
    if (dateTimeString.isEmpty) return '';
    DateTime dateTime;
    try {
      dateTime = DateTime.parse(dateTimeString);
    } catch (_) {
      return '';
    }
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
