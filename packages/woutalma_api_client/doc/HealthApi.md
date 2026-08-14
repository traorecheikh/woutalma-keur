# woutalma_api_client.api.HealthApi

## Load the API package
```dart
import 'package:woutalma_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**healthControllerLiveness**](HealthApi.md#healthcontrollerliveness) | **GET** /healthz | Liveness. Always 200 while the process is up. Never touches the database.
[**healthControllerReadiness**](HealthApi.md#healthcontrollerreadiness) | **GET** /readyz | Readiness. Round-trips the database so a boot-time ping actually warms the connection pool.


# **healthControllerLiveness**
> LivenessDto healthControllerLiveness()

Liveness. Always 200 while the process is up. Never touches the database.

### Example
```dart
import 'package:woutalma_api_client/api.dart';

final api = WoutalmaApiClient().getHealthApi();

try {
    final response = api.healthControllerLiveness();
    print(response);
} on DioException catch (e) {
    print('Exception when calling HealthApi->healthControllerLiveness: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**LivenessDto**](LivenessDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **healthControllerReadiness**
> ReadinessDto healthControllerReadiness()

Readiness. Round-trips the database so a boot-time ping actually warms the connection pool.

### Example
```dart
import 'package:woutalma_api_client/api.dart';

final api = WoutalmaApiClient().getHealthApi();

try {
    final response = api.healthControllerReadiness();
    print(response);
} on DioException catch (e) {
    print('Exception when calling HealthApi->healthControllerReadiness: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ReadinessDto**](ReadinessDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

