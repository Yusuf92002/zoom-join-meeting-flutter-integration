import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Bridge class for communicating with native Zoom SDK
class ZoomBridge {
  static const _channel = MethodChannel('zoom_bridge');

  // Error codes for different failure scenarios
  static const int errorUnknown = -1;          // Generic/unexpected error
  static const int errorPlatformException = -2; // Platform-specific error from native code
  static const int errorNullResult = -3;       // Native method returned null

  /// Initializes the Zoom SDK with the provided JWT token
  /// 
  /// [jwtToken] - JWT token required for Zoom SDK authentication
  /// 
  /// Returns:
  /// - `true` if SDK initialization was successful
  /// - `false` if initialization failed (invalid token, network issues, etc.)
  /// 
  /// This method must be called before attempting to join any meetings.
  static Future<bool> initialize({required String jwtToken}) async {
    try {
      // Native Android/iOS implementation
      final result = await _channel.invokeMethod<bool>('init', {
        'jwtToken': jwtToken,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to initialize Zoom SDK: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Error initializing Zoom SDK: $e');
      return false;
    }
  }

  /// Joins a Zoom meeting with the specified credentials
  /// 
  /// [meetingNumber] - The Zoom meeting ID (e.g., "123456789")
  /// [passcode] - Meeting passcode/password
  /// [displayName] - Name to display in the meeting
  /// 
  /// Returns:
  /// - `0` or positive number: Success (meeting joined successfully)
  /// - `errorNullResult` (-3): Native method returned null
  /// - `errorPlatformException` (-2): Platform-specific error (invalid credentials, network issues)
  /// - `errorUnknown` (-1): Unexpected error occurred
  /// 
  /// Note: SDK must be initialized before calling this method.
  static Future<int> joinMeeting({
    required String meetingNumber,
    required String passcode,
    required String displayName,
  }) async {
    try {
      // Native Android/iOS implementation
      final result = await _channel.invokeMethod<int>('join', {
        'meetingNumber': meetingNumber,
        'passcode': passcode,
        'displayName': displayName,
      });
      return result ?? errorNullResult;
    } on PlatformException catch (e) {
      debugPrint('Failed to join meeting: ${e.message}');
      return errorPlatformException;
    } catch (e) {
      debugPrint('Error joining meeting: $e');
      return errorUnknown;
    }
  }
}