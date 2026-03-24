import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/user_repository_impl.dart';
import '../../../domain/usecases/user/get_all_users.dart';
import '../../../domain/usecases/user/get_user_by_id.dart';
import '../../../domain/usecases/user/update_user.dart';
import '../../../domain/usecases/user/change_password.dart';
import '../../../domain/usecases/user/delete_user.dart';
import '../../../domain/usecases/user/upload_avatar.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final GetAllUsersUseCase getAllUsers;
  final GetUserByIdUseCase getUserById;
  final UpdateUserUseCase updateUser;
  final ChangePasswordUseCase changePassword;
  final DeleteUserUseCase deleteUser;
  final UploadAvatarUseCase uploadAvatar;

  UserBloc({
    required this.getAllUsers,
    required this.getUserById,
    required this.updateUser,
    required this.changePassword,
    required this.deleteUser,
    required this.uploadAvatar,
  }) : super(const UserInitial()) {
    on<GetAllUsersEvent>(_onGetAll);
    on<GetUserByIdEvent>(_onGetById);
    on<UpdateUserEvent>(_onUpdate);
    on<ChangePasswordEvent>(_onChangePassword);
    on<DeleteUserEvent>(_onDelete);
    on<UploadUserAvatarEvent>(_onUploadAvatar);
  }

  /// Factory: creates bloc with a single shared UserRepository instance
  factory UserBloc.create() {
    final repo = UserRepository();
    return UserBloc(
      getAllUsers: GetAllUsersUseCase(repo),
      getUserById: GetUserByIdUseCase(repo),
      updateUser: UpdateUserUseCase(repo),
      changePassword: ChangePasswordUseCase(repo),
      deleteUser: DeleteUserUseCase(repo),
      uploadAvatar: UploadAvatarUseCase(repo),
    );
  }

  Future<void> _onGetAll(
    GetAllUsersEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    try {
      emit(UserListLoaded(await getAllUsers()));
    } catch (e) {
      emit(UserError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onGetById(
    GetUserByIdEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    try {
      emit(UserLoaded(await getUserById(event.id)));
    } catch (e) {
      emit(UserError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onUpdate(UpdateUserEvent event, Emitter<UserState> emit) async {
    emit(const UserLoading());
    try {
      final user = await updateUser(event.id, event.request);
      emit(
        UserActionSuccess(
          message: 'Cập nhật thông tin thành công!',
          updatedUser: user,
        ),
      );
    } catch (e) {
      emit(UserError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onChangePassword(
    ChangePasswordEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    try {
      await changePassword(event.id, event.request);
      emit(const UserActionSuccess(message: 'Đổi mật khẩu thành công!'));
    } catch (e) {
      emit(UserError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onDelete(DeleteUserEvent event, Emitter<UserState> emit) async {
    emit(const UserLoading());
    try {
      await deleteUser(event.id);
      emit(const UserActionSuccess(message: 'Xoá tài khoản thành công!'));
    } catch (e) {
      emit(UserError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onUploadAvatar(
    UploadUserAvatarEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    try {
      await uploadAvatar(event.id, event.imageFile);
      emit(const UserActionSuccess(message: 'Tải ảnh đại diện thành công!'));
    } catch (e) {
      emit(UserError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
