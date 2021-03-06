import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mis_lab3/screens/add_location_event.dart';
import 'package:mis_lab3/screens/calendar_screen.dart';
import 'package:mis_lab3/screens/login_screen.dart';
import 'package:mis_lab3/screens/map_screen.dart';
import 'package:mis_lab3/screens/register_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'kolokvium.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FirebaseMessaging messaging = FirebaseMessaging.instance;

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications',
  importance: Importance.high,
  playSound: true
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true
  );

  runApp(const MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('A bg message just showed up : ${message.messageId}');
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MIS Lab 5',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      // home: const MyHomePage(title: 'MIS Lab 4'),
      initialRoute: '/login',
      routes: {
        '/calendar': (context) => const CalendarScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegistrationScreen(),
        '/home': (context) => const MyHomePage(title: 'MIS Lab 5'),
        '/add-location': (context) => AddLocationEvent(notify: (reminder, address) {
          print(reminder);
          print(address);
          flutterLocalNotificationsPlugin
              .show(0,
                '???????????????????? ???? $address!',
                '???? ?????????????????? ???? $reminder',
                NotificationDetails(
                  android: AndroidNotificationDetails(
                      channel.id,
                      channel.name,
                      channelDescription: channel.description,
                      color: Colors.blue,
                      playSound: true,
                      icon: '@mipmap/ic_launcher'
                  )
              )
              )
              .then((result) {})
              .catchError((onError) {
            print('[flutterLocalNotificationsPlugin.show] ERROR: $onError');
          });
        },),
        '/map': (context) => MapScreen()
      },
    );
  }
}

final _firestore = FirebaseFirestore.instance;
User? loggedInUser;

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final _auth = FirebaseAuth.instance;
  List<Map<String, dynamic> > elements = [];
  List<Map<String, dynamic> > locationEvents = [];
  final nameController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();

  Future<void> loadFromDb() async {
    List<Map<String, dynamic> > elems = [];
    await _firestore.collection('exams').where('userId', isEqualTo: loggedInUser!.uid).get().then((value) => {
      for(var elem in value.docs) {
        elems.add(elem.data())
      }
    });

    List<Map<String, dynamic> > locEvents = [];
    await _firestore.collection('locationEvents').where('userId', isEqualTo: loggedInUser!.uid).get().then((value) => {
      for(var elem in value.docs) {
        locEvents.add(elem.data())
      }
    });

    setState(() {
      elements = elems;
      locationEvents = locEvents;
    });
  }

  DateTime parseDateTime(String date, String time) {
    return DateTime.parse('${date}T$time');
  }
  
  Widget getElements(){
    if (elements.isEmpty){
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: const Center(
            child: Text(
              "???? ???????????????? ???????????? ???????????????? ????????????????????",
              style: TextStyle(
                  fontSize: 20
              ),
            )
        ),
      );
    }else{
      return Expanded(
        flex: 4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            itemCount: elements.length,
            itemBuilder: (contx, index) {
              return Kolokvium(
                  elements[index]['title'] as String,
                  elements[index]['date'] as String,
                  elements[index]['time'] as String,
                  Theme.of(contx).primaryColor
              );
            },
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/ic_launcher'
              )
            )
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
          showDialog(context: context, builder: (_) {
            return AlertDialog(
              title: Text(notification.title != null ? notification.title! : '????????????????????????'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notification.body != null ? notification.body! : '??????????????????')
                  ],
                ),
              )
            );
          });
      }

    });

    _auth.userChanges()
        .listen((User? user) {
          if (user != null) {
            setState(() {
              loggedInUser = user;
            });
            loadFromDb();
          }
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            IconButton(onPressed: () {

              setState(() {
                elements.add({
                  "title": nameController.text,
                  "date": dateController.text,
                  "time": timeController.text
                });
                _firestore.collection('exams').add(
                    {'userId': loggedInUser!.uid,
                     'title': nameController.text,
                     'date': dateController.text,
                     'time': timeController.text
                    }
                      ).then((value) => print("Exam Added"))
                    .catchError((error) => print("Failed to add exam: $error"));

                final date = parseDateTime(dateController.text, timeController.text);

                flutterLocalNotificationsPlugin.schedule(
                    0,
                    '?????????????????? - ${nameController.text}',
                    '?????????????????? ???? ?????????????????? ?????????? ???? ${timeController.text}',
                    date.subtract(Duration(hours: 1)),
                    NotificationDetails(
                      android: AndroidNotificationDetails(
                          channel.id,
                          channel.name,
                          channelDescription: channel.description,
                          importance: Importance.high,
                          color: Colors.blue,
                          playSound: true,
                          icon: '@mipmap/ic_launcher'
                      ),
                    )
                );


                nameController.clear();
                dateController.clear();
                timeController.clear();

              });

              showDialog(
                context: context,
                builder: (context) {
                  return const AlertDialog(
                    content: Text('?????????????? ?????????????????? ?????? ??????????????????'),
                  );
                },
              );

            }, icon: const Icon(Icons.add))
          ],
        ),
        body: Container(
          height: 600,
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  margin: const EdgeInsets.all(3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          child: Text('????????????????'),
                          onPressed: () {
                            Navigator.pushNamed(context, '/calendar', arguments: elements);
                          },
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          child: Text('???????????? ??????a????????'),
                          onPressed: () {
                            Navigator.pushNamed(context, '/add-location');
                          },
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          child: Text('????????'),
                          onPressed: () async {
                            await loadFromDb();
                            Navigator.pushNamed(context, '/map', arguments: locationEvents);
                          },
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          child: Text('???????????? ????'),
                          onPressed: () {
                            _auth.signOut();
                            Navigator.pop(context);
                          }
                        ),
                      ),
                    ],
                  )
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Container(
                      height: 40,
                      margin: const EdgeInsets.all(2),
                      child: TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '?????? ???? ??????????????',
                        ),
                      ),
                    ),
                    Container(
                      height: 40,
                      margin: const EdgeInsets.all(2),
                      child: TextField(
                        controller: dateController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '?????????? (???????????? YYYY-MM-DD)',
                        ),
                      ),
                    ),
                    Container(
                      height: 40,
                      margin: const EdgeInsets.all(2),
                      child: TextField(
                        controller: timeController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '?????????? ???? ???????????????? (???????????? HH:MM)',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(flex: 1, child: Text('user: ${loggedInUser != null ? loggedInUser!.email : 'loading..'}'),),
              getElements()
          ]),
        ),
      ),
    );
  }
}
