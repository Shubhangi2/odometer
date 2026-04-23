import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class UtilityFunctions {
  static Future<bool> checkInternetConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi)) {
      return true;
    } else {
      return false;
    }
  }

  static String dateFormatForImages(String dateValue) {
    String date = "";

    // Input format: "dd-MM-yyyy hh:mm"
    DateFormat inputFormat = DateFormat("dd-MM-yyyy hh:mm");
    DateTime? newDate;

    try {
      newDate = inputFormat.parse(dateValue);
    } catch (e) {
      print('Error parsing date: $e');
      return "";
    }

    // Output format: "ddMMyyyy"
    DateFormat outputFormat = DateFormat("ddMMyyyy");
    date = outputFormat.format(newDate);

    print('Original dateValue: $dateValue'); // image date folder
    print('Formatted date: $date');
    return date;
  }

  static String formatDateInDDMMYY(String date) {
    // current format yyyy-mm-dd
    DateTime dateTime = DateTime.parse(date);
    String formattedDate = DateFormat("dd-MM-yy").format(dateTime);
    return formattedDate;
  }

  static Future<bool> locationServiceEnabledOrNot() async {
    ServiceStatus serviceStatus = await Permission.locationWhenInUse.serviceStatus;
    bool enabled = (serviceStatus == ServiceStatus.enabled);
    return enabled;
  }

  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timed out. Please check your internet and try again.';
        case DioExceptionType.connectionError:
          return 'No internet connection. Please try again.';
        case DioExceptionType.badResponse:
          return 'Server error. Please try again later.';
        default:
          return 'Something went wrong. Please try again.';
      }
    }
    return 'An unexpected error occurred.';
  }
}
