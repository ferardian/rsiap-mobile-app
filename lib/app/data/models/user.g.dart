// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  nama: json['nm_pasien'] as String,
  noRkmMedis: json['no_rkm_medis'] as String,
  jenisKelamin: json['jenis_kelamin'] as String,
  tglLahir: json['tgl_lahir'] as String,
  alamat: json['alamat'] as String,
  noTlp: json['no_tlp'] as String,
  email: json['email'] as String,
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'nm_pasien': instance.nama,
  'no_rkm_medis': instance.noRkmMedis,
  'jenis_kelamin': instance.jenisKelamin,
  'tgl_lahir': instance.tglLahir,
  'alamat': instance.alamat,
  'no_tlp': instance.noTlp,
  'email': instance.email,
};
