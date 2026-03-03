import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/service_repository_impl.dart';
import '../../../domain/usecases/service/get_services.dart';
import '../../../domain/usecases/service/get_service_by_id.dart';
import 'service_event.dart';
import 'service_state.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final GetServicesUseCase getServices;
  final GetServiceByIdUseCase getServiceById;

  ServiceBloc({
    required this.getServices,
    required this.getServiceById,
  }) : super(const ServiceInitial()) {
    on<GetServicesEvent>(_onGetAll);
    on<GetServiceByIdEvent>(_onGetById);
  }

  factory ServiceBloc.create() {
    final repo = ServiceRepository();
    return ServiceBloc(
      getServices: GetServicesUseCase(repo),
      getServiceById: GetServiceByIdUseCase(repo),
    );
  }

  Future<void> _onGetAll(GetServicesEvent event, Emitter<ServiceState> emit) async {
    emit(const ServiceLoading());
    try {
      final items = await getServices();
      emit(ServiceListLoaded(items));
    } catch (e) {
      emit(ServiceError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onGetById(GetServiceByIdEvent event, Emitter<ServiceState> emit) async {
    emit(const ServiceLoading());
    try {
      final item = await getServiceById(event.id);
      emit(ServiceLoaded(item));
    } catch (e) {
      emit(ServiceError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
