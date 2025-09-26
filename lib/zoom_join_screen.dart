import 'package:flutter/material.dart';
import 'package:zoom_demo_app/zoom_bridge.dart';
import 'zoom_meeting_configuration.dart';

class ZoomJoinScreen extends StatefulWidget {
  const ZoomJoinScreen({super.key});

  @override
  State<ZoomJoinScreen> createState() => _ZoomJoinScreenState();
}

class _ZoomJoinScreenState extends State<ZoomJoinScreen> {
  final TextEditingController _nameController = TextEditingController();
  final ZoomMeetingConfiguration _zoomConfig = ZoomMeetingConfiguration();
  bool _isSDKInitialized = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Set default display name from configuration
    _zoomConfig.displayName =
        _zoomConfig.displayName; // You can set this from your actual config
    _nameController.text = _zoomConfig.displayName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2D8CFF), Color(0xFF1E40AF)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    48,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Zoom Logo
                  Container(
                    height: 120,
                    width: 120,
                    margin: const EdgeInsets.only(bottom: 32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.videocam,
                      size: 60,
                      color: Color(0xFF2D8CFF),
                    ),
                  ),

                  // Title
                  const Text(
                    'Zoom Meeting',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Join your meeting instantly',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 48),

                  // Initialize SDK Button
                  _buildActionButton(
                    onPressed: _isSDKInitialized ? null : _initializeSDK,
                    text: _isSDKInitialized
                        ? 'SDK Initialized ✓'
                        : 'Initialize SDK',
                    backgroundColor:
                        _isSDKInitialized ? Colors.green : Colors.white,
                    textColor: _isSDKInitialized
                        ? Colors.white
                        : const Color(0xFF2D8CFF),
                    isLoading: _isLoading && !_isSDKInitialized,
                  ),
                  const SizedBox(height: 24),

                  // Name Input Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your display name',
                        labelText: 'Display Name',
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: Color(0xFF2D8CFF),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(20),
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        labelStyle: TextStyle(
                          color: Color(0xFF2D8CFF),
                          fontSize: 16,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Join Meeting Button
                  _buildActionButton(
                    onPressed: _canJoinMeeting() ? _joinMeeting : null,
                    text: 'Join Meeting',
                    backgroundColor: Colors.orange,
                    textColor: Colors.white,
                    isLoading: _isLoading && _isSDKInitialized,
                  ),
                  const SizedBox(height: 32),

                  // Status Text
                  if (_isSDKInitialized)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Ready to join meetings',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback? onPressed,
    required String text,
    required Color backgroundColor,
    required Color textColor,
    bool isLoading = false,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
      ),
    );
  }

  bool _canJoinMeeting() {
    return _isSDKInitialized &&
        _nameController.text.trim().isNotEmpty &&
        !_isLoading;
  }

  Future<void> _initializeSDK() async {
    setState(() {
      _isLoading = true;
    });

    // SDK initialization
    await ZoomBridge.initialize(jwtToken: _zoomConfig.jwtToken);

    setState(() {
      _isSDKInitialized = true;
      _isLoading = false;
    });

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('SDK initialized successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _joinMeeting() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Update the configuration with the current display name
      _zoomConfig.displayName = _nameController.text.trim();

      // Joining meeting
      final result = await ZoomBridge.joinMeeting(
        meetingNumber: _zoomConfig.meetingNumber,
        passcode: _zoomConfig.passcode,
        displayName: _zoomConfig.displayName,
      );

      setState(() {
        _isLoading = false;
      });

      // Show appropriate message based on result
      if (mounted) {
        if (result == 0) {
          // Success
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Joining meeting as ${_zoomConfig.displayName}...'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        } else {
          // Handle specific error codes
          String errorMessage = 'Failed to join meeting';
          switch (result) {
            case ZoomBridge.errorNullResult:
              errorMessage = 'Meeting join returned null result';
              break;
            case ZoomBridge.errorPlatformException:
              errorMessage = 'Platform error occurred while joining meeting';
              break;
            case ZoomBridge.errorUnknown:
              errorMessage = 'Unknown error occurred while joining meeting';
              break;
            default:
              errorMessage = 'Failed to join meeting (Error code: $result)';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error joining meeting: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }

      debugPrint('Error joining meeting: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
