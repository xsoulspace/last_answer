// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collections.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetProjectIsarCollectionCollection on Isar {
  IsarCollection<ProjectIsarCollection> get projectIsarCollections =>
      this.collection();
}

const ProjectIsarCollectionSchema = CollectionSchema(
  name: r'ProjectIsarCollection',
  id: 5417514155736590420,
  properties: {
    r'jsonContent': PropertySchema(
      id: 0,
      name: r'jsonContent',
      type: IsarType.string,
    ),
    r'modelIdHashcode': PropertySchema(
      id: 1,
      name: r'modelIdHashcode',
      type: IsarType.long,
    ),
    r'modelIdStr': PropertySchema(
      id: 2,
      name: r'modelIdStr',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 3,
      name: r'type',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 4,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _projectIsarCollectionEstimateSize,
  serialize: _projectIsarCollectionSerialize,
  deserialize: _projectIsarCollectionDeserialize,
  deserializeProp: _projectIsarCollectionDeserializeProp,
  idName: r'isarId',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _projectIsarCollectionGetId,
  getLinks: _projectIsarCollectionGetLinks,
  attach: _projectIsarCollectionAttach,
  version: '3.1.0+1',
);

int _projectIsarCollectionEstimateSize(
  ProjectIsarCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.jsonContent.length * 3;
  bytesCount += 3 + object.modelIdStr.length * 3;
  bytesCount += 3 + object.type.length * 3;
  return bytesCount;
}

void _projectIsarCollectionSerialize(
  ProjectIsarCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.jsonContent);
  writer.writeLong(offsets[1], object.modelIdHashcode);
  writer.writeString(offsets[2], object.modelIdStr);
  writer.writeString(offsets[3], object.type);
  writer.writeDateTime(offsets[4], object.updatedAt);
}

ProjectIsarCollection _projectIsarCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ProjectIsarCollection();
  object.jsonContent = reader.readString(offsets[0]);
  object.modelIdHashcode = reader.readLong(offsets[1]);
  object.modelIdStr = reader.readString(offsets[2]);
  object.type = reader.readString(offsets[3]);
  object.updatedAt = reader.readDateTimeOrNull(offsets[4]);
  return object;
}

P _projectIsarCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _projectIsarCollectionGetId(ProjectIsarCollection object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _projectIsarCollectionGetLinks(
    ProjectIsarCollection object) {
  return [];
}

void _projectIsarCollectionAttach(
    IsarCollection<dynamic> col, Id id, ProjectIsarCollection object) {}

extension ProjectIsarCollectionQueryWhereSort
    on QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QWhere> {
  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ProjectIsarCollectionQueryWhere on QueryBuilder<ProjectIsarCollection,
    ProjectIsarCollection, QWhereClause> {
  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterWhereClause>
      isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ProjectIsarCollectionQueryFilter on QueryBuilder<
    ProjectIsarCollection, ProjectIsarCollection, QFilterCondition> {
  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> jsonContentEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'jsonContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> jsonContentGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'jsonContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> jsonContentLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'jsonContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> jsonContentBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'jsonContent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> jsonContentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'jsonContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> jsonContentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'jsonContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
          QAfterFilterCondition>
      jsonContentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'jsonContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
          QAfterFilterCondition>
      jsonContentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'jsonContent',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> jsonContentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'jsonContent',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> jsonContentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'jsonContent',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> modelIdHashcodeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'modelIdHashcode',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> modelIdHashcodeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'modelIdHashcode',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> modelIdHashcodeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'modelIdHashcode',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> modelIdHashcodeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'modelIdHashcode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> modelIdStrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'modelIdStr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> modelIdStrGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'modelIdStr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> modelIdStrLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'modelIdStr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> modelIdStrBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'modelIdStr',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> modelIdStrStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'modelIdStr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> modelIdStrEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'modelIdStr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
          QAfterFilterCondition>
      modelIdStrContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'modelIdStr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
          QAfterFilterCondition>
      modelIdStrMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'modelIdStr',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> modelIdStrIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'modelIdStr',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> modelIdStrIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'modelIdStr',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> typeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> typeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> typeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> typeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> typeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> typeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
          QAfterFilterCondition>
      typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
          QAfterFilterCondition>
      typeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> updatedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> updatedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> updatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ProjectIsarCollectionQueryObject on QueryBuilder<
    ProjectIsarCollection, ProjectIsarCollection, QFilterCondition> {}

extension ProjectIsarCollectionQueryLinks on QueryBuilder<ProjectIsarCollection,
    ProjectIsarCollection, QFilterCondition> {}

extension ProjectIsarCollectionQuerySortBy
    on QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QSortBy> {
  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterSortBy>
      sortByJsonContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jsonContent', Sort.asc);
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterSortBy>
      sortByJsonContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jsonContent', Sort.desc);
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterSortBy>
      sortByModelIdHashcode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modelIdHashcode', Sort.asc);
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterSortBy>
      sortByModelIdHashcodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modelIdHashcode', Sort.desc);
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterSortBy>
      sortByModelIdStr() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modelIdStr', Sort.asc);
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterSortBy>
      sortByModelIdStrDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modelIdStr', Sort.desc);
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterSortBy>
      sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterSortBy>
      sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ProjectIsarCollectionQuerySortThenBy
    on QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QSortThenBy> {
  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterSortBy>
      thenByJsonContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jsonContent', Sort.asc);
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterSortBy>
      thenByJsonContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jsonContent', Sort.desc);
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterSortBy>
      thenByModelIdHashcode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modelIdHashcode', Sort.asc);
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterSortBy>
      thenByModelIdHashcodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modelIdHashcode', Sort.desc);
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterSortBy>
      thenByModelIdStr() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modelIdStr', Sort.asc);
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterSortBy>
      thenByModelIdStrDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modelIdStr', Sort.desc);
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterSortBy>
      thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterSortBy>
      thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ProjectIsarCollectionQueryWhereDistinct
    on QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QDistinct> {
  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QDistinct>
      distinctByJsonContent({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'jsonContent', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QDistinct>
      distinctByModelIdHashcode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'modelIdHashcode');
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QDistinct>
      distinctByModelIdStr({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'modelIdStr', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QDistinct>
      distinctByType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension ProjectIsarCollectionQueryProperty on QueryBuilder<
    ProjectIsarCollection, ProjectIsarCollection, QQueryProperty> {
  QueryBuilder<ProjectIsarCollection, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<ProjectIsarCollection, String, QQueryOperations>
      jsonContentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'jsonContent');
    });
  }

  QueryBuilder<ProjectIsarCollection, int, QQueryOperations>
      modelIdHashcodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'modelIdHashcode');
    });
  }

  QueryBuilder<ProjectIsarCollection, String, QQueryOperations>
      modelIdStrProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'modelIdStr');
    });
  }

  QueryBuilder<ProjectIsarCollection, String, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<ProjectIsarCollection, DateTime?, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
