import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/shop_entity.dart';
import '../../../core/theme/colors.dart';
import '../../../data/models/shop/update_shop_request.dart';
import '../../../data/datasources/shop_api_service.dart';
import '../../../data/repositories/shop_repository_impl.dart';
import '../../bloc/shop/shop_bloc.dart';
import '../../bloc/shop/shop_event.dart';
import '../../bloc/shop/shop_state.dart';
import '../../../shared/widgets/map_picker_widget.dart';
import 'admin_layout.dart';
import '../../../routes/app_router.dart';

/// Admin Shop Settings Page
class AdminShopPage extends StatelessWidget {
  final User user;

  const AdminShopPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      user: user,
      currentRoute: AppRoutes.adminShop,
      child: BlocProvider(
        create: (_) => ShopBloc.create(),
        child: const _AdminShopContent(),
      ),
    );
  }
}

class _AdminShopContent extends StatefulWidget {
  const _AdminShopContent();

  @override
  State<_AdminShopContent> createState() => _AdminShopContentState();
}

class _AdminShopContentState extends State<_AdminShopContent> {
  final _formKey = GlobalKey<FormState>();
  final _shopNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _shopRepository =
      ShopRepositoryImpl(remoteDataSource: ShopRemoteDataSource());

  List<ShopEntity> _shops = [];
  String? _selectedShopId;
  bool _isLoadingShops = true;
  bool _isReloadingShops = false;
  String? _loadError;

  double? _selectedLat;
  double? _selectedLng;
  String? _shopId;

  @override
  void initState() {
    super.initState();
    _loadShops();
  }

  Future<void> _loadShops({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoadingShops = true;
        _loadError = null;
      });
    } else {
      setState(() {
        _isReloadingShops = true;
      });
    }

    try {
      final shops = await _shopRepository.getShops();
      if (!mounted) return;

      setState(() {
        _shops = shops;
        _loadError = null;

        if (_shops.isEmpty) {
          _selectedShopId = null;
          _shopId = null;
          _shopNameController.clear();
          _addressController.clear();
          _selectedLat = null;
          _selectedLng = null;
        } else {
          final selectedExists =
              _selectedShopId != null &&
              _shops.any((shop) => shop.id == _selectedShopId);
          _selectedShopId = selectedExists ? _selectedShopId : _shops.first.id;
          _applySelectedShop();
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Không thể tải danh sách shop: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingShops = false;
        _isReloadingShops = false;
      });
    }
  }

  void _applySelectedShop() {
    if (_selectedShopId == null) return;
    final selected = _shops.where((s) => s.id == _selectedShopId).firstOrNull;
    if (selected == null) return;

    _shopId = selected.id;
    _shopNameController.text = selected.shopName;
    _addressController.text = selected.address;
    _selectedLat = selected.latitude;
    _selectedLng = selected.longitude;
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _onLocationPicked(double lat, double lng) {
    setState(() {
      _selectedLat = lat;
      _selectedLng = lng;
    });
  }

  void _submitForm(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    if (_shopId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy thông tin shop'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final request = UpdateShopRequest(
      shopName: _shopNameController.text.trim(),
      address: _addressController.text.trim(),
      latitude: _selectedLat,
      longitude: _selectedLng,
    );

    context.read<ShopBloc>().add(
      UpdateShopEvent(shopId: _shopId!, request: request),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShopBloc, ShopState>(
      listener: (context, state) {
        if (state is ShopUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          _loadShops(silent: true);
        } else if (state is ShopError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final isUpdating = state is ShopUpdating;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Text(
                      'Cài Đặt Shop',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: _isReloadingShops
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh_rounded),
                      onPressed: (_isReloadingShops || _isLoadingShops)
                          ? null
                          : () => _loadShops(silent: true),
                      tooltip: 'Làm mới danh sách shop',
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                if (_isLoadingShops)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(48),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_loadError != null)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _loadError!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadShops,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  )
                else if (_shops.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(48),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Center(
                      child: Text('Chưa có shop nào trong hệ thống'),
                    ),
                  )
                else ...[
                  // Shop Info Form
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Thông tin Shop',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tổng số shop: ${_shops.length}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 20),

                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: _selectedShopId,
                          decoration: InputDecoration(
                            labelText: 'Chọn shop',
                            prefixIcon: const Icon(Icons.store_mall_directory),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: _shops
                              .map(
                                (shop) => DropdownMenuItem<String>(
                                  value: shop.id,
                                  child: Text(
                                    shop.shopName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: isUpdating
                              ? null
                              : (value) {
                                  if (value == null) return;
                                  setState(() {
                                    _selectedShopId = value;
                                    _applySelectedShop();
                                  });
                                },
                        ),
                        const SizedBox(height: 16),

                        // Shop Name
                        TextFormField(
                          controller: _shopNameController,
                          enabled: !isUpdating,
                          decoration: InputDecoration(
                            labelText: 'Tên Shop *',
                            hintText: 'Nhập tên shop',
                            prefixIcon: const Icon(Icons.store_rounded),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập tên shop';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Address
                        TextFormField(
                          controller: _addressController,
                          enabled: !isUpdating,
                          decoration: InputDecoration(
                            labelText: 'Địa chỉ *',
                            hintText: 'Nhập địa chỉ shop',
                            prefixIcon: const Icon(Icons.location_on_rounded),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          maxLines: 2,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập địa chỉ';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Map Picker
                        const Text(
                          'Vị trí trên bản đồ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        MapPickerWidget(
                          key: ValueKey(_selectedShopId),
                          initialLatitude: _selectedLat,
                          initialLongitude: _selectedLng,
                          onLocationPicked: _onLocationPicked,
                        ),
                        const SizedBox(height: 24),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isUpdating
                                ? null
                                : () => _submitForm(context),
                            icon: const Icon(Icons.save_rounded),
                            label: Text(
                              isUpdating ? 'Đang lưu...' : 'Lưu thay đổi',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
