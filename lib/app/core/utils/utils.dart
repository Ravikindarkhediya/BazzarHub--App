import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../data/constants/app_colors.dart';


class Utils {

  final BuildContext context;

  Utils(this.context);

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
  double heightPercentage(double percentage) => screenHeight * (percentage / 100);

  static const int childAge = 12;

  static bool isEmpty(String? value) {
    if(value == null) {
      return true;
    }
    return value.isEmpty;
  }

  static bool isEmptyList(List<dynamic>? value) {
    if(value == null) {
      return true;
    }
    return value.isEmpty;
  }

  static List<String> nonNullableList(List<String?> nullableList) {
    return nullableList.where((item) => item != null).cast<String>().toList();
  }

  static Widget getButtonLoader() {
    return  SizedBox(height: 22, width: 22,child:CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        strokeWidth: 1));
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

  // static void showTopDialog(BuildContext context, String title, String subtitle) {
  //   Color backgroundColor = Colors.white;
  //   Color textColor = AppColors.black;
  //   Duration duration = const Duration(seconds: 3);
  //
  //   showGeneralDialog(
  //     barrierLabel: "Popup",
  //     barrierDismissible: true,
  //     barrierColor: Colors.black.withOpacity(0.5),
  //     transitionDuration: const Duration(milliseconds: 400),
  //     context: context,
  //     pageBuilder: (context, anim1, anim2) {
  //       Future.delayed(duration, () {
  //         if (Navigator.of(context).canPop()) {
  //           Navigator.of(context).pop();
  //         }
  //       });
  //
  //       return Align(
  //         alignment: Alignment.topCenter,
  //         child: Material(
  //           color: Colors.transparent,
  //           child: Container(
  //             margin: const EdgeInsets.only(top: 50, left: 20, right: 20),
  //             padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
  //             decoration: BoxDecoration(
  //               color: backgroundColor,
  //               borderRadius: BorderRadius.circular(5),
  //               border: Border.all(color: AppColors.primary, width: 1),
  //             ),
  //             child: Row(
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               children: [
  //                 // The image on the left
  //                 Container(
  //                   margin: const EdgeInsets.only(right: 15),
  //                   child: ClipRRect(
  //                     borderRadius: BorderRadius.circular(10),
  //                     child: Assets.images.imgLaunch.image(height: 30, width: 30, fit: BoxFit.contain),
  //                   ),
  //                 ),
  //                 // The text on the right
  //                 Expanded(
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       Text(title, style: boldTextStyle(14, textColor)),
  //                       Text(subtitle, style: regularTextStyle(12, textColor)),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //     transitionBuilder: (context, anim1, anim2, child) {
  //       return SlideTransition(
  //         position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
  //             .animate(anim1),
  //         child: child,
  //       );
  //     },
  //   );
  // }
  //
  //
  //
  // static void showAlertDialog(BuildContext context,String title, String message) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         backgroundColor: BrandColors.appBgColor,
  //         title: Text(title),
  //         content: Text(message),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop(); // Close the dialog
  //             },
  //             child: Text('OK',style: mediumTextStyle(15, BrandColors.appColor),),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
  //
  // static String convertToISOFormat(String dateString) {
  //   try {
  //     DateTime dateTime = DateFormat('dd MMM yyyy').parse(dateString);
  //     String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
  //     return formattedDate;
  //   } catch (e) {
  //     print("Date conversion error: $e");
  //     return "";
  //   }
  // }
  //
  // static DateTime stringToDate(String dateString, String format) {
  //   final formatter = DateFormat(format);
  //   return formatter.parse(dateString);
  // }
  //
  // static String formatDate02(DateTime dateTime, String format) {
  //   final formatter = DateFormat(format);
  //   return formatter.format(dateTime);
  // }
  //
  // static String? convertDateFormatIOS(String? dateStr) {
  //   if (dateStr == null || dateStr.isEmpty) return null;
  //
  //   try {
  //     DateTime parsedDate = DateTime.parse(dateStr.trim());
  //     return parsedDate.toIso8601String();
  //   } catch (e) {
  //     print('Error parsing date: $e');
  //     return null;
  //   }
  // }
  //
  // static String changeDateFormat(String dateStr, String fromFormat, String toFormat) {
  //   DateFormat originalFormat = DateFormat(fromFormat);
  //   DateTime dateTime = originalFormat.parse(dateStr);
  //   DateFormat newFormat = DateFormat(toFormat);
  //   String newDateStr = newFormat.format(dateTime);
  //   return newDateStr;
  // }
  //
  // static String formatTimestamp(int timestamp) {
  //   // Convert the timestamp to a DateTime object in the local timezone
  //   DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: false);
  //   String outputFormat = Utils.isToday(dateTime) ? "HH:mm" : "d MMM, HH:mm";
  //   DateFormat format = DateFormat(outputFormat);
  //   return format.format(dateTime);
  // }
  //
  // static bool isToday(DateTime date) {
  //   final now = DateTime.now();
  //   return date.year == now.year && date.month == now.month && date.day == now.day;
  // }
  //
  static bool isValidEmail(String email) {
    String pattern =
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }
  //
  // static bool isValidPhoneNumber(String? countryCode, String phone) {
  //   if (countryCode == null || countryCode.isEmpty) {
  //     return false;
  //   }
  //   RegExp phoneRegex = RegExp(r'^\+\d{1,3}\d{10}$');
  //   return phoneRegex.hasMatch('$countryCode$phone');
  // }
  //
  // static String getAbbreviatedDay(String day) {
  //   try {
  //     String normalizedDay = day.trim().toLowerCase();
  //     const Map<String, String> dayAbbreviations = {
  //       'monday': 'mon',
  //       'tuesday': 'tue',
  //       'wednesday': 'wed',
  //       'thursday': 'thu',
  //       'friday': 'fri',
  //       'saturday': 'sat',
  //       'sunday': 'sun',
  //     };
  //     if (dayAbbreviations.containsKey(normalizedDay)) {
  //       return dayAbbreviations[normalizedDay]!;
  //     }
  //     DateTime date = DateFormat('EEEE').parse(day);
  //     String abbreviatedDay = DateFormat('EE').format(date);
  //     return abbreviatedDay.toLowerCase();
  //   } catch (e) {
  //     return '';
  //   }
  // }
  //
  // static Future<void> selectDate(BuildContext context, Function(String) onDateSelected) async {
  //   final DateTime now = DateTime.now();
  //
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: now,
  //     firstDate: now,
  //     lastDate: DateTime(2101),
  //     builder: (BuildContext context, Widget? child) {
  //       return Theme(
  //         data: ThemeData.light().copyWith(
  //           primaryColor: BrandColors.appColor,
  //           hintColor: BrandColors.appColor,
  //           scaffoldBackgroundColor: Colors.white,
  //           colorScheme: const ColorScheme.light(primary: BrandColors.appColor),
  //           buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
  //         ),
  //         child: child!,
  //       );
  //     },
  //   );
  //
  //   if (picked != null) {
  //     String formattedDate = DateFormat('dd MMM yyyy').format(picked);
  //     onDateSelected(formattedDate);
  //   }
  // }
  //
  // static String formatDate(String dateTimeString) {
  //   DateTime dateTime = DateTime.parse(dateTimeString);
  //   return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
  // }
  //
  // static Future<void> saveLastSyncDate() async {
  //   final DateFormat dateFormatGmt = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
  //   final String date = dateFormatGmt.format(DateTime.now().toUtc());
  //
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('lastSyncedDate', date);
  // }
  //
  // static Future<String?> getLastSyncDate() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? dateString = prefs.getString('lastSyncedDate');
  //
  //   if (dateString != null) {
  //     return dateString;
  //   }
  //   return null;
  // }
  //
  // static Future<void> generateDynamicLinkForVenue(VenueModel venue) async {
  //   try {
  //     var apiClient = await getApiClient();
  //     var params = {
  //       "title": venue.name,
  //       "description": venue.address,
  //       "image": venue.logo,
  //       "itemId": venue.id,
  //       "itemType": "venue"
  //     };
  //     var response = await apiClient.requestCreateDynamicLink(params);
  //     if (response.data.status == 1) {
  //       String dynamicLink = response.data.data;
  //       Share.share(
  //         '${venue.name} \n\n ${venue.address} \n\n $dynamicLink',
  //         subject: venue.name,  // Optional, used as a subject in email-like share options
  //       );
  //     } else {
  //       AppToast.showError(response.data.message ?? "Something went wrong, Please try again.");
  //     }
  //   } on DioError catch (e) {
  //     AppToast.showError("$e");
  //   }
  //   catch (error) {
  //     AppToast.showError("$error");
  //   } finally {
  //   }
  // }
  //
  // static Future<void> generateDynamicLinkForOffer(OfferModel offer) async {
  //   try {
  //     var apiClient = await getApiClient();
  //     var params = {
  //       "title": offer.title,
  //       "description": offer.description,
  //       "image": offer.image,
  //       "itemId": offer.id,
  //       "itemType": "offer"
  //     };
  //     var response = await apiClient.requestCreateDynamicLink(params);
  //     if (response.data.status == 1) {
  //       String dynamicLink = response.data.data;
  //       Share.share(
  //         '${offer.title} \n\n ${offer.description} \n\n $dynamicLink',
  //         subject: offer.title,  // Optional, used as a subject in email-like share options
  //       );
  //     } else {
  //       AppToast.showError(response.data.message ?? "Something went wrong, Please try again.");
  //     }
  //   } on DioError catch (e) {
  //     AppToast.showError("$e");
  //   }
  //   catch (error) {
  //     AppToast.showError("$error");
  //   } finally {
  //   }
  // }
  //
  // static Future<void> generateDynamicLinkForUser(UserModel user) async {
  //   try {
  //     var apiClient = await getApiClient();
  //     var params = {
  //       "title": user.firstName,
  //       "description": (user.bio != null && user.bio.isNotEmpty) ? user.bio : ' ',
  //       "image": user.image,
  //       "itemId": user.id,
  //       "itemType": "user"
  //     };
  //     print(params);
  //     var response = await apiClient.requestCreateDynamicLink(params);
  //     print(response);
  //     if (response.data.status == 1) {
  //       String dynamicLink = response.data.data;
  //       Share.share(
  //         '${user.firstName} \n\n ${user.bio} \n\n $dynamicLink',
  //         subject: user.firstName,
  //       );
  //     } else {
  //       print(response.data.message);
  //       AppToast.showError(response.data.message ?? "Something went wrong, Please try again.");
  //     }
  //   } on DioError catch (e) {
  //     print(e);
  //     AppToast.showError("$e");
  //   }
  //   catch (error) {
  //     print(error);
  //     AppToast.showError("$error");
  //   } finally {
  //   }
  // }
  //
  // static void openUrl(String? url) async {
  //   if (url != null && await canLaunch(url)) {
  //     await launch(url);
  //   } else {
  //     print('Could not launch $url');
  //   }
  // }
  //
  // static String decodeMessage(String encodedMessage) {
  //   if (encodedMessage.isEmpty) {
  //     return "No message available";
  //   }
  //   try {
  //
  //     final decodedBytes = base64Decode(encodedMessage);
  //     return utf8.decode(decodedBytes);
  //   } catch (e) {
  //     print(" $e");
  //     return "Data Not available";
  //   }
  // }
  //
  // static String formatTime(String time) {
  //   DateTime dateTime = DateFormat('HH:mm').parse(time);
  //   return DateFormat('hh:mm a').format(dateTime);
  // }
  //
  // static String capitalizeFirstLetter(String value) {
  //   if (value.isEmpty) {
  //     return value;
  //   }
  //   return "${value[0].toUpperCase()}${value.substring(1).toLowerCase()}";
  // }
  //
  // static String getCurrentDateTime() {
  //   final now = DateTime.now();
  //   final DateFormat formatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
  //   return formatter.format(now);
  // }
  //
  // static String formatDateTime(String dateTimeStr) {
  //   try {
  //     DateTime dateTime = DateTime.parse(dateTimeStr);
  //     return DateFormat('hh:mm a').format(dateTime);
  //   } catch (e) {
  //     return ''; // Return empty string if parsing fails
  //   }
  // }
  //
  // static String formatDateTimeMonth(String dateTimeString) {
  //   DateTime dateTime = DateTime.parse(dateTimeString);
  //   return DateFormat('dd MMM yyyy HH:mm').format(dateTime);
  // }
  //
  // static String timeAgoSince(DateTime date) {
  //   final now = DateTime.now();
  //   final difference = now.difference(date);
  //
  //   if (difference.inDays > 365) {
  //     final years = (difference.inDays / 365).floor();
  //     return '$years''y ago';
  //   } else if (difference.inDays > 30) {
  //     final months = (difference.inDays / 30).floor();
  //     return '$months''mo ago';
  //   } else if (difference.inDays >= 7) {
  //     final weeks = (difference.inDays / 7).floor();
  //     return '$weeks''w ago';
  //   } else if (difference.inDays > 0) {
  //     return '${difference.inDays}''d ago';
  //   } else if (difference.inHours > 0) {
  //     return '${difference.inHours} h ago';
  //   } else if (difference.inMinutes > 0) {
  //     return '${difference.inMinutes} m ago';
  //   } else {
  //     return 'Just now';
  //   }
  // }
  //
  // static Future<String?> getDeviceId() async {
  //   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  //   String? deviceId;
  //
  //   if (Platform.isAndroid) {
  //     AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  //     deviceId = androidInfo.id; // Unique ID for Android devices
  //   } else if (Platform.isIOS) {
  //     IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
  //     deviceId = iosInfo.identifierForVendor; // Unique ID for iOS devices
  //   }
  //
  //   return deviceId;
  // }
  //
  // static String getDiscount(String discount) {
  //   return discount.contains('%') ? discount : '$discount%';
  // }
  //
  // static String convertDateFormat(String originalDate, String originalFormat, String targetFormat) {
  //   DateFormat originalFormatter = DateFormat(originalFormat);
  //   DateTime? dateTime;
  //   try {
  //     dateTime = originalFormatter.parse(originalDate);
  //   } catch (e) {
  //     return '';
  //   }
  //   DateFormat targetFormatter = DateFormat(targetFormat);
  //   return targetFormatter.format(dateTime);
  // }
  //
  // static String getDays(String? days) {
  //   if (days == null || days.isEmpty) return "";
  //   List<String> dayArray = days.split(",");
  //
  //   if (dayArray.length == 1) {
  //     return dayArray[0].trim().substring(0, 1).toUpperCase() + dayArray[0].trim().substring(1).toLowerCase();
  //   } else if (dayArray.length == 7) {
  //     return "All days";
  //   } else {
  //     StringBuffer formattedDays = StringBuffer();
  //     for (int i = 0; i < dayArray.length; i++) {
  //       String day = dayArray[i].trim();
  //       String capitalizedDay = day.substring(0, 1).toUpperCase() + day.substring(1).toLowerCase();
  //       if (i == 0) {
  //         formattedDays.write(capitalizedDay);
  //       } else {
  //         formattedDays.write(", $capitalizedDay");
  //       }
  //     }
  //     return formattedDays.toString();
  //   }
  // }
  //
  // static String? convertMainDateFormat(String originalDateString) {
  //   try {
  //     final originalFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", "en_US");
  //     final outputFormat = DateFormat("EEE, dd MMM yyyy", "en_US");
  //     final originalDate = originalFormat.parseUtc(originalDateString).toLocal();
  //     return outputFormat.format(originalDate);
  //   } catch (e) {
  //     print(e);
  //     return null;
  //   }
  // }
  //
  // static IconData getStatusIcon(ChatMessageModel message) {
  //   if (message.members != null && message.seenBy != null && message.receivers != null) {
  //     if (message.seenBy!.length >= message.members!.length - 1) {
  //       return Icons.done_all;
  //     } else if (message.receivers!.length >= message.members!.length) {
  //       return Icons.done_all;
  //     } else if (message.receivers!.contains(SessionManager().userObjectModel!.id)) {
  //       return Icons.check;
  //     } else {
  //       return Icons.access_time;
  //     }
  //   }
  //   return Icons.access_time;
  // }
  //
  // static Color getStatusIconColor(ChatMessageModel message) {
  //   if (message.members != null && message.seenBy != null && message.receivers != null) {
  //     if (message.seenBy!.length >= message.members!.length - 1) {
  //       return Colors.green;
  //     }
  //   }
  //   return Colors.white;
  // }

}