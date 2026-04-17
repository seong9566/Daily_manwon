// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'favorite_templates_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FavoriteTemplatesState {

 List<FavoriteExpenseEntity> get favorites; List<ExpenseEntity> get recentExpenses; bool get isLoading;
/// Create a copy of FavoriteTemplatesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FavoriteTemplatesStateCopyWith<FavoriteTemplatesState> get copyWith => _$FavoriteTemplatesStateCopyWithImpl<FavoriteTemplatesState>(this as FavoriteTemplatesState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FavoriteTemplatesState&&const DeepCollectionEquality().equals(other.favorites, favorites)&&const DeepCollectionEquality().equals(other.recentExpenses, recentExpenses)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(favorites),const DeepCollectionEquality().hash(recentExpenses),isLoading);

@override
String toString() {
  return 'FavoriteTemplatesState(favorites: $favorites, recentExpenses: $recentExpenses, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class $FavoriteTemplatesStateCopyWith<$Res>  {
  factory $FavoriteTemplatesStateCopyWith(FavoriteTemplatesState value, $Res Function(FavoriteTemplatesState) _then) = _$FavoriteTemplatesStateCopyWithImpl;
@useResult
$Res call({
 List<FavoriteExpenseEntity> favorites, List<ExpenseEntity> recentExpenses, bool isLoading
});




}
/// @nodoc
class _$FavoriteTemplatesStateCopyWithImpl<$Res>
    implements $FavoriteTemplatesStateCopyWith<$Res> {
  _$FavoriteTemplatesStateCopyWithImpl(this._self, this._then);

  final FavoriteTemplatesState _self;
  final $Res Function(FavoriteTemplatesState) _then;

/// Create a copy of FavoriteTemplatesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? favorites = null,Object? recentExpenses = null,Object? isLoading = null,}) {
  return _then(_self.copyWith(
favorites: null == favorites ? _self.favorites : favorites // ignore: cast_nullable_to_non_nullable
as List<FavoriteExpenseEntity>,recentExpenses: null == recentExpenses ? _self.recentExpenses : recentExpenses // ignore: cast_nullable_to_non_nullable
as List<ExpenseEntity>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FavoriteTemplatesState].
extension FavoriteTemplatesStatePatterns on FavoriteTemplatesState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FavoriteTemplatesState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FavoriteTemplatesState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FavoriteTemplatesState value)  $default,){
final _that = this;
switch (_that) {
case _FavoriteTemplatesState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FavoriteTemplatesState value)?  $default,){
final _that = this;
switch (_that) {
case _FavoriteTemplatesState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<FavoriteExpenseEntity> favorites,  List<ExpenseEntity> recentExpenses,  bool isLoading)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FavoriteTemplatesState() when $default != null:
return $default(_that.favorites,_that.recentExpenses,_that.isLoading);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<FavoriteExpenseEntity> favorites,  List<ExpenseEntity> recentExpenses,  bool isLoading)  $default,) {final _that = this;
switch (_that) {
case _FavoriteTemplatesState():
return $default(_that.favorites,_that.recentExpenses,_that.isLoading);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<FavoriteExpenseEntity> favorites,  List<ExpenseEntity> recentExpenses,  bool isLoading)?  $default,) {final _that = this;
switch (_that) {
case _FavoriteTemplatesState() when $default != null:
return $default(_that.favorites,_that.recentExpenses,_that.isLoading);case _:
  return null;

}
}

}

/// @nodoc


class _FavoriteTemplatesState implements FavoriteTemplatesState {
  const _FavoriteTemplatesState({final  List<FavoriteExpenseEntity> favorites = const [], final  List<ExpenseEntity> recentExpenses = const [], this.isLoading = true}): _favorites = favorites,_recentExpenses = recentExpenses;
  

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

@override@JsonKey() final  bool isLoading;

/// Create a copy of FavoriteTemplatesState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FavoriteTemplatesStateCopyWith<_FavoriteTemplatesState> get copyWith => __$FavoriteTemplatesStateCopyWithImpl<_FavoriteTemplatesState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FavoriteTemplatesState&&const DeepCollectionEquality().equals(other._favorites, _favorites)&&const DeepCollectionEquality().equals(other._recentExpenses, _recentExpenses)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_favorites),const DeepCollectionEquality().hash(_recentExpenses),isLoading);

@override
String toString() {
  return 'FavoriteTemplatesState(favorites: $favorites, recentExpenses: $recentExpenses, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class _$FavoriteTemplatesStateCopyWith<$Res> implements $FavoriteTemplatesStateCopyWith<$Res> {
  factory _$FavoriteTemplatesStateCopyWith(_FavoriteTemplatesState value, $Res Function(_FavoriteTemplatesState) _then) = __$FavoriteTemplatesStateCopyWithImpl;
@override @useResult
$Res call({
 List<FavoriteExpenseEntity> favorites, List<ExpenseEntity> recentExpenses, bool isLoading
});




}
/// @nodoc
class __$FavoriteTemplatesStateCopyWithImpl<$Res>
    implements _$FavoriteTemplatesStateCopyWith<$Res> {
  __$FavoriteTemplatesStateCopyWithImpl(this._self, this._then);

  final _FavoriteTemplatesState _self;
  final $Res Function(_FavoriteTemplatesState) _then;

/// Create a copy of FavoriteTemplatesState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? favorites = null,Object? recentExpenses = null,Object? isLoading = null,}) {
  return _then(_FavoriteTemplatesState(
favorites: null == favorites ? _self._favorites : favorites // ignore: cast_nullable_to_non_nullable
as List<FavoriteExpenseEntity>,recentExpenses: null == recentExpenses ? _self._recentExpenses : recentExpenses // ignore: cast_nullable_to_non_nullable
as List<ExpenseEntity>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
