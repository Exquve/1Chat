class UserModel {
  final String uid;
  final String name;
  final String phoneNumber;
  final String profilePic;
  final bool isOnline;
  final List<String> groupIds;

  UserModel({
    required this.uid,
    required this.name,
    required this.phoneNumber,
    required this.profilePic,
    required this.isOnline,
    required this.groupIds,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'phoneNumber': phoneNumber,
      'profilePic': profilePic,
      'isOnline': isOnline,
      'groupIds': groupIds,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      profilePic: map['profilePic'] ?? '',
      isOnline: map['isOnline'] ?? false,
      groupIds: List<String>.from(map['groupIds'] ?? []),
    );
  }
}
