// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_rows.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBrokerRowCollection on Isar {
  IsarCollection<BrokerRow> get brokerRows => this.collection();
}

const BrokerRowSchema = CollectionSchema(
  name: r'BrokerRow',
  id: -831637455665728941,
  properties: {
    r'coverage': PropertySchema(
      id: 0,
      name: r'coverage',
      type: IsarType.stringList,
    ),
    r'kind': PropertySchema(
      id: 1,
      name: r'kind',
      type: IsarType.byte,
      enumMap: _BrokerRowkindEnumValueMap,
    ),
    r'latitude': PropertySchema(
      id: 2,
      name: r'latitude',
      type: IsarType.double,
    ),
    r'logoAsset': PropertySchema(
      id: 3,
      name: r'logoAsset',
      type: IsarType.string,
    ),
    r'longitude': PropertySchema(
      id: 4,
      name: r'longitude',
      type: IsarType.double,
    ),
    r'name': PropertySchema(id: 5, name: r'name', type: IsarType.string),
    r'phone': PropertySchema(id: 6, name: r'phone', type: IsarType.string),
    r'pinned': PropertySchema(id: 7, name: r'pinned', type: IsarType.bool),
    r'responseRate': PropertySchema(
      id: 8,
      name: r'responseRate',
      type: IsarType.double,
    ),
    r'uid': PropertySchema(id: 9, name: r'uid', type: IsarType.string),
    r'verification': PropertySchema(
      id: 10,
      name: r'verification',
      type: IsarType.byte,
      enumMap: _BrokerRowverificationEnumValueMap,
    ),
    r'whatsapp': PropertySchema(
      id: 11,
      name: r'whatsapp',
      type: IsarType.string,
    ),
  },

  estimateSize: _brokerRowEstimateSize,
  serialize: _brokerRowSerialize,
  deserialize: _brokerRowDeserialize,
  deserializeProp: _brokerRowDeserializeProp,
  idName: r'id',
  indexes: {
    r'uid': IndexSchema(
      id: 8193695471701937315,
      name: r'uid',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'uid',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _brokerRowGetId,
  getLinks: _brokerRowGetLinks,
  attach: _brokerRowAttach,
  version: '3.3.2',
);

int _brokerRowEstimateSize(
  BrokerRow object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.coverage.length * 3;
  {
    for (var i = 0; i < object.coverage.length; i++) {
      final value = object.coverage[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.logoAsset;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.phone.length * 3;
  bytesCount += 3 + object.uid.length * 3;
  {
    final value = object.whatsapp;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _brokerRowSerialize(
  BrokerRow object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.coverage);
  writer.writeByte(offsets[1], object.kind.index);
  writer.writeDouble(offsets[2], object.latitude);
  writer.writeString(offsets[3], object.logoAsset);
  writer.writeDouble(offsets[4], object.longitude);
  writer.writeString(offsets[5], object.name);
  writer.writeString(offsets[6], object.phone);
  writer.writeBool(offsets[7], object.pinned);
  writer.writeDouble(offsets[8], object.responseRate);
  writer.writeString(offsets[9], object.uid);
  writer.writeByte(offsets[10], object.verification.index);
  writer.writeString(offsets[11], object.whatsapp);
}

BrokerRow _brokerRowDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BrokerRow();
  object.coverage = reader.readStringList(offsets[0]) ?? [];
  object.id = id;
  object.kind =
      _BrokerRowkindValueEnumMap[reader.readByteOrNull(offsets[1])] ??
      BrokerKind.individual;
  object.latitude = reader.readDouble(offsets[2]);
  object.logoAsset = reader.readStringOrNull(offsets[3]);
  object.longitude = reader.readDouble(offsets[4]);
  object.name = reader.readString(offsets[5]);
  object.phone = reader.readString(offsets[6]);
  object.pinned = reader.readBool(offsets[7]);
  object.responseRate = reader.readDouble(offsets[8]);
  object.uid = reader.readString(offsets[9]);
  object.verification =
      _BrokerRowverificationValueEnumMap[reader.readByteOrNull(offsets[10])] ??
      VerificationStatus.none;
  object.whatsapp = reader.readStringOrNull(offsets[11]);
  return object;
}

P _brokerRowDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset) ?? []) as P;
    case 1:
      return (_BrokerRowkindValueEnumMap[reader.readByteOrNull(offset)] ??
              BrokerKind.individual)
          as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readDouble(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (_BrokerRowverificationValueEnumMap[reader.readByteOrNull(
                offset,
              )] ??
              VerificationStatus.none)
          as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _BrokerRowkindEnumValueMap = {'individual': 0, 'agency': 1};
const _BrokerRowkindValueEnumMap = {
  0: BrokerKind.individual,
  1: BrokerKind.agency,
};
const _BrokerRowverificationEnumValueMap = {
  'none': 0,
  'pending': 1,
  'verified': 2,
  'rejected': 3,
};
const _BrokerRowverificationValueEnumMap = {
  0: VerificationStatus.none,
  1: VerificationStatus.pending,
  2: VerificationStatus.verified,
  3: VerificationStatus.rejected,
};

Id _brokerRowGetId(BrokerRow object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _brokerRowGetLinks(BrokerRow object) {
  return [];
}

void _brokerRowAttach(IsarCollection<dynamic> col, Id id, BrokerRow object) {
  object.id = id;
}

extension BrokerRowByIndex on IsarCollection<BrokerRow> {
  Future<BrokerRow?> getByUid(String uid) {
    return getByIndex(r'uid', [uid]);
  }

  BrokerRow? getByUidSync(String uid) {
    return getByIndexSync(r'uid', [uid]);
  }

  Future<bool> deleteByUid(String uid) {
    return deleteByIndex(r'uid', [uid]);
  }

  bool deleteByUidSync(String uid) {
    return deleteByIndexSync(r'uid', [uid]);
  }

  Future<List<BrokerRow?>> getAllByUid(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uid', values);
  }

  List<BrokerRow?> getAllByUidSync(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'uid', values);
  }

  Future<int> deleteAllByUid(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'uid', values);
  }

  int deleteAllByUidSync(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'uid', values);
  }

  Future<Id> putByUid(BrokerRow object) {
    return putByIndex(r'uid', object);
  }

  Id putByUidSync(BrokerRow object, {bool saveLinks = true}) {
    return putByIndexSync(r'uid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUid(List<BrokerRow> objects) {
    return putAllByIndex(r'uid', objects);
  }

  List<Id> putAllByUidSync(List<BrokerRow> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'uid', objects, saveLinks: saveLinks);
  }
}

extension BrokerRowQueryWhereSort
    on QueryBuilder<BrokerRow, BrokerRow, QWhere> {
  QueryBuilder<BrokerRow, BrokerRow, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BrokerRowQueryWhere
    on QueryBuilder<BrokerRow, BrokerRow, QWhereClause> {
  QueryBuilder<BrokerRow, BrokerRow, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterWhereClause> uidEqualTo(String uid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'uid', value: [uid]),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterWhereClause> uidNotEqualTo(
    String uid,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uid',
                lower: [],
                upper: [uid],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uid',
                lower: [uid],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uid',
                lower: [uid],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uid',
                lower: [],
                upper: [uid],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension BrokerRowQueryFilter
    on QueryBuilder<BrokerRow, BrokerRow, QFilterCondition> {
  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition>
  coverageElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'coverage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition>
  coverageElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'coverage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition>
  coverageElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'coverage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition>
  coverageElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'coverage',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition>
  coverageElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'coverage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition>
  coverageElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'coverage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition>
  coverageElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'coverage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition>
  coverageElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'coverage',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition>
  coverageElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'coverage', value: ''),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition>
  coverageElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'coverage', value: ''),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition>
  coverageLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'coverage', length, true, length, true);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> coverageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'coverage', 0, true, 0, true);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition>
  coverageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'coverage', 0, false, 999999, true);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition>
  coverageLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'coverage', 0, true, length, include);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition>
  coverageLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'coverage', length, include, 999999, true);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition>
  coverageLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'coverage',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> kindEqualTo(
    BrokerKind value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'kind', value: value),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> kindGreaterThan(
    BrokerKind value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'kind',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> kindLessThan(
    BrokerKind value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'kind',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> kindBetween(
    BrokerKind lower,
    BrokerKind upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'kind',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> latitudeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'latitude',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> latitudeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'latitude',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> latitudeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'latitude',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> latitudeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'latitude',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> logoAssetIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'logoAsset'),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition>
  logoAssetIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'logoAsset'),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> logoAssetEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'logoAsset',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition>
  logoAssetGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'logoAsset',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> logoAssetLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'logoAsset',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> logoAssetBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'logoAsset',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> logoAssetStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'logoAsset',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> logoAssetEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'logoAsset',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> logoAssetContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'logoAsset',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> logoAssetMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'logoAsset',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> logoAssetIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'logoAsset', value: ''),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition>
  logoAssetIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'logoAsset', value: ''),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> longitudeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'longitude',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition>
  longitudeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'longitude',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> longitudeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'longitude',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> longitudeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'longitude',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'name',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> nameContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> nameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'name',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> phoneEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'phone',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> phoneGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'phone',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> phoneLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'phone',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> phoneBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'phone',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> phoneStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'phone',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> phoneEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'phone',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> phoneContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'phone',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> phoneMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'phone',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> phoneIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'phone', value: ''),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> phoneIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'phone', value: ''),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> pinnedEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'pinned', value: value),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> responseRateEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'responseRate',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition>
  responseRateGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'responseRate',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition>
  responseRateLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'responseRate',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> responseRateBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'responseRate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> uidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> uidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> uidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> uidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'uid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> uidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> uidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> uidContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> uidMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'uid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> uidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'uid', value: ''),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> uidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'uid', value: ''),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> verificationEqualTo(
    VerificationStatus value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'verification', value: value),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition>
  verificationGreaterThan(VerificationStatus value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'verification',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition>
  verificationLessThan(VerificationStatus value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'verification',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> verificationBetween(
    VerificationStatus lower,
    VerificationStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'verification',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> whatsappIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'whatsapp'),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition>
  whatsappIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'whatsapp'),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> whatsappEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'whatsapp',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> whatsappGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'whatsapp',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> whatsappLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'whatsapp',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> whatsappBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'whatsapp',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> whatsappStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'whatsapp',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> whatsappEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'whatsapp',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> whatsappContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'whatsapp',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> whatsappMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'whatsapp',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition> whatsappIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'whatsapp', value: ''),
      );
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterFilterCondition>
  whatsappIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'whatsapp', value: ''),
      );
    });
  }
}

extension BrokerRowQueryObject
    on QueryBuilder<BrokerRow, BrokerRow, QFilterCondition> {}

extension BrokerRowQueryLinks
    on QueryBuilder<BrokerRow, BrokerRow, QFilterCondition> {}

extension BrokerRowQuerySortBy on QueryBuilder<BrokerRow, BrokerRow, QSortBy> {
  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> sortByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> sortByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> sortByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> sortByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> sortByLogoAsset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logoAsset', Sort.asc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> sortByLogoAssetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logoAsset', Sort.desc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> sortByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> sortByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> sortByPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.asc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> sortByPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.desc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> sortByPinned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinned', Sort.asc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> sortByPinnedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinned', Sort.desc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> sortByResponseRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'responseRate', Sort.asc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> sortByResponseRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'responseRate', Sort.desc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> sortByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> sortByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> sortByVerification() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verification', Sort.asc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> sortByVerificationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verification', Sort.desc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> sortByWhatsapp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'whatsapp', Sort.asc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> sortByWhatsappDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'whatsapp', Sort.desc);
    });
  }
}

extension BrokerRowQuerySortThenBy
    on QueryBuilder<BrokerRow, BrokerRow, QSortThenBy> {
  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> thenByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> thenByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> thenByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> thenByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> thenByLogoAsset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logoAsset', Sort.asc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> thenByLogoAssetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logoAsset', Sort.desc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> thenByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> thenByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> thenByPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.asc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> thenByPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.desc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> thenByPinned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinned', Sort.asc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> thenByPinnedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinned', Sort.desc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> thenByResponseRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'responseRate', Sort.asc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> thenByResponseRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'responseRate', Sort.desc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> thenByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> thenByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> thenByVerification() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verification', Sort.asc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> thenByVerificationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verification', Sort.desc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> thenByWhatsapp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'whatsapp', Sort.asc);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QAfterSortBy> thenByWhatsappDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'whatsapp', Sort.desc);
    });
  }
}

extension BrokerRowQueryWhereDistinct
    on QueryBuilder<BrokerRow, BrokerRow, QDistinct> {
  QueryBuilder<BrokerRow, BrokerRow, QDistinct> distinctByCoverage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'coverage');
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QDistinct> distinctByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kind');
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QDistinct> distinctByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'latitude');
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QDistinct> distinctByLogoAsset({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'logoAsset', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QDistinct> distinctByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longitude');
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QDistinct> distinctByPhone({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'phone', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QDistinct> distinctByPinned() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pinned');
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QDistinct> distinctByResponseRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'responseRate');
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QDistinct> distinctByUid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QDistinct> distinctByVerification() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'verification');
    });
  }

  QueryBuilder<BrokerRow, BrokerRow, QDistinct> distinctByWhatsapp({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'whatsapp', caseSensitive: caseSensitive);
    });
  }
}

extension BrokerRowQueryProperty
    on QueryBuilder<BrokerRow, BrokerRow, QQueryProperty> {
  QueryBuilder<BrokerRow, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BrokerRow, List<String>, QQueryOperations> coverageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'coverage');
    });
  }

  QueryBuilder<BrokerRow, BrokerKind, QQueryOperations> kindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kind');
    });
  }

  QueryBuilder<BrokerRow, double, QQueryOperations> latitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'latitude');
    });
  }

  QueryBuilder<BrokerRow, String?, QQueryOperations> logoAssetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'logoAsset');
    });
  }

  QueryBuilder<BrokerRow, double, QQueryOperations> longitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longitude');
    });
  }

  QueryBuilder<BrokerRow, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<BrokerRow, String, QQueryOperations> phoneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'phone');
    });
  }

  QueryBuilder<BrokerRow, bool, QQueryOperations> pinnedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pinned');
    });
  }

  QueryBuilder<BrokerRow, double, QQueryOperations> responseRateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'responseRate');
    });
  }

  QueryBuilder<BrokerRow, String, QQueryOperations> uidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uid');
    });
  }

  QueryBuilder<BrokerRow, VerificationStatus, QQueryOperations>
  verificationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'verification');
    });
  }

  QueryBuilder<BrokerRow, String?, QQueryOperations> whatsappProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'whatsapp');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPropertyRowCollection on Isar {
  IsarCollection<PropertyRow> get propertyRows => this.collection();
}

const PropertyRowSchema = CollectionSchema(
  name: r'PropertyRow',
  id: 2867694153187043371,
  properties: {
    r'brokerUid': PropertySchema(
      id: 0,
      name: r'brokerUid',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'description': PropertySchema(
      id: 2,
      name: r'description',
      type: IsarType.string,
    ),
    r'kind': PropertySchema(
      id: 3,
      name: r'kind',
      type: IsarType.byte,
      enumMap: _PropertyRowkindEnumValueMap,
    ),
    r'latitude': PropertySchema(
      id: 4,
      name: r'latitude',
      type: IsarType.double,
    ),
    r'longitude': PropertySchema(
      id: 5,
      name: r'longitude',
      type: IsarType.double,
    ),
    r'neighbourhood': PropertySchema(
      id: 6,
      name: r'neighbourhood',
      type: IsarType.string,
    ),
    r'photoAssets': PropertySchema(
      id: 7,
      name: r'photoAssets',
      type: IsarType.stringList,
    ),
    r'price': PropertySchema(id: 8, name: r'price', type: IsarType.long),
    r'rooms': PropertySchema(id: 9, name: r'rooms', type: IsarType.long),
    r'status': PropertySchema(
      id: 10,
      name: r'status',
      type: IsarType.byte,
      enumMap: _PropertyRowstatusEnumValueMap,
    ),
    r'surface': PropertySchema(id: 11, name: r'surface', type: IsarType.long),
    r'title': PropertySchema(id: 12, name: r'title', type: IsarType.string),
    r'transaction': PropertySchema(
      id: 13,
      name: r'transaction',
      type: IsarType.byte,
      enumMap: _PropertyRowtransactionEnumValueMap,
    ),
    r'uid': PropertySchema(id: 14, name: r'uid', type: IsarType.string),
  },

  estimateSize: _propertyRowEstimateSize,
  serialize: _propertyRowSerialize,
  deserialize: _propertyRowDeserialize,
  deserializeProp: _propertyRowDeserializeProp,
  idName: r'id',
  indexes: {
    r'uid': IndexSchema(
      id: 8193695471701937315,
      name: r'uid',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'uid',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'brokerUid': IndexSchema(
      id: -4122443871658440195,
      name: r'brokerUid',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'brokerUid',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _propertyRowGetId,
  getLinks: _propertyRowGetLinks,
  attach: _propertyRowAttach,
  version: '3.3.2',
);

int _propertyRowEstimateSize(
  PropertyRow object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.brokerUid.length * 3;
  bytesCount += 3 + object.description.length * 3;
  bytesCount += 3 + object.neighbourhood.length * 3;
  bytesCount += 3 + object.photoAssets.length * 3;
  {
    for (var i = 0; i < object.photoAssets.length; i++) {
      final value = object.photoAssets[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  bytesCount += 3 + object.uid.length * 3;
  return bytesCount;
}

void _propertyRowSerialize(
  PropertyRow object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.brokerUid);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.description);
  writer.writeByte(offsets[3], object.kind.index);
  writer.writeDouble(offsets[4], object.latitude);
  writer.writeDouble(offsets[5], object.longitude);
  writer.writeString(offsets[6], object.neighbourhood);
  writer.writeStringList(offsets[7], object.photoAssets);
  writer.writeLong(offsets[8], object.price);
  writer.writeLong(offsets[9], object.rooms);
  writer.writeByte(offsets[10], object.status.index);
  writer.writeLong(offsets[11], object.surface);
  writer.writeString(offsets[12], object.title);
  writer.writeByte(offsets[13], object.transaction.index);
  writer.writeString(offsets[14], object.uid);
}

PropertyRow _propertyRowDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PropertyRow();
  object.brokerUid = reader.readString(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.description = reader.readString(offsets[2]);
  object.id = id;
  object.kind =
      _PropertyRowkindValueEnumMap[reader.readByteOrNull(offsets[3])] ??
      PropertyKind.apartment;
  object.latitude = reader.readDouble(offsets[4]);
  object.longitude = reader.readDouble(offsets[5]);
  object.neighbourhood = reader.readString(offsets[6]);
  object.photoAssets = reader.readStringList(offsets[7]) ?? [];
  object.price = reader.readLong(offsets[8]);
  object.rooms = reader.readLongOrNull(offsets[9]);
  object.status =
      _PropertyRowstatusValueEnumMap[reader.readByteOrNull(offsets[10])] ??
      PropertyStatus.available;
  object.surface = reader.readLongOrNull(offsets[11]);
  object.title = reader.readString(offsets[12]);
  object.transaction =
      _PropertyRowtransactionValueEnumMap[reader.readByteOrNull(offsets[13])] ??
      TransactionKind.rent;
  object.uid = reader.readString(offsets[14]);
  return object;
}

P _propertyRowDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (_PropertyRowkindValueEnumMap[reader.readByteOrNull(offset)] ??
              PropertyKind.apartment)
          as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readStringList(offset) ?? []) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readLongOrNull(offset)) as P;
    case 10:
      return (_PropertyRowstatusValueEnumMap[reader.readByteOrNull(offset)] ??
              PropertyStatus.available)
          as P;
    case 11:
      return (reader.readLongOrNull(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (_PropertyRowtransactionValueEnumMap[reader.readByteOrNull(
                offset,
              )] ??
              TransactionKind.rent)
          as P;
    case 14:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _PropertyRowkindEnumValueMap = {
  'apartment': 0,
  'house': 1,
  'land': 2,
  'studio': 3,
  'room': 4,
};
const _PropertyRowkindValueEnumMap = {
  0: PropertyKind.apartment,
  1: PropertyKind.house,
  2: PropertyKind.land,
  3: PropertyKind.studio,
  4: PropertyKind.room,
};
const _PropertyRowstatusEnumValueMap = {
  'available': 0,
  'reserved': 1,
  'closed': 2,
};
const _PropertyRowstatusValueEnumMap = {
  0: PropertyStatus.available,
  1: PropertyStatus.reserved,
  2: PropertyStatus.closed,
};
const _PropertyRowtransactionEnumValueMap = {'rent': 0, 'sale': 1};
const _PropertyRowtransactionValueEnumMap = {
  0: TransactionKind.rent,
  1: TransactionKind.sale,
};

Id _propertyRowGetId(PropertyRow object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _propertyRowGetLinks(PropertyRow object) {
  return [];
}

void _propertyRowAttach(
  IsarCollection<dynamic> col,
  Id id,
  PropertyRow object,
) {
  object.id = id;
}

extension PropertyRowByIndex on IsarCollection<PropertyRow> {
  Future<PropertyRow?> getByUid(String uid) {
    return getByIndex(r'uid', [uid]);
  }

  PropertyRow? getByUidSync(String uid) {
    return getByIndexSync(r'uid', [uid]);
  }

  Future<bool> deleteByUid(String uid) {
    return deleteByIndex(r'uid', [uid]);
  }

  bool deleteByUidSync(String uid) {
    return deleteByIndexSync(r'uid', [uid]);
  }

  Future<List<PropertyRow?>> getAllByUid(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uid', values);
  }

  List<PropertyRow?> getAllByUidSync(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'uid', values);
  }

  Future<int> deleteAllByUid(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'uid', values);
  }

  int deleteAllByUidSync(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'uid', values);
  }

  Future<Id> putByUid(PropertyRow object) {
    return putByIndex(r'uid', object);
  }

  Id putByUidSync(PropertyRow object, {bool saveLinks = true}) {
    return putByIndexSync(r'uid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUid(List<PropertyRow> objects) {
    return putAllByIndex(r'uid', objects);
  }

  List<Id> putAllByUidSync(List<PropertyRow> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'uid', objects, saveLinks: saveLinks);
  }
}

extension PropertyRowQueryWhereSort
    on QueryBuilder<PropertyRow, PropertyRow, QWhere> {
  QueryBuilder<PropertyRow, PropertyRow, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PropertyRowQueryWhere
    on QueryBuilder<PropertyRow, PropertyRow, QWhereClause> {
  QueryBuilder<PropertyRow, PropertyRow, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterWhereClause> uidEqualTo(
    String uid,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'uid', value: [uid]),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterWhereClause> uidNotEqualTo(
    String uid,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uid',
                lower: [],
                upper: [uid],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uid',
                lower: [uid],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uid',
                lower: [uid],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uid',
                lower: [],
                upper: [uid],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterWhereClause> brokerUidEqualTo(
    String brokerUid,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'brokerUid', value: [brokerUid]),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterWhereClause> brokerUidNotEqualTo(
    String brokerUid,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'brokerUid',
                lower: [],
                upper: [brokerUid],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'brokerUid',
                lower: [brokerUid],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'brokerUid',
                lower: [brokerUid],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'brokerUid',
                lower: [],
                upper: [brokerUid],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension PropertyRowQueryFilter
    on QueryBuilder<PropertyRow, PropertyRow, QFilterCondition> {
  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  brokerUidEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'brokerUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  brokerUidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'brokerUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  brokerUidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'brokerUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  brokerUidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'brokerUid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  brokerUidStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'brokerUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  brokerUidEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'brokerUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  brokerUidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'brokerUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  brokerUidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'brokerUid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  brokerUidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'brokerUid', value: ''),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  brokerUidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'brokerUid', value: ''),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  createdAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  descriptionEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  descriptionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  descriptionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  descriptionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'description',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  descriptionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  descriptionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'description',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'description', value: ''),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'description', value: ''),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition> kindEqualTo(
    PropertyKind value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'kind', value: value),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition> kindGreaterThan(
    PropertyKind value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'kind',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition> kindLessThan(
    PropertyKind value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'kind',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition> kindBetween(
    PropertyKind lower,
    PropertyKind upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'kind',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition> latitudeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'latitude',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  latitudeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'latitude',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  latitudeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'latitude',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition> latitudeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'latitude',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  longitudeEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'longitude',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  longitudeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'longitude',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  longitudeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'longitude',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  longitudeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'longitude',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  neighbourhoodEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'neighbourhood',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  neighbourhoodGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'neighbourhood',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  neighbourhoodLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'neighbourhood',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  neighbourhoodBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'neighbourhood',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  neighbourhoodStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'neighbourhood',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  neighbourhoodEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'neighbourhood',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  neighbourhoodContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'neighbourhood',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  neighbourhoodMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'neighbourhood',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  neighbourhoodIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'neighbourhood', value: ''),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  neighbourhoodIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'neighbourhood', value: ''),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  photoAssetsElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'photoAssets',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  photoAssetsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'photoAssets',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  photoAssetsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'photoAssets',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  photoAssetsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'photoAssets',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  photoAssetsElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'photoAssets',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  photoAssetsElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'photoAssets',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  photoAssetsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'photoAssets',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  photoAssetsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'photoAssets',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  photoAssetsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'photoAssets', value: ''),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  photoAssetsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'photoAssets', value: ''),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  photoAssetsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'photoAssets', length, true, length, true);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  photoAssetsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'photoAssets', 0, true, 0, true);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  photoAssetsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'photoAssets', 0, false, 999999, true);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  photoAssetsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'photoAssets', 0, true, length, include);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  photoAssetsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'photoAssets', length, include, 999999, true);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  photoAssetsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'photoAssets',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition> priceEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'price', value: value),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  priceGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'price',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition> priceLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'price',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition> priceBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'price',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition> roomsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'rooms'),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  roomsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'rooms'),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition> roomsEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'rooms', value: value),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  roomsGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'rooms',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition> roomsLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'rooms',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition> roomsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'rooms',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition> statusEqualTo(
    PropertyStatus value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: value),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  statusGreaterThan(PropertyStatus value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'status',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition> statusLessThan(
    PropertyStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'status',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition> statusBetween(
    PropertyStatus lower,
    PropertyStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'status',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  surfaceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'surface'),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  surfaceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'surface'),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition> surfaceEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'surface', value: value),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  surfaceGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'surface',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition> surfaceLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'surface',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition> surfaceBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'surface',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'title',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition> titleContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition> titleMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'title',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  transactionEqualTo(TransactionKind value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'transaction', value: value),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  transactionGreaterThan(TransactionKind value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'transaction',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  transactionLessThan(TransactionKind value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'transaction',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  transactionBetween(
    TransactionKind lower,
    TransactionKind upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'transaction',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition> uidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition> uidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition> uidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition> uidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'uid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition> uidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition> uidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition> uidContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition> uidMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'uid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition> uidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'uid', value: ''),
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterFilterCondition>
  uidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'uid', value: ''),
      );
    });
  }
}

extension PropertyRowQueryObject
    on QueryBuilder<PropertyRow, PropertyRow, QFilterCondition> {}

extension PropertyRowQueryLinks
    on QueryBuilder<PropertyRow, PropertyRow, QFilterCondition> {}

extension PropertyRowQuerySortBy
    on QueryBuilder<PropertyRow, PropertyRow, QSortBy> {
  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> sortByBrokerUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brokerUid', Sort.asc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> sortByBrokerUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brokerUid', Sort.desc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> sortByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> sortByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> sortByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> sortByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> sortByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> sortByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> sortByNeighbourhood() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'neighbourhood', Sort.asc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy>
  sortByNeighbourhoodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'neighbourhood', Sort.desc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> sortByPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'price', Sort.asc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> sortByPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'price', Sort.desc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> sortByRooms() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rooms', Sort.asc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> sortByRoomsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rooms', Sort.desc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> sortBySurface() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'surface', Sort.asc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> sortBySurfaceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'surface', Sort.desc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> sortByTransaction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transaction', Sort.asc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> sortByTransactionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transaction', Sort.desc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> sortByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> sortByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }
}

extension PropertyRowQuerySortThenBy
    on QueryBuilder<PropertyRow, PropertyRow, QSortThenBy> {
  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> thenByBrokerUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brokerUid', Sort.asc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> thenByBrokerUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brokerUid', Sort.desc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> thenByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> thenByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> thenByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> thenByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> thenByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> thenByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> thenByNeighbourhood() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'neighbourhood', Sort.asc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy>
  thenByNeighbourhoodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'neighbourhood', Sort.desc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> thenByPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'price', Sort.asc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> thenByPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'price', Sort.desc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> thenByRooms() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rooms', Sort.asc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> thenByRoomsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rooms', Sort.desc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> thenBySurface() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'surface', Sort.asc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> thenBySurfaceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'surface', Sort.desc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> thenByTransaction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transaction', Sort.asc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> thenByTransactionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transaction', Sort.desc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> thenByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QAfterSortBy> thenByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }
}

extension PropertyRowQueryWhereDistinct
    on QueryBuilder<PropertyRow, PropertyRow, QDistinct> {
  QueryBuilder<PropertyRow, PropertyRow, QDistinct> distinctByBrokerUid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'brokerUid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QDistinct> distinctByDescription({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QDistinct> distinctByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kind');
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QDistinct> distinctByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'latitude');
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QDistinct> distinctByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longitude');
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QDistinct> distinctByNeighbourhood({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'neighbourhood',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QDistinct> distinctByPhotoAssets() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'photoAssets');
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QDistinct> distinctByPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'price');
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QDistinct> distinctByRooms() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rooms');
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QDistinct> distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QDistinct> distinctBySurface() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'surface');
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QDistinct> distinctByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QDistinct> distinctByTransaction() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'transaction');
    });
  }

  QueryBuilder<PropertyRow, PropertyRow, QDistinct> distinctByUid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uid', caseSensitive: caseSensitive);
    });
  }
}

extension PropertyRowQueryProperty
    on QueryBuilder<PropertyRow, PropertyRow, QQueryProperty> {
  QueryBuilder<PropertyRow, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PropertyRow, String, QQueryOperations> brokerUidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'brokerUid');
    });
  }

  QueryBuilder<PropertyRow, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<PropertyRow, String, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<PropertyRow, PropertyKind, QQueryOperations> kindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kind');
    });
  }

  QueryBuilder<PropertyRow, double, QQueryOperations> latitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'latitude');
    });
  }

  QueryBuilder<PropertyRow, double, QQueryOperations> longitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longitude');
    });
  }

  QueryBuilder<PropertyRow, String, QQueryOperations> neighbourhoodProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'neighbourhood');
    });
  }

  QueryBuilder<PropertyRow, List<String>, QQueryOperations>
  photoAssetsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'photoAssets');
    });
  }

  QueryBuilder<PropertyRow, int, QQueryOperations> priceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'price');
    });
  }

  QueryBuilder<PropertyRow, int?, QQueryOperations> roomsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rooms');
    });
  }

  QueryBuilder<PropertyRow, PropertyStatus, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<PropertyRow, int?, QQueryOperations> surfaceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'surface');
    });
  }

  QueryBuilder<PropertyRow, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<PropertyRow, TransactionKind, QQueryOperations>
  transactionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'transaction');
    });
  }

  QueryBuilder<PropertyRow, String, QQueryOperations> uidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uid');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetReviewRowCollection on Isar {
  IsarCollection<ReviewRow> get reviewRows => this.collection();
}

const ReviewRowSchema = CollectionSchema(
  name: r'ReviewRow',
  id: 2112931455239043598,
  properties: {
    r'accuracy': PropertySchema(id: 0, name: r'accuracy', type: IsarType.long),
    r'brokerReply': PropertySchema(
      id: 1,
      name: r'brokerReply',
      type: IsarType.string,
    ),
    r'brokerUid': PropertySchema(
      id: 2,
      name: r'brokerUid',
      type: IsarType.string,
    ),
    r'comment': PropertySchema(id: 3, name: r'comment', type: IsarType.string),
    r'contactUid': PropertySchema(
      id: 4,
      name: r'contactUid',
      type: IsarType.string,
    ),
    r'courtesy': PropertySchema(id: 5, name: r'courtesy', type: IsarType.long),
    r'createdAt': PropertySchema(
      id: 6,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'moderation': PropertySchema(
      id: 7,
      name: r'moderation',
      type: IsarType.byte,
      enumMap: _ReviewRowmoderationEnumValueMap,
    ),
    r'rating': PropertySchema(id: 8, name: r'rating', type: IsarType.long),
    r'responsiveness': PropertySchema(
      id: 9,
      name: r'responsiveness',
      type: IsarType.long,
    ),
    r'uid': PropertySchema(id: 10, name: r'uid', type: IsarType.string),
  },

  estimateSize: _reviewRowEstimateSize,
  serialize: _reviewRowSerialize,
  deserialize: _reviewRowDeserialize,
  deserializeProp: _reviewRowDeserializeProp,
  idName: r'id',
  indexes: {
    r'uid': IndexSchema(
      id: 8193695471701937315,
      name: r'uid',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'uid',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'brokerUid': IndexSchema(
      id: -4122443871658440195,
      name: r'brokerUid',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'brokerUid',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _reviewRowGetId,
  getLinks: _reviewRowGetLinks,
  attach: _reviewRowAttach,
  version: '3.3.2',
);

int _reviewRowEstimateSize(
  ReviewRow object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.brokerReply;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.brokerUid.length * 3;
  {
    final value = object.comment;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.contactUid.length * 3;
  bytesCount += 3 + object.uid.length * 3;
  return bytesCount;
}

void _reviewRowSerialize(
  ReviewRow object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.accuracy);
  writer.writeString(offsets[1], object.brokerReply);
  writer.writeString(offsets[2], object.brokerUid);
  writer.writeString(offsets[3], object.comment);
  writer.writeString(offsets[4], object.contactUid);
  writer.writeLong(offsets[5], object.courtesy);
  writer.writeDateTime(offsets[6], object.createdAt);
  writer.writeByte(offsets[7], object.moderation.index);
  writer.writeLong(offsets[8], object.rating);
  writer.writeLong(offsets[9], object.responsiveness);
  writer.writeString(offsets[10], object.uid);
}

ReviewRow _reviewRowDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ReviewRow();
  object.accuracy = reader.readLongOrNull(offsets[0]);
  object.brokerReply = reader.readStringOrNull(offsets[1]);
  object.brokerUid = reader.readString(offsets[2]);
  object.comment = reader.readStringOrNull(offsets[3]);
  object.contactUid = reader.readString(offsets[4]);
  object.courtesy = reader.readLongOrNull(offsets[5]);
  object.createdAt = reader.readDateTime(offsets[6]);
  object.id = id;
  object.moderation =
      _ReviewRowmoderationValueEnumMap[reader.readByteOrNull(offsets[7])] ??
      ModerationStatus.pending;
  object.rating = reader.readLong(offsets[8]);
  object.responsiveness = reader.readLongOrNull(offsets[9]);
  object.uid = reader.readString(offsets[10]);
  return object;
}

P _reviewRowDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    case 7:
      return (_ReviewRowmoderationValueEnumMap[reader.readByteOrNull(offset)] ??
              ModerationStatus.pending)
          as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readLongOrNull(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _ReviewRowmoderationEnumValueMap = {
  'pending': 0,
  'published': 1,
  'rejected': 2,
};
const _ReviewRowmoderationValueEnumMap = {
  0: ModerationStatus.pending,
  1: ModerationStatus.published,
  2: ModerationStatus.rejected,
};

Id _reviewRowGetId(ReviewRow object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _reviewRowGetLinks(ReviewRow object) {
  return [];
}

void _reviewRowAttach(IsarCollection<dynamic> col, Id id, ReviewRow object) {
  object.id = id;
}

extension ReviewRowByIndex on IsarCollection<ReviewRow> {
  Future<ReviewRow?> getByUid(String uid) {
    return getByIndex(r'uid', [uid]);
  }

  ReviewRow? getByUidSync(String uid) {
    return getByIndexSync(r'uid', [uid]);
  }

  Future<bool> deleteByUid(String uid) {
    return deleteByIndex(r'uid', [uid]);
  }

  bool deleteByUidSync(String uid) {
    return deleteByIndexSync(r'uid', [uid]);
  }

  Future<List<ReviewRow?>> getAllByUid(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uid', values);
  }

  List<ReviewRow?> getAllByUidSync(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'uid', values);
  }

  Future<int> deleteAllByUid(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'uid', values);
  }

  int deleteAllByUidSync(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'uid', values);
  }

  Future<Id> putByUid(ReviewRow object) {
    return putByIndex(r'uid', object);
  }

  Id putByUidSync(ReviewRow object, {bool saveLinks = true}) {
    return putByIndexSync(r'uid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUid(List<ReviewRow> objects) {
    return putAllByIndex(r'uid', objects);
  }

  List<Id> putAllByUidSync(List<ReviewRow> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'uid', objects, saveLinks: saveLinks);
  }
}

extension ReviewRowQueryWhereSort
    on QueryBuilder<ReviewRow, ReviewRow, QWhere> {
  QueryBuilder<ReviewRow, ReviewRow, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ReviewRowQueryWhere
    on QueryBuilder<ReviewRow, ReviewRow, QWhereClause> {
  QueryBuilder<ReviewRow, ReviewRow, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterWhereClause> uidEqualTo(String uid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'uid', value: [uid]),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterWhereClause> uidNotEqualTo(
    String uid,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uid',
                lower: [],
                upper: [uid],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uid',
                lower: [uid],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uid',
                lower: [uid],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uid',
                lower: [],
                upper: [uid],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterWhereClause> brokerUidEqualTo(
    String brokerUid,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'brokerUid', value: [brokerUid]),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterWhereClause> brokerUidNotEqualTo(
    String brokerUid,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'brokerUid',
                lower: [],
                upper: [brokerUid],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'brokerUid',
                lower: [brokerUid],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'brokerUid',
                lower: [brokerUid],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'brokerUid',
                lower: [],
                upper: [brokerUid],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension ReviewRowQueryFilter
    on QueryBuilder<ReviewRow, ReviewRow, QFilterCondition> {
  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> accuracyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'accuracy'),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition>
  accuracyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'accuracy'),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> accuracyEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'accuracy', value: value),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> accuracyGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'accuracy',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> accuracyLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'accuracy',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> accuracyBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'accuracy',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition>
  brokerReplyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'brokerReply'),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition>
  brokerReplyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'brokerReply'),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> brokerReplyEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'brokerReply',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition>
  brokerReplyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'brokerReply',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> brokerReplyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'brokerReply',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> brokerReplyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'brokerReply',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition>
  brokerReplyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'brokerReply',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> brokerReplyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'brokerReply',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> brokerReplyContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'brokerReply',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> brokerReplyMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'brokerReply',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition>
  brokerReplyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'brokerReply', value: ''),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition>
  brokerReplyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'brokerReply', value: ''),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> brokerUidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'brokerUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition>
  brokerUidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'brokerUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> brokerUidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'brokerUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> brokerUidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'brokerUid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> brokerUidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'brokerUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> brokerUidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'brokerUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> brokerUidContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'brokerUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> brokerUidMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'brokerUid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> brokerUidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'brokerUid', value: ''),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition>
  brokerUidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'brokerUid', value: ''),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> commentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'comment'),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> commentIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'comment'),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> commentEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'comment',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> commentGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'comment',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> commentLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'comment',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> commentBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'comment',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> commentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'comment',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> commentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'comment',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> commentContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'comment',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> commentMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'comment',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> commentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'comment', value: ''),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition>
  commentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'comment', value: ''),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> contactUidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'contactUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition>
  contactUidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'contactUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> contactUidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'contactUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> contactUidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'contactUid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition>
  contactUidStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'contactUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> contactUidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'contactUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> contactUidContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'contactUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> contactUidMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'contactUid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition>
  contactUidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'contactUid', value: ''),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition>
  contactUidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'contactUid', value: ''),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> courtesyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'courtesy'),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition>
  courtesyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'courtesy'),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> courtesyEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'courtesy', value: value),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> courtesyGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'courtesy',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> courtesyLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'courtesy',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> courtesyBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'courtesy',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> createdAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> moderationEqualTo(
    ModerationStatus value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'moderation', value: value),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition>
  moderationGreaterThan(ModerationStatus value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'moderation',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> moderationLessThan(
    ModerationStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'moderation',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> moderationBetween(
    ModerationStatus lower,
    ModerationStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'moderation',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> ratingEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'rating', value: value),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> ratingGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'rating',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> ratingLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'rating',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> ratingBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'rating',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition>
  responsivenessIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'responsiveness'),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition>
  responsivenessIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'responsiveness'),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition>
  responsivenessEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'responsiveness', value: value),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition>
  responsivenessGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'responsiveness',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition>
  responsivenessLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'responsiveness',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition>
  responsivenessBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'responsiveness',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> uidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> uidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> uidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> uidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'uid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> uidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> uidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> uidContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> uidMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'uid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> uidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'uid', value: ''),
      );
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterFilterCondition> uidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'uid', value: ''),
      );
    });
  }
}

extension ReviewRowQueryObject
    on QueryBuilder<ReviewRow, ReviewRow, QFilterCondition> {}

extension ReviewRowQueryLinks
    on QueryBuilder<ReviewRow, ReviewRow, QFilterCondition> {}

extension ReviewRowQuerySortBy on QueryBuilder<ReviewRow, ReviewRow, QSortBy> {
  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> sortByAccuracy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracy', Sort.asc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> sortByAccuracyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracy', Sort.desc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> sortByBrokerReply() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brokerReply', Sort.asc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> sortByBrokerReplyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brokerReply', Sort.desc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> sortByBrokerUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brokerUid', Sort.asc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> sortByBrokerUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brokerUid', Sort.desc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> sortByComment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'comment', Sort.asc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> sortByCommentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'comment', Sort.desc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> sortByContactUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactUid', Sort.asc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> sortByContactUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactUid', Sort.desc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> sortByCourtesy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courtesy', Sort.asc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> sortByCourtesyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courtesy', Sort.desc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> sortByModeration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moderation', Sort.asc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> sortByModerationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moderation', Sort.desc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> sortByRating() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rating', Sort.asc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> sortByRatingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rating', Sort.desc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> sortByResponsiveness() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'responsiveness', Sort.asc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> sortByResponsivenessDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'responsiveness', Sort.desc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> sortByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> sortByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }
}

extension ReviewRowQuerySortThenBy
    on QueryBuilder<ReviewRow, ReviewRow, QSortThenBy> {
  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> thenByAccuracy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracy', Sort.asc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> thenByAccuracyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracy', Sort.desc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> thenByBrokerReply() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brokerReply', Sort.asc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> thenByBrokerReplyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brokerReply', Sort.desc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> thenByBrokerUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brokerUid', Sort.asc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> thenByBrokerUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brokerUid', Sort.desc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> thenByComment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'comment', Sort.asc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> thenByCommentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'comment', Sort.desc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> thenByContactUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactUid', Sort.asc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> thenByContactUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactUid', Sort.desc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> thenByCourtesy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courtesy', Sort.asc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> thenByCourtesyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courtesy', Sort.desc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> thenByModeration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moderation', Sort.asc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> thenByModerationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moderation', Sort.desc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> thenByRating() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rating', Sort.asc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> thenByRatingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rating', Sort.desc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> thenByResponsiveness() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'responsiveness', Sort.asc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> thenByResponsivenessDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'responsiveness', Sort.desc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> thenByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QAfterSortBy> thenByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }
}

extension ReviewRowQueryWhereDistinct
    on QueryBuilder<ReviewRow, ReviewRow, QDistinct> {
  QueryBuilder<ReviewRow, ReviewRow, QDistinct> distinctByAccuracy() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accuracy');
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QDistinct> distinctByBrokerReply({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'brokerReply', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QDistinct> distinctByBrokerUid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'brokerUid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QDistinct> distinctByComment({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'comment', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QDistinct> distinctByContactUid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contactUid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QDistinct> distinctByCourtesy() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'courtesy');
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QDistinct> distinctByModeration() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'moderation');
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QDistinct> distinctByRating() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rating');
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QDistinct> distinctByResponsiveness() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'responsiveness');
    });
  }

  QueryBuilder<ReviewRow, ReviewRow, QDistinct> distinctByUid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uid', caseSensitive: caseSensitive);
    });
  }
}

extension ReviewRowQueryProperty
    on QueryBuilder<ReviewRow, ReviewRow, QQueryProperty> {
  QueryBuilder<ReviewRow, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ReviewRow, int?, QQueryOperations> accuracyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accuracy');
    });
  }

  QueryBuilder<ReviewRow, String?, QQueryOperations> brokerReplyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'brokerReply');
    });
  }

  QueryBuilder<ReviewRow, String, QQueryOperations> brokerUidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'brokerUid');
    });
  }

  QueryBuilder<ReviewRow, String?, QQueryOperations> commentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'comment');
    });
  }

  QueryBuilder<ReviewRow, String, QQueryOperations> contactUidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contactUid');
    });
  }

  QueryBuilder<ReviewRow, int?, QQueryOperations> courtesyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'courtesy');
    });
  }

  QueryBuilder<ReviewRow, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ReviewRow, ModerationStatus, QQueryOperations>
  moderationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'moderation');
    });
  }

  QueryBuilder<ReviewRow, int, QQueryOperations> ratingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rating');
    });
  }

  QueryBuilder<ReviewRow, int?, QQueryOperations> responsivenessProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'responsiveness');
    });
  }

  QueryBuilder<ReviewRow, String, QQueryOperations> uidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uid');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetContactRowCollection on Isar {
  IsarCollection<ContactRow> get contactRows => this.collection();
}

const ContactRowSchema = CollectionSchema(
  name: r'ContactRow',
  id: -5033585501990320848,
  properties: {
    r'brokerUid': PropertySchema(
      id: 0,
      name: r'brokerUid',
      type: IsarType.string,
    ),
    r'channel': PropertySchema(
      id: 1,
      name: r'channel',
      type: IsarType.byte,
      enumMap: _ContactRowchannelEnumValueMap,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'outcome': PropertySchema(
      id: 3,
      name: r'outcome',
      type: IsarType.byte,
      enumMap: _ContactRowoutcomeEnumValueMap,
    ),
    r'propertyUid': PropertySchema(
      id: 4,
      name: r'propertyUid',
      type: IsarType.string,
    ),
    r'reviewUid': PropertySchema(
      id: 5,
      name: r'reviewUid',
      type: IsarType.string,
    ),
    r'uid': PropertySchema(id: 6, name: r'uid', type: IsarType.string),
  },

  estimateSize: _contactRowEstimateSize,
  serialize: _contactRowSerialize,
  deserialize: _contactRowDeserialize,
  deserializeProp: _contactRowDeserializeProp,
  idName: r'id',
  indexes: {
    r'uid': IndexSchema(
      id: 8193695471701937315,
      name: r'uid',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'uid',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'brokerUid': IndexSchema(
      id: -4122443871658440195,
      name: r'brokerUid',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'brokerUid',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _contactRowGetId,
  getLinks: _contactRowGetLinks,
  attach: _contactRowAttach,
  version: '3.3.2',
);

int _contactRowEstimateSize(
  ContactRow object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.brokerUid.length * 3;
  {
    final value = object.propertyUid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.reviewUid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.uid.length * 3;
  return bytesCount;
}

void _contactRowSerialize(
  ContactRow object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.brokerUid);
  writer.writeByte(offsets[1], object.channel.index);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeByte(offsets[3], object.outcome.index);
  writer.writeString(offsets[4], object.propertyUid);
  writer.writeString(offsets[5], object.reviewUid);
  writer.writeString(offsets[6], object.uid);
}

ContactRow _contactRowDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ContactRow();
  object.brokerUid = reader.readString(offsets[0]);
  object.channel =
      _ContactRowchannelValueEnumMap[reader.readByteOrNull(offsets[1])] ??
      ContactChannel.call;
  object.createdAt = reader.readDateTime(offsets[2]);
  object.id = id;
  object.outcome =
      _ContactRowoutcomeValueEnumMap[reader.readByteOrNull(offsets[3])] ??
      ContactOutcome.attempted;
  object.propertyUid = reader.readStringOrNull(offsets[4]);
  object.reviewUid = reader.readStringOrNull(offsets[5]);
  object.uid = reader.readString(offsets[6]);
  return object;
}

P _contactRowDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (_ContactRowchannelValueEnumMap[reader.readByteOrNull(offset)] ??
              ContactChannel.call)
          as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (_ContactRowoutcomeValueEnumMap[reader.readByteOrNull(offset)] ??
              ContactOutcome.attempted)
          as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _ContactRowchannelEnumValueMap = {
  'call': 0,
  'sms': 1,
  'whatsapp': 2,
  'voiceMessage': 3,
};
const _ContactRowchannelValueEnumMap = {
  0: ContactChannel.call,
  1: ContactChannel.sms,
  2: ContactChannel.whatsapp,
  3: ContactChannel.voiceMessage,
};
const _ContactRowoutcomeEnumValueMap = {
  'attempted': 0,
  'reached': 1,
  'noAnswer': 2,
};
const _ContactRowoutcomeValueEnumMap = {
  0: ContactOutcome.attempted,
  1: ContactOutcome.reached,
  2: ContactOutcome.noAnswer,
};

Id _contactRowGetId(ContactRow object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _contactRowGetLinks(ContactRow object) {
  return [];
}

void _contactRowAttach(IsarCollection<dynamic> col, Id id, ContactRow object) {
  object.id = id;
}

extension ContactRowByIndex on IsarCollection<ContactRow> {
  Future<ContactRow?> getByUid(String uid) {
    return getByIndex(r'uid', [uid]);
  }

  ContactRow? getByUidSync(String uid) {
    return getByIndexSync(r'uid', [uid]);
  }

  Future<bool> deleteByUid(String uid) {
    return deleteByIndex(r'uid', [uid]);
  }

  bool deleteByUidSync(String uid) {
    return deleteByIndexSync(r'uid', [uid]);
  }

  Future<List<ContactRow?>> getAllByUid(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uid', values);
  }

  List<ContactRow?> getAllByUidSync(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'uid', values);
  }

  Future<int> deleteAllByUid(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'uid', values);
  }

  int deleteAllByUidSync(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'uid', values);
  }

  Future<Id> putByUid(ContactRow object) {
    return putByIndex(r'uid', object);
  }

  Id putByUidSync(ContactRow object, {bool saveLinks = true}) {
    return putByIndexSync(r'uid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUid(List<ContactRow> objects) {
    return putAllByIndex(r'uid', objects);
  }

  List<Id> putAllByUidSync(List<ContactRow> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'uid', objects, saveLinks: saveLinks);
  }
}

extension ContactRowQueryWhereSort
    on QueryBuilder<ContactRow, ContactRow, QWhere> {
  QueryBuilder<ContactRow, ContactRow, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ContactRowQueryWhere
    on QueryBuilder<ContactRow, ContactRow, QWhereClause> {
  QueryBuilder<ContactRow, ContactRow, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterWhereClause> uidEqualTo(
    String uid,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'uid', value: [uid]),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterWhereClause> uidNotEqualTo(
    String uid,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uid',
                lower: [],
                upper: [uid],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uid',
                lower: [uid],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uid',
                lower: [uid],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uid',
                lower: [],
                upper: [uid],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterWhereClause> brokerUidEqualTo(
    String brokerUid,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'brokerUid', value: [brokerUid]),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterWhereClause> brokerUidNotEqualTo(
    String brokerUid,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'brokerUid',
                lower: [],
                upper: [brokerUid],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'brokerUid',
                lower: [brokerUid],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'brokerUid',
                lower: [brokerUid],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'brokerUid',
                lower: [],
                upper: [brokerUid],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension ContactRowQueryFilter
    on QueryBuilder<ContactRow, ContactRow, QFilterCondition> {
  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition> brokerUidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'brokerUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition>
  brokerUidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'brokerUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition> brokerUidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'brokerUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition> brokerUidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'brokerUid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition>
  brokerUidStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'brokerUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition> brokerUidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'brokerUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition> brokerUidContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'brokerUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition> brokerUidMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'brokerUid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition>
  brokerUidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'brokerUid', value: ''),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition>
  brokerUidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'brokerUid', value: ''),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition> channelEqualTo(
    ContactChannel value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'channel', value: value),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition>
  channelGreaterThan(ContactChannel value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'channel',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition> channelLessThan(
    ContactChannel value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'channel',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition> channelBetween(
    ContactChannel lower,
    ContactChannel upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'channel',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition> createdAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition> outcomeEqualTo(
    ContactOutcome value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'outcome', value: value),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition>
  outcomeGreaterThan(ContactOutcome value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'outcome',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition> outcomeLessThan(
    ContactOutcome value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'outcome',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition> outcomeBetween(
    ContactOutcome lower,
    ContactOutcome upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'outcome',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition>
  propertyUidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'propertyUid'),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition>
  propertyUidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'propertyUid'),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition>
  propertyUidEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'propertyUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition>
  propertyUidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'propertyUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition>
  propertyUidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'propertyUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition>
  propertyUidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'propertyUid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition>
  propertyUidStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'propertyUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition>
  propertyUidEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'propertyUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition>
  propertyUidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'propertyUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition>
  propertyUidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'propertyUid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition>
  propertyUidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'propertyUid', value: ''),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition>
  propertyUidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'propertyUid', value: ''),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition>
  reviewUidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'reviewUid'),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition>
  reviewUidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'reviewUid'),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition> reviewUidEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'reviewUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition>
  reviewUidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'reviewUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition> reviewUidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'reviewUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition> reviewUidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'reviewUid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition>
  reviewUidStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'reviewUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition> reviewUidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'reviewUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition> reviewUidContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'reviewUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition> reviewUidMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'reviewUid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition>
  reviewUidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'reviewUid', value: ''),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition>
  reviewUidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'reviewUid', value: ''),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition> uidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition> uidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition> uidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition> uidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'uid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition> uidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition> uidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition> uidContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition> uidMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'uid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition> uidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'uid', value: ''),
      );
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterFilterCondition> uidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'uid', value: ''),
      );
    });
  }
}

extension ContactRowQueryObject
    on QueryBuilder<ContactRow, ContactRow, QFilterCondition> {}

extension ContactRowQueryLinks
    on QueryBuilder<ContactRow, ContactRow, QFilterCondition> {}

extension ContactRowQuerySortBy
    on QueryBuilder<ContactRow, ContactRow, QSortBy> {
  QueryBuilder<ContactRow, ContactRow, QAfterSortBy> sortByBrokerUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brokerUid', Sort.asc);
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterSortBy> sortByBrokerUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brokerUid', Sort.desc);
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterSortBy> sortByChannel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'channel', Sort.asc);
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterSortBy> sortByChannelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'channel', Sort.desc);
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterSortBy> sortByOutcome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outcome', Sort.asc);
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterSortBy> sortByOutcomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outcome', Sort.desc);
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterSortBy> sortByPropertyUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'propertyUid', Sort.asc);
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterSortBy> sortByPropertyUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'propertyUid', Sort.desc);
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterSortBy> sortByReviewUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewUid', Sort.asc);
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterSortBy> sortByReviewUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewUid', Sort.desc);
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterSortBy> sortByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterSortBy> sortByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }
}

extension ContactRowQuerySortThenBy
    on QueryBuilder<ContactRow, ContactRow, QSortThenBy> {
  QueryBuilder<ContactRow, ContactRow, QAfterSortBy> thenByBrokerUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brokerUid', Sort.asc);
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterSortBy> thenByBrokerUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brokerUid', Sort.desc);
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterSortBy> thenByChannel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'channel', Sort.asc);
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterSortBy> thenByChannelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'channel', Sort.desc);
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterSortBy> thenByOutcome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outcome', Sort.asc);
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterSortBy> thenByOutcomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outcome', Sort.desc);
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterSortBy> thenByPropertyUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'propertyUid', Sort.asc);
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterSortBy> thenByPropertyUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'propertyUid', Sort.desc);
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterSortBy> thenByReviewUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewUid', Sort.asc);
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterSortBy> thenByReviewUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewUid', Sort.desc);
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterSortBy> thenByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<ContactRow, ContactRow, QAfterSortBy> thenByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }
}

extension ContactRowQueryWhereDistinct
    on QueryBuilder<ContactRow, ContactRow, QDistinct> {
  QueryBuilder<ContactRow, ContactRow, QDistinct> distinctByBrokerUid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'brokerUid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ContactRow, ContactRow, QDistinct> distinctByChannel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'channel');
    });
  }

  QueryBuilder<ContactRow, ContactRow, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ContactRow, ContactRow, QDistinct> distinctByOutcome() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'outcome');
    });
  }

  QueryBuilder<ContactRow, ContactRow, QDistinct> distinctByPropertyUid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'propertyUid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ContactRow, ContactRow, QDistinct> distinctByReviewUid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reviewUid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ContactRow, ContactRow, QDistinct> distinctByUid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uid', caseSensitive: caseSensitive);
    });
  }
}

extension ContactRowQueryProperty
    on QueryBuilder<ContactRow, ContactRow, QQueryProperty> {
  QueryBuilder<ContactRow, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ContactRow, String, QQueryOperations> brokerUidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'brokerUid');
    });
  }

  QueryBuilder<ContactRow, ContactChannel, QQueryOperations> channelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'channel');
    });
  }

  QueryBuilder<ContactRow, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ContactRow, ContactOutcome, QQueryOperations> outcomeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'outcome');
    });
  }

  QueryBuilder<ContactRow, String?, QQueryOperations> propertyUidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'propertyUid');
    });
  }

  QueryBuilder<ContactRow, String?, QQueryOperations> reviewUidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reviewUid');
    });
  }

  QueryBuilder<ContactRow, String, QQueryOperations> uidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uid');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCacheMetaRowCollection on Isar {
  IsarCollection<CacheMetaRow> get cacheMetaRows => this.collection();
}

const CacheMetaRowSchema = CollectionSchema(
  name: r'CacheMetaRow',
  id: 4068495754540071474,
  properties: {
    r'key': PropertySchema(id: 0, name: r'key', type: IsarType.string),
    r'updatedAt': PropertySchema(
      id: 1,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'value': PropertySchema(id: 2, name: r'value', type: IsarType.string),
  },

  estimateSize: _cacheMetaRowEstimateSize,
  serialize: _cacheMetaRowSerialize,
  deserialize: _cacheMetaRowDeserialize,
  deserializeProp: _cacheMetaRowDeserializeProp,
  idName: r'id',
  indexes: {
    r'key': IndexSchema(
      id: -4906094122524121629,
      name: r'key',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'key',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _cacheMetaRowGetId,
  getLinks: _cacheMetaRowGetLinks,
  attach: _cacheMetaRowAttach,
  version: '3.3.2',
);

int _cacheMetaRowEstimateSize(
  CacheMetaRow object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.key.length * 3;
  {
    final value = object.value;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _cacheMetaRowSerialize(
  CacheMetaRow object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.key);
  writer.writeDateTime(offsets[1], object.updatedAt);
  writer.writeString(offsets[2], object.value);
}

CacheMetaRow _cacheMetaRowDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CacheMetaRow();
  object.id = id;
  object.key = reader.readString(offsets[0]);
  object.updatedAt = reader.readDateTimeOrNull(offsets[1]);
  object.value = reader.readStringOrNull(offsets[2]);
  return object;
}

P _cacheMetaRowDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _cacheMetaRowGetId(CacheMetaRow object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _cacheMetaRowGetLinks(CacheMetaRow object) {
  return [];
}

void _cacheMetaRowAttach(
  IsarCollection<dynamic> col,
  Id id,
  CacheMetaRow object,
) {
  object.id = id;
}

extension CacheMetaRowByIndex on IsarCollection<CacheMetaRow> {
  Future<CacheMetaRow?> getByKey(String key) {
    return getByIndex(r'key', [key]);
  }

  CacheMetaRow? getByKeySync(String key) {
    return getByIndexSync(r'key', [key]);
  }

  Future<bool> deleteByKey(String key) {
    return deleteByIndex(r'key', [key]);
  }

  bool deleteByKeySync(String key) {
    return deleteByIndexSync(r'key', [key]);
  }

  Future<List<CacheMetaRow?>> getAllByKey(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return getAllByIndex(r'key', values);
  }

  List<CacheMetaRow?> getAllByKeySync(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'key', values);
  }

  Future<int> deleteAllByKey(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'key', values);
  }

  int deleteAllByKeySync(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'key', values);
  }

  Future<Id> putByKey(CacheMetaRow object) {
    return putByIndex(r'key', object);
  }

  Id putByKeySync(CacheMetaRow object, {bool saveLinks = true}) {
    return putByIndexSync(r'key', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByKey(List<CacheMetaRow> objects) {
    return putAllByIndex(r'key', objects);
  }

  List<Id> putAllByKeySync(
    List<CacheMetaRow> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'key', objects, saveLinks: saveLinks);
  }
}

extension CacheMetaRowQueryWhereSort
    on QueryBuilder<CacheMetaRow, CacheMetaRow, QWhere> {
  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CacheMetaRowQueryWhere
    on QueryBuilder<CacheMetaRow, CacheMetaRow, QWhereClause> {
  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterWhereClause> keyEqualTo(
    String key,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'key', value: [key]),
      );
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterWhereClause> keyNotEqualTo(
    String key,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'key',
                lower: [],
                upper: [key],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'key',
                lower: [key],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'key',
                lower: [key],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'key',
                lower: [],
                upper: [key],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension CacheMetaRowQueryFilter
    on QueryBuilder<CacheMetaRow, CacheMetaRow, QFilterCondition> {
  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterFilterCondition> keyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterFilterCondition>
  keyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterFilterCondition> keyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterFilterCondition> keyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'key',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterFilterCondition> keyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterFilterCondition> keyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterFilterCondition> keyContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterFilterCondition> keyMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'key',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterFilterCondition> keyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'key', value: ''),
      );
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterFilterCondition>
  keyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'key', value: ''),
      );
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterFilterCondition>
  updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'updatedAt'),
      );
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterFilterCondition>
  updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'updatedAt'),
      );
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterFilterCondition>
  updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterFilterCondition>
  updatedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterFilterCondition>
  updatedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterFilterCondition>
  updatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'updatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterFilterCondition>
  valueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'value'),
      );
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterFilterCondition>
  valueIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'value'),
      );
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterFilterCondition> valueEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'value',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterFilterCondition>
  valueGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'value',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterFilterCondition> valueLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'value',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterFilterCondition> valueBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'value',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterFilterCondition>
  valueStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'value',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterFilterCondition> valueEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'value',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterFilterCondition> valueContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'value',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterFilterCondition> valueMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'value',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterFilterCondition>
  valueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'value', value: ''),
      );
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterFilterCondition>
  valueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'value', value: ''),
      );
    });
  }
}

extension CacheMetaRowQueryObject
    on QueryBuilder<CacheMetaRow, CacheMetaRow, QFilterCondition> {}

extension CacheMetaRowQueryLinks
    on QueryBuilder<CacheMetaRow, CacheMetaRow, QFilterCondition> {}

extension CacheMetaRowQuerySortBy
    on QueryBuilder<CacheMetaRow, CacheMetaRow, QSortBy> {
  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterSortBy> sortByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterSortBy> sortByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterSortBy> sortByValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.asc);
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterSortBy> sortByValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.desc);
    });
  }
}

extension CacheMetaRowQuerySortThenBy
    on QueryBuilder<CacheMetaRow, CacheMetaRow, QSortThenBy> {
  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterSortBy> thenByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterSortBy> thenByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterSortBy> thenByValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.asc);
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QAfterSortBy> thenByValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.desc);
    });
  }
}

extension CacheMetaRowQueryWhereDistinct
    on QueryBuilder<CacheMetaRow, CacheMetaRow, QDistinct> {
  QueryBuilder<CacheMetaRow, CacheMetaRow, QDistinct> distinctByKey({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'key', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<CacheMetaRow, CacheMetaRow, QDistinct> distinctByValue({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'value', caseSensitive: caseSensitive);
    });
  }
}

extension CacheMetaRowQueryProperty
    on QueryBuilder<CacheMetaRow, CacheMetaRow, QQueryProperty> {
  QueryBuilder<CacheMetaRow, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CacheMetaRow, String, QQueryOperations> keyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'key');
    });
  }

  QueryBuilder<CacheMetaRow, DateTime?, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<CacheMetaRow, String?, QQueryOperations> valueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'value');
    });
  }
}
