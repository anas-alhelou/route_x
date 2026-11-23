class FleetCompany {
  const FleetCompany({
    required this.id,
    required this.name,
    this.address,
    this.driversCount,
  });

  final String id;
  final String name;
  final String? address;
  final String? driversCount;
}
