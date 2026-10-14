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
  static const VerificationMeta _detailedPositionMeta = const VerificationMeta(
    'detailedPosition',
  );
  @override
  late final GeneratedColumn<String> detailedPosition = GeneratedColumn<String>(
    'detailed_position',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _secondaryPositionMeta = const VerificationMeta(
    'secondaryPosition',
  );
  @override
  late final GeneratedColumn<String> secondaryPosition =
      GeneratedColumn<String>(
        'secondary_position',
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
    detailedPosition,
    secondaryPosition,
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
    if (data.containsKey('detailed_position')) {
      context.handle(
        _detailedPositionMeta,
        detailedPosition.isAcceptableOrUnknown(
          data['detailed_position']!,
          _detailedPositionMeta,
        ),
      );
    }
    if (data.containsKey('secondary_position')) {
      context.handle(
        _secondaryPositionMeta,
        secondaryPosition.isAcceptableOrUnknown(
          data['secondary_position']!,
          _secondaryPositionMeta,
        ),
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
      detailedPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detailed_position'],
      ),
      secondaryPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}secondary_position'],
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
  final String? detailedPosition;
  final String? secondaryPosition;
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
    this.detailedPosition,
    this.secondaryPosition,
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
    if (!nullToAbsent || detailedPosition != null) {
      map['detailed_position'] = Variable<String>(detailedPosition);
    }
    if (!nullToAbsent || secondaryPosition != null) {
      map['secondary_position'] = Variable<String>(secondaryPosition);
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
      detailedPosition: detailedPosition == null && nullToAbsent
          ? const Value.absent()
          : Value(detailedPosition),
      secondaryPosition: secondaryPosition == null && nullToAbsent
          ? const Value.absent()
          : Value(secondaryPosition),
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
      detailedPosition: serializer.fromJson<String?>(json['detailedPosition']),
      secondaryPosition: serializer.fromJson<String?>(
        json['secondaryPosition'],
      ),
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
      'detailedPosition': serializer.toJson<String?>(detailedPosition),
      'secondaryPosition': serializer.toJson<String?>(secondaryPosition),
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
    Value<String?> detailedPosition = const Value.absent(),
    Value<String?> secondaryPosition = const Value.absent(),
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
    detailedPosition: detailedPosition.present
        ? detailedPosition.value
        : this.detailedPosition,
    secondaryPosition: secondaryPosition.present
        ? secondaryPosition.value
        : this.secondaryPosition,
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
      detailedPosition: data.detailedPosition.present
          ? data.detailedPosition.value
          : this.detailedPosition,
      secondaryPosition: data.secondaryPosition.present
          ? data.secondaryPosition.value
          : this.secondaryPosition,
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
          ..write('photoPath: $photoPath, ')
          ..write('detailedPosition: $detailedPosition, ')
          ..write('secondaryPosition: $secondaryPosition')
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
    detailedPosition,
    secondaryPosition,
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
          other.photoPath == this.photoPath &&
          other.detailedPosition == this.detailedPosition &&
          other.secondaryPosition == this.secondaryPosition);
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
  final Value<String?> detailedPosition;
  final Value<String?> secondaryPosition;
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
    this.detailedPosition = const Value.absent(),
    this.secondaryPosition = const Value.absent(),
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
    this.detailedPosition = const Value.absent(),
    this.secondaryPosition = const Value.absent(),
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
    Expression<String>? detailedPosition,
    Expression<String>? secondaryPosition,
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
      if (detailedPosition != null) 'detailed_position': detailedPosition,
      if (secondaryPosition != null) 'secondary_position': secondaryPosition,
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
    Value<String?>? detailedPosition,
    Value<String?>? secondaryPosition,
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
      detailedPosition: detailedPosition ?? this.detailedPosition,
      secondaryPosition: secondaryPosition ?? this.secondaryPosition,
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
    if (detailedPosition.present) {
      map['detailed_position'] = Variable<String>(detailedPosition.value);
    }
    if (secondaryPosition.present) {
      map['secondary_position'] = Variable<String>(secondaryPosition.value);
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
          ..write('detailedPosition: $detailedPosition, ')
          ..write('secondaryPosition: $secondaryPosition, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions
    with TableInfo<$SessionsTable, TrainingSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<String> startTime = GeneratedColumn<String>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plannedDurationMinMeta =
      const VerificationMeta('plannedDurationMin');
  @override
  late final GeneratedColumn<int> plannedDurationMin = GeneratedColumn<int>(
    'planned_duration_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(90),
  );
  static const VerificationMeta _objectiveMeta = const VerificationMeta(
    'objective',
  );
  @override
  late final GeneratedColumn<String> objective = GeneratedColumn<String>(
    'objective',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remarksMeta = const VerificationMeta(
    'remarks',
  );
  @override
  late final GeneratedColumn<String> remarks = GeneratedColumn<String>(
    'remarks',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('planned'),
  );
  static const VerificationMeta _plannedRpeMeta = const VerificationMeta(
    'plannedRpe',
  );
  @override
  late final GeneratedColumn<int> plannedRpe = GeneratedColumn<int>(
    'planned_rpe',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
    date,
    startTime,
    type,
    plannedDurationMin,
    objective,
    remarks,
    status,
    plannedRpe,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrainingSession> instance, {
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
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('planned_duration_min')) {
      context.handle(
        _plannedDurationMinMeta,
        plannedDurationMin.isAcceptableOrUnknown(
          data['planned_duration_min']!,
          _plannedDurationMinMeta,
        ),
      );
    }
    if (data.containsKey('objective')) {
      context.handle(
        _objectiveMeta,
        objective.isAcceptableOrUnknown(data['objective']!, _objectiveMeta),
      );
    }
    if (data.containsKey('remarks')) {
      context.handle(
        _remarksMeta,
        remarks.isAcceptableOrUnknown(data['remarks']!, _remarksMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('planned_rpe')) {
      context.handle(
        _plannedRpeMeta,
        plannedRpe.isAcceptableOrUnknown(data['planned_rpe']!, _plannedRpeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrainingSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrainingSession(
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
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_time'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      plannedDurationMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_duration_min'],
      )!,
      objective: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}objective'],
      ),
      remarks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remarks'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      plannedRpe: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_rpe'],
      ),
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class TrainingSession extends DataClass implements Insertable<TrainingSession> {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String? serverUpdatedAt;
  final bool deleted;

  /// Modifiée localement et pas encore envoyée. Jamais synchronisée.
  final bool isDirty;
  final String teamId;
  final String date;
  final String startTime;
  final String type;
  final int plannedDurationMin;
  final String? objective;
  final String? remarks;
  final String status;

  /// RPE visé : charge prévue = durée prévue × RPE prévu.
  final int? plannedRpe;
  const TrainingSession({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.serverUpdatedAt,
    required this.deleted,
    required this.isDirty,
    required this.teamId,
    required this.date,
    required this.startTime,
    required this.type,
    required this.plannedDurationMin,
    this.objective,
    this.remarks,
    required this.status,
    this.plannedRpe,
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
    map['date'] = Variable<String>(date);
    map['start_time'] = Variable<String>(startTime);
    map['type'] = Variable<String>(type);
    map['planned_duration_min'] = Variable<int>(plannedDurationMin);
    if (!nullToAbsent || objective != null) {
      map['objective'] = Variable<String>(objective);
    }
    if (!nullToAbsent || remarks != null) {
      map['remarks'] = Variable<String>(remarks);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || plannedRpe != null) {
      map['planned_rpe'] = Variable<int>(plannedRpe);
    }
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      deleted: Value(deleted),
      isDirty: Value(isDirty),
      teamId: Value(teamId),
      date: Value(date),
      startTime: Value(startTime),
      type: Value(type),
      plannedDurationMin: Value(plannedDurationMin),
      objective: objective == null && nullToAbsent
          ? const Value.absent()
          : Value(objective),
      remarks: remarks == null && nullToAbsent
          ? const Value.absent()
          : Value(remarks),
      status: Value(status),
      plannedRpe: plannedRpe == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedRpe),
    );
  }

  factory TrainingSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrainingSession(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      serverUpdatedAt: serializer.fromJson<String?>(json['serverUpdatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      teamId: serializer.fromJson<String>(json['teamId']),
      date: serializer.fromJson<String>(json['date']),
      startTime: serializer.fromJson<String>(json['startTime']),
      type: serializer.fromJson<String>(json['type']),
      plannedDurationMin: serializer.fromJson<int>(json['plannedDurationMin']),
      objective: serializer.fromJson<String?>(json['objective']),
      remarks: serializer.fromJson<String?>(json['remarks']),
      status: serializer.fromJson<String>(json['status']),
      plannedRpe: serializer.fromJson<int?>(json['plannedRpe']),
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
      'date': serializer.toJson<String>(date),
      'startTime': serializer.toJson<String>(startTime),
      'type': serializer.toJson<String>(type),
      'plannedDurationMin': serializer.toJson<int>(plannedDurationMin),
      'objective': serializer.toJson<String?>(objective),
      'remarks': serializer.toJson<String?>(remarks),
      'status': serializer.toJson<String>(status),
      'plannedRpe': serializer.toJson<int?>(plannedRpe),
    };
  }

  TrainingSession copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    Value<String?> serverUpdatedAt = const Value.absent(),
    bool? deleted,
    bool? isDirty,
    String? teamId,
    String? date,
    String? startTime,
    String? type,
    int? plannedDurationMin,
    Value<String?> objective = const Value.absent(),
    Value<String?> remarks = const Value.absent(),
    String? status,
    Value<int?> plannedRpe = const Value.absent(),
  }) => TrainingSession(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    deleted: deleted ?? this.deleted,
    isDirty: isDirty ?? this.isDirty,
    teamId: teamId ?? this.teamId,
    date: date ?? this.date,
    startTime: startTime ?? this.startTime,
    type: type ?? this.type,
    plannedDurationMin: plannedDurationMin ?? this.plannedDurationMin,
    objective: objective.present ? objective.value : this.objective,
    remarks: remarks.present ? remarks.value : this.remarks,
    status: status ?? this.status,
    plannedRpe: plannedRpe.present ? plannedRpe.value : this.plannedRpe,
  );
  TrainingSession copyWithCompanion(SessionsCompanion data) {
    return TrainingSession(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      date: data.date.present ? data.date.value : this.date,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      type: data.type.present ? data.type.value : this.type,
      plannedDurationMin: data.plannedDurationMin.present
          ? data.plannedDurationMin.value
          : this.plannedDurationMin,
      objective: data.objective.present ? data.objective.value : this.objective,
      remarks: data.remarks.present ? data.remarks.value : this.remarks,
      status: data.status.present ? data.status.value : this.status,
      plannedRpe: data.plannedRpe.present
          ? data.plannedRpe.value
          : this.plannedRpe,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrainingSession(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('teamId: $teamId, ')
          ..write('date: $date, ')
          ..write('startTime: $startTime, ')
          ..write('type: $type, ')
          ..write('plannedDurationMin: $plannedDurationMin, ')
          ..write('objective: $objective, ')
          ..write('remarks: $remarks, ')
          ..write('status: $status, ')
          ..write('plannedRpe: $plannedRpe')
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
    date,
    startTime,
    type,
    plannedDurationMin,
    objective,
    remarks,
    status,
    plannedRpe,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrainingSession &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.deleted == this.deleted &&
          other.isDirty == this.isDirty &&
          other.teamId == this.teamId &&
          other.date == this.date &&
          other.startTime == this.startTime &&
          other.type == this.type &&
          other.plannedDurationMin == this.plannedDurationMin &&
          other.objective == this.objective &&
          other.remarks == this.remarks &&
          other.status == this.status &&
          other.plannedRpe == this.plannedRpe);
}

class SessionsCompanion extends UpdateCompanion<TrainingSession> {
  final Value<String> id;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> serverUpdatedAt;
  final Value<bool> deleted;
  final Value<bool> isDirty;
  final Value<String> teamId;
  final Value<String> date;
  final Value<String> startTime;
  final Value<String> type;
  final Value<int> plannedDurationMin;
  final Value<String?> objective;
  final Value<String?> remarks;
  final Value<String> status;
  final Value<int?> plannedRpe;
  final Value<int> rowid;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.teamId = const Value.absent(),
    this.date = const Value.absent(),
    this.startTime = const Value.absent(),
    this.type = const Value.absent(),
    this.plannedDurationMin = const Value.absent(),
    this.objective = const Value.absent(),
    this.remarks = const Value.absent(),
    this.status = const Value.absent(),
    this.plannedRpe = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsCompanion.insert({
    required String id,
    required String createdAt,
    required String updatedAt,
    this.serverUpdatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    required String teamId,
    required String date,
    required String startTime,
    required String type,
    this.plannedDurationMin = const Value.absent(),
    this.objective = const Value.absent(),
    this.remarks = const Value.absent(),
    this.status = const Value.absent(),
    this.plannedRpe = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       teamId = Value(teamId),
       date = Value(date),
       startTime = Value(startTime),
       type = Value(type);
  static Insertable<TrainingSession> custom({
    Expression<String>? id,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? serverUpdatedAt,
    Expression<bool>? deleted,
    Expression<bool>? isDirty,
    Expression<String>? teamId,
    Expression<String>? date,
    Expression<String>? startTime,
    Expression<String>? type,
    Expression<int>? plannedDurationMin,
    Expression<String>? objective,
    Expression<String>? remarks,
    Expression<String>? status,
    Expression<int>? plannedRpe,
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
      if (date != null) 'date': date,
      if (startTime != null) 'start_time': startTime,
      if (type != null) 'type': type,
      if (plannedDurationMin != null)
        'planned_duration_min': plannedDurationMin,
      if (objective != null) 'objective': objective,
      if (remarks != null) 'remarks': remarks,
      if (status != null) 'status': status,
      if (plannedRpe != null) 'planned_rpe': plannedRpe,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? serverUpdatedAt,
    Value<bool>? deleted,
    Value<bool>? isDirty,
    Value<String>? teamId,
    Value<String>? date,
    Value<String>? startTime,
    Value<String>? type,
    Value<int>? plannedDurationMin,
    Value<String?>? objective,
    Value<String?>? remarks,
    Value<String>? status,
    Value<int?>? plannedRpe,
    Value<int>? rowid,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      deleted: deleted ?? this.deleted,
      isDirty: isDirty ?? this.isDirty,
      teamId: teamId ?? this.teamId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      type: type ?? this.type,
      plannedDurationMin: plannedDurationMin ?? this.plannedDurationMin,
      objective: objective ?? this.objective,
      remarks: remarks ?? this.remarks,
      status: status ?? this.status,
      plannedRpe: plannedRpe ?? this.plannedRpe,
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
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<String>(startTime.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (plannedDurationMin.present) {
      map['planned_duration_min'] = Variable<int>(plannedDurationMin.value);
    }
    if (objective.present) {
      map['objective'] = Variable<String>(objective.value);
    }
    if (remarks.present) {
      map['remarks'] = Variable<String>(remarks.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (plannedRpe.present) {
      map['planned_rpe'] = Variable<int>(plannedRpe.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('teamId: $teamId, ')
          ..write('date: $date, ')
          ..write('startTime: $startTime, ')
          ..write('type: $type, ')
          ..write('plannedDurationMin: $plannedDurationMin, ')
          ..write('objective: $objective, ')
          ..write('remarks: $remarks, ')
          ..write('status: $status, ')
          ..write('plannedRpe: $plannedRpe, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionPlayersTable extends SessionPlayers
    with TableInfo<$SessionPlayersTable, SessionPlayer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionPlayersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playerIdMeta = const VerificationMeta(
    'playerId',
  );
  @override
  late final GeneratedColumn<String> playerId = GeneratedColumn<String>(
    'player_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _presentMeta = const VerificationMeta(
    'present',
  );
  @override
  late final GeneratedColumn<bool> present = GeneratedColumn<bool>(
    'present',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("present" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _absenceReasonMeta = const VerificationMeta(
    'absenceReason',
  );
  @override
  late final GeneratedColumn<String> absenceReason = GeneratedColumn<String>(
    'absence_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMinMeta = const VerificationMeta(
    'durationMin',
  );
  @override
  late final GeneratedColumn<int> durationMin = GeneratedColumn<int>(
    'duration_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rpeMeta = const VerificationMeta('rpe');
  @override
  late final GeneratedColumn<int> rpe = GeneratedColumn<int>(
    'rpe',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remarkMeta = const VerificationMeta('remark');
  @override
  late final GeneratedColumn<String> remark = GeneratedColumn<String>(
    'remark',
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
    sessionId,
    playerId,
    present,
    absenceReason,
    durationMin,
    rpe,
    remark,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_players';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionPlayer> instance, {
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
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('player_id')) {
      context.handle(
        _playerIdMeta,
        playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('present')) {
      context.handle(
        _presentMeta,
        present.isAcceptableOrUnknown(data['present']!, _presentMeta),
      );
    }
    if (data.containsKey('absence_reason')) {
      context.handle(
        _absenceReasonMeta,
        absenceReason.isAcceptableOrUnknown(
          data['absence_reason']!,
          _absenceReasonMeta,
        ),
      );
    }
    if (data.containsKey('duration_min')) {
      context.handle(
        _durationMinMeta,
        durationMin.isAcceptableOrUnknown(
          data['duration_min']!,
          _durationMinMeta,
        ),
      );
    }
    if (data.containsKey('rpe')) {
      context.handle(
        _rpeMeta,
        rpe.isAcceptableOrUnknown(data['rpe']!, _rpeMeta),
      );
    }
    if (data.containsKey('remark')) {
      context.handle(
        _remarkMeta,
        remark.isAcceptableOrUnknown(data['remark']!, _remarkMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionPlayer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionPlayer(
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
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      playerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}player_id'],
      )!,
      present: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}present'],
      )!,
      absenceReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}absence_reason'],
      ),
      durationMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_min'],
      ),
      rpe: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rpe'],
      ),
      remark: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remark'],
      ),
    );
  }

  @override
  $SessionPlayersTable createAlias(String alias) {
    return $SessionPlayersTable(attachedDatabase, alias);
  }
}

class SessionPlayer extends DataClass implements Insertable<SessionPlayer> {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String? serverUpdatedAt;
  final bool deleted;

  /// Modifiée localement et pas encore envoyée. Jamais synchronisée.
  final bool isDirty;
  final String teamId;
  final String sessionId;
  final String playerId;
  final bool present;
  final String? absenceReason;
  final int? durationMin;
  final int? rpe;
  final String? remark;
  const SessionPlayer({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.serverUpdatedAt,
    required this.deleted,
    required this.isDirty,
    required this.teamId,
    required this.sessionId,
    required this.playerId,
    required this.present,
    this.absenceReason,
    this.durationMin,
    this.rpe,
    this.remark,
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
    map['session_id'] = Variable<String>(sessionId);
    map['player_id'] = Variable<String>(playerId);
    map['present'] = Variable<bool>(present);
    if (!nullToAbsent || absenceReason != null) {
      map['absence_reason'] = Variable<String>(absenceReason);
    }
    if (!nullToAbsent || durationMin != null) {
      map['duration_min'] = Variable<int>(durationMin);
    }
    if (!nullToAbsent || rpe != null) {
      map['rpe'] = Variable<int>(rpe);
    }
    if (!nullToAbsent || remark != null) {
      map['remark'] = Variable<String>(remark);
    }
    return map;
  }

  SessionPlayersCompanion toCompanion(bool nullToAbsent) {
    return SessionPlayersCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      deleted: Value(deleted),
      isDirty: Value(isDirty),
      teamId: Value(teamId),
      sessionId: Value(sessionId),
      playerId: Value(playerId),
      present: Value(present),
      absenceReason: absenceReason == null && nullToAbsent
          ? const Value.absent()
          : Value(absenceReason),
      durationMin: durationMin == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMin),
      rpe: rpe == null && nullToAbsent ? const Value.absent() : Value(rpe),
      remark: remark == null && nullToAbsent
          ? const Value.absent()
          : Value(remark),
    );
  }

  factory SessionPlayer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionPlayer(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      serverUpdatedAt: serializer.fromJson<String?>(json['serverUpdatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      teamId: serializer.fromJson<String>(json['teamId']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      playerId: serializer.fromJson<String>(json['playerId']),
      present: serializer.fromJson<bool>(json['present']),
      absenceReason: serializer.fromJson<String?>(json['absenceReason']),
      durationMin: serializer.fromJson<int?>(json['durationMin']),
      rpe: serializer.fromJson<int?>(json['rpe']),
      remark: serializer.fromJson<String?>(json['remark']),
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
      'sessionId': serializer.toJson<String>(sessionId),
      'playerId': serializer.toJson<String>(playerId),
      'present': serializer.toJson<bool>(present),
      'absenceReason': serializer.toJson<String?>(absenceReason),
      'durationMin': serializer.toJson<int?>(durationMin),
      'rpe': serializer.toJson<int?>(rpe),
      'remark': serializer.toJson<String?>(remark),
    };
  }

  SessionPlayer copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    Value<String?> serverUpdatedAt = const Value.absent(),
    bool? deleted,
    bool? isDirty,
    String? teamId,
    String? sessionId,
    String? playerId,
    bool? present,
    Value<String?> absenceReason = const Value.absent(),
    Value<int?> durationMin = const Value.absent(),
    Value<int?> rpe = const Value.absent(),
    Value<String?> remark = const Value.absent(),
  }) => SessionPlayer(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    deleted: deleted ?? this.deleted,
    isDirty: isDirty ?? this.isDirty,
    teamId: teamId ?? this.teamId,
    sessionId: sessionId ?? this.sessionId,
    playerId: playerId ?? this.playerId,
    present: present ?? this.present,
    absenceReason: absenceReason.present
        ? absenceReason.value
        : this.absenceReason,
    durationMin: durationMin.present ? durationMin.value : this.durationMin,
    rpe: rpe.present ? rpe.value : this.rpe,
    remark: remark.present ? remark.value : this.remark,
  );
  SessionPlayer copyWithCompanion(SessionPlayersCompanion data) {
    return SessionPlayer(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      present: data.present.present ? data.present.value : this.present,
      absenceReason: data.absenceReason.present
          ? data.absenceReason.value
          : this.absenceReason,
      durationMin: data.durationMin.present
          ? data.durationMin.value
          : this.durationMin,
      rpe: data.rpe.present ? data.rpe.value : this.rpe,
      remark: data.remark.present ? data.remark.value : this.remark,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionPlayer(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('teamId: $teamId, ')
          ..write('sessionId: $sessionId, ')
          ..write('playerId: $playerId, ')
          ..write('present: $present, ')
          ..write('absenceReason: $absenceReason, ')
          ..write('durationMin: $durationMin, ')
          ..write('rpe: $rpe, ')
          ..write('remark: $remark')
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
    sessionId,
    playerId,
    present,
    absenceReason,
    durationMin,
    rpe,
    remark,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionPlayer &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.deleted == this.deleted &&
          other.isDirty == this.isDirty &&
          other.teamId == this.teamId &&
          other.sessionId == this.sessionId &&
          other.playerId == this.playerId &&
          other.present == this.present &&
          other.absenceReason == this.absenceReason &&
          other.durationMin == this.durationMin &&
          other.rpe == this.rpe &&
          other.remark == this.remark);
}

class SessionPlayersCompanion extends UpdateCompanion<SessionPlayer> {
  final Value<String> id;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> serverUpdatedAt;
  final Value<bool> deleted;
  final Value<bool> isDirty;
  final Value<String> teamId;
  final Value<String> sessionId;
  final Value<String> playerId;
  final Value<bool> present;
  final Value<String?> absenceReason;
  final Value<int?> durationMin;
  final Value<int?> rpe;
  final Value<String?> remark;
  final Value<int> rowid;
  const SessionPlayersCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.teamId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.playerId = const Value.absent(),
    this.present = const Value.absent(),
    this.absenceReason = const Value.absent(),
    this.durationMin = const Value.absent(),
    this.rpe = const Value.absent(),
    this.remark = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionPlayersCompanion.insert({
    required String id,
    required String createdAt,
    required String updatedAt,
    this.serverUpdatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    required String teamId,
    required String sessionId,
    required String playerId,
    this.present = const Value.absent(),
    this.absenceReason = const Value.absent(),
    this.durationMin = const Value.absent(),
    this.rpe = const Value.absent(),
    this.remark = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       teamId = Value(teamId),
       sessionId = Value(sessionId),
       playerId = Value(playerId);
  static Insertable<SessionPlayer> custom({
    Expression<String>? id,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? serverUpdatedAt,
    Expression<bool>? deleted,
    Expression<bool>? isDirty,
    Expression<String>? teamId,
    Expression<String>? sessionId,
    Expression<String>? playerId,
    Expression<bool>? present,
    Expression<String>? absenceReason,
    Expression<int>? durationMin,
    Expression<int>? rpe,
    Expression<String>? remark,
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
      if (sessionId != null) 'session_id': sessionId,
      if (playerId != null) 'player_id': playerId,
      if (present != null) 'present': present,
      if (absenceReason != null) 'absence_reason': absenceReason,
      if (durationMin != null) 'duration_min': durationMin,
      if (rpe != null) 'rpe': rpe,
      if (remark != null) 'remark': remark,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionPlayersCompanion copyWith({
    Value<String>? id,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? serverUpdatedAt,
    Value<bool>? deleted,
    Value<bool>? isDirty,
    Value<String>? teamId,
    Value<String>? sessionId,
    Value<String>? playerId,
    Value<bool>? present,
    Value<String?>? absenceReason,
    Value<int?>? durationMin,
    Value<int?>? rpe,
    Value<String?>? remark,
    Value<int>? rowid,
  }) {
    return SessionPlayersCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      deleted: deleted ?? this.deleted,
      isDirty: isDirty ?? this.isDirty,
      teamId: teamId ?? this.teamId,
      sessionId: sessionId ?? this.sessionId,
      playerId: playerId ?? this.playerId,
      present: present ?? this.present,
      absenceReason: absenceReason ?? this.absenceReason,
      durationMin: durationMin ?? this.durationMin,
      rpe: rpe ?? this.rpe,
      remark: remark ?? this.remark,
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
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (playerId.present) {
      map['player_id'] = Variable<String>(playerId.value);
    }
    if (present.present) {
      map['present'] = Variable<bool>(present.value);
    }
    if (absenceReason.present) {
      map['absence_reason'] = Variable<String>(absenceReason.value);
    }
    if (durationMin.present) {
      map['duration_min'] = Variable<int>(durationMin.value);
    }
    if (rpe.present) {
      map['rpe'] = Variable<int>(rpe.value);
    }
    if (remark.present) {
      map['remark'] = Variable<String>(remark.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionPlayersCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('teamId: $teamId, ')
          ..write('sessionId: $sessionId, ')
          ..write('playerId: $playerId, ')
          ..write('present: $present, ')
          ..write('absenceReason: $absenceReason, ')
          ..write('durationMin: $durationMin, ')
          ..write('rpe: $rpe, ')
          ..write('remark: $remark, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WellnessTable extends Wellness
    with TableInfo<$WellnessTable, WellnessEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WellnessTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playerIdMeta = const VerificationMeta(
    'playerId',
  );
  @override
  late final GeneratedColumn<String> playerId = GeneratedColumn<String>(
    'player_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sleepHoursMeta = const VerificationMeta(
    'sleepHours',
  );
  @override
  late final GeneratedColumn<double> sleepHours = GeneratedColumn<double>(
    'sleep_hours',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sleepQualityMeta = const VerificationMeta(
    'sleepQuality',
  );
  @override
  late final GeneratedColumn<int> sleepQuality = GeneratedColumn<int>(
    'sleep_quality',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatigueMeta = const VerificationMeta(
    'fatigue',
  );
  @override
  late final GeneratedColumn<int> fatigue = GeneratedColumn<int>(
    'fatigue',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sorenessMeta = const VerificationMeta(
    'soreness',
  );
  @override
  late final GeneratedColumn<int> soreness = GeneratedColumn<int>(
    'soreness',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stressMeta = const VerificationMeta('stress');
  @override
  late final GeneratedColumn<int> stress = GeneratedColumn<int>(
    'stress',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<int> mood = GeneratedColumn<int>(
    'mood',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remarkMeta = const VerificationMeta('remark');
  @override
  late final GeneratedColumn<String> remark = GeneratedColumn<String>(
    'remark',
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
    sessionId,
    playerId,
    sleepHours,
    sleepQuality,
    fatigue,
    soreness,
    stress,
    mood,
    remark,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wellness';
  @override
  VerificationContext validateIntegrity(
    Insertable<WellnessEntry> instance, {
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
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('player_id')) {
      context.handle(
        _playerIdMeta,
        playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('sleep_hours')) {
      context.handle(
        _sleepHoursMeta,
        sleepHours.isAcceptableOrUnknown(data['sleep_hours']!, _sleepHoursMeta),
      );
    } else if (isInserting) {
      context.missing(_sleepHoursMeta);
    }
    if (data.containsKey('sleep_quality')) {
      context.handle(
        _sleepQualityMeta,
        sleepQuality.isAcceptableOrUnknown(
          data['sleep_quality']!,
          _sleepQualityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sleepQualityMeta);
    }
    if (data.containsKey('fatigue')) {
      context.handle(
        _fatigueMeta,
        fatigue.isAcceptableOrUnknown(data['fatigue']!, _fatigueMeta),
      );
    } else if (isInserting) {
      context.missing(_fatigueMeta);
    }
    if (data.containsKey('soreness')) {
      context.handle(
        _sorenessMeta,
        soreness.isAcceptableOrUnknown(data['soreness']!, _sorenessMeta),
      );
    } else if (isInserting) {
      context.missing(_sorenessMeta);
    }
    if (data.containsKey('stress')) {
      context.handle(
        _stressMeta,
        stress.isAcceptableOrUnknown(data['stress']!, _stressMeta),
      );
    } else if (isInserting) {
      context.missing(_stressMeta);
    }
    if (data.containsKey('mood')) {
      context.handle(
        _moodMeta,
        mood.isAcceptableOrUnknown(data['mood']!, _moodMeta),
      );
    } else if (isInserting) {
      context.missing(_moodMeta);
    }
    if (data.containsKey('remark')) {
      context.handle(
        _remarkMeta,
        remark.isAcceptableOrUnknown(data['remark']!, _remarkMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WellnessEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WellnessEntry(
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
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      playerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}player_id'],
      )!,
      sleepHours: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sleep_hours'],
      )!,
      sleepQuality: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sleep_quality'],
      )!,
      fatigue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fatigue'],
      )!,
      soreness: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}soreness'],
      )!,
      stress: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stress'],
      )!,
      mood: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mood'],
      )!,
      remark: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remark'],
      ),
    );
  }

  @override
  $WellnessTable createAlias(String alias) {
    return $WellnessTable(attachedDatabase, alias);
  }
}

class WellnessEntry extends DataClass implements Insertable<WellnessEntry> {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String? serverUpdatedAt;
  final bool deleted;

  /// Modifiée localement et pas encore envoyée. Jamais synchronisée.
  final bool isDirty;
  final String teamId;
  final String sessionId;
  final String playerId;
  final double sleepHours;
  final int sleepQuality;
  final int fatigue;
  final int soreness;
  final int stress;
  final int mood;
  final String? remark;
  const WellnessEntry({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.serverUpdatedAt,
    required this.deleted,
    required this.isDirty,
    required this.teamId,
    required this.sessionId,
    required this.playerId,
    required this.sleepHours,
    required this.sleepQuality,
    required this.fatigue,
    required this.soreness,
    required this.stress,
    required this.mood,
    this.remark,
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
    map['session_id'] = Variable<String>(sessionId);
    map['player_id'] = Variable<String>(playerId);
    map['sleep_hours'] = Variable<double>(sleepHours);
    map['sleep_quality'] = Variable<int>(sleepQuality);
    map['fatigue'] = Variable<int>(fatigue);
    map['soreness'] = Variable<int>(soreness);
    map['stress'] = Variable<int>(stress);
    map['mood'] = Variable<int>(mood);
    if (!nullToAbsent || remark != null) {
      map['remark'] = Variable<String>(remark);
    }
    return map;
  }

  WellnessCompanion toCompanion(bool nullToAbsent) {
    return WellnessCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      deleted: Value(deleted),
      isDirty: Value(isDirty),
      teamId: Value(teamId),
      sessionId: Value(sessionId),
      playerId: Value(playerId),
      sleepHours: Value(sleepHours),
      sleepQuality: Value(sleepQuality),
      fatigue: Value(fatigue),
      soreness: Value(soreness),
      stress: Value(stress),
      mood: Value(mood),
      remark: remark == null && nullToAbsent
          ? const Value.absent()
          : Value(remark),
    );
  }

  factory WellnessEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WellnessEntry(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      serverUpdatedAt: serializer.fromJson<String?>(json['serverUpdatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      teamId: serializer.fromJson<String>(json['teamId']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      playerId: serializer.fromJson<String>(json['playerId']),
      sleepHours: serializer.fromJson<double>(json['sleepHours']),
      sleepQuality: serializer.fromJson<int>(json['sleepQuality']),
      fatigue: serializer.fromJson<int>(json['fatigue']),
      soreness: serializer.fromJson<int>(json['soreness']),
      stress: serializer.fromJson<int>(json['stress']),
      mood: serializer.fromJson<int>(json['mood']),
      remark: serializer.fromJson<String?>(json['remark']),
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
      'sessionId': serializer.toJson<String>(sessionId),
      'playerId': serializer.toJson<String>(playerId),
      'sleepHours': serializer.toJson<double>(sleepHours),
      'sleepQuality': serializer.toJson<int>(sleepQuality),
      'fatigue': serializer.toJson<int>(fatigue),
      'soreness': serializer.toJson<int>(soreness),
      'stress': serializer.toJson<int>(stress),
      'mood': serializer.toJson<int>(mood),
      'remark': serializer.toJson<String?>(remark),
    };
  }

  WellnessEntry copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    Value<String?> serverUpdatedAt = const Value.absent(),
    bool? deleted,
    bool? isDirty,
    String? teamId,
    String? sessionId,
    String? playerId,
    double? sleepHours,
    int? sleepQuality,
    int? fatigue,
    int? soreness,
    int? stress,
    int? mood,
    Value<String?> remark = const Value.absent(),
  }) => WellnessEntry(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    deleted: deleted ?? this.deleted,
    isDirty: isDirty ?? this.isDirty,
    teamId: teamId ?? this.teamId,
    sessionId: sessionId ?? this.sessionId,
    playerId: playerId ?? this.playerId,
    sleepHours: sleepHours ?? this.sleepHours,
    sleepQuality: sleepQuality ?? this.sleepQuality,
    fatigue: fatigue ?? this.fatigue,
    soreness: soreness ?? this.soreness,
    stress: stress ?? this.stress,
    mood: mood ?? this.mood,
    remark: remark.present ? remark.value : this.remark,
  );
  WellnessEntry copyWithCompanion(WellnessCompanion data) {
    return WellnessEntry(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      sleepHours: data.sleepHours.present
          ? data.sleepHours.value
          : this.sleepHours,
      sleepQuality: data.sleepQuality.present
          ? data.sleepQuality.value
          : this.sleepQuality,
      fatigue: data.fatigue.present ? data.fatigue.value : this.fatigue,
      soreness: data.soreness.present ? data.soreness.value : this.soreness,
      stress: data.stress.present ? data.stress.value : this.stress,
      mood: data.mood.present ? data.mood.value : this.mood,
      remark: data.remark.present ? data.remark.value : this.remark,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WellnessEntry(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('teamId: $teamId, ')
          ..write('sessionId: $sessionId, ')
          ..write('playerId: $playerId, ')
          ..write('sleepHours: $sleepHours, ')
          ..write('sleepQuality: $sleepQuality, ')
          ..write('fatigue: $fatigue, ')
          ..write('soreness: $soreness, ')
          ..write('stress: $stress, ')
          ..write('mood: $mood, ')
          ..write('remark: $remark')
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
    sessionId,
    playerId,
    sleepHours,
    sleepQuality,
    fatigue,
    soreness,
    stress,
    mood,
    remark,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WellnessEntry &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.deleted == this.deleted &&
          other.isDirty == this.isDirty &&
          other.teamId == this.teamId &&
          other.sessionId == this.sessionId &&
          other.playerId == this.playerId &&
          other.sleepHours == this.sleepHours &&
          other.sleepQuality == this.sleepQuality &&
          other.fatigue == this.fatigue &&
          other.soreness == this.soreness &&
          other.stress == this.stress &&
          other.mood == this.mood &&
          other.remark == this.remark);
}

class WellnessCompanion extends UpdateCompanion<WellnessEntry> {
  final Value<String> id;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> serverUpdatedAt;
  final Value<bool> deleted;
  final Value<bool> isDirty;
  final Value<String> teamId;
  final Value<String> sessionId;
  final Value<String> playerId;
  final Value<double> sleepHours;
  final Value<int> sleepQuality;
  final Value<int> fatigue;
  final Value<int> soreness;
  final Value<int> stress;
  final Value<int> mood;
  final Value<String?> remark;
  final Value<int> rowid;
  const WellnessCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.teamId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.playerId = const Value.absent(),
    this.sleepHours = const Value.absent(),
    this.sleepQuality = const Value.absent(),
    this.fatigue = const Value.absent(),
    this.soreness = const Value.absent(),
    this.stress = const Value.absent(),
    this.mood = const Value.absent(),
    this.remark = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WellnessCompanion.insert({
    required String id,
    required String createdAt,
    required String updatedAt,
    this.serverUpdatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    required String teamId,
    required String sessionId,
    required String playerId,
    required double sleepHours,
    required int sleepQuality,
    required int fatigue,
    required int soreness,
    required int stress,
    required int mood,
    this.remark = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       teamId = Value(teamId),
       sessionId = Value(sessionId),
       playerId = Value(playerId),
       sleepHours = Value(sleepHours),
       sleepQuality = Value(sleepQuality),
       fatigue = Value(fatigue),
       soreness = Value(soreness),
       stress = Value(stress),
       mood = Value(mood);
  static Insertable<WellnessEntry> custom({
    Expression<String>? id,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? serverUpdatedAt,
    Expression<bool>? deleted,
    Expression<bool>? isDirty,
    Expression<String>? teamId,
    Expression<String>? sessionId,
    Expression<String>? playerId,
    Expression<double>? sleepHours,
    Expression<int>? sleepQuality,
    Expression<int>? fatigue,
    Expression<int>? soreness,
    Expression<int>? stress,
    Expression<int>? mood,
    Expression<String>? remark,
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
      if (sessionId != null) 'session_id': sessionId,
      if (playerId != null) 'player_id': playerId,
      if (sleepHours != null) 'sleep_hours': sleepHours,
      if (sleepQuality != null) 'sleep_quality': sleepQuality,
      if (fatigue != null) 'fatigue': fatigue,
      if (soreness != null) 'soreness': soreness,
      if (stress != null) 'stress': stress,
      if (mood != null) 'mood': mood,
      if (remark != null) 'remark': remark,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WellnessCompanion copyWith({
    Value<String>? id,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? serverUpdatedAt,
    Value<bool>? deleted,
    Value<bool>? isDirty,
    Value<String>? teamId,
    Value<String>? sessionId,
    Value<String>? playerId,
    Value<double>? sleepHours,
    Value<int>? sleepQuality,
    Value<int>? fatigue,
    Value<int>? soreness,
    Value<int>? stress,
    Value<int>? mood,
    Value<String?>? remark,
    Value<int>? rowid,
  }) {
    return WellnessCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      deleted: deleted ?? this.deleted,
      isDirty: isDirty ?? this.isDirty,
      teamId: teamId ?? this.teamId,
      sessionId: sessionId ?? this.sessionId,
      playerId: playerId ?? this.playerId,
      sleepHours: sleepHours ?? this.sleepHours,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      fatigue: fatigue ?? this.fatigue,
      soreness: soreness ?? this.soreness,
      stress: stress ?? this.stress,
      mood: mood ?? this.mood,
      remark: remark ?? this.remark,
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
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (playerId.present) {
      map['player_id'] = Variable<String>(playerId.value);
    }
    if (sleepHours.present) {
      map['sleep_hours'] = Variable<double>(sleepHours.value);
    }
    if (sleepQuality.present) {
      map['sleep_quality'] = Variable<int>(sleepQuality.value);
    }
    if (fatigue.present) {
      map['fatigue'] = Variable<int>(fatigue.value);
    }
    if (soreness.present) {
      map['soreness'] = Variable<int>(soreness.value);
    }
    if (stress.present) {
      map['stress'] = Variable<int>(stress.value);
    }
    if (mood.present) {
      map['mood'] = Variable<int>(mood.value);
    }
    if (remark.present) {
      map['remark'] = Variable<String>(remark.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WellnessCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('teamId: $teamId, ')
          ..write('sessionId: $sessionId, ')
          ..write('playerId: $playerId, ')
          ..write('sleepHours: $sleepHours, ')
          ..write('sleepQuality: $sleepQuality, ')
          ..write('fatigue: $fatigue, ')
          ..write('soreness: $soreness, ')
          ..write('stress: $stress, ')
          ..write('mood: $mood, ')
          ..write('remark: $remark, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MatchesTable extends Matches
    with TableInfo<$MatchesTable, FootballMatch> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MatchesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kickOffTimeMeta = const VerificationMeta(
    'kickOffTime',
  );
  @override
  late final GeneratedColumn<String> kickOffTime = GeneratedColumn<String>(
    'kick_off_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opponentMeta = const VerificationMeta(
    'opponent',
  );
  @override
  late final GeneratedColumn<String> opponent = GeneratedColumn<String>(
    'opponent',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _homeAwayMeta = const VerificationMeta(
    'homeAway',
  );
  @override
  late final GeneratedColumn<String> homeAway = GeneratedColumn<String>(
    'home_away',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _competitionMeta = const VerificationMeta(
    'competition',
  );
  @override
  late final GeneratedColumn<String> competition = GeneratedColumn<String>(
    'competition',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMinMeta = const VerificationMeta(
    'durationMin',
  );
  @override
  late final GeneratedColumn<int> durationMin = GeneratedColumn<int>(
    'duration_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(90),
  );
  static const VerificationMeta _goalsForMeta = const VerificationMeta(
    'goalsFor',
  );
  @override
  late final GeneratedColumn<int> goalsFor = GeneratedColumn<int>(
    'goals_for',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _goalsAgainstMeta = const VerificationMeta(
    'goalsAgainst',
  );
  @override
  late final GeneratedColumn<int> goalsAgainst = GeneratedColumn<int>(
    'goals_against',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remarksMeta = const VerificationMeta(
    'remarks',
  );
  @override
  late final GeneratedColumn<String> remarks = GeneratedColumn<String>(
    'remarks',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('planned'),
  );
  static const VerificationMeta _phaseMeta = const VerificationMeta('phase');
  @override
  late final GeneratedColumn<String> phase = GeneratedColumn<String>(
    'phase',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _matchdayMeta = const VerificationMeta(
    'matchday',
  );
  @override
  late final GeneratedColumn<int> matchday = GeneratedColumn<int>(
    'matchday',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
    date,
    kickOffTime,
    opponent,
    homeAway,
    competition,
    durationMin,
    goalsFor,
    goalsAgainst,
    remarks,
    status,
    phase,
    matchday,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'matches';
  @override
  VerificationContext validateIntegrity(
    Insertable<FootballMatch> instance, {
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
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('kick_off_time')) {
      context.handle(
        _kickOffTimeMeta,
        kickOffTime.isAcceptableOrUnknown(
          data['kick_off_time']!,
          _kickOffTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_kickOffTimeMeta);
    }
    if (data.containsKey('opponent')) {
      context.handle(
        _opponentMeta,
        opponent.isAcceptableOrUnknown(data['opponent']!, _opponentMeta),
      );
    } else if (isInserting) {
      context.missing(_opponentMeta);
    }
    if (data.containsKey('home_away')) {
      context.handle(
        _homeAwayMeta,
        homeAway.isAcceptableOrUnknown(data['home_away']!, _homeAwayMeta),
      );
    } else if (isInserting) {
      context.missing(_homeAwayMeta);
    }
    if (data.containsKey('competition')) {
      context.handle(
        _competitionMeta,
        competition.isAcceptableOrUnknown(
          data['competition']!,
          _competitionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_competitionMeta);
    }
    if (data.containsKey('duration_min')) {
      context.handle(
        _durationMinMeta,
        durationMin.isAcceptableOrUnknown(
          data['duration_min']!,
          _durationMinMeta,
        ),
      );
    }
    if (data.containsKey('goals_for')) {
      context.handle(
        _goalsForMeta,
        goalsFor.isAcceptableOrUnknown(data['goals_for']!, _goalsForMeta),
      );
    }
    if (data.containsKey('goals_against')) {
      context.handle(
        _goalsAgainstMeta,
        goalsAgainst.isAcceptableOrUnknown(
          data['goals_against']!,
          _goalsAgainstMeta,
        ),
      );
    }
    if (data.containsKey('remarks')) {
      context.handle(
        _remarksMeta,
        remarks.isAcceptableOrUnknown(data['remarks']!, _remarksMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('phase')) {
      context.handle(
        _phaseMeta,
        phase.isAcceptableOrUnknown(data['phase']!, _phaseMeta),
      );
    }
    if (data.containsKey('matchday')) {
      context.handle(
        _matchdayMeta,
        matchday.isAcceptableOrUnknown(data['matchday']!, _matchdayMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FootballMatch map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FootballMatch(
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
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      kickOffTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kick_off_time'],
      )!,
      opponent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}opponent'],
      )!,
      homeAway: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}home_away'],
      )!,
      competition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}competition'],
      )!,
      durationMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_min'],
      )!,
      goalsFor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}goals_for'],
      ),
      goalsAgainst: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}goals_against'],
      ),
      remarks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remarks'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      phase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phase'],
      ),
      matchday: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}matchday'],
      ),
    );
  }

  @override
  $MatchesTable createAlias(String alias) {
    return $MatchesTable(attachedDatabase, alias);
  }
}

class FootballMatch extends DataClass implements Insertable<FootballMatch> {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String? serverUpdatedAt;
  final bool deleted;

  /// Modifiée localement et pas encore envoyée. Jamais synchronisée.
  final bool isDirty;
  final String teamId;
  final String date;
  final String kickOffTime;
  final String opponent;
  final String homeAway;
  final String competition;
  final int durationMin;
  final int? goalsFor;
  final int? goalsAgainst;
  final String? remarks;
  final String status;

  /// Phase de championnat (first_leg / second_leg) et numéro de journée.
  final String? phase;
  final int? matchday;
  const FootballMatch({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.serverUpdatedAt,
    required this.deleted,
    required this.isDirty,
    required this.teamId,
    required this.date,
    required this.kickOffTime,
    required this.opponent,
    required this.homeAway,
    required this.competition,
    required this.durationMin,
    this.goalsFor,
    this.goalsAgainst,
    this.remarks,
    required this.status,
    this.phase,
    this.matchday,
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
    map['date'] = Variable<String>(date);
    map['kick_off_time'] = Variable<String>(kickOffTime);
    map['opponent'] = Variable<String>(opponent);
    map['home_away'] = Variable<String>(homeAway);
    map['competition'] = Variable<String>(competition);
    map['duration_min'] = Variable<int>(durationMin);
    if (!nullToAbsent || goalsFor != null) {
      map['goals_for'] = Variable<int>(goalsFor);
    }
    if (!nullToAbsent || goalsAgainst != null) {
      map['goals_against'] = Variable<int>(goalsAgainst);
    }
    if (!nullToAbsent || remarks != null) {
      map['remarks'] = Variable<String>(remarks);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || phase != null) {
      map['phase'] = Variable<String>(phase);
    }
    if (!nullToAbsent || matchday != null) {
      map['matchday'] = Variable<int>(matchday);
    }
    return map;
  }

  MatchesCompanion toCompanion(bool nullToAbsent) {
    return MatchesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      deleted: Value(deleted),
      isDirty: Value(isDirty),
      teamId: Value(teamId),
      date: Value(date),
      kickOffTime: Value(kickOffTime),
      opponent: Value(opponent),
      homeAway: Value(homeAway),
      competition: Value(competition),
      durationMin: Value(durationMin),
      goalsFor: goalsFor == null && nullToAbsent
          ? const Value.absent()
          : Value(goalsFor),
      goalsAgainst: goalsAgainst == null && nullToAbsent
          ? const Value.absent()
          : Value(goalsAgainst),
      remarks: remarks == null && nullToAbsent
          ? const Value.absent()
          : Value(remarks),
      status: Value(status),
      phase: phase == null && nullToAbsent
          ? const Value.absent()
          : Value(phase),
      matchday: matchday == null && nullToAbsent
          ? const Value.absent()
          : Value(matchday),
    );
  }

  factory FootballMatch.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FootballMatch(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      serverUpdatedAt: serializer.fromJson<String?>(json['serverUpdatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      teamId: serializer.fromJson<String>(json['teamId']),
      date: serializer.fromJson<String>(json['date']),
      kickOffTime: serializer.fromJson<String>(json['kickOffTime']),
      opponent: serializer.fromJson<String>(json['opponent']),
      homeAway: serializer.fromJson<String>(json['homeAway']),
      competition: serializer.fromJson<String>(json['competition']),
      durationMin: serializer.fromJson<int>(json['durationMin']),
      goalsFor: serializer.fromJson<int?>(json['goalsFor']),
      goalsAgainst: serializer.fromJson<int?>(json['goalsAgainst']),
      remarks: serializer.fromJson<String?>(json['remarks']),
      status: serializer.fromJson<String>(json['status']),
      phase: serializer.fromJson<String?>(json['phase']),
      matchday: serializer.fromJson<int?>(json['matchday']),
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
      'date': serializer.toJson<String>(date),
      'kickOffTime': serializer.toJson<String>(kickOffTime),
      'opponent': serializer.toJson<String>(opponent),
      'homeAway': serializer.toJson<String>(homeAway),
      'competition': serializer.toJson<String>(competition),
      'durationMin': serializer.toJson<int>(durationMin),
      'goalsFor': serializer.toJson<int?>(goalsFor),
      'goalsAgainst': serializer.toJson<int?>(goalsAgainst),
      'remarks': serializer.toJson<String?>(remarks),
      'status': serializer.toJson<String>(status),
      'phase': serializer.toJson<String?>(phase),
      'matchday': serializer.toJson<int?>(matchday),
    };
  }

  FootballMatch copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    Value<String?> serverUpdatedAt = const Value.absent(),
    bool? deleted,
    bool? isDirty,
    String? teamId,
    String? date,
    String? kickOffTime,
    String? opponent,
    String? homeAway,
    String? competition,
    int? durationMin,
    Value<int?> goalsFor = const Value.absent(),
    Value<int?> goalsAgainst = const Value.absent(),
    Value<String?> remarks = const Value.absent(),
    String? status,
    Value<String?> phase = const Value.absent(),
    Value<int?> matchday = const Value.absent(),
  }) => FootballMatch(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    deleted: deleted ?? this.deleted,
    isDirty: isDirty ?? this.isDirty,
    teamId: teamId ?? this.teamId,
    date: date ?? this.date,
    kickOffTime: kickOffTime ?? this.kickOffTime,
    opponent: opponent ?? this.opponent,
    homeAway: homeAway ?? this.homeAway,
    competition: competition ?? this.competition,
    durationMin: durationMin ?? this.durationMin,
    goalsFor: goalsFor.present ? goalsFor.value : this.goalsFor,
    goalsAgainst: goalsAgainst.present ? goalsAgainst.value : this.goalsAgainst,
    remarks: remarks.present ? remarks.value : this.remarks,
    status: status ?? this.status,
    phase: phase.present ? phase.value : this.phase,
    matchday: matchday.present ? matchday.value : this.matchday,
  );
  FootballMatch copyWithCompanion(MatchesCompanion data) {
    return FootballMatch(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      date: data.date.present ? data.date.value : this.date,
      kickOffTime: data.kickOffTime.present
          ? data.kickOffTime.value
          : this.kickOffTime,
      opponent: data.opponent.present ? data.opponent.value : this.opponent,
      homeAway: data.homeAway.present ? data.homeAway.value : this.homeAway,
      competition: data.competition.present
          ? data.competition.value
          : this.competition,
      durationMin: data.durationMin.present
          ? data.durationMin.value
          : this.durationMin,
      goalsFor: data.goalsFor.present ? data.goalsFor.value : this.goalsFor,
      goalsAgainst: data.goalsAgainst.present
          ? data.goalsAgainst.value
          : this.goalsAgainst,
      remarks: data.remarks.present ? data.remarks.value : this.remarks,
      status: data.status.present ? data.status.value : this.status,
      phase: data.phase.present ? data.phase.value : this.phase,
      matchday: data.matchday.present ? data.matchday.value : this.matchday,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FootballMatch(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('teamId: $teamId, ')
          ..write('date: $date, ')
          ..write('kickOffTime: $kickOffTime, ')
          ..write('opponent: $opponent, ')
          ..write('homeAway: $homeAway, ')
          ..write('competition: $competition, ')
          ..write('durationMin: $durationMin, ')
          ..write('goalsFor: $goalsFor, ')
          ..write('goalsAgainst: $goalsAgainst, ')
          ..write('remarks: $remarks, ')
          ..write('status: $status, ')
          ..write('phase: $phase, ')
          ..write('matchday: $matchday')
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
    date,
    kickOffTime,
    opponent,
    homeAway,
    competition,
    durationMin,
    goalsFor,
    goalsAgainst,
    remarks,
    status,
    phase,
    matchday,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FootballMatch &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.deleted == this.deleted &&
          other.isDirty == this.isDirty &&
          other.teamId == this.teamId &&
          other.date == this.date &&
          other.kickOffTime == this.kickOffTime &&
          other.opponent == this.opponent &&
          other.homeAway == this.homeAway &&
          other.competition == this.competition &&
          other.durationMin == this.durationMin &&
          other.goalsFor == this.goalsFor &&
          other.goalsAgainst == this.goalsAgainst &&
          other.remarks == this.remarks &&
          other.status == this.status &&
          other.phase == this.phase &&
          other.matchday == this.matchday);
}

class MatchesCompanion extends UpdateCompanion<FootballMatch> {
  final Value<String> id;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> serverUpdatedAt;
  final Value<bool> deleted;
  final Value<bool> isDirty;
  final Value<String> teamId;
  final Value<String> date;
  final Value<String> kickOffTime;
  final Value<String> opponent;
  final Value<String> homeAway;
  final Value<String> competition;
  final Value<int> durationMin;
  final Value<int?> goalsFor;
  final Value<int?> goalsAgainst;
  final Value<String?> remarks;
  final Value<String> status;
  final Value<String?> phase;
  final Value<int?> matchday;
  final Value<int> rowid;
  const MatchesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.teamId = const Value.absent(),
    this.date = const Value.absent(),
    this.kickOffTime = const Value.absent(),
    this.opponent = const Value.absent(),
    this.homeAway = const Value.absent(),
    this.competition = const Value.absent(),
    this.durationMin = const Value.absent(),
    this.goalsFor = const Value.absent(),
    this.goalsAgainst = const Value.absent(),
    this.remarks = const Value.absent(),
    this.status = const Value.absent(),
    this.phase = const Value.absent(),
    this.matchday = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MatchesCompanion.insert({
    required String id,
    required String createdAt,
    required String updatedAt,
    this.serverUpdatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    required String teamId,
    required String date,
    required String kickOffTime,
    required String opponent,
    required String homeAway,
    required String competition,
    this.durationMin = const Value.absent(),
    this.goalsFor = const Value.absent(),
    this.goalsAgainst = const Value.absent(),
    this.remarks = const Value.absent(),
    this.status = const Value.absent(),
    this.phase = const Value.absent(),
    this.matchday = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       teamId = Value(teamId),
       date = Value(date),
       kickOffTime = Value(kickOffTime),
       opponent = Value(opponent),
       homeAway = Value(homeAway),
       competition = Value(competition);
  static Insertable<FootballMatch> custom({
    Expression<String>? id,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? serverUpdatedAt,
    Expression<bool>? deleted,
    Expression<bool>? isDirty,
    Expression<String>? teamId,
    Expression<String>? date,
    Expression<String>? kickOffTime,
    Expression<String>? opponent,
    Expression<String>? homeAway,
    Expression<String>? competition,
    Expression<int>? durationMin,
    Expression<int>? goalsFor,
    Expression<int>? goalsAgainst,
    Expression<String>? remarks,
    Expression<String>? status,
    Expression<String>? phase,
    Expression<int>? matchday,
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
      if (date != null) 'date': date,
      if (kickOffTime != null) 'kick_off_time': kickOffTime,
      if (opponent != null) 'opponent': opponent,
      if (homeAway != null) 'home_away': homeAway,
      if (competition != null) 'competition': competition,
      if (durationMin != null) 'duration_min': durationMin,
      if (goalsFor != null) 'goals_for': goalsFor,
      if (goalsAgainst != null) 'goals_against': goalsAgainst,
      if (remarks != null) 'remarks': remarks,
      if (status != null) 'status': status,
      if (phase != null) 'phase': phase,
      if (matchday != null) 'matchday': matchday,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MatchesCompanion copyWith({
    Value<String>? id,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? serverUpdatedAt,
    Value<bool>? deleted,
    Value<bool>? isDirty,
    Value<String>? teamId,
    Value<String>? date,
    Value<String>? kickOffTime,
    Value<String>? opponent,
    Value<String>? homeAway,
    Value<String>? competition,
    Value<int>? durationMin,
    Value<int?>? goalsFor,
    Value<int?>? goalsAgainst,
    Value<String?>? remarks,
    Value<String>? status,
    Value<String?>? phase,
    Value<int?>? matchday,
    Value<int>? rowid,
  }) {
    return MatchesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      deleted: deleted ?? this.deleted,
      isDirty: isDirty ?? this.isDirty,
      teamId: teamId ?? this.teamId,
      date: date ?? this.date,
      kickOffTime: kickOffTime ?? this.kickOffTime,
      opponent: opponent ?? this.opponent,
      homeAway: homeAway ?? this.homeAway,
      competition: competition ?? this.competition,
      durationMin: durationMin ?? this.durationMin,
      goalsFor: goalsFor ?? this.goalsFor,
      goalsAgainst: goalsAgainst ?? this.goalsAgainst,
      remarks: remarks ?? this.remarks,
      status: status ?? this.status,
      phase: phase ?? this.phase,
      matchday: matchday ?? this.matchday,
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
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (kickOffTime.present) {
      map['kick_off_time'] = Variable<String>(kickOffTime.value);
    }
    if (opponent.present) {
      map['opponent'] = Variable<String>(opponent.value);
    }
    if (homeAway.present) {
      map['home_away'] = Variable<String>(homeAway.value);
    }
    if (competition.present) {
      map['competition'] = Variable<String>(competition.value);
    }
    if (durationMin.present) {
      map['duration_min'] = Variable<int>(durationMin.value);
    }
    if (goalsFor.present) {
      map['goals_for'] = Variable<int>(goalsFor.value);
    }
    if (goalsAgainst.present) {
      map['goals_against'] = Variable<int>(goalsAgainst.value);
    }
    if (remarks.present) {
      map['remarks'] = Variable<String>(remarks.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (phase.present) {
      map['phase'] = Variable<String>(phase.value);
    }
    if (matchday.present) {
      map['matchday'] = Variable<int>(matchday.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MatchesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('teamId: $teamId, ')
          ..write('date: $date, ')
          ..write('kickOffTime: $kickOffTime, ')
          ..write('opponent: $opponent, ')
          ..write('homeAway: $homeAway, ')
          ..write('competition: $competition, ')
          ..write('durationMin: $durationMin, ')
          ..write('goalsFor: $goalsFor, ')
          ..write('goalsAgainst: $goalsAgainst, ')
          ..write('remarks: $remarks, ')
          ..write('status: $status, ')
          ..write('phase: $phase, ')
          ..write('matchday: $matchday, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MatchPlayersTable extends MatchPlayers
    with TableInfo<$MatchPlayersTable, MatchPlayer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MatchPlayersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _matchIdMeta = const VerificationMeta(
    'matchId',
  );
  @override
  late final GeneratedColumn<String> matchId = GeneratedColumn<String>(
    'match_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playerIdMeta = const VerificationMeta(
    'playerId',
  );
  @override
  late final GeneratedColumn<String> playerId = GeneratedColumn<String>(
    'player_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _presentMeta = const VerificationMeta(
    'present',
  );
  @override
  late final GeneratedColumn<bool> present = GeneratedColumn<bool>(
    'present',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("present" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _absenceReasonMeta = const VerificationMeta(
    'absenceReason',
  );
  @override
  late final GeneratedColumn<String> absenceReason = GeneratedColumn<String>(
    'absence_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minutesPlayedMeta = const VerificationMeta(
    'minutesPlayed',
  );
  @override
  late final GeneratedColumn<int> minutesPlayed = GeneratedColumn<int>(
    'minutes_played',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rpeMeta = const VerificationMeta('rpe');
  @override
  late final GeneratedColumn<int> rpe = GeneratedColumn<int>(
    'rpe',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remarkMeta = const VerificationMeta('remark');
  @override
  late final GeneratedColumn<String> remark = GeneratedColumn<String>(
    'remark',
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
    matchId,
    playerId,
    present,
    absenceReason,
    role,
    minutesPlayed,
    rpe,
    remark,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'match_players';
  @override
  VerificationContext validateIntegrity(
    Insertable<MatchPlayer> instance, {
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
    if (data.containsKey('match_id')) {
      context.handle(
        _matchIdMeta,
        matchId.isAcceptableOrUnknown(data['match_id']!, _matchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_matchIdMeta);
    }
    if (data.containsKey('player_id')) {
      context.handle(
        _playerIdMeta,
        playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('present')) {
      context.handle(
        _presentMeta,
        present.isAcceptableOrUnknown(data['present']!, _presentMeta),
      );
    }
    if (data.containsKey('absence_reason')) {
      context.handle(
        _absenceReasonMeta,
        absenceReason.isAcceptableOrUnknown(
          data['absence_reason']!,
          _absenceReasonMeta,
        ),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('minutes_played')) {
      context.handle(
        _minutesPlayedMeta,
        minutesPlayed.isAcceptableOrUnknown(
          data['minutes_played']!,
          _minutesPlayedMeta,
        ),
      );
    }
    if (data.containsKey('rpe')) {
      context.handle(
        _rpeMeta,
        rpe.isAcceptableOrUnknown(data['rpe']!, _rpeMeta),
      );
    }
    if (data.containsKey('remark')) {
      context.handle(
        _remarkMeta,
        remark.isAcceptableOrUnknown(data['remark']!, _remarkMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MatchPlayer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MatchPlayer(
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
      matchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}match_id'],
      )!,
      playerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}player_id'],
      )!,
      present: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}present'],
      )!,
      absenceReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}absence_reason'],
      ),
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      ),
      minutesPlayed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minutes_played'],
      ),
      rpe: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rpe'],
      ),
      remark: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remark'],
      ),
    );
  }

  @override
  $MatchPlayersTable createAlias(String alias) {
    return $MatchPlayersTable(attachedDatabase, alias);
  }
}

class MatchPlayer extends DataClass implements Insertable<MatchPlayer> {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String? serverUpdatedAt;
  final bool deleted;

  /// Modifiée localement et pas encore envoyée. Jamais synchronisée.
  final bool isDirty;
  final String teamId;
  final String matchId;
  final String playerId;
  final bool present;
  final String? absenceReason;
  final String? role;
  final int? minutesPlayed;
  final int? rpe;
  final String? remark;
  const MatchPlayer({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.serverUpdatedAt,
    required this.deleted,
    required this.isDirty,
    required this.teamId,
    required this.matchId,
    required this.playerId,
    required this.present,
    this.absenceReason,
    this.role,
    this.minutesPlayed,
    this.rpe,
    this.remark,
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
    map['match_id'] = Variable<String>(matchId);
    map['player_id'] = Variable<String>(playerId);
    map['present'] = Variable<bool>(present);
    if (!nullToAbsent || absenceReason != null) {
      map['absence_reason'] = Variable<String>(absenceReason);
    }
    if (!nullToAbsent || role != null) {
      map['role'] = Variable<String>(role);
    }
    if (!nullToAbsent || minutesPlayed != null) {
      map['minutes_played'] = Variable<int>(minutesPlayed);
    }
    if (!nullToAbsent || rpe != null) {
      map['rpe'] = Variable<int>(rpe);
    }
    if (!nullToAbsent || remark != null) {
      map['remark'] = Variable<String>(remark);
    }
    return map;
  }

  MatchPlayersCompanion toCompanion(bool nullToAbsent) {
    return MatchPlayersCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      deleted: Value(deleted),
      isDirty: Value(isDirty),
      teamId: Value(teamId),
      matchId: Value(matchId),
      playerId: Value(playerId),
      present: Value(present),
      absenceReason: absenceReason == null && nullToAbsent
          ? const Value.absent()
          : Value(absenceReason),
      role: role == null && nullToAbsent ? const Value.absent() : Value(role),
      minutesPlayed: minutesPlayed == null && nullToAbsent
          ? const Value.absent()
          : Value(minutesPlayed),
      rpe: rpe == null && nullToAbsent ? const Value.absent() : Value(rpe),
      remark: remark == null && nullToAbsent
          ? const Value.absent()
          : Value(remark),
    );
  }

  factory MatchPlayer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MatchPlayer(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      serverUpdatedAt: serializer.fromJson<String?>(json['serverUpdatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      teamId: serializer.fromJson<String>(json['teamId']),
      matchId: serializer.fromJson<String>(json['matchId']),
      playerId: serializer.fromJson<String>(json['playerId']),
      present: serializer.fromJson<bool>(json['present']),
      absenceReason: serializer.fromJson<String?>(json['absenceReason']),
      role: serializer.fromJson<String?>(json['role']),
      minutesPlayed: serializer.fromJson<int?>(json['minutesPlayed']),
      rpe: serializer.fromJson<int?>(json['rpe']),
      remark: serializer.fromJson<String?>(json['remark']),
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
      'matchId': serializer.toJson<String>(matchId),
      'playerId': serializer.toJson<String>(playerId),
      'present': serializer.toJson<bool>(present),
      'absenceReason': serializer.toJson<String?>(absenceReason),
      'role': serializer.toJson<String?>(role),
      'minutesPlayed': serializer.toJson<int?>(minutesPlayed),
      'rpe': serializer.toJson<int?>(rpe),
      'remark': serializer.toJson<String?>(remark),
    };
  }

  MatchPlayer copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    Value<String?> serverUpdatedAt = const Value.absent(),
    bool? deleted,
    bool? isDirty,
    String? teamId,
    String? matchId,
    String? playerId,
    bool? present,
    Value<String?> absenceReason = const Value.absent(),
    Value<String?> role = const Value.absent(),
    Value<int?> minutesPlayed = const Value.absent(),
    Value<int?> rpe = const Value.absent(),
    Value<String?> remark = const Value.absent(),
  }) => MatchPlayer(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    deleted: deleted ?? this.deleted,
    isDirty: isDirty ?? this.isDirty,
    teamId: teamId ?? this.teamId,
    matchId: matchId ?? this.matchId,
    playerId: playerId ?? this.playerId,
    present: present ?? this.present,
    absenceReason: absenceReason.present
        ? absenceReason.value
        : this.absenceReason,
    role: role.present ? role.value : this.role,
    minutesPlayed: minutesPlayed.present
        ? minutesPlayed.value
        : this.minutesPlayed,
    rpe: rpe.present ? rpe.value : this.rpe,
    remark: remark.present ? remark.value : this.remark,
  );
  MatchPlayer copyWithCompanion(MatchPlayersCompanion data) {
    return MatchPlayer(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      matchId: data.matchId.present ? data.matchId.value : this.matchId,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      present: data.present.present ? data.present.value : this.present,
      absenceReason: data.absenceReason.present
          ? data.absenceReason.value
          : this.absenceReason,
      role: data.role.present ? data.role.value : this.role,
      minutesPlayed: data.minutesPlayed.present
          ? data.minutesPlayed.value
          : this.minutesPlayed,
      rpe: data.rpe.present ? data.rpe.value : this.rpe,
      remark: data.remark.present ? data.remark.value : this.remark,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MatchPlayer(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('teamId: $teamId, ')
          ..write('matchId: $matchId, ')
          ..write('playerId: $playerId, ')
          ..write('present: $present, ')
          ..write('absenceReason: $absenceReason, ')
          ..write('role: $role, ')
          ..write('minutesPlayed: $minutesPlayed, ')
          ..write('rpe: $rpe, ')
          ..write('remark: $remark')
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
    matchId,
    playerId,
    present,
    absenceReason,
    role,
    minutesPlayed,
    rpe,
    remark,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MatchPlayer &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.deleted == this.deleted &&
          other.isDirty == this.isDirty &&
          other.teamId == this.teamId &&
          other.matchId == this.matchId &&
          other.playerId == this.playerId &&
          other.present == this.present &&
          other.absenceReason == this.absenceReason &&
          other.role == this.role &&
          other.minutesPlayed == this.minutesPlayed &&
          other.rpe == this.rpe &&
          other.remark == this.remark);
}

class MatchPlayersCompanion extends UpdateCompanion<MatchPlayer> {
  final Value<String> id;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> serverUpdatedAt;
  final Value<bool> deleted;
  final Value<bool> isDirty;
  final Value<String> teamId;
  final Value<String> matchId;
  final Value<String> playerId;
  final Value<bool> present;
  final Value<String?> absenceReason;
  final Value<String?> role;
  final Value<int?> minutesPlayed;
  final Value<int?> rpe;
  final Value<String?> remark;
  final Value<int> rowid;
  const MatchPlayersCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.teamId = const Value.absent(),
    this.matchId = const Value.absent(),
    this.playerId = const Value.absent(),
    this.present = const Value.absent(),
    this.absenceReason = const Value.absent(),
    this.role = const Value.absent(),
    this.minutesPlayed = const Value.absent(),
    this.rpe = const Value.absent(),
    this.remark = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MatchPlayersCompanion.insert({
    required String id,
    required String createdAt,
    required String updatedAt,
    this.serverUpdatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    required String teamId,
    required String matchId,
    required String playerId,
    this.present = const Value.absent(),
    this.absenceReason = const Value.absent(),
    this.role = const Value.absent(),
    this.minutesPlayed = const Value.absent(),
    this.rpe = const Value.absent(),
    this.remark = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       teamId = Value(teamId),
       matchId = Value(matchId),
       playerId = Value(playerId);
  static Insertable<MatchPlayer> custom({
    Expression<String>? id,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? serverUpdatedAt,
    Expression<bool>? deleted,
    Expression<bool>? isDirty,
    Expression<String>? teamId,
    Expression<String>? matchId,
    Expression<String>? playerId,
    Expression<bool>? present,
    Expression<String>? absenceReason,
    Expression<String>? role,
    Expression<int>? minutesPlayed,
    Expression<int>? rpe,
    Expression<String>? remark,
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
      if (matchId != null) 'match_id': matchId,
      if (playerId != null) 'player_id': playerId,
      if (present != null) 'present': present,
      if (absenceReason != null) 'absence_reason': absenceReason,
      if (role != null) 'role': role,
      if (minutesPlayed != null) 'minutes_played': minutesPlayed,
      if (rpe != null) 'rpe': rpe,
      if (remark != null) 'remark': remark,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MatchPlayersCompanion copyWith({
    Value<String>? id,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? serverUpdatedAt,
    Value<bool>? deleted,
    Value<bool>? isDirty,
    Value<String>? teamId,
    Value<String>? matchId,
    Value<String>? playerId,
    Value<bool>? present,
    Value<String?>? absenceReason,
    Value<String?>? role,
    Value<int?>? minutesPlayed,
    Value<int?>? rpe,
    Value<String?>? remark,
    Value<int>? rowid,
  }) {
    return MatchPlayersCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      deleted: deleted ?? this.deleted,
      isDirty: isDirty ?? this.isDirty,
      teamId: teamId ?? this.teamId,
      matchId: matchId ?? this.matchId,
      playerId: playerId ?? this.playerId,
      present: present ?? this.present,
      absenceReason: absenceReason ?? this.absenceReason,
      role: role ?? this.role,
      minutesPlayed: minutesPlayed ?? this.minutesPlayed,
      rpe: rpe ?? this.rpe,
      remark: remark ?? this.remark,
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
    if (matchId.present) {
      map['match_id'] = Variable<String>(matchId.value);
    }
    if (playerId.present) {
      map['player_id'] = Variable<String>(playerId.value);
    }
    if (present.present) {
      map['present'] = Variable<bool>(present.value);
    }
    if (absenceReason.present) {
      map['absence_reason'] = Variable<String>(absenceReason.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (minutesPlayed.present) {
      map['minutes_played'] = Variable<int>(minutesPlayed.value);
    }
    if (rpe.present) {
      map['rpe'] = Variable<int>(rpe.value);
    }
    if (remark.present) {
      map['remark'] = Variable<String>(remark.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MatchPlayersCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('teamId: $teamId, ')
          ..write('matchId: $matchId, ')
          ..write('playerId: $playerId, ')
          ..write('present: $present, ')
          ..write('absenceReason: $absenceReason, ')
          ..write('role: $role, ')
          ..write('minutesPlayed: $minutesPlayed, ')
          ..write('rpe: $rpe, ')
          ..write('remark: $remark, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MatchEventsTable extends MatchEvents
    with TableInfo<$MatchEventsTable, MatchEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MatchEventsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _matchIdMeta = const VerificationMeta(
    'matchId',
  );
  @override
  late final GeneratedColumn<String> matchId = GeneratedColumn<String>(
    'match_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playerIdMeta = const VerificationMeta(
    'playerId',
  );
  @override
  late final GeneratedColumn<String> playerId = GeneratedColumn<String>(
    'player_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minuteMeta = const VerificationMeta('minute');
  @override
  late final GeneratedColumn<int> minute = GeneratedColumn<int>(
    'minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assistPlayerIdMeta = const VerificationMeta(
    'assistPlayerId',
  );
  @override
  late final GeneratedColumn<String> assistPlayerId = GeneratedColumn<String>(
    'assist_player_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remarkMeta = const VerificationMeta('remark');
  @override
  late final GeneratedColumn<String> remark = GeneratedColumn<String>(
    'remark',
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
    matchId,
    playerId,
    type,
    minute,
    assistPlayerId,
    remark,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'match_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<MatchEvent> instance, {
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
    if (data.containsKey('match_id')) {
      context.handle(
        _matchIdMeta,
        matchId.isAcceptableOrUnknown(data['match_id']!, _matchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_matchIdMeta);
    }
    if (data.containsKey('player_id')) {
      context.handle(
        _playerIdMeta,
        playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('minute')) {
      context.handle(
        _minuteMeta,
        minute.isAcceptableOrUnknown(data['minute']!, _minuteMeta),
      );
    } else if (isInserting) {
      context.missing(_minuteMeta);
    }
    if (data.containsKey('assist_player_id')) {
      context.handle(
        _assistPlayerIdMeta,
        assistPlayerId.isAcceptableOrUnknown(
          data['assist_player_id']!,
          _assistPlayerIdMeta,
        ),
      );
    }
    if (data.containsKey('remark')) {
      context.handle(
        _remarkMeta,
        remark.isAcceptableOrUnknown(data['remark']!, _remarkMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MatchEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MatchEvent(
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
      matchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}match_id'],
      )!,
      playerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}player_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      minute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minute'],
      )!,
      assistPlayerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assist_player_id'],
      ),
      remark: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remark'],
      ),
    );
  }

  @override
  $MatchEventsTable createAlias(String alias) {
    return $MatchEventsTable(attachedDatabase, alias);
  }
}

class MatchEvent extends DataClass implements Insertable<MatchEvent> {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String? serverUpdatedAt;
  final bool deleted;

  /// Modifiée localement et pas encore envoyée. Jamais synchronisée.
  final bool isDirty;
  final String teamId;
  final String matchId;
  final String playerId;
  final String type;
  final int minute;
  final String? assistPlayerId;
  final String? remark;
  const MatchEvent({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.serverUpdatedAt,
    required this.deleted,
    required this.isDirty,
    required this.teamId,
    required this.matchId,
    required this.playerId,
    required this.type,
    required this.minute,
    this.assistPlayerId,
    this.remark,
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
    map['match_id'] = Variable<String>(matchId);
    map['player_id'] = Variable<String>(playerId);
    map['type'] = Variable<String>(type);
    map['minute'] = Variable<int>(minute);
    if (!nullToAbsent || assistPlayerId != null) {
      map['assist_player_id'] = Variable<String>(assistPlayerId);
    }
    if (!nullToAbsent || remark != null) {
      map['remark'] = Variable<String>(remark);
    }
    return map;
  }

  MatchEventsCompanion toCompanion(bool nullToAbsent) {
    return MatchEventsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      deleted: Value(deleted),
      isDirty: Value(isDirty),
      teamId: Value(teamId),
      matchId: Value(matchId),
      playerId: Value(playerId),
      type: Value(type),
      minute: Value(minute),
      assistPlayerId: assistPlayerId == null && nullToAbsent
          ? const Value.absent()
          : Value(assistPlayerId),
      remark: remark == null && nullToAbsent
          ? const Value.absent()
          : Value(remark),
    );
  }

  factory MatchEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MatchEvent(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      serverUpdatedAt: serializer.fromJson<String?>(json['serverUpdatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      teamId: serializer.fromJson<String>(json['teamId']),
      matchId: serializer.fromJson<String>(json['matchId']),
      playerId: serializer.fromJson<String>(json['playerId']),
      type: serializer.fromJson<String>(json['type']),
      minute: serializer.fromJson<int>(json['minute']),
      assistPlayerId: serializer.fromJson<String?>(json['assistPlayerId']),
      remark: serializer.fromJson<String?>(json['remark']),
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
      'matchId': serializer.toJson<String>(matchId),
      'playerId': serializer.toJson<String>(playerId),
      'type': serializer.toJson<String>(type),
      'minute': serializer.toJson<int>(minute),
      'assistPlayerId': serializer.toJson<String?>(assistPlayerId),
      'remark': serializer.toJson<String?>(remark),
    };
  }

  MatchEvent copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    Value<String?> serverUpdatedAt = const Value.absent(),
    bool? deleted,
    bool? isDirty,
    String? teamId,
    String? matchId,
    String? playerId,
    String? type,
    int? minute,
    Value<String?> assistPlayerId = const Value.absent(),
    Value<String?> remark = const Value.absent(),
  }) => MatchEvent(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    deleted: deleted ?? this.deleted,
    isDirty: isDirty ?? this.isDirty,
    teamId: teamId ?? this.teamId,
    matchId: matchId ?? this.matchId,
    playerId: playerId ?? this.playerId,
    type: type ?? this.type,
    minute: minute ?? this.minute,
    assistPlayerId: assistPlayerId.present
        ? assistPlayerId.value
        : this.assistPlayerId,
    remark: remark.present ? remark.value : this.remark,
  );
  MatchEvent copyWithCompanion(MatchEventsCompanion data) {
    return MatchEvent(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      matchId: data.matchId.present ? data.matchId.value : this.matchId,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      type: data.type.present ? data.type.value : this.type,
      minute: data.minute.present ? data.minute.value : this.minute,
      assistPlayerId: data.assistPlayerId.present
          ? data.assistPlayerId.value
          : this.assistPlayerId,
      remark: data.remark.present ? data.remark.value : this.remark,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MatchEvent(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('teamId: $teamId, ')
          ..write('matchId: $matchId, ')
          ..write('playerId: $playerId, ')
          ..write('type: $type, ')
          ..write('minute: $minute, ')
          ..write('assistPlayerId: $assistPlayerId, ')
          ..write('remark: $remark')
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
    matchId,
    playerId,
    type,
    minute,
    assistPlayerId,
    remark,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MatchEvent &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.deleted == this.deleted &&
          other.isDirty == this.isDirty &&
          other.teamId == this.teamId &&
          other.matchId == this.matchId &&
          other.playerId == this.playerId &&
          other.type == this.type &&
          other.minute == this.minute &&
          other.assistPlayerId == this.assistPlayerId &&
          other.remark == this.remark);
}

class MatchEventsCompanion extends UpdateCompanion<MatchEvent> {
  final Value<String> id;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> serverUpdatedAt;
  final Value<bool> deleted;
  final Value<bool> isDirty;
  final Value<String> teamId;
  final Value<String> matchId;
  final Value<String> playerId;
  final Value<String> type;
  final Value<int> minute;
  final Value<String?> assistPlayerId;
  final Value<String?> remark;
  final Value<int> rowid;
  const MatchEventsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.teamId = const Value.absent(),
    this.matchId = const Value.absent(),
    this.playerId = const Value.absent(),
    this.type = const Value.absent(),
    this.minute = const Value.absent(),
    this.assistPlayerId = const Value.absent(),
    this.remark = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MatchEventsCompanion.insert({
    required String id,
    required String createdAt,
    required String updatedAt,
    this.serverUpdatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    required String teamId,
    required String matchId,
    required String playerId,
    required String type,
    required int minute,
    this.assistPlayerId = const Value.absent(),
    this.remark = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       teamId = Value(teamId),
       matchId = Value(matchId),
       playerId = Value(playerId),
       type = Value(type),
       minute = Value(minute);
  static Insertable<MatchEvent> custom({
    Expression<String>? id,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? serverUpdatedAt,
    Expression<bool>? deleted,
    Expression<bool>? isDirty,
    Expression<String>? teamId,
    Expression<String>? matchId,
    Expression<String>? playerId,
    Expression<String>? type,
    Expression<int>? minute,
    Expression<String>? assistPlayerId,
    Expression<String>? remark,
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
      if (matchId != null) 'match_id': matchId,
      if (playerId != null) 'player_id': playerId,
      if (type != null) 'type': type,
      if (minute != null) 'minute': minute,
      if (assistPlayerId != null) 'assist_player_id': assistPlayerId,
      if (remark != null) 'remark': remark,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MatchEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? serverUpdatedAt,
    Value<bool>? deleted,
    Value<bool>? isDirty,
    Value<String>? teamId,
    Value<String>? matchId,
    Value<String>? playerId,
    Value<String>? type,
    Value<int>? minute,
    Value<String?>? assistPlayerId,
    Value<String?>? remark,
    Value<int>? rowid,
  }) {
    return MatchEventsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      deleted: deleted ?? this.deleted,
      isDirty: isDirty ?? this.isDirty,
      teamId: teamId ?? this.teamId,
      matchId: matchId ?? this.matchId,
      playerId: playerId ?? this.playerId,
      type: type ?? this.type,
      minute: minute ?? this.minute,
      assistPlayerId: assistPlayerId ?? this.assistPlayerId,
      remark: remark ?? this.remark,
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
    if (matchId.present) {
      map['match_id'] = Variable<String>(matchId.value);
    }
    if (playerId.present) {
      map['player_id'] = Variable<String>(playerId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (minute.present) {
      map['minute'] = Variable<int>(minute.value);
    }
    if (assistPlayerId.present) {
      map['assist_player_id'] = Variable<String>(assistPlayerId.value);
    }
    if (remark.present) {
      map['remark'] = Variable<String>(remark.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MatchEventsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('teamId: $teamId, ')
          ..write('matchId: $matchId, ')
          ..write('playerId: $playerId, ')
          ..write('type: $type, ')
          ..write('minute: $minute, ')
          ..write('assistPlayerId: $assistPlayerId, ')
          ..write('remark: $remark, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InjuriesTable extends Injuries with TableInfo<$InjuriesTable, Injury> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InjuriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _playerIdMeta = const VerificationMeta(
    'playerId',
  );
  @override
  late final GeneratedColumn<String> playerId = GeneratedColumn<String>(
    'player_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _matchIdMeta = const VerificationMeta(
    'matchId',
  );
  @override
  late final GeneratedColumn<String> matchId = GeneratedColumn<String>(
    'match_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minuteMeta = const VerificationMeta('minute');
  @override
  late final GeneratedColumn<int> minute = GeneratedColumn<int>(
    'minute',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyAreaMeta = const VerificationMeta(
    'bodyArea',
  );
  @override
  late final GeneratedColumn<String> bodyArea = GeneratedColumn<String>(
    'body_area',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sideMeta = const VerificationMeta('side');
  @override
  late final GeneratedColumn<String> side = GeneratedColumn<String>(
    'side',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mechanismMeta = const VerificationMeta(
    'mechanism',
  );
  @override
  late final GeneratedColumn<String> mechanism = GeneratedColumn<String>(
    'mechanism',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _severityMeta = const VerificationMeta(
    'severity',
  );
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
    'severity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expectedReturnDateMeta =
      const VerificationMeta('expectedReturnDate');
  @override
  late final GeneratedColumn<String> expectedReturnDate =
      GeneratedColumn<String>(
        'expected_return_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _returnDateMeta = const VerificationMeta(
    'returnDate',
  );
  @override
  late final GeneratedColumn<String> returnDate = GeneratedColumn<String>(
    'return_date',
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
    playerId,
    sessionId,
    matchId,
    minute,
    date,
    bodyArea,
    side,
    type,
    mechanism,
    severity,
    description,
    expectedReturnDate,
    returnDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'injuries';
  @override
  VerificationContext validateIntegrity(
    Insertable<Injury> instance, {
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
    if (data.containsKey('player_id')) {
      context.handle(
        _playerIdMeta,
        playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    }
    if (data.containsKey('match_id')) {
      context.handle(
        _matchIdMeta,
        matchId.isAcceptableOrUnknown(data['match_id']!, _matchIdMeta),
      );
    }
    if (data.containsKey('minute')) {
      context.handle(
        _minuteMeta,
        minute.isAcceptableOrUnknown(data['minute']!, _minuteMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('body_area')) {
      context.handle(
        _bodyAreaMeta,
        bodyArea.isAcceptableOrUnknown(data['body_area']!, _bodyAreaMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyAreaMeta);
    }
    if (data.containsKey('side')) {
      context.handle(
        _sideMeta,
        side.isAcceptableOrUnknown(data['side']!, _sideMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('mechanism')) {
      context.handle(
        _mechanismMeta,
        mechanism.isAcceptableOrUnknown(data['mechanism']!, _mechanismMeta),
      );
    } else if (isInserting) {
      context.missing(_mechanismMeta);
    }
    if (data.containsKey('severity')) {
      context.handle(
        _severityMeta,
        severity.isAcceptableOrUnknown(data['severity']!, _severityMeta),
      );
    } else if (isInserting) {
      context.missing(_severityMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('expected_return_date')) {
      context.handle(
        _expectedReturnDateMeta,
        expectedReturnDate.isAcceptableOrUnknown(
          data['expected_return_date']!,
          _expectedReturnDateMeta,
        ),
      );
    }
    if (data.containsKey('return_date')) {
      context.handle(
        _returnDateMeta,
        returnDate.isAcceptableOrUnknown(data['return_date']!, _returnDateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Injury map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Injury(
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
      playerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}player_id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      ),
      matchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}match_id'],
      ),
      minute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minute'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      bodyArea: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body_area'],
      )!,
      side: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}side'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      mechanism: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mechanism'],
      )!,
      severity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}severity'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      expectedReturnDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expected_return_date'],
      ),
      returnDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}return_date'],
      ),
    );
  }

  @override
  $InjuriesTable createAlias(String alias) {
    return $InjuriesTable(attachedDatabase, alias);
  }
}

class Injury extends DataClass implements Insertable<Injury> {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String? serverUpdatedAt;
  final bool deleted;

  /// Modifiée localement et pas encore envoyée. Jamais synchronisée.
  final bool isDirty;
  final String teamId;
  final String playerId;
  final String? sessionId;
  final String? matchId;
  final int? minute;
  final String date;
  final String bodyArea;
  final String? side;
  final String type;
  final String mechanism;
  final String severity;
  final String? description;
  final String? expectedReturnDate;
  final String? returnDate;
  const Injury({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.serverUpdatedAt,
    required this.deleted,
    required this.isDirty,
    required this.teamId,
    required this.playerId,
    this.sessionId,
    this.matchId,
    this.minute,
    required this.date,
    required this.bodyArea,
    this.side,
    required this.type,
    required this.mechanism,
    required this.severity,
    this.description,
    this.expectedReturnDate,
    this.returnDate,
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
    map['player_id'] = Variable<String>(playerId);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<String>(sessionId);
    }
    if (!nullToAbsent || matchId != null) {
      map['match_id'] = Variable<String>(matchId);
    }
    if (!nullToAbsent || minute != null) {
      map['minute'] = Variable<int>(minute);
    }
    map['date'] = Variable<String>(date);
    map['body_area'] = Variable<String>(bodyArea);
    if (!nullToAbsent || side != null) {
      map['side'] = Variable<String>(side);
    }
    map['type'] = Variable<String>(type);
    map['mechanism'] = Variable<String>(mechanism);
    map['severity'] = Variable<String>(severity);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || expectedReturnDate != null) {
      map['expected_return_date'] = Variable<String>(expectedReturnDate);
    }
    if (!nullToAbsent || returnDate != null) {
      map['return_date'] = Variable<String>(returnDate);
    }
    return map;
  }

  InjuriesCompanion toCompanion(bool nullToAbsent) {
    return InjuriesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      deleted: Value(deleted),
      isDirty: Value(isDirty),
      teamId: Value(teamId),
      playerId: Value(playerId),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      matchId: matchId == null && nullToAbsent
          ? const Value.absent()
          : Value(matchId),
      minute: minute == null && nullToAbsent
          ? const Value.absent()
          : Value(minute),
      date: Value(date),
      bodyArea: Value(bodyArea),
      side: side == null && nullToAbsent ? const Value.absent() : Value(side),
      type: Value(type),
      mechanism: Value(mechanism),
      severity: Value(severity),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      expectedReturnDate: expectedReturnDate == null && nullToAbsent
          ? const Value.absent()
          : Value(expectedReturnDate),
      returnDate: returnDate == null && nullToAbsent
          ? const Value.absent()
          : Value(returnDate),
    );
  }

  factory Injury.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Injury(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      serverUpdatedAt: serializer.fromJson<String?>(json['serverUpdatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      teamId: serializer.fromJson<String>(json['teamId']),
      playerId: serializer.fromJson<String>(json['playerId']),
      sessionId: serializer.fromJson<String?>(json['sessionId']),
      matchId: serializer.fromJson<String?>(json['matchId']),
      minute: serializer.fromJson<int?>(json['minute']),
      date: serializer.fromJson<String>(json['date']),
      bodyArea: serializer.fromJson<String>(json['bodyArea']),
      side: serializer.fromJson<String?>(json['side']),
      type: serializer.fromJson<String>(json['type']),
      mechanism: serializer.fromJson<String>(json['mechanism']),
      severity: serializer.fromJson<String>(json['severity']),
      description: serializer.fromJson<String?>(json['description']),
      expectedReturnDate: serializer.fromJson<String?>(
        json['expectedReturnDate'],
      ),
      returnDate: serializer.fromJson<String?>(json['returnDate']),
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
      'playerId': serializer.toJson<String>(playerId),
      'sessionId': serializer.toJson<String?>(sessionId),
      'matchId': serializer.toJson<String?>(matchId),
      'minute': serializer.toJson<int?>(minute),
      'date': serializer.toJson<String>(date),
      'bodyArea': serializer.toJson<String>(bodyArea),
      'side': serializer.toJson<String?>(side),
      'type': serializer.toJson<String>(type),
      'mechanism': serializer.toJson<String>(mechanism),
      'severity': serializer.toJson<String>(severity),
      'description': serializer.toJson<String?>(description),
      'expectedReturnDate': serializer.toJson<String?>(expectedReturnDate),
      'returnDate': serializer.toJson<String?>(returnDate),
    };
  }

  Injury copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    Value<String?> serverUpdatedAt = const Value.absent(),
    bool? deleted,
    bool? isDirty,
    String? teamId,
    String? playerId,
    Value<String?> sessionId = const Value.absent(),
    Value<String?> matchId = const Value.absent(),
    Value<int?> minute = const Value.absent(),
    String? date,
    String? bodyArea,
    Value<String?> side = const Value.absent(),
    String? type,
    String? mechanism,
    String? severity,
    Value<String?> description = const Value.absent(),
    Value<String?> expectedReturnDate = const Value.absent(),
    Value<String?> returnDate = const Value.absent(),
  }) => Injury(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    deleted: deleted ?? this.deleted,
    isDirty: isDirty ?? this.isDirty,
    teamId: teamId ?? this.teamId,
    playerId: playerId ?? this.playerId,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
    matchId: matchId.present ? matchId.value : this.matchId,
    minute: minute.present ? minute.value : this.minute,
    date: date ?? this.date,
    bodyArea: bodyArea ?? this.bodyArea,
    side: side.present ? side.value : this.side,
    type: type ?? this.type,
    mechanism: mechanism ?? this.mechanism,
    severity: severity ?? this.severity,
    description: description.present ? description.value : this.description,
    expectedReturnDate: expectedReturnDate.present
        ? expectedReturnDate.value
        : this.expectedReturnDate,
    returnDate: returnDate.present ? returnDate.value : this.returnDate,
  );
  Injury copyWithCompanion(InjuriesCompanion data) {
    return Injury(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      matchId: data.matchId.present ? data.matchId.value : this.matchId,
      minute: data.minute.present ? data.minute.value : this.minute,
      date: data.date.present ? data.date.value : this.date,
      bodyArea: data.bodyArea.present ? data.bodyArea.value : this.bodyArea,
      side: data.side.present ? data.side.value : this.side,
      type: data.type.present ? data.type.value : this.type,
      mechanism: data.mechanism.present ? data.mechanism.value : this.mechanism,
      severity: data.severity.present ? data.severity.value : this.severity,
      description: data.description.present
          ? data.description.value
          : this.description,
      expectedReturnDate: data.expectedReturnDate.present
          ? data.expectedReturnDate.value
          : this.expectedReturnDate,
      returnDate: data.returnDate.present
          ? data.returnDate.value
          : this.returnDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Injury(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('teamId: $teamId, ')
          ..write('playerId: $playerId, ')
          ..write('sessionId: $sessionId, ')
          ..write('matchId: $matchId, ')
          ..write('minute: $minute, ')
          ..write('date: $date, ')
          ..write('bodyArea: $bodyArea, ')
          ..write('side: $side, ')
          ..write('type: $type, ')
          ..write('mechanism: $mechanism, ')
          ..write('severity: $severity, ')
          ..write('description: $description, ')
          ..write('expectedReturnDate: $expectedReturnDate, ')
          ..write('returnDate: $returnDate')
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
    playerId,
    sessionId,
    matchId,
    minute,
    date,
    bodyArea,
    side,
    type,
    mechanism,
    severity,
    description,
    expectedReturnDate,
    returnDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Injury &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.deleted == this.deleted &&
          other.isDirty == this.isDirty &&
          other.teamId == this.teamId &&
          other.playerId == this.playerId &&
          other.sessionId == this.sessionId &&
          other.matchId == this.matchId &&
          other.minute == this.minute &&
          other.date == this.date &&
          other.bodyArea == this.bodyArea &&
          other.side == this.side &&
          other.type == this.type &&
          other.mechanism == this.mechanism &&
          other.severity == this.severity &&
          other.description == this.description &&
          other.expectedReturnDate == this.expectedReturnDate &&
          other.returnDate == this.returnDate);
}

class InjuriesCompanion extends UpdateCompanion<Injury> {
  final Value<String> id;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> serverUpdatedAt;
  final Value<bool> deleted;
  final Value<bool> isDirty;
  final Value<String> teamId;
  final Value<String> playerId;
  final Value<String?> sessionId;
  final Value<String?> matchId;
  final Value<int?> minute;
  final Value<String> date;
  final Value<String> bodyArea;
  final Value<String?> side;
  final Value<String> type;
  final Value<String> mechanism;
  final Value<String> severity;
  final Value<String?> description;
  final Value<String?> expectedReturnDate;
  final Value<String?> returnDate;
  final Value<int> rowid;
  const InjuriesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.teamId = const Value.absent(),
    this.playerId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.matchId = const Value.absent(),
    this.minute = const Value.absent(),
    this.date = const Value.absent(),
    this.bodyArea = const Value.absent(),
    this.side = const Value.absent(),
    this.type = const Value.absent(),
    this.mechanism = const Value.absent(),
    this.severity = const Value.absent(),
    this.description = const Value.absent(),
    this.expectedReturnDate = const Value.absent(),
    this.returnDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InjuriesCompanion.insert({
    required String id,
    required String createdAt,
    required String updatedAt,
    this.serverUpdatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    required String teamId,
    required String playerId,
    this.sessionId = const Value.absent(),
    this.matchId = const Value.absent(),
    this.minute = const Value.absent(),
    required String date,
    required String bodyArea,
    this.side = const Value.absent(),
    required String type,
    required String mechanism,
    required String severity,
    this.description = const Value.absent(),
    this.expectedReturnDate = const Value.absent(),
    this.returnDate = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       teamId = Value(teamId),
       playerId = Value(playerId),
       date = Value(date),
       bodyArea = Value(bodyArea),
       type = Value(type),
       mechanism = Value(mechanism),
       severity = Value(severity);
  static Insertable<Injury> custom({
    Expression<String>? id,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? serverUpdatedAt,
    Expression<bool>? deleted,
    Expression<bool>? isDirty,
    Expression<String>? teamId,
    Expression<String>? playerId,
    Expression<String>? sessionId,
    Expression<String>? matchId,
    Expression<int>? minute,
    Expression<String>? date,
    Expression<String>? bodyArea,
    Expression<String>? side,
    Expression<String>? type,
    Expression<String>? mechanism,
    Expression<String>? severity,
    Expression<String>? description,
    Expression<String>? expectedReturnDate,
    Expression<String>? returnDate,
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
      if (playerId != null) 'player_id': playerId,
      if (sessionId != null) 'session_id': sessionId,
      if (matchId != null) 'match_id': matchId,
      if (minute != null) 'minute': minute,
      if (date != null) 'date': date,
      if (bodyArea != null) 'body_area': bodyArea,
      if (side != null) 'side': side,
      if (type != null) 'type': type,
      if (mechanism != null) 'mechanism': mechanism,
      if (severity != null) 'severity': severity,
      if (description != null) 'description': description,
      if (expectedReturnDate != null)
        'expected_return_date': expectedReturnDate,
      if (returnDate != null) 'return_date': returnDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InjuriesCompanion copyWith({
    Value<String>? id,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? serverUpdatedAt,
    Value<bool>? deleted,
    Value<bool>? isDirty,
    Value<String>? teamId,
    Value<String>? playerId,
    Value<String?>? sessionId,
    Value<String?>? matchId,
    Value<int?>? minute,
    Value<String>? date,
    Value<String>? bodyArea,
    Value<String?>? side,
    Value<String>? type,
    Value<String>? mechanism,
    Value<String>? severity,
    Value<String?>? description,
    Value<String?>? expectedReturnDate,
    Value<String?>? returnDate,
    Value<int>? rowid,
  }) {
    return InjuriesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      deleted: deleted ?? this.deleted,
      isDirty: isDirty ?? this.isDirty,
      teamId: teamId ?? this.teamId,
      playerId: playerId ?? this.playerId,
      sessionId: sessionId ?? this.sessionId,
      matchId: matchId ?? this.matchId,
      minute: minute ?? this.minute,
      date: date ?? this.date,
      bodyArea: bodyArea ?? this.bodyArea,
      side: side ?? this.side,
      type: type ?? this.type,
      mechanism: mechanism ?? this.mechanism,
      severity: severity ?? this.severity,
      description: description ?? this.description,
      expectedReturnDate: expectedReturnDate ?? this.expectedReturnDate,
      returnDate: returnDate ?? this.returnDate,
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
    if (playerId.present) {
      map['player_id'] = Variable<String>(playerId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (matchId.present) {
      map['match_id'] = Variable<String>(matchId.value);
    }
    if (minute.present) {
      map['minute'] = Variable<int>(minute.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (bodyArea.present) {
      map['body_area'] = Variable<String>(bodyArea.value);
    }
    if (side.present) {
      map['side'] = Variable<String>(side.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (mechanism.present) {
      map['mechanism'] = Variable<String>(mechanism.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (expectedReturnDate.present) {
      map['expected_return_date'] = Variable<String>(expectedReturnDate.value);
    }
    if (returnDate.present) {
      map['return_date'] = Variable<String>(returnDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InjuriesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('teamId: $teamId, ')
          ..write('playerId: $playerId, ')
          ..write('sessionId: $sessionId, ')
          ..write('matchId: $matchId, ')
          ..write('minute: $minute, ')
          ..write('date: $date, ')
          ..write('bodyArea: $bodyArea, ')
          ..write('side: $side, ')
          ..write('type: $type, ')
          ..write('mechanism: $mechanism, ')
          ..write('severity: $severity, ')
          ..write('description: $description, ')
          ..write('expectedReturnDate: $expectedReturnDate, ')
          ..write('returnDate: $returnDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TestTypesTable extends TestTypes
    with TableInfo<$TestTypesTable, TestType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TestTypesTable(this.attachedDatabase, [this._alias]);
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
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
  static const VerificationMeta _betterMeta = const VerificationMeta('better');
  @override
  late final GeneratedColumn<String> better = GeneratedColumn<String>(
    'better',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(100),
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
    code,
    name,
    unit,
    category,
    better,
    attempts,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'test_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<TestType> instance, {
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
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
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
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
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
    if (data.containsKey('better')) {
      context.handle(
        _betterMeta,
        better.isAcceptableOrUnknown(data['better']!, _betterMeta),
      );
    } else if (isInserting) {
      context.missing(_betterMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TestType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TestType(
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
      ),
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      better: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}better'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $TestTypesTable createAlias(String alias) {
    return $TestTypesTable(attachedDatabase, alias);
  }
}

class TestType extends DataClass implements Insertable<TestType> {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String? serverUpdatedAt;
  final bool deleted;

  /// Modifiée localement et pas encore envoyée. Jamais synchronisée.
  final bool isDirty;
  final String? teamId;
  final String? code;
  final String name;
  final String? unit;
  final String category;

  /// higher / lower / none : sens du meilleur résultat.
  final String better;
  final int attempts;
  final int sortOrder;
  const TestType({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.serverUpdatedAt,
    required this.deleted,
    required this.isDirty,
    this.teamId,
    this.code,
    required this.name,
    this.unit,
    required this.category,
    required this.better,
    required this.attempts,
    required this.sortOrder,
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
    if (!nullToAbsent || teamId != null) {
      map['team_id'] = Variable<String>(teamId);
    }
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    map['category'] = Variable<String>(category);
    map['better'] = Variable<String>(better);
    map['attempts'] = Variable<int>(attempts);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  TestTypesCompanion toCompanion(bool nullToAbsent) {
    return TestTypesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      deleted: Value(deleted),
      isDirty: Value(isDirty),
      teamId: teamId == null && nullToAbsent
          ? const Value.absent()
          : Value(teamId),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
      name: Value(name),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      category: Value(category),
      better: Value(better),
      attempts: Value(attempts),
      sortOrder: Value(sortOrder),
    );
  }

  factory TestType.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TestType(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      serverUpdatedAt: serializer.fromJson<String?>(json['serverUpdatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      teamId: serializer.fromJson<String?>(json['teamId']),
      code: serializer.fromJson<String?>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      unit: serializer.fromJson<String?>(json['unit']),
      category: serializer.fromJson<String>(json['category']),
      better: serializer.fromJson<String>(json['better']),
      attempts: serializer.fromJson<int>(json['attempts']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
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
      'teamId': serializer.toJson<String?>(teamId),
      'code': serializer.toJson<String?>(code),
      'name': serializer.toJson<String>(name),
      'unit': serializer.toJson<String?>(unit),
      'category': serializer.toJson<String>(category),
      'better': serializer.toJson<String>(better),
      'attempts': serializer.toJson<int>(attempts),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  TestType copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    Value<String?> serverUpdatedAt = const Value.absent(),
    bool? deleted,
    bool? isDirty,
    Value<String?> teamId = const Value.absent(),
    Value<String?> code = const Value.absent(),
    String? name,
    Value<String?> unit = const Value.absent(),
    String? category,
    String? better,
    int? attempts,
    int? sortOrder,
  }) => TestType(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    deleted: deleted ?? this.deleted,
    isDirty: isDirty ?? this.isDirty,
    teamId: teamId.present ? teamId.value : this.teamId,
    code: code.present ? code.value : this.code,
    name: name ?? this.name,
    unit: unit.present ? unit.value : this.unit,
    category: category ?? this.category,
    better: better ?? this.better,
    attempts: attempts ?? this.attempts,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  TestType copyWithCompanion(TestTypesCompanion data) {
    return TestType(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      unit: data.unit.present ? data.unit.value : this.unit,
      category: data.category.present ? data.category.value : this.category,
      better: data.better.present ? data.better.value : this.better,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TestType(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('teamId: $teamId, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('unit: $unit, ')
          ..write('category: $category, ')
          ..write('better: $better, ')
          ..write('attempts: $attempts, ')
          ..write('sortOrder: $sortOrder')
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
    code,
    name,
    unit,
    category,
    better,
    attempts,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TestType &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.deleted == this.deleted &&
          other.isDirty == this.isDirty &&
          other.teamId == this.teamId &&
          other.code == this.code &&
          other.name == this.name &&
          other.unit == this.unit &&
          other.category == this.category &&
          other.better == this.better &&
          other.attempts == this.attempts &&
          other.sortOrder == this.sortOrder);
}

class TestTypesCompanion extends UpdateCompanion<TestType> {
  final Value<String> id;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> serverUpdatedAt;
  final Value<bool> deleted;
  final Value<bool> isDirty;
  final Value<String?> teamId;
  final Value<String?> code;
  final Value<String> name;
  final Value<String?> unit;
  final Value<String> category;
  final Value<String> better;
  final Value<int> attempts;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const TestTypesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.teamId = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.unit = const Value.absent(),
    this.category = const Value.absent(),
    this.better = const Value.absent(),
    this.attempts = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TestTypesCompanion.insert({
    required String id,
    required String createdAt,
    required String updatedAt,
    this.serverUpdatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.teamId = const Value.absent(),
    this.code = const Value.absent(),
    required String name,
    this.unit = const Value.absent(),
    required String category,
    required String better,
    this.attempts = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name),
       category = Value(category),
       better = Value(better);
  static Insertable<TestType> custom({
    Expression<String>? id,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? serverUpdatedAt,
    Expression<bool>? deleted,
    Expression<bool>? isDirty,
    Expression<String>? teamId,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? unit,
    Expression<String>? category,
    Expression<String>? better,
    Expression<int>? attempts,
    Expression<int>? sortOrder,
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
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (unit != null) 'unit': unit,
      if (category != null) 'category': category,
      if (better != null) 'better': better,
      if (attempts != null) 'attempts': attempts,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TestTypesCompanion copyWith({
    Value<String>? id,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? serverUpdatedAt,
    Value<bool>? deleted,
    Value<bool>? isDirty,
    Value<String?>? teamId,
    Value<String?>? code,
    Value<String>? name,
    Value<String?>? unit,
    Value<String>? category,
    Value<String>? better,
    Value<int>? attempts,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return TestTypesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      deleted: deleted ?? this.deleted,
      isDirty: isDirty ?? this.isDirty,
      teamId: teamId ?? this.teamId,
      code: code ?? this.code,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      better: better ?? this.better,
      attempts: attempts ?? this.attempts,
      sortOrder: sortOrder ?? this.sortOrder,
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
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (better.present) {
      map['better'] = Variable<String>(better.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TestTypesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('teamId: $teamId, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('unit: $unit, ')
          ..write('category: $category, ')
          ..write('better: $better, ')
          ..write('attempts: $attempts, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TestResultsTable extends TestResults
    with TableInfo<$TestResultsTable, TestResult> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TestResultsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _playerIdMeta = const VerificationMeta(
    'playerId',
  );
  @override
  late final GeneratedColumn<String> playerId = GeneratedColumn<String>(
    'player_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _testTypeIdMeta = const VerificationMeta(
    'testTypeId',
  );
  @override
  late final GeneratedColumn<String> testTypeId = GeneratedColumn<String>(
    'test_type_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptMeta = const VerificationMeta(
    'attempt',
  );
  @override
  late final GeneratedColumn<int> attempt = GeneratedColumn<int>(
    'attempt',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remarkMeta = const VerificationMeta('remark');
  @override
  late final GeneratedColumn<String> remark = GeneratedColumn<String>(
    'remark',
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
    playerId,
    testTypeId,
    date,
    attempt,
    value,
    remark,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'test_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<TestResult> instance, {
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
    if (data.containsKey('player_id')) {
      context.handle(
        _playerIdMeta,
        playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('test_type_id')) {
      context.handle(
        _testTypeIdMeta,
        testTypeId.isAcceptableOrUnknown(
          data['test_type_id']!,
          _testTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_testTypeIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('attempt')) {
      context.handle(
        _attemptMeta,
        attempt.isAcceptableOrUnknown(data['attempt']!, _attemptMeta),
      );
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('remark')) {
      context.handle(
        _remarkMeta,
        remark.isAcceptableOrUnknown(data['remark']!, _remarkMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TestResult map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TestResult(
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
      playerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}player_id'],
      )!,
      testTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}test_type_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      attempt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      )!,
      remark: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remark'],
      ),
    );
  }

  @override
  $TestResultsTable createAlias(String alias) {
    return $TestResultsTable(attachedDatabase, alias);
  }
}

class TestResult extends DataClass implements Insertable<TestResult> {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String? serverUpdatedAt;
  final bool deleted;

  /// Modifiée localement et pas encore envoyée. Jamais synchronisée.
  final bool isDirty;
  final String teamId;
  final String playerId;
  final String testTypeId;
  final String date;
  final int attempt;
  final double value;
  final String? remark;
  const TestResult({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.serverUpdatedAt,
    required this.deleted,
    required this.isDirty,
    required this.teamId,
    required this.playerId,
    required this.testTypeId,
    required this.date,
    required this.attempt,
    required this.value,
    this.remark,
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
    map['player_id'] = Variable<String>(playerId);
    map['test_type_id'] = Variable<String>(testTypeId);
    map['date'] = Variable<String>(date);
    map['attempt'] = Variable<int>(attempt);
    map['value'] = Variable<double>(value);
    if (!nullToAbsent || remark != null) {
      map['remark'] = Variable<String>(remark);
    }
    return map;
  }

  TestResultsCompanion toCompanion(bool nullToAbsent) {
    return TestResultsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      deleted: Value(deleted),
      isDirty: Value(isDirty),
      teamId: Value(teamId),
      playerId: Value(playerId),
      testTypeId: Value(testTypeId),
      date: Value(date),
      attempt: Value(attempt),
      value: Value(value),
      remark: remark == null && nullToAbsent
          ? const Value.absent()
          : Value(remark),
    );
  }

  factory TestResult.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TestResult(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      serverUpdatedAt: serializer.fromJson<String?>(json['serverUpdatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      teamId: serializer.fromJson<String>(json['teamId']),
      playerId: serializer.fromJson<String>(json['playerId']),
      testTypeId: serializer.fromJson<String>(json['testTypeId']),
      date: serializer.fromJson<String>(json['date']),
      attempt: serializer.fromJson<int>(json['attempt']),
      value: serializer.fromJson<double>(json['value']),
      remark: serializer.fromJson<String?>(json['remark']),
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
      'playerId': serializer.toJson<String>(playerId),
      'testTypeId': serializer.toJson<String>(testTypeId),
      'date': serializer.toJson<String>(date),
      'attempt': serializer.toJson<int>(attempt),
      'value': serializer.toJson<double>(value),
      'remark': serializer.toJson<String?>(remark),
    };
  }

  TestResult copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    Value<String?> serverUpdatedAt = const Value.absent(),
    bool? deleted,
    bool? isDirty,
    String? teamId,
    String? playerId,
    String? testTypeId,
    String? date,
    int? attempt,
    double? value,
    Value<String?> remark = const Value.absent(),
  }) => TestResult(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    deleted: deleted ?? this.deleted,
    isDirty: isDirty ?? this.isDirty,
    teamId: teamId ?? this.teamId,
    playerId: playerId ?? this.playerId,
    testTypeId: testTypeId ?? this.testTypeId,
    date: date ?? this.date,
    attempt: attempt ?? this.attempt,
    value: value ?? this.value,
    remark: remark.present ? remark.value : this.remark,
  );
  TestResult copyWithCompanion(TestResultsCompanion data) {
    return TestResult(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      testTypeId: data.testTypeId.present
          ? data.testTypeId.value
          : this.testTypeId,
      date: data.date.present ? data.date.value : this.date,
      attempt: data.attempt.present ? data.attempt.value : this.attempt,
      value: data.value.present ? data.value.value : this.value,
      remark: data.remark.present ? data.remark.value : this.remark,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TestResult(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('teamId: $teamId, ')
          ..write('playerId: $playerId, ')
          ..write('testTypeId: $testTypeId, ')
          ..write('date: $date, ')
          ..write('attempt: $attempt, ')
          ..write('value: $value, ')
          ..write('remark: $remark')
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
    playerId,
    testTypeId,
    date,
    attempt,
    value,
    remark,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TestResult &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.deleted == this.deleted &&
          other.isDirty == this.isDirty &&
          other.teamId == this.teamId &&
          other.playerId == this.playerId &&
          other.testTypeId == this.testTypeId &&
          other.date == this.date &&
          other.attempt == this.attempt &&
          other.value == this.value &&
          other.remark == this.remark);
}

class TestResultsCompanion extends UpdateCompanion<TestResult> {
  final Value<String> id;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> serverUpdatedAt;
  final Value<bool> deleted;
  final Value<bool> isDirty;
  final Value<String> teamId;
  final Value<String> playerId;
  final Value<String> testTypeId;
  final Value<String> date;
  final Value<int> attempt;
  final Value<double> value;
  final Value<String?> remark;
  final Value<int> rowid;
  const TestResultsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.teamId = const Value.absent(),
    this.playerId = const Value.absent(),
    this.testTypeId = const Value.absent(),
    this.date = const Value.absent(),
    this.attempt = const Value.absent(),
    this.value = const Value.absent(),
    this.remark = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TestResultsCompanion.insert({
    required String id,
    required String createdAt,
    required String updatedAt,
    this.serverUpdatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    required String teamId,
    required String playerId,
    required String testTypeId,
    required String date,
    this.attempt = const Value.absent(),
    required double value,
    this.remark = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       teamId = Value(teamId),
       playerId = Value(playerId),
       testTypeId = Value(testTypeId),
       date = Value(date),
       value = Value(value);
  static Insertable<TestResult> custom({
    Expression<String>? id,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? serverUpdatedAt,
    Expression<bool>? deleted,
    Expression<bool>? isDirty,
    Expression<String>? teamId,
    Expression<String>? playerId,
    Expression<String>? testTypeId,
    Expression<String>? date,
    Expression<int>? attempt,
    Expression<double>? value,
    Expression<String>? remark,
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
      if (playerId != null) 'player_id': playerId,
      if (testTypeId != null) 'test_type_id': testTypeId,
      if (date != null) 'date': date,
      if (attempt != null) 'attempt': attempt,
      if (value != null) 'value': value,
      if (remark != null) 'remark': remark,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TestResultsCompanion copyWith({
    Value<String>? id,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? serverUpdatedAt,
    Value<bool>? deleted,
    Value<bool>? isDirty,
    Value<String>? teamId,
    Value<String>? playerId,
    Value<String>? testTypeId,
    Value<String>? date,
    Value<int>? attempt,
    Value<double>? value,
    Value<String?>? remark,
    Value<int>? rowid,
  }) {
    return TestResultsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      deleted: deleted ?? this.deleted,
      isDirty: isDirty ?? this.isDirty,
      teamId: teamId ?? this.teamId,
      playerId: playerId ?? this.playerId,
      testTypeId: testTypeId ?? this.testTypeId,
      date: date ?? this.date,
      attempt: attempt ?? this.attempt,
      value: value ?? this.value,
      remark: remark ?? this.remark,
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
    if (playerId.present) {
      map['player_id'] = Variable<String>(playerId.value);
    }
    if (testTypeId.present) {
      map['test_type_id'] = Variable<String>(testTypeId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (attempt.present) {
      map['attempt'] = Variable<int>(attempt.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (remark.present) {
      map['remark'] = Variable<String>(remark.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TestResultsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('teamId: $teamId, ')
          ..write('playerId: $playerId, ')
          ..write('testTypeId: $testTypeId, ')
          ..write('date: $date, ')
          ..write('attempt: $attempt, ')
          ..write('value: $value, ')
          ..write('remark: $remark, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlayerProfilesTable extends PlayerProfiles
    with TableInfo<$PlayerProfilesTable, PlayerProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayerProfilesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _playerIdMeta = const VerificationMeta(
    'playerId',
  );
  @override
  late final GeneratedColumn<String> playerId = GeneratedColumn<String>(
    'player_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nationalityMeta = const VerificationMeta(
    'nationality',
  );
  @override
  late final GeneratedColumn<String> nationality = GeneratedColumn<String>(
    'nationality',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthPlaceMeta = const VerificationMeta(
    'birthPlace',
  );
  @override
  late final GeneratedColumn<String> birthPlace = GeneratedColumn<String>(
    'birth_place',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schoolMeta = const VerificationMeta('school');
  @override
  late final GeneratedColumn<String> school = GeneratedColumn<String>(
    'school',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schoolYearMeta = const VerificationMeta(
    'schoolYear',
  );
  @override
  late final GeneratedColumn<String> schoolYear = GeneratedColumn<String>(
    'school_year',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fatherNameMeta = const VerificationMeta(
    'fatherName',
  );
  @override
  late final GeneratedColumn<String> fatherName = GeneratedColumn<String>(
    'father_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fatherNationalityMeta = const VerificationMeta(
    'fatherNationality',
  );
  @override
  late final GeneratedColumn<String> fatherNationality =
      GeneratedColumn<String>(
        'father_nationality',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _fatherOccupationMeta = const VerificationMeta(
    'fatherOccupation',
  );
  @override
  late final GeneratedColumn<String> fatherOccupation = GeneratedColumn<String>(
    'father_occupation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fatherMaritalStatusMeta =
      const VerificationMeta('fatherMaritalStatus');
  @override
  late final GeneratedColumn<String> fatherMaritalStatus =
      GeneratedColumn<String>(
        'father_marital_status',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _motherNameMeta = const VerificationMeta(
    'motherName',
  );
  @override
  late final GeneratedColumn<String> motherName = GeneratedColumn<String>(
    'mother_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _motherNationalityMeta = const VerificationMeta(
    'motherNationality',
  );
  @override
  late final GeneratedColumn<String> motherNationality =
      GeneratedColumn<String>(
        'mother_nationality',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _motherMaritalStatusMeta =
      const VerificationMeta('motherMaritalStatus');
  @override
  late final GeneratedColumn<String> motherMaritalStatus =
      GeneratedColumn<String>(
        'mother_marital_status',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _previousClubMeta = const VerificationMeta(
    'previousClub',
  );
  @override
  late final GeneratedColumn<String> previousClub = GeneratedColumn<String>(
    'previous_club',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _previousClubCityMeta = const VerificationMeta(
    'previousClubCity',
  );
  @override
  late final GeneratedColumn<String> previousClubCity = GeneratedColumn<String>(
    'previous_club_city',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yearsTrainingMeta = const VerificationMeta(
    'yearsTraining',
  );
  @override
  late final GeneratedColumn<int> yearsTraining = GeneratedColumn<int>(
    'years_training',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _preferredRoleMeta = const VerificationMeta(
    'preferredRole',
  );
  @override
  late final GeneratedColumn<String> preferredRole = GeneratedColumn<String>(
    'preferred_role',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remarksMeta = const VerificationMeta(
    'remarks',
  );
  @override
  late final GeneratedColumn<String> remarks = GeneratedColumn<String>(
    'remarks',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _otherPositionMeta = const VerificationMeta(
    'otherPosition',
  );
  @override
  late final GeneratedColumn<String> otherPosition = GeneratedColumn<String>(
    'other_position',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schoolAddressMeta = const VerificationMeta(
    'schoolAddress',
  );
  @override
  late final GeneratedColumn<String> schoolAddress = GeneratedColumn<String>(
    'school_address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coachNameMeta = const VerificationMeta(
    'coachName',
  );
  @override
  late final GeneratedColumn<String> coachName = GeneratedColumn<String>(
    'coach_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _managerNameMeta = const VerificationMeta(
    'managerName',
  );
  @override
  late final GeneratedColumn<String> managerName = GeneratedColumn<String>(
    'manager_name',
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
    playerId,
    nationality,
    birthPlace,
    phone,
    email,
    address,
    school,
    schoolYear,
    fatherName,
    fatherNationality,
    fatherOccupation,
    fatherMaritalStatus,
    motherName,
    motherNationality,
    motherMaritalStatus,
    previousClub,
    previousClubCity,
    yearsTraining,
    preferredRole,
    remarks,
    otherPosition,
    schoolAddress,
    coachName,
    managerName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'player_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlayerProfile> instance, {
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
    if (data.containsKey('player_id')) {
      context.handle(
        _playerIdMeta,
        playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('nationality')) {
      context.handle(
        _nationalityMeta,
        nationality.isAcceptableOrUnknown(
          data['nationality']!,
          _nationalityMeta,
        ),
      );
    }
    if (data.containsKey('birth_place')) {
      context.handle(
        _birthPlaceMeta,
        birthPlace.isAcceptableOrUnknown(data['birth_place']!, _birthPlaceMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('school')) {
      context.handle(
        _schoolMeta,
        school.isAcceptableOrUnknown(data['school']!, _schoolMeta),
      );
    }
    if (data.containsKey('school_year')) {
      context.handle(
        _schoolYearMeta,
        schoolYear.isAcceptableOrUnknown(data['school_year']!, _schoolYearMeta),
      );
    }
    if (data.containsKey('father_name')) {
      context.handle(
        _fatherNameMeta,
        fatherName.isAcceptableOrUnknown(data['father_name']!, _fatherNameMeta),
      );
    }
    if (data.containsKey('father_nationality')) {
      context.handle(
        _fatherNationalityMeta,
        fatherNationality.isAcceptableOrUnknown(
          data['father_nationality']!,
          _fatherNationalityMeta,
        ),
      );
    }
    if (data.containsKey('father_occupation')) {
      context.handle(
        _fatherOccupationMeta,
        fatherOccupation.isAcceptableOrUnknown(
          data['father_occupation']!,
          _fatherOccupationMeta,
        ),
      );
    }
    if (data.containsKey('father_marital_status')) {
      context.handle(
        _fatherMaritalStatusMeta,
        fatherMaritalStatus.isAcceptableOrUnknown(
          data['father_marital_status']!,
          _fatherMaritalStatusMeta,
        ),
      );
    }
    if (data.containsKey('mother_name')) {
      context.handle(
        _motherNameMeta,
        motherName.isAcceptableOrUnknown(data['mother_name']!, _motherNameMeta),
      );
    }
    if (data.containsKey('mother_nationality')) {
      context.handle(
        _motherNationalityMeta,
        motherNationality.isAcceptableOrUnknown(
          data['mother_nationality']!,
          _motherNationalityMeta,
        ),
      );
    }
    if (data.containsKey('mother_marital_status')) {
      context.handle(
        _motherMaritalStatusMeta,
        motherMaritalStatus.isAcceptableOrUnknown(
          data['mother_marital_status']!,
          _motherMaritalStatusMeta,
        ),
      );
    }
    if (data.containsKey('previous_club')) {
      context.handle(
        _previousClubMeta,
        previousClub.isAcceptableOrUnknown(
          data['previous_club']!,
          _previousClubMeta,
        ),
      );
    }
    if (data.containsKey('previous_club_city')) {
      context.handle(
        _previousClubCityMeta,
        previousClubCity.isAcceptableOrUnknown(
          data['previous_club_city']!,
          _previousClubCityMeta,
        ),
      );
    }
    if (data.containsKey('years_training')) {
      context.handle(
        _yearsTrainingMeta,
        yearsTraining.isAcceptableOrUnknown(
          data['years_training']!,
          _yearsTrainingMeta,
        ),
      );
    }
    if (data.containsKey('preferred_role')) {
      context.handle(
        _preferredRoleMeta,
        preferredRole.isAcceptableOrUnknown(
          data['preferred_role']!,
          _preferredRoleMeta,
        ),
      );
    }
    if (data.containsKey('remarks')) {
      context.handle(
        _remarksMeta,
        remarks.isAcceptableOrUnknown(data['remarks']!, _remarksMeta),
      );
    }
    if (data.containsKey('other_position')) {
      context.handle(
        _otherPositionMeta,
        otherPosition.isAcceptableOrUnknown(
          data['other_position']!,
          _otherPositionMeta,
        ),
      );
    }
    if (data.containsKey('school_address')) {
      context.handle(
        _schoolAddressMeta,
        schoolAddress.isAcceptableOrUnknown(
          data['school_address']!,
          _schoolAddressMeta,
        ),
      );
    }
    if (data.containsKey('coach_name')) {
      context.handle(
        _coachNameMeta,
        coachName.isAcceptableOrUnknown(data['coach_name']!, _coachNameMeta),
      );
    }
    if (data.containsKey('manager_name')) {
      context.handle(
        _managerNameMeta,
        managerName.isAcceptableOrUnknown(
          data['manager_name']!,
          _managerNameMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlayerProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlayerProfile(
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
      playerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}player_id'],
      )!,
      nationality: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nationality'],
      ),
      birthPlace: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}birth_place'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      school: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school'],
      ),
      schoolYear: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_year'],
      ),
      fatherName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}father_name'],
      ),
      fatherNationality: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}father_nationality'],
      ),
      fatherOccupation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}father_occupation'],
      ),
      fatherMaritalStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}father_marital_status'],
      ),
      motherName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mother_name'],
      ),
      motherNationality: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mother_nationality'],
      ),
      motherMaritalStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mother_marital_status'],
      ),
      previousClub: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}previous_club'],
      ),
      previousClubCity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}previous_club_city'],
      ),
      yearsTraining: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}years_training'],
      ),
      preferredRole: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preferred_role'],
      ),
      remarks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remarks'],
      ),
      otherPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}other_position'],
      ),
      schoolAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_address'],
      ),
      coachName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}coach_name'],
      ),
      managerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manager_name'],
      ),
    );
  }

  @override
  $PlayerProfilesTable createAlias(String alias) {
    return $PlayerProfilesTable(attachedDatabase, alias);
  }
}

class PlayerProfile extends DataClass implements Insertable<PlayerProfile> {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String? serverUpdatedAt;
  final bool deleted;

  /// Modifiée localement et pas encore envoyée. Jamais synchronisée.
  final bool isDirty;
  final String teamId;
  final String playerId;
  final String? nationality;
  final String? birthPlace;
  final String? phone;
  final String? email;
  final String? address;
  final String? school;
  final String? schoolYear;
  final String? fatherName;
  final String? fatherNationality;
  final String? fatherOccupation;
  final String? fatherMaritalStatus;
  final String? motherName;
  final String? motherNationality;
  final String? motherMaritalStatus;
  final String? previousClub;
  final String? previousClubCity;
  final int? yearsTraining;
  final String? preferredRole;
  final String? remarks;
  final String? otherPosition;
  final String? schoolAddress;
  final String? coachName;
  final String? managerName;
  const PlayerProfile({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.serverUpdatedAt,
    required this.deleted,
    required this.isDirty,
    required this.teamId,
    required this.playerId,
    this.nationality,
    this.birthPlace,
    this.phone,
    this.email,
    this.address,
    this.school,
    this.schoolYear,
    this.fatherName,
    this.fatherNationality,
    this.fatherOccupation,
    this.fatherMaritalStatus,
    this.motherName,
    this.motherNationality,
    this.motherMaritalStatus,
    this.previousClub,
    this.previousClubCity,
    this.yearsTraining,
    this.preferredRole,
    this.remarks,
    this.otherPosition,
    this.schoolAddress,
    this.coachName,
    this.managerName,
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
    map['player_id'] = Variable<String>(playerId);
    if (!nullToAbsent || nationality != null) {
      map['nationality'] = Variable<String>(nationality);
    }
    if (!nullToAbsent || birthPlace != null) {
      map['birth_place'] = Variable<String>(birthPlace);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || school != null) {
      map['school'] = Variable<String>(school);
    }
    if (!nullToAbsent || schoolYear != null) {
      map['school_year'] = Variable<String>(schoolYear);
    }
    if (!nullToAbsent || fatherName != null) {
      map['father_name'] = Variable<String>(fatherName);
    }
    if (!nullToAbsent || fatherNationality != null) {
      map['father_nationality'] = Variable<String>(fatherNationality);
    }
    if (!nullToAbsent || fatherOccupation != null) {
      map['father_occupation'] = Variable<String>(fatherOccupation);
    }
    if (!nullToAbsent || fatherMaritalStatus != null) {
      map['father_marital_status'] = Variable<String>(fatherMaritalStatus);
    }
    if (!nullToAbsent || motherName != null) {
      map['mother_name'] = Variable<String>(motherName);
    }
    if (!nullToAbsent || motherNationality != null) {
      map['mother_nationality'] = Variable<String>(motherNationality);
    }
    if (!nullToAbsent || motherMaritalStatus != null) {
      map['mother_marital_status'] = Variable<String>(motherMaritalStatus);
    }
    if (!nullToAbsent || previousClub != null) {
      map['previous_club'] = Variable<String>(previousClub);
    }
    if (!nullToAbsent || previousClubCity != null) {
      map['previous_club_city'] = Variable<String>(previousClubCity);
    }
    if (!nullToAbsent || yearsTraining != null) {
      map['years_training'] = Variable<int>(yearsTraining);
    }
    if (!nullToAbsent || preferredRole != null) {
      map['preferred_role'] = Variable<String>(preferredRole);
    }
    if (!nullToAbsent || remarks != null) {
      map['remarks'] = Variable<String>(remarks);
    }
    if (!nullToAbsent || otherPosition != null) {
      map['other_position'] = Variable<String>(otherPosition);
    }
    if (!nullToAbsent || schoolAddress != null) {
      map['school_address'] = Variable<String>(schoolAddress);
    }
    if (!nullToAbsent || coachName != null) {
      map['coach_name'] = Variable<String>(coachName);
    }
    if (!nullToAbsent || managerName != null) {
      map['manager_name'] = Variable<String>(managerName);
    }
    return map;
  }

  PlayerProfilesCompanion toCompanion(bool nullToAbsent) {
    return PlayerProfilesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      deleted: Value(deleted),
      isDirty: Value(isDirty),
      teamId: Value(teamId),
      playerId: Value(playerId),
      nationality: nationality == null && nullToAbsent
          ? const Value.absent()
          : Value(nationality),
      birthPlace: birthPlace == null && nullToAbsent
          ? const Value.absent()
          : Value(birthPlace),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      school: school == null && nullToAbsent
          ? const Value.absent()
          : Value(school),
      schoolYear: schoolYear == null && nullToAbsent
          ? const Value.absent()
          : Value(schoolYear),
      fatherName: fatherName == null && nullToAbsent
          ? const Value.absent()
          : Value(fatherName),
      fatherNationality: fatherNationality == null && nullToAbsent
          ? const Value.absent()
          : Value(fatherNationality),
      fatherOccupation: fatherOccupation == null && nullToAbsent
          ? const Value.absent()
          : Value(fatherOccupation),
      fatherMaritalStatus: fatherMaritalStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(fatherMaritalStatus),
      motherName: motherName == null && nullToAbsent
          ? const Value.absent()
          : Value(motherName),
      motherNationality: motherNationality == null && nullToAbsent
          ? const Value.absent()
          : Value(motherNationality),
      motherMaritalStatus: motherMaritalStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(motherMaritalStatus),
      previousClub: previousClub == null && nullToAbsent
          ? const Value.absent()
          : Value(previousClub),
      previousClubCity: previousClubCity == null && nullToAbsent
          ? const Value.absent()
          : Value(previousClubCity),
      yearsTraining: yearsTraining == null && nullToAbsent
          ? const Value.absent()
          : Value(yearsTraining),
      preferredRole: preferredRole == null && nullToAbsent
          ? const Value.absent()
          : Value(preferredRole),
      remarks: remarks == null && nullToAbsent
          ? const Value.absent()
          : Value(remarks),
      otherPosition: otherPosition == null && nullToAbsent
          ? const Value.absent()
          : Value(otherPosition),
      schoolAddress: schoolAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(schoolAddress),
      coachName: coachName == null && nullToAbsent
          ? const Value.absent()
          : Value(coachName),
      managerName: managerName == null && nullToAbsent
          ? const Value.absent()
          : Value(managerName),
    );
  }

  factory PlayerProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlayerProfile(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      serverUpdatedAt: serializer.fromJson<String?>(json['serverUpdatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      teamId: serializer.fromJson<String>(json['teamId']),
      playerId: serializer.fromJson<String>(json['playerId']),
      nationality: serializer.fromJson<String?>(json['nationality']),
      birthPlace: serializer.fromJson<String?>(json['birthPlace']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      address: serializer.fromJson<String?>(json['address']),
      school: serializer.fromJson<String?>(json['school']),
      schoolYear: serializer.fromJson<String?>(json['schoolYear']),
      fatherName: serializer.fromJson<String?>(json['fatherName']),
      fatherNationality: serializer.fromJson<String?>(
        json['fatherNationality'],
      ),
      fatherOccupation: serializer.fromJson<String?>(json['fatherOccupation']),
      fatherMaritalStatus: serializer.fromJson<String?>(
        json['fatherMaritalStatus'],
      ),
      motherName: serializer.fromJson<String?>(json['motherName']),
      motherNationality: serializer.fromJson<String?>(
        json['motherNationality'],
      ),
      motherMaritalStatus: serializer.fromJson<String?>(
        json['motherMaritalStatus'],
      ),
      previousClub: serializer.fromJson<String?>(json['previousClub']),
      previousClubCity: serializer.fromJson<String?>(json['previousClubCity']),
      yearsTraining: serializer.fromJson<int?>(json['yearsTraining']),
      preferredRole: serializer.fromJson<String?>(json['preferredRole']),
      remarks: serializer.fromJson<String?>(json['remarks']),
      otherPosition: serializer.fromJson<String?>(json['otherPosition']),
      schoolAddress: serializer.fromJson<String?>(json['schoolAddress']),
      coachName: serializer.fromJson<String?>(json['coachName']),
      managerName: serializer.fromJson<String?>(json['managerName']),
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
      'playerId': serializer.toJson<String>(playerId),
      'nationality': serializer.toJson<String?>(nationality),
      'birthPlace': serializer.toJson<String?>(birthPlace),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'address': serializer.toJson<String?>(address),
      'school': serializer.toJson<String?>(school),
      'schoolYear': serializer.toJson<String?>(schoolYear),
      'fatherName': serializer.toJson<String?>(fatherName),
      'fatherNationality': serializer.toJson<String?>(fatherNationality),
      'fatherOccupation': serializer.toJson<String?>(fatherOccupation),
      'fatherMaritalStatus': serializer.toJson<String?>(fatherMaritalStatus),
      'motherName': serializer.toJson<String?>(motherName),
      'motherNationality': serializer.toJson<String?>(motherNationality),
      'motherMaritalStatus': serializer.toJson<String?>(motherMaritalStatus),
      'previousClub': serializer.toJson<String?>(previousClub),
      'previousClubCity': serializer.toJson<String?>(previousClubCity),
      'yearsTraining': serializer.toJson<int?>(yearsTraining),
      'preferredRole': serializer.toJson<String?>(preferredRole),
      'remarks': serializer.toJson<String?>(remarks),
      'otherPosition': serializer.toJson<String?>(otherPosition),
      'schoolAddress': serializer.toJson<String?>(schoolAddress),
      'coachName': serializer.toJson<String?>(coachName),
      'managerName': serializer.toJson<String?>(managerName),
    };
  }

  PlayerProfile copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    Value<String?> serverUpdatedAt = const Value.absent(),
    bool? deleted,
    bool? isDirty,
    String? teamId,
    String? playerId,
    Value<String?> nationality = const Value.absent(),
    Value<String?> birthPlace = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> school = const Value.absent(),
    Value<String?> schoolYear = const Value.absent(),
    Value<String?> fatherName = const Value.absent(),
    Value<String?> fatherNationality = const Value.absent(),
    Value<String?> fatherOccupation = const Value.absent(),
    Value<String?> fatherMaritalStatus = const Value.absent(),
    Value<String?> motherName = const Value.absent(),
    Value<String?> motherNationality = const Value.absent(),
    Value<String?> motherMaritalStatus = const Value.absent(),
    Value<String?> previousClub = const Value.absent(),
    Value<String?> previousClubCity = const Value.absent(),
    Value<int?> yearsTraining = const Value.absent(),
    Value<String?> preferredRole = const Value.absent(),
    Value<String?> remarks = const Value.absent(),
    Value<String?> otherPosition = const Value.absent(),
    Value<String?> schoolAddress = const Value.absent(),
    Value<String?> coachName = const Value.absent(),
    Value<String?> managerName = const Value.absent(),
  }) => PlayerProfile(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    deleted: deleted ?? this.deleted,
    isDirty: isDirty ?? this.isDirty,
    teamId: teamId ?? this.teamId,
    playerId: playerId ?? this.playerId,
    nationality: nationality.present ? nationality.value : this.nationality,
    birthPlace: birthPlace.present ? birthPlace.value : this.birthPlace,
    phone: phone.present ? phone.value : this.phone,
    email: email.present ? email.value : this.email,
    address: address.present ? address.value : this.address,
    school: school.present ? school.value : this.school,
    schoolYear: schoolYear.present ? schoolYear.value : this.schoolYear,
    fatherName: fatherName.present ? fatherName.value : this.fatherName,
    fatherNationality: fatherNationality.present
        ? fatherNationality.value
        : this.fatherNationality,
    fatherOccupation: fatherOccupation.present
        ? fatherOccupation.value
        : this.fatherOccupation,
    fatherMaritalStatus: fatherMaritalStatus.present
        ? fatherMaritalStatus.value
        : this.fatherMaritalStatus,
    motherName: motherName.present ? motherName.value : this.motherName,
    motherNationality: motherNationality.present
        ? motherNationality.value
        : this.motherNationality,
    motherMaritalStatus: motherMaritalStatus.present
        ? motherMaritalStatus.value
        : this.motherMaritalStatus,
    previousClub: previousClub.present ? previousClub.value : this.previousClub,
    previousClubCity: previousClubCity.present
        ? previousClubCity.value
        : this.previousClubCity,
    yearsTraining: yearsTraining.present
        ? yearsTraining.value
        : this.yearsTraining,
    preferredRole: preferredRole.present
        ? preferredRole.value
        : this.preferredRole,
    remarks: remarks.present ? remarks.value : this.remarks,
    otherPosition: otherPosition.present
        ? otherPosition.value
        : this.otherPosition,
    schoolAddress: schoolAddress.present
        ? schoolAddress.value
        : this.schoolAddress,
    coachName: coachName.present ? coachName.value : this.coachName,
    managerName: managerName.present ? managerName.value : this.managerName,
  );
  PlayerProfile copyWithCompanion(PlayerProfilesCompanion data) {
    return PlayerProfile(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      nationality: data.nationality.present
          ? data.nationality.value
          : this.nationality,
      birthPlace: data.birthPlace.present
          ? data.birthPlace.value
          : this.birthPlace,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      address: data.address.present ? data.address.value : this.address,
      school: data.school.present ? data.school.value : this.school,
      schoolYear: data.schoolYear.present
          ? data.schoolYear.value
          : this.schoolYear,
      fatherName: data.fatherName.present
          ? data.fatherName.value
          : this.fatherName,
      fatherNationality: data.fatherNationality.present
          ? data.fatherNationality.value
          : this.fatherNationality,
      fatherOccupation: data.fatherOccupation.present
          ? data.fatherOccupation.value
          : this.fatherOccupation,
      fatherMaritalStatus: data.fatherMaritalStatus.present
          ? data.fatherMaritalStatus.value
          : this.fatherMaritalStatus,
      motherName: data.motherName.present
          ? data.motherName.value
          : this.motherName,
      motherNationality: data.motherNationality.present
          ? data.motherNationality.value
          : this.motherNationality,
      motherMaritalStatus: data.motherMaritalStatus.present
          ? data.motherMaritalStatus.value
          : this.motherMaritalStatus,
      previousClub: data.previousClub.present
          ? data.previousClub.value
          : this.previousClub,
      previousClubCity: data.previousClubCity.present
          ? data.previousClubCity.value
          : this.previousClubCity,
      yearsTraining: data.yearsTraining.present
          ? data.yearsTraining.value
          : this.yearsTraining,
      preferredRole: data.preferredRole.present
          ? data.preferredRole.value
          : this.preferredRole,
      remarks: data.remarks.present ? data.remarks.value : this.remarks,
      otherPosition: data.otherPosition.present
          ? data.otherPosition.value
          : this.otherPosition,
      schoolAddress: data.schoolAddress.present
          ? data.schoolAddress.value
          : this.schoolAddress,
      coachName: data.coachName.present ? data.coachName.value : this.coachName,
      managerName: data.managerName.present
          ? data.managerName.value
          : this.managerName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlayerProfile(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('teamId: $teamId, ')
          ..write('playerId: $playerId, ')
          ..write('nationality: $nationality, ')
          ..write('birthPlace: $birthPlace, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('school: $school, ')
          ..write('schoolYear: $schoolYear, ')
          ..write('fatherName: $fatherName, ')
          ..write('fatherNationality: $fatherNationality, ')
          ..write('fatherOccupation: $fatherOccupation, ')
          ..write('fatherMaritalStatus: $fatherMaritalStatus, ')
          ..write('motherName: $motherName, ')
          ..write('motherNationality: $motherNationality, ')
          ..write('motherMaritalStatus: $motherMaritalStatus, ')
          ..write('previousClub: $previousClub, ')
          ..write('previousClubCity: $previousClubCity, ')
          ..write('yearsTraining: $yearsTraining, ')
          ..write('preferredRole: $preferredRole, ')
          ..write('remarks: $remarks, ')
          ..write('otherPosition: $otherPosition, ')
          ..write('schoolAddress: $schoolAddress, ')
          ..write('coachName: $coachName, ')
          ..write('managerName: $managerName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    createdAt,
    updatedAt,
    serverUpdatedAt,
    deleted,
    isDirty,
    teamId,
    playerId,
    nationality,
    birthPlace,
    phone,
    email,
    address,
    school,
    schoolYear,
    fatherName,
    fatherNationality,
    fatherOccupation,
    fatherMaritalStatus,
    motherName,
    motherNationality,
    motherMaritalStatus,
    previousClub,
    previousClubCity,
    yearsTraining,
    preferredRole,
    remarks,
    otherPosition,
    schoolAddress,
    coachName,
    managerName,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlayerProfile &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.deleted == this.deleted &&
          other.isDirty == this.isDirty &&
          other.teamId == this.teamId &&
          other.playerId == this.playerId &&
          other.nationality == this.nationality &&
          other.birthPlace == this.birthPlace &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.address == this.address &&
          other.school == this.school &&
          other.schoolYear == this.schoolYear &&
          other.fatherName == this.fatherName &&
          other.fatherNationality == this.fatherNationality &&
          other.fatherOccupation == this.fatherOccupation &&
          other.fatherMaritalStatus == this.fatherMaritalStatus &&
          other.motherName == this.motherName &&
          other.motherNationality == this.motherNationality &&
          other.motherMaritalStatus == this.motherMaritalStatus &&
          other.previousClub == this.previousClub &&
          other.previousClubCity == this.previousClubCity &&
          other.yearsTraining == this.yearsTraining &&
          other.preferredRole == this.preferredRole &&
          other.remarks == this.remarks &&
          other.otherPosition == this.otherPosition &&
          other.schoolAddress == this.schoolAddress &&
          other.coachName == this.coachName &&
          other.managerName == this.managerName);
}

class PlayerProfilesCompanion extends UpdateCompanion<PlayerProfile> {
  final Value<String> id;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> serverUpdatedAt;
  final Value<bool> deleted;
  final Value<bool> isDirty;
  final Value<String> teamId;
  final Value<String> playerId;
  final Value<String?> nationality;
  final Value<String?> birthPlace;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> address;
  final Value<String?> school;
  final Value<String?> schoolYear;
  final Value<String?> fatherName;
  final Value<String?> fatherNationality;
  final Value<String?> fatherOccupation;
  final Value<String?> fatherMaritalStatus;
  final Value<String?> motherName;
  final Value<String?> motherNationality;
  final Value<String?> motherMaritalStatus;
  final Value<String?> previousClub;
  final Value<String?> previousClubCity;
  final Value<int?> yearsTraining;
  final Value<String?> preferredRole;
  final Value<String?> remarks;
  final Value<String?> otherPosition;
  final Value<String?> schoolAddress;
  final Value<String?> coachName;
  final Value<String?> managerName;
  final Value<int> rowid;
  const PlayerProfilesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.teamId = const Value.absent(),
    this.playerId = const Value.absent(),
    this.nationality = const Value.absent(),
    this.birthPlace = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.school = const Value.absent(),
    this.schoolYear = const Value.absent(),
    this.fatherName = const Value.absent(),
    this.fatherNationality = const Value.absent(),
    this.fatherOccupation = const Value.absent(),
    this.fatherMaritalStatus = const Value.absent(),
    this.motherName = const Value.absent(),
    this.motherNationality = const Value.absent(),
    this.motherMaritalStatus = const Value.absent(),
    this.previousClub = const Value.absent(),
    this.previousClubCity = const Value.absent(),
    this.yearsTraining = const Value.absent(),
    this.preferredRole = const Value.absent(),
    this.remarks = const Value.absent(),
    this.otherPosition = const Value.absent(),
    this.schoolAddress = const Value.absent(),
    this.coachName = const Value.absent(),
    this.managerName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlayerProfilesCompanion.insert({
    required String id,
    required String createdAt,
    required String updatedAt,
    this.serverUpdatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    required String teamId,
    required String playerId,
    this.nationality = const Value.absent(),
    this.birthPlace = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.school = const Value.absent(),
    this.schoolYear = const Value.absent(),
    this.fatherName = const Value.absent(),
    this.fatherNationality = const Value.absent(),
    this.fatherOccupation = const Value.absent(),
    this.fatherMaritalStatus = const Value.absent(),
    this.motherName = const Value.absent(),
    this.motherNationality = const Value.absent(),
    this.motherMaritalStatus = const Value.absent(),
    this.previousClub = const Value.absent(),
    this.previousClubCity = const Value.absent(),
    this.yearsTraining = const Value.absent(),
    this.preferredRole = const Value.absent(),
    this.remarks = const Value.absent(),
    this.otherPosition = const Value.absent(),
    this.schoolAddress = const Value.absent(),
    this.coachName = const Value.absent(),
    this.managerName = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       teamId = Value(teamId),
       playerId = Value(playerId);
  static Insertable<PlayerProfile> custom({
    Expression<String>? id,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? serverUpdatedAt,
    Expression<bool>? deleted,
    Expression<bool>? isDirty,
    Expression<String>? teamId,
    Expression<String>? playerId,
    Expression<String>? nationality,
    Expression<String>? birthPlace,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? address,
    Expression<String>? school,
    Expression<String>? schoolYear,
    Expression<String>? fatherName,
    Expression<String>? fatherNationality,
    Expression<String>? fatherOccupation,
    Expression<String>? fatherMaritalStatus,
    Expression<String>? motherName,
    Expression<String>? motherNationality,
    Expression<String>? motherMaritalStatus,
    Expression<String>? previousClub,
    Expression<String>? previousClubCity,
    Expression<int>? yearsTraining,
    Expression<String>? preferredRole,
    Expression<String>? remarks,
    Expression<String>? otherPosition,
    Expression<String>? schoolAddress,
    Expression<String>? coachName,
    Expression<String>? managerName,
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
      if (playerId != null) 'player_id': playerId,
      if (nationality != null) 'nationality': nationality,
      if (birthPlace != null) 'birth_place': birthPlace,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (school != null) 'school': school,
      if (schoolYear != null) 'school_year': schoolYear,
      if (fatherName != null) 'father_name': fatherName,
      if (fatherNationality != null) 'father_nationality': fatherNationality,
      if (fatherOccupation != null) 'father_occupation': fatherOccupation,
      if (fatherMaritalStatus != null)
        'father_marital_status': fatherMaritalStatus,
      if (motherName != null) 'mother_name': motherName,
      if (motherNationality != null) 'mother_nationality': motherNationality,
      if (motherMaritalStatus != null)
        'mother_marital_status': motherMaritalStatus,
      if (previousClub != null) 'previous_club': previousClub,
      if (previousClubCity != null) 'previous_club_city': previousClubCity,
      if (yearsTraining != null) 'years_training': yearsTraining,
      if (preferredRole != null) 'preferred_role': preferredRole,
      if (remarks != null) 'remarks': remarks,
      if (otherPosition != null) 'other_position': otherPosition,
      if (schoolAddress != null) 'school_address': schoolAddress,
      if (coachName != null) 'coach_name': coachName,
      if (managerName != null) 'manager_name': managerName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlayerProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? serverUpdatedAt,
    Value<bool>? deleted,
    Value<bool>? isDirty,
    Value<String>? teamId,
    Value<String>? playerId,
    Value<String?>? nationality,
    Value<String?>? birthPlace,
    Value<String?>? phone,
    Value<String?>? email,
    Value<String?>? address,
    Value<String?>? school,
    Value<String?>? schoolYear,
    Value<String?>? fatherName,
    Value<String?>? fatherNationality,
    Value<String?>? fatherOccupation,
    Value<String?>? fatherMaritalStatus,
    Value<String?>? motherName,
    Value<String?>? motherNationality,
    Value<String?>? motherMaritalStatus,
    Value<String?>? previousClub,
    Value<String?>? previousClubCity,
    Value<int?>? yearsTraining,
    Value<String?>? preferredRole,
    Value<String?>? remarks,
    Value<String?>? otherPosition,
    Value<String?>? schoolAddress,
    Value<String?>? coachName,
    Value<String?>? managerName,
    Value<int>? rowid,
  }) {
    return PlayerProfilesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      deleted: deleted ?? this.deleted,
      isDirty: isDirty ?? this.isDirty,
      teamId: teamId ?? this.teamId,
      playerId: playerId ?? this.playerId,
      nationality: nationality ?? this.nationality,
      birthPlace: birthPlace ?? this.birthPlace,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      school: school ?? this.school,
      schoolYear: schoolYear ?? this.schoolYear,
      fatherName: fatherName ?? this.fatherName,
      fatherNationality: fatherNationality ?? this.fatherNationality,
      fatherOccupation: fatherOccupation ?? this.fatherOccupation,
      fatherMaritalStatus: fatherMaritalStatus ?? this.fatherMaritalStatus,
      motherName: motherName ?? this.motherName,
      motherNationality: motherNationality ?? this.motherNationality,
      motherMaritalStatus: motherMaritalStatus ?? this.motherMaritalStatus,
      previousClub: previousClub ?? this.previousClub,
      previousClubCity: previousClubCity ?? this.previousClubCity,
      yearsTraining: yearsTraining ?? this.yearsTraining,
      preferredRole: preferredRole ?? this.preferredRole,
      remarks: remarks ?? this.remarks,
      otherPosition: otherPosition ?? this.otherPosition,
      schoolAddress: schoolAddress ?? this.schoolAddress,
      coachName: coachName ?? this.coachName,
      managerName: managerName ?? this.managerName,
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
    if (playerId.present) {
      map['player_id'] = Variable<String>(playerId.value);
    }
    if (nationality.present) {
      map['nationality'] = Variable<String>(nationality.value);
    }
    if (birthPlace.present) {
      map['birth_place'] = Variable<String>(birthPlace.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (school.present) {
      map['school'] = Variable<String>(school.value);
    }
    if (schoolYear.present) {
      map['school_year'] = Variable<String>(schoolYear.value);
    }
    if (fatherName.present) {
      map['father_name'] = Variable<String>(fatherName.value);
    }
    if (fatherNationality.present) {
      map['father_nationality'] = Variable<String>(fatherNationality.value);
    }
    if (fatherOccupation.present) {
      map['father_occupation'] = Variable<String>(fatherOccupation.value);
    }
    if (fatherMaritalStatus.present) {
      map['father_marital_status'] = Variable<String>(
        fatherMaritalStatus.value,
      );
    }
    if (motherName.present) {
      map['mother_name'] = Variable<String>(motherName.value);
    }
    if (motherNationality.present) {
      map['mother_nationality'] = Variable<String>(motherNationality.value);
    }
    if (motherMaritalStatus.present) {
      map['mother_marital_status'] = Variable<String>(
        motherMaritalStatus.value,
      );
    }
    if (previousClub.present) {
      map['previous_club'] = Variable<String>(previousClub.value);
    }
    if (previousClubCity.present) {
      map['previous_club_city'] = Variable<String>(previousClubCity.value);
    }
    if (yearsTraining.present) {
      map['years_training'] = Variable<int>(yearsTraining.value);
    }
    if (preferredRole.present) {
      map['preferred_role'] = Variable<String>(preferredRole.value);
    }
    if (remarks.present) {
      map['remarks'] = Variable<String>(remarks.value);
    }
    if (otherPosition.present) {
      map['other_position'] = Variable<String>(otherPosition.value);
    }
    if (schoolAddress.present) {
      map['school_address'] = Variable<String>(schoolAddress.value);
    }
    if (coachName.present) {
      map['coach_name'] = Variable<String>(coachName.value);
    }
    if (managerName.present) {
      map['manager_name'] = Variable<String>(managerName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayerProfilesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('teamId: $teamId, ')
          ..write('playerId: $playerId, ')
          ..write('nationality: $nationality, ')
          ..write('birthPlace: $birthPlace, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('school: $school, ')
          ..write('schoolYear: $schoolYear, ')
          ..write('fatherName: $fatherName, ')
          ..write('fatherNationality: $fatherNationality, ')
          ..write('fatherOccupation: $fatherOccupation, ')
          ..write('fatherMaritalStatus: $fatherMaritalStatus, ')
          ..write('motherName: $motherName, ')
          ..write('motherNationality: $motherNationality, ')
          ..write('motherMaritalStatus: $motherMaritalStatus, ')
          ..write('previousClub: $previousClub, ')
          ..write('previousClubCity: $previousClubCity, ')
          ..write('yearsTraining: $yearsTraining, ')
          ..write('preferredRole: $preferredRole, ')
          ..write('remarks: $remarks, ')
          ..write('otherPosition: $otherPosition, ')
          ..write('schoolAddress: $schoolAddress, ')
          ..write('coachName: $coachName, ')
          ..write('managerName: $managerName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlayerMedicalTable extends PlayerMedical
    with TableInfo<$PlayerMedicalTable, MedicalRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayerMedicalTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _playerIdMeta = const VerificationMeta(
    'playerId',
  );
  @override
  late final GeneratedColumn<String> playerId = GeneratedColumn<String>(
    'player_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _consentDateMeta = const VerificationMeta(
    'consentDate',
  );
  @override
  late final GeneratedColumn<String> consentDate = GeneratedColumn<String>(
    'consent_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _consentByMeta = const VerificationMeta(
    'consentBy',
  );
  @override
  late final GeneratedColumn<String> consentBy = GeneratedColumn<String>(
    'consent_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _allergiesMeta = const VerificationMeta(
    'allergies',
  );
  @override
  late final GeneratedColumn<String> allergies = GeneratedColumn<String>(
    'allergies',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _conditionsMeta = const VerificationMeta(
    'conditions',
  );
  @override
  late final GeneratedColumn<String> conditions = GeneratedColumn<String>(
    'conditions',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lowBpAnxietyMeta = const VerificationMeta(
    'lowBpAnxiety',
  );
  @override
  late final GeneratedColumn<String> lowBpAnxiety = GeneratedColumn<String>(
    'low_bp_anxiety',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _surgeriesMeta = const VerificationMeta(
    'surgeries',
  );
  @override
  late final GeneratedColumn<String> surgeries = GeneratedColumn<String>(
    'surgeries',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recentInjuriesMeta = const VerificationMeta(
    'recentInjuries',
  );
  @override
  late final GeneratedColumn<String> recentInjuries = GeneratedColumn<String>(
    'recent_injuries',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remarksMeta = const VerificationMeta(
    'remarks',
  );
  @override
  late final GeneratedColumn<String> remarks = GeneratedColumn<String>(
    'remarks',
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
    playerId,
    consentDate,
    consentBy,
    allergies,
    conditions,
    lowBpAnxiety,
    surgeries,
    recentInjuries,
    remarks,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'player_medical';
  @override
  VerificationContext validateIntegrity(
    Insertable<MedicalRecord> instance, {
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
    if (data.containsKey('player_id')) {
      context.handle(
        _playerIdMeta,
        playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('consent_date')) {
      context.handle(
        _consentDateMeta,
        consentDate.isAcceptableOrUnknown(
          data['consent_date']!,
          _consentDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_consentDateMeta);
    }
    if (data.containsKey('consent_by')) {
      context.handle(
        _consentByMeta,
        consentBy.isAcceptableOrUnknown(data['consent_by']!, _consentByMeta),
      );
    } else if (isInserting) {
      context.missing(_consentByMeta);
    }
    if (data.containsKey('allergies')) {
      context.handle(
        _allergiesMeta,
        allergies.isAcceptableOrUnknown(data['allergies']!, _allergiesMeta),
      );
    }
    if (data.containsKey('conditions')) {
      context.handle(
        _conditionsMeta,
        conditions.isAcceptableOrUnknown(data['conditions']!, _conditionsMeta),
      );
    }
    if (data.containsKey('low_bp_anxiety')) {
      context.handle(
        _lowBpAnxietyMeta,
        lowBpAnxiety.isAcceptableOrUnknown(
          data['low_bp_anxiety']!,
          _lowBpAnxietyMeta,
        ),
      );
    }
    if (data.containsKey('surgeries')) {
      context.handle(
        _surgeriesMeta,
        surgeries.isAcceptableOrUnknown(data['surgeries']!, _surgeriesMeta),
      );
    }
    if (data.containsKey('recent_injuries')) {
      context.handle(
        _recentInjuriesMeta,
        recentInjuries.isAcceptableOrUnknown(
          data['recent_injuries']!,
          _recentInjuriesMeta,
        ),
      );
    }
    if (data.containsKey('remarks')) {
      context.handle(
        _remarksMeta,
        remarks.isAcceptableOrUnknown(data['remarks']!, _remarksMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MedicalRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicalRecord(
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
      playerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}player_id'],
      )!,
      consentDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}consent_date'],
      )!,
      consentBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}consent_by'],
      )!,
      allergies: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}allergies'],
      ),
      conditions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conditions'],
      ),
      lowBpAnxiety: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}low_bp_anxiety'],
      ),
      surgeries: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}surgeries'],
      ),
      recentInjuries: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recent_injuries'],
      ),
      remarks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remarks'],
      ),
    );
  }

  @override
  $PlayerMedicalTable createAlias(String alias) {
    return $PlayerMedicalTable(attachedDatabase, alias);
  }
}

class MedicalRecord extends DataClass implements Insertable<MedicalRecord> {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String? serverUpdatedAt;
  final bool deleted;

  /// Modifiée localement et pas encore envoyée. Jamais synchronisée.
  final bool isDirty;
  final String teamId;
  final String playerId;
  final String consentDate;

  /// player / guardian
  final String consentBy;
  final String? allergies;
  final String? conditions;
  final String? lowBpAnxiety;
  final String? surgeries;
  final String? recentInjuries;
  final String? remarks;
  const MedicalRecord({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.serverUpdatedAt,
    required this.deleted,
    required this.isDirty,
    required this.teamId,
    required this.playerId,
    required this.consentDate,
    required this.consentBy,
    this.allergies,
    this.conditions,
    this.lowBpAnxiety,
    this.surgeries,
    this.recentInjuries,
    this.remarks,
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
    map['player_id'] = Variable<String>(playerId);
    map['consent_date'] = Variable<String>(consentDate);
    map['consent_by'] = Variable<String>(consentBy);
    if (!nullToAbsent || allergies != null) {
      map['allergies'] = Variable<String>(allergies);
    }
    if (!nullToAbsent || conditions != null) {
      map['conditions'] = Variable<String>(conditions);
    }
    if (!nullToAbsent || lowBpAnxiety != null) {
      map['low_bp_anxiety'] = Variable<String>(lowBpAnxiety);
    }
    if (!nullToAbsent || surgeries != null) {
      map['surgeries'] = Variable<String>(surgeries);
    }
    if (!nullToAbsent || recentInjuries != null) {
      map['recent_injuries'] = Variable<String>(recentInjuries);
    }
    if (!nullToAbsent || remarks != null) {
      map['remarks'] = Variable<String>(remarks);
    }
    return map;
  }

  PlayerMedicalCompanion toCompanion(bool nullToAbsent) {
    return PlayerMedicalCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      deleted: Value(deleted),
      isDirty: Value(isDirty),
      teamId: Value(teamId),
      playerId: Value(playerId),
      consentDate: Value(consentDate),
      consentBy: Value(consentBy),
      allergies: allergies == null && nullToAbsent
          ? const Value.absent()
          : Value(allergies),
      conditions: conditions == null && nullToAbsent
          ? const Value.absent()
          : Value(conditions),
      lowBpAnxiety: lowBpAnxiety == null && nullToAbsent
          ? const Value.absent()
          : Value(lowBpAnxiety),
      surgeries: surgeries == null && nullToAbsent
          ? const Value.absent()
          : Value(surgeries),
      recentInjuries: recentInjuries == null && nullToAbsent
          ? const Value.absent()
          : Value(recentInjuries),
      remarks: remarks == null && nullToAbsent
          ? const Value.absent()
          : Value(remarks),
    );
  }

  factory MedicalRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicalRecord(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      serverUpdatedAt: serializer.fromJson<String?>(json['serverUpdatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      teamId: serializer.fromJson<String>(json['teamId']),
      playerId: serializer.fromJson<String>(json['playerId']),
      consentDate: serializer.fromJson<String>(json['consentDate']),
      consentBy: serializer.fromJson<String>(json['consentBy']),
      allergies: serializer.fromJson<String?>(json['allergies']),
      conditions: serializer.fromJson<String?>(json['conditions']),
      lowBpAnxiety: serializer.fromJson<String?>(json['lowBpAnxiety']),
      surgeries: serializer.fromJson<String?>(json['surgeries']),
      recentInjuries: serializer.fromJson<String?>(json['recentInjuries']),
      remarks: serializer.fromJson<String?>(json['remarks']),
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
      'playerId': serializer.toJson<String>(playerId),
      'consentDate': serializer.toJson<String>(consentDate),
      'consentBy': serializer.toJson<String>(consentBy),
      'allergies': serializer.toJson<String?>(allergies),
      'conditions': serializer.toJson<String?>(conditions),
      'lowBpAnxiety': serializer.toJson<String?>(lowBpAnxiety),
      'surgeries': serializer.toJson<String?>(surgeries),
      'recentInjuries': serializer.toJson<String?>(recentInjuries),
      'remarks': serializer.toJson<String?>(remarks),
    };
  }

  MedicalRecord copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    Value<String?> serverUpdatedAt = const Value.absent(),
    bool? deleted,
    bool? isDirty,
    String? teamId,
    String? playerId,
    String? consentDate,
    String? consentBy,
    Value<String?> allergies = const Value.absent(),
    Value<String?> conditions = const Value.absent(),
    Value<String?> lowBpAnxiety = const Value.absent(),
    Value<String?> surgeries = const Value.absent(),
    Value<String?> recentInjuries = const Value.absent(),
    Value<String?> remarks = const Value.absent(),
  }) => MedicalRecord(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    deleted: deleted ?? this.deleted,
    isDirty: isDirty ?? this.isDirty,
    teamId: teamId ?? this.teamId,
    playerId: playerId ?? this.playerId,
    consentDate: consentDate ?? this.consentDate,
    consentBy: consentBy ?? this.consentBy,
    allergies: allergies.present ? allergies.value : this.allergies,
    conditions: conditions.present ? conditions.value : this.conditions,
    lowBpAnxiety: lowBpAnxiety.present ? lowBpAnxiety.value : this.lowBpAnxiety,
    surgeries: surgeries.present ? surgeries.value : this.surgeries,
    recentInjuries: recentInjuries.present
        ? recentInjuries.value
        : this.recentInjuries,
    remarks: remarks.present ? remarks.value : this.remarks,
  );
  MedicalRecord copyWithCompanion(PlayerMedicalCompanion data) {
    return MedicalRecord(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      consentDate: data.consentDate.present
          ? data.consentDate.value
          : this.consentDate,
      consentBy: data.consentBy.present ? data.consentBy.value : this.consentBy,
      allergies: data.allergies.present ? data.allergies.value : this.allergies,
      conditions: data.conditions.present
          ? data.conditions.value
          : this.conditions,
      lowBpAnxiety: data.lowBpAnxiety.present
          ? data.lowBpAnxiety.value
          : this.lowBpAnxiety,
      surgeries: data.surgeries.present ? data.surgeries.value : this.surgeries,
      recentInjuries: data.recentInjuries.present
          ? data.recentInjuries.value
          : this.recentInjuries,
      remarks: data.remarks.present ? data.remarks.value : this.remarks,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicalRecord(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('teamId: $teamId, ')
          ..write('playerId: $playerId, ')
          ..write('consentDate: $consentDate, ')
          ..write('consentBy: $consentBy, ')
          ..write('allergies: $allergies, ')
          ..write('conditions: $conditions, ')
          ..write('lowBpAnxiety: $lowBpAnxiety, ')
          ..write('surgeries: $surgeries, ')
          ..write('recentInjuries: $recentInjuries, ')
          ..write('remarks: $remarks')
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
    playerId,
    consentDate,
    consentBy,
    allergies,
    conditions,
    lowBpAnxiety,
    surgeries,
    recentInjuries,
    remarks,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicalRecord &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.deleted == this.deleted &&
          other.isDirty == this.isDirty &&
          other.teamId == this.teamId &&
          other.playerId == this.playerId &&
          other.consentDate == this.consentDate &&
          other.consentBy == this.consentBy &&
          other.allergies == this.allergies &&
          other.conditions == this.conditions &&
          other.lowBpAnxiety == this.lowBpAnxiety &&
          other.surgeries == this.surgeries &&
          other.recentInjuries == this.recentInjuries &&
          other.remarks == this.remarks);
}

class PlayerMedicalCompanion extends UpdateCompanion<MedicalRecord> {
  final Value<String> id;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> serverUpdatedAt;
  final Value<bool> deleted;
  final Value<bool> isDirty;
  final Value<String> teamId;
  final Value<String> playerId;
  final Value<String> consentDate;
  final Value<String> consentBy;
  final Value<String?> allergies;
  final Value<String?> conditions;
  final Value<String?> lowBpAnxiety;
  final Value<String?> surgeries;
  final Value<String?> recentInjuries;
  final Value<String?> remarks;
  final Value<int> rowid;
  const PlayerMedicalCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.teamId = const Value.absent(),
    this.playerId = const Value.absent(),
    this.consentDate = const Value.absent(),
    this.consentBy = const Value.absent(),
    this.allergies = const Value.absent(),
    this.conditions = const Value.absent(),
    this.lowBpAnxiety = const Value.absent(),
    this.surgeries = const Value.absent(),
    this.recentInjuries = const Value.absent(),
    this.remarks = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlayerMedicalCompanion.insert({
    required String id,
    required String createdAt,
    required String updatedAt,
    this.serverUpdatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    required String teamId,
    required String playerId,
    required String consentDate,
    required String consentBy,
    this.allergies = const Value.absent(),
    this.conditions = const Value.absent(),
    this.lowBpAnxiety = const Value.absent(),
    this.surgeries = const Value.absent(),
    this.recentInjuries = const Value.absent(),
    this.remarks = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       teamId = Value(teamId),
       playerId = Value(playerId),
       consentDate = Value(consentDate),
       consentBy = Value(consentBy);
  static Insertable<MedicalRecord> custom({
    Expression<String>? id,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? serverUpdatedAt,
    Expression<bool>? deleted,
    Expression<bool>? isDirty,
    Expression<String>? teamId,
    Expression<String>? playerId,
    Expression<String>? consentDate,
    Expression<String>? consentBy,
    Expression<String>? allergies,
    Expression<String>? conditions,
    Expression<String>? lowBpAnxiety,
    Expression<String>? surgeries,
    Expression<String>? recentInjuries,
    Expression<String>? remarks,
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
      if (playerId != null) 'player_id': playerId,
      if (consentDate != null) 'consent_date': consentDate,
      if (consentBy != null) 'consent_by': consentBy,
      if (allergies != null) 'allergies': allergies,
      if (conditions != null) 'conditions': conditions,
      if (lowBpAnxiety != null) 'low_bp_anxiety': lowBpAnxiety,
      if (surgeries != null) 'surgeries': surgeries,
      if (recentInjuries != null) 'recent_injuries': recentInjuries,
      if (remarks != null) 'remarks': remarks,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlayerMedicalCompanion copyWith({
    Value<String>? id,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? serverUpdatedAt,
    Value<bool>? deleted,
    Value<bool>? isDirty,
    Value<String>? teamId,
    Value<String>? playerId,
    Value<String>? consentDate,
    Value<String>? consentBy,
    Value<String?>? allergies,
    Value<String?>? conditions,
    Value<String?>? lowBpAnxiety,
    Value<String?>? surgeries,
    Value<String?>? recentInjuries,
    Value<String?>? remarks,
    Value<int>? rowid,
  }) {
    return PlayerMedicalCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      deleted: deleted ?? this.deleted,
      isDirty: isDirty ?? this.isDirty,
      teamId: teamId ?? this.teamId,
      playerId: playerId ?? this.playerId,
      consentDate: consentDate ?? this.consentDate,
      consentBy: consentBy ?? this.consentBy,
      allergies: allergies ?? this.allergies,
      conditions: conditions ?? this.conditions,
      lowBpAnxiety: lowBpAnxiety ?? this.lowBpAnxiety,
      surgeries: surgeries ?? this.surgeries,
      recentInjuries: recentInjuries ?? this.recentInjuries,
      remarks: remarks ?? this.remarks,
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
    if (playerId.present) {
      map['player_id'] = Variable<String>(playerId.value);
    }
    if (consentDate.present) {
      map['consent_date'] = Variable<String>(consentDate.value);
    }
    if (consentBy.present) {
      map['consent_by'] = Variable<String>(consentBy.value);
    }
    if (allergies.present) {
      map['allergies'] = Variable<String>(allergies.value);
    }
    if (conditions.present) {
      map['conditions'] = Variable<String>(conditions.value);
    }
    if (lowBpAnxiety.present) {
      map['low_bp_anxiety'] = Variable<String>(lowBpAnxiety.value);
    }
    if (surgeries.present) {
      map['surgeries'] = Variable<String>(surgeries.value);
    }
    if (recentInjuries.present) {
      map['recent_injuries'] = Variable<String>(recentInjuries.value);
    }
    if (remarks.present) {
      map['remarks'] = Variable<String>(remarks.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayerMedicalCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('teamId: $teamId, ')
          ..write('playerId: $playerId, ')
          ..write('consentDate: $consentDate, ')
          ..write('consentBy: $consentBy, ')
          ..write('allergies: $allergies, ')
          ..write('conditions: $conditions, ')
          ..write('lowBpAnxiety: $lowBpAnxiety, ')
          ..write('surgeries: $surgeries, ')
          ..write('recentInjuries: $recentInjuries, ')
          ..write('remarks: $remarks, ')
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
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $SessionPlayersTable sessionPlayers = $SessionPlayersTable(this);
  late final $WellnessTable wellness = $WellnessTable(this);
  late final $MatchesTable matches = $MatchesTable(this);
  late final $MatchPlayersTable matchPlayers = $MatchPlayersTable(this);
  late final $MatchEventsTable matchEvents = $MatchEventsTable(this);
  late final $InjuriesTable injuries = $InjuriesTable(this);
  late final $TestTypesTable testTypes = $TestTypesTable(this);
  late final $TestResultsTable testResults = $TestResultsTable(this);
  late final $PlayerProfilesTable playerProfiles = $PlayerProfilesTable(this);
  late final $PlayerMedicalTable playerMedical = $PlayerMedicalTable(this);
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
    sessions,
    sessionPlayers,
    wellness,
    matches,
    matchPlayers,
    matchEvents,
    injuries,
    testTypes,
    testResults,
    playerProfiles,
    playerMedical,
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
  Value<String?> detailedPosition,
  Value<String?> secondaryPosition,
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
  Value<String?> detailedPosition,
  Value<String?> secondaryPosition,
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

  ColumnFilters<String> get detailedPosition => $composableBuilder(
    column: $table.detailedPosition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get secondaryPosition => $composableBuilder(
    column: $table.secondaryPosition,
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

  ColumnOrderings<String> get detailedPosition => $composableBuilder(
    column: $table.detailedPosition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secondaryPosition => $composableBuilder(
    column: $table.secondaryPosition,
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

  GeneratedColumn<String> get detailedPosition => $composableBuilder(
    column: $table.detailedPosition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get secondaryPosition => $composableBuilder(
    column: $table.secondaryPosition,
    builder: (column) => column,
  );
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
                Value<String?> detailedPosition = const Value.absent(),
                Value<String?> secondaryPosition = const Value.absent(),
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
                detailedPosition: detailedPosition,
                secondaryPosition: secondaryPosition,
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
                Value<String?> detailedPosition = const Value.absent(),
                Value<String?> secondaryPosition = const Value.absent(),
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
                detailedPosition: detailedPosition,
                secondaryPosition: secondaryPosition,
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
typedef $$SessionsTableCreateCompanionBuilder = SessionsCompanion Function({
  required String id,
  required String createdAt,
  required String updatedAt,
  Value<String?> serverUpdatedAt,
  Value<bool> deleted,
  Value<bool> isDirty,
  required String teamId,
  required String date,
  required String startTime,
  required String type,
  Value<int> plannedDurationMin,
  Value<String?> objective,
  Value<String?> remarks,
  Value<String> status,
  Value<int?> plannedRpe,
  Value<int> rowid,
});
typedef $$SessionsTableUpdateCompanionBuilder = SessionsCompanion Function({
  Value<String> id,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String?> serverUpdatedAt,
  Value<bool> deleted,
  Value<bool> isDirty,
  Value<String> teamId,
  Value<String> date,
  Value<String> startTime,
  Value<String> type,
  Value<int> plannedDurationMin,
  Value<String?> objective,
  Value<String?> remarks,
  Value<String> status,
  Value<int?> plannedRpe,
  Value<int> rowid,
});

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
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

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedDurationMin => $composableBuilder(
    column: $table.plannedDurationMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get objective => $composableBuilder(
    column: $table.objective,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedRpe => $composableBuilder(
    column: $table.plannedRpe,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
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

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedDurationMin => $composableBuilder(
    column: $table.plannedDurationMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get objective => $composableBuilder(
    column: $table.objective,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedRpe => $composableBuilder(
    column: $table.plannedRpe,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
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

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get plannedDurationMin => $composableBuilder(
    column: $table.plannedDurationMin,
    builder: (column) => column,
  );

  GeneratedColumn<String> get objective =>
      $composableBuilder(column: $table.objective, builder: (column) => column);

  GeneratedColumn<String> get remarks =>
      $composableBuilder(column: $table.remarks, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get plannedRpe => $composableBuilder(
    column: $table.plannedRpe,
    builder: (column) => column,
  );
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          TrainingSession,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (
            TrainingSession,
            BaseReferences<_$AppDatabase, $SessionsTable, TrainingSession>,
          ),
          TrainingSession,
          PrefetchHooks Function()
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> serverUpdatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<String> teamId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> startTime = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> plannedDurationMin = const Value.absent(),
                Value<String?> objective = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> plannedRpe = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                deleted: deleted,
                isDirty: isDirty,
                teamId: teamId,
                date: date,
                startTime: startTime,
                type: type,
                plannedDurationMin: plannedDurationMin,
                objective: objective,
                remarks: remarks,
                status: status,
                plannedRpe: plannedRpe,
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
                required String date,
                required String startTime,
                required String type,
                Value<int> plannedDurationMin = const Value.absent(),
                Value<String?> objective = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> plannedRpe = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                deleted: deleted,
                isDirty: isDirty,
                teamId: teamId,
                date: date,
                startTime: startTime,
                type: type,
                plannedDurationMin: plannedDurationMin,
                objective: objective,
                remarks: remarks,
                status: status,
                plannedRpe: plannedRpe,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionsTable, TrainingSession>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SessionsTable,
                    TrainingSession
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      TrainingSession,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (
        TrainingSession,
        BaseReferences<_$AppDatabase, $SessionsTable, TrainingSession>,
      ),
      TrainingSession,
      PrefetchHooks Function()
    >;
typedef $$SessionPlayersTableCreateCompanionBuilder =
    SessionPlayersCompanion Function({
      required String id,
      required String createdAt,
      required String updatedAt,
      Value<String?> serverUpdatedAt,
      Value<bool> deleted,
      Value<bool> isDirty,
      required String teamId,
      required String sessionId,
      required String playerId,
      Value<bool> present,
      Value<String?> absenceReason,
      Value<int?> durationMin,
      Value<int?> rpe,
      Value<String?> remark,
      Value<int> rowid,
    });
typedef $$SessionPlayersTableUpdateCompanionBuilder =
    SessionPlayersCompanion Function({
      Value<String> id,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String?> serverUpdatedAt,
      Value<bool> deleted,
      Value<bool> isDirty,
      Value<String> teamId,
      Value<String> sessionId,
      Value<String> playerId,
      Value<bool> present,
      Value<String?> absenceReason,
      Value<int?> durationMin,
      Value<int?> rpe,
      Value<String?> remark,
      Value<int> rowid,
    });

class $$SessionPlayersTableFilterComposer
    extends Composer<_$AppDatabase, $SessionPlayersTable> {
  $$SessionPlayersTableFilterComposer({
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

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get playerId => $composableBuilder(
    column: $table.playerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get present => $composableBuilder(
    column: $table.present,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get absenceReason => $composableBuilder(
    column: $table.absenceReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rpe => $composableBuilder(
    column: $table.rpe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionPlayersTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionPlayersTable> {
  $$SessionPlayersTableOrderingComposer({
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

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get playerId => $composableBuilder(
    column: $table.playerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get present => $composableBuilder(
    column: $table.present,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get absenceReason => $composableBuilder(
    column: $table.absenceReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rpe => $composableBuilder(
    column: $table.rpe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionPlayersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionPlayersTable> {
  $$SessionPlayersTableAnnotationComposer({
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

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get playerId =>
      $composableBuilder(column: $table.playerId, builder: (column) => column);

  GeneratedColumn<bool> get present =>
      $composableBuilder(column: $table.present, builder: (column) => column);

  GeneratedColumn<String> get absenceReason => $composableBuilder(
    column: $table.absenceReason,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rpe =>
      $composableBuilder(column: $table.rpe, builder: (column) => column);

  GeneratedColumn<String> get remark =>
      $composableBuilder(column: $table.remark, builder: (column) => column);
}

class $$SessionPlayersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionPlayersTable,
          SessionPlayer,
          $$SessionPlayersTableFilterComposer,
          $$SessionPlayersTableOrderingComposer,
          $$SessionPlayersTableAnnotationComposer,
          $$SessionPlayersTableCreateCompanionBuilder,
          $$SessionPlayersTableUpdateCompanionBuilder,
          (
            SessionPlayer,
            BaseReferences<_$AppDatabase, $SessionPlayersTable, SessionPlayer>,
          ),
          SessionPlayer,
          PrefetchHooks Function()
        > {
  $$SessionPlayersTableTableManager(
    _$AppDatabase db,
    $SessionPlayersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionPlayersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionPlayersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionPlayersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> serverUpdatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<String> teamId = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> playerId = const Value.absent(),
                Value<bool> present = const Value.absent(),
                Value<String?> absenceReason = const Value.absent(),
                Value<int?> durationMin = const Value.absent(),
                Value<int?> rpe = const Value.absent(),
                Value<String?> remark = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionPlayersCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                deleted: deleted,
                isDirty: isDirty,
                teamId: teamId,
                sessionId: sessionId,
                playerId: playerId,
                present: present,
                absenceReason: absenceReason,
                durationMin: durationMin,
                rpe: rpe,
                remark: remark,
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
                required String sessionId,
                required String playerId,
                Value<bool> present = const Value.absent(),
                Value<String?> absenceReason = const Value.absent(),
                Value<int?> durationMin = const Value.absent(),
                Value<int?> rpe = const Value.absent(),
                Value<String?> remark = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionPlayersCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                deleted: deleted,
                isDirty: isDirty,
                teamId: teamId,
                sessionId: sessionId,
                playerId: playerId,
                present: present,
                absenceReason: absenceReason,
                durationMin: durationMin,
                rpe: rpe,
                remark: remark,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionPlayersTable, SessionPlayer>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SessionPlayersTable,
                    SessionPlayer
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionPlayersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionPlayersTable,
      SessionPlayer,
      $$SessionPlayersTableFilterComposer,
      $$SessionPlayersTableOrderingComposer,
      $$SessionPlayersTableAnnotationComposer,
      $$SessionPlayersTableCreateCompanionBuilder,
      $$SessionPlayersTableUpdateCompanionBuilder,
      (
        SessionPlayer,
        BaseReferences<_$AppDatabase, $SessionPlayersTable, SessionPlayer>,
      ),
      SessionPlayer,
      PrefetchHooks Function()
    >;
typedef $$WellnessTableCreateCompanionBuilder = WellnessCompanion Function({
  required String id,
  required String createdAt,
  required String updatedAt,
  Value<String?> serverUpdatedAt,
  Value<bool> deleted,
  Value<bool> isDirty,
  required String teamId,
  required String sessionId,
  required String playerId,
  required double sleepHours,
  required int sleepQuality,
  required int fatigue,
  required int soreness,
  required int stress,
  required int mood,
  Value<String?> remark,
  Value<int> rowid,
});
typedef $$WellnessTableUpdateCompanionBuilder = WellnessCompanion Function({
  Value<String> id,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String?> serverUpdatedAt,
  Value<bool> deleted,
  Value<bool> isDirty,
  Value<String> teamId,
  Value<String> sessionId,
  Value<String> playerId,
  Value<double> sleepHours,
  Value<int> sleepQuality,
  Value<int> fatigue,
  Value<int> soreness,
  Value<int> stress,
  Value<int> mood,
  Value<String?> remark,
  Value<int> rowid,
});

class $$WellnessTableFilterComposer
    extends Composer<_$AppDatabase, $WellnessTable> {
  $$WellnessTableFilterComposer({
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

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get playerId => $composableBuilder(
    column: $table.playerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sleepHours => $composableBuilder(
    column: $table.sleepHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sleepQuality => $composableBuilder(
    column: $table.sleepQuality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fatigue => $composableBuilder(
    column: $table.fatigue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get soreness => $composableBuilder(
    column: $table.soreness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stress => $composableBuilder(
    column: $table.stress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WellnessTableOrderingComposer
    extends Composer<_$AppDatabase, $WellnessTable> {
  $$WellnessTableOrderingComposer({
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

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get playerId => $composableBuilder(
    column: $table.playerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sleepHours => $composableBuilder(
    column: $table.sleepHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sleepQuality => $composableBuilder(
    column: $table.sleepQuality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fatigue => $composableBuilder(
    column: $table.fatigue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get soreness => $composableBuilder(
    column: $table.soreness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stress => $composableBuilder(
    column: $table.stress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WellnessTableAnnotationComposer
    extends Composer<_$AppDatabase, $WellnessTable> {
  $$WellnessTableAnnotationComposer({
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

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get playerId =>
      $composableBuilder(column: $table.playerId, builder: (column) => column);

  GeneratedColumn<double> get sleepHours => $composableBuilder(
    column: $table.sleepHours,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sleepQuality => $composableBuilder(
    column: $table.sleepQuality,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fatigue =>
      $composableBuilder(column: $table.fatigue, builder: (column) => column);

  GeneratedColumn<int> get soreness =>
      $composableBuilder(column: $table.soreness, builder: (column) => column);

  GeneratedColumn<int> get stress =>
      $composableBuilder(column: $table.stress, builder: (column) => column);

  GeneratedColumn<int> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<String> get remark =>
      $composableBuilder(column: $table.remark, builder: (column) => column);
}

class $$WellnessTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WellnessTable,
          WellnessEntry,
          $$WellnessTableFilterComposer,
          $$WellnessTableOrderingComposer,
          $$WellnessTableAnnotationComposer,
          $$WellnessTableCreateCompanionBuilder,
          $$WellnessTableUpdateCompanionBuilder,
          (
            WellnessEntry,
            BaseReferences<_$AppDatabase, $WellnessTable, WellnessEntry>,
          ),
          WellnessEntry,
          PrefetchHooks Function()
        > {
  $$WellnessTableTableManager(_$AppDatabase db, $WellnessTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WellnessTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WellnessTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WellnessTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> serverUpdatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<String> teamId = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> playerId = const Value.absent(),
                Value<double> sleepHours = const Value.absent(),
                Value<int> sleepQuality = const Value.absent(),
                Value<int> fatigue = const Value.absent(),
                Value<int> soreness = const Value.absent(),
                Value<int> stress = const Value.absent(),
                Value<int> mood = const Value.absent(),
                Value<String?> remark = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WellnessCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                deleted: deleted,
                isDirty: isDirty,
                teamId: teamId,
                sessionId: sessionId,
                playerId: playerId,
                sleepHours: sleepHours,
                sleepQuality: sleepQuality,
                fatigue: fatigue,
                soreness: soreness,
                stress: stress,
                mood: mood,
                remark: remark,
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
                required String sessionId,
                required String playerId,
                required double sleepHours,
                required int sleepQuality,
                required int fatigue,
                required int soreness,
                required int stress,
                required int mood,
                Value<String?> remark = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WellnessCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                deleted: deleted,
                isDirty: isDirty,
                teamId: teamId,
                sessionId: sessionId,
                playerId: playerId,
                sleepHours: sleepHours,
                sleepQuality: sleepQuality,
                fatigue: fatigue,
                soreness: soreness,
                stress: stress,
                mood: mood,
                remark: remark,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WellnessTable, WellnessEntry>(table),
                  BaseReferences<_$AppDatabase, $WellnessTable, WellnessEntry>(
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

typedef $$WellnessTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WellnessTable,
      WellnessEntry,
      $$WellnessTableFilterComposer,
      $$WellnessTableOrderingComposer,
      $$WellnessTableAnnotationComposer,
      $$WellnessTableCreateCompanionBuilder,
      $$WellnessTableUpdateCompanionBuilder,
      (
        WellnessEntry,
        BaseReferences<_$AppDatabase, $WellnessTable, WellnessEntry>,
      ),
      WellnessEntry,
      PrefetchHooks Function()
    >;
typedef $$MatchesTableCreateCompanionBuilder = MatchesCompanion Function({
  required String id,
  required String createdAt,
  required String updatedAt,
  Value<String?> serverUpdatedAt,
  Value<bool> deleted,
  Value<bool> isDirty,
  required String teamId,
  required String date,
  required String kickOffTime,
  required String opponent,
  required String homeAway,
  required String competition,
  Value<int> durationMin,
  Value<int?> goalsFor,
  Value<int?> goalsAgainst,
  Value<String?> remarks,
  Value<String> status,
  Value<String?> phase,
  Value<int?> matchday,
  Value<int> rowid,
});
typedef $$MatchesTableUpdateCompanionBuilder = MatchesCompanion Function({
  Value<String> id,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String?> serverUpdatedAt,
  Value<bool> deleted,
  Value<bool> isDirty,
  Value<String> teamId,
  Value<String> date,
  Value<String> kickOffTime,
  Value<String> opponent,
  Value<String> homeAway,
  Value<String> competition,
  Value<int> durationMin,
  Value<int?> goalsFor,
  Value<int?> goalsAgainst,
  Value<String?> remarks,
  Value<String> status,
  Value<String?> phase,
  Value<int?> matchday,
  Value<int> rowid,
});

class $$MatchesTableFilterComposer
    extends Composer<_$AppDatabase, $MatchesTable> {
  $$MatchesTableFilterComposer({
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

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kickOffTime => $composableBuilder(
    column: $table.kickOffTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get opponent => $composableBuilder(
    column: $table.opponent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get homeAway => $composableBuilder(
    column: $table.homeAway,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get competition => $composableBuilder(
    column: $table.competition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get goalsFor => $composableBuilder(
    column: $table.goalsFor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get goalsAgainst => $composableBuilder(
    column: $table.goalsAgainst,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get matchday => $composableBuilder(
    column: $table.matchday,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MatchesTableOrderingComposer
    extends Composer<_$AppDatabase, $MatchesTable> {
  $$MatchesTableOrderingComposer({
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

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kickOffTime => $composableBuilder(
    column: $table.kickOffTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get opponent => $composableBuilder(
    column: $table.opponent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get homeAway => $composableBuilder(
    column: $table.homeAway,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get competition => $composableBuilder(
    column: $table.competition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get goalsFor => $composableBuilder(
    column: $table.goalsFor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get goalsAgainst => $composableBuilder(
    column: $table.goalsAgainst,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get matchday => $composableBuilder(
    column: $table.matchday,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MatchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MatchesTable> {
  $$MatchesTableAnnotationComposer({
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

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get kickOffTime => $composableBuilder(
    column: $table.kickOffTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get opponent =>
      $composableBuilder(column: $table.opponent, builder: (column) => column);

  GeneratedColumn<String> get homeAway =>
      $composableBuilder(column: $table.homeAway, builder: (column) => column);

  GeneratedColumn<String> get competition => $composableBuilder(
    column: $table.competition,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get goalsFor =>
      $composableBuilder(column: $table.goalsFor, builder: (column) => column);

  GeneratedColumn<int> get goalsAgainst => $composableBuilder(
    column: $table.goalsAgainst,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remarks =>
      $composableBuilder(column: $table.remarks, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get phase =>
      $composableBuilder(column: $table.phase, builder: (column) => column);

  GeneratedColumn<int> get matchday =>
      $composableBuilder(column: $table.matchday, builder: (column) => column);
}

class $$MatchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MatchesTable,
          FootballMatch,
          $$MatchesTableFilterComposer,
          $$MatchesTableOrderingComposer,
          $$MatchesTableAnnotationComposer,
          $$MatchesTableCreateCompanionBuilder,
          $$MatchesTableUpdateCompanionBuilder,
          (
            FootballMatch,
            BaseReferences<_$AppDatabase, $MatchesTable, FootballMatch>,
          ),
          FootballMatch,
          PrefetchHooks Function()
        > {
  $$MatchesTableTableManager(_$AppDatabase db, $MatchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> serverUpdatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<String> teamId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> kickOffTime = const Value.absent(),
                Value<String> opponent = const Value.absent(),
                Value<String> homeAway = const Value.absent(),
                Value<String> competition = const Value.absent(),
                Value<int> durationMin = const Value.absent(),
                Value<int?> goalsFor = const Value.absent(),
                Value<int?> goalsAgainst = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> phase = const Value.absent(),
                Value<int?> matchday = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MatchesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                deleted: deleted,
                isDirty: isDirty,
                teamId: teamId,
                date: date,
                kickOffTime: kickOffTime,
                opponent: opponent,
                homeAway: homeAway,
                competition: competition,
                durationMin: durationMin,
                goalsFor: goalsFor,
                goalsAgainst: goalsAgainst,
                remarks: remarks,
                status: status,
                phase: phase,
                matchday: matchday,
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
                required String date,
                required String kickOffTime,
                required String opponent,
                required String homeAway,
                required String competition,
                Value<int> durationMin = const Value.absent(),
                Value<int?> goalsFor = const Value.absent(),
                Value<int?> goalsAgainst = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> phase = const Value.absent(),
                Value<int?> matchday = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MatchesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                deleted: deleted,
                isDirty: isDirty,
                teamId: teamId,
                date: date,
                kickOffTime: kickOffTime,
                opponent: opponent,
                homeAway: homeAway,
                competition: competition,
                durationMin: durationMin,
                goalsFor: goalsFor,
                goalsAgainst: goalsAgainst,
                remarks: remarks,
                status: status,
                phase: phase,
                matchday: matchday,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MatchesTable, FootballMatch>(table),
                  BaseReferences<_$AppDatabase, $MatchesTable, FootballMatch>(
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

typedef $$MatchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MatchesTable,
      FootballMatch,
      $$MatchesTableFilterComposer,
      $$MatchesTableOrderingComposer,
      $$MatchesTableAnnotationComposer,
      $$MatchesTableCreateCompanionBuilder,
      $$MatchesTableUpdateCompanionBuilder,
      (
        FootballMatch,
        BaseReferences<_$AppDatabase, $MatchesTable, FootballMatch>,
      ),
      FootballMatch,
      PrefetchHooks Function()
    >;
typedef $$MatchPlayersTableCreateCompanionBuilder =
    MatchPlayersCompanion Function({
      required String id,
      required String createdAt,
      required String updatedAt,
      Value<String?> serverUpdatedAt,
      Value<bool> deleted,
      Value<bool> isDirty,
      required String teamId,
      required String matchId,
      required String playerId,
      Value<bool> present,
      Value<String?> absenceReason,
      Value<String?> role,
      Value<int?> minutesPlayed,
      Value<int?> rpe,
      Value<String?> remark,
      Value<int> rowid,
    });
typedef $$MatchPlayersTableUpdateCompanionBuilder =
    MatchPlayersCompanion Function({
      Value<String> id,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String?> serverUpdatedAt,
      Value<bool> deleted,
      Value<bool> isDirty,
      Value<String> teamId,
      Value<String> matchId,
      Value<String> playerId,
      Value<bool> present,
      Value<String?> absenceReason,
      Value<String?> role,
      Value<int?> minutesPlayed,
      Value<int?> rpe,
      Value<String?> remark,
      Value<int> rowid,
    });

class $$MatchPlayersTableFilterComposer
    extends Composer<_$AppDatabase, $MatchPlayersTable> {
  $$MatchPlayersTableFilterComposer({
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

  ColumnFilters<String> get matchId => $composableBuilder(
    column: $table.matchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get playerId => $composableBuilder(
    column: $table.playerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get present => $composableBuilder(
    column: $table.present,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get absenceReason => $composableBuilder(
    column: $table.absenceReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minutesPlayed => $composableBuilder(
    column: $table.minutesPlayed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rpe => $composableBuilder(
    column: $table.rpe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MatchPlayersTableOrderingComposer
    extends Composer<_$AppDatabase, $MatchPlayersTable> {
  $$MatchPlayersTableOrderingComposer({
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

  ColumnOrderings<String> get matchId => $composableBuilder(
    column: $table.matchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get playerId => $composableBuilder(
    column: $table.playerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get present => $composableBuilder(
    column: $table.present,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get absenceReason => $composableBuilder(
    column: $table.absenceReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minutesPlayed => $composableBuilder(
    column: $table.minutesPlayed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rpe => $composableBuilder(
    column: $table.rpe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MatchPlayersTableAnnotationComposer
    extends Composer<_$AppDatabase, $MatchPlayersTable> {
  $$MatchPlayersTableAnnotationComposer({
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

  GeneratedColumn<String> get matchId =>
      $composableBuilder(column: $table.matchId, builder: (column) => column);

  GeneratedColumn<String> get playerId =>
      $composableBuilder(column: $table.playerId, builder: (column) => column);

  GeneratedColumn<bool> get present =>
      $composableBuilder(column: $table.present, builder: (column) => column);

  GeneratedColumn<String> get absenceReason => $composableBuilder(
    column: $table.absenceReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<int> get minutesPlayed => $composableBuilder(
    column: $table.minutesPlayed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rpe =>
      $composableBuilder(column: $table.rpe, builder: (column) => column);

  GeneratedColumn<String> get remark =>
      $composableBuilder(column: $table.remark, builder: (column) => column);
}

class $$MatchPlayersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MatchPlayersTable,
          MatchPlayer,
          $$MatchPlayersTableFilterComposer,
          $$MatchPlayersTableOrderingComposer,
          $$MatchPlayersTableAnnotationComposer,
          $$MatchPlayersTableCreateCompanionBuilder,
          $$MatchPlayersTableUpdateCompanionBuilder,
          (
            MatchPlayer,
            BaseReferences<_$AppDatabase, $MatchPlayersTable, MatchPlayer>,
          ),
          MatchPlayer,
          PrefetchHooks Function()
        > {
  $$MatchPlayersTableTableManager(_$AppDatabase db, $MatchPlayersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MatchPlayersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MatchPlayersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MatchPlayersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> serverUpdatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<String> teamId = const Value.absent(),
                Value<String> matchId = const Value.absent(),
                Value<String> playerId = const Value.absent(),
                Value<bool> present = const Value.absent(),
                Value<String?> absenceReason = const Value.absent(),
                Value<String?> role = const Value.absent(),
                Value<int?> minutesPlayed = const Value.absent(),
                Value<int?> rpe = const Value.absent(),
                Value<String?> remark = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MatchPlayersCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                deleted: deleted,
                isDirty: isDirty,
                teamId: teamId,
                matchId: matchId,
                playerId: playerId,
                present: present,
                absenceReason: absenceReason,
                role: role,
                minutesPlayed: minutesPlayed,
                rpe: rpe,
                remark: remark,
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
                required String matchId,
                required String playerId,
                Value<bool> present = const Value.absent(),
                Value<String?> absenceReason = const Value.absent(),
                Value<String?> role = const Value.absent(),
                Value<int?> minutesPlayed = const Value.absent(),
                Value<int?> rpe = const Value.absent(),
                Value<String?> remark = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MatchPlayersCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                deleted: deleted,
                isDirty: isDirty,
                teamId: teamId,
                matchId: matchId,
                playerId: playerId,
                present: present,
                absenceReason: absenceReason,
                role: role,
                minutesPlayed: minutesPlayed,
                rpe: rpe,
                remark: remark,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MatchPlayersTable, MatchPlayer>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $MatchPlayersTable,
                    MatchPlayer
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MatchPlayersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MatchPlayersTable,
      MatchPlayer,
      $$MatchPlayersTableFilterComposer,
      $$MatchPlayersTableOrderingComposer,
      $$MatchPlayersTableAnnotationComposer,
      $$MatchPlayersTableCreateCompanionBuilder,
      $$MatchPlayersTableUpdateCompanionBuilder,
      (
        MatchPlayer,
        BaseReferences<_$AppDatabase, $MatchPlayersTable, MatchPlayer>,
      ),
      MatchPlayer,
      PrefetchHooks Function()
    >;
typedef $$MatchEventsTableCreateCompanionBuilder =
    MatchEventsCompanion Function({
      required String id,
      required String createdAt,
      required String updatedAt,
      Value<String?> serverUpdatedAt,
      Value<bool> deleted,
      Value<bool> isDirty,
      required String teamId,
      required String matchId,
      required String playerId,
      required String type,
      required int minute,
      Value<String?> assistPlayerId,
      Value<String?> remark,
      Value<int> rowid,
    });
typedef $$MatchEventsTableUpdateCompanionBuilder =
    MatchEventsCompanion Function({
      Value<String> id,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String?> serverUpdatedAt,
      Value<bool> deleted,
      Value<bool> isDirty,
      Value<String> teamId,
      Value<String> matchId,
      Value<String> playerId,
      Value<String> type,
      Value<int> minute,
      Value<String?> assistPlayerId,
      Value<String?> remark,
      Value<int> rowid,
    });

class $$MatchEventsTableFilterComposer
    extends Composer<_$AppDatabase, $MatchEventsTable> {
  $$MatchEventsTableFilterComposer({
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

  ColumnFilters<String> get matchId => $composableBuilder(
    column: $table.matchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get playerId => $composableBuilder(
    column: $table.playerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minute => $composableBuilder(
    column: $table.minute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assistPlayerId => $composableBuilder(
    column: $table.assistPlayerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MatchEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $MatchEventsTable> {
  $$MatchEventsTableOrderingComposer({
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

  ColumnOrderings<String> get matchId => $composableBuilder(
    column: $table.matchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get playerId => $composableBuilder(
    column: $table.playerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minute => $composableBuilder(
    column: $table.minute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assistPlayerId => $composableBuilder(
    column: $table.assistPlayerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MatchEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MatchEventsTable> {
  $$MatchEventsTableAnnotationComposer({
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

  GeneratedColumn<String> get matchId =>
      $composableBuilder(column: $table.matchId, builder: (column) => column);

  GeneratedColumn<String> get playerId =>
      $composableBuilder(column: $table.playerId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get minute =>
      $composableBuilder(column: $table.minute, builder: (column) => column);

  GeneratedColumn<String> get assistPlayerId => $composableBuilder(
    column: $table.assistPlayerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remark =>
      $composableBuilder(column: $table.remark, builder: (column) => column);
}

class $$MatchEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MatchEventsTable,
          MatchEvent,
          $$MatchEventsTableFilterComposer,
          $$MatchEventsTableOrderingComposer,
          $$MatchEventsTableAnnotationComposer,
          $$MatchEventsTableCreateCompanionBuilder,
          $$MatchEventsTableUpdateCompanionBuilder,
          (
            MatchEvent,
            BaseReferences<_$AppDatabase, $MatchEventsTable, MatchEvent>,
          ),
          MatchEvent,
          PrefetchHooks Function()
        > {
  $$MatchEventsTableTableManager(_$AppDatabase db, $MatchEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MatchEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MatchEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MatchEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> serverUpdatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<String> teamId = const Value.absent(),
                Value<String> matchId = const Value.absent(),
                Value<String> playerId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> minute = const Value.absent(),
                Value<String?> assistPlayerId = const Value.absent(),
                Value<String?> remark = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MatchEventsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                deleted: deleted,
                isDirty: isDirty,
                teamId: teamId,
                matchId: matchId,
                playerId: playerId,
                type: type,
                minute: minute,
                assistPlayerId: assistPlayerId,
                remark: remark,
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
                required String matchId,
                required String playerId,
                required String type,
                required int minute,
                Value<String?> assistPlayerId = const Value.absent(),
                Value<String?> remark = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MatchEventsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                deleted: deleted,
                isDirty: isDirty,
                teamId: teamId,
                matchId: matchId,
                playerId: playerId,
                type: type,
                minute: minute,
                assistPlayerId: assistPlayerId,
                remark: remark,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MatchEventsTable, MatchEvent>(table),
                  BaseReferences<_$AppDatabase, $MatchEventsTable, MatchEvent>(
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

typedef $$MatchEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MatchEventsTable,
      MatchEvent,
      $$MatchEventsTableFilterComposer,
      $$MatchEventsTableOrderingComposer,
      $$MatchEventsTableAnnotationComposer,
      $$MatchEventsTableCreateCompanionBuilder,
      $$MatchEventsTableUpdateCompanionBuilder,
      (
        MatchEvent,
        BaseReferences<_$AppDatabase, $MatchEventsTable, MatchEvent>,
      ),
      MatchEvent,
      PrefetchHooks Function()
    >;
typedef $$InjuriesTableCreateCompanionBuilder = InjuriesCompanion Function({
  required String id,
  required String createdAt,
  required String updatedAt,
  Value<String?> serverUpdatedAt,
  Value<bool> deleted,
  Value<bool> isDirty,
  required String teamId,
  required String playerId,
  Value<String?> sessionId,
  Value<String?> matchId,
  Value<int?> minute,
  required String date,
  required String bodyArea,
  Value<String?> side,
  required String type,
  required String mechanism,
  required String severity,
  Value<String?> description,
  Value<String?> expectedReturnDate,
  Value<String?> returnDate,
  Value<int> rowid,
});
typedef $$InjuriesTableUpdateCompanionBuilder = InjuriesCompanion Function({
  Value<String> id,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String?> serverUpdatedAt,
  Value<bool> deleted,
  Value<bool> isDirty,
  Value<String> teamId,
  Value<String> playerId,
  Value<String?> sessionId,
  Value<String?> matchId,
  Value<int?> minute,
  Value<String> date,
  Value<String> bodyArea,
  Value<String?> side,
  Value<String> type,
  Value<String> mechanism,
  Value<String> severity,
  Value<String?> description,
  Value<String?> expectedReturnDate,
  Value<String?> returnDate,
  Value<int> rowid,
});

class $$InjuriesTableFilterComposer
    extends Composer<_$AppDatabase, $InjuriesTable> {
  $$InjuriesTableFilterComposer({
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

  ColumnFilters<String> get playerId => $composableBuilder(
    column: $table.playerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get matchId => $composableBuilder(
    column: $table.matchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minute => $composableBuilder(
    column: $table.minute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bodyArea => $composableBuilder(
    column: $table.bodyArea,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get side => $composableBuilder(
    column: $table.side,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mechanism => $composableBuilder(
    column: $table.mechanism,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get expectedReturnDate => $composableBuilder(
    column: $table.expectedReturnDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get returnDate => $composableBuilder(
    column: $table.returnDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InjuriesTableOrderingComposer
    extends Composer<_$AppDatabase, $InjuriesTable> {
  $$InjuriesTableOrderingComposer({
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

  ColumnOrderings<String> get playerId => $composableBuilder(
    column: $table.playerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get matchId => $composableBuilder(
    column: $table.matchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minute => $composableBuilder(
    column: $table.minute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bodyArea => $composableBuilder(
    column: $table.bodyArea,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get side => $composableBuilder(
    column: $table.side,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mechanism => $composableBuilder(
    column: $table.mechanism,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expectedReturnDate => $composableBuilder(
    column: $table.expectedReturnDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get returnDate => $composableBuilder(
    column: $table.returnDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InjuriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InjuriesTable> {
  $$InjuriesTableAnnotationComposer({
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

  GeneratedColumn<String> get playerId =>
      $composableBuilder(column: $table.playerId, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get matchId =>
      $composableBuilder(column: $table.matchId, builder: (column) => column);

  GeneratedColumn<int> get minute =>
      $composableBuilder(column: $table.minute, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get bodyArea =>
      $composableBuilder(column: $table.bodyArea, builder: (column) => column);

  GeneratedColumn<String> get side =>
      $composableBuilder(column: $table.side, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get mechanism =>
      $composableBuilder(column: $table.mechanism, builder: (column) => column);

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get expectedReturnDate => $composableBuilder(
    column: $table.expectedReturnDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get returnDate => $composableBuilder(
    column: $table.returnDate,
    builder: (column) => column,
  );
}

class $$InjuriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InjuriesTable,
          Injury,
          $$InjuriesTableFilterComposer,
          $$InjuriesTableOrderingComposer,
          $$InjuriesTableAnnotationComposer,
          $$InjuriesTableCreateCompanionBuilder,
          $$InjuriesTableUpdateCompanionBuilder,
          (Injury, BaseReferences<_$AppDatabase, $InjuriesTable, Injury>),
          Injury,
          PrefetchHooks Function()
        > {
  $$InjuriesTableTableManager(_$AppDatabase db, $InjuriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InjuriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InjuriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InjuriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> serverUpdatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<String> teamId = const Value.absent(),
                Value<String> playerId = const Value.absent(),
                Value<String?> sessionId = const Value.absent(),
                Value<String?> matchId = const Value.absent(),
                Value<int?> minute = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> bodyArea = const Value.absent(),
                Value<String?> side = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> mechanism = const Value.absent(),
                Value<String> severity = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> expectedReturnDate = const Value.absent(),
                Value<String?> returnDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InjuriesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                deleted: deleted,
                isDirty: isDirty,
                teamId: teamId,
                playerId: playerId,
                sessionId: sessionId,
                matchId: matchId,
                minute: minute,
                date: date,
                bodyArea: bodyArea,
                side: side,
                type: type,
                mechanism: mechanism,
                severity: severity,
                description: description,
                expectedReturnDate: expectedReturnDate,
                returnDate: returnDate,
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
                required String playerId,
                Value<String?> sessionId = const Value.absent(),
                Value<String?> matchId = const Value.absent(),
                Value<int?> minute = const Value.absent(),
                required String date,
                required String bodyArea,
                Value<String?> side = const Value.absent(),
                required String type,
                required String mechanism,
                required String severity,
                Value<String?> description = const Value.absent(),
                Value<String?> expectedReturnDate = const Value.absent(),
                Value<String?> returnDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InjuriesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                deleted: deleted,
                isDirty: isDirty,
                teamId: teamId,
                playerId: playerId,
                sessionId: sessionId,
                matchId: matchId,
                minute: minute,
                date: date,
                bodyArea: bodyArea,
                side: side,
                type: type,
                mechanism: mechanism,
                severity: severity,
                description: description,
                expectedReturnDate: expectedReturnDate,
                returnDate: returnDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$InjuriesTable, Injury>(table),
                  BaseReferences<_$AppDatabase, $InjuriesTable, Injury>(
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

typedef $$InjuriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InjuriesTable,
      Injury,
      $$InjuriesTableFilterComposer,
      $$InjuriesTableOrderingComposer,
      $$InjuriesTableAnnotationComposer,
      $$InjuriesTableCreateCompanionBuilder,
      $$InjuriesTableUpdateCompanionBuilder,
      (Injury, BaseReferences<_$AppDatabase, $InjuriesTable, Injury>),
      Injury,
      PrefetchHooks Function()
    >;
typedef $$TestTypesTableCreateCompanionBuilder = TestTypesCompanion Function({
  required String id,
  required String createdAt,
  required String updatedAt,
  Value<String?> serverUpdatedAt,
  Value<bool> deleted,
  Value<bool> isDirty,
  Value<String?> teamId,
  Value<String?> code,
  required String name,
  Value<String?> unit,
  required String category,
  required String better,
  Value<int> attempts,
  Value<int> sortOrder,
  Value<int> rowid,
});
typedef $$TestTypesTableUpdateCompanionBuilder = TestTypesCompanion Function({
  Value<String> id,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String?> serverUpdatedAt,
  Value<bool> deleted,
  Value<bool> isDirty,
  Value<String?> teamId,
  Value<String?> code,
  Value<String> name,
  Value<String?> unit,
  Value<String> category,
  Value<String> better,
  Value<int> attempts,
  Value<int> sortOrder,
  Value<int> rowid,
});

class $$TestTypesTableFilterComposer
    extends Composer<_$AppDatabase, $TestTypesTable> {
  $$TestTypesTableFilterComposer({
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

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get better => $composableBuilder(
    column: $table.better,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TestTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $TestTypesTable> {
  $$TestTypesTableOrderingComposer({
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

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get better => $composableBuilder(
    column: $table.better,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TestTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TestTypesTable> {
  $$TestTypesTableAnnotationComposer({
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

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get better =>
      $composableBuilder(column: $table.better, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$TestTypesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TestTypesTable,
          TestType,
          $$TestTypesTableFilterComposer,
          $$TestTypesTableOrderingComposer,
          $$TestTypesTableAnnotationComposer,
          $$TestTypesTableCreateCompanionBuilder,
          $$TestTypesTableUpdateCompanionBuilder,
          (TestType, BaseReferences<_$AppDatabase, $TestTypesTable, TestType>),
          TestType,
          PrefetchHooks Function()
        > {
  $$TestTypesTableTableManager(_$AppDatabase db, $TestTypesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TestTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TestTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TestTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> serverUpdatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<String?> teamId = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> better = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TestTypesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                deleted: deleted,
                isDirty: isDirty,
                teamId: teamId,
                code: code,
                name: name,
                unit: unit,
                category: category,
                better: better,
                attempts: attempts,
                sortOrder: sortOrder,
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
                Value<String?> teamId = const Value.absent(),
                Value<String?> code = const Value.absent(),
                required String name,
                Value<String?> unit = const Value.absent(),
                required String category,
                required String better,
                Value<int> attempts = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TestTypesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                deleted: deleted,
                isDirty: isDirty,
                teamId: teamId,
                code: code,
                name: name,
                unit: unit,
                category: category,
                better: better,
                attempts: attempts,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TestTypesTable, TestType>(table),
                  BaseReferences<_$AppDatabase, $TestTypesTable, TestType>(
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

typedef $$TestTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TestTypesTable,
      TestType,
      $$TestTypesTableFilterComposer,
      $$TestTypesTableOrderingComposer,
      $$TestTypesTableAnnotationComposer,
      $$TestTypesTableCreateCompanionBuilder,
      $$TestTypesTableUpdateCompanionBuilder,
      (TestType, BaseReferences<_$AppDatabase, $TestTypesTable, TestType>),
      TestType,
      PrefetchHooks Function()
    >;
typedef $$TestResultsTableCreateCompanionBuilder =
    TestResultsCompanion Function({
      required String id,
      required String createdAt,
      required String updatedAt,
      Value<String?> serverUpdatedAt,
      Value<bool> deleted,
      Value<bool> isDirty,
      required String teamId,
      required String playerId,
      required String testTypeId,
      required String date,
      Value<int> attempt,
      required double value,
      Value<String?> remark,
      Value<int> rowid,
    });
typedef $$TestResultsTableUpdateCompanionBuilder =
    TestResultsCompanion Function({
      Value<String> id,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String?> serverUpdatedAt,
      Value<bool> deleted,
      Value<bool> isDirty,
      Value<String> teamId,
      Value<String> playerId,
      Value<String> testTypeId,
      Value<String> date,
      Value<int> attempt,
      Value<double> value,
      Value<String?> remark,
      Value<int> rowid,
    });

class $$TestResultsTableFilterComposer
    extends Composer<_$AppDatabase, $TestResultsTable> {
  $$TestResultsTableFilterComposer({
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

  ColumnFilters<String> get playerId => $composableBuilder(
    column: $table.playerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get testTypeId => $composableBuilder(
    column: $table.testTypeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempt => $composableBuilder(
    column: $table.attempt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TestResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $TestResultsTable> {
  $$TestResultsTableOrderingComposer({
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

  ColumnOrderings<String> get playerId => $composableBuilder(
    column: $table.playerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get testTypeId => $composableBuilder(
    column: $table.testTypeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempt => $composableBuilder(
    column: $table.attempt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TestResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TestResultsTable> {
  $$TestResultsTableAnnotationComposer({
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

  GeneratedColumn<String> get playerId =>
      $composableBuilder(column: $table.playerId, builder: (column) => column);

  GeneratedColumn<String> get testTypeId => $composableBuilder(
    column: $table.testTypeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get attempt =>
      $composableBuilder(column: $table.attempt, builder: (column) => column);

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get remark =>
      $composableBuilder(column: $table.remark, builder: (column) => column);
}

class $$TestResultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TestResultsTable,
          TestResult,
          $$TestResultsTableFilterComposer,
          $$TestResultsTableOrderingComposer,
          $$TestResultsTableAnnotationComposer,
          $$TestResultsTableCreateCompanionBuilder,
          $$TestResultsTableUpdateCompanionBuilder,
          (
            TestResult,
            BaseReferences<_$AppDatabase, $TestResultsTable, TestResult>,
          ),
          TestResult,
          PrefetchHooks Function()
        > {
  $$TestResultsTableTableManager(_$AppDatabase db, $TestResultsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TestResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TestResultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TestResultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> serverUpdatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<String> teamId = const Value.absent(),
                Value<String> playerId = const Value.absent(),
                Value<String> testTypeId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<int> attempt = const Value.absent(),
                Value<double> value = const Value.absent(),
                Value<String?> remark = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TestResultsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                deleted: deleted,
                isDirty: isDirty,
                teamId: teamId,
                playerId: playerId,
                testTypeId: testTypeId,
                date: date,
                attempt: attempt,
                value: value,
                remark: remark,
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
                required String playerId,
                required String testTypeId,
                required String date,
                Value<int> attempt = const Value.absent(),
                required double value,
                Value<String?> remark = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TestResultsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                deleted: deleted,
                isDirty: isDirty,
                teamId: teamId,
                playerId: playerId,
                testTypeId: testTypeId,
                date: date,
                attempt: attempt,
                value: value,
                remark: remark,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TestResultsTable, TestResult>(table),
                  BaseReferences<_$AppDatabase, $TestResultsTable, TestResult>(
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

typedef $$TestResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TestResultsTable,
      TestResult,
      $$TestResultsTableFilterComposer,
      $$TestResultsTableOrderingComposer,
      $$TestResultsTableAnnotationComposer,
      $$TestResultsTableCreateCompanionBuilder,
      $$TestResultsTableUpdateCompanionBuilder,
      (
        TestResult,
        BaseReferences<_$AppDatabase, $TestResultsTable, TestResult>,
      ),
      TestResult,
      PrefetchHooks Function()
    >;
typedef $$PlayerProfilesTableCreateCompanionBuilder =
    PlayerProfilesCompanion Function({
      required String id,
      required String createdAt,
      required String updatedAt,
      Value<String?> serverUpdatedAt,
      Value<bool> deleted,
      Value<bool> isDirty,
      required String teamId,
      required String playerId,
      Value<String?> nationality,
      Value<String?> birthPlace,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> address,
      Value<String?> school,
      Value<String?> schoolYear,
      Value<String?> fatherName,
      Value<String?> fatherNationality,
      Value<String?> fatherOccupation,
      Value<String?> fatherMaritalStatus,
      Value<String?> motherName,
      Value<String?> motherNationality,
      Value<String?> motherMaritalStatus,
      Value<String?> previousClub,
      Value<String?> previousClubCity,
      Value<int?> yearsTraining,
      Value<String?> preferredRole,
      Value<String?> remarks,
      Value<String?> otherPosition,
      Value<String?> schoolAddress,
      Value<String?> coachName,
      Value<String?> managerName,
      Value<int> rowid,
    });
typedef $$PlayerProfilesTableUpdateCompanionBuilder =
    PlayerProfilesCompanion Function({
      Value<String> id,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String?> serverUpdatedAt,
      Value<bool> deleted,
      Value<bool> isDirty,
      Value<String> teamId,
      Value<String> playerId,
      Value<String?> nationality,
      Value<String?> birthPlace,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> address,
      Value<String?> school,
      Value<String?> schoolYear,
      Value<String?> fatherName,
      Value<String?> fatherNationality,
      Value<String?> fatherOccupation,
      Value<String?> fatherMaritalStatus,
      Value<String?> motherName,
      Value<String?> motherNationality,
      Value<String?> motherMaritalStatus,
      Value<String?> previousClub,
      Value<String?> previousClubCity,
      Value<int?> yearsTraining,
      Value<String?> preferredRole,
      Value<String?> remarks,
      Value<String?> otherPosition,
      Value<String?> schoolAddress,
      Value<String?> coachName,
      Value<String?> managerName,
      Value<int> rowid,
    });

class $$PlayerProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $PlayerProfilesTable> {
  $$PlayerProfilesTableFilterComposer({
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

  ColumnFilters<String> get playerId => $composableBuilder(
    column: $table.playerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nationality => $composableBuilder(
    column: $table.nationality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get birthPlace => $composableBuilder(
    column: $table.birthPlace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get school => $composableBuilder(
    column: $table.school,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolYear => $composableBuilder(
    column: $table.schoolYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fatherName => $composableBuilder(
    column: $table.fatherName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fatherNationality => $composableBuilder(
    column: $table.fatherNationality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fatherOccupation => $composableBuilder(
    column: $table.fatherOccupation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fatherMaritalStatus => $composableBuilder(
    column: $table.fatherMaritalStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get motherName => $composableBuilder(
    column: $table.motherName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get motherNationality => $composableBuilder(
    column: $table.motherNationality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get motherMaritalStatus => $composableBuilder(
    column: $table.motherMaritalStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get previousClub => $composableBuilder(
    column: $table.previousClub,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get previousClubCity => $composableBuilder(
    column: $table.previousClubCity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get yearsTraining => $composableBuilder(
    column: $table.yearsTraining,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preferredRole => $composableBuilder(
    column: $table.preferredRole,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get otherPosition => $composableBuilder(
    column: $table.otherPosition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolAddress => $composableBuilder(
    column: $table.schoolAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coachName => $composableBuilder(
    column: $table.coachName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get managerName => $composableBuilder(
    column: $table.managerName,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlayerProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayerProfilesTable> {
  $$PlayerProfilesTableOrderingComposer({
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

  ColumnOrderings<String> get playerId => $composableBuilder(
    column: $table.playerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nationality => $composableBuilder(
    column: $table.nationality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get birthPlace => $composableBuilder(
    column: $table.birthPlace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get school => $composableBuilder(
    column: $table.school,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolYear => $composableBuilder(
    column: $table.schoolYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fatherName => $composableBuilder(
    column: $table.fatherName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fatherNationality => $composableBuilder(
    column: $table.fatherNationality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fatherOccupation => $composableBuilder(
    column: $table.fatherOccupation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fatherMaritalStatus => $composableBuilder(
    column: $table.fatherMaritalStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get motherName => $composableBuilder(
    column: $table.motherName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get motherNationality => $composableBuilder(
    column: $table.motherNationality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get motherMaritalStatus => $composableBuilder(
    column: $table.motherMaritalStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get previousClub => $composableBuilder(
    column: $table.previousClub,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get previousClubCity => $composableBuilder(
    column: $table.previousClubCity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get yearsTraining => $composableBuilder(
    column: $table.yearsTraining,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preferredRole => $composableBuilder(
    column: $table.preferredRole,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get otherPosition => $composableBuilder(
    column: $table.otherPosition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolAddress => $composableBuilder(
    column: $table.schoolAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coachName => $composableBuilder(
    column: $table.coachName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get managerName => $composableBuilder(
    column: $table.managerName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlayerProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayerProfilesTable> {
  $$PlayerProfilesTableAnnotationComposer({
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

  GeneratedColumn<String> get playerId =>
      $composableBuilder(column: $table.playerId, builder: (column) => column);

  GeneratedColumn<String> get nationality => $composableBuilder(
    column: $table.nationality,
    builder: (column) => column,
  );

  GeneratedColumn<String> get birthPlace => $composableBuilder(
    column: $table.birthPlace,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get school =>
      $composableBuilder(column: $table.school, builder: (column) => column);

  GeneratedColumn<String> get schoolYear => $composableBuilder(
    column: $table.schoolYear,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fatherName => $composableBuilder(
    column: $table.fatherName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fatherNationality => $composableBuilder(
    column: $table.fatherNationality,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fatherOccupation => $composableBuilder(
    column: $table.fatherOccupation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fatherMaritalStatus => $composableBuilder(
    column: $table.fatherMaritalStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get motherName => $composableBuilder(
    column: $table.motherName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get motherNationality => $composableBuilder(
    column: $table.motherNationality,
    builder: (column) => column,
  );

  GeneratedColumn<String> get motherMaritalStatus => $composableBuilder(
    column: $table.motherMaritalStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get previousClub => $composableBuilder(
    column: $table.previousClub,
    builder: (column) => column,
  );

  GeneratedColumn<String> get previousClubCity => $composableBuilder(
    column: $table.previousClubCity,
    builder: (column) => column,
  );

  GeneratedColumn<int> get yearsTraining => $composableBuilder(
    column: $table.yearsTraining,
    builder: (column) => column,
  );

  GeneratedColumn<String> get preferredRole => $composableBuilder(
    column: $table.preferredRole,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remarks =>
      $composableBuilder(column: $table.remarks, builder: (column) => column);

  GeneratedColumn<String> get otherPosition => $composableBuilder(
    column: $table.otherPosition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get schoolAddress => $composableBuilder(
    column: $table.schoolAddress,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coachName =>
      $composableBuilder(column: $table.coachName, builder: (column) => column);

  GeneratedColumn<String> get managerName => $composableBuilder(
    column: $table.managerName,
    builder: (column) => column,
  );
}

class $$PlayerProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayerProfilesTable,
          PlayerProfile,
          $$PlayerProfilesTableFilterComposer,
          $$PlayerProfilesTableOrderingComposer,
          $$PlayerProfilesTableAnnotationComposer,
          $$PlayerProfilesTableCreateCompanionBuilder,
          $$PlayerProfilesTableUpdateCompanionBuilder,
          (
            PlayerProfile,
            BaseReferences<_$AppDatabase, $PlayerProfilesTable, PlayerProfile>,
          ),
          PlayerProfile,
          PrefetchHooks Function()
        > {
  $$PlayerProfilesTableTableManager(
    _$AppDatabase db,
    $PlayerProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayerProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayerProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayerProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> serverUpdatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<String> teamId = const Value.absent(),
                Value<String> playerId = const Value.absent(),
                Value<String?> nationality = const Value.absent(),
                Value<String?> birthPlace = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> school = const Value.absent(),
                Value<String?> schoolYear = const Value.absent(),
                Value<String?> fatherName = const Value.absent(),
                Value<String?> fatherNationality = const Value.absent(),
                Value<String?> fatherOccupation = const Value.absent(),
                Value<String?> fatherMaritalStatus = const Value.absent(),
                Value<String?> motherName = const Value.absent(),
                Value<String?> motherNationality = const Value.absent(),
                Value<String?> motherMaritalStatus = const Value.absent(),
                Value<String?> previousClub = const Value.absent(),
                Value<String?> previousClubCity = const Value.absent(),
                Value<int?> yearsTraining = const Value.absent(),
                Value<String?> preferredRole = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<String?> otherPosition = const Value.absent(),
                Value<String?> schoolAddress = const Value.absent(),
                Value<String?> coachName = const Value.absent(),
                Value<String?> managerName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlayerProfilesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                deleted: deleted,
                isDirty: isDirty,
                teamId: teamId,
                playerId: playerId,
                nationality: nationality,
                birthPlace: birthPlace,
                phone: phone,
                email: email,
                address: address,
                school: school,
                schoolYear: schoolYear,
                fatherName: fatherName,
                fatherNationality: fatherNationality,
                fatherOccupation: fatherOccupation,
                fatherMaritalStatus: fatherMaritalStatus,
                motherName: motherName,
                motherNationality: motherNationality,
                motherMaritalStatus: motherMaritalStatus,
                previousClub: previousClub,
                previousClubCity: previousClubCity,
                yearsTraining: yearsTraining,
                preferredRole: preferredRole,
                remarks: remarks,
                otherPosition: otherPosition,
                schoolAddress: schoolAddress,
                coachName: coachName,
                managerName: managerName,
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
                required String playerId,
                Value<String?> nationality = const Value.absent(),
                Value<String?> birthPlace = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> school = const Value.absent(),
                Value<String?> schoolYear = const Value.absent(),
                Value<String?> fatherName = const Value.absent(),
                Value<String?> fatherNationality = const Value.absent(),
                Value<String?> fatherOccupation = const Value.absent(),
                Value<String?> fatherMaritalStatus = const Value.absent(),
                Value<String?> motherName = const Value.absent(),
                Value<String?> motherNationality = const Value.absent(),
                Value<String?> motherMaritalStatus = const Value.absent(),
                Value<String?> previousClub = const Value.absent(),
                Value<String?> previousClubCity = const Value.absent(),
                Value<int?> yearsTraining = const Value.absent(),
                Value<String?> preferredRole = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<String?> otherPosition = const Value.absent(),
                Value<String?> schoolAddress = const Value.absent(),
                Value<String?> coachName = const Value.absent(),
                Value<String?> managerName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlayerProfilesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                deleted: deleted,
                isDirty: isDirty,
                teamId: teamId,
                playerId: playerId,
                nationality: nationality,
                birthPlace: birthPlace,
                phone: phone,
                email: email,
                address: address,
                school: school,
                schoolYear: schoolYear,
                fatherName: fatherName,
                fatherNationality: fatherNationality,
                fatherOccupation: fatherOccupation,
                fatherMaritalStatus: fatherMaritalStatus,
                motherName: motherName,
                motherNationality: motherNationality,
                motherMaritalStatus: motherMaritalStatus,
                previousClub: previousClub,
                previousClubCity: previousClubCity,
                yearsTraining: yearsTraining,
                preferredRole: preferredRole,
                remarks: remarks,
                otherPosition: otherPosition,
                schoolAddress: schoolAddress,
                coachName: coachName,
                managerName: managerName,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlayerProfilesTable, PlayerProfile>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PlayerProfilesTable,
                    PlayerProfile
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlayerProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayerProfilesTable,
      PlayerProfile,
      $$PlayerProfilesTableFilterComposer,
      $$PlayerProfilesTableOrderingComposer,
      $$PlayerProfilesTableAnnotationComposer,
      $$PlayerProfilesTableCreateCompanionBuilder,
      $$PlayerProfilesTableUpdateCompanionBuilder,
      (
        PlayerProfile,
        BaseReferences<_$AppDatabase, $PlayerProfilesTable, PlayerProfile>,
      ),
      PlayerProfile,
      PrefetchHooks Function()
    >;
typedef $$PlayerMedicalTableCreateCompanionBuilder =
    PlayerMedicalCompanion Function({
      required String id,
      required String createdAt,
      required String updatedAt,
      Value<String?> serverUpdatedAt,
      Value<bool> deleted,
      Value<bool> isDirty,
      required String teamId,
      required String playerId,
      required String consentDate,
      required String consentBy,
      Value<String?> allergies,
      Value<String?> conditions,
      Value<String?> lowBpAnxiety,
      Value<String?> surgeries,
      Value<String?> recentInjuries,
      Value<String?> remarks,
      Value<int> rowid,
    });
typedef $$PlayerMedicalTableUpdateCompanionBuilder =
    PlayerMedicalCompanion Function({
      Value<String> id,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String?> serverUpdatedAt,
      Value<bool> deleted,
      Value<bool> isDirty,
      Value<String> teamId,
      Value<String> playerId,
      Value<String> consentDate,
      Value<String> consentBy,
      Value<String?> allergies,
      Value<String?> conditions,
      Value<String?> lowBpAnxiety,
      Value<String?> surgeries,
      Value<String?> recentInjuries,
      Value<String?> remarks,
      Value<int> rowid,
    });

class $$PlayerMedicalTableFilterComposer
    extends Composer<_$AppDatabase, $PlayerMedicalTable> {
  $$PlayerMedicalTableFilterComposer({
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

  ColumnFilters<String> get playerId => $composableBuilder(
    column: $table.playerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get consentDate => $composableBuilder(
    column: $table.consentDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get consentBy => $composableBuilder(
    column: $table.consentBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get allergies => $composableBuilder(
    column: $table.allergies,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conditions => $composableBuilder(
    column: $table.conditions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lowBpAnxiety => $composableBuilder(
    column: $table.lowBpAnxiety,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get surgeries => $composableBuilder(
    column: $table.surgeries,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recentInjuries => $composableBuilder(
    column: $table.recentInjuries,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlayerMedicalTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayerMedicalTable> {
  $$PlayerMedicalTableOrderingComposer({
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

  ColumnOrderings<String> get playerId => $composableBuilder(
    column: $table.playerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get consentDate => $composableBuilder(
    column: $table.consentDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get consentBy => $composableBuilder(
    column: $table.consentBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get allergies => $composableBuilder(
    column: $table.allergies,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conditions => $composableBuilder(
    column: $table.conditions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lowBpAnxiety => $composableBuilder(
    column: $table.lowBpAnxiety,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get surgeries => $composableBuilder(
    column: $table.surgeries,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recentInjuries => $composableBuilder(
    column: $table.recentInjuries,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlayerMedicalTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayerMedicalTable> {
  $$PlayerMedicalTableAnnotationComposer({
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

  GeneratedColumn<String> get playerId =>
      $composableBuilder(column: $table.playerId, builder: (column) => column);

  GeneratedColumn<String> get consentDate => $composableBuilder(
    column: $table.consentDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get consentBy =>
      $composableBuilder(column: $table.consentBy, builder: (column) => column);

  GeneratedColumn<String> get allergies =>
      $composableBuilder(column: $table.allergies, builder: (column) => column);

  GeneratedColumn<String> get conditions => $composableBuilder(
    column: $table.conditions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lowBpAnxiety => $composableBuilder(
    column: $table.lowBpAnxiety,
    builder: (column) => column,
  );

  GeneratedColumn<String> get surgeries =>
      $composableBuilder(column: $table.surgeries, builder: (column) => column);

  GeneratedColumn<String> get recentInjuries => $composableBuilder(
    column: $table.recentInjuries,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remarks =>
      $composableBuilder(column: $table.remarks, builder: (column) => column);
}

class $$PlayerMedicalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayerMedicalTable,
          MedicalRecord,
          $$PlayerMedicalTableFilterComposer,
          $$PlayerMedicalTableOrderingComposer,
          $$PlayerMedicalTableAnnotationComposer,
          $$PlayerMedicalTableCreateCompanionBuilder,
          $$PlayerMedicalTableUpdateCompanionBuilder,
          (
            MedicalRecord,
            BaseReferences<_$AppDatabase, $PlayerMedicalTable, MedicalRecord>,
          ),
          MedicalRecord,
          PrefetchHooks Function()
        > {
  $$PlayerMedicalTableTableManager(_$AppDatabase db, $PlayerMedicalTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayerMedicalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayerMedicalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayerMedicalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> serverUpdatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<String> teamId = const Value.absent(),
                Value<String> playerId = const Value.absent(),
                Value<String> consentDate = const Value.absent(),
                Value<String> consentBy = const Value.absent(),
                Value<String?> allergies = const Value.absent(),
                Value<String?> conditions = const Value.absent(),
                Value<String?> lowBpAnxiety = const Value.absent(),
                Value<String?> surgeries = const Value.absent(),
                Value<String?> recentInjuries = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlayerMedicalCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                deleted: deleted,
                isDirty: isDirty,
                teamId: teamId,
                playerId: playerId,
                consentDate: consentDate,
                consentBy: consentBy,
                allergies: allergies,
                conditions: conditions,
                lowBpAnxiety: lowBpAnxiety,
                surgeries: surgeries,
                recentInjuries: recentInjuries,
                remarks: remarks,
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
                required String playerId,
                required String consentDate,
                required String consentBy,
                Value<String?> allergies = const Value.absent(),
                Value<String?> conditions = const Value.absent(),
                Value<String?> lowBpAnxiety = const Value.absent(),
                Value<String?> surgeries = const Value.absent(),
                Value<String?> recentInjuries = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlayerMedicalCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                deleted: deleted,
                isDirty: isDirty,
                teamId: teamId,
                playerId: playerId,
                consentDate: consentDate,
                consentBy: consentBy,
                allergies: allergies,
                conditions: conditions,
                lowBpAnxiety: lowBpAnxiety,
                surgeries: surgeries,
                recentInjuries: recentInjuries,
                remarks: remarks,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlayerMedicalTable, MedicalRecord>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PlayerMedicalTable,
                    MedicalRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlayerMedicalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayerMedicalTable,
      MedicalRecord,
      $$PlayerMedicalTableFilterComposer,
      $$PlayerMedicalTableOrderingComposer,
      $$PlayerMedicalTableAnnotationComposer,
      $$PlayerMedicalTableCreateCompanionBuilder,
      $$PlayerMedicalTableUpdateCompanionBuilder,
      (
        MedicalRecord,
        BaseReferences<_$AppDatabase, $PlayerMedicalTable, MedicalRecord>,
      ),
      MedicalRecord,
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
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$SessionPlayersTableTableManager get sessionPlayers =>
      $$SessionPlayersTableTableManager(_db, _db.sessionPlayers);
  $$WellnessTableTableManager get wellness =>
      $$WellnessTableTableManager(_db, _db.wellness);
  $$MatchesTableTableManager get matches =>
      $$MatchesTableTableManager(_db, _db.matches);
  $$MatchPlayersTableTableManager get matchPlayers =>
      $$MatchPlayersTableTableManager(_db, _db.matchPlayers);
  $$MatchEventsTableTableManager get matchEvents =>
      $$MatchEventsTableTableManager(_db, _db.matchEvents);
  $$InjuriesTableTableManager get injuries =>
      $$InjuriesTableTableManager(_db, _db.injuries);
  $$TestTypesTableTableManager get testTypes =>
      $$TestTypesTableTableManager(_db, _db.testTypes);
  $$TestResultsTableTableManager get testResults =>
      $$TestResultsTableTableManager(_db, _db.testResults);
  $$PlayerProfilesTableTableManager get playerProfiles =>
      $$PlayerProfilesTableTableManager(_db, _db.playerProfiles);
  $$PlayerMedicalTableTableManager get playerMedical =>
      $$PlayerMedicalTableTableManager(_db, _db.playerMedical);
  $$SyncStateTableTableManager get syncState =>
      $$SyncStateTableTableManager(_db, _db.syncState);
  $$LocalSettingsTableTableManager get localSettings =>
      $$LocalSettingsTableTableManager(_db, _db.localSettings);
}
