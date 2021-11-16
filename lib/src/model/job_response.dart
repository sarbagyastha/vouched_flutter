import 'dart:convert';

abstract class _Model {
  Map<String, dynamic> toMap();

  String toJson() => jsonEncode(toMap());
}

class JobResponse extends _Model {
  JobResponse({
    required this.id,
    required this.token,
    required this.result,
    required this.errors,
    required this.signals,
  });

  /// The job ID.
  final String id;

  /// The token.
  final String token;

  /// Successfully completed job result.
  final JobResult? result;

  /// List of errors for unsuccessful completed jobs.
  final List<JobError> errors;

  /// List of signals affecting id scores.
  final List<Signal> signals;

  factory JobResponse.fromJson(String str) {
    return JobResponse.fromMap(jsonDecode(str));
  }

  factory JobResponse.fromMap(Map<String, dynamic> json) {
    final result = json['result'];
    final errors = json['errors'] ?? [];
    final signals = json['signals'] ?? [];

    return JobResponse(
      id: json['id'] ?? '',
      token: json['token'] ?? '',
      result: result == null ? null : JobResult.fromMap(result),
      errors: List<JobError>.from(errors.map((x) => JobError.fromMap(x))),
      signals: List<Signal>.from(signals.map((x) => Signal.fromMap(x))),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'token': token,
      'result': result?.toMap(),
      'errors': List.from(errors.map((x) => x.toMap())),
      'signals': List.from(signals.map((x) => x.toMap())),
    };
  }

  /// Returns true if the job has any unsuccessful completed jobs.
  bool get hasErrors => errors.isNotEmpty;
}

class JobError extends _Model {
  JobError({
    required this.type,
    required this.message,
    required this.warning,
    required this.suggestion,
  });

  /// Error type code.
  final String type;

  /// Details on the occurring error.
  final String message;

  /// Is this a warning?
  final bool warning;

  /// A suggestion for matching name.
  final String suggestion;

  factory JobError.fromJson(String str) => JobError.fromMap(jsonDecode(str));

  factory JobError.fromMap(Map<String, dynamic> json) {
    return JobError(
      type: json['type'] ?? '',
      message: json['message'] ?? '',
      warning: json['warning'] ?? false,
      suggestion: json['suggestion'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'message': message,
      'warning': warning,
      'suggestion': suggestion,
    };
  }
}

class JobResult extends _Model {
  JobResult({
    required this.success,
    required this.warnings,
    required this.gender,
    required this.type,
    required this.state,
    required this.country,
    required this.id,
    required this.expireDate,
    required this.issueDate,
    required this.idType,
    required this.endorsements,
    required this.motorcycle,
    required this.birthDate,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.confidences,
  });

  /// Did the id verification completed successfully with no errors?
  /// The verification could have warnings.
  final bool success;

  /// Does the completed verification contain warnings?
  final bool warnings;

  /// The detected gender.
  final ResultGender gender;

  /// The detected id type.
  /// For unrecognized ids, the type will be other.
  final String type;

  /// The issuing state/province/territory of the id as a ISO 3166-2 code.
  final String state;

  /// The issuing country of the id in ISO 3166-1 format.
  final String country;

  /// The verified id number of the id.
  final String id;

  /// The verified expired date in MM/DD/YYYY.
  final String expireDate;

  /// The verified issued date in MM/DD/YYYY.
  final String issueDate;

  /// Any additional id type information available on the card.
  final String idType;

  /// The id endorsements.
  final String endorsements;

  /// The motorcycle property.
  final String motorcycle;

  /// The verified date in MM/DD/YYYY.
  final String birthDate;

  /// The user's verified first name.
  final String firstName;

  /// The user's verified middle name.
  final String middleName;

  /// The user's verified last name.
  final String lastName;

  final ResultConfidences? confidences;

  factory JobResult.fromJson(String str) => JobResult.fromMap(jsonDecode(str));

  factory JobResult.fromMap(Map<String, dynamic> json) {
    final confidences = json['confidences'];

    return JobResult(
      success: json['success'] ?? false,
      warnings: json['warnings'] ?? false,
      gender: ResultGender.fromMap(json['gender'] ?? {}),
      type: json['type'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      id: json['id'] ?? '',
      expireDate: json['expireDate'] ?? '',
      issueDate: json['issueDate'] ?? '',
      idType: json['idType'] ?? '',
      endorsements: json['endorsements'] ?? '',
      motorcycle: json['motorcycle'] ?? '',
      birthDate: json['birthDate'] ?? '',
      firstName: json['firstName'] ?? '',
      middleName: json['middleName'] ?? '',
      lastName: json['lastName'] ?? '',
      confidences: confidences == null
          ? null
          : ResultConfidences.fromMap(confidences ?? {}),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'warnings': warnings,
      'gender': gender.toMap(),
      'type': type,
      'state': state,
      'country': country,
      'id': id,
      'expireDate': expireDate,
      'issueDate': issueDate,
      'idType': idType,
      'endorsements': endorsements,
      'motorcycle': motorcycle,
      'birthDate': birthDate,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'confidences': confidences?.toMap(),
    };
  }
}

class ResultConfidences extends _Model {
  ResultConfidences({
    required this.id,
    required this.idQuality,
    required this.idGlareQuality,
    required this.selfie,
    required this.idMatch,
    required this.idExpired,
    required this.faceMatch,
    required this.birthDateMatch,
    required this.nameMatch,
    required this.selfieSunglasses,
    required this.selfieEyeglasses,
  });

  /// Confidence score for an id photo.
  final double id;

  /// Confidence score for image quality of the id.
  final double idQuality;

  /// Confidence score for image quality of the id.
  final double idGlareQuality;

  /// Confidence score for a selfie photo.
  final double selfie;

  /// Confidence score for matching data on the id.
  final double idMatch;

  /// Confidence score for id expiration date.
  final double idExpired;

  /// Confidence score for matching faces.
  final double faceMatch;

  /// Confidence score for matching birth dates.
  final double birthDateMatch;

  /// Confidence score for matching names.
  final double nameMatch;

  /// Confidence score for selfie with sunglasses.
  final double selfieSunglasses;

  /// Confidence score for selfie with eyeglasses.
  final double selfieEyeglasses;

  factory ResultConfidences.fromJson(String str) {
    return ResultConfidences.fromMap(jsonDecode(str));
  }

  factory ResultConfidences.fromMap(Map<String, dynamic> json) {
    return ResultConfidences(
      id: json['id'] ?? 0,
      idQuality: json['idQuality'] ?? 0,
      idGlareQuality: json['idGlareQuality'] ?? 0,
      selfie: json['selfie'] ?? 0,
      idMatch: json['idMatch'] ?? 0,
      idExpired: json['idExpired'] ?? 0,
      faceMatch: json['faceMatch'] ?? 0,
      birthDateMatch: json['birthDateMatch'] ?? 0,
      nameMatch: json['nameMatch'] ?? 0,
      selfieSunglasses: json['selfieSunglasses'] ?? 0,
      selfieEyeglasses: json['selfieEyeglasses'] ?? 0,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idQuality': idQuality,
      'idGlareQuality': idGlareQuality,
      'selfie': selfie,
      'idMatch': idMatch,
      'idExpired': idExpired,
      'faceMatch': faceMatch,
      'birthDateMatch': birthDateMatch,
      'nameMatch': nameMatch,
      'selfieSunglasses': selfieSunglasses,
      'selfieEyeglasses': selfieEyeglasses,
    };
  }
}

class GenderDistributionClass extends _Model {
  GenderDistributionClass({
    required this.man,
    required this.woman,
  });

  /// Frequency with a range 0-100 of the first name in men with a minimum found frequency of 0.0001
  final double man;

  /// Frequency with a range 0-100 of the first name in women with a minimum found frequency of 0.0001
  final double woman;

  factory GenderDistributionClass.fromJson(String str) {
    return GenderDistributionClass.fromMap(jsonDecode(str));
  }

  factory GenderDistributionClass.fromMap(Map<String, dynamic> json) {
    return GenderDistributionClass(
      man: json['man'] ?? 0,
      woman: json['woman'] ?? 0,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'man': man,
      'woman': woman,
    };
  }
}

class ResultGender extends _Model {
  ResultGender({
    required this.gender,
    required this.genderDistribution,
  });

  /// man or woman based on extracted fields from the ID.
  final String gender;

  /// The gender distribution analyzed from the first name.
  final GenderDistributionClass genderDistribution;

  factory ResultGender.fromJson(String str) {
    return ResultGender.fromMap(jsonDecode(str));
  }

  factory ResultGender.fromMap(Map<String, dynamic> json) {
    return ResultGender(
      gender: json['gender'] ?? '',
      genderDistribution: GenderDistributionClass.fromMap(
        json['genderDistribution'] ?? {},
      ),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'gender': gender,
      'genderDistribution': genderDistribution.toMap(),
    };
  }
}

class Signal extends _Model {
  Signal({
    required this.category,
    required this.message,
    required this.type,
    required this.fields,
    required this.property,
  });

  /// Affected verification category.
  final String category;

  /// Message associated with the signal.
  final String message;

  /// Signals affecting the score of the associated verification category.
  final String type;

  /// An array of strings of the affected fields.
  final List<String> fields;

  /// Property of the Signal.
  final String property;

  factory Signal.fromJson(String str) => Signal.fromMap(jsonDecode(str));

  factory Signal.fromMap(Map<String, dynamic> json) {
    final fields = json['fields'] ?? [];

    return Signal(
      category: json['category'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      fields: List<String>.from(fields.map((x) => x)),
      property: json['property'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'message': message,
      'type': type,
      'fields': List<String>.from(fields.map((x) => x)),
      'property': property,
    };
  }

  bool get isPublicProperty => property == 'public';
}
