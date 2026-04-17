// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stats_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StatsState {

 DateTime get selectedMonth; DateTime get selectedWeekStart; StatsViewMode get viewMode; List<CategoryStat> get categoryStats; List<WeekdayStat> get weekdayStats; List<DailyStat> get dailyStats; double get dailyBudget; int get weeklyTotalSpent; int get weeklyBudget; int get weeklySuccessDays; int get weeklyTotalDays; int? get weeklyTopCategoryIndex; int? get prevWeekTotalSpent;
/// Create a copy of StatsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatsStateCopyWith<StatsState> get copyWith => _$StatsStateCopyWithImpl<StatsState>(this as StatsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatsState&&(identical(other.selectedMonth, selectedMonth) || other.selectedMonth == selectedMonth)&&(identical(other.selectedWeekStart, selectedWeekStart) || other.selectedWeekStart == selectedWeekStart)&&(identical(other.viewMode, viewMode) || other.viewMode == viewMode)&&const DeepCollectionEquality().equals(other.categoryStats, categoryStats)&&const DeepCollectionEquality().equals(other.weekdayStats, weekdayStats)&&const DeepCollectionEquality().equals(other.dailyStats, dailyStats)&&(identical(other.dailyBudget, dailyBudget) || other.dailyBudget == dailyBudget)&&(identical(other.weeklyTotalSpent, weeklyTotalSpent) || other.weeklyTotalSpent == weeklyTotalSpent)&&(identical(other.weeklyBudget, weeklyBudget) || other.weeklyBudget == weeklyBudget)&&(identical(other.weeklySuccessDays, weeklySuccessDays) || other.weeklySuccessDays == weeklySuccessDays)&&(identical(other.weeklyTotalDays, weeklyTotalDays) || other.weeklyTotalDays == weeklyTotalDays)&&(identical(other.weeklyTopCategoryIndex, weeklyTopCategoryIndex) || other.weeklyTopCategoryIndex == weeklyTopCategoryIndex)&&(identical(other.prevWeekTotalSpent, prevWeekTotalSpent) || other.prevWeekTotalSpent == prevWeekTotalSpent));
}


@override
int get hashCode => Object.hash(runtimeType,selectedMonth,selectedWeekStart,viewMode,const DeepCollectionEquality().hash(categoryStats),const DeepCollectionEquality().hash(weekdayStats),const DeepCollectionEquality().hash(dailyStats),dailyBudget,weeklyTotalSpent,weeklyBudget,weeklySuccessDays,weeklyTotalDays,weeklyTopCategoryIndex,prevWeekTotalSpent);

@override
String toString() {
  return 'StatsState(selectedMonth: $selectedMonth, selectedWeekStart: $selectedWeekStart, viewMode: $viewMode, categoryStats: $categoryStats, weekdayStats: $weekdayStats, dailyStats: $dailyStats, dailyBudget: $dailyBudget, weeklyTotalSpent: $weeklyTotalSpent, weeklyBudget: $weeklyBudget, weeklySuccessDays: $weeklySuccessDays, weeklyTotalDays: $weeklyTotalDays, weeklyTopCategoryIndex: $weeklyTopCategoryIndex, prevWeekTotalSpent: $prevWeekTotalSpent)';
}


}

/// @nodoc
abstract mixin class $StatsStateCopyWith<$Res>  {
  factory $StatsStateCopyWith(StatsState value, $Res Function(StatsState) _then) = _$StatsStateCopyWithImpl;
@useResult
$Res call({
 DateTime selectedMonth, DateTime selectedWeekStart, StatsViewMode viewMode, List<CategoryStat> categoryStats, List<WeekdayStat> weekdayStats, List<DailyStat> dailyStats, double dailyBudget, int weeklyTotalSpent, int weeklyBudget, int weeklySuccessDays, int weeklyTotalDays, int? weeklyTopCategoryIndex, int? prevWeekTotalSpent
});




}
/// @nodoc
class _$StatsStateCopyWithImpl<$Res>
    implements $StatsStateCopyWith<$Res> {
  _$StatsStateCopyWithImpl(this._self, this._then);

  final StatsState _self;
  final $Res Function(StatsState) _then;

/// Create a copy of StatsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedMonth = null,Object? selectedWeekStart = null,Object? viewMode = null,Object? categoryStats = null,Object? weekdayStats = null,Object? dailyStats = null,Object? dailyBudget = null,Object? weeklyTotalSpent = null,Object? weeklyBudget = null,Object? weeklySuccessDays = null,Object? weeklyTotalDays = null,Object? weeklyTopCategoryIndex = freezed,Object? prevWeekTotalSpent = freezed,}) {
  return _then(_self.copyWith(
selectedMonth: null == selectedMonth ? _self.selectedMonth : selectedMonth // ignore: cast_nullable_to_non_nullable
as DateTime,selectedWeekStart: null == selectedWeekStart ? _self.selectedWeekStart : selectedWeekStart // ignore: cast_nullable_to_non_nullable
as DateTime,viewMode: null == viewMode ? _self.viewMode : viewMode // ignore: cast_nullable_to_non_nullable
as StatsViewMode,categoryStats: null == categoryStats ? _self.categoryStats : categoryStats // ignore: cast_nullable_to_non_nullable
as List<CategoryStat>,weekdayStats: null == weekdayStats ? _self.weekdayStats : weekdayStats // ignore: cast_nullable_to_non_nullable
as List<WeekdayStat>,dailyStats: null == dailyStats ? _self.dailyStats : dailyStats // ignore: cast_nullable_to_non_nullable
as List<DailyStat>,dailyBudget: null == dailyBudget ? _self.dailyBudget : dailyBudget // ignore: cast_nullable_to_non_nullable
as double,weeklyTotalSpent: null == weeklyTotalSpent ? _self.weeklyTotalSpent : weeklyTotalSpent // ignore: cast_nullable_to_non_nullable
as int,weeklyBudget: null == weeklyBudget ? _self.weeklyBudget : weeklyBudget // ignore: cast_nullable_to_non_nullable
as int,weeklySuccessDays: null == weeklySuccessDays ? _self.weeklySuccessDays : weeklySuccessDays // ignore: cast_nullable_to_non_nullable
as int,weeklyTotalDays: null == weeklyTotalDays ? _self.weeklyTotalDays : weeklyTotalDays // ignore: cast_nullable_to_non_nullable
as int,weeklyTopCategoryIndex: freezed == weeklyTopCategoryIndex ? _self.weeklyTopCategoryIndex : weeklyTopCategoryIndex // ignore: cast_nullable_to_non_nullable
as int?,prevWeekTotalSpent: freezed == prevWeekTotalSpent ? _self.prevWeekTotalSpent : prevWeekTotalSpent // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [StatsState].
extension StatsStatePatterns on StatsState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StatsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatsState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StatsState value)  $default,){
final _that = this;
switch (_that) {
case _StatsState():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StatsState value)?  $default,){
final _that = this;
switch (_that) {
case _StatsState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime selectedMonth,  DateTime selectedWeekStart,  StatsViewMode viewMode,  List<CategoryStat> categoryStats,  List<WeekdayStat> weekdayStats,  List<DailyStat> dailyStats,  double dailyBudget,  int weeklyTotalSpent,  int weeklyBudget,  int weeklySuccessDays,  int weeklyTotalDays,  int? weeklyTopCategoryIndex,  int? prevWeekTotalSpent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatsState() when $default != null:
return $default(_that.selectedMonth,_that.selectedWeekStart,_that.viewMode,_that.categoryStats,_that.weekdayStats,_that.dailyStats,_that.dailyBudget,_that.weeklyTotalSpent,_that.weeklyBudget,_that.weeklySuccessDays,_that.weeklyTotalDays,_that.weeklyTopCategoryIndex,_that.prevWeekTotalSpent);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime selectedMonth,  DateTime selectedWeekStart,  StatsViewMode viewMode,  List<CategoryStat> categoryStats,  List<WeekdayStat> weekdayStats,  List<DailyStat> dailyStats,  double dailyBudget,  int weeklyTotalSpent,  int weeklyBudget,  int weeklySuccessDays,  int weeklyTotalDays,  int? weeklyTopCategoryIndex,  int? prevWeekTotalSpent)  $default,) {final _that = this;
switch (_that) {
case _StatsState():
return $default(_that.selectedMonth,_that.selectedWeekStart,_that.viewMode,_that.categoryStats,_that.weekdayStats,_that.dailyStats,_that.dailyBudget,_that.weeklyTotalSpent,_that.weeklyBudget,_that.weeklySuccessDays,_that.weeklyTotalDays,_that.weeklyTopCategoryIndex,_that.prevWeekTotalSpent);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime selectedMonth,  DateTime selectedWeekStart,  StatsViewMode viewMode,  List<CategoryStat> categoryStats,  List<WeekdayStat> weekdayStats,  List<DailyStat> dailyStats,  double dailyBudget,  int weeklyTotalSpent,  int weeklyBudget,  int weeklySuccessDays,  int weeklyTotalDays,  int? weeklyTopCategoryIndex,  int? prevWeekTotalSpent)?  $default,) {final _that = this;
switch (_that) {
case _StatsState() when $default != null:
return $default(_that.selectedMonth,_that.selectedWeekStart,_that.viewMode,_that.categoryStats,_that.weekdayStats,_that.dailyStats,_that.dailyBudget,_that.weeklyTotalSpent,_that.weeklyBudget,_that.weeklySuccessDays,_that.weeklyTotalDays,_that.weeklyTopCategoryIndex,_that.prevWeekTotalSpent);case _:
  return null;

}
}

}

/// @nodoc


class _StatsState implements StatsState {
  const _StatsState({required this.selectedMonth, required this.selectedWeekStart, this.viewMode = StatsViewMode.monthly, final  List<CategoryStat> categoryStats = const [], final  List<WeekdayStat> weekdayStats = const [], final  List<DailyStat> dailyStats = const [], this.dailyBudget = 0.0, this.weeklyTotalSpent = 0, this.weeklyBudget = 0, this.weeklySuccessDays = 0, this.weeklyTotalDays = 7, this.weeklyTopCategoryIndex, this.prevWeekTotalSpent}): _categoryStats = categoryStats,_weekdayStats = weekdayStats,_dailyStats = dailyStats;
  

@override final  DateTime selectedMonth;
@override final  DateTime selectedWeekStart;
@override@JsonKey() final  StatsViewMode viewMode;
 final  List<CategoryStat> _categoryStats;
@override@JsonKey() List<CategoryStat> get categoryStats {
  if (_categoryStats is EqualUnmodifiableListView) return _categoryStats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categoryStats);
}

 final  List<WeekdayStat> _weekdayStats;
@override@JsonKey() List<WeekdayStat> get weekdayStats {
  if (_weekdayStats is EqualUnmodifiableListView) return _weekdayStats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_weekdayStats);
}

 final  List<DailyStat> _dailyStats;
@override@JsonKey() List<DailyStat> get dailyStats {
  if (_dailyStats is EqualUnmodifiableListView) return _dailyStats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dailyStats);
}

@override@JsonKey() final  double dailyBudget;
@override@JsonKey() final  int weeklyTotalSpent;
@override@JsonKey() final  int weeklyBudget;
@override@JsonKey() final  int weeklySuccessDays;
@override@JsonKey() final  int weeklyTotalDays;
@override final  int? weeklyTopCategoryIndex;
@override final  int? prevWeekTotalSpent;

/// Create a copy of StatsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatsStateCopyWith<_StatsState> get copyWith => __$StatsStateCopyWithImpl<_StatsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatsState&&(identical(other.selectedMonth, selectedMonth) || other.selectedMonth == selectedMonth)&&(identical(other.selectedWeekStart, selectedWeekStart) || other.selectedWeekStart == selectedWeekStart)&&(identical(other.viewMode, viewMode) || other.viewMode == viewMode)&&const DeepCollectionEquality().equals(other._categoryStats, _categoryStats)&&const DeepCollectionEquality().equals(other._weekdayStats, _weekdayStats)&&const DeepCollectionEquality().equals(other._dailyStats, _dailyStats)&&(identical(other.dailyBudget, dailyBudget) || other.dailyBudget == dailyBudget)&&(identical(other.weeklyTotalSpent, weeklyTotalSpent) || other.weeklyTotalSpent == weeklyTotalSpent)&&(identical(other.weeklyBudget, weeklyBudget) || other.weeklyBudget == weeklyBudget)&&(identical(other.weeklySuccessDays, weeklySuccessDays) || other.weeklySuccessDays == weeklySuccessDays)&&(identical(other.weeklyTotalDays, weeklyTotalDays) || other.weeklyTotalDays == weeklyTotalDays)&&(identical(other.weeklyTopCategoryIndex, weeklyTopCategoryIndex) || other.weeklyTopCategoryIndex == weeklyTopCategoryIndex)&&(identical(other.prevWeekTotalSpent, prevWeekTotalSpent) || other.prevWeekTotalSpent == prevWeekTotalSpent));
}


@override
int get hashCode => Object.hash(runtimeType,selectedMonth,selectedWeekStart,viewMode,const DeepCollectionEquality().hash(_categoryStats),const DeepCollectionEquality().hash(_weekdayStats),const DeepCollectionEquality().hash(_dailyStats),dailyBudget,weeklyTotalSpent,weeklyBudget,weeklySuccessDays,weeklyTotalDays,weeklyTopCategoryIndex,prevWeekTotalSpent);

@override
String toString() {
  return 'StatsState(selectedMonth: $selectedMonth, selectedWeekStart: $selectedWeekStart, viewMode: $viewMode, categoryStats: $categoryStats, weekdayStats: $weekdayStats, dailyStats: $dailyStats, dailyBudget: $dailyBudget, weeklyTotalSpent: $weeklyTotalSpent, weeklyBudget: $weeklyBudget, weeklySuccessDays: $weeklySuccessDays, weeklyTotalDays: $weeklyTotalDays, weeklyTopCategoryIndex: $weeklyTopCategoryIndex, prevWeekTotalSpent: $prevWeekTotalSpent)';
}


}

/// @nodoc
abstract mixin class _$StatsStateCopyWith<$Res> implements $StatsStateCopyWith<$Res> {
  factory _$StatsStateCopyWith(_StatsState value, $Res Function(_StatsState) _then) = __$StatsStateCopyWithImpl;
@override @useResult
$Res call({
 DateTime selectedMonth, DateTime selectedWeekStart, StatsViewMode viewMode, List<CategoryStat> categoryStats, List<WeekdayStat> weekdayStats, List<DailyStat> dailyStats, double dailyBudget, int weeklyTotalSpent, int weeklyBudget, int weeklySuccessDays, int weeklyTotalDays, int? weeklyTopCategoryIndex, int? prevWeekTotalSpent
});




}
/// @nodoc
class __$StatsStateCopyWithImpl<$Res>
    implements _$StatsStateCopyWith<$Res> {
  __$StatsStateCopyWithImpl(this._self, this._then);

  final _StatsState _self;
  final $Res Function(_StatsState) _then;

/// Create a copy of StatsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedMonth = null,Object? selectedWeekStart = null,Object? viewMode = null,Object? categoryStats = null,Object? weekdayStats = null,Object? dailyStats = null,Object? dailyBudget = null,Object? weeklyTotalSpent = null,Object? weeklyBudget = null,Object? weeklySuccessDays = null,Object? weeklyTotalDays = null,Object? weeklyTopCategoryIndex = freezed,Object? prevWeekTotalSpent = freezed,}) {
  return _then(_StatsState(
selectedMonth: null == selectedMonth ? _self.selectedMonth : selectedMonth // ignore: cast_nullable_to_non_nullable
as DateTime,selectedWeekStart: null == selectedWeekStart ? _self.selectedWeekStart : selectedWeekStart // ignore: cast_nullable_to_non_nullable
as DateTime,viewMode: null == viewMode ? _self.viewMode : viewMode // ignore: cast_nullable_to_non_nullable
as StatsViewMode,categoryStats: null == categoryStats ? _self._categoryStats : categoryStats // ignore: cast_nullable_to_non_nullable
as List<CategoryStat>,weekdayStats: null == weekdayStats ? _self._weekdayStats : weekdayStats // ignore: cast_nullable_to_non_nullable
as List<WeekdayStat>,dailyStats: null == dailyStats ? _self._dailyStats : dailyStats // ignore: cast_nullable_to_non_nullable
as List<DailyStat>,dailyBudget: null == dailyBudget ? _self.dailyBudget : dailyBudget // ignore: cast_nullable_to_non_nullable
as double,weeklyTotalSpent: null == weeklyTotalSpent ? _self.weeklyTotalSpent : weeklyTotalSpent // ignore: cast_nullable_to_non_nullable
as int,weeklyBudget: null == weeklyBudget ? _self.weeklyBudget : weeklyBudget // ignore: cast_nullable_to_non_nullable
as int,weeklySuccessDays: null == weeklySuccessDays ? _self.weeklySuccessDays : weeklySuccessDays // ignore: cast_nullable_to_non_nullable
as int,weeklyTotalDays: null == weeklyTotalDays ? _self.weeklyTotalDays : weeklyTotalDays // ignore: cast_nullable_to_non_nullable
as int,weeklyTopCategoryIndex: freezed == weeklyTopCategoryIndex ? _self.weeklyTopCategoryIndex : weeklyTopCategoryIndex // ignore: cast_nullable_to_non_nullable
as int?,prevWeekTotalSpent: freezed == prevWeekTotalSpent ? _self.prevWeekTotalSpent : prevWeekTotalSpent // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
