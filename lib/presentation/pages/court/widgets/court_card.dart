import 'package:flutter/material.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../domain/entities/court_entity.dart';

class CourtCard extends StatelessWidget {
  final CourtEntity court;
  final VoidCallback onTap;

  const CourtCard({
    super.key,
    required this.court,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryImage = court.primaryImageUrl;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (primaryImage != null && primaryImage.isNotEmpty)
                    Image.network(
                      ApiConstants.getFullImageUrl(primaryImage),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 50),
                      ),
                    )
                  else
                    Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.sports_tennis, size: 50, color: Colors.grey),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (court.status == 'Available' || court.status == 'Active') 
                          ? Colors.green 
                          : (court.status == 'Inactive' || court.status == 'Maintenance' ? Colors.red : Colors.orange),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        court.status,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    court.courtName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (court.description != null)
                    Text(
                      court.description!,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
