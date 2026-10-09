// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TeamsTable extends Teams with TableInfo<$TeamsTable, Team> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TeamsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<String> serverUpdatedAt = GeneratedColumn<String>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clubNameMeta = const VerificationMeta(
    'clubName',
  );
  @override
  late final GeneratedColumn<String> clubName = GeneratedColumn<String>(
    'club_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seasonMeta = const VerificationMeta('season');
  @override
  late final GeneratedColumn<String> season = GeneratedColumn<String>(
    'season',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _logoPathMeta = const VerificationMeta(
    'logoPath',
  );
  @override
  late final GeneratedColumn<String> logoPath = GeneratedColumn<String>(
    'logo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    serverUpdatedAt,
    deleted,
    isDirty,
    name,
    clubName,
    category,
    season,
    logoPath,
    createdBy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'teams';
  @override
  VerificationContext validateIntegrity(
    Insertable<Team> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('club_name')) {
      context.handle(
        _clubNameMeta,
        clubName.isAcceptableOrUnknown(data['club_name']!, _clubNameMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('season')) {
      context.handle(
        _seasonMeta,
        season.isAcceptableOrUnknown(data['season']!, _seasonMeta),
      );
    } else if (isInserting) {
      context.missing(_seasonMeta);
    }
    if (data.containsKey('logo_path')) {
      context.handle(
        _logoPathMeta,
        logoPath.isAcceptableOrUnknown(data['logo_path']!, _logoPathMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Team map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Team(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_updated_at'],
      ),
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      clubName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}club_name'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      season: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}season'],
      )!,
      logoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logo_path'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
    );
  }

  @override
  $TeamsTable createAlias(String alias) {
    return $TeamsTable(attachedDatabase, alias);
  }
}

class Team extends DataClass implements Insertable<Team> {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String? serverUpdatedAt;
  final bool deleted;

  /// Modifiée localement et pas encore envoyée. Jamais synchronisée.
  final bool isDirty;
  final String name;
  final String? clubName;
  final String category;
  final String season;
  final String? logoPath;
  final String createdBy;
  const Team({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.serverUpdatedAt,
    required this.deleted,
    required this.isDirty,
    required this.name,
    this.clubName,
    required this.category,
    required this.season,
    this.logoPath,
    required this.createdBy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<String>(serverUpdatedAt);
    }
    map['deleted'] = Variable<bool>(deleted);
    map['is_dirty'] = Variable<bool>(isDirty);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || clubName != null) {
      map['club_name'] = Variable<String>(clubName);
    }
    map['category'] = Variable<String>(category);
    map['season'] = Variable<String>(season);
    if (!nullToAbsent || logoPath != null) {
      map['logo_path'] = Variable<String>(logoPath);
    }
    map['created_by'] = Variable<String>(createdBy);
    return map;
  }

  TeamsCompanion toCompanion(bool nullToAbsent) {
    return TeamsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      deleted: Value(deleted),
      isDirty: Value(isDirty),
      name: Value(name),
      clubName: clubName == null && nullToAbsent
          ? const Value.absent()
          : Value(clubName),
      category: Value(category),
      season: Value(season),
      logoPath: logoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(logoPath),
      createdBy: Value(createdBy),
    );
  }

  factory Team.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Team(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      serverUpdatedAt: serializer.fromJson<String?>(json['serverUpdatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      name: serializer.fromJson<String>(json['name']),
      clubName: serializer.fromJson<String?>(json['clubName']),
      category: serializer.fromJson<String>(json['category']),
      season: serializer.fromJson<String>(json['season']),
      logoPath: serializer.fromJson<String?>(json['logoPath']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'serverUpdatedAt': serializer.toJson<String?>(serverUpdatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'isDirty': serializer.toJson<bool>(isDirty),
      'name': serializer.toJson<String>(name),
      'clubName': serializer.toJson<String?>(clubName),
      'category': serializer.toJson<String>(category),
      'season': serializer.toJson<String>(season),
      'logoPath': serializer.toJson<String?>(logoPath),
      'createdBy': serializer.toJson<String>(createdBy),
    };
  }

  Team copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    Value<String?> serverUpdatedAt = const Value.absent(),
    bool? deleted,
    bool? isDirty,
    String? name,
    Value<String?> clubName = const Value.absent(),
    String? category,
    String? season,
    Value<String?> logoPath = const Value.absent(),
    String? createdBy,
  }) => Team(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    deleted: deleted ?? this.deleted,
    isDirty: isDirty ?? this.isDirty,
    name: name ?? this.name,
    clubName: clubName.present ? clubName.value : this.clubName,
    category: category ?? this.category,
    season: season ?? this.season,
    logoPath: logoPath.present ? logoPath.value : this.logoPath,
    createdBy: createdBy ?? this.createdBy,
  );
  Team copyWithCompanion(TeamsCompanion data) {
    return Team(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      name: data.name.present ? data.name.value : this.name,
      clubName: data.clubName.present ? data.clubName.value : this.clubName,
      category: data.category.present ? data.category.value : this.category,
      season: data.season.present ? data.season.value : this.season,
      logoPath: data.logoPath.present ? data.logoPath.value : this.logoPath,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Team(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('name: $name, ')
          ..write('clubName: $clubName, ')
          ..write('category: $category, ')
          ..write('season: $season, ')
          ..write('logoPath: $logoPath, ')
          ..write('createdBy: $createdBy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    serverUpdatedAt,
    deleted,
    isDirty,
    name,
    clubName,
    category,
    season,
    logoPath,
    createdBy,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Team &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.deleted == this.deleted &&
          other.isDirty == this.isDirty &&
          other.name == this.name &&
          other.clubName == this.clubName &&
          other.category == this.category &&
          other.season == this.season &&
          other.logoPath == this.logoPath &&
          other.createdBy == this.createdBy);
}

class TeamsCompanion extends UpdateCompanion<Team> {
  final Value<String> id;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> serverUpdatedAt;
  final Value<bool> deleted;
  final Value<bool> isDirty;
  final Value<String> name;
  final Value<String?> clubName;
  final Value<String> category;
  final Value<String> season;
  final Value<String?> logoPath;
  final Value<String> createdBy;
  final Value<int> rowid;
  const TeamsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.name = const Value.absent(),
    this.clubName = const Value.absent(),
    this.category = const Value.absent(),
    this.season = const Value.absent(),
    this.logoPath = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TeamsCompanion.insert({
    required String id,
    required String createdAt,
    required String updatedAt,
    this.serverUpdatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    required String name,
    this.clubName = const Value.absent(),
    required String category,
    required String season,
    this.logoPath = const Value.absent(),
    required String createdBy,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name),
       category = Value(category),
       season = Value(season),
       createdBy = Value(createdBy);
  static Insertable<Team> custom({
    Expression<String>? id,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? serverUpdatedAt,
    Expression<bool>? deleted,
    Expression<bool>? isDirty,
    Expression<String>? name,
    Expression<String>? clubName,
    Expression<String>? category,
    Expression<String>? season,
    Expression<String>? logoPath,
    Expression<String>? createdBy,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (deleted != null) 'deleted': deleted,
      if (isDirty != null) 'is_dirty': isDirty,
      if (name != null) 'name': name,
      if (clubName != null) 'club_name': clubName,
      if (category != null) 'category': category,
      if (season != null) 'season': season,
      if (logoPath != null) 'logo_path': logoPath,
      if (createdBy != null) 'created_by': createdBy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TeamsCompanion copyWith({
    Value<String>? id,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? serverUpdatedAt,
    Value<bool>? deleted,
    Value<bool>? isDirty,
    Value<String>? name,
    Value<String?>? clubName,
    Value<String>? category,
    Value<String>? season,
    Value<String?>? logoPath,
    Value<String>? createdBy,
    Value<int>? rowid,
  }) {
    return TeamsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      deleted: deleted ?? this.deleted,
      isDirty: isDirty ?? this.isDirty,
      name: name ?? this.name,
      clubName: clubName ?? this.clubName,
      category: category ?? this.category,
      season: season ?? this.season,
      logoPath: logoPath ?? this.logoPath,
      createdBy: createdBy ?? this.createdBy,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<String>(serverUpdatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (clubName.present) {
      map['club_name'] = Variable<String>(clubName.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (season.present) {
      map['season'] = Variable<String>(season.value);
    }
    if (logoPath.present) {
      map['logo_path'] = Variable<String>(logoPath.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TeamsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('name: $name, ')
          ..write('clubName: $clubName, ')
          ..write('category: $category, ')
          ..write('season: $season, ')
          ..write('logoPath: $logoPath, ')
          ..write('createdBy: $createdBy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TeamMembersTable extends TeamMembers
    with TableInfo<$TeamMembersTable, TeamMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TeamMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<String> serverUpdatedAt = GeneratedColumn<String>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _teamIdMeta = const VerificationMeta('teamId');
  @override
  late final GeneratedColumn<String> teamId = GeneratedColumn<String>(
    'team_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    serverUpdatedAt,
    deleted,
    isDirty,
    teamId,
    userId,
    role,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'team_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<TeamMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('team_id')) {
      context.handle(
        _teamIdMeta,
        teamId.isAcceptableOrUnknown(data['team_id']!, _teamIdMeta),
      );
    } else if (isInserting) {
      context.missing(_teamIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TeamMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TeamMember(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_updated_at'],
      ),
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
      teamId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}team_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
    );
  }

  @override
  $TeamMembersTable createAlias(String alias) {
    return $TeamMembersTable(attachedDatabase, alias);
  }
}

class TeamMember extends DataClass implements Insertable<TeamMember> {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String? serverUpdatedAt;
  final bool deleted;

  /// Modifiée localement et pas encore envoyée. Jamais synchronisée.
  final bool isDirty;
  final String teamId;
  final String userId;
  final String role;
  const TeamMember({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.serverUpdatedAt,
    required this.deleted,
    required this.isDirty,
    required this.teamId,
    required this.userId,
    required this.role,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<String>(serverUpdatedAt);
    }
    map['deleted'] = Variable<bool>(deleted);
    map['is_dirty'] = Variable<bool>(isDirty);
    map['team_id'] = Variable<String>(teamId);
    map['user_id'] = Variable<String>(userId);
    map['role'] = Variable<String>(role);
    return map;
  }

  TeamMembersCompanion toCompanion(bool nullToAbsent) {
    return TeamMembersCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      deleted: Value(deleted),
      isDirty: Value(isDirty),
      teamId: Value(teamId),
      userId: Value(userId),
      role: Value(role),
    );
  }

  factory TeamMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TeamMember(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      serverUpdatedAt: serializer.fromJson<String?>(json['serverUpdatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      teamId: serializer.fromJson<String>(json['teamId']),
      userId: serializer.fromJson<String>(json['userId']),
      role: serializer.fromJson<String>(json['role']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'serverUpdatedAt': serializer.toJson<String?>(serverUpdatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'isDirty': serializer.toJson<bool>(isDirty),
      'teamId': serializer.toJson<String>(teamId),
      'userId': serializer.toJson<String>(userId),
      'role': serializer.toJson<String>(role),
    };
  }

  TeamMember copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    Value<String?> serverUpdatedAt = const Value.absent(),
    bool? deleted,
    bool? isDirty,
    String? teamId,
    String? userId,
    String? role,
  }) => TeamMember(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    deleted: deleted ?? this.deleted,
    isDirty: isDirty ?? this.isDirty,
    teamId: teamId ?? this.teamId,
    userId: userId ?? this.userId,
    role: role ?? this.role,
  );
  TeamMember copyWithCompanion(TeamMembersCompanion data) {
    return TeamMember(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      userId: data.userId.present ? data.userId.value : this.userId,
      role: data.role.present ? data.role.value : this.role,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TeamMember(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('teamId: $teamId, ')
          ..write('userId: $userId, ')
          ..write('role: $role')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    serverUpdatedAt,
    deleted,
    isDirty,
    teamId,
    userId,
    role,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TeamMember &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.deleted == this.deleted &&
          other.isDirty == this.isDirty &&
          other.teamId == this.teamId &&
          other.userId == this.userId &&
          other.role == this.role);
}

class TeamMembersCompanion extends UpdateCompanion<TeamMember> {
  final Value<String> id;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> serverUpdatedAt;
  final Value<bool> deleted;
  final Value<bool> isDirty;
  final Value<String> teamId;
  final Value<String> userId;
  final Value<String> role;
  final Value<int> rowid;
  const TeamMembersCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.teamId = const Value.absent(),
    this.userId = const Value.absent(),
    this.role = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TeamMembersCompanion.insert({
    required String id,
    required String createdAt,
    required String updatedAt,
    this.serverUpdatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    required String teamId,
    required String userId,
    required String role,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       teamId = Value(teamId),
       userId = Value(userId),
       role = Value(role);
  static Insertable<TeamMember> custom({
    Expression<String>? id,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? serverUpdatedAt,
    Expression<bool>? deleted,
    Expression<bool>? isDirty,
    Expression<String>? teamId,
    Expression<String>? userId,
    Expression<String>? role,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (deleted != null) 'deleted': deleted,
      if (isDirty != null) 'is_dirty': isDirty,
      if (teamId != null) 'team_id': teamId,
      if (userId != null) 'user_id': userId,
      if (role != null) 'role': role,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TeamMembersCompanion copyWith({
    Value<String>? id,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? serverUpdatedAt,
    Value<bool>? deleted,
    Value<bool>? isDirty,
    Value<String>? teamId,
    Value<String>? userId,
    Value<String>? role,
    Value<int>? rowid,
  }) {
    return TeamMembersCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      deleted: deleted ?? this.deleted,
      isDirty: isDirty ?? this.isDirty,
      teamId: teamId ?? this.teamId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<String>(serverUpdatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (teamId.present) {
      map['team_id'] = Variable<String>(teamId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TeamMembersCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('teamId: $teamId, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlayersTable extends Players with TableInfo<$PlayersTable, Player> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<String> serverUpdatedAt = GeneratedColumn<String>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _teamIdMeta = const VerificationMeta('teamId');
  @override
  late final GeneratedColumn<String> teamId = GeneratedColumn<String>(
    'team_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shirtNumberMeta = const VerificationMeta(
    'shirtNumber',
  );
  @override
  late final GeneratedColumn<int> shirtNumber = GeneratedColumn<int>(
    'shirt_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<String> position = GeneratedColumn<String>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _birthDateMeta = const VerificationMeta(
    'birthDate',
  );
  @override
  late final GeneratedColumn<String> birthDate = GeneratedColumn<String>(
    'birth_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dominantFootMeta = const VerificationMeta(
    'dominantFoot',
  );
  @override
  late final GeneratedColumn<String> dominantFoot = GeneratedColumn<String>(
    'dominant_foot',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<int> heightCm = GeneratedColumn<int>(
    'height_cm',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    serverUpdatedAt,
    deleted,
    isDirty,
    teamId,
    firstName,
    lastName,
    shirtNumber,
    position,
    birthDate,
    dominantFoot,
    heightCm,
    photoPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'players';
  @override
  VerificationContext validateIntegrity(
    Insertable<Player> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('team_id')) {
      context.handle(
        _teamIdMeta,
        teamId.isAcceptableOrUnknown(data['team_id']!, _teamIdMeta),
      );
    } else if (isInserting) {
      context.missing(_teamIdMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    } else if (isInserting) {
      context.missing(_lastNameMeta);
    }
    if (data.containsKey('shirt_number')) {
      context.handle(
        _shirtNumberMeta,
        shirtNumber.isAcceptableOrUnknown(
          data['shirt_number']!,
          _shirtNumberMeta,
        ),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('birth_date')) {
      context.handle(
        _birthDateMeta,
        birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta),
      );
    }
    if (data.containsKey('dominant_foot')) {
      context.handle(
        _dominantFootMeta,
        dominantFoot.isAcceptableOrUnknown(
          data['dominant_foot']!,
          _dominantFootMeta,
        ),
      );
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Player map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Player(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_updated_at'],
      ),
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
      teamId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}team_id'],
      )!,
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      )!,
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      )!,
      shirtNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shirt_number'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}position'],
      )!,
      birthDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}birth_date'],
      ),
      dominantFoot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dominant_foot'],
      ),
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height_cm'],
      ),
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
    );
  }

  @override
  $PlayersTable createAlias(String alias) {
    return $PlayersTable(attachedDatabase, alias);
  }
}

class Player extends DataClass implements Insertable<Player> {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String? serverUpdatedAt;
  final bool deleted;

  /// Modifiée localement et pas encore envoyée. Jamais synchronisée.
  final bool isDirty;
  final String teamId;
  final String firstName;
  final String lastName;
  final int? shirtNumber;
  final String position;
  final String? birthDate;
  final String? dominantFoot;
  final int? heightCm;
  final String? photoPath;
  const Player({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.serverUpdatedAt,
    required this.deleted,
    required this.isDirty,
    required this.teamId,
    required this.firstName,
    required this.lastName,
    this.shirtNumber,
    required this.position,
    this.birthDate,
    this.dominantFoot,
    this.heightCm,
    this.photoPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<String>(serverUpdatedAt);
    }
    map['deleted'] = Variable<bool>(deleted);
    map['is_dirty'] = Variable<bool>(isDirty);
    map['team_id'] = Variable<String>(teamId);
    map['first_name'] = Variable<String>(firstName);
    map['last_name'] = Variable<String>(lastName);
    if (!nullToAbsent || shirtNumber != null) {
      map['shirt_number'] = Variable<int>(shirtNumber);
    }
    map['position'] = Variable<String>(position);
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<String>(birthDate);
    }
    if (!nullToAbsent || dominantFoot != null) {
      map['dominant_foot'] = Variable<String>(dominantFoot);
    }
    if (!nullToAbsent || heightCm != null) {
      map['height_cm'] = Variable<int>(heightCm);
    }
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    return map;
  }

  PlayersCompanion toCompanion(bool nullToAbsent) {
    return PlayersCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      deleted: Value(deleted),
      isDirty: Value(isDirty),
      teamId: Value(teamId),
      firstName: Value(firstName),
      lastName: Value(lastName),
      shirtNumber: shirtNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(shirtNumber),
      position: Value(position),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      dominantFoot: dominantFoot == null && nullToAbsent
          ? const Value.absent()
          : Value(dominantFoot),
      heightCm: heightCm == null && nullToAbsent
          ? const Value.absent()
          : Value(heightCm),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
    );
  }

  factory Player.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Player(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      serverUpdatedAt: serializer.fromJson<String?>(json['serverUpdatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      teamId: serializer.fromJson<String>(json['teamId']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String>(json['lastName']),
      shirtNumber: serializer.fromJson<int?>(json['shirtNumber']),
      position: serializer.fromJson<String>(json['position']),
      birthDate: serializer.fromJson<String?>(json['birthDate']),
      dominantFoot: serializer.fromJson<String?>(json['dominantFoot']),
      heightCm: serializer.fromJson<int?>(json['heightCm']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'serverUpdatedAt': serializer.toJson<String?>(serverUpdatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'isDirty': serializer.toJson<bool>(isDirty),
      'teamId': serializer.toJson<String>(teamId),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String>(lastName),
      'shirtNumber': serializer.toJson<int?>(shirtNumber),
      'position': serializer.toJson<String>(position),
      'birthDate': serializer.toJson<String?>(birthDate),
      'dominantFoot': serializer.toJson<String?>(dominantFoot),
      'heightCm': serializer.toJson<int?>(heightCm),
      'photoPath': serializer.toJson<String?>(photoPath),
    };
  }

  Player copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    Value<String?> serverUpdatedAt = const Value.absent(),
    bool? deleted,
    bool? isDirty,
    String? teamId,
    String? firstName,
    String? lastName,
    Value<int?> shirtNumber = const Value.absent(),
    String? position,
    Value<String?> birthDate = const Value.absent(),
    Value<String?> dominantFoot = const Value.absent(),
    Value<int?> heightCm = const Value.absent(),
    Value<String?> photoPath = const Value.absent(),
  }) => Player(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    deleted: deleted ?? this.deleted,
    isDirty: isDirty ?? this.isDirty,
    teamId: teamId ?? this.teamId,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    shirtNumber: shirtNumber.present ? shirtNumber.value : this.shirtNumber,
    position: position ?? this.position,
    birthDate: birthDate.present ? birthDate.value : this.birthDate,
    dominantFoot: dominantFoot.present ? dominantFoot.value : this.dominantFoot,
    heightCm: heightCm.present ? heightCm.value : this.heightCm,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
  );
  Player copyWithCompanion(PlayersCompanion data) {
    return Player(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      shirtNumber: data.shirtNumber.present
          ? data.shirtNumber.value
          : this.shirtNumber,
      position: data.position.present ? data.position.value : this.position,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      dominantFoot: data.dominantFoot.present
          ? data.dominantFoot.value
          : this.dominantFoot,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Player(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('teamId: $teamId, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('shirtNumber: $shirtNumber, ')
          ..write('position: $position, ')
          ..write('birthDate: $birthDate, ')
          ..write('dominantFoot: $dominantFoot, ')
          ..write('heightCm: $heightCm, ')
          ..write('photoPath: $photoPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    serverUpdatedAt,
    deleted,
    isDirty,
    teamId,
    firstName,
    lastName,
    shirtNumber,
    position,
    birthDate,
    dominantFoot,
    heightCm,
    photoPath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Player &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.deleted == this.deleted &&
          other.isDirty == this.isDirty &&
          other.teamId == this.teamId &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.shirtNumber == this.shirtNumber &&
          other.position == this.position &&
          other.birthDate == this.birthDate &&
          other.dominantFoot == this.dominantFoot &&
          other.heightCm == this.heightCm &&
          other.photoPath == this.photoPath);
}

class PlayersCompanion extends UpdateCompanion<Player> {
  final Value<String> id;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> serverUpdatedAt;
  final Value<bool> deleted;
  final Value<bool> isDirty;
  final Value<String> teamId;
  final Value<String> firstName;
  final Value<String> lastName;
  final Value<int?> shirtNumber;
  final Value<String> position;
  final Value<String?> birthDate;
  final Value<String?> dominantFoot;
  final Value<int?> heightCm;
  final Value<String?> photoPath;
  final Value<int> rowid;
  const PlayersCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.teamId = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.shirtNumber = const Value.absent(),
    this.position = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.dominantFoot = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlayersCompanion.insert({
    required String id,
    required String createdAt,
    required String updatedAt,
    this.serverUpdatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    required String teamId,
    required String firstName,
    required String lastName,
    this.shirtNumber = const Value.absent(),
    required String position,
    this.birthDate = const Value.absent(),
    this.dominantFoot = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       teamId = Value(teamId),
       firstName = Value(firstName),
       lastName = Value(lastName),
       position = Value(position);
  static Insertable<Player> custom({
    Expression<String>? id,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? serverUpdatedAt,
    Expression<bool>? deleted,
    Expression<bool>? isDirty,
    Expression<String>? teamId,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<int>? shirtNumber,
    Expression<String>? position,
    Expression<String>? birthDate,
    Expression<String>? dominantFoot,
    Expression<int>? heightCm,
    Expression<String>? photoPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (deleted != null) 'deleted': deleted,
      if (isDirty != null) 'is_dirty': isDirty,
      if (teamId != null) 'team_id': teamId,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (shirtNumber != null) 'shirt_number': shirtNumber,
      if (position != null) 'position': position,
      if (birthDate != null) 'birth_date': birthDate,
      if (dominantFoot != null) 'dominant_foot': dominantFoot,
      if (heightCm != null) 'height_cm': heightCm,
      if (photoPath != null) 'photo_path': photoPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlayersCompanion copyWith({
    Value<String>? id,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? serverUpdatedAt,
    Value<bool>? deleted,
    Value<bool>? isDirty,
    Value<String>? teamId,
    Value<String>? firstName,
    Value<String>? lastName,
    Value<int?>? shirtNumber,
    Value<String>? position,
    Value<String?>? birthDate,
    Value<String?>? dominantFoot,
    Value<int?>? heightCm,
    Value<String?>? photoPath,
    Value<int>? rowid,
  }) {
    return PlayersCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      deleted: deleted ?? this.deleted,
      isDirty: isDirty ?? this.isDirty,
      teamId: teamId ?? this.teamId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      shirtNumber: shirtNumber ?? this.shirtNumber,
      position: position ?? this.position,
      birthDate: birthDate ?? this.birthDate,
      dominantFoot: dominantFoot ?? this.dominantFoot,
      heightCm: heightCm ?? this.heightCm,
      photoPath: photoPath ?? this.photoPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<String>(serverUpdatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (teamId.present) {
      map['team_id'] = Variable<String>(teamId.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (shirtNumber.present) {
      map['shirt_number'] = Variable<int>(shirtNumber.value);
    }
    if (position.present) {
      map['position'] = Variable<String>(position.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<String>(birthDate.value);
    }
    if (dominantFoot.present) {
      map['dominant_foot'] = Variable<String>(dominantFoot.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<int>(heightCm.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayersCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('teamId: $teamId, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('shirtNumber: $shirtNumber, ')
          ..write('position: $position, ')
          ..write('birthDate: $birthDate, ')
          ..write('dominantFoot: $dominantFoot, ')
          ..write('heightCm: $heightCm, ')
          ..write('photoPath: $photoPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncStateTable extends SyncState
    with TableInfo<$SyncStateTable, SyncStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tableName_Meta = const VerificationMeta(
    'tableName_',
  );
  @override
  late final GeneratedColumn<String> tableName_ = GeneratedColumn<String>(
    'table_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cursorMeta = const VerificationMeta('cursor');
  @override
  late final GeneratedColumn<String> cursor = GeneratedColumn<String>(
    'cursor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [tableName_, cursor];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('table_name')) {
      context.handle(
        _tableName_Meta,
        tableName_.isAcceptableOrUnknown(data['table_name']!, _tableName_Meta),
      );
    } else if (isInserting) {
      context.missing(_tableName_Meta);
    }
    if (data.containsKey('cursor')) {
      context.handle(
        _cursorMeta,
        cursor.isAcceptableOrUnknown(data['cursor']!, _cursorMeta),
      );
    } else if (isInserting) {
      context.missing(_cursorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tableName_};
  @override
  SyncStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateData(
      tableName_: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}table_name'],
      )!,
      cursor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cursor'],
      )!,
    );
  }

  @override
  $SyncStateTable createAlias(String alias) {
    return $SyncStateTable(attachedDatabase, alias);
  }
}

class SyncStateData extends DataClass implements Insertable<SyncStateData> {
  final String tableName_;
  final String cursor;
  const SyncStateData({required this.tableName_, required this.cursor});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['table_name'] = Variable<String>(tableName_);
    map['cursor'] = Variable<String>(cursor);
    return map;
  }

  SyncStateCompanion toCompanion(bool nullToAbsent) {
    return SyncStateCompanion(
      tableName_: Value(tableName_),
      cursor: Value(cursor),
    );
  }

  factory SyncStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateData(
      tableName_: serializer.fromJson<String>(json['tableName_']),
      cursor: serializer.fromJson<String>(json['cursor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tableName_': serializer.toJson<String>(tableName_),
      'cursor': serializer.toJson<String>(cursor),
    };
  }

  SyncStateData copyWith({String? tableName_, String? cursor}) => SyncStateData(
    tableName_: tableName_ ?? this.tableName_,
    cursor: cursor ?? this.cursor,
  );
  SyncStateData copyWithCompanion(SyncStateCompanion data) {
    return SyncStateData(
      tableName_: data.tableName_.present
          ? data.tableName_.value
          : this.tableName_,
      cursor: data.cursor.present ? data.cursor.value : this.cursor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateData(')
          ..write('tableName_: $tableName_, ')
          ..write('cursor: $cursor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(tableName_, cursor);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateData &&
          other.tableName_ == this.tableName_ &&
          other.cursor == this.cursor);
}

class SyncStateCompanion extends UpdateCompanion<SyncStateData> {
  final Value<String> tableName_;
  final Value<String> cursor;
  final Value<int> rowid;
  const SyncStateCompanion({
    this.tableName_ = const Value.absent(),
    this.cursor = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStateCompanion.insert({
    required String tableName_,
    required String cursor,
    this.rowid = const Value.absent(),
  }) : tableName_ = Value(tableName_),
       cursor = Value(cursor);
  static Insertable<SyncStateData> custom({
    Expression<String>? tableName_,
    Expression<String>? cursor,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tableName_ != null) 'table_name': tableName_,
      if (cursor != null) 'cursor': cursor,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStateCompanion copyWith({
    Value<String>? tableName_,
    Value<String>? cursor,
    Value<int>? rowid,
  }) {
    return SyncStateCompanion(
      tableName_: tableName_ ?? this.tableName_,
      cursor: cursor ?? this.cursor,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tableName_.present) {
      map['table_name'] = Variable<String>(tableName_.value);
    }
    if (cursor.present) {
      map['cursor'] = Variable<String>(cursor.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateCompanion(')
          ..write('tableName_: $tableName_, ')
          ..write('cursor: $cursor, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalSettingsTable extends LocalSettings
    with TableInfo<$LocalSettingsTable, LocalSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  LocalSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $LocalSettingsTable createAlias(String alias) {
    return $LocalSettingsTable(attachedDatabase, alias);
  }
}

class LocalSetting extends DataClass implements Insertable<LocalSetting> {
  final String key;
  final String value;
  const LocalSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  LocalSettingsCompanion toCompanion(bool nullToAbsent) {
    return LocalSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory LocalSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  LocalSetting copyWith({String? key, String? value}) =>
      LocalSetting(key: key ?? this.key, value: value ?? this.value);
  LocalSetting copyWithCompanion(LocalSettingsCompanion data) {
    return LocalSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class LocalSettingsCompanion extends UpdateCompanion<LocalSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const LocalSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<LocalSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return LocalSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TeamsTable teams = $TeamsTable(this);
  late final $TeamMembersTable teamMembers = $TeamMembersTable(this);
  late final $PlayersTable players = $PlayersTable(this);
  late final $SyncStateTable syncState = $SyncStateTable(this);
  late final $LocalSettingsTable localSettings = $LocalSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    teams,
    teamMembers,
    players,
    syncState,
    localSettings,
  ];
}

typedef $$TeamsTableCreateCompanionBuilder = TeamsCompanion Function({
  required String id,
  required String createdAt,
  required String updatedAt,
  Value<String?> serverUpdatedAt,
  Value<bool> deleted,
  Value<bool> isDirty,
  required String name,
  Value<String?> clubName,
  required String category,
  required String season,
  Value<String?> logoPath,
  required String createdBy,
  Value<int> rowid,
});
typedef $$TeamsTableUpdateCompanionBuilder = TeamsCompanion Function({
  Value<String> id,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String?> serverUpdatedAt,
  Value<bool> deleted,
  Value<bool> isDirty,
  Value<String> name,
  Value<String?> clubName,
  Value<String> category,
  Value<String> season,
  Value<String?> logoPath,
  Value<String> createdBy,
  Value<int> rowid,
});

class $$TeamsTableFilterComposer extends Composer<_$AppDatabase, $TeamsTable> {
  $$TeamsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clubName => $composableBuilder(
    column: $table.clubName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logoPath => $composableBuilder(
    column: $table.logoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TeamsTableOrderingComposer
    extends Composer<_$AppDatabase, $TeamsTable> {
  $$TeamsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clubName => $composableBuilder(
    column: $table.clubName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logoPath => $composableBuilder(
    column: $table.logoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TeamsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TeamsTable> {
  $$TeamsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get clubName =>
      $composableBuilder(column: $table.clubName, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get season =>
      $composableBuilder(column: $table.season, builder: (column) => column);

  GeneratedColumn<String> get logoPath =>
      $composableBuilder(column: $table.logoPath, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);
}

class $$TeamsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TeamsTable,
          Team,
          $$TeamsTableFilterComposer,
          $$TeamsTableOrderingComposer,
          $$TeamsTableAnnotationComposer,
          $$TeamsTableCreateCompanionBuilder,
          $$TeamsTableUpdateCompanionBuilder,
          (Team, BaseReferences<_$AppDatabase, $TeamsTable, Team>),
          Team,
          PrefetchHooks Function()
        > {
  $$TeamsTableTableManager(_$AppDatabase db, $TeamsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TeamsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TeamsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TeamsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> serverUpdatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> clubName = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> season = const Value.absent(),
                Value<String?> logoPath = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeamsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                deleted: deleted,
                isDirty: isDirty,
                name: name,
                clubName: clubName,
                category: category,
                season: season,
                logoPath: logoPath,
                createdBy: createdBy,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String createdAt,
                required String updatedAt,
                Value<String?> serverUpdatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                required String name,
                Value<String?> clubName = const Value.absent(),
                required String category,
                required String season,
                Value<String?> logoPath = const Value.absent(),
                required String createdBy,
                Value<int> rowid = const Value.absent(),
              }) => TeamsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                deleted: deleted,
                isDirty: isDirty,
                name: name,
                clubName: clubName,
                category: category,
                season: season,
                logoPath: logoPath,
                createdBy: createdBy,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TeamsTable, Team>(table),
                  BaseReferences<_$AppDatabase, $TeamsTable, Team>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TeamsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TeamsTable,
      Team,
      $$TeamsTableFilterComposer,
      $$TeamsTableOrderingComposer,
      $$TeamsTableAnnotationComposer,
      $$TeamsTableCreateCompanionBuilder,
      $$TeamsTableUpdateCompanionBuilder,
      (Team, BaseReferences<_$AppDatabase, $TeamsTable, Team>),
      Team,
      PrefetchHooks Function()
    >;
typedef $$TeamMembersTableCreateCompanionBuilder =
    TeamMembersCompanion Function({
      required String id,
      required String createdAt,
      required String updatedAt,
      Value<String?> serverUpdatedAt,
      Value<bool> deleted,
      Value<bool> isDirty,
      required String teamId,
      required String userId,
      required String role,
      Value<int> rowid,
    });
typedef $$TeamMembersTableUpdateCompanionBuilder =
    TeamMembersCompanion Function({
      Value<String> id,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String?> serverUpdatedAt,
      Value<bool> deleted,
      Value<bool> isDirty,
      Value<String> teamId,
      Value<String> userId,
      Value<String> role,
      Value<int> rowid,
    });

class $$TeamMembersTableFilterComposer
    extends Composer<_$AppDatabase, $TeamMembersTable> {
  $$TeamMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TeamMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $TeamMembersTable> {
  $$TeamMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TeamMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $TeamMembersTable> {
  $$TeamMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<String> get teamId =>
      $composableBuilder(column: $table.teamId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);
}

class $$TeamMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TeamMembersTable,
          TeamMember,
          $$TeamMembersTableFilterComposer,
          $$TeamMembersTableOrderingComposer,
          $$TeamMembersTableAnnotationComposer,
          $$TeamMembersTableCreateCompanionBuilder,
          $$TeamMembersTableUpdateCompanionBuilder,
          (
            TeamMember,
            BaseReferences<_$AppDatabase, $TeamMembersTable, TeamMember>,
          ),
          TeamMember,
          PrefetchHooks Function()
        > {
  $$TeamMembersTableTableManager(_$AppDatabase db, $TeamMembersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TeamMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TeamMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TeamMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> serverUpdatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<String> teamId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeamMembersCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                deleted: deleted,
                isDirty: isDirty,
                teamId: teamId,
                userId: userId,
                role: role,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String createdAt,
                required String updatedAt,
                Value<String?> serverUpdatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                required String teamId,
                required String userId,
                required String role,
                Value<int> rowid = const Value.absent(),
              }) => TeamMembersCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                deleted: deleted,
                isDirty: isDirty,
                teamId: teamId,
                userId: userId,
                role: role,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TeamMembersTable, TeamMember>(table),
                  BaseReferences<_$AppDatabase, $TeamMembersTable, TeamMember>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TeamMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TeamMembersTable,
      TeamMember,
      $$TeamMembersTableFilterComposer,
      $$TeamMembersTableOrderingComposer,
      $$TeamMembersTableAnnotationComposer,
      $$TeamMembersTableCreateCompanionBuilder,
      $$TeamMembersTableUpdateCompanionBuilder,
      (
        TeamMember,
        BaseReferences<_$AppDatabase, $TeamMembersTable, TeamMember>,
      ),
      TeamMember,
      PrefetchHooks Function()
    >;
typedef $$PlayersTableCreateCompanionBuilder = PlayersCompanion Function({
  required String id,
  required String createdAt,
  required String updatedAt,
  Value<String?> serverUpdatedAt,
  Value<bool> deleted,
  Value<bool> isDirty,
  required String teamId,
  required String firstName,
  required String lastName,
  Value<int?> shirtNumber,
  required String position,
  Value<String?> birthDate,
  Value<String?> dominantFoot,
  Value<int?> heightCm,
  Value<String?> photoPath,
  Value<int> rowid,
});
typedef $$PlayersTableUpdateCompanionBuilder = PlayersCompanion Function({
  Value<String> id,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String?> serverUpdatedAt,
  Value<bool> deleted,
  Value<bool> isDirty,
  Value<String> teamId,
  Value<String> firstName,
  Value<String> lastName,
  Value<int?> shirtNumber,
  Value<String> position,
  Value<String?> birthDate,
  Value<String?> dominantFoot,
  Value<int?> heightCm,
  Value<String?> photoPath,
  Value<int> rowid,
});

class $$PlayersTableFilterComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get shirtNumber => $composableBuilder(
    column: $table.shirtNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dominantFoot => $composableBuilder(
    column: $table.dominantFoot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlayersTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get shirtNumber => $composableBuilder(
    column: $table.shirtNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dominantFoot => $composableBuilder(
    column: $table.dominantFoot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlayersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<String> get teamId =>
      $composableBuilder(column: $table.teamId, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<int> get shirtNumber => $composableBuilder(
    column: $table.shirtNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<String> get dominantFoot => $composableBuilder(
    column: $table.dominantFoot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);
}

class $$PlayersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayersTable,
          Player,
          $$PlayersTableFilterComposer,
          $$PlayersTableOrderingComposer,
          $$PlayersTableAnnotationComposer,
          $$PlayersTableCreateCompanionBuilder,
          $$PlayersTableUpdateCompanionBuilder,
          (Player, BaseReferences<_$AppDatabase, $PlayersTable, Player>),
          Player,
          PrefetchHooks Function()
        > {
  $$PlayersTableTableManager(_$AppDatabase db, $PlayersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> serverUpdatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<String> teamId = const Value.absent(),
                Value<String> firstName = const Value.absent(),
                Value<String> lastName = const Value.absent(),
                Value<int?> shirtNumber = const Value.absent(),
                Value<String> position = const Value.absent(),
                Value<String?> birthDate = const Value.absent(),
                Value<String?> dominantFoot = const Value.absent(),
                Value<int?> heightCm = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlayersCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                deleted: deleted,
                isDirty: isDirty,
                teamId: teamId,
                firstName: firstName,
                lastName: lastName,
                shirtNumber: shirtNumber,
                position: position,
                birthDate: birthDate,
                dominantFoot: dominantFoot,
                heightCm: heightCm,
                photoPath: photoPath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String createdAt,
                required String updatedAt,
                Value<String?> serverUpdatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                required String teamId,
                required String firstName,
                required String lastName,
                Value<int?> shirtNumber = const Value.absent(),
                required String position,
                Value<String?> birthDate = const Value.absent(),
                Value<String?> dominantFoot = const Value.absent(),
                Value<int?> heightCm = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlayersCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                deleted: deleted,
                isDirty: isDirty,
                teamId: teamId,
                firstName: firstName,
                lastName: lastName,
                shirtNumber: shirtNumber,
                position: position,
                birthDate: birthDate,
                dominantFoot: dominantFoot,
                heightCm: heightCm,
                photoPath: photoPath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlayersTable, Player>(table),
                  BaseReferences<_$AppDatabase, $PlayersTable, Player>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlayersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayersTable,
      Player,
      $$PlayersTableFilterComposer,
      $$PlayersTableOrderingComposer,
      $$PlayersTableAnnotationComposer,
      $$PlayersTableCreateCompanionBuilder,
      $$PlayersTableUpdateCompanionBuilder,
      (Player, BaseReferences<_$AppDatabase, $PlayersTable, Player>),
      Player,
      PrefetchHooks Function()
    >;
typedef $$SyncStateTableCreateCompanionBuilder = SyncStateCompanion Function({
  required String tableName_,
  required String cursor,
  Value<int> rowid,
});
typedef $$SyncStateTableUpdateCompanionBuilder = SyncStateCompanion Function({
  Value<String> tableName_,
  Value<String> cursor,
  Value<int> rowid,
});

class $$SyncStateTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get tableName_ => $composableBuilder(
    column: $table.tableName_,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncStateTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get tableName_ => $composableBuilder(
    column: $table.tableName_,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get tableName_ => $composableBuilder(
    column: $table.tableName_,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => column);
}

class $$SyncStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncStateTable,
          SyncStateData,
          $$SyncStateTableFilterComposer,
          $$SyncStateTableOrderingComposer,
          $$SyncStateTableAnnotationComposer,
          $$SyncStateTableCreateCompanionBuilder,
          $$SyncStateTableUpdateCompanionBuilder,
          (
            SyncStateData,
            BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateData>,
          ),
          SyncStateData,
          PrefetchHooks Function()
        > {
  $$SyncStateTableTableManager(_$AppDatabase db, $SyncStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> tableName_ = const Value.absent(),
                Value<String> cursor = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion(
                tableName_: tableName_,
                cursor: cursor,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String tableName_,
                required String cursor,
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion.insert(
                tableName_: tableName_,
                cursor: cursor,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncStateTable, SyncStateData>(table),
                  BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateData>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncStateTable,
      SyncStateData,
      $$SyncStateTableFilterComposer,
      $$SyncStateTableOrderingComposer,
      $$SyncStateTableAnnotationComposer,
      $$SyncStateTableCreateCompanionBuilder,
      $$SyncStateTableUpdateCompanionBuilder,
      (
        SyncStateData,
        BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateData>,
      ),
      SyncStateData,
      PrefetchHooks Function()
    >;
typedef $$LocalSettingsTableCreateCompanionBuilder =
    LocalSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$LocalSettingsTableUpdateCompanionBuilder =
    LocalSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$LocalSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalSettingsTable> {
  $$LocalSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalSettingsTable> {
  $$LocalSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalSettingsTable> {
  $$LocalSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$LocalSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalSettingsTable,
          LocalSetting,
          $$LocalSettingsTableFilterComposer,
          $$LocalSettingsTableOrderingComposer,
          $$LocalSettingsTableAnnotationComposer,
          $$LocalSettingsTableCreateCompanionBuilder,
          $$LocalSettingsTableUpdateCompanionBuilder,
          (
            LocalSetting,
            BaseReferences<_$AppDatabase, $LocalSettingsTable, LocalSetting>,
          ),
          LocalSetting,
          PrefetchHooks Function()
        > {
  $$LocalSettingsTableTableManager(_$AppDatabase db, $LocalSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => LocalSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => LocalSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalSettingsTable, LocalSetting>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalSettingsTable,
                    LocalSetting
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalSettingsTable,
      LocalSetting,
      $$LocalSettingsTableFilterComposer,
      $$LocalSettingsTableOrderingComposer,
      $$LocalSettingsTableAnnotationComposer,
      $$LocalSettingsTableCreateCompanionBuilder,
      $$LocalSettingsTableUpdateCompanionBuilder,
      (
        LocalSetting,
        BaseReferences<_$AppDatabase, $LocalSettingsTable, LocalSetting>,
      ),
      LocalSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TeamsTableTableManager get teams =>
      $$TeamsTableTableManager(_db, _db.teams);
  $$TeamMembersTableTableManager get teamMembers =>
      $$TeamMembersTableTableManager(_db, _db.teamMembers);
  $$PlayersTableTableManager get players =>
      $$PlayersTableTableManager(_db, _db.players);
  $$SyncStateTableTableManager get syncState =>
      $$SyncStateTableTableManager(_db, _db.syncState);
  $$LocalSettingsTableTableManager get localSettings =>
      $$LocalSettingsTableTableManager(_db, _db.localSettings);
}
