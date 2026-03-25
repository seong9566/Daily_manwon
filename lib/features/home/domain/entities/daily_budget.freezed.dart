// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_budget.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DailyBudgetEntity {

 int get id; DateTime get date; int get baseAmount; int get carryOver;
/// Create a copy of DailyBudgetEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyBudgetEntityCopyWith<DailyBudgetEntity> get copyWith => _$DailyBudgetEntityCopyWithImpl<DailyBudgetEntity>(this as DailyBudgetEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyBudgetEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.baseAmount, baseAmount) || other.baseAmount == baseAmount)&&(identical(other.carryOver, carryOver) || other.carryOver == carryOver));
}


@override
int get hashCode => Object.hash(runtimeType,id,date,baseAmount,carryOver);

@override
String toString() {
  return 'DailyBudgetEntity(id: $id, date: $date, baseAmount: $baseAmount, carryOver: $carryOver)';
}


}

/// @nodoc
abstract mixin class $DailyBudgetEntityCopyWith<$Res>  {
  factory $DailyBudgetEntityCopyWith(DailyBudgetEntity value, $Res Function(DailyBudgetEntity) _then) = _$DailyBudgetEntityCopyWithImpl;
@useResult
$Res call({
 int id, DateTime date, int baseAmount, int carryOver
});




}
/// @nodoc
class _$DailyBudgetEntityCopyWithImpl<$Res>
    implements $DailyBudgetEntityCopyWith<$Res> {
  _$DailyBudgetEntityCopyWithImpl(this._self, this._then);

  final DailyBudgetEntity _self;
  final $Res Function(DailyBudgetEntity) _then;

/// Create a copy of DailyBudgetEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? date = null,Object? baseAmount = null,Object? carryOver = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,baseAmount: null == baseAmount ? _self.baseAmount : baseAmount // ignore: cast_nullable_to_non_nullable
as int,carryOver: null == carryOver ? _self.carryOver : carryOver // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyBudgetEntity].
extension DailyBudgetEntityPatterns on DailyBudgetEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyBudgetEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyBudgetEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyBudgetEntity value)  $default,){
final _that = this;
switch (_that) {
case _DailyBudgetEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyBudgetEntity value)?  $default,){
final _that = this;
switch (_that) {
case _DailyBudgetEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  DateTime date,  int baseAmount,  int carryOver)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyBudgetEntity() when $default != null:
return $default(_that.id,_that.date,_that.baseAmount,_that.carryOver);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  DateTime date,  int baseAmount,  int carryOver)  $default,) {final _that = this;
switch (_that) {
case _DailyBudgetEntity():
return $default(_that.id,_that.date,_that.baseAmount,_that.carryOver);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  DateTime date,  int baseAmount,  int carryOver)?  $default,) {final _that = this;
switch (_that) {
case _DailyBudgetEntity() when $default != null:
return $default(_that.id,_that.date,_that.baseAmount,_that.carryOver);case _:
  return null;

}
}

}

/// @nodoc


class _DailyBudgetEntity implements DailyBudgetEntity {
  const _DailyBudgetEntity({required this.id, required this.date, this.baseAmount = 10000, this.carryOver = 0});
  

@override final  int id;
@override final  DateTime date;
@override@JsonKey() final  int baseAmount;
@override@JsonKey() final  int carryOver;

/// Create a copy of DailyBudgetEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyBudgetEntityCopyWith<_DailyBudgetEntity> get copyWith => __$DailyBudgetEntityCopyWithImpl<_DailyBudgetEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyBudgetEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.baseAmount, baseAmount) || other.baseAmount == baseAmount)&&(identical(other.carryOver, carryOver) || other.carryOver == carryOver));
}


@override
int get hashCode => Object.hash(runtimeType,id,date,baseAmount,carryOver);

@override
String toString() {
  return 'DailyBudgetEntity(id: $id, date: $date, baseAmount: $baseAmount, carryOver: $carryOver)';
}


}

/// @nodoc
abstract mixin class _$DailyBudgetEntityCopyWith<$Res> implements $DailyBudgetEntityCopyWith<$Res> {
  factory _$DailyBudgetEntityCopyWith(_DailyBudgetEntity value, $Res Function(_DailyBudgetEntity) _then) = __$DailyBudgetEntityCopyWithImpl;
@override @useResult
$Res call({
 int id, DateTime date, int baseAmount, int carryOver
});




}
/// @nodoc
class __$DailyBudgetEntityCopyWithImpl<$Res>
    implements _$DailyBudgetEntityCopyWith<$Res> {
  __$DailyBudgetEntityCopyWithImpl(this._self, this._then);

  final _DailyBudgetEntity _self;
  final $Res Function(_DailyBudgetEntity) _then;

/// Create a copy of DailyBudgetEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? date = null,Object? baseAmount = null,Object? carryOver = null,}) {
  return _then(_DailyBudgetEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,baseAmount: null == baseAmount ? _self.baseAmount : baseAmount // ignore: cast_nullable_to_non_nullable
as int,carryOver: null == carryOver ? _self.carryOver : carryOver // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
