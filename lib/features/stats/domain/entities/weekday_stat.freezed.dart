// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weekday_stat.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WeekdayStat {

 int get weekday; int get avgAmount;
/// Create a copy of WeekdayStat
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeekdayStatCopyWith<WeekdayStat> get copyWith => _$WeekdayStatCopyWithImpl<WeekdayStat>(this as WeekdayStat, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeekdayStat&&(identical(other.weekday, weekday) || other.weekday == weekday)&&(identical(other.avgAmount, avgAmount) || other.avgAmount == avgAmount));
}


@override
int get hashCode => Object.hash(runtimeType,weekday,avgAmount);

@override
String toString() {
  return 'WeekdayStat(weekday: $weekday, avgAmount: $avgAmount)';
}


}

/// @nodoc
abstract mixin class $WeekdayStatCopyWith<$Res>  {
  factory $WeekdayStatCopyWith(WeekdayStat value, $Res Function(WeekdayStat) _then) = _$WeekdayStatCopyWithImpl;
@useResult
$Res call({
 int weekday, int avgAmount
});




}
/// @nodoc
class _$WeekdayStatCopyWithImpl<$Res>
    implements $WeekdayStatCopyWith<$Res> {
  _$WeekdayStatCopyWithImpl(this._self, this._then);

  final WeekdayStat _self;
  final $Res Function(WeekdayStat) _then;

/// Create a copy of WeekdayStat
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? weekday = null,Object? avgAmount = null,}) {
  return _then(_self.copyWith(
weekday: null == weekday ? _self.weekday : weekday // ignore: cast_nullable_to_non_nullable
as int,avgAmount: null == avgAmount ? _self.avgAmount : avgAmount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [WeekdayStat].
extension WeekdayStatPatterns on WeekdayStat {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeekdayStat value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeekdayStat() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeekdayStat value)  $default,){
final _that = this;
switch (_that) {
case _WeekdayStat():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeekdayStat value)?  $default,){
final _that = this;
switch (_that) {
case _WeekdayStat() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int weekday,  int avgAmount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeekdayStat() when $default != null:
return $default(_that.weekday,_that.avgAmount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int weekday,  int avgAmount)  $default,) {final _that = this;
switch (_that) {
case _WeekdayStat():
return $default(_that.weekday,_that.avgAmount);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int weekday,  int avgAmount)?  $default,) {final _that = this;
switch (_that) {
case _WeekdayStat() when $default != null:
return $default(_that.weekday,_that.avgAmount);case _:
  return null;

}
}

}

/// @nodoc


class _WeekdayStat implements WeekdayStat {
  const _WeekdayStat({required this.weekday, required this.avgAmount});
  

@override final  int weekday;
@override final  int avgAmount;

/// Create a copy of WeekdayStat
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeekdayStatCopyWith<_WeekdayStat> get copyWith => __$WeekdayStatCopyWithImpl<_WeekdayStat>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeekdayStat&&(identical(other.weekday, weekday) || other.weekday == weekday)&&(identical(other.avgAmount, avgAmount) || other.avgAmount == avgAmount));
}


@override
int get hashCode => Object.hash(runtimeType,weekday,avgAmount);

@override
String toString() {
  return 'WeekdayStat(weekday: $weekday, avgAmount: $avgAmount)';
}


}

/// @nodoc
abstract mixin class _$WeekdayStatCopyWith<$Res> implements $WeekdayStatCopyWith<$Res> {
  factory _$WeekdayStatCopyWith(_WeekdayStat value, $Res Function(_WeekdayStat) _then) = __$WeekdayStatCopyWithImpl;
@override @useResult
$Res call({
 int weekday, int avgAmount
});




}
/// @nodoc
class __$WeekdayStatCopyWithImpl<$Res>
    implements _$WeekdayStatCopyWith<$Res> {
  __$WeekdayStatCopyWithImpl(this._self, this._then);

  final _WeekdayStat _self;
  final $Res Function(_WeekdayStat) _then;

/// Create a copy of WeekdayStat
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? weekday = null,Object? avgAmount = null,}) {
  return _then(_WeekdayStat(
weekday: null == weekday ? _self.weekday : weekday // ignore: cast_nullable_to_non_nullable
as int,avgAmount: null == avgAmount ? _self.avgAmount : avgAmount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
