import 'package:equatable/equatable.dart';

class UpdateProfileImageEntity extends Equatable {
  final bool? success;
  final String? message;
  final String? photo;
  final String? photoUrl;

  const UpdateProfileImageEntity({
    this.success,
    this.message,
    this.photo,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [success, message, photo, photoUrl];
}
