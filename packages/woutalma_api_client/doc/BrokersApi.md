# woutalma_api_client.api.BrokersApi

## Load the API package
```dart
import 'package:woutalma_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**brokersControllerCreate**](BrokersApi.md#brokerscontrollercreate) | **POST** /brokers | B01 — create the caller’s broker profile. Starts unverified.
[**brokersControllerFindAll**](BrokersApi.md#brokerscontrollerfindall) | **GET** /brokers | Mirrors BrokerRepository.all().
[**brokersControllerFindById**](BrokersApi.md#brokerscontrollerfindbyid) | **GET** /brokers/{id} | Mirrors BrokerRepository.byId.
[**brokersControllerFindContacts**](BrokersApi.md#brokerscontrollerfindcontacts) | **GET** /brokers/{id}/contacts | Contacts this broker RECEIVED — the broker-side counterpart of GET /contacts, which only ever lists what the caller sent as a client. Owner-only, and without any client-identifying field (PRODUCT.md §4 rule 7).
[**brokersControllerFindProperties**](BrokersApi.md#brokerscontrollerfindproperties) | **GET** /brokers/{id}/properties | Mirrors PropertyRepository.byBroker(brokerId, {onlyDiscoverable}).
[**brokersControllerRequestVerification**](BrokersApi.md#brokerscontrollerrequestverification) | **POST** /brokers/{id}/verification-request | B02 — puts the caller’s own profile in the verification queue (NONE/REJECTED → PENDING). A request, never a grant: PENDING is the only status it can write, and calling it again while PENDING or VERIFIED just returns the current state.
[**brokersControllerUpdate**](BrokersApi.md#brokerscontrollerupdate) | **PATCH** /brokers/{id} | Edit the caller’s own broker profile. 403 for someone else’s.


# **brokersControllerCreate**
> BrokerDto brokersControllerCreate(createBrokerDto)

B01 — create the caller’s broker profile. Starts unverified.

### Example
```dart
import 'package:woutalma_api_client/api.dart';

final api = WoutalmaApiClient().getBrokersApi();
final CreateBrokerDto createBrokerDto = ; // CreateBrokerDto | 

try {
    final response = api.brokersControllerCreate(createBrokerDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BrokersApi->brokersControllerCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createBrokerDto** | [**CreateBrokerDto**](CreateBrokerDto.md)|  | 

### Return type

[**BrokerDto**](BrokerDto.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **brokersControllerFindAll**
> BuiltList<BrokerDto> brokersControllerFindAll()

Mirrors BrokerRepository.all().

### Example
```dart
import 'package:woutalma_api_client/api.dart';

final api = WoutalmaApiClient().getBrokersApi();

try {
    final response = api.brokersControllerFindAll();
    print(response);
} on DioException catch (e) {
    print('Exception when calling BrokersApi->brokersControllerFindAll: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;BrokerDto&gt;**](BrokerDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **brokersControllerFindById**
> BrokerDto brokersControllerFindById(id)

Mirrors BrokerRepository.byId.

### Example
```dart
import 'package:woutalma_api_client/api.dart';

final api = WoutalmaApiClient().getBrokersApi();
final String id = id_example; // String | 

try {
    final response = api.brokersControllerFindById(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BrokersApi->brokersControllerFindById: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**BrokerDto**](BrokerDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **brokersControllerFindContacts**
> BuiltList<BrokerContactLogDto> brokersControllerFindContacts(id)

Contacts this broker RECEIVED — the broker-side counterpart of GET /contacts, which only ever lists what the caller sent as a client. Owner-only, and without any client-identifying field (PRODUCT.md §4 rule 7).

### Example
```dart
import 'package:woutalma_api_client/api.dart';

final api = WoutalmaApiClient().getBrokersApi();
final String id = id_example; // String | 

try {
    final response = api.brokersControllerFindContacts(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BrokersApi->brokersControllerFindContacts: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**BuiltList&lt;BrokerContactLogDto&gt;**](BrokerContactLogDto.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **brokersControllerFindProperties**
> BuiltList<PropertyDto> brokersControllerFindProperties(id, onlyDiscoverable)

Mirrors PropertyRepository.byBroker(brokerId, {onlyDiscoverable}).

### Example
```dart
import 'package:woutalma_api_client/api.dart';

final api = WoutalmaApiClient().getBrokersApi();
final String id = id_example; // String | 
final bool onlyDiscoverable = true; // bool | 

try {
    final response = api.brokersControllerFindProperties(id, onlyDiscoverable);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BrokersApi->brokersControllerFindProperties: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **onlyDiscoverable** | **bool**|  | [optional] 

### Return type

[**BuiltList&lt;PropertyDto&gt;**](PropertyDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **brokersControllerRequestVerification**
> BrokerDto brokersControllerRequestVerification(id)

B02 — puts the caller’s own profile in the verification queue (NONE/REJECTED → PENDING). A request, never a grant: PENDING is the only status it can write, and calling it again while PENDING or VERIFIED just returns the current state.

### Example
```dart
import 'package:woutalma_api_client/api.dart';

final api = WoutalmaApiClient().getBrokersApi();
final String id = id_example; // String | 

try {
    final response = api.brokersControllerRequestVerification(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BrokersApi->brokersControllerRequestVerification: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**BrokerDto**](BrokerDto.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **brokersControllerUpdate**
> BrokerDto brokersControllerUpdate(id, updateBrokerDto)

Edit the caller’s own broker profile. 403 for someone else’s.

### Example
```dart
import 'package:woutalma_api_client/api.dart';

final api = WoutalmaApiClient().getBrokersApi();
final String id = id_example; // String | 
final UpdateBrokerDto updateBrokerDto = ; // UpdateBrokerDto | 

try {
    final response = api.brokersControllerUpdate(id, updateBrokerDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BrokersApi->brokersControllerUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **updateBrokerDto** | [**UpdateBrokerDto**](UpdateBrokerDto.md)|  | 

### Return type

[**BrokerDto**](BrokerDto.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

