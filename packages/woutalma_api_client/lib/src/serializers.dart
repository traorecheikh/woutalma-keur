//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_import

import 'package:one_of_serializer/any_of_serializer.dart';
import 'package:one_of_serializer/one_of_serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:woutalma_api_client/src/date_serializer.dart';
import 'package:woutalma_api_client/src/model/date.dart';

import 'package:woutalma_api_client/src/model/auth_session_dto.dart';
import 'package:woutalma_api_client/src/model/broker_dto.dart';
import 'package:woutalma_api_client/src/model/broker_listing_dto.dart';
import 'package:woutalma_api_client/src/model/broker_search_results_dto.dart';
import 'package:woutalma_api_client/src/model/contact_log_dto.dart';
import 'package:woutalma_api_client/src/model/create_broker_dto.dart';
import 'package:woutalma_api_client/src/model/create_contact_dto.dart';
import 'package:woutalma_api_client/src/model/create_property_dto.dart';
import 'package:woutalma_api_client/src/model/create_review_dto.dart';
import 'package:woutalma_api_client/src/model/dev_sign_in_dto.dart';
import 'package:woutalma_api_client/src/model/geo_point_dto.dart';
import 'package:woutalma_api_client/src/model/google_sign_in_dto.dart';
import 'package:woutalma_api_client/src/model/liveness_dto.dart';
import 'package:woutalma_api_client/src/model/property_dto.dart';
import 'package:woutalma_api_client/src/model/property_search_results_dto.dart';
import 'package:woutalma_api_client/src/model/readiness_dto.dart';
import 'package:woutalma_api_client/src/model/refresh_session_dto.dart';
import 'package:woutalma_api_client/src/model/review_dto.dart';
import 'package:woutalma_api_client/src/model/search_suggestions_dto.dart';
import 'package:woutalma_api_client/src/model/update_broker_dto.dart';
import 'package:woutalma_api_client/src/model/update_contact_outcome_dto.dart';
import 'package:woutalma_api_client/src/model/update_property_dto.dart';
import 'package:woutalma_api_client/src/model/upload_photo_dto.dart';

part 'serializers.g.dart';

@SerializersFor([
  AuthSessionDto,
  BrokerDto,
  BrokerListingDto,
  BrokerSearchResultsDto,
  ContactLogDto,
  CreateBrokerDto,
  CreateContactDto,
  CreatePropertyDto,
  CreateReviewDto,
  DevSignInDto,
  GeoPointDto,
  GoogleSignInDto,
  LivenessDto,
  PropertyDto,
  PropertySearchResultsDto,
  ReadinessDto,
  RefreshSessionDto,
  ReviewDto,
  SearchSuggestionsDto,
  UpdateBrokerDto,
  UpdateContactOutcomeDto,
  UpdatePropertyDto,
  UploadPhotoDto,
])
Serializers serializers = (_$serializers.toBuilder()
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(BrokerListingDto)]),
        () => ListBuilder<BrokerListingDto>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(ReviewDto)]),
        () => ListBuilder<ReviewDto>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(PropertyDto)]),
        () => ListBuilder<PropertyDto>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(UploadPhotoDto)]),
        () => ListBuilder<UploadPhotoDto>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(ContactLogDto)]),
        () => ListBuilder<ContactLogDto>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(BrokerDto)]),
        () => ListBuilder<BrokerDto>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(String)]),
        () => ListBuilder<String>(),
      )
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer()))
    .build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
