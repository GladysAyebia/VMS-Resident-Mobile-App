import 'package:dio/dio.dart';

class ErrorHandler {
  static String handle(DioException error) {
    if (error.response != null) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      return "Error: ${error.response!.statusCode} - ${error.response!.data['message']}";
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      return "Error: ${error.message}";
    }
  }
}
