/// Bondly API Endpoints and Cloud Functions URLs
class ApiEndpoints {
  // Base Cloud Functions region endpoint (placeholder for live project)
  static const String functionsBaseUrl = 'https://us-central1-bondly-f401f.cloudfunctions.net';

  // Feature endpoints
  static const String authSync = '$functionsBaseUrl/authSync';
  static const String notifications = '$functionsBaseUrl/sendNotification';
  static const String invitations = '$functionsBaseUrl/validateInvitation';
  static const String reports = '$functionsBaseUrl/submitReport';
}
