class CensusModel {
  int? id;
  String householdId;
  String caste;
  String education;
  String occupation;
  int income;
  String region;
  String? profileImageBase64; // <--- The Photo Field

  CensusModel({
    this.id,
    required this.householdId,
    required this.caste,
    required this.education,
    required this.occupation,
    required this.income,
    required this.region,
    this.profileImageBase64,
  });

  // Convert to Map for Database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'householdId': householdId,
      'caste': caste,
      'education': education,
      'occupation': occupation,
      'income': income,
      'region': region,
      'profileImageBase64': profileImageBase64,
      'status': 'PENDING', // Default status when saving offline
    };
  }
}