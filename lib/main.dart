import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.requestNotificationsPermission();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.requestExactAlarmsPermission();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >()
      ?.requestPermissions(alert: true, badge: true, sound: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;

  // 1. Notifikasyon Imedya

  Future<void> showImmediateNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'immediate_channel',
          'Immediate Notifications',
          importance: Importance.max,
          priority: Priority.high,
        );

    await flutterLocalNotificationsPlugin.show(
      0,
      "Notifikasyon Imedya",
      "Sa se yon notifikasyon ki parèt touswit.",
      const NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // 2. Notifikasyon Big Text

  Future<void> showBigTextNotification() async {
    const AndroidNotificationDetails
    androidDetails = AndroidNotificationDetails(
      'bigtext_channel',
      'Big Text Notifications',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(
        "Sa se yon notifikasyon ki gen yon tèks long pou montre kijan "
        "BigTextStyle mache nan Flutter. Lè ou depliye notifikasyon an, "
        "ou ka wè tout mesaj la san pwoblèm. Sa trè itil pou nouvèl ak alèt.",
        htmlFormatBigText: true,
        contentTitle: "Big Text Notifikasyon",
        summaryText: "Tèks long dewoule",
      ),
    );

    await flutterLocalNotificationsPlugin.show(
      3,
      "Big Text Notifikasyon",
      "Gade tèks long lan...",
      const NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // 3. Notifikasyon ak Bouton Aksyon

  Future<void> showActionNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'action_channel',
          'Action Notifications',
          importance: Importance.max,
          priority: Priority.high,
          actions: [
            AndroidNotificationAction('accept', 'Aksepte'),
            AndroidNotificationAction('decline', 'Refize'),
          ],
        );

    await flutterLocalNotificationsPlugin.show(
      4,
      "Notifikasyon ak Aksyon",
      "Ou gen yon envitasyon! Ki sa ou vle fè?",
      const NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // 4. Notifikasyon Progress Bar

  Future<void> showProgressNotification() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    for (int progress = 0; progress <= 100; progress += 10) {
      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'progress_channel',
            'Progress Notifications',
            importance: Importance.max,
            priority: Priority.high,
            showProgress: true,
            maxProgress: 100,
            progress: progress,
            onlyAlertOnce: true,
            ongoing: progress < 100,
            playSound: true,
            enableVibration: true,
          );

      await flutterLocalNotificationsPlugin.show(
        5,
        progress < 100 ? "Download ap fèt... $progress%" : "Download Fini! ",
        progress < 100 ? "Tanpri tann..." : "Fichye a telechaje avèk siksè.",
        NotificationDetails(
          android: androidDetails,
          iOS: DarwinNotificationDetails(
            presentAlert: progress == 0 || progress == 100,
            presentBadge: true,
            presentSound: progress == 0 || progress == 100,
          ),
        ),
      );

      if (progress < 100) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    setState(() => _isLoading = false);
  }

  // 5. Notifikasyon Silans

  Future<void> showSilentNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'silent_channel',
          'Silent Notifications',
          importance: Importance.low,
          priority: Priority.low,
          playSound: false,
          enableVibration: false,
          silent: true,
        );

    await flutterLocalNotificationsPlugin.show(
      6,
      "Notifikasyon Silansye",
      "Notifikasyon sa a parèt san son ni vibrasyon.",
      const NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: false,
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.blue.shade700,
      ),
    );
  }

  Widget buildNotificationButton({
    required String title,
    required String description,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 60,
            child: OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isActive ? Colors.orange : Colors.black,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: isActive
                    ? Colors.orange.shade50
                    : Colors.white,
              ),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: isActive ? Colors.orange : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Notification Demo",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            buildNotificationButton(
              title: "Immediate Notification",
              description: "Voye yon notifikasyon ki parèt touswit imedyatman.",
              onPressed: () async {
                await showImmediateNotification();
                _showSnackBar("Notifikasyon imedya voye!");
              },
            ),
            buildNotificationButton(
              title: "Big Text Notification",
              description:
                  "Voye yon notifikasyon ak yon long tèks ou ka depliye.",
              onPressed: () async {
                await showBigTextNotification();
                _showSnackBar("Big Text notifikasyon voye!");
              },
            ),
            buildNotificationButton(
              title: "Action Notification",
              description:
                  "Notifikasyon ak bouton aksyon: Aksepte oswa Refize.",
              onPressed: () async {
                await showActionNotification();
                _showSnackBar("Notifikasyon ak bouton voye!");
              },
            ),
            buildNotificationButton(
              title: _isLoading
                  ? "Download ap fèt... "
                  : "Progress Bar Notification",
              description:
                  "Montre yon ba pwogrè pou simile yon download (5 segonn).",
              isActive: _isLoading,
              onPressed: () async {
                await showProgressNotification();
                _showSnackBar("Download fini!");
              },
            ),
            buildNotificationButton(
              title: "Silent Notification",
              description: "Notifikasyon ki parèt san son ni vibrasyon ditou.",
              onPressed: () async {
                await showSilentNotification();
                _showSnackBar("Notifikasyon silansye voye!");
              },
            ),
          ],
        ),
      ),
    );
  }
}
