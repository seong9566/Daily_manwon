// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expense_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExpenseSummary {

 int get totalSpent; int get totalDays; int get successDays; int? get topCategoryIndex;
/// Create a copy of ExpenseSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpenseSummaryCopyWith<ExpenseSummary> get copyWith => _$ExpenseSummaryCopyWithImpl<ExpenseSummary>(this as ExpenseSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpenseSummary&&(identical(other.totalSpent, totalSpent) || other.totalSpent == totalSpent)&&(identical(other.totalDays, totalDays) || other.totalDays == totalDays)&&(identical(other.successDays, successDays) || other.successDays == successDays)&&(identical(other.topCategoryIndex, topCategoryIndex) || other.topCategoryIndex == topCategoryIndex));
}


@override
int get hashCode => Object.hash(runtimeType,totalSpent,totalDays,successDays,topCategoryIndex);

@override
String toString() {
  return 'ExpenseSummary(totalSpent: $totalSpent, totalDays: $totalDays, successDays: $successDays, topCategoryIndex: $topCategoryIndex)';
}


}

/// @nodoc
abstract mixin class $ExpenseSummaryCopyWith<$Res>  {
  factory $ExpenseSummaryCopyWith(ExpenseSummary value, $Res Function(ExpenseSummary) _then) = _$ExpenseSummaryCopyWithImpl;
@useResult
$Res call({
 int totalSpent, int totalDays, int successDays, int? topCategoryIndex
});




}
/// @nodoc
class _$ExpenseSummaryCopyWithImpl<$Res>
    implements $ExpenseSummaryCopyWith<$Res> {
  _$ExpenseSummaryCopyWithImpl(this._self, this._then);

  final ExpenseSummary _self;
  final $Res Function(ExpenseSummary) _then;

/// Create a copy of ExpenseSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalSpent = null,Object? totalDays = null,Object? successDays = null,Object? topCategoryIndex = freezed,}) {
  return _then(_self.copyWith(
totalSpent: null == totalSpent ? _self.totalSpent : totalSpent // ignore: cast_nullable_to_non_nullable
as int,totalDays: null == totalDays ? _self.totalDays : totalDays // ignore: cast_nullable_to_non_nullable
as int,successDays: null == successDays ? _self.successDays : successDays // ignore: cast_nullable_to_non_nullable
as int,topCategoryIndex: freezed == topCategoryIndex ? _self.topCategoryIndex : topCategoryIndex // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExpenseSummary].
extension ExpenseSummaryPatterns on ExpenseSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExpenseSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExpenseSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExpenseSummary value)  $default,){
final _that = this;
switch (_that) {
case _ExpenseSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExpenseSummary value)?  $default,){
final _that = this;
switch (_that) {
case _ExpenseSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalSpent,  int totalDays,  int successDays,  int? topCategoryIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExpenseSummary() when $default != null:
return $default(_that.totalSpent,_that.totalDays,_that.successDays,_that.topCategoryIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalSpent,  int totalDays,  int successDays,  int? topCategoryIndex)  $default,) {final _that = this;
switch (_that) {
case _ExpenseSummary():
return $default(_that.totalSpent,_that.totalDays,_that.successDays,_that.topCategoryIndex);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalSpent,  int totalDays,  int successDays,  int? topCategoryIndex)?  $default,) {final _that = this;
switch (_that) {
case _ExpenseSummary() when $default != null:
return $default(_that.totalSpent,_that.totalDays,_that.successDays,_that.topCategoryIndex);case _:
  return null;

}
}

}

/// @nodoc


class _ExpenseSummary implements ExpenseSummary {
  const _ExpenseSummary({required this.totalSpent, required this.totalDays, required this.successDays, required this.topCategoryIndex});
  

@override final  int totalSpent;
@override final  int totalDays;
@override final  int successDays;
@override final  int? topCategoryIndex;

/// Create a copy of ExpenseSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpenseSummaryCopyWith<_ExpenseSummary> get copyWith => __$ExpenseSummaryCopyWithImpl<_ExpenseSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExpenseSummary&&(identical(other.totalSpent, totalSpent) || other.totalSpent == totalSpent)&&(identical(other.totalDays, totalDays) || other.totalDays == totalDays)&&(identical(other.successDays, successDays) || other.successDays == successDays)&&(identical(other.topCategoryIndex, topCategoryIndex) || other.topCategoryIndex == topCategoryIndex));
}


@override
int get hashCode => Object.hash(runtimeType,totalSpent,totalDays,successDays,topCategoryIndex);

@override
String toString() {
  return 'ExpenseSummary(totalSpent: $totalSpent, totalDays: $totalDays, successDays: $successDays, topCategoryIndex: $topCategoryIndex)';
}


}

/// @nodoc
abstract mixin class _$ExpenseSummaryCopyWith<$Res> implements $ExpenseSummaryCopyWith<$Res> {
  factory _$ExpenseSummaryCopyWith(_ExpenseSummary value, $Res Function(_ExpenseSummary) _then) = __$ExpenseSummaryCopyWithImpl;
@override @useResult
$Res call({
 int totalSpent, int totalDays, int successDays, int? topCategoryIndex
});




}
/// @nodoc
class __$ExpenseSummaryCopyWithImpl<$Res>
    implements _$ExpenseSummaryCopyWith<$Res> {
  __$ExpenseSummaryCopyWithImpl(this._self, this._then);

  final _ExpenseSummary _self;
  final $Res Function(_ExpenseSummary) _then;

/// Create a copy of ExpenseSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalSpent = null,Object? totalDays = null,Object? successDays = null,Object? topCategoryIndex = freezed,}) {
  return _then(_ExpenseSummary(
totalSpent: null == totalSpent ? _self.totalSpent : totalSpent // ignore: cast_nullable_to_non_nullable
as int,totalDays: null == totalDays ? _self.totalDays : totalDays // ignore: cast_nullable_to_non_nullable
as int,successDays: null == successDays ? _self.successDays : successDays // ignore: cast_nullable_to_non_nullable
as int,topCategoryIndex: freezed == topCategoryIndex ? _self.topCategoryIndex : topCategoryIndex // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
