import 'package:equatable/equatable.dart';

abstract class CourtEvent extends Equatable {
  const CourtEvent();
  @override
  List<Object?> get props => [];
}

class LoadAllCourts extends CourtEvent {
  const LoadAllCourts();
}

class LoadCourtById extends CourtEvent {
  final String id;
  const LoadCourtById(this.id);
  @override
  List<Object?> get props => [id];
}
