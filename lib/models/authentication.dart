class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String idToken;
  final String refreshToken;
  final bool isSuperAdmin;
  final bool isAdmin;
  final List<Role> roles;
  final List<Organization> organizations;
  final DateTime expiryDate;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.idToken,
    required this.refreshToken,
    required this.isSuperAdmin,
    required this.isAdmin,
    required this.roles,
    required this.organizations,
    required this.expiryDate,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    var rolesList = json['roles'] as List;
    List<Role> roles = rolesList.map((i) => Role.fromJson(i)).toList();

    var organizationsList = json['organizations'] as List;
    List<Organization> organizations = organizationsList.map((i) => Organization.fromJson(i)).toList();

    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      idToken: json['idToken'],
      refreshToken: json['refreshToken'],
      isSuperAdmin: json['isSuperAdmin'],
      isAdmin: json['isAdmin'],
      roles: roles,
      organizations: organizations,
      expiryDate: DateTime.parse(json['expiryDate']),
    );
  }
}


class Role {
  final String roleName;
  final List<Claim> claims;

  Role({required this.roleName, required this.claims});

  factory Role.fromJson(Map<String, dynamic> json) {
    var claimsList = json['claims'] as List;
    List<Claim> claims = claimsList.map((i) => Claim.fromJson(i)).toList();

    return Role(
      roleName: json['roleName'],
      claims: claims,
    );
  }
}


class Claim {
  final int id;
  final int clientId;
  final String claim;

  Claim({required this.id, required this.clientId, required this.claim});

  factory Claim.fromJson(Map<String, dynamic> json) {
    return Claim(
      id: json['id'],
      clientId: json['clientId'],
      claim: json['claim'],
    );
  }
}

class Organization {
  final int id;
  final String name;
  final String logo;
  final String organizationCode;
  final String database;
  final String blob;
  final String email;

  Organization({
    required this.id,
    required this.name,
    required this.logo,
    required this.organizationCode,
    required this.database,
    required this.blob,
    required this.email,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'],
      name: json['name'],
      logo: json['logo'],
      organizationCode: json['organizationCode'],
      database: json['database'],
      blob: json['blob'],
      email: json['email'],
    );
  }
}


class ClientAuthResponse {
  final String clientId;
  final String accessToken;
  final String refreshToken;

  ClientAuthResponse({
    required this.clientId,
    required this.accessToken,
    required this.refreshToken,
  });

  factory ClientAuthResponse.fromJson(Map<String, dynamic> json) {
    return ClientAuthResponse(
      clientId: json['clientId'],
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }
}