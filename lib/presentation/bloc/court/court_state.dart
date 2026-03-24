import 'package:equatable/equatable.dart';
import '../../../domain/entities/court_entity.dart';

abstract class CourtState extends Equatable {
  const CourtState();
  @override
  List<Object?> get props => [];
}

class CourtInitial extends CourtState {
  const CourtInitial();
}

class CourtLoading extends CourtState {
  const CourtLoading();
}

class CourtListLoaded extends CourtState {
  final List<CourtEntity> courts;
  const CourtListLoaded(this.courts);
  @override
  List<Object?> get props => [courts];
}

class CourtDetailLoaded extends CourtState {
  final CourtEntity court;
  const CourtDetailLoaded(this.court);
  @override
  List<Object?> get props => [court];
}

class CourtActionSuccess extends CourtState {
  final String message;
  const CourtActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class CourtError extends CourtState {
  final String message;
  const CourtError(this.message);
  @override
  List<Object?> get props => [message];
}
