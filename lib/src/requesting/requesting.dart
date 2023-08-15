import 'package:dio/dio.dart';
import 'package:events_time_microapp_dependencies/events_time_microapp_dependencies.dart';
import 'package:events_time_microapp_dependencies/src/requesting/http_method.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

abstract class IRequesting {
  Future<void> getTokensJWT();
  bool get hasTokensJWT;
  Future<void> setTokensJWT(String accessTokenJWT, String refreshTokenJWT);
  Future<void> deleteTokensJWT();

  Future<RequestingResponse<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
    Map<String, dynamic>? header,
  });
  Future<RequestingResponse<dynamic>> post(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
    Map<String, dynamic>? header,
  });
  Future<RequestingResponse<dynamic>> put(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
    Map<String, dynamic>? header,
  });
  Future<RequestingResponse<dynamic>> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
    Map<String, dynamic>? header,
  });
}

class Requesting implements IRequesting {
  String get keyAccessToken => 'tokenJWT';
  String get keyRefreshToken => 'refreshTokenJWT';
  String? accessToken;
  String? refreshToken;

  late Dio dio;
  final String baseUrl;
  final ILocalStorage localStorage;

  Requesting({required this.baseUrl, required this.localStorage}) {
    dio = Dio();
    getTokensJWT();
    if (kDebugMode) dio.interceptors.add(PrettyDioLogger());

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (
        RequestOptions options,
        RequestInterceptorHandler handler,
      ) {
        // Adicione o token de acesso às requisições se estiver disponível
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        return handler.next(options);
      },
      // onResponse: (
      //   Response<dynamic> response,
      //   ResponseInterceptorHandler handler,
      // ) {
      //   // if (response.statusCode == 401) {
      //   //   return _refreshTokenAndRetry(response.requestOptions, handler);
      //   // }
      //   return handler.next(response);
      // },
    ));
  }

  // Future<void> _refreshTokenAndRetry(
  //   RequestOptions requestOptions,
  //   ResponseInterceptorHandler handler,
  // ) async {
  //   try {
  //     final response = await dio.post('$baseUrl/refresh_token', data: {
  //       'refresh_token': refreshToken,
  //     });

  //     final data = response.data;

  //     if (data.containsKey('access_token')) {
  //       accessToken = data['access_token'];
  //       // Atualize o cabeçalho da requisição com o novo access token
  //       requestOptions.headers['Authorization'] = 'Bearer $accessToken';
  //       // Repita a requisição original com o novo access token

  //       return handler.resolve(await dio.fetch(requestOptions));
  //     } else {
  //       // TODO: logout user
  //     }
  //   } catch (error) {
  //     // TODO: logout user
  //   }
  // }

  @override
  Future<void> getTokensJWT() async {
    accessToken = await localStorage.getString(keyAccessToken);
    refreshToken = await localStorage.getString(keyRefreshToken);
  }

  @override
  Future<void> setTokensJWT(
    String accessTokenJWT,
    String refreshTokenJWT,
  ) async {
    accessToken = accessTokenJWT;
    refreshToken = refreshTokenJWT;

    await localStorage.setString(keyAccessToken, accessTokenJWT);
    await localStorage.setString(keyRefreshToken, refreshTokenJWT);
  }

  @override
  bool get hasTokensJWT => accessToken?.isNotEmpty ?? false;
  //  && (refreshToken?.isNotEmpty ?? false)

  @override
  Future<void> deleteTokensJWT() async {
    accessToken = null;
    refreshToken = null;
    await localStorage.delete(keyAccessToken);
    await localStorage.delete(keyRefreshToken);
  }

  Future<RequestingResponse<dynamic>> _request(
    String path, {
    required HttpMethod httpMethod,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
    Map<String, dynamic>? header,
    bool isFullPath = false,
  }) async {
    final Response<dynamic> response = await dio.request(
      (isFullPath ? '' : baseUrl) + path,
      queryParameters: queryParameters,
      data: body,
      options: Options(
        method: httpMethod.method,
        headers: header,
      ),
    );

    return RequestingResponse<dynamic>(
      response.statusCode ?? 500,
      response.realUri.toString(),
      response.data,
      response.headers.map,
    );
  }

  @override
  Future<RequestingResponse<dynamic>> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
    Map<String, dynamic>? header,
    bool isFullPath = false,
  }) async {
    return _request(
      path,
      queryParameters: queryParameters,
      body: body,
      header: header,
      httpMethod: HttpMethod.DELETE,
      isFullPath: isFullPath,
    );
  }

  @override
  Future<RequestingResponse<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
    Map<String, dynamic>? header,
    bool isFullPath = false,
  }) async {
    return _request(
      path,
      queryParameters: queryParameters,
      body: body,
      header: header,
      httpMethod: HttpMethod.GET,
      isFullPath: isFullPath,
    );
  }

  @override
  Future<RequestingResponse<dynamic>> post(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
    Map<String, dynamic>? header,
    bool isFullPath = false,
  }) async {
    return _request(
      path,
      queryParameters: queryParameters,
      body: body,
      header: header,
      httpMethod: HttpMethod.POST,
      isFullPath: isFullPath,
    );
  }

  @override
  Future<RequestingResponse<dynamic>> put(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
    Map<String, dynamic>? header,
    bool isFullPath = false,
  }) async {
    return _request(
      path,
      queryParameters: queryParameters,
      body: body,
      header: header,
      httpMethod: HttpMethod.PUT,
      isFullPath: isFullPath,
    );
  }
}
