import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin gestionnaireNotifications =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const AndroidInitializationSettings parametresAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings parametresIOS =
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

  const InitializationSettings parametresInitialisation =
      InitializationSettings(android: parametresAndroid, iOS: parametresIOS);

  await gestionnaireNotifications.initialize(parametresInitialisation);

  await gestionnaireNotifications
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.requestNotificationsPermission();

  await gestionnaireNotifications
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.requestExactAlarmsPermission();

  await gestionnaireNotifications
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >()
      ?.requestPermissions(alert: true, badge: true, sound: true);

  runApp(const ApplicationPrincipale());
}

class ApplicationPrincipale extends StatelessWidget {
  const ApplicationPrincipale({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const EcranAccueil(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
    );
  }
}

class EcranAccueil extends StatefulWidget {
  const EcranAccueil({super.key});

  @override
  State<EcranAccueil> createState() => _EcranAccueilState();
}

class _EcranAccueilState extends State<EcranAccueil> {
  //1. Heads-up Notification
  Future<void> lancerNotifUrgente() async {
    const AndroidNotificationDetails configAndroid = AndroidNotificationDetails(
      'canal_urgent',
      'Notifications Urgentes',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
    );

    await gestionnaireNotifications.show(
      10,
      "Alerte Importante",
      "Cette notification apparait en haut de l'ecran meme si une autre application est ouverte.",
      const NotificationDetails(
        android: configAndroid,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  //2. Immediate Notification
  Future<void> lancerNotifInstantanee() async {
    const AndroidNotificationDetails configAndroid = AndroidNotificationDetails(
      'canal_instantane',
      'Notifications Instantanees',
      importance: Importance.max,
      priority: Priority.high,
    );

    await gestionnaireNotifications.show(
      20,
      "Notification Instantanee",
      "Cette notification s'affiche immediatement apres avoir appuye sur le bouton.",
      const NotificationDetails(
        android: configAndroid,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  //3. Action Notification
  Future<void> lancerNotifAvecActions() async {
    const AndroidNotificationDetails configAndroid = AndroidNotificationDetails(
      'canal_actions',
      'Notifications avec Actions',
      importance: Importance.max,
      priority: Priority.high,
      actions: [
        AndroidNotificationAction('confirmer', 'Confirmer'),
        AndroidNotificationAction('annuler', 'Annuler'),
      ],
    );

    await gestionnaireNotifications.show(
      30,
      "Confirmation Requise",
      "Voulez-vous confirmer votre rendez-vous de demain a 10h?",
      const NotificationDetails(
        android: configAndroid,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  //4. Inbox Style Notification
  Future<void> lancerNotifBoiteReception() async {
    const AndroidNotificationDetails configAndroid = AndroidNotificationDetails(
      'canal_boite',
      'Notifications Boite de Reception',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: InboxStyleInformation(
        [
          "Marie: Bonjour, tu es disponible?",
          "Jean: La reunion est a 15h.",
          "Sophie: N'oublie pas le rapport!",
          "Paul: Merci pour ton aide hier.",
        ],
        contentTitle: "4 nouveaux messages",
        summaryText: "4 messages non lus",
      ),
    );

    await gestionnaireNotifications.show(
      40,
      "Boite de Reception",
      "Vous avez 4 nouveaux messages.",
      const NotificationDetails(
        android: configAndroid,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  //5. Big Text Notification
  Future<void> lancerNotifGrandTexte() async {
    const AndroidNotificationDetails configAndroid = AndroidNotificationDetails(
      'canal_grand_texte',
      'Notifications Grand Texte',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(
        "Ceci est une notification avec un contenu etendu. "
        "Lorsque vous depliez cette notification, vous pouvez lire "
        "l'integralite du message sans avoir a ouvrir l'application. "
        "Cette fonctionnalite est tres utile pour les actualites ou les rappels detailles.",
        htmlFormatBigText: true,
        contentTitle: "Message Complet",
        summaryText: "Appuyez pour lire la suite",
      ),
    );

    await gestionnaireNotifications.show(
      50,
      "Nouveau Message",
      "Depliez pour lire le message complet...",
      const NotificationDetails(
        android: configAndroid,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  void _afficherMessageConfirmation(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.blue.shade700,
      ),
    );
  }

  Widget construireBoutonNotification({
    required String titre,
    required String description,
    required VoidCallback onPressed,
    bool estActif = false,
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
                  color: estActif ? Colors.orange : Colors.black,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: estActif
                    ? Colors.orange.shade50
                    : Colors.white,
              ),
              child: Text(
                titre,
                style: TextStyle(
                  fontSize: 16,
                  color: estActif ? Colors.orange : Colors.black87,
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
            construireBoutonNotification(
              titre: "Heads-up Notification",
              description:
                  "Affiche une notification en haut de l'ecran, meme si une autre app est ouverte.",
              onPressed: () async {
                await lancerNotifUrgente();
                _afficherMessageConfirmation("Notification heads-up envoyee!");
              },
            ),
            construireBoutonNotification(
              titre: "Immediate Notification",
              description:
                  "Envoie une notification qui s'affiche instantanement.",
              onPressed: () async {
                await lancerNotifInstantanee();
                _afficherMessageConfirmation(
                  "Notification instantanee envoyee!",
                );
              },
            ),
            construireBoutonNotification(
              titre: "Action Notification",
              description:
                  "Notification avec boutons d'action: Confirmer ou Annuler.",
              onPressed: () async {
                await lancerNotifAvecActions();
                _afficherMessageConfirmation(
                  "Notification avec actions envoyee!",
                );
              },
            ),
            construireBoutonNotification(
              titre: "Inbox Style Notification",
              description:
                  "Affiche plusieurs messages groupes dans une seule notification.",
              onPressed: () async {
                await lancerNotifBoiteReception();
                _afficherMessageConfirmation(
                  "Notification boite de reception envoyee!",
                );
              },
            ),
            construireBoutonNotification(
              titre: "Big Text Notification",
              description:
                  "Affiche un long message que vous pouvez lire en depliez la notification.",
              onPressed: () async {
                await lancerNotifGrandTexte();
                _afficherMessageConfirmation(
                  "Notification grand texte envoyee!",
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
