// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'category_stat.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CategoryStat {

 int get categoryIndex; int get totalAmount; double get percentage;
/// Create a copy of CategoryStat
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryStatCopyWith<CategoryStat> get copyWith => _$CategoryStatCopyWithImpl<CategoryStat>(this as CategoryStat, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryStat&&(identical(other.categoryIndex, categoryIndex) || other.categoryIndex == categoryIndex)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.percentage, percentage) || other.percentage == percentage));
}


@override
int get hashCode => Object.hash(runtimeType,categoryIndex,totalAmount,percentage);

@override
String toString() {
  return 'CategoryStat(categoryIndex: $categoryIndex, totalAmount: $totalAmount, percentage: $percentage)';
}


}

/// @nodoc
abstract mixin class $CategoryStatCopyWith<$Res>  {
  factory $CategoryStatCopyWith(CategoryStat value, $Res Function(CategoryStat) _then) = _$CategoryStatCopyWithImpl;
@useResult
$Res call({
 int categoryIndex, int totalAmount, double percentage
});




}
/// @nodoc
class _$CategoryStatCopyWithImpl<$Res>
    implements $CategoryStatCopyWith<$Res> {
  _$CategoryStatCopyWithImpl(this._self, this._then);

  final CategoryStat _self;
  final $Res Function(CategoryStat) _then;

/// Create a copy of CategoryStat
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categoryIndex = null,Object? totalAmount = null,Object? percentage = null,}) {
  return _then(_self.copyWith(
categoryIndex: null == categoryIndex ? _self.categoryIndex : categoryIndex // ignore: cast_nullable_to_non_nullable
as int,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as int,percentage: null == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [CategoryStat].
extension CategoryStatPatterns on CategoryStat {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoryStat value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoryStat() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoryStat value)  $default,){
final _that = this;
switch (_that) {
case _CategoryStat():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoryStat value)?  $default,){
final _that = this;
switch (_that) {
case _CategoryStat() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int categoryIndex,  int totalAmount,  double percentage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoryStat() when $default != null:
return $default(_that.categoryIndex,_that.totalAmount,_that.percentage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int categoryIndex,  int totalAmount,  double percentage)  $default,) {final _that = this;
switch (_that) {
case _CategoryStat():
return $default(_that.categoryIndex,_that.totalAmount,_that.percentage);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int categoryIndex,  int totalAmount,  double percentage)?  $default,) {final _that = this;
switch (_that) {
case _CategoryStat() when $default != null:
return $default(_that.categoryIndex,_that.totalAmount,_that.percentage);case _:
  return null;

}
}

}

/// @nodoc


class _CategoryStat implements CategoryStat {
  const _CategoryStat({required this.categoryIndex, required this.totalAmount, required this.percentage});
  

@override final  int categoryIndex;
@override final  int totalAmount;
@override final  double percentage;

/// Create a copy of CategoryStat
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryStatCopyWith<_CategoryStat> get copyWith => __$CategoryStatCopyWithImpl<_CategoryStat>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryStat&&(identical(other.categoryIndex, categoryIndex) || other.categoryIndex == categoryIndex)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.percentage, percentage) || other.percentage == percentage));
}


@override
int get hashCode => Object.hash(runtimeType,categoryIndex,totalAmount,percentage);

@override
String toString() {
  return 'CategoryStat(categoryIndex: $categoryIndex, totalAmount: $totalAmount, percentage: $percentage)';
}


}

/// @nodoc
abstract mixin class _$CategoryStatCopyWith<$Res> implements $CategoryStatCopyWith<$Res> {
  factory _$CategoryStatCopyWith(_CategoryStat value, $Res Function(_CategoryStat) _then) = __$CategoryStatCopyWithImpl;
@override @useResult
$Res call({
 int categoryIndex, int totalAmount, double percentage
});




}
/// @nodoc
class __$CategoryStatCopyWithImpl<$Res>
    implements _$CategoryStatCopyWith<$Res> {
  __$CategoryStatCopyWithImpl(this._self, this._then);

  final _CategoryStat _self;
  final $Res Function(_CategoryStat) _then;

/// Create a copy of CategoryStat
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categoryIndex = null,Object? totalAmount = null,Object? percentage = null,}) {
  return _then(_CategoryStat(
categoryIndex: null == categoryIndex ? _self.categoryIndex : categoryIndex // ignore: cast_nullable_to_non_nullable
as int,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as int,percentage: null == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
