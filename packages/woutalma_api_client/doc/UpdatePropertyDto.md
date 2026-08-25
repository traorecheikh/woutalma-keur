# woutalma_api_client.model.UpdatePropertyDto

## Load the model package
```dart
import 'package:woutalma_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**kind** | **String** |  | [optional] 
**transaction** | **String** |  | [optional] 
**title** | **String** | Trimmed, and runs of whitespace collapsed to one space, before storage. Accents and non-Latin scripts are preserved. Must not be empty once trimmed. | [optional] 
**description** | **String** | Composed by the editor from the entered data, overridable by the broker. Trimmed at the ends; internal line breaks are kept. | [optional] 
**price** | **num** | CFA francs, integer. At least 1 — a free listing is not a product feature — and at most 10000000000. | [optional] 
**surface** | **num** | Square metres. Omit or send null when unknown, never 0. At most 1000000. | [optional] 
**rooms** | **num** | Room count. 0 is accepted and meaningful for a LAND listing; null/omitted means unstated. At most 50. | [optional] 
**latitude** | **num** |  | [optional] 
**longitude** | **num** |  | [optional] 
**neighbourhood** | **String** | Quartier name. The client offers a picker of known Dakar quartiers, but any non-empty name is accepted — the list is not exhaustive. Trimmed and whitespace-collapsed before storage. | [optional] 
**status** | **String** |  | [optional] 
**photoAssets** | **BuiltList&lt;String&gt;** |  | [optional] 
**newPhotos** | [**BuiltList&lt;UploadPhotoDto&gt;**](UploadPhotoDto.md) |  | [optional] 
**voiceAsset** | **String** | Existing `api:<id>` key to keep. Send an empty string to remove the voice note. Omit to leave it unchanged. | [optional] 
**newVoiceNote** | [**UploadVoiceNoteDto**](UploadVoiceNoteDto.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


