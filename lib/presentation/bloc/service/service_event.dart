import 'package:equatable/equatable.dart';

abstract class ServiceEvent extends Equatable {
  const ServiceEvent();
  @override
  List<Object?> get props => [];
}

class GetServicesEvent extends ServiceEvent {
  const GetServicesEvent();
}

class GetServiceByIdEvent extends ServiceEvent {
  final String id;
  const GetServiceByIdEvent(this.id);
  @override
  List<Object?> get props => [id];
}
