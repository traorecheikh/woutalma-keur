# woutalma_api_client.api.ContactsApi

## Load the API package
```dart
import 'package:woutalma_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**contactsControllerAll**](ContactsApi.md#contactscontrollerall) | **GET** /contacts | 
[**contactsControllerById**](ContactsApi.md#contactscontrollerbyid) | **GET** /contacts/{id} | 
[**contactsControllerLog**](ContactsApi.md#contactscontrollerlog) | **POST** /contacts | Logs a contact BEFORE the client opens the external channel (tel:/sms:/wa.me) — PRODUCT.md §3: \&quot;Journal local avant l&#39;ouverture du canal externe.\&quot;
[**contactsControllerUpdateOutcome**](ContactsApi.md#contactscontrollerupdateoutcome) | **PATCH** /contacts/{id}/outcome | Records the exchange result — &#39;reached&#39; is the only outcome that opens a review.


# **contactsControllerAll**
> BuiltList<ContactLogDto> contactsControllerAll()



### Example
```dart
import 'package:woutalma_api_client/api.dart';

final api = WoutalmaApiClient().getContactsApi();

try {
    final response = api.contactsControllerAll();
    print(response);
} on DioException catch (e) {
    print('Exception when calling ContactsApi->contactsControllerAll: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;ContactLogDto&gt;**](ContactLogDto.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **contactsControllerById**
> ContactLogDto contactsControllerById(id)



### Example
```dart
import 'package:woutalma_api_client/api.dart';

final api = WoutalmaApiClient().getContactsApi();
final String id = id_example; // String | 

try {
    final response = api.contactsControllerById(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ContactsApi->contactsControllerById: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**ContactLogDto**](ContactLogDto.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **contactsControllerLog**
> ContactLogDto contactsControllerLog(createContactDto)

Logs a contact BEFORE the client opens the external channel (tel:/sms:/wa.me) — PRODUCT.md §3: \"Journal local avant l'ouverture du canal externe.\"

### Example
```dart
import 'package:woutalma_api_client/api.dart';

final api = WoutalmaApiClient().getContactsApi();
final CreateContactDto createContactDto = ; // CreateContactDto | 

try {
    final response = api.contactsControllerLog(createContactDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ContactsApi->contactsControllerLog: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createContactDto** | [**CreateContactDto**](CreateContactDto.md)|  | 

### Return type

[**ContactLogDto**](ContactLogDto.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **contactsControllerUpdateOutcome**
> ContactLogDto contactsControllerUpdateOutcome(id, updateContactOutcomeDto)

Records the exchange result — 'reached' is the only outcome that opens a review.

### Example
```dart
import 'package:woutalma_api_client/api.dart';

final api = WoutalmaApiClient().getContactsApi();
final String id = id_example; // String | 
final UpdateContactOutcomeDto updateContactOutcomeDto = ; // UpdateContactOutcomeDto | 

try {
    final response = api.contactsControllerUpdateOutcome(id, updateContactOutcomeDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ContactsApi->contactsControllerUpdateOutcome: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **updateContactOutcomeDto** | [**UpdateContactOutcomeDto**](UpdateContactOutcomeDto.md)|  | 

### Return type

[**ContactLogDto**](ContactLogDto.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

