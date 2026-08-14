# woutalma_api_client.api.PropertiesApi

## Load the API package
```dart
import 'package:woutalma_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**propertiesControllerClose**](PropertiesApi.md#propertiescontrollerclose) | **DELETE** /properties/{id} | Withdraw a listing. Soft delete to CLOSED so client contact history keeps resolving it.
[**propertiesControllerCreate**](PropertiesApi.md#propertiescontrollercreate) | **POST** /properties | Publish a listing under the caller’s own broker profile (B03 save).
[**propertiesControllerFindAll**](PropertiesApi.md#propertiescontrollerfindall) | **GET** /properties | Mirrors PropertyRepository.all()/.discoverable() — pass discoverableOnly&#x3D;true for the latter.
[**propertiesControllerFindById**](PropertiesApi.md#propertiescontrollerfindbyid) | **GET** /properties/{id} | Mirrors PropertyRepository.byId.
[**propertiesControllerFindPhoto**](PropertiesApi.md#propertiescontrollerfindphoto) | **GET** /properties/photos/{photoId} | Bytes behind an &#x60;api:&lt;id&gt;&#x60; photoAssets entry. Public, like the listing itself.
[**propertiesControllerUpdate**](PropertiesApi.md#propertiescontrollerupdate) | **PATCH** /properties/{id} | Edit one of the caller’s own listings. 403 for someone else’s.


# **propertiesControllerClose**
> PropertyDto propertiesControllerClose(id)

Withdraw a listing. Soft delete to CLOSED so client contact history keeps resolving it.

### Example
```dart
import 'package:woutalma_api_client/api.dart';

final api = WoutalmaApiClient().getPropertiesApi();
final String id = id_example; // String | 

try {
    final response = api.propertiesControllerClose(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PropertiesApi->propertiesControllerClose: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**PropertyDto**](PropertyDto.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **propertiesControllerCreate**
> PropertyDto propertiesControllerCreate(createPropertyDto)

Publish a listing under the caller’s own broker profile (B03 save).

### Example
```dart
import 'package:woutalma_api_client/api.dart';

final api = WoutalmaApiClient().getPropertiesApi();
final CreatePropertyDto createPropertyDto = ; // CreatePropertyDto | 

try {
    final response = api.propertiesControllerCreate(createPropertyDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PropertiesApi->propertiesControllerCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createPropertyDto** | [**CreatePropertyDto**](CreatePropertyDto.md)|  | 

### Return type

[**PropertyDto**](PropertyDto.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **propertiesControllerFindAll**
> BuiltList<PropertyDto> propertiesControllerFindAll(discoverableOnly)

Mirrors PropertyRepository.all()/.discoverable() — pass discoverableOnly=true for the latter.

### Example
```dart
import 'package:woutalma_api_client/api.dart';

final api = WoutalmaApiClient().getPropertiesApi();
final String discoverableOnly = discoverableOnly_example; // String | 

try {
    final response = api.propertiesControllerFindAll(discoverableOnly);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PropertiesApi->propertiesControllerFindAll: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **discoverableOnly** | **String**|  | 

### Return type

[**BuiltList&lt;PropertyDto&gt;**](PropertyDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **propertiesControllerFindById**
> PropertyDto propertiesControllerFindById(id)

Mirrors PropertyRepository.byId.

### Example
```dart
import 'package:woutalma_api_client/api.dart';

final api = WoutalmaApiClient().getPropertiesApi();
final String id = id_example; // String | 

try {
    final response = api.propertiesControllerFindById(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PropertiesApi->propertiesControllerFindById: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**PropertyDto**](PropertyDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **propertiesControllerFindPhoto**
> propertiesControllerFindPhoto(photoId)

Bytes behind an `api:<id>` photoAssets entry. Public, like the listing itself.

### Example
```dart
import 'package:woutalma_api_client/api.dart';

final api = WoutalmaApiClient().getPropertiesApi();
final String photoId = photoId_example; // String | 

try {
    api.propertiesControllerFindPhoto(photoId);
} on DioException catch (e) {
    print('Exception when calling PropertiesApi->propertiesControllerFindPhoto: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **photoId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **propertiesControllerUpdate**
> PropertyDto propertiesControllerUpdate(id, updatePropertyDto)

Edit one of the caller’s own listings. 403 for someone else’s.

### Example
```dart
import 'package:woutalma_api_client/api.dart';

final api = WoutalmaApiClient().getPropertiesApi();
final String id = id_example; // String | 
final UpdatePropertyDto updatePropertyDto = ; // UpdatePropertyDto | 

try {
    final response = api.propertiesControllerUpdate(id, updatePropertyDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PropertiesApi->propertiesControllerUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **updatePropertyDto** | [**UpdatePropertyDto**](UpdatePropertyDto.md)|  | 

### Return type

[**PropertyDto**](PropertyDto.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

