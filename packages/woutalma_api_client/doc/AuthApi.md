# woutalma_api_client.api.AuthApi

## Load the API package
```dart
import 'package:woutalma_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**authControllerRefresh**](AuthApi.md#authcontrollerrefresh) | **POST** /auth/refresh | Exchange a refresh token for a fresh access/refresh pair.
[**authControllerRequestDevCode**](AuthApi.md#authcontrollerrequestdevcode) | **POST** /auth/dev/otp/request | Staging only. Returns the six-digit code for a phone number instead of sending an SMS. 404 unless DEV_AUTH_ENABLED&#x3D;true.
[**authControllerSignInAsDev**](AuthApi.md#authcontrollersigninasdev) | **POST** /auth/dev | Sign in as a seeded demo persona. Returns 404 unless the deployment sets DEV_AUTH_ENABLED&#x3D;true, and 401 without the matching x-dev-auth-secret header.
[**authControllerSignInWithGoogle**](AuthApi.md#authcontrollersigninwithgoogle) | **POST** /auth/google | Sign in (or sign up) with a Google ID token obtained on-device.
[**authControllerVerifyDevCode**](AuthApi.md#authcontrollerverifydevcode) | **POST** /auth/dev/otp/verify | Staging only. Verifies the code and opens a session, creating the account on first use. Pass asBroker to also create a broker profile.


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

# **authControllerRequestDevCode**
> DevRequestCodeResponseDto authControllerRequestDevCode(xDevAuthSecret, devRequestCodeDto)

Staging only. Returns the six-digit code for a phone number instead of sending an SMS. 404 unless DEV_AUTH_ENABLED=true.

### Example
```dart
import 'package:woutalma_api_client/api.dart';

final api = WoutalmaApiClient().getAuthApi();
final String xDevAuthSecret = xDevAuthSecret_example; // String | 
final DevRequestCodeDto devRequestCodeDto = ; // DevRequestCodeDto | 

try {
    final response = api.authControllerRequestDevCode(xDevAuthSecret, devRequestCodeDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerRequestDevCode: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xDevAuthSecret** | **String**|  | 
 **devRequestCodeDto** | [**DevRequestCodeDto**](DevRequestCodeDto.md)|  | 

### Return type

[**DevRequestCodeResponseDto**](DevRequestCodeResponseDto.md)

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

# **authControllerVerifyDevCode**
> AuthSessionDto authControllerVerifyDevCode(xDevAuthSecret, devVerifyCodeDto)

Staging only. Verifies the code and opens a session, creating the account on first use. Pass asBroker to also create a broker profile.

### Example
```dart
import 'package:woutalma_api_client/api.dart';

final api = WoutalmaApiClient().getAuthApi();
final String xDevAuthSecret = xDevAuthSecret_example; // String | 
final DevVerifyCodeDto devVerifyCodeDto = ; // DevVerifyCodeDto | 

try {
    final response = api.authControllerVerifyDevCode(xDevAuthSecret, devVerifyCodeDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerVerifyDevCode: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xDevAuthSecret** | **String**|  | 
 **devVerifyCodeDto** | [**DevVerifyCodeDto**](DevVerifyCodeDto.md)|  | 

### Return type

[**AuthSessionDto**](AuthSessionDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

