import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../routes/app_router.dart';
import '../../bloc/court/court_bloc.dart';
import '../../bloc/court/court_event.dart';
import '../../bloc/court/court_state.dart';
import '../../bloc/shop/shop_bloc.dart';
import '../../bloc/shop/shop_event.dart';
import '../../bloc/shop/shop_state.dart';

class CourtDetailPage extends StatefulWidget {
  final String courtId;

  const CourtDetailPage({super.key, required this.courtId});

  @override
  State<CourtDetailPage> createState() => _CourtDetailPageState();
}

class _CourtDetailPageState extends State<CourtDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<CourtBloc>().add(LoadCourtById(widget.courtId));
    _calculateDistance();
  }

  Future<void> _calculateDistance() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      
      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        context.read<ShopBloc>().add(CalculateDistance(
          userLat: position.latitude,
          userLng: position.longitude,
        ));
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết sân'),
      ),
      body: BlocBuilder<CourtBloc, CourtState>(
        builder: (context, courtState) {
          if (courtState is CourtLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (courtState is CourtDetailLoaded) {
            final court = courtState.court;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Gallery
                  if (court.courtImages.isNotEmpty)
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 250.0,
                        viewportFraction: 1.0,
                        enlargeCenterPage: false,
                        autoPlay: true,
                      ),
                      items: court.courtImages.map((img) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Image.network(
                              ApiConstants.getFullImageUrl(img.imageUrl),
                              fit: BoxFit.cover,
                              width: MediaQuery.of(context).size.width,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.image_not_supported, size: 50),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    )
                  else
                    Container(
                      height: 250,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(Icons.sports_tennis, size: 80, color: Colors.grey),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                court.courtName,
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: (court.status == 'Available' || court.status == 'Active') 
                                  ? Colors.green 
                                  : (court.status == 'Inactive' || court.status == 'Maintenance' ? Colors.red : Colors.orange),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                court.status,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Distance Info
                        BlocBuilder<ShopBloc, ShopState>(
                          builder: (context, shopState) {
                            if (shopState is ShopLoaded && shopState.distance != null) {
                              return Row(
                                children: [
                                  const Icon(Icons.location_on, color: Colors.red, size: 20),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Cách bạn ${shopState.distance} km',
                                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '(${shopState.shop.address})',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        
                        const Divider(height: 32),
                        const Text(
                          'Mô tả',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          court.description ?? 'Không có mô tả cho sân này.',
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                        
                        const SizedBox(height: 24),
                        const Text(
                          'Vị trí sân',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        
                        // Map showing Shop Location
                        BlocBuilder<ShopBloc, ShopState>(
                          builder: (context, shopState) {
                            if (shopState is ShopLoaded) {
                              final shop = shopState.shop;
                              if (shop.latitude != null && shop.longitude != null) {
                                final shopPos = LatLng(shop.latitude!, shop.longitude!);
                                return Container(
                                  height: 180,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: GoogleMap(
                                    initialCameraPosition: CameraPosition(
                                      target: shopPos,
                                      zoom: 15,
                                    ),
                                    markers: {
                                      Marker(
                                        markerId: const MarkerId('court_shop'),
                                        position: shopPos,
                                        infoWindow: InfoWindow(title: shop.shopName, snippet: shop.address),
                                      ),
                                    },
                                    myLocationEnabled: true,
                                    zoomControlsEnabled: false,
                                    mapToolbarEnabled: false,
                                  ),
                                );
                              }
                            }
                            return const SizedBox(
                                height: 100, 
                                child: Center(child: Text('Đang tải vị trí...'))
                            );
                          },
                        ),
                        
                        const SizedBox(height: 100), // Space for FAB or bottom buttons
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else if (courtState is CourtError) {
            return Center(child: Text('Lỗi: ${courtState.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.booking, arguments: widget.courtId);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Đặt sân ngay', style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      ),
    );
  }
}
