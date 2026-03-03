import 'package:equatable/equatable.dart';
import '../../../domain/entities/service_entity.dart';

abstract class ServiceState extends Equatable {
  const ServiceState();
  @override
  List<Object?> get props => [];
}

class ServiceInitial extends ServiceState {
  const ServiceInitial();
}

class ServiceLoading extends ServiceState {
  const ServiceLoading();
}

class ServiceListLoaded extends ServiceState {
  final List<ServiceEntity> services;
  const ServiceListLoaded(this.services);
  @override
  List<Object?> get props => [services];
}

class ServiceLoaded extends ServiceState {
  final ServiceEntity service;
  const ServiceLoaded(this.service);
  @override
  List<Object?> get props => [service];
}

class ServiceError extends ServiceState {
  final String message;
  const ServiceError(this.message);
  @override
  List<Object?> get props => [message];
}
