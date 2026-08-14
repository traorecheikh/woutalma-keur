# woutalma_api_client.api.ReviewsApi

## Load the API package
```dart
import 'package:woutalma_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**reviewsControllerAll**](ReviewsApi.md#reviewscontrollerall) | **GET** /reviews | 
[**reviewsControllerByBroker**](ReviewsApi.md#reviewscontrollerbybroker) | **GET** /reviews/broker/{brokerId} | 
[**reviewsControllerCreate**](ReviewsApi.md#reviewscontrollercreate) | **POST** /reviews | Port of ReviewEligibilityService — 403s with a &#x60;reason&#x60; (noContact/notReached/alreadyReviewed/notOwner) when not eligible.


# **reviewsControllerAll**
> BuiltList<ReviewDto> reviewsControllerAll(onlyPublic)



### Example
```dart
import 'package:woutalma_api_client/api.dart';

final api = WoutalmaApiClient().getReviewsApi();
final String onlyPublic = onlyPublic_example; // String | 

try {
    final response = api.reviewsControllerAll(onlyPublic);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReviewsApi->reviewsControllerAll: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **onlyPublic** | **String**|  | 

### Return type

[**BuiltList&lt;ReviewDto&gt;**](ReviewDto.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **reviewsControllerByBroker**
> BuiltList<ReviewDto> reviewsControllerByBroker(brokerId, onlyPublic)



### Example
```dart
import 'package:woutalma_api_client/api.dart';

final api = WoutalmaApiClient().getReviewsApi();
final String brokerId = brokerId_example; // String | 
final String onlyPublic = onlyPublic_example; // String | 

try {
    final response = api.reviewsControllerByBroker(brokerId, onlyPublic);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReviewsApi->reviewsControllerByBroker: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **brokerId** | **String**|  | 
 **onlyPublic** | **String**|  | 

### Return type

[**BuiltList&lt;ReviewDto&gt;**](ReviewDto.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **reviewsControllerCreate**
> ReviewDto reviewsControllerCreate(createReviewDto)

Port of ReviewEligibilityService — 403s with a `reason` (noContact/notReached/alreadyReviewed/notOwner) when not eligible.

### Example
```dart
import 'package:woutalma_api_client/api.dart';

final api = WoutalmaApiClient().getReviewsApi();
final CreateReviewDto createReviewDto = ; // CreateReviewDto | 

try {
    final response = api.reviewsControllerCreate(createReviewDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReviewsApi->reviewsControllerCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createReviewDto** | [**CreateReviewDto**](CreateReviewDto.md)|  | 

### Return type

[**ReviewDto**](ReviewDto.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

