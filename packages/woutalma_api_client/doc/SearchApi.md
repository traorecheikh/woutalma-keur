# woutalma_api_client.api.SearchApi

## Load the API package
```dart
import 'package:woutalma_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**searchControllerFindBrokers**](SearchApi.md#searchcontrollerfindbrokers) | **GET** /search/brokers | Mirrors DiscoveryService.findBrokers, ranked server-side via PostGIS.
[**searchControllerFindProperties**](SearchApi.md#searchcontrollerfindproperties) | **GET** /search/properties | Mirrors DiscoveryService.findProperties, sorted by distance.
[**searchControllerSuggestions**](SearchApi.md#searchcontrollersuggestions) | **GET** /search/suggestions | Returns ranked server-side search suggestions.


# **searchControllerFindBrokers**
> BrokerSearchResultsDto searchControllerFindBrokers(lat, lng, transaction, kind, maxPrice, radiusMeters, query, limit, offset)

Mirrors DiscoveryService.findBrokers, ranked server-side via PostGIS.

### Example
```dart
import 'package:woutalma_api_client/api.dart';

final api = WoutalmaApiClient().getSearchApi();
final num lat = 8.14; // num | Client latitude — required to rank/sort by distance.
final num lng = 8.14; // num | Client longitude — required to rank/sort by distance.
final String transaction = transaction_example; // String | 
final String kind = kind_example; // String | 
final num maxPrice = 8.14; // num | 
final num radiusMeters = 8.14; // num | Meters.
final String query = query_example; // String | Free text against broker name/coverage or property title/neighbourhood.
final num limit = 8.14; // num | 
final num offset = 8.14; // num | 

try {
    final response = api.searchControllerFindBrokers(lat, lng, transaction, kind, maxPrice, radiusMeters, query, limit, offset);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SearchApi->searchControllerFindBrokers: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **lat** | **num**| Client latitude — required to rank/sort by distance. | 
 **lng** | **num**| Client longitude — required to rank/sort by distance. | 
 **transaction** | **String**|  | [optional] 
 **kind** | **String**|  | [optional] 
 **maxPrice** | **num**|  | [optional] 
 **radiusMeters** | **num**| Meters. | [optional] 
 **query** | **String**| Free text against broker name/coverage or property title/neighbourhood. | [optional] 
 **limit** | **num**|  | [optional] [default to 20]
 **offset** | **num**|  | [optional] [default to 0]

### Return type

[**BrokerSearchResultsDto**](BrokerSearchResultsDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **searchControllerFindProperties**
> PropertySearchResultsDto searchControllerFindProperties(lat, lng, transaction, kind, maxPrice, radiusMeters, query, limit, offset)

Mirrors DiscoveryService.findProperties, sorted by distance.

### Example
```dart
import 'package:woutalma_api_client/api.dart';

final api = WoutalmaApiClient().getSearchApi();
final num lat = 8.14; // num | Client latitude — required to rank/sort by distance.
final num lng = 8.14; // num | Client longitude — required to rank/sort by distance.
final String transaction = transaction_example; // String | 
final String kind = kind_example; // String | 
final num maxPrice = 8.14; // num | 
final num radiusMeters = 8.14; // num | Meters.
final String query = query_example; // String | Free text against broker name/coverage or property title/neighbourhood.
final num limit = 8.14; // num | 
final num offset = 8.14; // num | 

try {
    final response = api.searchControllerFindProperties(lat, lng, transaction, kind, maxPrice, radiusMeters, query, limit, offset);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SearchApi->searchControllerFindProperties: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **lat** | **num**| Client latitude — required to rank/sort by distance. | 
 **lng** | **num**| Client longitude — required to rank/sort by distance. | 
 **transaction** | **String**|  | [optional] 
 **kind** | **String**|  | [optional] 
 **maxPrice** | **num**|  | [optional] 
 **radiusMeters** | **num**| Meters. | [optional] 
 **query** | **String**| Free text against broker name/coverage or property title/neighbourhood. | [optional] 
 **limit** | **num**|  | [optional] [default to 20]
 **offset** | **num**|  | [optional] [default to 0]

### Return type

[**PropertySearchResultsDto**](PropertySearchResultsDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **searchControllerSuggestions**
> SearchSuggestionsDto searchControllerSuggestions(lat, lng, transaction, kind, maxPrice, radiusMeters, query, limit, offset)

Returns ranked server-side search suggestions.

### Example
```dart
import 'package:woutalma_api_client/api.dart';

final api = WoutalmaApiClient().getSearchApi();
final num lat = 8.14; // num | Client latitude — required to rank/sort by distance.
final num lng = 8.14; // num | Client longitude — required to rank/sort by distance.
final String transaction = transaction_example; // String | 
final String kind = kind_example; // String | 
final num maxPrice = 8.14; // num | 
final num radiusMeters = 8.14; // num | Meters.
final String query = query_example; // String | Free text against broker name/coverage or property title/neighbourhood.
final num limit = 8.14; // num | 
final num offset = 8.14; // num | 

try {
    final response = api.searchControllerSuggestions(lat, lng, transaction, kind, maxPrice, radiusMeters, query, limit, offset);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SearchApi->searchControllerSuggestions: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **lat** | **num**| Client latitude — required to rank/sort by distance. | 
 **lng** | **num**| Client longitude — required to rank/sort by distance. | 
 **transaction** | **String**|  | [optional] 
 **kind** | **String**|  | [optional] 
 **maxPrice** | **num**|  | [optional] 
 **radiusMeters** | **num**| Meters. | [optional] 
 **query** | **String**| Free text against broker name/coverage or property title/neighbourhood. | [optional] 
 **limit** | **num**|  | [optional] [default to 20]
 **offset** | **num**|  | [optional] [default to 0]

### Return type

[**SearchSuggestionsDto**](SearchSuggestionsDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

