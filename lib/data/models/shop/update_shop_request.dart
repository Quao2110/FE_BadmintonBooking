class UpdateShopRequest {
  final String? shopName;
  final String? address;
  final double? latitude;
  final double? longitude;

  UpdateShopRequest({
    this.shopName,
    this.address,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      if (shopName != null) 'shopName': shopName,
      if (address != null) 'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }
}
