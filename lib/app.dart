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
import 'src/pages/devices/device_list.dart';
import 'src/pages/devices/device_qr.dart';
import 'src/pages/devices/device_checkqr.dart';
import 'src/pages/devices/device_dangerzone.dart';
import 'src/pages/gestures/gesture_add_page.dart';
import 'src/pages/add_page.dart';
import 'src/pages/splash_page.dart';
import 'src/pages/targets/targets_add_page.dart';
import 'src/pages/personal_page.dart';
import 'src/pages/album/album_list_page.dart';
import 'src/pages/album/album_details_page.dart';
import 'src/pages/notification_page.dart';
import 'package:frontend1/src/routes/route_observer.dart';

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
      home: SplashPage(), // 첫 시작 화면
      navigatorObservers: [routeObserver],
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
            return MaterialPageRoute(builder: (_) => const HomePage());

          case '/AddPage':
            return MaterialPageRoute(builder: (_) => const AddPage());

          case '/GestureAddPage':
            return MaterialPageRoute(
              builder: (_) => const GestureAddPage(),
              settings: settings, // arguments 유지 필수
            );

          case '/deviceList': // ✅ 추가된 라우트
            return MaterialPageRoute(builder: (_) => const DeviceListPage());

          case '/DeviceQRPage':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => DeviceQRPage(userId: args['userId']),
            );

          case '/DeviceCheckQRPage':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder:
                  (_) => DeviceCheckQRPage(
                    cameraId: args['cameraId'],
                    deviceId: args['deviceId'],
                    deviceIP: args['deviceIP'],
                  ),
            );

          case '/DeviceDangerZonePage':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder:
                  (_) => DeviceDangerZonePage(
                    cameraId: args['cameraId'],
                    deviceId: args['deviceId'],
                    deviceIP: args['deviceIP'],
                  ),
            );
          case '/targetsAddPage':
            final args = settings.arguments as Map<String, dynamic>?;
            if (args == null) {
              return MaterialPageRoute(
                builder:
                    (_) => const Scaffold(
                      body: Center(
                        child: Text('Missing arguments for TargetsAddPage'),
                      ),
                    ),
              );
            }

            return MaterialPageRoute(
              builder: (_) => TargetsAddPage(),
              settings: RouteSettings(arguments: args), // 전달 그대로 유지
            );
          case '/NotificationPage':
            return MaterialPageRoute(builder: (_) => const NotificationPage());

          case '/PersonalPage':
            return MaterialPageRoute(builder: (_) => const PersonalPage());

          case '/AlbumListPage':
            return MaterialPageRoute(builder: (_) => const AlbumListPage());

          case '/AlbumDetailPage':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => AlbumDetailPage(imageId: args['imageId']),
            );

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
