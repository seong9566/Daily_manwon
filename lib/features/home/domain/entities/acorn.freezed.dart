// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'acorn.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AcornEntity {

 int get id; DateTime get date; int get count; String get reason;
/// Create a copy of AcornEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AcornEntityCopyWith<AcornEntity> get copyWith => _$AcornEntityCopyWithImpl<AcornEntity>(this as AcornEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AcornEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.count, count) || other.count == count)&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode => Object.hash(runtimeType,id,date,count,reason);

@override
String toString() {
  return 'AcornEntity(id: $id, date: $date, count: $count, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $AcornEntityCopyWith<$Res>  {
  factory $AcornEntityCopyWith(AcornEntity value, $Res Function(AcornEntity) _then) = _$AcornEntityCopyWithImpl;
@useResult
$Res call({
 int id, DateTime date, int count, String reason
});




}
/// @nodoc
class _$AcornEntityCopyWithImpl<$Res>
    implements $AcornEntityCopyWith<$Res> {
  _$AcornEntityCopyWithImpl(this._self, this._then);

  final AcornEntity _self;
  final $Res Function(AcornEntity) _then;

/// Create a copy of AcornEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? date = null,Object? count = null,Object? reason = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AcornEntity].
extension AcornEntityPatterns on AcornEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AcornEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AcornEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AcornEntity value)  $default,){
final _that = this;
switch (_that) {
case _AcornEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AcornEntity value)?  $default,){
final _that = this;
switch (_that) {
case _AcornEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  DateTime date,  int count,  String reason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AcornEntity() when $default != null:
return $default(_that.id,_that.date,_that.count,_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  DateTime date,  int count,  String reason)  $default,) {final _that = this;
switch (_that) {
case _AcornEntity():
return $default(_that.id,_that.date,_that.count,_that.reason);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  DateTime date,  int count,  String reason)?  $default,) {final _that = this;
switch (_that) {
case _AcornEntity() when $default != null:
return $default(_that.id,_that.date,_that.count,_that.reason);case _:
  return null;

}
}

}

/// @nodoc


class _AcornEntity implements AcornEntity {
  const _AcornEntity({required this.id, required this.date, required this.count, required this.reason});
  

@override final  int id;
@override final  DateTime date;
@override final  int count;
@override final  String reason;

/// Create a copy of AcornEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AcornEntityCopyWith<_AcornEntity> get copyWith => __$AcornEntityCopyWithImpl<_AcornEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AcornEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.count, count) || other.count == count)&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode => Object.hash(runtimeType,id,date,count,reason);

@override
String toString() {
  return 'AcornEntity(id: $id, date: $date, count: $count, reason: $reason)';
}


}

/// @nodoc
abstract mixin class _$AcornEntityCopyWith<$Res> implements $AcornEntityCopyWith<$Res> {
  factory _$AcornEntityCopyWith(_AcornEntity value, $Res Function(_AcornEntity) _then) = __$AcornEntityCopyWithImpl;
@override @useResult
$Res call({
 int id, DateTime date, int count, String reason
});




}
/// @nodoc
class __$AcornEntityCopyWithImpl<$Res>
    implements _$AcornEntityCopyWith<$Res> {
  __$AcornEntityCopyWithImpl(this._self, this._then);

  final _AcornEntity _self;
  final $Res Function(_AcornEntity) _then;

/// Create a copy of AcornEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? date = null,Object? count = null,Object? reason = null,}) {
  return _then(_AcornEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
