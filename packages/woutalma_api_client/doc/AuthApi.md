# woutalma_api_client.api.AuthApi

## Load the API package
```dart
import 'package:woutalma_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**authControllerRefresh**](AuthApi.md#authcontrollerrefresh) | **POST** /auth/refresh | Exchange a refresh token for a fresh access/refresh pair.
[**authControllerSignInAsDev**](AuthApi.md#authcontrollersigninasdev) | **POST** /auth/dev | Sign in as a seeded demo persona. Returns 404 unless the deployment sets DEV_AUTH_ENABLED&#x3D;true, and 401 without the matching x-dev-auth-secret header.
[**authControllerSignInWithGoogle**](AuthApi.md#authcontrollersigninwithgoogle) | **POST** /auth/google | Sign in (or sign up) with a Google ID token obtained on-device.


# **authControllerRefresh**
> AuthSessionDto authControllerRefresh(refreshSessionDto)

Exchange a refresh token for a fresh access/refresh pair.

### Example
```dart
import 'package:woutalma_api_client/api.dart';

final api = WoutalmaApiClient().getAuthApi();
final RefreshSessionDto refreshSessionDto = ; // RefreshSessionDto | 

try {
    final response = api.authControllerRefresh(refreshSessionDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerRefresh: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **refreshSessionDto** | [**RefreshSessionDto**](RefreshSessionDto.md)|  | 

### Return type

[**AuthSessionDto**](AuthSessionDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authControllerSignInAsDev**
> AuthSessionDto authControllerSignInAsDev(xDevAuthSecret, devSignInDto)

Sign in as a seeded demo persona. Returns 404 unless the deployment sets DEV_AUTH_ENABLED=true, and 401 without the matching x-dev-auth-secret header.

### Example
```dart
import 'package:woutalma_api_client/api.dart';

final api = WoutalmaApiClient().getAuthApi();
final String xDevAuthSecret = xDevAuthSecret_example; // String | 
final DevSignInDto devSignInDto = ; // DevSignInDto | 

try {
    final response = api.authControllerSignInAsDev(xDevAuthSecret, devSignInDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerSignInAsDev: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xDevAuthSecret** | **String**|  | 
 **devSignInDto** | [**DevSignInDto**](DevSignInDto.md)|  | 

### Return type

[**AuthSessionDto**](AuthSessionDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authControllerSignInWithGoogle**
> AuthSessionDto authControllerSignInWithGoogle(googleSignInDto)

Sign in (or sign up) with a Google ID token obtained on-device.

### Example
```dart
import 'package:woutalma_api_client/api.dart';

final api = WoutalmaApiClient().getAuthApi();
final GoogleSignInDto googleSignInDto = ; // GoogleSignInDto | 

try {
    final response = api.authControllerSignInWithGoogle(googleSignInDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerSignInWithGoogle: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **googleSignInDto** | [**GoogleSignInDto**](GoogleSignInDto.md)|  | 

### Return type

[**AuthSessionDto**](AuthSessionDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

