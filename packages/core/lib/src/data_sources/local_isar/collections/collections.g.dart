// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collections.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetProjectIsarCollectionCollection on Isar {
  IsarCollection<String, ProjectIsarCollection> get projectIsarCollections =>
      this.collection();
}

const ProjectIsarCollectionSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'ProjectIsarCollection',
    idName: 'modelIdStr',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'updatedAt',
        type: IsarType.dateTime,
      ),
      IsarPropertySchema(
        name: 'tags',
        type: IsarType.stringList,
      ),
      IsarPropertySchema(
        name: 'type',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'jsonContent',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'modelIdStr',
        type: IsarType.string,
      ),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<String, ProjectIsarCollection>(
    serialize: serializeProjectIsarCollection,
    deserialize: deserializeProjectIsarCollection,
    deserializeProperty: deserializeProjectIsarCollectionProp,
  ),
  embeddedSchemas: [],
);

@isarProtected
int serializeProjectIsarCollection(
    IsarWriter writer, ProjectIsarCollection object) {
  IsarCore.writeLong(writer, 1,
      object.updatedAt?.toUtc().microsecondsSinceEpoch ?? -9223372036854775808);
  {
    final list = object.tags;
    final listWriter = IsarCore.beginList(writer, 2, list.length);
    for (var i = 0; i < list.length; i++) {
      IsarCore.writeString(listWriter, i, list[i]);
    }
    IsarCore.endList(writer, listWriter);
  }
  IsarCore.writeString(writer, 3, object.type);
  IsarCore.writeString(writer, 4, object.jsonContent);
  IsarCore.writeString(writer, 5, object.modelIdStr);
  return Isar.fastHash(object.modelIdStr);
}

@isarProtected
ProjectIsarCollection deserializeProjectIsarCollection(IsarReader reader) {
  final object = ProjectIsarCollection();
  {
    final value = IsarCore.readLong(reader, 1);
    if (value == -9223372036854775808) {
      object.updatedAt = null;
    } else {
      object.updatedAt =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  {
    final length = IsarCore.readList(reader, 2, IsarCore.readerPtrPtr);
    {
      final reader = IsarCore.readerPtr;
      if (reader.isNull) {
        object.tags = const <String>[];
      } else {
        final list = List<String>.filled(length, '', growable: true);
        for (var i = 0; i < length; i++) {
          list[i] = IsarCore.readString(reader, i) ?? '';
        }
        IsarCore.freeReader(reader);
        object.tags = list;
      }
    }
  }
  object.type = IsarCore.readString(reader, 3) ?? '';
  object.jsonContent = IsarCore.readString(reader, 4) ?? '';
  object.modelIdStr = IsarCore.readString(reader, 5) ?? '';
  return object;
}

@isarProtected
dynamic deserializeProjectIsarCollectionProp(IsarReader reader, int property) {
  switch (property) {
    case 1:
      {
        final value = IsarCore.readLong(reader, 1);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    case 2:
      {
        final length = IsarCore.readList(reader, 2, IsarCore.readerPtrPtr);
        {
          final reader = IsarCore.readerPtr;
          if (reader.isNull) {
            return const <String>[];
          } else {
            final list = List<String>.filled(length, '', growable: true);
            for (var i = 0; i < length; i++) {
              list[i] = IsarCore.readString(reader, i) ?? '';
            }
            IsarCore.freeReader(reader);
            return list;
          }
        }
      }
    case 3:
      return IsarCore.readString(reader, 3) ?? '';
    case 4:
      return IsarCore.readString(reader, 4) ?? '';
    case 5:
      return IsarCore.readString(reader, 5) ?? '';
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _ProjectIsarCollectionUpdate {
  bool call({
    required String modelIdStr,
    DateTime? updatedAt,
    String? type,
    String? jsonContent,
  });
}

class _ProjectIsarCollectionUpdateImpl implements _ProjectIsarCollectionUpdate {
  const _ProjectIsarCollectionUpdateImpl(this.collection);

  final IsarCollection<String, ProjectIsarCollection> collection;

  @override
  bool call({
    required String modelIdStr,
    Object? updatedAt = ignore,
    Object? type = ignore,
    Object? jsonContent = ignore,
  }) {
    return collection.updateProperties([
          modelIdStr
        ], {
          if (updatedAt != ignore) 1: updatedAt as DateTime?,
          if (type != ignore) 3: type as String?,
          if (jsonContent != ignore) 4: jsonContent as String?,
        }) >
        0;
  }
}

sealed class _ProjectIsarCollectionUpdateAll {
  int call({
    required List<String> modelIdStr,
    DateTime? updatedAt,
    String? type,
    String? jsonContent,
  });
}

class _ProjectIsarCollectionUpdateAllImpl
    implements _ProjectIsarCollectionUpdateAll {
  const _ProjectIsarCollectionUpdateAllImpl(this.collection);

  final IsarCollection<String, ProjectIsarCollection> collection;

  @override
  int call({
    required List<String> modelIdStr,
    Object? updatedAt = ignore,
    Object? type = ignore,
    Object? jsonContent = ignore,
  }) {
    return collection.updateProperties(modelIdStr, {
      if (updatedAt != ignore) 1: updatedAt as DateTime?,
      if (type != ignore) 3: type as String?,
      if (jsonContent != ignore) 4: jsonContent as String?,
    });
  }
}

extension ProjectIsarCollectionUpdate
    on IsarCollection<String, ProjectIsarCollection> {
  _ProjectIsarCollectionUpdate get update =>
      _ProjectIsarCollectionUpdateImpl(this);

  _ProjectIsarCollectionUpdateAll get updateAll =>
      _ProjectIsarCollectionUpdateAllImpl(this);
}

sealed class _ProjectIsarCollectionQueryUpdate {
  int call({
    DateTime? updatedAt,
    String? type,
    String? jsonContent,
  });
}

class _ProjectIsarCollectionQueryUpdateImpl
    implements _ProjectIsarCollectionQueryUpdate {
  const _ProjectIsarCollectionQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<ProjectIsarCollection> query;
  final int? limit;

  @override
  int call({
    Object? updatedAt = ignore,
    Object? type = ignore,
    Object? jsonContent = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (updatedAt != ignore) 1: updatedAt as DateTime?,
      if (type != ignore) 3: type as String?,
      if (jsonContent != ignore) 4: jsonContent as String?,
    });
  }
}

extension ProjectIsarCollectionQueryUpdate on IsarQuery<ProjectIsarCollection> {
  _ProjectIsarCollectionQueryUpdate get updateFirst =>
      _ProjectIsarCollectionQueryUpdateImpl(this, limit: 1);

  _ProjectIsarCollectionQueryUpdate get updateAll =>
      _ProjectIsarCollectionQueryUpdateImpl(this);
}

class _ProjectIsarCollectionQueryBuilderUpdateImpl
    implements _ProjectIsarCollectionQueryUpdate {
  const _ProjectIsarCollectionQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QOperations>
      query;
  final int? limit;

  @override
  int call({
    Object? updatedAt = ignore,
    Object? type = ignore,
    Object? jsonContent = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (updatedAt != ignore) 1: updatedAt as DateTime?,
        if (type != ignore) 3: type as String?,
        if (jsonContent != ignore) 4: jsonContent as String?,
      });
    } finally {
      q.close();
    }
  }
}

extension ProjectIsarCollectionQueryBuilderUpdate
    on QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QOperations> {
  _ProjectIsarCollectionQueryUpdate get updateFirst =>
      _ProjectIsarCollectionQueryBuilderUpdateImpl(this, limit: 1);

  _ProjectIsarCollectionQueryUpdate get updateAll =>
      _ProjectIsarCollectionQueryBuilderUpdateImpl(this);
}

extension ProjectIsarCollectionQueryFilter on QueryBuilder<
    ProjectIsarCollection, ProjectIsarCollection, QFilterCondition> {
  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 1));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> updatedAtIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 1));
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> updatedAtEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 1,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> updatedAtGreaterThan(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 1,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> updatedAtGreaterThanOrEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 1,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> updatedAtLessThan(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 1,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> updatedAtLessThanOrEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 1,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> updatedAtBetween(
    DateTime? lower,
    DateTime? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 1,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> tagsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> tagsElementGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> tagsElementGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> tagsElementLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> tagsElementLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> tagsElementBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 2,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> tagsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> tagsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
          QAfterFilterCondition>
      tagsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
          QAfterFilterCondition>
      tagsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 2,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> tagsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> tagsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> tagsIsEmpty() {
    return not().tagsIsNotEmpty();
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> tagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 2, value: null),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> typeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> typeGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> typeGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> typeLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> typeLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> typeBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 3,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> typeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> typeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
          QAfterFilterCondition>
      typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
          QAfterFilterCondition>
      typeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 3,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> jsonContentEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> jsonContentGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> jsonContentGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> jsonContentLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> jsonContentLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> jsonContentBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 4,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> jsonContentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> jsonContentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
          QAfterFilterCondition>
      jsonContentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
          QAfterFilterCondition>
      jsonContentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 4,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> jsonContentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 4,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> jsonContentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 4,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> modelIdStrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> modelIdStrGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> modelIdStrGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> modelIdStrLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> modelIdStrLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> modelIdStrBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 5,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> modelIdStrStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> modelIdStrEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
          QAfterFilterCondition>
      modelIdStrContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
          QAfterFilterCondition>
      modelIdStrMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 5,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> modelIdStrIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 5,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
      QAfterFilterCondition> modelIdStrIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 5,
          value: '',
        ),
      );
    });
  }
}

extension ProjectIsarCollectionQueryObject on QueryBuilder<
    ProjectIsarCollection, ProjectIsarCollection, QFilterCondition> {}

extension ProjectIsarCollectionQuerySortBy
    on QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QSortBy> {
  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1);
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc);
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterSortBy>
      sortByType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterSortBy>
      sortByTypeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterSortBy>
      sortByJsonContent({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        4,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterSortBy>
      sortByJsonContentDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        4,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterSortBy>
      sortByModelIdStr({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        5,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterSortBy>
      sortByModelIdStrDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        5,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }
}

extension ProjectIsarCollectionQuerySortThenBy
    on QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QSortThenBy> {
  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1);
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc);
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterSortBy>
      thenByType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterSortBy>
      thenByTypeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterSortBy>
      thenByJsonContent({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterSortBy>
      thenByJsonContentDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterSortBy>
      thenByModelIdStr({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterSortBy>
      thenByModelIdStrDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }
}

extension ProjectIsarCollectionQueryWhereDistinct
    on QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QDistinct> {
  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1);
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterDistinct>
      distinctByTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2);
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterDistinct>
      distinctByType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QAfterDistinct>
      distinctByJsonContent({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4, caseSensitive: caseSensitive);
    });
  }
}

extension ProjectIsarCollectionQueryProperty1
    on QueryBuilder<ProjectIsarCollection, ProjectIsarCollection, QProperty> {
  QueryBuilder<ProjectIsarCollection, DateTime?, QAfterProperty>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<ProjectIsarCollection, List<String>, QAfterProperty>
      tagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<ProjectIsarCollection, String, QAfterProperty> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<ProjectIsarCollection, String, QAfterProperty>
      jsonContentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<ProjectIsarCollection, String, QAfterProperty>
      modelIdStrProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }
}

extension ProjectIsarCollectionQueryProperty2<R>
    on QueryBuilder<ProjectIsarCollection, R, QAfterProperty> {
  QueryBuilder<ProjectIsarCollection, (R, DateTime?), QAfterProperty>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<ProjectIsarCollection, (R, List<String>), QAfterProperty>
      tagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<ProjectIsarCollection, (R, String), QAfterProperty>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<ProjectIsarCollection, (R, String), QAfterProperty>
      jsonContentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<ProjectIsarCollection, (R, String), QAfterProperty>
      modelIdStrProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }
}

extension ProjectIsarCollectionQueryProperty3<R1, R2>
    on QueryBuilder<ProjectIsarCollection, (R1, R2), QAfterProperty> {
  QueryBuilder<ProjectIsarCollection, (R1, R2, DateTime?), QOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<ProjectIsarCollection, (R1, R2, List<String>), QOperations>
      tagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<ProjectIsarCollection, (R1, R2, String), QOperations>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<ProjectIsarCollection, (R1, R2, String), QOperations>
      jsonContentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<ProjectIsarCollection, (R1, R2, String), QOperations>
      modelIdStrProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }
}
