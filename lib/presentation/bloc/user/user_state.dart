import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';

abstract class UserState extends Equatable {
  const UserState();
  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {
  const UserInitial();
}

class UserLoading extends UserState {
  const UserLoading();
}

class UserListLoaded extends UserState {
  final List<UserEntity> users;
  const UserListLoaded(this.users);
  @override
  List<Object?> get props => [users];
}

class UserLoaded extends UserState {
  final UserEntity user;
  const UserLoaded(this.user);
  @override
  List<Object?> get props => [user];
}

class UserActionSuccess extends UserState {
  final String message;
  final UserEntity? updatedUser;
  const UserActionSuccess({required this.message, this.updatedUser});
  @override
  List<Object?> get props => [message, updatedUser];
}

class UserError extends UserState {
  final String message;
  const UserError(this.message);
  @override
  List<Object?> get props => [message];
}
