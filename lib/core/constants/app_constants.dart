class AppConstants {
  AppConstants._();

  static const String appName = 'Isra Fields Booking';
  static const String universityName = 'Isra University';

  static const int studentIdLength = 10;
  static const String studentIdPattern = r'^\d{10}$';

  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;

  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusCircular = 100.0;

  static const double buttonHeight = 52.0;
  static const double inputHeight = 56.0;
  static const double iconSizeS = 18.0;
  static const double iconSizeM = 24.0;
  static const double iconSizeL = 32.0;

  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 350);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration mockAuthDelay = Duration(seconds: 2);

  static const List<String> mockValidStudentIds = [
    '2021100001',
    '2021100002',
    '2022100010',
    '2023100099',
    '2020100050',
  ];

  static const String logoPath = 'assets/images/isra_logo.png';
}