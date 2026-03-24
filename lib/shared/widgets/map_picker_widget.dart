import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/theme/colors.dart';

/// Widget Map Picker cho phép admin click chọn vị trí trên bản đồ
class MapPickerWidget extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final Function(double lat, double lng) onLocationPicked;

  const MapPickerWidget({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    required this.onLocationPicked,
  });

  @override
  State<MapPickerWidget> createState() => _MapPickerWidgetState();
}

class _MapPickerWidgetState extends State<MapPickerWidget> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  bool _locationPermissionGranted = false;
  static const LatLng _defaultLocation = LatLng(10.875153, 106.800729);

  bool _isInVietnam(double lat, double lng) {
    return lat >= 8.0 && lat <= 24.5 && lng >= 102.0 && lng <= 110.0;
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      final lat = widget.initialLatitude!;
      final lng = widget.initialLongitude!;

      // Dữ liệu backend đôi khi trả về tọa độ sai (ví dụ rất xa VN).
      // Khi đó fallback về vị trí mặc định để admin dễ chọn lại.
      if (_isInVietnam(lat, lng)) {
        _selectedLocation = LatLng(lat, lng);
      }
    }
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (!mounted) return;
    setState(() {
      _locationPermissionGranted =
          permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
    widget.onLocationPicked(position.latitude, position.longitude);
  }

  @override
  Widget build(BuildContext context) {
    final initialPosition = _selectedLocation ?? _defaultLocation;

    return Container(
      height: 550,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 2),
      ),
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialPosition,
              zoom: 15,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: _onMapTap,
            markers: _selectedLocation != null
                ? {
                    Marker(
                      markerId: const MarkerId('selected_location'),
                      position: _selectedLocation!,
                      draggable: true,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen,
                      ),
                      onDragEnd: (newPosition) {
                        setState(() {
                          _selectedLocation = newPosition;
                        });
                        widget.onLocationPicked(
                          newPosition.latitude,
                          newPosition.longitude,
                        );
                      },
                    ),
                  }
                : {},
            myLocationButtonEnabled: _locationPermissionGranted,
            myLocationEnabled: _locationPermissionGranted,
            zoomControlsEnabled: true,
            mapType: MapType.normal,
          ),
          // Instruction overlay - nhỏ gọn
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.touch_app_rounded,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Click hoặc kéo marker để chọn vị trí',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Coordinates display - compact
          if (_selectedLocation != null)
            Positioned(
              bottom: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Lat: ${_selectedLocation!.latitude.toStringAsFixed(6)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Lng: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
