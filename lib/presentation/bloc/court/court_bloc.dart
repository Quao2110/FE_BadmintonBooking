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
  }

  factory CourtBloc.create() {
    return CourtBloc(repository: CourtRepository());
  }

  Future<void> _onLoadAllCourts(LoadAllCourts event, Emitter<CourtState> emit) async {
    emit(const CourtLoading());
    try {
      final courts = await repository.getAll();
      emit(CourtListLoaded(courts));
    } catch (e) {
      emit(CourtError(e.toString()));
    }
  }

  Future<void> _onLoadCourtById(LoadCourtById event, Emitter<CourtState> emit) async {
    emit(const CourtLoading());
    try {
      final court = await repository.getById(event.id);
      if (court != null) {
        emit(CourtDetailLoaded(court));
      } else {
        emit(const CourtError('Court not found'));
      }
    } catch (e) {
      emit(CourtError(e.toString()));
    }
  }
}
