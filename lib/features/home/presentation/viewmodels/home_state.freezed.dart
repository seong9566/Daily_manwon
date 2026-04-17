// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HomeState {

 int get remainingBudget; int get totalBudget; List<ExpenseEntity> get expenses; int get totalAcorns; int get streakDays; bool get isLoading; int get carryOver; bool get isNewWeek; List<FavoriteExpenseEntity> get favorites; List<ExpenseEntity> get recentExpenses;
/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeStateCopyWith<HomeState> get copyWith => _$HomeStateCopyWithImpl<HomeState>(this as HomeState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeState&&(identical(other.remainingBudget, remainingBudget) || other.remainingBudget == remainingBudget)&&(identical(other.totalBudget, totalBudget) || other.totalBudget == totalBudget)&&const DeepCollectionEquality().equals(other.expenses, expenses)&&(identical(other.totalAcorns, totalAcorns) || other.totalAcorns == totalAcorns)&&(identical(other.streakDays, streakDays) || other.streakDays == streakDays)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.carryOver, carryOver) || other.carryOver == carryOver)&&(identical(other.isNewWeek, isNewWeek) || other.isNewWeek == isNewWeek)&&const DeepCollectionEquality().equals(other.favorites, favorites)&&const DeepCollectionEquality().equals(other.recentExpenses, recentExpenses));
}


@override
int get hashCode => Object.hash(runtimeType,remainingBudget,totalBudget,const DeepCollectionEquality().hash(expenses),totalAcorns,streakDays,isLoading,carryOver,isNewWeek,const DeepCollectionEquality().hash(favorites),const DeepCollectionEquality().hash(recentExpenses));

@override
String toString() {
  return 'HomeState(remainingBudget: $remainingBudget, totalBudget: $totalBudget, expenses: $expenses, totalAcorns: $totalAcorns, streakDays: $streakDays, isLoading: $isLoading, carryOver: $carryOver, isNewWeek: $isNewWeek, favorites: $favorites, recentExpenses: $recentExpenses)';
}


}

/// @nodoc
abstract mixin class $HomeStateCopyWith<$Res>  {
  factory $HomeStateCopyWith(HomeState value, $Res Function(HomeState) _then) = _$HomeStateCopyWithImpl;
@useResult
$Res call({
 int remainingBudget, int totalBudget, List<ExpenseEntity> expenses, int totalAcorns, int streakDays, bool isLoading, int carryOver, bool isNewWeek, List<FavoriteExpenseEntity> favorites, List<ExpenseEntity> recentExpenses
});




}
/// @nodoc
class _$HomeStateCopyWithImpl<$Res>
    implements $HomeStateCopyWith<$Res> {
  _$HomeStateCopyWithImpl(this._self, this._then);

  final HomeState _self;
  final $Res Function(HomeState) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? remainingBudget = null,Object? totalBudget = null,Object? expenses = null,Object? totalAcorns = null,Object? streakDays = null,Object? isLoading = null,Object? carryOver = null,Object? isNewWeek = null,Object? favorites = null,Object? recentExpenses = null,}) {
  return _then(_self.copyWith(
remainingBudget: null == remainingBudget ? _self.remainingBudget : remainingBudget // ignore: cast_nullable_to_non_nullable
as int,totalBudget: null == totalBudget ? _self.totalBudget : totalBudget // ignore: cast_nullable_to_non_nullable
as int,expenses: null == expenses ? _self.expenses : expenses // ignore: cast_nullable_to_non_nullable
as List<ExpenseEntity>,totalAcorns: null == totalAcorns ? _self.totalAcorns : totalAcorns // ignore: cast_nullable_to_non_nullable
as int,streakDays: null == streakDays ? _self.streakDays : streakDays // ignore: cast_nullable_to_non_nullable
as int,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,carryOver: null == carryOver ? _self.carryOver : carryOver // ignore: cast_nullable_to_non_nullable
as int,isNewWeek: null == isNewWeek ? _self.isNewWeek : isNewWeek // ignore: cast_nullable_to_non_nullable
as bool,favorites: null == favorites ? _self.favorites : favorites // ignore: cast_nullable_to_non_nullable
as List<FavoriteExpenseEntity>,recentExpenses: null == recentExpenses ? _self.recentExpenses : recentExpenses // ignore: cast_nullable_to_non_nullable
as List<ExpenseEntity>,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeState].
extension HomeStatePatterns on HomeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeState value)  $default,){
final _that = this;
switch (_that) {
case _HomeState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeState value)?  $default,){
final _that = this;
switch (_that) {
case _HomeState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int remainingBudget,  int totalBudget,  List<ExpenseEntity> expenses,  int totalAcorns,  int streakDays,  bool isLoading,  int carryOver,  bool isNewWeek,  List<FavoriteExpenseEntity> favorites,  List<ExpenseEntity> recentExpenses)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeState() when $default != null:
return $default(_that.remainingBudget,_that.totalBudget,_that.expenses,_that.totalAcorns,_that.streakDays,_that.isLoading,_that.carryOver,_that.isNewWeek,_that.favorites,_that.recentExpenses);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int remainingBudget,  int totalBudget,  List<ExpenseEntity> expenses,  int totalAcorns,  int streakDays,  bool isLoading,  int carryOver,  bool isNewWeek,  List<FavoriteExpenseEntity> favorites,  List<ExpenseEntity> recentExpenses)  $default,) {final _that = this;
switch (_that) {
case _HomeState():
return $default(_that.remainingBudget,_that.totalBudget,_that.expenses,_that.totalAcorns,_that.streakDays,_that.isLoading,_that.carryOver,_that.isNewWeek,_that.favorites,_that.recentExpenses);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int remainingBudget,  int totalBudget,  List<ExpenseEntity> expenses,  int totalAcorns,  int streakDays,  bool isLoading,  int carryOver,  bool isNewWeek,  List<FavoriteExpenseEntity> favorites,  List<ExpenseEntity> recentExpenses)?  $default,) {final _that = this;
switch (_that) {
case _HomeState() when $default != null:
return $default(_that.remainingBudget,_that.totalBudget,_that.expenses,_that.totalAcorns,_that.streakDays,_that.isLoading,_that.carryOver,_that.isNewWeek,_that.favorites,_that.recentExpenses);case _:
  return null;

}
}

}

/// @nodoc


class _HomeState implements HomeState {
  const _HomeState({this.remainingBudget = 10000, this.totalBudget = 10000, final  List<ExpenseEntity> expenses = const [], this.totalAcorns = 0, this.streakDays = 0, this.isLoading = true, this.carryOver = 0, this.isNewWeek = false, final  List<FavoriteExpenseEntity> favorites = const [], final  List<ExpenseEntity> recentExpenses = const []}): _expenses = expenses,_favorites = favorites,_recentExpenses = recentExpenses;
  

@override@JsonKey() final  int remainingBudget;
@override@JsonKey() final  int totalBudget;
 final  List<ExpenseEntity> _expenses;
@override@JsonKey() List<ExpenseEntity> get expenses {
  if (_expenses is EqualUnmodifiableListView) return _expenses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_expenses);
}

@override@JsonKey() final  int totalAcorns;
@override@JsonKey() final  int streakDays;
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  int carryOver;
@override@JsonKey() final  bool isNewWeek;
 final  List<FavoriteExpenseEntity> _favorites;
@override@JsonKey() List<FavoriteExpenseEntity> get favorites {
  if (_favorites is EqualUnmodifiableListView) return _favorites;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_favorites);
}

 final  List<ExpenseEntity> _recentExpenses;
@override@JsonKey() List<ExpenseEntity> get recentExpenses {
  if (_recentExpenses is EqualUnmodifiableListView) return _recentExpenses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentExpenses);
}


/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeStateCopyWith<_HomeState> get copyWith => __$HomeStateCopyWithImpl<_HomeState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeState&&(identical(other.remainingBudget, remainingBudget) || other.remainingBudget == remainingBudget)&&(identical(other.totalBudget, totalBudget) || other.totalBudget == totalBudget)&&const DeepCollectionEquality().equals(other._expenses, _expenses)&&(identical(other.totalAcorns, totalAcorns) || other.totalAcorns == totalAcorns)&&(identical(other.streakDays, streakDays) || other.streakDays == streakDays)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.carryOver, carryOver) || other.carryOver == carryOver)&&(identical(other.isNewWeek, isNewWeek) || other.isNewWeek == isNewWeek)&&const DeepCollectionEquality().equals(other._favorites, _favorites)&&const DeepCollectionEquality().equals(other._recentExpenses, _recentExpenses));
}


@override
int get hashCode => Object.hash(runtimeType,remainingBudget,totalBudget,const DeepCollectionEquality().hash(_expenses),totalAcorns,streakDays,isLoading,carryOver,isNewWeek,const DeepCollectionEquality().hash(_favorites),const DeepCollectionEquality().hash(_recentExpenses));

@override
String toString() {
  return 'HomeState(remainingBudget: $remainingBudget, totalBudget: $totalBudget, expenses: $expenses, totalAcorns: $totalAcorns, streakDays: $streakDays, isLoading: $isLoading, carryOver: $carryOver, isNewWeek: $isNewWeek, favorites: $favorites, recentExpenses: $recentExpenses)';
}


}

/// @nodoc
abstract mixin class _$HomeStateCopyWith<$Res> implements $HomeStateCopyWith<$Res> {
  factory _$HomeStateCopyWith(_HomeState value, $Res Function(_HomeState) _then) = __$HomeStateCopyWithImpl;
@override @useResult
$Res call({
 int remainingBudget, int totalBudget, List<ExpenseEntity> expenses, int totalAcorns, int streakDays, bool isLoading, int carryOver, bool isNewWeek, List<FavoriteExpenseEntity> favorites, List<ExpenseEntity> recentExpenses
});




}
/// @nodoc
class __$HomeStateCopyWithImpl<$Res>
    implements _$HomeStateCopyWith<$Res> {
  __$HomeStateCopyWithImpl(this._self, this._then);

  final _HomeState _self;
  final $Res Function(_HomeState) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? remainingBudget = null,Object? totalBudget = null,Object? expenses = null,Object? totalAcorns = null,Object? streakDays = null,Object? isLoading = null,Object? carryOver = null,Object? isNewWeek = null,Object? favorites = null,Object? recentExpenses = null,}) {
  return _then(_HomeState(
remainingBudget: null == remainingBudget ? _self.remainingBudget : remainingBudget // ignore: cast_nullable_to_non_nullable
as int,totalBudget: null == totalBudget ? _self.totalBudget : totalBudget // ignore: cast_nullable_to_non_nullable
as int,expenses: null == expenses ? _self._expenses : expenses // ignore: cast_nullable_to_non_nullable
as List<ExpenseEntity>,totalAcorns: null == totalAcorns ? _self.totalAcorns : totalAcorns // ignore: cast_nullable_to_non_nullable
as int,streakDays: null == streakDays ? _self.streakDays : streakDays // ignore: cast_nullable_to_non_nullable
as int,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,carryOver: null == carryOver ? _self.carryOver : carryOver // ignore: cast_nullable_to_non_nullable
as int,isNewWeek: null == isNewWeek ? _self.isNewWeek : isNewWeek // ignore: cast_nullable_to_non_nullable
as bool,favorites: null == favorites ? _self._favorites : favorites // ignore: cast_nullable_to_non_nullable
as List<FavoriteExpenseEntity>,recentExpenses: null == recentExpenses ? _self._recentExpenses : recentExpenses // ignore: cast_nullable_to_non_nullable
as List<ExpenseEntity>,
  ));
}


}

// dart format on
