class RouteConstants {
  RouteConstants._();

  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String fieldList = '/home/fields';
  static const String fieldDetail = '/home/fields/:fieldId';
  static const String timeSlotSelection = '/home/fields/:fieldId/slots';
  static const String reservationConfirm = '/home/reservations/confirm';
  static const String reservationHistory = '/home/reservations/history';
  static const String reservationDetail = '/home/reservations/:reservationId';
  static const String notifications = '/home/notifications';
  static const String profile = '/home/profile';
}