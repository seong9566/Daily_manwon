// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'achievement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AchievementEntity {

 int get id; String get type; DateTime get achievedAt;
/// Create a copy of AchievementEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AchievementEntityCopyWith<AchievementEntity> get copyWith => _$AchievementEntityCopyWithImpl<AchievementEntity>(this as AchievementEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AchievementEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.achievedAt, achievedAt) || other.achievedAt == achievedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,type,achievedAt);

@override
String toString() {
  return 'AchievementEntity(id: $id, type: $type, achievedAt: $achievedAt)';
}


}

/// @nodoc
abstract mixin class $AchievementEntityCopyWith<$Res>  {
  factory $AchievementEntityCopyWith(AchievementEntity value, $Res Function(AchievementEntity) _then) = _$AchievementEntityCopyWithImpl;
@useResult
$Res call({
 int id, String type, DateTime achievedAt
});




}
/// @nodoc
class _$AchievementEntityCopyWithImpl<$Res>
    implements $AchievementEntityCopyWith<$Res> {
  _$AchievementEntityCopyWithImpl(this._self, this._then);

  final AchievementEntity _self;
  final $Res Function(AchievementEntity) _then;

/// Create a copy of AchievementEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? achievedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,achievedAt: null == achievedAt ? _self.achievedAt : achievedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AchievementEntity].
extension AchievementEntityPatterns on AchievementEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AchievementEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AchievementEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AchievementEntity value)  $default,){
final _that = this;
switch (_that) {
case _AchievementEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AchievementEntity value)?  $default,){
final _that = this;
switch (_that) {
case _AchievementEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String type,  DateTime achievedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AchievementEntity() when $default != null:
return $default(_that.id,_that.type,_that.achievedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String type,  DateTime achievedAt)  $default,) {final _that = this;
switch (_that) {
case _AchievementEntity():
return $default(_that.id,_that.type,_that.achievedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String type,  DateTime achievedAt)?  $default,) {final _that = this;
switch (_that) {
case _AchievementEntity() when $default != null:
return $default(_that.id,_that.type,_that.achievedAt);case _:
  return null;

}
}

}

/// @nodoc


class _AchievementEntity implements AchievementEntity {
  const _AchievementEntity({required this.id, required this.type, required this.achievedAt});
  

@override final  int id;
@override final  String type;
@override final  DateTime achievedAt;

/// Create a copy of AchievementEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AchievementEntityCopyWith<_AchievementEntity> get copyWith => __$AchievementEntityCopyWithImpl<_AchievementEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AchievementEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.achievedAt, achievedAt) || other.achievedAt == achievedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,type,achievedAt);

@override
String toString() {
  return 'AchievementEntity(id: $id, type: $type, achievedAt: $achievedAt)';
}


}

/// @nodoc
abstract mixin class _$AchievementEntityCopyWith<$Res> implements $AchievementEntityCopyWith<$Res> {
  factory _$AchievementEntityCopyWith(_AchievementEntity value, $Res Function(_AchievementEntity) _then) = __$AchievementEntityCopyWithImpl;
@override @useResult
$Res call({
 int id, String type, DateTime achievedAt
});




}
/// @nodoc
class __$AchievementEntityCopyWithImpl<$Res>
    implements _$AchievementEntityCopyWith<$Res> {
  __$AchievementEntityCopyWithImpl(this._self, this._then);

  final _AchievementEntity _self;
  final $Res Function(_AchievementEntity) _then;

/// Create a copy of AchievementEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? achievedAt = null,}) {
  return _then(_AchievementEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,achievedAt: null == achievedAt ? _self.achievedAt : achievedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
