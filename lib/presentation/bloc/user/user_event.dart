import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../data/models/user/update_user_request.dart';
import '../../../data/models/user/change_password_request.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();
  @override
  List<Object?> get props => [];
}

class GetAllUsersEvent extends UserEvent {
  const GetAllUsersEvent();
}

class GetUserByIdEvent extends UserEvent {
  final String id;
  const GetUserByIdEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class UpdateUserEvent extends UserEvent {
  final String id;
  final UpdateUserRequest request;
  const UpdateUserEvent({required this.id, required this.request});
  @override
  List<Object?> get props => [id, request];
}

class ChangePasswordEvent extends UserEvent {
  final String id;
  final ChangePasswordRequest request;
  const ChangePasswordEvent({required this.id, required this.request});
  @override
  List<Object?> get props => [id];
}

class DeleteUserEvent extends UserEvent {
  final String id;
  const DeleteUserEvent(this.id);
  @override
  List<Object?> get props => [id];
}
