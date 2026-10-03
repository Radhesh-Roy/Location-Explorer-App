import 'package:flutter/material.dart';
import '../models/favorite_location.dart';

class LocationInfoDialog extends StatelessWidget {
  final FavoriteLocation location;

  const LocationInfoDialog({
    super.key,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      title: Row(
        children: const [
          Icon(Icons.star, color: Colors.amber),
          SizedBox(width: 8),
          Text(
            'Favorite Location',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('ID', location.id.toString()),
          const Divider(),
          _buildInfoRow('Name', location.name),
          const Divider(),
          _buildInfoRow('Latitude', location.latitude.toStringAsFixed(4)),
          const Divider(),
          _buildInfoRow('Longitude', location.longitude.toStringAsFixed(4)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
