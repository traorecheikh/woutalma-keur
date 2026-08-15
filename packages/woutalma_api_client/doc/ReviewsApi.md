# woutalma_api_client.api.ReviewsApi

## Load the API package
```dart
import 'package:woutalma_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**reviewsControllerAll**](ReviewsApi.md#reviewscontrollerall) | **GET** /reviews | Published reviews only, every broker together — feeds the client-side averages.
[**reviewsControllerByBroker**](ReviewsApi.md#reviewscontrollerbybroker) | **GET** /reviews/broker/{brokerId} | Published reviews of one broker. &#x60;onlyPublic&#x3D;false&#x60; additionally returns the pending/rejected ones, and only to the broker who owns the profile — for anyone else it is ignored.
[**reviewsControllerCreate**](ReviewsApi.md#reviewscontrollercreate) | **POST** /reviews | Port of ReviewEligibilityService — 403s with a &#x60;reason&#x60; (noContact/notReached/alreadyReviewed/notOwner) when not eligible.
[**reviewsControllerReply**](ReviewsApi.md#reviewscontrollerreply) | **PATCH** /reviews/{id}/reply | B05 — the broker answers a review about them. 403 for a review about someone else.
[**reviewsControllerReport**](ReviewsApi.md#reviewscontrollerreport) | **POST** /reviews/{id}/report | B05 — the broker asks for a review to be re-moderated. Sets PENDING and nothing else: a broker cannot reject a review about them.


# **reviewsControllerAll**
> BuiltList<ReviewDto> reviewsControllerAll()

Published reviews only, every broker together — feeds the client-side averages.

### Example
```dart
import 'package:woutalma_api_client/api.dart';

final api = WoutalmaApiClient().getReviewsApi();

try {
    final response = api.reviewsControllerAll();
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReviewsApi->reviewsControllerAll: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

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

Published reviews of one broker. `onlyPublic=false` additionally returns the pending/rejected ones, and only to the broker who owns the profile — for anyone else it is ignored.

### Example
```dart
import 'package:woutalma_api_client/api.dart';

final api = WoutalmaApiClient().getReviewsApi();
final String brokerId = brokerId_example; // String | 
final bool onlyPublic = true; // bool | 

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
 **onlyPublic** | **bool**|  | [optional] 

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

# **reviewsControllerReply**
> ReviewDto reviewsControllerReply(id, replyReviewDto)

B05 — the broker answers a review about them. 403 for a review about someone else.

### Example
```dart
import 'package:woutalma_api_client/api.dart';

final api = WoutalmaApiClient().getReviewsApi();
final String id = id_example; // String | 
final ReplyReviewDto replyReviewDto = ; // ReplyReviewDto | 

try {
    final response = api.reviewsControllerReply(id, replyReviewDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReviewsApi->reviewsControllerReply: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **replyReviewDto** | [**ReplyReviewDto**](ReplyReviewDto.md)|  | 

### Return type

[**ReviewDto**](ReviewDto.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **reviewsControllerReport**
> ReviewDto reviewsControllerReport(id, reportReviewDto)

B05 — the broker asks for a review to be re-moderated. Sets PENDING and nothing else: a broker cannot reject a review about them.

### Example
```dart
import 'package:woutalma_api_client/api.dart';

final api = WoutalmaApiClient().getReviewsApi();
final String id = id_example; // String | 
final ReportReviewDto reportReviewDto = ; // ReportReviewDto | 

try {
    final response = api.reviewsControllerReport(id, reportReviewDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReviewsApi->reviewsControllerReport: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **reportReviewDto** | [**ReportReviewDto**](ReportReviewDto.md)|  | 

### Return type

[**ReviewDto**](ReviewDto.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

