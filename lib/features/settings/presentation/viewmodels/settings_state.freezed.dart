// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SettingsState {

 bool get lunchEnabled; TimeOfDay get lunchTime; bool get dinnerEnabled; TimeOfDay get dinnerTime; bool get isDarkMode; int get dailyBudget; bool get carryoverEnabled; bool get isLoading;
/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsStateCopyWith<SettingsState> get copyWith => _$SettingsStateCopyWithImpl<SettingsState>(this as SettingsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsState&&(identical(other.lunchEnabled, lunchEnabled) || other.lunchEnabled == lunchEnabled)&&(identical(other.lunchTime, lunchTime) || other.lunchTime == lunchTime)&&(identical(other.dinnerEnabled, dinnerEnabled) || other.dinnerEnabled == dinnerEnabled)&&(identical(other.dinnerTime, dinnerTime) || other.dinnerTime == dinnerTime)&&(identical(other.isDarkMode, isDarkMode) || other.isDarkMode == isDarkMode)&&(identical(other.dailyBudget, dailyBudget) || other.dailyBudget == dailyBudget)&&(identical(other.carryoverEnabled, carryoverEnabled) || other.carryoverEnabled == carryoverEnabled)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,lunchEnabled,lunchTime,dinnerEnabled,dinnerTime,isDarkMode,dailyBudget,carryoverEnabled,isLoading);

@override
String toString() {
  return 'SettingsState(lunchEnabled: $lunchEnabled, lunchTime: $lunchTime, dinnerEnabled: $dinnerEnabled, dinnerTime: $dinnerTime, isDarkMode: $isDarkMode, dailyBudget: $dailyBudget, carryoverEnabled: $carryoverEnabled, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class $SettingsStateCopyWith<$Res>  {
  factory $SettingsStateCopyWith(SettingsState value, $Res Function(SettingsState) _then) = _$SettingsStateCopyWithImpl;
@useResult
$Res call({
 bool lunchEnabled, TimeOfDay lunchTime, bool dinnerEnabled, TimeOfDay dinnerTime, bool isDarkMode, int dailyBudget, bool carryoverEnabled, bool isLoading
});




}
/// @nodoc
class _$SettingsStateCopyWithImpl<$Res>
    implements $SettingsStateCopyWith<$Res> {
  _$SettingsStateCopyWithImpl(this._self, this._then);

  final SettingsState _self;
  final $Res Function(SettingsState) _then;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lunchEnabled = null,Object? lunchTime = null,Object? dinnerEnabled = null,Object? dinnerTime = null,Object? isDarkMode = null,Object? dailyBudget = null,Object? carryoverEnabled = null,Object? isLoading = null,}) {
  return _then(_self.copyWith(
lunchEnabled: null == lunchEnabled ? _self.lunchEnabled : lunchEnabled // ignore: cast_nullable_to_non_nullable
as bool,lunchTime: null == lunchTime ? _self.lunchTime : lunchTime // ignore: cast_nullable_to_non_nullable
as TimeOfDay,dinnerEnabled: null == dinnerEnabled ? _self.dinnerEnabled : dinnerEnabled // ignore: cast_nullable_to_non_nullable
as bool,dinnerTime: null == dinnerTime ? _self.dinnerTime : dinnerTime // ignore: cast_nullable_to_non_nullable
as TimeOfDay,isDarkMode: null == isDarkMode ? _self.isDarkMode : isDarkMode // ignore: cast_nullable_to_non_nullable
as bool,dailyBudget: null == dailyBudget ? _self.dailyBudget : dailyBudget // ignore: cast_nullable_to_non_nullable
as int,carryoverEnabled: null == carryoverEnabled ? _self.carryoverEnabled : carryoverEnabled // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SettingsState].
extension SettingsStatePatterns on SettingsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SettingsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SettingsState value)  $default,){
final _that = this;
switch (_that) {
case _SettingsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SettingsState value)?  $default,){
final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool lunchEnabled,  TimeOfDay lunchTime,  bool dinnerEnabled,  TimeOfDay dinnerTime,  bool isDarkMode,  int dailyBudget,  bool carryoverEnabled,  bool isLoading)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
return $default(_that.lunchEnabled,_that.lunchTime,_that.dinnerEnabled,_that.dinnerTime,_that.isDarkMode,_that.dailyBudget,_that.carryoverEnabled,_that.isLoading);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool lunchEnabled,  TimeOfDay lunchTime,  bool dinnerEnabled,  TimeOfDay dinnerTime,  bool isDarkMode,  int dailyBudget,  bool carryoverEnabled,  bool isLoading)  $default,) {final _that = this;
switch (_that) {
case _SettingsState():
return $default(_that.lunchEnabled,_that.lunchTime,_that.dinnerEnabled,_that.dinnerTime,_that.isDarkMode,_that.dailyBudget,_that.carryoverEnabled,_that.isLoading);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool lunchEnabled,  TimeOfDay lunchTime,  bool dinnerEnabled,  TimeOfDay dinnerTime,  bool isDarkMode,  int dailyBudget,  bool carryoverEnabled,  bool isLoading)?  $default,) {final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
return $default(_that.lunchEnabled,_that.lunchTime,_that.dinnerEnabled,_that.dinnerTime,_that.isDarkMode,_that.dailyBudget,_that.carryoverEnabled,_that.isLoading);case _:
  return null;

}
}

}

/// @nodoc


class _SettingsState implements SettingsState {
  const _SettingsState({this.lunchEnabled = false, this.lunchTime = const TimeOfDay(hour: 12, minute: 0), this.dinnerEnabled = false, this.dinnerTime = const TimeOfDay(hour: 20, minute: 0), this.isDarkMode = false, this.dailyBudget = 10000, this.carryoverEnabled = false, this.isLoading = false});
  

@override@JsonKey() final  bool lunchEnabled;
@override@JsonKey() final  TimeOfDay lunchTime;
@override@JsonKey() final  bool dinnerEnabled;
@override@JsonKey() final  TimeOfDay dinnerTime;
@override@JsonKey() final  bool isDarkMode;
@override@JsonKey() final  int dailyBudget;
@override@JsonKey() final  bool carryoverEnabled;
@override@JsonKey() final  bool isLoading;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettingsStateCopyWith<_SettingsState> get copyWith => __$SettingsStateCopyWithImpl<_SettingsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SettingsState&&(identical(other.lunchEnabled, lunchEnabled) || other.lunchEnabled == lunchEnabled)&&(identical(other.lunchTime, lunchTime) || other.lunchTime == lunchTime)&&(identical(other.dinnerEnabled, dinnerEnabled) || other.dinnerEnabled == dinnerEnabled)&&(identical(other.dinnerTime, dinnerTime) || other.dinnerTime == dinnerTime)&&(identical(other.isDarkMode, isDarkMode) || other.isDarkMode == isDarkMode)&&(identical(other.dailyBudget, dailyBudget) || other.dailyBudget == dailyBudget)&&(identical(other.carryoverEnabled, carryoverEnabled) || other.carryoverEnabled == carryoverEnabled)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,lunchEnabled,lunchTime,dinnerEnabled,dinnerTime,isDarkMode,dailyBudget,carryoverEnabled,isLoading);

@override
String toString() {
  return 'SettingsState(lunchEnabled: $lunchEnabled, lunchTime: $lunchTime, dinnerEnabled: $dinnerEnabled, dinnerTime: $dinnerTime, isDarkMode: $isDarkMode, dailyBudget: $dailyBudget, carryoverEnabled: $carryoverEnabled, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class _$SettingsStateCopyWith<$Res> implements $SettingsStateCopyWith<$Res> {
  factory _$SettingsStateCopyWith(_SettingsState value, $Res Function(_SettingsState) _then) = __$SettingsStateCopyWithImpl;
@override @useResult
$Res call({
 bool lunchEnabled, TimeOfDay lunchTime, bool dinnerEnabled, TimeOfDay dinnerTime, bool isDarkMode, int dailyBudget, bool carryoverEnabled, bool isLoading
});




}
/// @nodoc
class __$SettingsStateCopyWithImpl<$Res>
    implements _$SettingsStateCopyWith<$Res> {
  __$SettingsStateCopyWithImpl(this._self, this._then);

  final _SettingsState _self;
  final $Res Function(_SettingsState) _then;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lunchEnabled = null,Object? lunchTime = null,Object? dinnerEnabled = null,Object? dinnerTime = null,Object? isDarkMode = null,Object? dailyBudget = null,Object? carryoverEnabled = null,Object? isLoading = null,}) {
  return _then(_SettingsState(
lunchEnabled: null == lunchEnabled ? _self.lunchEnabled : lunchEnabled // ignore: cast_nullable_to_non_nullable
as bool,lunchTime: null == lunchTime ? _self.lunchTime : lunchTime // ignore: cast_nullable_to_non_nullable
as TimeOfDay,dinnerEnabled: null == dinnerEnabled ? _self.dinnerEnabled : dinnerEnabled // ignore: cast_nullable_to_non_nullable
as bool,dinnerTime: null == dinnerTime ? _self.dinnerTime : dinnerTime // ignore: cast_nullable_to_non_nullable
as TimeOfDay,isDarkMode: null == isDarkMode ? _self.isDarkMode : isDarkMode // ignore: cast_nullable_to_non_nullable
as bool,dailyBudget: null == dailyBudget ? _self.dailyBudget : dailyBudget // ignore: cast_nullable_to_non_nullable
as int,carryoverEnabled: null == carryoverEnabled ? _self.carryoverEnabled : carryoverEnabled // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
