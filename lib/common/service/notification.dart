import 'package:get/get.dart';

class NotificationService extends GetxController {
  // Rx<DateTime> selectedDateTime = Rx<DateTime>(DateTime.now());
  //
  // void scheduleNotification() async {
  //   var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
  //     'your_channel_id',
  //     'your_channel_name',
  //     channelDescription: 'your_channel_description',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //     playSound: true,
  //   );
  //   var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
  //   await flutterLocalNotificationsPlugin.zonedSchedule(
  //     0,
  //     'Reminder',
  //     'Time to do something!',
  //     selectedDateTime.value,
  //     platformChannelSpecifics,
  //     androidAllowWhileIdle: true,
  //     uiLocalNotificationDateInterpretation:
  //     UILocalNotificationDateInterpretation.absoluteTime,
  //   );
  // }
}