class ShipmentEvent {
  final String stage;
  final String? description;
  final String? location;
  final DateTime occurredAt;
  final String? evidenceUrl;

  ShipmentEvent({
    required this.stage,
    this.description,
    this.location,
    required this.occurredAt,
    this.evidenceUrl,
  });

  factory ShipmentEvent.fromJson(Map<String, dynamic> j) => ShipmentEvent(
    stage: (j['stage'] ?? '').toString(),
    description: j['description']?.toString(),
    location: j['location']?.toString(),
    occurredAt:
        DateTime.tryParse((j['occurredAt'] ?? '').toString()) ?? DateTime.now(),
    evidenceUrl: j['evidenceUrl']?.toString(),
  );
}

class ShipmentModel {
  final String id;
  final String orderId;
  final String? carrier;
  final String? trackingNumber;
  final String? originCountry;
  final String? destinationCity;
  final List<ShipmentEvent> events;

  ShipmentModel({
    required this.id,
    required this.orderId,
    this.carrier,
    this.trackingNumber,
    this.originCountry,
    this.destinationCity,
    this.events = const [],
  });

  factory ShipmentModel.fromJson(Map<String, dynamic> j) => ShipmentModel(
    id: (j['_id'] ?? j['id'] ?? '').toString(),
    orderId: (j['order'] ?? '').toString(),
    carrier: j['carrier']?.toString(),
    trackingNumber: j['trackingNumber']?.toString(),
    originCountry: j['originCountry']?.toString(),
    destinationCity: j['destinationCity']?.toString(),
    events: (j['events'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(ShipmentEvent.fromJson)
        .toList(),
  );
}
