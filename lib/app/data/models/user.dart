// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class User with _$User {
  const factory User({
    @JsonKey(name: 'nm_pasien') required String nama,
    @JsonKey(name: 'no_rkm_medis') required String noRkmMedis,
    @JsonKey(name: 'jenis_kelamin') required String jenisKelamin,
    @JsonKey(name: 'tgl_lahir') required String tglLahir,
    required String alamat,
    @JsonKey(name: 'no_tlp') required String noTlp,
    required String email,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
