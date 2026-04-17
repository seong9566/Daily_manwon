// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'favorite_expense.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FavoriteExpenseEntity {

 int get id; int get amount; int get category; String get memo; int get usageCount; DateTime get createdAt;
/// Create a copy of FavoriteExpenseEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FavoriteExpenseEntityCopyWith<FavoriteExpenseEntity> get copyWith => _$FavoriteExpenseEntityCopyWithImpl<FavoriteExpenseEntity>(this as FavoriteExpenseEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FavoriteExpenseEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.category, category) || other.category == category)&&(identical(other.memo, memo) || other.memo == memo)&&(identical(other.usageCount, usageCount) || other.usageCount == usageCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,amount,category,memo,usageCount,createdAt);

@override
String toString() {
  return 'FavoriteExpenseEntity(id: $id, amount: $amount, category: $category, memo: $memo, usageCount: $usageCount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $FavoriteExpenseEntityCopyWith<$Res>  {
  factory $FavoriteExpenseEntityCopyWith(FavoriteExpenseEntity value, $Res Function(FavoriteExpenseEntity) _then) = _$FavoriteExpenseEntityCopyWithImpl;
@useResult
$Res call({
 int id, int amount, int category, String memo, int usageCount, DateTime createdAt
});




}
/// @nodoc
class _$FavoriteExpenseEntityCopyWithImpl<$Res>
    implements $FavoriteExpenseEntityCopyWith<$Res> {
  _$FavoriteExpenseEntityCopyWithImpl(this._self, this._then);

  final FavoriteExpenseEntity _self;
  final $Res Function(FavoriteExpenseEntity) _then;

/// Create a copy of FavoriteExpenseEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? amount = null,Object? category = null,Object? memo = null,Object? usageCount = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as int,memo: null == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String,usageCount: null == usageCount ? _self.usageCount : usageCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FavoriteExpenseEntity].
extension FavoriteExpenseEntityPatterns on FavoriteExpenseEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FavoriteExpenseEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FavoriteExpenseEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FavoriteExpenseEntity value)  $default,){
final _that = this;
switch (_that) {
case _FavoriteExpenseEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FavoriteExpenseEntity value)?  $default,){
final _that = this;
switch (_that) {
case _FavoriteExpenseEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int amount,  int category,  String memo,  int usageCount,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FavoriteExpenseEntity() when $default != null:
return $default(_that.id,_that.amount,_that.category,_that.memo,_that.usageCount,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int amount,  int category,  String memo,  int usageCount,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _FavoriteExpenseEntity():
return $default(_that.id,_that.amount,_that.category,_that.memo,_that.usageCount,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int amount,  int category,  String memo,  int usageCount,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _FavoriteExpenseEntity() when $default != null:
return $default(_that.id,_that.amount,_that.category,_that.memo,_that.usageCount,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _FavoriteExpenseEntity implements FavoriteExpenseEntity {
  const _FavoriteExpenseEntity({this.id = 0, required this.amount, required this.category, this.memo = '', this.usageCount = 0, required this.createdAt});
  

@override@JsonKey() final  int id;
@override final  int amount;
@override final  int category;
@override@JsonKey() final  String memo;
@override@JsonKey() final  int usageCount;
@override final  DateTime createdAt;

/// Create a copy of FavoriteExpenseEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FavoriteExpenseEntityCopyWith<_FavoriteExpenseEntity> get copyWith => __$FavoriteExpenseEntityCopyWithImpl<_FavoriteExpenseEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FavoriteExpenseEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.category, category) || other.category == category)&&(identical(other.memo, memo) || other.memo == memo)&&(identical(other.usageCount, usageCount) || other.usageCount == usageCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,amount,category,memo,usageCount,createdAt);

@override
String toString() {
  return 'FavoriteExpenseEntity(id: $id, amount: $amount, category: $category, memo: $memo, usageCount: $usageCount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$FavoriteExpenseEntityCopyWith<$Res> implements $FavoriteExpenseEntityCopyWith<$Res> {
  factory _$FavoriteExpenseEntityCopyWith(_FavoriteExpenseEntity value, $Res Function(_FavoriteExpenseEntity) _then) = __$FavoriteExpenseEntityCopyWithImpl;
@override @useResult
$Res call({
 int id, int amount, int category, String memo, int usageCount, DateTime createdAt
});




}
/// @nodoc
class __$FavoriteExpenseEntityCopyWithImpl<$Res>
    implements _$FavoriteExpenseEntityCopyWith<$Res> {
  __$FavoriteExpenseEntityCopyWithImpl(this._self, this._then);

  final _FavoriteExpenseEntity _self;
  final $Res Function(_FavoriteExpenseEntity) _then;

/// Create a copy of FavoriteExpenseEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? amount = null,Object? category = null,Object? memo = null,Object? usageCount = null,Object? createdAt = null,}) {
  return _then(_FavoriteExpenseEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as int,memo: null == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String,usageCount: null == usageCount ? _self.usageCount : usageCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
