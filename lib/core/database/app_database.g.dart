// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ExpensesTable extends Expenses with TableInfo<$ExpensesTable, Expense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<int> category = GeneratedColumn<int>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
    'memo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, amount, category, memo, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Expense> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Expense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Expense(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category'],
      )!,
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }
}

class Expense extends DataClass implements Insertable<Expense> {
  final int id;
  final int amount;
  final int category;
  final String memo;
  final DateTime createdAt;
  const Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.memo,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['amount'] = Variable<int>(amount);
    map['category'] = Variable<int>(category);
    map['memo'] = Variable<String>(memo);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      amount: Value(amount),
      category: Value(category),
      memo: Value(memo),
      createdAt: Value(createdAt),
    );
  }

  factory Expense.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Expense(
      id: serializer.fromJson<int>(json['id']),
      amount: serializer.fromJson<int>(json['amount']),
      category: serializer.fromJson<int>(json['category']),
      memo: serializer.fromJson<String>(json['memo']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'amount': serializer.toJson<int>(amount),
      'category': serializer.toJson<int>(category),
      'memo': serializer.toJson<String>(memo),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Expense copyWith({
    int? id,
    int? amount,
    int? category,
    String? memo,
    DateTime? createdAt,
  }) => Expense(
    id: id ?? this.id,
    amount: amount ?? this.amount,
    category: category ?? this.category,
    memo: memo ?? this.memo,
    createdAt: createdAt ?? this.createdAt,
  );
  Expense copyWithCompanion(ExpensesCompanion data) {
    return Expense(
      id: data.id.present ? data.id.value : this.id,
      amount: data.amount.present ? data.amount.value : this.amount,
      category: data.category.present ? data.category.value : this.category,
      memo: data.memo.present ? data.memo.value : this.memo,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Expense(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('memo: $memo, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, amount, category, memo, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Expense &&
          other.id == this.id &&
          other.amount == this.amount &&
          other.category == this.category &&
          other.memo == this.memo &&
          other.createdAt == this.createdAt);
}

class ExpensesCompanion extends UpdateCompanion<Expense> {
  final Value<int> id;
  final Value<int> amount;
  final Value<int> category;
  final Value<String> memo;
  final Value<DateTime> createdAt;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.amount = const Value.absent(),
    this.category = const Value.absent(),
    this.memo = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ExpensesCompanion.insert({
    this.id = const Value.absent(),
    required int amount,
    required int category,
    this.memo = const Value.absent(),
    required DateTime createdAt,
  }) : amount = Value(amount),
       category = Value(category),
       createdAt = Value(createdAt);
  static Insertable<Expense> custom({
    Expression<int>? id,
    Expression<int>? amount,
    Expression<int>? category,
    Expression<String>? memo,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (category != null) 'category': category,
      if (memo != null) 'memo': memo,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ExpensesCompanion copyWith({
    Value<int>? id,
    Value<int>? amount,
    Value<int>? category,
    Value<String>? memo,
    Value<DateTime>? createdAt,
  }) {
    return ExpensesCompanion(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (category.present) {
      map['category'] = Variable<int>(category.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('memo: $memo, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DailyBudgetsTable extends DailyBudgets
    with TableInfo<$DailyBudgetsTable, DailyBudget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyBudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _baseAmountMeta = const VerificationMeta(
    'baseAmount',
  );
  @override
  late final GeneratedColumn<int> baseAmount = GeneratedColumn<int>(
    'base_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10000),
  );
  static const VerificationMeta _carryOverMeta = const VerificationMeta(
    'carryOver',
  );
  @override
  late final GeneratedColumn<int> carryOver = GeneratedColumn<int>(
    'carry_over',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<String> mood = GeneratedColumn<String>(
    'mood',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, date, baseAmount, carryOver, mood];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyBudget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('base_amount')) {
      context.handle(
        _baseAmountMeta,
        baseAmount.isAcceptableOrUnknown(data['base_amount']!, _baseAmountMeta),
      );
    }
    if (data.containsKey('carry_over')) {
      context.handle(
        _carryOverMeta,
        carryOver.isAcceptableOrUnknown(data['carry_over']!, _carryOverMeta),
      );
    }
    if (data.containsKey('mood')) {
      context.handle(
        _moodMeta,
        mood.isAcceptableOrUnknown(data['mood']!, _moodMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailyBudget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyBudget(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      baseAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_amount'],
      )!,
      carryOver: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}carry_over'],
      )!,
      mood: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mood'],
      ),
    );
  }

  @override
  $DailyBudgetsTable createAlias(String alias) {
    return $DailyBudgetsTable(attachedDatabase, alias);
  }
}

class DailyBudget extends DataClass implements Insertable<DailyBudget> {
  final int id;
  final DateTime date;
  final int baseAmount;
  final int carryOver;
  final String? mood;
  const DailyBudget({
    required this.id,
    required this.date,
    required this.baseAmount,
    required this.carryOver,
    this.mood,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['base_amount'] = Variable<int>(baseAmount);
    map['carry_over'] = Variable<int>(carryOver);
    if (!nullToAbsent || mood != null) {
      map['mood'] = Variable<String>(mood);
    }
    return map;
  }

  DailyBudgetsCompanion toCompanion(bool nullToAbsent) {
    return DailyBudgetsCompanion(
      id: Value(id),
      date: Value(date),
      baseAmount: Value(baseAmount),
      carryOver: Value(carryOver),
      mood: mood == null && nullToAbsent ? const Value.absent() : Value(mood),
    );
  }

  factory DailyBudget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyBudget(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      baseAmount: serializer.fromJson<int>(json['baseAmount']),
      carryOver: serializer.fromJson<int>(json['carryOver']),
      mood: serializer.fromJson<String?>(json['mood']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'baseAmount': serializer.toJson<int>(baseAmount),
      'carryOver': serializer.toJson<int>(carryOver),
      'mood': serializer.toJson<String?>(mood),
    };
  }

  DailyBudget copyWith({
    int? id,
    DateTime? date,
    int? baseAmount,
    int? carryOver,
    Value<String?> mood = const Value.absent(),
  }) => DailyBudget(
    id: id ?? this.id,
    date: date ?? this.date,
    baseAmount: baseAmount ?? this.baseAmount,
    carryOver: carryOver ?? this.carryOver,
    mood: mood.present ? mood.value : this.mood,
  );
  DailyBudget copyWithCompanion(DailyBudgetsCompanion data) {
    return DailyBudget(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      baseAmount: data.baseAmount.present
          ? data.baseAmount.value
          : this.baseAmount,
      carryOver: data.carryOver.present ? data.carryOver.value : this.carryOver,
      mood: data.mood.present ? data.mood.value : this.mood,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyBudget(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('baseAmount: $baseAmount, ')
          ..write('carryOver: $carryOver, ')
          ..write('mood: $mood')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, baseAmount, carryOver, mood);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyBudget &&
          other.id == this.id &&
          other.date == this.date &&
          other.baseAmount == this.baseAmount &&
          other.carryOver == this.carryOver &&
          other.mood == this.mood);
}

class DailyBudgetsCompanion extends UpdateCompanion<DailyBudget> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<int> baseAmount;
  final Value<int> carryOver;
  final Value<String?> mood;
  const DailyBudgetsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.baseAmount = const Value.absent(),
    this.carryOver = const Value.absent(),
    this.mood = const Value.absent(),
  });
  DailyBudgetsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    this.baseAmount = const Value.absent(),
    this.carryOver = const Value.absent(),
    this.mood = const Value.absent(),
  }) : date = Value(date);
  static Insertable<DailyBudget> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<int>? baseAmount,
    Expression<int>? carryOver,
    Expression<String>? mood,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (baseAmount != null) 'base_amount': baseAmount,
      if (carryOver != null) 'carry_over': carryOver,
      if (mood != null) 'mood': mood,
    });
  }

  DailyBudgetsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<int>? baseAmount,
    Value<int>? carryOver,
    Value<String?>? mood,
  }) {
    return DailyBudgetsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      baseAmount: baseAmount ?? this.baseAmount,
      carryOver: carryOver ?? this.carryOver,
      mood: mood ?? this.mood,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (baseAmount.present) {
      map['base_amount'] = Variable<int>(baseAmount.value);
    }
    if (carryOver.present) {
      map['carry_over'] = Variable<int>(carryOver.value);
    }
    if (mood.present) {
      map['mood'] = Variable<String>(mood.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyBudgetsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('baseAmount: $baseAmount, ')
          ..write('carryOver: $carryOver, ')
          ..write('mood: $mood')
          ..write(')'))
        .toString();
  }
}

class $AcornsTable extends Acorns with TableInfo<$AcornsTable, Acorn> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AcornsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, date, count, reason];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'acorns';
  @override
  VerificationContext validateIntegrity(
    Insertable<Acorn> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    } else if (isInserting) {
      context.missing(_countMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Acorn map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Acorn(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
    );
  }

  @override
  $AcornsTable createAlias(String alias) {
    return $AcornsTable(attachedDatabase, alias);
  }
}

class Acorn extends DataClass implements Insertable<Acorn> {
  final int id;
  final DateTime date;
  final int count;
  final String reason;
  const Acorn({
    required this.id,
    required this.date,
    required this.count,
    required this.reason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['count'] = Variable<int>(count);
    map['reason'] = Variable<String>(reason);
    return map;
  }

  AcornsCompanion toCompanion(bool nullToAbsent) {
    return AcornsCompanion(
      id: Value(id),
      date: Value(date),
      count: Value(count),
      reason: Value(reason),
    );
  }

  factory Acorn.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Acorn(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      count: serializer.fromJson<int>(json['count']),
      reason: serializer.fromJson<String>(json['reason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'count': serializer.toJson<int>(count),
      'reason': serializer.toJson<String>(reason),
    };
  }

  Acorn copyWith({int? id, DateTime? date, int? count, String? reason}) =>
      Acorn(
        id: id ?? this.id,
        date: date ?? this.date,
        count: count ?? this.count,
        reason: reason ?? this.reason,
      );
  Acorn copyWithCompanion(AcornsCompanion data) {
    return Acorn(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      count: data.count.present ? data.count.value : this.count,
      reason: data.reason.present ? data.reason.value : this.reason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Acorn(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('count: $count, ')
          ..write('reason: $reason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, count, reason);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Acorn &&
          other.id == this.id &&
          other.date == this.date &&
          other.count == this.count &&
          other.reason == this.reason);
}

class AcornsCompanion extends UpdateCompanion<Acorn> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<int> count;
  final Value<String> reason;
  const AcornsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.count = const Value.absent(),
    this.reason = const Value.absent(),
  });
  AcornsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required int count,
    required String reason,
  }) : date = Value(date),
       count = Value(count),
       reason = Value(reason);
  static Insertable<Acorn> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<int>? count,
    Expression<String>? reason,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (count != null) 'count': count,
      if (reason != null) 'reason': reason,
    });
  }

  AcornsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<int>? count,
    Value<String>? reason,
  }) {
    return AcornsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      count: count ?? this.count,
      reason: reason ?? this.reason,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AcornsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('count: $count, ')
          ..write('reason: $reason')
          ..write(')'))
        .toString();
  }
}

class $AchievementsTable extends Achievements
    with TableInfo<$AchievementsTable, Achievement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AchievementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
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
  static const VerificationMeta _achievedAtMeta = const VerificationMeta(
    'achievedAt',
  );
  @override
  late final GeneratedColumn<DateTime> achievedAt = GeneratedColumn<DateTime>(
    'achieved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, type, achievedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'achievements';
  @override
  VerificationContext validateIntegrity(
    Insertable<Achievement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('achieved_at')) {
      context.handle(
        _achievedAtMeta,
        achievedAt.isAcceptableOrUnknown(data['achieved_at']!, _achievedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_achievedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Achievement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Achievement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      achievedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}achieved_at'],
      )!,
    );
  }

  @override
  $AchievementsTable createAlias(String alias) {
    return $AchievementsTable(attachedDatabase, alias);
  }
}

class Achievement extends DataClass implements Insertable<Achievement> {
  final int id;
  final String type;
  final DateTime achievedAt;
  const Achievement({
    required this.id,
    required this.type,
    required this.achievedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    map['achieved_at'] = Variable<DateTime>(achievedAt);
    return map;
  }

  AchievementsCompanion toCompanion(bool nullToAbsent) {
    return AchievementsCompanion(
      id: Value(id),
      type: Value(type),
      achievedAt: Value(achievedAt),
    );
  }

  factory Achievement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Achievement(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      achievedAt: serializer.fromJson<DateTime>(json['achievedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'achievedAt': serializer.toJson<DateTime>(achievedAt),
    };
  }

  Achievement copyWith({int? id, String? type, DateTime? achievedAt}) =>
      Achievement(
        id: id ?? this.id,
        type: type ?? this.type,
        achievedAt: achievedAt ?? this.achievedAt,
      );
  Achievement copyWithCompanion(AchievementsCompanion data) {
    return Achievement(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      achievedAt: data.achievedAt.present
          ? data.achievedAt.value
          : this.achievedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Achievement(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('achievedAt: $achievedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, achievedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Achievement &&
          other.id == this.id &&
          other.type == this.type &&
          other.achievedAt == this.achievedAt);
}

class AchievementsCompanion extends UpdateCompanion<Achievement> {
  final Value<int> id;
  final Value<String> type;
  final Value<DateTime> achievedAt;
  const AchievementsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.achievedAt = const Value.absent(),
  });
  AchievementsCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    required DateTime achievedAt,
  }) : type = Value(type),
       achievedAt = Value(achievedAt);
  static Insertable<Achievement> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<DateTime>? achievedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (achievedAt != null) 'achieved_at': achievedAt,
    });
  }

  AchievementsCompanion copyWith({
    Value<int>? id,
    Value<String>? type,
    Value<DateTime>? achievedAt,
  }) {
    return AchievementsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      achievedAt: achievedAt ?? this.achievedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (achievedAt.present) {
      map['achieved_at'] = Variable<DateTime>(achievedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AchievementsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('achievedAt: $achievedAt')
          ..write(')'))
        .toString();
  }
}

class $UserPreferencesTable extends UserPreferences
    with TableInfo<$UserPreferencesTable, UserPreference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _isDarkModeMeta = const VerificationMeta(
    'isDarkMode',
  );
  @override
  late final GeneratedColumn<bool> isDarkMode = GeneratedColumn<bool>(
    'is_dark_mode',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dark_mode" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isOnboardingCompletedMeta =
      const VerificationMeta('isOnboardingCompleted');
  @override
  late final GeneratedColumn<bool> isOnboardingCompleted =
      GeneratedColumn<bool>(
        'is_onboarding_completed',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_onboarding_completed" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _dailyBudgetMeta = const VerificationMeta(
    'dailyBudget',
  );
  @override
  late final GeneratedColumn<int> dailyBudget = GeneratedColumn<int>(
    'daily_budget',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10000),
  );
  static const VerificationMeta _carryoverEnabledMeta = const VerificationMeta(
    'carryoverEnabled',
  );
  @override
  late final GeneratedColumn<bool> carryoverEnabled = GeneratedColumn<bool>(
    'carryover_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("carryover_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    isDarkMode,
    isOnboardingCompleted,
    dailyBudget,
    carryoverEnabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserPreference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('is_dark_mode')) {
      context.handle(
        _isDarkModeMeta,
        isDarkMode.isAcceptableOrUnknown(
          data['is_dark_mode']!,
          _isDarkModeMeta,
        ),
      );
    }
    if (data.containsKey('is_onboarding_completed')) {
      context.handle(
        _isOnboardingCompletedMeta,
        isOnboardingCompleted.isAcceptableOrUnknown(
          data['is_onboarding_completed']!,
          _isOnboardingCompletedMeta,
        ),
      );
    }
    if (data.containsKey('daily_budget')) {
      context.handle(
        _dailyBudgetMeta,
        dailyBudget.isAcceptableOrUnknown(
          data['daily_budget']!,
          _dailyBudgetMeta,
        ),
      );
    }
    if (data.containsKey('carryover_enabled')) {
      context.handle(
        _carryoverEnabledMeta,
        carryoverEnabled.isAcceptableOrUnknown(
          data['carryover_enabled']!,
          _carryoverEnabledMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserPreference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserPreference(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      isDarkMode: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dark_mode'],
      )!,
      isOnboardingCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_onboarding_completed'],
      )!,
      dailyBudget: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_budget'],
      )!,
      carryoverEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}carryover_enabled'],
      )!,
    );
  }

  @override
  $UserPreferencesTable createAlias(String alias) {
    return $UserPreferencesTable(attachedDatabase, alias);
  }
}

class UserPreference extends DataClass implements Insertable<UserPreference> {
  final int id;
  final bool isDarkMode;
  final bool isOnboardingCompleted;
  final int dailyBudget;
  final bool carryoverEnabled;
  const UserPreference({
    required this.id,
    required this.isDarkMode,
    required this.isOnboardingCompleted,
    required this.dailyBudget,
    required this.carryoverEnabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['is_dark_mode'] = Variable<bool>(isDarkMode);
    map['is_onboarding_completed'] = Variable<bool>(isOnboardingCompleted);
    map['daily_budget'] = Variable<int>(dailyBudget);
    map['carryover_enabled'] = Variable<bool>(carryoverEnabled);
    return map;
  }

  UserPreferencesCompanion toCompanion(bool nullToAbsent) {
    return UserPreferencesCompanion(
      id: Value(id),
      isDarkMode: Value(isDarkMode),
      isOnboardingCompleted: Value(isOnboardingCompleted),
      dailyBudget: Value(dailyBudget),
      carryoverEnabled: Value(carryoverEnabled),
    );
  }

  factory UserPreference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserPreference(
      id: serializer.fromJson<int>(json['id']),
      isDarkMode: serializer.fromJson<bool>(json['isDarkMode']),
      isOnboardingCompleted: serializer.fromJson<bool>(
        json['isOnboardingCompleted'],
      ),
      dailyBudget: serializer.fromJson<int>(json['dailyBudget']),
      carryoverEnabled: serializer.fromJson<bool>(json['carryoverEnabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'isDarkMode': serializer.toJson<bool>(isDarkMode),
      'isOnboardingCompleted': serializer.toJson<bool>(isOnboardingCompleted),
      'dailyBudget': serializer.toJson<int>(dailyBudget),
      'carryoverEnabled': serializer.toJson<bool>(carryoverEnabled),
    };
  }

  UserPreference copyWith({
    int? id,
    bool? isDarkMode,
    bool? isOnboardingCompleted,
    int? dailyBudget,
    bool? carryoverEnabled,
  }) => UserPreference(
    id: id ?? this.id,
    isDarkMode: isDarkMode ?? this.isDarkMode,
    isOnboardingCompleted: isOnboardingCompleted ?? this.isOnboardingCompleted,
    dailyBudget: dailyBudget ?? this.dailyBudget,
    carryoverEnabled: carryoverEnabled ?? this.carryoverEnabled,
  );
  UserPreference copyWithCompanion(UserPreferencesCompanion data) {
    return UserPreference(
      id: data.id.present ? data.id.value : this.id,
      isDarkMode: data.isDarkMode.present
          ? data.isDarkMode.value
          : this.isDarkMode,
      isOnboardingCompleted: data.isOnboardingCompleted.present
          ? data.isOnboardingCompleted.value
          : this.isOnboardingCompleted,
      dailyBudget: data.dailyBudget.present
          ? data.dailyBudget.value
          : this.dailyBudget,
      carryoverEnabled: data.carryoverEnabled.present
          ? data.carryoverEnabled.value
          : this.carryoverEnabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserPreference(')
          ..write('id: $id, ')
          ..write('isDarkMode: $isDarkMode, ')
          ..write('isOnboardingCompleted: $isOnboardingCompleted, ')
          ..write('dailyBudget: $dailyBudget, ')
          ..write('carryoverEnabled: $carryoverEnabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    isDarkMode,
    isOnboardingCompleted,
    dailyBudget,
    carryoverEnabled,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserPreference &&
          other.id == this.id &&
          other.isDarkMode == this.isDarkMode &&
          other.isOnboardingCompleted == this.isOnboardingCompleted &&
          other.dailyBudget == this.dailyBudget &&
          other.carryoverEnabled == this.carryoverEnabled);
}

class UserPreferencesCompanion extends UpdateCompanion<UserPreference> {
  final Value<int> id;
  final Value<bool> isDarkMode;
  final Value<bool> isOnboardingCompleted;
  final Value<int> dailyBudget;
  final Value<bool> carryoverEnabled;
  const UserPreferencesCompanion({
    this.id = const Value.absent(),
    this.isDarkMode = const Value.absent(),
    this.isOnboardingCompleted = const Value.absent(),
    this.dailyBudget = const Value.absent(),
    this.carryoverEnabled = const Value.absent(),
  });
  UserPreferencesCompanion.insert({
    this.id = const Value.absent(),
    this.isDarkMode = const Value.absent(),
    this.isOnboardingCompleted = const Value.absent(),
    this.dailyBudget = const Value.absent(),
    this.carryoverEnabled = const Value.absent(),
  });
  static Insertable<UserPreference> custom({
    Expression<int>? id,
    Expression<bool>? isDarkMode,
    Expression<bool>? isOnboardingCompleted,
    Expression<int>? dailyBudget,
    Expression<bool>? carryoverEnabled,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (isDarkMode != null) 'is_dark_mode': isDarkMode,
      if (isOnboardingCompleted != null)
        'is_onboarding_completed': isOnboardingCompleted,
      if (dailyBudget != null) 'daily_budget': dailyBudget,
      if (carryoverEnabled != null) 'carryover_enabled': carryoverEnabled,
    });
  }

  UserPreferencesCompanion copyWith({
    Value<int>? id,
    Value<bool>? isDarkMode,
    Value<bool>? isOnboardingCompleted,
    Value<int>? dailyBudget,
    Value<bool>? carryoverEnabled,
  }) {
    return UserPreferencesCompanion(
      id: id ?? this.id,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isOnboardingCompleted:
          isOnboardingCompleted ?? this.isOnboardingCompleted,
      dailyBudget: dailyBudget ?? this.dailyBudget,
      carryoverEnabled: carryoverEnabled ?? this.carryoverEnabled,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (isDarkMode.present) {
      map['is_dark_mode'] = Variable<bool>(isDarkMode.value);
    }
    if (isOnboardingCompleted.present) {
      map['is_onboarding_completed'] = Variable<bool>(
        isOnboardingCompleted.value,
      );
    }
    if (dailyBudget.present) {
      map['daily_budget'] = Variable<int>(dailyBudget.value);
    }
    if (carryoverEnabled.present) {
      map['carryover_enabled'] = Variable<bool>(carryoverEnabled.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserPreferencesCompanion(')
          ..write('id: $id, ')
          ..write('isDarkMode: $isDarkMode, ')
          ..write('isOnboardingCompleted: $isOnboardingCompleted, ')
          ..write('dailyBudget: $dailyBudget, ')
          ..write('carryoverEnabled: $carryoverEnabled')
          ..write(')'))
        .toString();
  }
}

class $NotificationSettingsTable extends NotificationSettings
    with TableInfo<$NotificationSettingsTable, NotificationSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _lunchEnabledMeta = const VerificationMeta(
    'lunchEnabled',
  );
  @override
  late final GeneratedColumn<bool> lunchEnabled = GeneratedColumn<bool>(
    'lunch_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("lunch_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lunchTimeMeta = const VerificationMeta(
    'lunchTime',
  );
  @override
  late final GeneratedColumn<String> lunchTime = GeneratedColumn<String>(
    'lunch_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('12:00'),
  );
  static const VerificationMeta _dinnerEnabledMeta = const VerificationMeta(
    'dinnerEnabled',
  );
  @override
  late final GeneratedColumn<bool> dinnerEnabled = GeneratedColumn<bool>(
    'dinner_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dinner_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _dinnerTimeMeta = const VerificationMeta(
    'dinnerTime',
  );
  @override
  late final GeneratedColumn<String> dinnerTime = GeneratedColumn<String>(
    'dinner_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('20:00'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lunchEnabled,
    lunchTime,
    dinnerEnabled,
    dinnerTime,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notification_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotificationSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('lunch_enabled')) {
      context.handle(
        _lunchEnabledMeta,
        lunchEnabled.isAcceptableOrUnknown(
          data['lunch_enabled']!,
          _lunchEnabledMeta,
        ),
      );
    }
    if (data.containsKey('lunch_time')) {
      context.handle(
        _lunchTimeMeta,
        lunchTime.isAcceptableOrUnknown(data['lunch_time']!, _lunchTimeMeta),
      );
    }
    if (data.containsKey('dinner_enabled')) {
      context.handle(
        _dinnerEnabledMeta,
        dinnerEnabled.isAcceptableOrUnknown(
          data['dinner_enabled']!,
          _dinnerEnabledMeta,
        ),
      );
    }
    if (data.containsKey('dinner_time')) {
      context.handle(
        _dinnerTimeMeta,
        dinnerTime.isAcceptableOrUnknown(data['dinner_time']!, _dinnerTimeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotificationSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      lunchEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}lunch_enabled'],
      )!,
      lunchTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lunch_time'],
      )!,
      dinnerEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dinner_enabled'],
      )!,
      dinnerTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dinner_time'],
      )!,
    );
  }

  @override
  $NotificationSettingsTable createAlias(String alias) {
    return $NotificationSettingsTable(attachedDatabase, alias);
  }
}

class NotificationSetting extends DataClass
    implements Insertable<NotificationSetting> {
  final int id;
  final bool lunchEnabled;
  final String lunchTime;
  final bool dinnerEnabled;
  final String dinnerTime;
  const NotificationSetting({
    required this.id,
    required this.lunchEnabled,
    required this.lunchTime,
    required this.dinnerEnabled,
    required this.dinnerTime,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['lunch_enabled'] = Variable<bool>(lunchEnabled);
    map['lunch_time'] = Variable<String>(lunchTime);
    map['dinner_enabled'] = Variable<bool>(dinnerEnabled);
    map['dinner_time'] = Variable<String>(dinnerTime);
    return map;
  }

  NotificationSettingsCompanion toCompanion(bool nullToAbsent) {
    return NotificationSettingsCompanion(
      id: Value(id),
      lunchEnabled: Value(lunchEnabled),
      lunchTime: Value(lunchTime),
      dinnerEnabled: Value(dinnerEnabled),
      dinnerTime: Value(dinnerTime),
    );
  }

  factory NotificationSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationSetting(
      id: serializer.fromJson<int>(json['id']),
      lunchEnabled: serializer.fromJson<bool>(json['lunchEnabled']),
      lunchTime: serializer.fromJson<String>(json['lunchTime']),
      dinnerEnabled: serializer.fromJson<bool>(json['dinnerEnabled']),
      dinnerTime: serializer.fromJson<String>(json['dinnerTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lunchEnabled': serializer.toJson<bool>(lunchEnabled),
      'lunchTime': serializer.toJson<String>(lunchTime),
      'dinnerEnabled': serializer.toJson<bool>(dinnerEnabled),
      'dinnerTime': serializer.toJson<String>(dinnerTime),
    };
  }

  NotificationSetting copyWith({
    int? id,
    bool? lunchEnabled,
    String? lunchTime,
    bool? dinnerEnabled,
    String? dinnerTime,
  }) => NotificationSetting(
    id: id ?? this.id,
    lunchEnabled: lunchEnabled ?? this.lunchEnabled,
    lunchTime: lunchTime ?? this.lunchTime,
    dinnerEnabled: dinnerEnabled ?? this.dinnerEnabled,
    dinnerTime: dinnerTime ?? this.dinnerTime,
  );
  NotificationSetting copyWithCompanion(NotificationSettingsCompanion data) {
    return NotificationSetting(
      id: data.id.present ? data.id.value : this.id,
      lunchEnabled: data.lunchEnabled.present
          ? data.lunchEnabled.value
          : this.lunchEnabled,
      lunchTime: data.lunchTime.present ? data.lunchTime.value : this.lunchTime,
      dinnerEnabled: data.dinnerEnabled.present
          ? data.dinnerEnabled.value
          : this.dinnerEnabled,
      dinnerTime: data.dinnerTime.present
          ? data.dinnerTime.value
          : this.dinnerTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationSetting(')
          ..write('id: $id, ')
          ..write('lunchEnabled: $lunchEnabled, ')
          ..write('lunchTime: $lunchTime, ')
          ..write('dinnerEnabled: $dinnerEnabled, ')
          ..write('dinnerTime: $dinnerTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, lunchEnabled, lunchTime, dinnerEnabled, dinnerTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationSetting &&
          other.id == this.id &&
          other.lunchEnabled == this.lunchEnabled &&
          other.lunchTime == this.lunchTime &&
          other.dinnerEnabled == this.dinnerEnabled &&
          other.dinnerTime == this.dinnerTime);
}

class NotificationSettingsCompanion
    extends UpdateCompanion<NotificationSetting> {
  final Value<int> id;
  final Value<bool> lunchEnabled;
  final Value<String> lunchTime;
  final Value<bool> dinnerEnabled;
  final Value<String> dinnerTime;
  const NotificationSettingsCompanion({
    this.id = const Value.absent(),
    this.lunchEnabled = const Value.absent(),
    this.lunchTime = const Value.absent(),
    this.dinnerEnabled = const Value.absent(),
    this.dinnerTime = const Value.absent(),
  });
  NotificationSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.lunchEnabled = const Value.absent(),
    this.lunchTime = const Value.absent(),
    this.dinnerEnabled = const Value.absent(),
    this.dinnerTime = const Value.absent(),
  });
  static Insertable<NotificationSetting> custom({
    Expression<int>? id,
    Expression<bool>? lunchEnabled,
    Expression<String>? lunchTime,
    Expression<bool>? dinnerEnabled,
    Expression<String>? dinnerTime,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lunchEnabled != null) 'lunch_enabled': lunchEnabled,
      if (lunchTime != null) 'lunch_time': lunchTime,
      if (dinnerEnabled != null) 'dinner_enabled': dinnerEnabled,
      if (dinnerTime != null) 'dinner_time': dinnerTime,
    });
  }

  NotificationSettingsCompanion copyWith({
    Value<int>? id,
    Value<bool>? lunchEnabled,
    Value<String>? lunchTime,
    Value<bool>? dinnerEnabled,
    Value<String>? dinnerTime,
  }) {
    return NotificationSettingsCompanion(
      id: id ?? this.id,
      lunchEnabled: lunchEnabled ?? this.lunchEnabled,
      lunchTime: lunchTime ?? this.lunchTime,
      dinnerEnabled: dinnerEnabled ?? this.dinnerEnabled,
      dinnerTime: dinnerTime ?? this.dinnerTime,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lunchEnabled.present) {
      map['lunch_enabled'] = Variable<bool>(lunchEnabled.value);
    }
    if (lunchTime.present) {
      map['lunch_time'] = Variable<String>(lunchTime.value);
    }
    if (dinnerEnabled.present) {
      map['dinner_enabled'] = Variable<bool>(dinnerEnabled.value);
    }
    if (dinnerTime.present) {
      map['dinner_time'] = Variable<String>(dinnerTime.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationSettingsCompanion(')
          ..write('id: $id, ')
          ..write('lunchEnabled: $lunchEnabled, ')
          ..write('lunchTime: $lunchTime, ')
          ..write('dinnerEnabled: $dinnerEnabled, ')
          ..write('dinnerTime: $dinnerTime')
          ..write(')'))
        .toString();
  }
}

class $FavoriteExpensesTable extends FavoriteExpenses
    with TableInfo<$FavoriteExpensesTable, FavoriteExpense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoriteExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<int> category = GeneratedColumn<int>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
    'memo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _usageCountMeta = const VerificationMeta(
    'usageCount',
  );
  @override
  late final GeneratedColumn<int> usageCount = GeneratedColumn<int>(
    'usage_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    amount,
    category,
    memo,
    usageCount,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorite_expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoriteExpense> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    }
    if (data.containsKey('usage_count')) {
      context.handle(
        _usageCountMeta,
        usageCount.isAcceptableOrUnknown(data['usage_count']!, _usageCountMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FavoriteExpense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteExpense(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category'],
      )!,
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      )!,
      usageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}usage_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FavoriteExpensesTable createAlias(String alias) {
    return $FavoriteExpensesTable(attachedDatabase, alias);
  }
}

class FavoriteExpense extends DataClass implements Insertable<FavoriteExpense> {
  final int id;
  final int amount;
  final int category;
  final String memo;
  final int usageCount;
  final DateTime createdAt;
  const FavoriteExpense({
    required this.id,
    required this.amount,
    required this.category,
    required this.memo,
    required this.usageCount,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['amount'] = Variable<int>(amount);
    map['category'] = Variable<int>(category);
    map['memo'] = Variable<String>(memo);
    map['usage_count'] = Variable<int>(usageCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FavoriteExpensesCompanion toCompanion(bool nullToAbsent) {
    return FavoriteExpensesCompanion(
      id: Value(id),
      amount: Value(amount),
      category: Value(category),
      memo: Value(memo),
      usageCount: Value(usageCount),
      createdAt: Value(createdAt),
    );
  }

  factory FavoriteExpense.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteExpense(
      id: serializer.fromJson<int>(json['id']),
      amount: serializer.fromJson<int>(json['amount']),
      category: serializer.fromJson<int>(json['category']),
      memo: serializer.fromJson<String>(json['memo']),
      usageCount: serializer.fromJson<int>(json['usageCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'amount': serializer.toJson<int>(amount),
      'category': serializer.toJson<int>(category),
      'memo': serializer.toJson<String>(memo),
      'usageCount': serializer.toJson<int>(usageCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FavoriteExpense copyWith({
    int? id,
    int? amount,
    int? category,
    String? memo,
    int? usageCount,
    DateTime? createdAt,
  }) => FavoriteExpense(
    id: id ?? this.id,
    amount: amount ?? this.amount,
    category: category ?? this.category,
    memo: memo ?? this.memo,
    usageCount: usageCount ?? this.usageCount,
    createdAt: createdAt ?? this.createdAt,
  );
  FavoriteExpense copyWithCompanion(FavoriteExpensesCompanion data) {
    return FavoriteExpense(
      id: data.id.present ? data.id.value : this.id,
      amount: data.amount.present ? data.amount.value : this.amount,
      category: data.category.present ? data.category.value : this.category,
      memo: data.memo.present ? data.memo.value : this.memo,
      usageCount: data.usageCount.present
          ? data.usageCount.value
          : this.usageCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteExpense(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('memo: $memo, ')
          ..write('usageCount: $usageCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, amount, category, memo, usageCount, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteExpense &&
          other.id == this.id &&
          other.amount == this.amount &&
          other.category == this.category &&
          other.memo == this.memo &&
          other.usageCount == this.usageCount &&
          other.createdAt == this.createdAt);
}

class FavoriteExpensesCompanion extends UpdateCompanion<FavoriteExpense> {
  final Value<int> id;
  final Value<int> amount;
  final Value<int> category;
  final Value<String> memo;
  final Value<int> usageCount;
  final Value<DateTime> createdAt;
  const FavoriteExpensesCompanion({
    this.id = const Value.absent(),
    this.amount = const Value.absent(),
    this.category = const Value.absent(),
    this.memo = const Value.absent(),
    this.usageCount = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FavoriteExpensesCompanion.insert({
    this.id = const Value.absent(),
    required int amount,
    required int category,
    this.memo = const Value.absent(),
    this.usageCount = const Value.absent(),
    required DateTime createdAt,
  }) : amount = Value(amount),
       category = Value(category),
       createdAt = Value(createdAt);
  static Insertable<FavoriteExpense> custom({
    Expression<int>? id,
    Expression<int>? amount,
    Expression<int>? category,
    Expression<String>? memo,
    Expression<int>? usageCount,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (category != null) 'category': category,
      if (memo != null) 'memo': memo,
      if (usageCount != null) 'usage_count': usageCount,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FavoriteExpensesCompanion copyWith({
    Value<int>? id,
    Value<int>? amount,
    Value<int>? category,
    Value<String>? memo,
    Value<int>? usageCount,
    Value<DateTime>? createdAt,
  }) {
    return FavoriteExpensesCompanion(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      memo: memo ?? this.memo,
      usageCount: usageCount ?? this.usageCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (category.present) {
      map['category'] = Variable<int>(category.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (usageCount.present) {
      map['usage_count'] = Variable<int>(usageCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteExpensesCompanion(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('memo: $memo, ')
          ..write('usageCount: $usageCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $DailyBudgetsTable dailyBudgets = $DailyBudgetsTable(this);
  late final $AcornsTable acorns = $AcornsTable(this);
  late final $AchievementsTable achievements = $AchievementsTable(this);
  late final $UserPreferencesTable userPreferences = $UserPreferencesTable(
    this,
  );
  late final $NotificationSettingsTable notificationSettings =
      $NotificationSettingsTable(this);
  late final $FavoriteExpensesTable favoriteExpenses = $FavoriteExpensesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    expenses,
    dailyBudgets,
    acorns,
    achievements,
    userPreferences,
    notificationSettings,
    favoriteExpenses,
  ];
}

typedef $$ExpensesTableCreateCompanionBuilder =
    ExpensesCompanion Function({
      Value<int> id,
      required int amount,
      required int category,
      Value<String> memo,
      required DateTime createdAt,
    });
typedef $$ExpensesTableUpdateCompanionBuilder =
    ExpensesCompanion Function({
      Value<int> id,
      Value<int> amount,
      Value<int> category,
      Value<String> memo,
      Value<DateTime> createdAt,
    });

class $$ExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<int> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ExpensesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpensesTable,
          Expense,
          $$ExpensesTableFilterComposer,
          $$ExpensesTableOrderingComposer,
          $$ExpensesTableAnnotationComposer,
          $$ExpensesTableCreateCompanionBuilder,
          $$ExpensesTableUpdateCompanionBuilder,
          (Expense, BaseReferences<_$AppDatabase, $ExpensesTable, Expense>),
          Expense,
          PrefetchHooks Function()
        > {
  $$ExpensesTableTableManager(_$AppDatabase db, $ExpensesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<int> category = const Value.absent(),
                Value<String> memo = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ExpensesCompanion(
                id: id,
                amount: amount,
                category: category,
                memo: memo,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int amount,
                required int category,
                Value<String> memo = const Value.absent(),
                required DateTime createdAt,
              }) => ExpensesCompanion.insert(
                id: id,
                amount: amount,
                category: category,
                memo: memo,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpensesTable,
      Expense,
      $$ExpensesTableFilterComposer,
      $$ExpensesTableOrderingComposer,
      $$ExpensesTableAnnotationComposer,
      $$ExpensesTableCreateCompanionBuilder,
      $$ExpensesTableUpdateCompanionBuilder,
      (Expense, BaseReferences<_$AppDatabase, $ExpensesTable, Expense>),
      Expense,
      PrefetchHooks Function()
    >;
typedef $$DailyBudgetsTableCreateCompanionBuilder =
    DailyBudgetsCompanion Function({
      Value<int> id,
      required DateTime date,
      Value<int> baseAmount,
      Value<int> carryOver,
      Value<String?> mood,
    });
typedef $$DailyBudgetsTableUpdateCompanionBuilder =
    DailyBudgetsCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<int> baseAmount,
      Value<int> carryOver,
      Value<String?> mood,
    });

class $$DailyBudgetsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyBudgetsTable> {
  $$DailyBudgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseAmount => $composableBuilder(
    column: $table.baseAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get carryOver => $composableBuilder(
    column: $table.carryOver,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyBudgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyBudgetsTable> {
  $$DailyBudgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseAmount => $composableBuilder(
    column: $table.baseAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get carryOver => $composableBuilder(
    column: $table.carryOver,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyBudgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyBudgetsTable> {
  $$DailyBudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get baseAmount => $composableBuilder(
    column: $table.baseAmount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get carryOver =>
      $composableBuilder(column: $table.carryOver, builder: (column) => column);

  GeneratedColumn<String> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);
}

class $$DailyBudgetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyBudgetsTable,
          DailyBudget,
          $$DailyBudgetsTableFilterComposer,
          $$DailyBudgetsTableOrderingComposer,
          $$DailyBudgetsTableAnnotationComposer,
          $$DailyBudgetsTableCreateCompanionBuilder,
          $$DailyBudgetsTableUpdateCompanionBuilder,
          (
            DailyBudget,
            BaseReferences<_$AppDatabase, $DailyBudgetsTable, DailyBudget>,
          ),
          DailyBudget,
          PrefetchHooks Function()
        > {
  $$DailyBudgetsTableTableManager(_$AppDatabase db, $DailyBudgetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyBudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyBudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyBudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> baseAmount = const Value.absent(),
                Value<int> carryOver = const Value.absent(),
                Value<String?> mood = const Value.absent(),
              }) => DailyBudgetsCompanion(
                id: id,
                date: date,
                baseAmount: baseAmount,
                carryOver: carryOver,
                mood: mood,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                Value<int> baseAmount = const Value.absent(),
                Value<int> carryOver = const Value.absent(),
                Value<String?> mood = const Value.absent(),
              }) => DailyBudgetsCompanion.insert(
                id: id,
                date: date,
                baseAmount: baseAmount,
                carryOver: carryOver,
                mood: mood,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyBudgetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyBudgetsTable,
      DailyBudget,
      $$DailyBudgetsTableFilterComposer,
      $$DailyBudgetsTableOrderingComposer,
      $$DailyBudgetsTableAnnotationComposer,
      $$DailyBudgetsTableCreateCompanionBuilder,
      $$DailyBudgetsTableUpdateCompanionBuilder,
      (
        DailyBudget,
        BaseReferences<_$AppDatabase, $DailyBudgetsTable, DailyBudget>,
      ),
      DailyBudget,
      PrefetchHooks Function()
    >;
typedef $$AcornsTableCreateCompanionBuilder =
    AcornsCompanion Function({
      Value<int> id,
      required DateTime date,
      required int count,
      required String reason,
    });
typedef $$AcornsTableUpdateCompanionBuilder =
    AcornsCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<int> count,
      Value<String> reason,
    });

class $$AcornsTableFilterComposer
    extends Composer<_$AppDatabase, $AcornsTable> {
  $$AcornsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AcornsTableOrderingComposer
    extends Composer<_$AppDatabase, $AcornsTable> {
  $$AcornsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AcornsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AcornsTable> {
  $$AcornsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);
}

class $$AcornsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AcornsTable,
          Acorn,
          $$AcornsTableFilterComposer,
          $$AcornsTableOrderingComposer,
          $$AcornsTableAnnotationComposer,
          $$AcornsTableCreateCompanionBuilder,
          $$AcornsTableUpdateCompanionBuilder,
          (Acorn, BaseReferences<_$AppDatabase, $AcornsTable, Acorn>),
          Acorn,
          PrefetchHooks Function()
        > {
  $$AcornsTableTableManager(_$AppDatabase db, $AcornsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AcornsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AcornsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AcornsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<String> reason = const Value.absent(),
              }) => AcornsCompanion(
                id: id,
                date: date,
                count: count,
                reason: reason,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required int count,
                required String reason,
              }) => AcornsCompanion.insert(
                id: id,
                date: date,
                count: count,
                reason: reason,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AcornsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AcornsTable,
      Acorn,
      $$AcornsTableFilterComposer,
      $$AcornsTableOrderingComposer,
      $$AcornsTableAnnotationComposer,
      $$AcornsTableCreateCompanionBuilder,
      $$AcornsTableUpdateCompanionBuilder,
      (Acorn, BaseReferences<_$AppDatabase, $AcornsTable, Acorn>),
      Acorn,
      PrefetchHooks Function()
    >;
typedef $$AchievementsTableCreateCompanionBuilder =
    AchievementsCompanion Function({
      Value<int> id,
      required String type,
      required DateTime achievedAt,
    });
typedef $$AchievementsTableUpdateCompanionBuilder =
    AchievementsCompanion Function({
      Value<int> id,
      Value<String> type,
      Value<DateTime> achievedAt,
    });

class $$AchievementsTableFilterComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AchievementsTableOrderingComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AchievementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => column,
  );
}

class $$AchievementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AchievementsTable,
          Achievement,
          $$AchievementsTableFilterComposer,
          $$AchievementsTableOrderingComposer,
          $$AchievementsTableAnnotationComposer,
          $$AchievementsTableCreateCompanionBuilder,
          $$AchievementsTableUpdateCompanionBuilder,
          (
            Achievement,
            BaseReferences<_$AppDatabase, $AchievementsTable, Achievement>,
          ),
          Achievement,
          PrefetchHooks Function()
        > {
  $$AchievementsTableTableManager(_$AppDatabase db, $AchievementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AchievementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AchievementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AchievementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> achievedAt = const Value.absent(),
              }) => AchievementsCompanion(
                id: id,
                type: type,
                achievedAt: achievedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String type,
                required DateTime achievedAt,
              }) => AchievementsCompanion.insert(
                id: id,
                type: type,
                achievedAt: achievedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AchievementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AchievementsTable,
      Achievement,
      $$AchievementsTableFilterComposer,
      $$AchievementsTableOrderingComposer,
      $$AchievementsTableAnnotationComposer,
      $$AchievementsTableCreateCompanionBuilder,
      $$AchievementsTableUpdateCompanionBuilder,
      (
        Achievement,
        BaseReferences<_$AppDatabase, $AchievementsTable, Achievement>,
      ),
      Achievement,
      PrefetchHooks Function()
    >;
typedef $$UserPreferencesTableCreateCompanionBuilder =
    UserPreferencesCompanion Function({
      Value<int> id,
      Value<bool> isDarkMode,
      Value<bool> isOnboardingCompleted,
      Value<int> dailyBudget,
      Value<bool> carryoverEnabled,
    });
typedef $$UserPreferencesTableUpdateCompanionBuilder =
    UserPreferencesCompanion Function({
      Value<int> id,
      Value<bool> isDarkMode,
      Value<bool> isOnboardingCompleted,
      Value<int> dailyBudget,
      Value<bool> carryoverEnabled,
    });

class $$UserPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDarkMode => $composableBuilder(
    column: $table.isDarkMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOnboardingCompleted => $composableBuilder(
    column: $table.isOnboardingCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyBudget => $composableBuilder(
    column: $table.dailyBudget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get carryoverEnabled => $composableBuilder(
    column: $table.carryoverEnabled,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDarkMode => $composableBuilder(
    column: $table.isDarkMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOnboardingCompleted => $composableBuilder(
    column: $table.isOnboardingCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyBudget => $composableBuilder(
    column: $table.dailyBudget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get carryoverEnabled => $composableBuilder(
    column: $table.carryoverEnabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get isDarkMode => $composableBuilder(
    column: $table.isDarkMode,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isOnboardingCompleted => $composableBuilder(
    column: $table.isOnboardingCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dailyBudget => $composableBuilder(
    column: $table.dailyBudget,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get carryoverEnabled => $composableBuilder(
    column: $table.carryoverEnabled,
    builder: (column) => column,
  );
}

class $$UserPreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserPreferencesTable,
          UserPreference,
          $$UserPreferencesTableFilterComposer,
          $$UserPreferencesTableOrderingComposer,
          $$UserPreferencesTableAnnotationComposer,
          $$UserPreferencesTableCreateCompanionBuilder,
          $$UserPreferencesTableUpdateCompanionBuilder,
          (
            UserPreference,
            BaseReferences<
              _$AppDatabase,
              $UserPreferencesTable,
              UserPreference
            >,
          ),
          UserPreference,
          PrefetchHooks Function()
        > {
  $$UserPreferencesTableTableManager(
    _$AppDatabase db,
    $UserPreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserPreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserPreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> isDarkMode = const Value.absent(),
                Value<bool> isOnboardingCompleted = const Value.absent(),
                Value<int> dailyBudget = const Value.absent(),
                Value<bool> carryoverEnabled = const Value.absent(),
              }) => UserPreferencesCompanion(
                id: id,
                isDarkMode: isDarkMode,
                isOnboardingCompleted: isOnboardingCompleted,
                dailyBudget: dailyBudget,
                carryoverEnabled: carryoverEnabled,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> isDarkMode = const Value.absent(),
                Value<bool> isOnboardingCompleted = const Value.absent(),
                Value<int> dailyBudget = const Value.absent(),
                Value<bool> carryoverEnabled = const Value.absent(),
              }) => UserPreferencesCompanion.insert(
                id: id,
                isDarkMode: isDarkMode,
                isOnboardingCompleted: isOnboardingCompleted,
                dailyBudget: dailyBudget,
                carryoverEnabled: carryoverEnabled,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserPreferencesTable,
      UserPreference,
      $$UserPreferencesTableFilterComposer,
      $$UserPreferencesTableOrderingComposer,
      $$UserPreferencesTableAnnotationComposer,
      $$UserPreferencesTableCreateCompanionBuilder,
      $$UserPreferencesTableUpdateCompanionBuilder,
      (
        UserPreference,
        BaseReferences<_$AppDatabase, $UserPreferencesTable, UserPreference>,
      ),
      UserPreference,
      PrefetchHooks Function()
    >;
typedef $$NotificationSettingsTableCreateCompanionBuilder =
    NotificationSettingsCompanion Function({
      Value<int> id,
      Value<bool> lunchEnabled,
      Value<String> lunchTime,
      Value<bool> dinnerEnabled,
      Value<String> dinnerTime,
    });
typedef $$NotificationSettingsTableUpdateCompanionBuilder =
    NotificationSettingsCompanion Function({
      Value<int> id,
      Value<bool> lunchEnabled,
      Value<String> lunchTime,
      Value<bool> dinnerEnabled,
      Value<String> dinnerTime,
    });

class $$NotificationSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationSettingsTable> {
  $$NotificationSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get lunchEnabled => $composableBuilder(
    column: $table.lunchEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lunchTime => $composableBuilder(
    column: $table.lunchTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dinnerEnabled => $composableBuilder(
    column: $table.dinnerEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dinnerTime => $composableBuilder(
    column: $table.dinnerTime,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotificationSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationSettingsTable> {
  $$NotificationSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get lunchEnabled => $composableBuilder(
    column: $table.lunchEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lunchTime => $composableBuilder(
    column: $table.lunchTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dinnerEnabled => $composableBuilder(
    column: $table.dinnerEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dinnerTime => $composableBuilder(
    column: $table.dinnerTime,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotificationSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationSettingsTable> {
  $$NotificationSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get lunchEnabled => $composableBuilder(
    column: $table.lunchEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lunchTime =>
      $composableBuilder(column: $table.lunchTime, builder: (column) => column);

  GeneratedColumn<bool> get dinnerEnabled => $composableBuilder(
    column: $table.dinnerEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dinnerTime => $composableBuilder(
    column: $table.dinnerTime,
    builder: (column) => column,
  );
}

class $$NotificationSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotificationSettingsTable,
          NotificationSetting,
          $$NotificationSettingsTableFilterComposer,
          $$NotificationSettingsTableOrderingComposer,
          $$NotificationSettingsTableAnnotationComposer,
          $$NotificationSettingsTableCreateCompanionBuilder,
          $$NotificationSettingsTableUpdateCompanionBuilder,
          (
            NotificationSetting,
            BaseReferences<
              _$AppDatabase,
              $NotificationSettingsTable,
              NotificationSetting
            >,
          ),
          NotificationSetting,
          PrefetchHooks Function()
        > {
  $$NotificationSettingsTableTableManager(
    _$AppDatabase db,
    $NotificationSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationSettingsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$NotificationSettingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> lunchEnabled = const Value.absent(),
                Value<String> lunchTime = const Value.absent(),
                Value<bool> dinnerEnabled = const Value.absent(),
                Value<String> dinnerTime = const Value.absent(),
              }) => NotificationSettingsCompanion(
                id: id,
                lunchEnabled: lunchEnabled,
                lunchTime: lunchTime,
                dinnerEnabled: dinnerEnabled,
                dinnerTime: dinnerTime,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> lunchEnabled = const Value.absent(),
                Value<String> lunchTime = const Value.absent(),
                Value<bool> dinnerEnabled = const Value.absent(),
                Value<String> dinnerTime = const Value.absent(),
              }) => NotificationSettingsCompanion.insert(
                id: id,
                lunchEnabled: lunchEnabled,
                lunchTime: lunchTime,
                dinnerEnabled: dinnerEnabled,
                dinnerTime: dinnerTime,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotificationSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotificationSettingsTable,
      NotificationSetting,
      $$NotificationSettingsTableFilterComposer,
      $$NotificationSettingsTableOrderingComposer,
      $$NotificationSettingsTableAnnotationComposer,
      $$NotificationSettingsTableCreateCompanionBuilder,
      $$NotificationSettingsTableUpdateCompanionBuilder,
      (
        NotificationSetting,
        BaseReferences<
          _$AppDatabase,
          $NotificationSettingsTable,
          NotificationSetting
        >,
      ),
      NotificationSetting,
      PrefetchHooks Function()
    >;
typedef $$FavoriteExpensesTableCreateCompanionBuilder =
    FavoriteExpensesCompanion Function({
      Value<int> id,
      required int amount,
      required int category,
      Value<String> memo,
      Value<int> usageCount,
      required DateTime createdAt,
    });
typedef $$FavoriteExpensesTableUpdateCompanionBuilder =
    FavoriteExpensesCompanion Function({
      Value<int> id,
      Value<int> amount,
      Value<int> category,
      Value<String> memo,
      Value<int> usageCount,
      Value<DateTime> createdAt,
    });

class $$FavoriteExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $FavoriteExpensesTable> {
  $$FavoriteExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get usageCount => $composableBuilder(
    column: $table.usageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoriteExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoriteExpensesTable> {
  $$FavoriteExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get usageCount => $composableBuilder(
    column: $table.usageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoriteExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoriteExpensesTable> {
  $$FavoriteExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<int> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<int> get usageCount => $composableBuilder(
    column: $table.usageCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FavoriteExpensesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavoriteExpensesTable,
          FavoriteExpense,
          $$FavoriteExpensesTableFilterComposer,
          $$FavoriteExpensesTableOrderingComposer,
          $$FavoriteExpensesTableAnnotationComposer,
          $$FavoriteExpensesTableCreateCompanionBuilder,
          $$FavoriteExpensesTableUpdateCompanionBuilder,
          (
            FavoriteExpense,
            BaseReferences<
              _$AppDatabase,
              $FavoriteExpensesTable,
              FavoriteExpense
            >,
          ),
          FavoriteExpense,
          PrefetchHooks Function()
        > {
  $$FavoriteExpensesTableTableManager(
    _$AppDatabase db,
    $FavoriteExpensesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoriteExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoriteExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoriteExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<int> category = const Value.absent(),
                Value<String> memo = const Value.absent(),
                Value<int> usageCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => FavoriteExpensesCompanion(
                id: id,
                amount: amount,
                category: category,
                memo: memo,
                usageCount: usageCount,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int amount,
                required int category,
                Value<String> memo = const Value.absent(),
                Value<int> usageCount = const Value.absent(),
                required DateTime createdAt,
              }) => FavoriteExpensesCompanion.insert(
                id: id,
                amount: amount,
                category: category,
                memo: memo,
                usageCount: usageCount,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoriteExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavoriteExpensesTable,
      FavoriteExpense,
      $$FavoriteExpensesTableFilterComposer,
      $$FavoriteExpensesTableOrderingComposer,
      $$FavoriteExpensesTableAnnotationComposer,
      $$FavoriteExpensesTableCreateCompanionBuilder,
      $$FavoriteExpensesTableUpdateCompanionBuilder,
      (
        FavoriteExpense,
        BaseReferences<_$AppDatabase, $FavoriteExpensesTable, FavoriteExpense>,
      ),
      FavoriteExpense,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
  $$DailyBudgetsTableTableManager get dailyBudgets =>
      $$DailyBudgetsTableTableManager(_db, _db.dailyBudgets);
  $$AcornsTableTableManager get acorns =>
      $$AcornsTableTableManager(_db, _db.acorns);
  $$AchievementsTableTableManager get achievements =>
      $$AchievementsTableTableManager(_db, _db.achievements);
  $$UserPreferencesTableTableManager get userPreferences =>
      $$UserPreferencesTableTableManager(_db, _db.userPreferences);
  $$NotificationSettingsTableTableManager get notificationSettings =>
      $$NotificationSettingsTableTableManager(_db, _db.notificationSettings);
  $$FavoriteExpensesTableTableManager get favoriteExpenses =>
      $$FavoriteExpensesTableTableManager(_db, _db.favoriteExpenses);
}
