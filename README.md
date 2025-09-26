# Zoom Meeting Join — Flutter Integration

Professional Flutter sample that demonstrates how to join a Zoom meeting from inside a Flutter app using the Zoom Meeting SDK. This repository contains minimal wiring to initialize the Meeting SDK and join as a participant for development testing.

## Goals
- Let users join a Zoom meeting from inside the app (no external browser required).
- Demonstrate a secure development workflow: generate short-lived Meeting SDK JWTs for testing and recommend server-side token minting for production.

## Repository structure
- `lib/` — Flutter source (integration points: `zoom_bridge.dart`, `zoom_join_screen.dart`, `zoom_meeting_configuration.dart`).
- `android/`, `ios/` — platform-specific integration and native SDK configuration.

## Prerequisites
- Flutter SDK (https://flutter.dev).
- Platform toolchains for your target platforms (Android Studio for Android, Xcode for iOS).
- A Zoom developer account and a Meeting SDK app created in the Zoom App Marketplace.

## Quick start
1. Clone the repository:

   git clone https://github.com/Yusuf92002/zoom-join-meeting-flutter-integration.git
   cd zoom-join-meeting-flutter-integration

2. Install dependencies:

   flutter pub get

3. Configure your credentials and token generation (see "Configuration" below).

4. Run the app on a device or emulator:

   flutter run

## Configuration
1. In the Zoom App Marketplace create a Meeting SDK app or an appropriate app type and obtain the AppKey (Client ID) and App Secret (Client Secret).

2. For quick development testing, you can generate a Participant Meeting SDK JWT using Zoom's Test SDK JWT generator (see "Generating a Participant JWT" below). For production, use a backend to mint tokens.

3. Supply credentials to the app during development. Example (PowerShell):

```powershell
$env:ZOOM_MEETING_SDK_KEY = "<YOUR_APP_KEY>"
$env:ZOOM_MEETING_SDK_SECRET = "<YOUR_APP_SECRET>"
# Or, if you already generated a participant JWT for local testing:
$env:MEETING_PARTICIPANT_JWT = "<GENERATED_PARTICIPANT_JWT>"
```

4. The Flutter code reads the configured token or mints a join request using the SDK initialization. See `lib/zoom_bridge.dart` and `lib/zoom_join_screen.dart` for the join flow and where to plug in the JWT.

## Generating a Participant JWT for development (based on included screenshots)
Follow these steps to create a short-lived Participant JWT for local testing:

1. Create an app in Zoom App Marketplace (choose the app type that exposes Meeting SDK credentials).  
   The screenshot below demonstrates creating a General/Meeting SDK app:  

   <img src="" alt="Screenshot (400)" width="800"/>

2. In the app configuration enable the Meeting SDK Embed options and note the platform SDK versions if you need native SDKs:  

   <img src="" alt="Screenshot (401)" width="800"/>  
   <img src="" alt="Screenshot (402)" width="800"/>

3. Copy the Client ID (AppKey) and Client Secret from the app **Basic Information** page:  

   <img src="" alt="Screenshot (403)" width="800"/>

4. Open the Meeting SDK docs and use the **"Test SDK JWT generator"** tab. Enter:  
   - Meeting SDK AppKey (Client ID)  
   - Meeting SDK Secret (Client Secret)  
   - Meeting Number for the meeting you want to join  
   - Role Type = Participant  

   Generate the JWT and copy the token:  

   <img src="" alt="Screenshot (404)" width="800"/>

5. Use that token for local development by exporting it as an environment variable, or paste it into the debug configuration. The app can then use the token to join as a Participant.

Important: the Test SDK JWT generator is for development only. Tokens are short lived and should not be used in production.

## Local SDK files and gitignore
If you download Zoom Meeting SDK binaries for Android, iOS or other platforms, place them locally and do not commit them to the repository. Typical locations used by this project:

- Android native SDKs / libraries: `android/app/libs/`
- iOS native SDKs: `ios/ZoomSDK/` or `ios/Pods/ZoomSDK/` when using CocoaPods
- Alternative local folder: top-level `ZoomSDK/` or `libs/` for manual placement

This repository's `.gitignore` already excludes these folders so you can keep the SDKs locally and out of version control. Do not add SDK binaries or secrets to commits — add them to your local `.gitignore` or the project's `.gitignore` if you change your folder layout.

## Security recommendations
- Never commit App Secrets, Client Secrets, or JWTs into source control.
- For production, implement a small backend service that holds the App Secret and mints short-lived JWTs on demand. The client requests a token from your backend over TLS and then uses it to initialize/join the meeting.
- Keep JWT lifetimes short and scope tokens to the minimum privileges needed (Participant vs Host).
- Use HTTPS/TLS for all connections between client and backend.
- Rotate secrets regularly and follow Zoom's security checklists when publishing apps.

## Troubleshooting
- SDK initialization errors often indicate invalid credentials or missing native SDK artifacts; check device logs.
- Authentication/join failures: verify the JWT was generated with the correct AppKey and Secret and the meeting number and role are correct.

## References
- Zoom Meeting SDK docs: https://developer.zoom.us/docs/meetings/overview/
- Zoom App Marketplace: https://marketplace.zoom.us/

## Contributing
- Contributions are welcome. Open an issue or a pull request. Do not add secrets to commits.

## License
- [MIT](LICENSE)

## Credits
- Demo prepared to illustrate embedding Zoom meeting join functionality in a Flutter application while following secure practices for development and production.
