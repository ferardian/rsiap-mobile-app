// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$User {

@JsonKey(name: 'nm_pasien') String get nama;@JsonKey(name: 'no_rkm_medis') String get noRkmMedis;@JsonKey(name: 'jenis_kelamin') String get jenisKelamin;@JsonKey(name: 'tgl_lahir') String get tglLahir; String get alamat;@JsonKey(name: 'no_tlp') String get noTlp; String get email;
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserCopyWith<User> get copyWith => _$UserCopyWithImpl<User>(this as User, _$identity);

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is User&&(identical(other.nama, nama) || other.nama == nama)&&(identical(other.noRkmMedis, noRkmMedis) || other.noRkmMedis == noRkmMedis)&&(identical(other.jenisKelamin, jenisKelamin) || other.jenisKelamin == jenisKelamin)&&(identical(other.tglLahir, tglLahir) || other.tglLahir == tglLahir)&&(identical(other.alamat, alamat) || other.alamat == alamat)&&(identical(other.noTlp, noTlp) || other.noTlp == noTlp)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,nama,noRkmMedis,jenisKelamin,tglLahir,alamat,noTlp,email);

@override
String toString() {
  return 'User(nama: $nama, noRkmMedis: $noRkmMedis, jenisKelamin: $jenisKelamin, tglLahir: $tglLahir, alamat: $alamat, noTlp: $noTlp, email: $email)';
}


}

/// @nodoc
abstract mixin class $UserCopyWith<$Res>  {
  factory $UserCopyWith(User value, $Res Function(User) _then) = _$UserCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'nm_pasien') String nama,@JsonKey(name: 'no_rkm_medis') String noRkmMedis,@JsonKey(name: 'jenis_kelamin') String jenisKelamin,@JsonKey(name: 'tgl_lahir') String tglLahir, String alamat,@JsonKey(name: 'no_tlp') String noTlp, String email
});




}
/// @nodoc
class _$UserCopyWithImpl<$Res>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._self, this._then);

  final User _self;
  final $Res Function(User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nama = null,Object? noRkmMedis = null,Object? jenisKelamin = null,Object? tglLahir = null,Object? alamat = null,Object? noTlp = null,Object? email = null,}) {
  return _then(_self.copyWith(
nama: null == nama ? _self.nama : nama // ignore: cast_nullable_to_non_nullable
as String,noRkmMedis: null == noRkmMedis ? _self.noRkmMedis : noRkmMedis // ignore: cast_nullable_to_non_nullable
as String,jenisKelamin: null == jenisKelamin ? _self.jenisKelamin : jenisKelamin // ignore: cast_nullable_to_non_nullable
as String,tglLahir: null == tglLahir ? _self.tglLahir : tglLahir // ignore: cast_nullable_to_non_nullable
as String,alamat: null == alamat ? _self.alamat : alamat // ignore: cast_nullable_to_non_nullable
as String,noTlp: null == noTlp ? _self.noTlp : noTlp // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [User].
extension UserPatterns on User {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _User value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _User() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _User value)  $default,){
final _that = this;
switch (_that) {
case _User():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _User value)?  $default,){
final _that = this;
switch (_that) {
case _User() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'nm_pasien')  String nama, @JsonKey(name: 'no_rkm_medis')  String noRkmMedis, @JsonKey(name: 'jenis_kelamin')  String jenisKelamin, @JsonKey(name: 'tgl_lahir')  String tglLahir,  String alamat, @JsonKey(name: 'no_tlp')  String noTlp,  String email)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.nama,_that.noRkmMedis,_that.jenisKelamin,_that.tglLahir,_that.alamat,_that.noTlp,_that.email);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'nm_pasien')  String nama, @JsonKey(name: 'no_rkm_medis')  String noRkmMedis, @JsonKey(name: 'jenis_kelamin')  String jenisKelamin, @JsonKey(name: 'tgl_lahir')  String tglLahir,  String alamat, @JsonKey(name: 'no_tlp')  String noTlp,  String email)  $default,) {final _that = this;
switch (_that) {
case _User():
return $default(_that.nama,_that.noRkmMedis,_that.jenisKelamin,_that.tglLahir,_that.alamat,_that.noTlp,_that.email);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'nm_pasien')  String nama, @JsonKey(name: 'no_rkm_medis')  String noRkmMedis, @JsonKey(name: 'jenis_kelamin')  String jenisKelamin, @JsonKey(name: 'tgl_lahir')  String tglLahir,  String alamat, @JsonKey(name: 'no_tlp')  String noTlp,  String email)?  $default,) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.nama,_that.noRkmMedis,_that.jenisKelamin,_that.tglLahir,_that.alamat,_that.noTlp,_that.email);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _User implements User {
  const _User({@JsonKey(name: 'nm_pasien') required this.nama, @JsonKey(name: 'no_rkm_medis') required this.noRkmMedis, @JsonKey(name: 'jenis_kelamin') required this.jenisKelamin, @JsonKey(name: 'tgl_lahir') required this.tglLahir, required this.alamat, @JsonKey(name: 'no_tlp') required this.noTlp, required this.email});
  factory _User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

@override@JsonKey(name: 'nm_pasien') final  String nama;
@override@JsonKey(name: 'no_rkm_medis') final  String noRkmMedis;
@override@JsonKey(name: 'jenis_kelamin') final  String jenisKelamin;
@override@JsonKey(name: 'tgl_lahir') final  String tglLahir;
@override final  String alamat;
@override@JsonKey(name: 'no_tlp') final  String noTlp;
@override final  String email;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserCopyWith<_User> get copyWith => __$UserCopyWithImpl<_User>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _User&&(identical(other.nama, nama) || other.nama == nama)&&(identical(other.noRkmMedis, noRkmMedis) || other.noRkmMedis == noRkmMedis)&&(identical(other.jenisKelamin, jenisKelamin) || other.jenisKelamin == jenisKelamin)&&(identical(other.tglLahir, tglLahir) || other.tglLahir == tglLahir)&&(identical(other.alamat, alamat) || other.alamat == alamat)&&(identical(other.noTlp, noTlp) || other.noTlp == noTlp)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,nama,noRkmMedis,jenisKelamin,tglLahir,alamat,noTlp,email);

@override
String toString() {
  return 'User(nama: $nama, noRkmMedis: $noRkmMedis, jenisKelamin: $jenisKelamin, tglLahir: $tglLahir, alamat: $alamat, noTlp: $noTlp, email: $email)';
}


}

/// @nodoc
abstract mixin class _$UserCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$UserCopyWith(_User value, $Res Function(_User) _then) = __$UserCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'nm_pasien') String nama,@JsonKey(name: 'no_rkm_medis') String noRkmMedis,@JsonKey(name: 'jenis_kelamin') String jenisKelamin,@JsonKey(name: 'tgl_lahir') String tglLahir, String alamat,@JsonKey(name: 'no_tlp') String noTlp, String email
});




}
/// @nodoc
class __$UserCopyWithImpl<$Res>
    implements _$UserCopyWith<$Res> {
  __$UserCopyWithImpl(this._self, this._then);

  final _User _self;
  final $Res Function(_User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nama = null,Object? noRkmMedis = null,Object? jenisKelamin = null,Object? tglLahir = null,Object? alamat = null,Object? noTlp = null,Object? email = null,}) {
  return _then(_User(
nama: null == nama ? _self.nama : nama // ignore: cast_nullable_to_non_nullable
as String,noRkmMedis: null == noRkmMedis ? _self.noRkmMedis : noRkmMedis // ignore: cast_nullable_to_non_nullable
as String,jenisKelamin: null == jenisKelamin ? _self.jenisKelamin : jenisKelamin // ignore: cast_nullable_to_non_nullable
as String,tglLahir: null == tglLahir ? _self.tglLahir : tglLahir // ignore: cast_nullable_to_non_nullable
as String,alamat: null == alamat ? _self.alamat : alamat // ignore: cast_nullable_to_non_nullable
as String,noTlp: null == noTlp ? _self.noTlp : noTlp // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
