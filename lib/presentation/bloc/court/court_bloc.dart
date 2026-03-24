import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/court_repository_impl.dart';
import '../../../domain/repositories/i_court_repository.dart';
import 'court_event.dart';
import 'court_state.dart';

class CourtBloc extends Bloc<CourtEvent, CourtState> {
  final ICourtRepository repository;

  CourtBloc({required this.repository}) : super(const CourtInitial()) {
    on<LoadAllCourts>(_onLoadAllCourts);
    on<LoadCourtById>(_onLoadCourtById);
    on<UploadCourtImage>(_onUploadCourtImage);
    on<UpdateCourt>(_onUpdateCourt);
  }

  factory CourtBloc.create() {
    return CourtBloc(repository: CourtRepository());
  }

  Future<void> _onLoadAllCourts(
    LoadAllCourts event,
    Emitter<CourtState> emit,
  ) async {
    emit(const CourtLoading());
    try {
      final courts = await repository.getAll();
      emit(CourtListLoaded(courts));
    } catch (e) {
      emit(CourtError(e.toString()));
    }
  }

  Future<void> _onLoadCourtById(
    LoadCourtById event,
    Emitter<CourtState> emit,
  ) async {
    emit(const CourtLoading());
    try {
      final court = await repository.getById(event.id);
      emit(CourtDetailLoaded(court));
    } catch (e) {
      emit(CourtError(e.toString()));
    }
  }

  Future<void> _onUploadCourtImage(
    UploadCourtImage event,
    Emitter<CourtState> emit,
  ) async {
    emit(const CourtLoading());
    try {
      await repository.uploadImage(event.courtId, event.imageFile);
      emit(const CourtActionSuccess('Tải ảnh sân thành công!'));
    } catch (e) {
      emit(CourtError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onUpdateCourt(
    UpdateCourt event,
    Emitter<CourtState> emit,
  ) async {
    emit(const CourtLoading());
    try {
      await repository.updateCourt(
        courtId: event.courtId,
        courtName: event.courtName,
        description: event.description,
        status: event.status,
      );
      emit(const CourtActionSuccess('Cập nhật sân thành công!'));
    } catch (e) {
      emit(CourtError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
