// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_stat.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DailyStat {

 DateTime get date; int get amount;
/// Create a copy of DailyStat
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyStatCopyWith<DailyStat> get copyWith => _$DailyStatCopyWithImpl<DailyStat>(this as DailyStat, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyStat&&(identical(other.date, date) || other.date == date)&&(identical(other.amount, amount) || other.amount == amount));
}


@override
int get hashCode => Object.hash(runtimeType,date,amount);

@override
String toString() {
  return 'DailyStat(date: $date, amount: $amount)';
}


}

/// @nodoc
abstract mixin class $DailyStatCopyWith<$Res>  {
  factory $DailyStatCopyWith(DailyStat value, $Res Function(DailyStat) _then) = _$DailyStatCopyWithImpl;
@useResult
$Res call({
 DateTime date, int amount
});




}
/// @nodoc
class _$DailyStatCopyWithImpl<$Res>
    implements $DailyStatCopyWith<$Res> {
  _$DailyStatCopyWithImpl(this._self, this._then);

  final DailyStat _self;
  final $Res Function(DailyStat) _then;

/// Create a copy of DailyStat
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? amount = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyStat].
extension DailyStatPatterns on DailyStat {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyStat value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyStat() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyStat value)  $default,){
final _that = this;
switch (_that) {
case _DailyStat():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyStat value)?  $default,){
final _that = this;
switch (_that) {
case _DailyStat() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  int amount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyStat() when $default != null:
return $default(_that.date,_that.amount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  int amount)  $default,) {final _that = this;
switch (_that) {
case _DailyStat():
return $default(_that.date,_that.amount);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  int amount)?  $default,) {final _that = this;
switch (_that) {
case _DailyStat() when $default != null:
return $default(_that.date,_that.amount);case _:
  return null;

}
}

}

/// @nodoc


class _DailyStat implements DailyStat {
  const _DailyStat({required this.date, required this.amount});
  

@override final  DateTime date;
@override final  int amount;

/// Create a copy of DailyStat
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyStatCopyWith<_DailyStat> get copyWith => __$DailyStatCopyWithImpl<_DailyStat>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyStat&&(identical(other.date, date) || other.date == date)&&(identical(other.amount, amount) || other.amount == amount));
}


@override
int get hashCode => Object.hash(runtimeType,date,amount);

@override
String toString() {
  return 'DailyStat(date: $date, amount: $amount)';
}


}

/// @nodoc
abstract mixin class _$DailyStatCopyWith<$Res> implements $DailyStatCopyWith<$Res> {
  factory _$DailyStatCopyWith(_DailyStat value, $Res Function(_DailyStat) _then) = __$DailyStatCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, int amount
});




}
/// @nodoc
class __$DailyStatCopyWithImpl<$Res>
    implements _$DailyStatCopyWith<$Res> {
  __$DailyStatCopyWithImpl(this._self, this._then);

  final _DailyStat _self;
  final $Res Function(_DailyStat) _then;

/// Create a copy of DailyStat
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? amount = null,}) {
  return _then(_DailyStat(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
