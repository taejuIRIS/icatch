import 'package:flutter/material.dart';
import 'src/pages/start_page.dart';
import 'src/pages/register_page.dart';
import 'src/pages/login_page.dart';
import 'src/pages/settings/settings1_qr.dart';
import 'src/pages/settings/settings2_checkqr.dart';
import 'src/pages/settings/settings3_camname.dart';
import 'src/pages/settings/settings4_targets.dart';
import 'src/pages/settings/settings5_dangerzone.dart';
import 'src/pages/settings/settings6_gestures.dart';
import 'src/pages/home_page.dart';
import 'src/pages/devices/device_list.dart'; // ✅ 추가

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iCatch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Pretendard',
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const StartPage());

          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterPage());

          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginPage());

          case '/settingsqr':
            final userId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (_) => SettingsQRPage(userId: userId),
            );

          case '/checkMonitoring':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder:
                  (_) => CheckMonitoringPage(
                    cameraId: args['cameraId'],
                    deviceId: args['deviceId'],
                    deviceIP: args['deviceIP'],
                  ),
            );

          case '/settingsCamName':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder:
                  (_) => SettingsCamNamePage(
                    deviceId: args['deviceId'],
                    deviceIP: args['deviceIP'],
                  ),
            );

          case '/settingsTargets':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => SettingsTargetsPage(),
              settings: RouteSettings(arguments: args),
            );

          case '/settingsDangerZone':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder:
                  (_) => SettingsDangerZonePage(
                    cameraId: args['cameraId'],
                    deviceId: args['deviceId'],
                    deviceIP: args['deviceIP'],
                  ),
            );

          case '/settingsGesture':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder:
                  (_) => SettingsGesturePage(
                    cameraId: args['cameraId'],
                    deviceId: args['deviceId'],
                    deviceIP: args['deviceIP'],
                  ),
            );

          case '/home':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder:
                  (_) => HomePage(
                    cameraId: args?['cameraId'],
                    deviceId: args?['deviceId'],
                    deviceIP: args?['deviceIP'],
                  ),
            );

          case '/deviceList': // ✅ 추가된 라우트
            return MaterialPageRoute(builder: (_) => const DeviceListPage());

          default:
            return MaterialPageRoute(
              builder:
                  (_) => const Scaffold(
                    body: Center(child: Text('404 - 페이지를 찾을 수 없습니다')),
                  ),
            );
        }
      },
    );
  }
}
