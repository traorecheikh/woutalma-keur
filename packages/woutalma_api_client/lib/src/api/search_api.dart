//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'package:woutalma_api_client/src/api_util.dart';
import 'package:woutalma_api_client/src/model/broker_search_results_dto.dart';
import 'package:woutalma_api_client/src/model/property_search_results_dto.dart';
import 'package:woutalma_api_client/src/model/search_suggestions_dto.dart';

class SearchApi {
  final Dio _dio;

  final Serializers _serializers;

  const SearchApi(this._dio, this._serializers);

  /// Mirrors DiscoveryService.findBrokers, ranked server-side via PostGIS.
  ///
  ///
  /// Parameters:
  /// * [lat] - Client latitude — required to rank/sort by distance.
  /// * [lng] - Client longitude — required to rank/sort by distance.
  /// * [transaction]
  /// * [kind]
  /// * [maxPrice]
  /// * [radiusMeters] - Meters.
  /// * [query] - Free text against broker name/coverage or property title/neighbourhood.
  /// * [limit]
  /// * [offset]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [BrokerSearchResultsDto] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<BrokerSearchResultsDto>> searchControllerFindBrokers({
    required num lat,
    required num lng,
    String? transaction,
    String? kind,
    num? maxPrice,
    num? radiusMeters,
    String? query,
    num? limit = 20,
    num? offset = 0,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/search/brokers';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _queryParameters = <String, dynamic>{
      r'lat': encodeQueryParameter(_serializers, lat, const FullType(num)),
      r'lng': encodeQueryParameter(_serializers, lng, const FullType(num)),
      if (transaction != null)
        r'transaction': encodeQueryParameter(
            _serializers, transaction, const FullType(String)),
      if (kind != null)
        r'kind':
            encodeQueryParameter(_serializers, kind, const FullType(String)),
      if (maxPrice != null)
        r'maxPrice':
            encodeQueryParameter(_serializers, maxPrice, const FullType(num)),
      if (radiusMeters != null)
        r'radiusMeters': encodeQueryParameter(
            _serializers, radiusMeters, const FullType(num)),
      if (query != null)
        r'query':
            encodeQueryParameter(_serializers, query, const FullType(String)),
      if (limit != null)
        r'limit':
            encodeQueryParameter(_serializers, limit, const FullType(num)),
      if (offset != null)
        r'offset':
            encodeQueryParameter(_serializers, offset, const FullType(num)),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    BrokerSearchResultsDto? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(BrokerSearchResultsDto),
            ) as BrokerSearchResultsDto;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<BrokerSearchResultsDto>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// Mirrors DiscoveryService.findProperties, sorted by distance.
  ///
  ///
  /// Parameters:
  /// * [lat] - Client latitude — required to rank/sort by distance.
  /// * [lng] - Client longitude — required to rank/sort by distance.
  /// * [transaction]
  /// * [kind]
  /// * [maxPrice]
  /// * [radiusMeters] - Meters.
  /// * [query] - Free text against broker name/coverage or property title/neighbourhood.
  /// * [limit]
  /// * [offset]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [PropertySearchResultsDto] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<PropertySearchResultsDto>> searchControllerFindProperties({
    required num lat,
    required num lng,
    String? transaction,
    String? kind,
    num? maxPrice,
    num? radiusMeters,
    String? query,
    num? limit = 20,
    num? offset = 0,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/search/properties';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _queryParameters = <String, dynamic>{
      r'lat': encodeQueryParameter(_serializers, lat, const FullType(num)),
      r'lng': encodeQueryParameter(_serializers, lng, const FullType(num)),
      if (transaction != null)
        r'transaction': encodeQueryParameter(
            _serializers, transaction, const FullType(String)),
      if (kind != null)
        r'kind':
            encodeQueryParameter(_serializers, kind, const FullType(String)),
      if (maxPrice != null)
        r'maxPrice':
            encodeQueryParameter(_serializers, maxPrice, const FullType(num)),
      if (radiusMeters != null)
        r'radiusMeters': encodeQueryParameter(
            _serializers, radiusMeters, const FullType(num)),
      if (query != null)
        r'query':
            encodeQueryParameter(_serializers, query, const FullType(String)),
      if (limit != null)
        r'limit':
            encodeQueryParameter(_serializers, limit, const FullType(num)),
      if (offset != null)
        r'offset':
            encodeQueryParameter(_serializers, offset, const FullType(num)),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    PropertySearchResultsDto? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(PropertySearchResultsDto),
            ) as PropertySearchResultsDto;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<PropertySearchResultsDto>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// Returns ranked server-side search suggestions.
  ///
  ///
  /// Parameters:
  /// * [lat] - Client latitude — required to rank/sort by distance.
  /// * [lng] - Client longitude — required to rank/sort by distance.
  /// * [transaction]
  /// * [kind]
  /// * [maxPrice]
  /// * [radiusMeters] - Meters.
  /// * [query] - Free text against broker name/coverage or property title/neighbourhood.
  /// * [limit]
  /// * [offset]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [SearchSuggestionsDto] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<SearchSuggestionsDto>> searchControllerSuggestions({
    required num lat,
    required num lng,
    String? transaction,
    String? kind,
    num? maxPrice,
    num? radiusMeters,
    String? query,
    num? limit = 20,
    num? offset = 0,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/search/suggestions';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _queryParameters = <String, dynamic>{
      r'lat': encodeQueryParameter(_serializers, lat, const FullType(num)),
      r'lng': encodeQueryParameter(_serializers, lng, const FullType(num)),
      if (transaction != null)
        r'transaction': encodeQueryParameter(
            _serializers, transaction, const FullType(String)),
      if (kind != null)
        r'kind':
            encodeQueryParameter(_serializers, kind, const FullType(String)),
      if (maxPrice != null)
        r'maxPrice':
            encodeQueryParameter(_serializers, maxPrice, const FullType(num)),
      if (radiusMeters != null)
        r'radiusMeters': encodeQueryParameter(
            _serializers, radiusMeters, const FullType(num)),
      if (query != null)
        r'query':
            encodeQueryParameter(_serializers, query, const FullType(String)),
      if (limit != null)
        r'limit':
            encodeQueryParameter(_serializers, limit, const FullType(num)),
      if (offset != null)
        r'offset':
            encodeQueryParameter(_serializers, offset, const FullType(num)),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    SearchSuggestionsDto? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(SearchSuggestionsDto),
            ) as SearchSuggestionsDto;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<SearchSuggestionsDto>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }
}
