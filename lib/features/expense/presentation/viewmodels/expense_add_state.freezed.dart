// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expense_add_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExpenseAddState {

 String get amountString; ExpenseCategory get selectedCategory; bool get isSaving; bool get addToFavorite; bool get saveError; DateTime get recordDate; DateTime get saveCreatedAt;
/// Create a copy of ExpenseAddState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpenseAddStateCopyWith<ExpenseAddState> get copyWith => _$ExpenseAddStateCopyWithImpl<ExpenseAddState>(this as ExpenseAddState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpenseAddState&&(identical(other.amountString, amountString) || other.amountString == amountString)&&(identical(other.selectedCategory, selectedCategory) || other.selectedCategory == selectedCategory)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.addToFavorite, addToFavorite) || other.addToFavorite == addToFavorite)&&(identical(other.saveError, saveError) || other.saveError == saveError)&&(identical(other.recordDate, recordDate) || other.recordDate == recordDate)&&(identical(other.saveCreatedAt, saveCreatedAt) || other.saveCreatedAt == saveCreatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,amountString,selectedCategory,isSaving,addToFavorite,saveError,recordDate,saveCreatedAt);

@override
String toString() {
  return 'ExpenseAddState(amountString: $amountString, selectedCategory: $selectedCategory, isSaving: $isSaving, addToFavorite: $addToFavorite, saveError: $saveError, recordDate: $recordDate, saveCreatedAt: $saveCreatedAt)';
}


}

/// @nodoc
abstract mixin class $ExpenseAddStateCopyWith<$Res>  {
  factory $ExpenseAddStateCopyWith(ExpenseAddState value, $Res Function(ExpenseAddState) _then) = _$ExpenseAddStateCopyWithImpl;
@useResult
$Res call({
 String amountString, ExpenseCategory selectedCategory, bool isSaving, bool addToFavorite, bool saveError, DateTime recordDate, DateTime saveCreatedAt
});




}
/// @nodoc
class _$ExpenseAddStateCopyWithImpl<$Res>
    implements $ExpenseAddStateCopyWith<$Res> {
  _$ExpenseAddStateCopyWithImpl(this._self, this._then);

  final ExpenseAddState _self;
  final $Res Function(ExpenseAddState) _then;

/// Create a copy of ExpenseAddState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? amountString = null,Object? selectedCategory = null,Object? isSaving = null,Object? addToFavorite = null,Object? saveError = null,Object? recordDate = null,Object? saveCreatedAt = null,}) {
  return _then(_self.copyWith(
amountString: null == amountString ? _self.amountString : amountString // ignore: cast_nullable_to_non_nullable
as String,selectedCategory: null == selectedCategory ? _self.selectedCategory : selectedCategory // ignore: cast_nullable_to_non_nullable
as ExpenseCategory,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,addToFavorite: null == addToFavorite ? _self.addToFavorite : addToFavorite // ignore: cast_nullable_to_non_nullable
as bool,saveError: null == saveError ? _self.saveError : saveError // ignore: cast_nullable_to_non_nullable
as bool,recordDate: null == recordDate ? _self.recordDate : recordDate // ignore: cast_nullable_to_non_nullable
as DateTime,saveCreatedAt: null == saveCreatedAt ? _self.saveCreatedAt : saveCreatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ExpenseAddState].
extension ExpenseAddStatePatterns on ExpenseAddState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExpenseAddState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExpenseAddState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExpenseAddState value)  $default,){
final _that = this;
switch (_that) {
case _ExpenseAddState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExpenseAddState value)?  $default,){
final _that = this;
switch (_that) {
case _ExpenseAddState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String amountString,  ExpenseCategory selectedCategory,  bool isSaving,  bool addToFavorite,  bool saveError,  DateTime recordDate,  DateTime saveCreatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExpenseAddState() when $default != null:
return $default(_that.amountString,_that.selectedCategory,_that.isSaving,_that.addToFavorite,_that.saveError,_that.recordDate,_that.saveCreatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String amountString,  ExpenseCategory selectedCategory,  bool isSaving,  bool addToFavorite,  bool saveError,  DateTime recordDate,  DateTime saveCreatedAt)  $default,) {final _that = this;
switch (_that) {
case _ExpenseAddState():
return $default(_that.amountString,_that.selectedCategory,_that.isSaving,_that.addToFavorite,_that.saveError,_that.recordDate,_that.saveCreatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String amountString,  ExpenseCategory selectedCategory,  bool isSaving,  bool addToFavorite,  bool saveError,  DateTime recordDate,  DateTime saveCreatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ExpenseAddState() when $default != null:
return $default(_that.amountString,_that.selectedCategory,_that.isSaving,_that.addToFavorite,_that.saveError,_that.recordDate,_that.saveCreatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _ExpenseAddState extends ExpenseAddState {
  const _ExpenseAddState({this.amountString = '', this.selectedCategory = ExpenseCategory.cafe, this.isSaving = false, this.addToFavorite = false, this.saveError = false, required this.recordDate, required this.saveCreatedAt}): super._();
  

@override@JsonKey() final  String amountString;
@override@JsonKey() final  ExpenseCategory selectedCategory;
@override@JsonKey() final  bool isSaving;
@override@JsonKey() final  bool addToFavorite;
@override@JsonKey() final  bool saveError;
@override final  DateTime recordDate;
@override final  DateTime saveCreatedAt;

/// Create a copy of ExpenseAddState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpenseAddStateCopyWith<_ExpenseAddState> get copyWith => __$ExpenseAddStateCopyWithImpl<_ExpenseAddState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExpenseAddState&&(identical(other.amountString, amountString) || other.amountString == amountString)&&(identical(other.selectedCategory, selectedCategory) || other.selectedCategory == selectedCategory)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.addToFavorite, addToFavorite) || other.addToFavorite == addToFavorite)&&(identical(other.saveError, saveError) || other.saveError == saveError)&&(identical(other.recordDate, recordDate) || other.recordDate == recordDate)&&(identical(other.saveCreatedAt, saveCreatedAt) || other.saveCreatedAt == saveCreatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,amountString,selectedCategory,isSaving,addToFavorite,saveError,recordDate,saveCreatedAt);

@override
String toString() {
  return 'ExpenseAddState(amountString: $amountString, selectedCategory: $selectedCategory, isSaving: $isSaving, addToFavorite: $addToFavorite, saveError: $saveError, recordDate: $recordDate, saveCreatedAt: $saveCreatedAt)';
}


}

/// @nodoc
abstract mixin class _$ExpenseAddStateCopyWith<$Res> implements $ExpenseAddStateCopyWith<$Res> {
  factory _$ExpenseAddStateCopyWith(_ExpenseAddState value, $Res Function(_ExpenseAddState) _then) = __$ExpenseAddStateCopyWithImpl;
@override @useResult
$Res call({
 String amountString, ExpenseCategory selectedCategory, bool isSaving, bool addToFavorite, bool saveError, DateTime recordDate, DateTime saveCreatedAt
});




}
/// @nodoc
class __$ExpenseAddStateCopyWithImpl<$Res>
    implements _$ExpenseAddStateCopyWith<$Res> {
  __$ExpenseAddStateCopyWithImpl(this._self, this._then);

  final _ExpenseAddState _self;
  final $Res Function(_ExpenseAddState) _then;

/// Create a copy of ExpenseAddState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? amountString = null,Object? selectedCategory = null,Object? isSaving = null,Object? addToFavorite = null,Object? saveError = null,Object? recordDate = null,Object? saveCreatedAt = null,}) {
  return _then(_ExpenseAddState(
amountString: null == amountString ? _self.amountString : amountString // ignore: cast_nullable_to_non_nullable
as String,selectedCategory: null == selectedCategory ? _self.selectedCategory : selectedCategory // ignore: cast_nullable_to_non_nullable
as ExpenseCategory,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,addToFavorite: null == addToFavorite ? _self.addToFavorite : addToFavorite // ignore: cast_nullable_to_non_nullable
as bool,saveError: null == saveError ? _self.saveError : saveError // ignore: cast_nullable_to_non_nullable
as bool,recordDate: null == recordDate ? _self.recordDate : recordDate // ignore: cast_nullable_to_non_nullable
as DateTime,saveCreatedAt: null == saveCreatedAt ? _self.saveCreatedAt : saveCreatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
