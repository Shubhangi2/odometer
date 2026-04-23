// import 'package:dio/dio.dart';

// import 'package:fpdart/fpdart.dart';

// class ApiClient {
//   final TokenManager _tokenManager;
//   final Dio _dio;

//   ApiClient(this._tokenManager)
//     : _dio = Dio(
//         BaseOptions(
//           baseUrl: Constants.BASE_URL,
//           contentType: 'application/json',
//           headers: {'Accept': 'application/json'},
//         ),
//       ) {
//     _dio.interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (options, handler) async {
//           final bool? tokenParam = options.extra['tokenParam'] as bool?;
//           final token = await _tokenManager.getToken(tokenParam);
//           print("token is $token");
//           if (token.isNotEmpty) {
//             options.headers['Authorization'] = token;
//           }
//           return handler.next(options);
//         },
//         onError: (DioException error, handler) async {
//           // Handle token expiry or unauthorized access
//           if (error.response?.statusCode == 401) {
//             // might want to clear token or redirect to login
//             // await _tokenManager.clearToken();
//           }
//           return handler.next(error);
//         },
//       ),
//     );
//   }

//   Failure handleError(Object e) {
//     print(e.toString());
//     if (e is DioException && e.response?.statusCode == 401) {
//       return Failure("Unauthorized request");
//     }
//     String message = UtilityFunctions.getErrorMessage(e.toString());
//     return Failure(message);
//   }

//   Future<Either<Failure, T>> get<T>(
//     String path, {
//     Map<String, dynamic>? queryParameters,
//     required T Function(dynamic data) parser,
//     required String customErrorMessage,
//   }) async {
//     try {
//       final response = await _dio.get(path, queryParameters: queryParameters);
//       print(response.data);

//       if (response.statusCode == 200) {
//         return right(parser(response.data));
//       }
//       return left(Failure(customErrorMessage));
//     } catch (e) {
//       return left(handleError(e));
//     }
//   }

//   Future<Either<Failure, T>> post<T>(
//     String path, {
//     dynamic data,
//     required T Function(dynamic data) parser,
//     String? customErrorMessage,
//     bool? isLoginApi,
//   }) async {
//     try {
//       final response = await _dio.post(
//         path,
//         data: data,
//         options: Options(extra: {"tokenParam": isLoginApi}),
//       );
//       print(response.data);
//       if (response.statusCode == 200) {
//         return right(parser(response.data));
//       }
//       return left(Failure(customErrorMessage ?? "Request failed"));
//     } catch (e) {
//       return left(handleError(e));
//     }
//   }

//   Future<Either<Failure, List<T>>> postList<T>(
//     String path, {
//     dynamic data,
//     required T Function(dynamic json) fromJson,
//     required String customErrorMessage,
//   }) async {
//     try {
//       final response = await _dio.post(path, data: data);
//       print(response.data);
//       if (response.statusCode == 200) {
//         if (response.data["data"] is List<dynamic>) {
//           final List<T> resultList = (response.data["data"] as List)
//               .map((e) => fromJson(e))
//               .toList();
//           return right(resultList);
//         } else {
//           return right([]);
//         }
//       }
//       return left(Failure(customErrorMessage));
//     } catch (e) {
//       return left(handleError(e));
//     }
//   }

//   Future<Either<Failure, List<T>>> getList<T>(
//     String path, {
//     required T Function(dynamic json) fromJson,
//     required String customErrorMessage,
//   }) async {
//     try {
//       final response = await _dio.get(path);
//       print(response.data);
//       if (response.statusCode == 200) {
//         if (response.data["data"] is List<dynamic>) {
//           final List<T> resultList = (response.data["data"] as List)
//               .map((e) => fromJson(e))
//               .toList();
//           return right(resultList);
//         } else {
//           return right([]);
//         }
//       }
//       return left(Failure(customErrorMessage));
//     } catch (e) {
//       return left(handleError(e));
//     }
//   }

//   Future<Either<Failure, String>> postSuccess(
//     String path, {
//     dynamic data,
//     required String successMessage,
//     required String customErrorMessage,
//   }) async {
//     try {
//       final response = await _dio.post(path, data: data);
//       print(response.data);

//       if (response.statusCode == 200) {
//         return right(successMessage);
//       }
//       return left(Failure(customErrorMessage));
//     } catch (e) {
//       return left(handleError(e));
//     }
//   }

//   Future<Either<Failure, Response<dynamic>>> getRequest(
//     String path, {
//     required String successMessage,
//     required String customErrorMessage,
//   }) async {
//     try {
//       Response response = await _dio.get(path);
//       print(response.data);
//       return right(response);
//     } catch (e) {
//       return left(handleError(e));
//     }
//   }
// }
