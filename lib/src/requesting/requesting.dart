import 'dart:async';

import 'package:dio/dio.dart';
import 'package:events_time_microapp_dependencies/events_time_microapp_dependencies.dart';
import 'package:events_time_microapp_dependencies/src/requesting/http_method.dart';
import 'package:events_time_microapp_hub/domain/models/all.dart';
import 'package:events_time_microapp_hub/microapp/hub_states.dart';
import 'package:events_time_microapp_hub/microapp/microapp_hub.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

abstract class IRequesting {
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
  String? accessToken;
  String? refreshToken;

  late Dio dio;
  late MicroappHub hub;
  final String baseUrl;
  final Map<String, ValueNotifier<dynamic>> messengers;

  int refreshCountsAttempts = 0;

  Requesting({
    required this.baseUrl,
    required this.messengers,
  }) {
    dio = Dio();
    hub = messengers['hub']! as MicroappHub;
    if (kDebugMode) dio.interceptors.add(PrettyDioLogger());

    hub.addListener(() {
      if (hub.value is SentJWTTokensHubState ||
          hub.value is SuccessTokensRenewingHubState) {
        final JWTTokensHubModel varJWTTokensHubModel =
            (hub.value is SentJWTTokensHubState
                    ? hub.value as SentJWTTokensHubState
                    : hub.value as SuccessTokensRenewingHubState)
                .payload as JWTTokensHubModel;

        accessToken = varJWTTokensHubModel.accessToken;
        refreshToken = varJWTTokensHubModel.refreshToken;
        return;
      }

      if (hub.value is LogoutHubState ||
          hub.value is ErrorTokensRenewingHubState) {
        accessToken = null;
        refreshToken = null;
        return;
      }
    });

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
      onError: (DioException exception, ErrorInterceptorHandler handler) {
        if (exception.response != null &&
            exception.response!.statusCode == 401 &&
            refreshCountsAttempts == 0) {
          refreshCountsAttempts += 1;
          _refreshTokenAndRetry(exception.response!.requestOptions, handler);
          return;
        }

        refreshCountsAttempts = 0;
        return handler.next(exception);
      },
    ));
  }

  Future<bool> _isSuccessTokensRenewing() async {
    hub.send(AccessTokenExpiredHubState(refreshToken));

    final Completer<bool> completer = Completer<bool>();
    final Timer timer = Timer(const Duration(seconds: 5), () {
      completer.complete(false);
    });

    final Function() refreshTokenListener;
    refreshTokenListener = () {
      if (hub.value is SuccessTokensRenewingHubState) {
        completer.complete(true);
        return;
      }

      if (hub.value is ErrorTokensRenewingHubState) {
        completer.complete(false);
        return;
      }
    };

    hub.addListener(refreshTokenListener);
    final bool isSuccess = await completer.future;
    if (timer.isActive) timer.cancel();
    hub.removeListener(refreshTokenListener);

    return isSuccess;
  }

  Future<void> _refreshTokenAndRetry(
    RequestOptions requestOptions,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      if (!await _isSuccessTokensRenewing()) throw Exception();

      requestOptions.headers['Authorization'] = 'Bearer $accessToken';
      handler.resolve(await dio.fetch(requestOptions));
    } catch (_) {
      hub.send(LogoutHubState());
    }
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
