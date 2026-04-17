// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_settings_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NotificationSettingsEntity {

/// 점심 알림 활성화 여부 (기본값: true)
 bool get lunchEnabled;/// 점심 알림 시 (기본값: 12)
 int get lunchTimeHour;/// 점심 알림 분 (기본값: 0)
 int get lunchTimeMinute;/// 저녁 알림 활성화 여부 (기본값: true)
 bool get dinnerEnabled;/// 저녁 알림 시 (기본값: 20)
 int get dinnerTimeHour;/// 저녁 알림 분 (기본값: 0)
 int get dinnerTimeMinute;
/// Create a copy of NotificationSettingsEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationSettingsEntityCopyWith<NotificationSettingsEntity> get copyWith => _$NotificationSettingsEntityCopyWithImpl<NotificationSettingsEntity>(this as NotificationSettingsEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationSettingsEntity&&(identical(other.lunchEnabled, lunchEnabled) || other.lunchEnabled == lunchEnabled)&&(identical(other.lunchTimeHour, lunchTimeHour) || other.lunchTimeHour == lunchTimeHour)&&(identical(other.lunchTimeMinute, lunchTimeMinute) || other.lunchTimeMinute == lunchTimeMinute)&&(identical(other.dinnerEnabled, dinnerEnabled) || other.dinnerEnabled == dinnerEnabled)&&(identical(other.dinnerTimeHour, dinnerTimeHour) || other.dinnerTimeHour == dinnerTimeHour)&&(identical(other.dinnerTimeMinute, dinnerTimeMinute) || other.dinnerTimeMinute == dinnerTimeMinute));
}


@override
int get hashCode => Object.hash(runtimeType,lunchEnabled,lunchTimeHour,lunchTimeMinute,dinnerEnabled,dinnerTimeHour,dinnerTimeMinute);

@override
String toString() {
  return 'NotificationSettingsEntity(lunchEnabled: $lunchEnabled, lunchTimeHour: $lunchTimeHour, lunchTimeMinute: $lunchTimeMinute, dinnerEnabled: $dinnerEnabled, dinnerTimeHour: $dinnerTimeHour, dinnerTimeMinute: $dinnerTimeMinute)';
}


}

/// @nodoc
abstract mixin class $NotificationSettingsEntityCopyWith<$Res>  {
  factory $NotificationSettingsEntityCopyWith(NotificationSettingsEntity value, $Res Function(NotificationSettingsEntity) _then) = _$NotificationSettingsEntityCopyWithImpl;
@useResult
$Res call({
 bool lunchEnabled, int lunchTimeHour, int lunchTimeMinute, bool dinnerEnabled, int dinnerTimeHour, int dinnerTimeMinute
});




}
/// @nodoc
class _$NotificationSettingsEntityCopyWithImpl<$Res>
    implements $NotificationSettingsEntityCopyWith<$Res> {
  _$NotificationSettingsEntityCopyWithImpl(this._self, this._then);

  final NotificationSettingsEntity _self;
  final $Res Function(NotificationSettingsEntity) _then;

/// Create a copy of NotificationSettingsEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lunchEnabled = null,Object? lunchTimeHour = null,Object? lunchTimeMinute = null,Object? dinnerEnabled = null,Object? dinnerTimeHour = null,Object? dinnerTimeMinute = null,}) {
  return _then(_self.copyWith(
lunchEnabled: null == lunchEnabled ? _self.lunchEnabled : lunchEnabled // ignore: cast_nullable_to_non_nullable
as bool,lunchTimeHour: null == lunchTimeHour ? _self.lunchTimeHour : lunchTimeHour // ignore: cast_nullable_to_non_nullable
as int,lunchTimeMinute: null == lunchTimeMinute ? _self.lunchTimeMinute : lunchTimeMinute // ignore: cast_nullable_to_non_nullable
as int,dinnerEnabled: null == dinnerEnabled ? _self.dinnerEnabled : dinnerEnabled // ignore: cast_nullable_to_non_nullable
as bool,dinnerTimeHour: null == dinnerTimeHour ? _self.dinnerTimeHour : dinnerTimeHour // ignore: cast_nullable_to_non_nullable
as int,dinnerTimeMinute: null == dinnerTimeMinute ? _self.dinnerTimeMinute : dinnerTimeMinute // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationSettingsEntity].
extension NotificationSettingsEntityPatterns on NotificationSettingsEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationSettingsEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationSettingsEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationSettingsEntity value)  $default,){
final _that = this;
switch (_that) {
case _NotificationSettingsEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationSettingsEntity value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationSettingsEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool lunchEnabled,  int lunchTimeHour,  int lunchTimeMinute,  bool dinnerEnabled,  int dinnerTimeHour,  int dinnerTimeMinute)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationSettingsEntity() when $default != null:
return $default(_that.lunchEnabled,_that.lunchTimeHour,_that.lunchTimeMinute,_that.dinnerEnabled,_that.dinnerTimeHour,_that.dinnerTimeMinute);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool lunchEnabled,  int lunchTimeHour,  int lunchTimeMinute,  bool dinnerEnabled,  int dinnerTimeHour,  int dinnerTimeMinute)  $default,) {final _that = this;
switch (_that) {
case _NotificationSettingsEntity():
return $default(_that.lunchEnabled,_that.lunchTimeHour,_that.lunchTimeMinute,_that.dinnerEnabled,_that.dinnerTimeHour,_that.dinnerTimeMinute);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool lunchEnabled,  int lunchTimeHour,  int lunchTimeMinute,  bool dinnerEnabled,  int dinnerTimeHour,  int dinnerTimeMinute)?  $default,) {final _that = this;
switch (_that) {
case _NotificationSettingsEntity() when $default != null:
return $default(_that.lunchEnabled,_that.lunchTimeHour,_that.lunchTimeMinute,_that.dinnerEnabled,_that.dinnerTimeHour,_that.dinnerTimeMinute);case _:
  return null;

}
}

}

/// @nodoc


class _NotificationSettingsEntity extends NotificationSettingsEntity {
  const _NotificationSettingsEntity({this.lunchEnabled = true, this.lunchTimeHour = 12, this.lunchTimeMinute = 0, this.dinnerEnabled = true, this.dinnerTimeHour = 20, this.dinnerTimeMinute = 0}): super._();
  

/// 점심 알림 활성화 여부 (기본값: true)
@override@JsonKey() final  bool lunchEnabled;
/// 점심 알림 시 (기본값: 12)
@override@JsonKey() final  int lunchTimeHour;
/// 점심 알림 분 (기본값: 0)
@override@JsonKey() final  int lunchTimeMinute;
/// 저녁 알림 활성화 여부 (기본값: true)
@override@JsonKey() final  bool dinnerEnabled;
/// 저녁 알림 시 (기본값: 20)
@override@JsonKey() final  int dinnerTimeHour;
/// 저녁 알림 분 (기본값: 0)
@override@JsonKey() final  int dinnerTimeMinute;

/// Create a copy of NotificationSettingsEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationSettingsEntityCopyWith<_NotificationSettingsEntity> get copyWith => __$NotificationSettingsEntityCopyWithImpl<_NotificationSettingsEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationSettingsEntity&&(identical(other.lunchEnabled, lunchEnabled) || other.lunchEnabled == lunchEnabled)&&(identical(other.lunchTimeHour, lunchTimeHour) || other.lunchTimeHour == lunchTimeHour)&&(identical(other.lunchTimeMinute, lunchTimeMinute) || other.lunchTimeMinute == lunchTimeMinute)&&(identical(other.dinnerEnabled, dinnerEnabled) || other.dinnerEnabled == dinnerEnabled)&&(identical(other.dinnerTimeHour, dinnerTimeHour) || other.dinnerTimeHour == dinnerTimeHour)&&(identical(other.dinnerTimeMinute, dinnerTimeMinute) || other.dinnerTimeMinute == dinnerTimeMinute));
}


@override
int get hashCode => Object.hash(runtimeType,lunchEnabled,lunchTimeHour,lunchTimeMinute,dinnerEnabled,dinnerTimeHour,dinnerTimeMinute);

@override
String toString() {
  return 'NotificationSettingsEntity(lunchEnabled: $lunchEnabled, lunchTimeHour: $lunchTimeHour, lunchTimeMinute: $lunchTimeMinute, dinnerEnabled: $dinnerEnabled, dinnerTimeHour: $dinnerTimeHour, dinnerTimeMinute: $dinnerTimeMinute)';
}


}

/// @nodoc
abstract mixin class _$NotificationSettingsEntityCopyWith<$Res> implements $NotificationSettingsEntityCopyWith<$Res> {
  factory _$NotificationSettingsEntityCopyWith(_NotificationSettingsEntity value, $Res Function(_NotificationSettingsEntity) _then) = __$NotificationSettingsEntityCopyWithImpl;
@override @useResult
$Res call({
 bool lunchEnabled, int lunchTimeHour, int lunchTimeMinute, bool dinnerEnabled, int dinnerTimeHour, int dinnerTimeMinute
});




}
/// @nodoc
class __$NotificationSettingsEntityCopyWithImpl<$Res>
    implements _$NotificationSettingsEntityCopyWith<$Res> {
  __$NotificationSettingsEntityCopyWithImpl(this._self, this._then);

  final _NotificationSettingsEntity _self;
  final $Res Function(_NotificationSettingsEntity) _then;

/// Create a copy of NotificationSettingsEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lunchEnabled = null,Object? lunchTimeHour = null,Object? lunchTimeMinute = null,Object? dinnerEnabled = null,Object? dinnerTimeHour = null,Object? dinnerTimeMinute = null,}) {
  return _then(_NotificationSettingsEntity(
lunchEnabled: null == lunchEnabled ? _self.lunchEnabled : lunchEnabled // ignore: cast_nullable_to_non_nullable
as bool,lunchTimeHour: null == lunchTimeHour ? _self.lunchTimeHour : lunchTimeHour // ignore: cast_nullable_to_non_nullable
as int,lunchTimeMinute: null == lunchTimeMinute ? _self.lunchTimeMinute : lunchTimeMinute // ignore: cast_nullable_to_non_nullable
as int,dinnerEnabled: null == dinnerEnabled ? _self.dinnerEnabled : dinnerEnabled // ignore: cast_nullable_to_non_nullable
as bool,dinnerTimeHour: null == dinnerTimeHour ? _self.dinnerTimeHour : dinnerTimeHour // ignore: cast_nullable_to_non_nullable
as int,dinnerTimeMinute: null == dinnerTimeMinute ? _self.dinnerTimeMinute : dinnerTimeMinute // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
