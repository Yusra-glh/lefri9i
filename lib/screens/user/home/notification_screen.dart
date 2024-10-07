import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:gark_academy/services/provider/notification_provider.dart';
import 'package:gark_academy/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: secondaryColor,
        title: Text(
          'Notifications',
          style: GoogleFonts.montserrat(
            color: black,
            fontWeight: FontWeight.w700,
            fontSize: MediaQuery.of(context).size.width * 0.047,
          ),
        ),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          final notifications = notificationProvider.notifications;

          if (notifications.isEmpty) {
            return const Center(
              child: Text('Aucune notification pour le moment.'),
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Dismissible(
                key: Key(notification.id.toString()),
                background: Container(
                  color: red.withOpacity(0.5),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Icon(Icons.delete, color: white),
                      ),
                    ],
                  ),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  // Delete the notification
                  Provider.of<NotificationProvider>(context, listen: false)
                      .deleteNotification(notification.id);
                },
                // child: ListTile(
                //   title: Text(notification.message),
                //   subtitle: Text(notification.creationDate.toString()),
                //   trailing: Icon(
                //     notification.viewed ? Icons.check_circle : Icons.circle,
                //     color: notification.viewed ? Colors.green : Colors.grey,
                //   ),
                //   onTap: () {
                //     if (!notification.viewed) {
                //       Provider.of<NotificationProvider>(context, listen: false)
                //           .markNotificationAsSeen(notification.id);
                //     }
                //   },
                // ),
                child: notification.viewed
                    ? buildSeenNotification(
                        context,
                        notification.message,
                        notification.creationDate,
                        notification.id,
                        notification.viewed)
                    : buildUnseenNotification(
                        context,
                        notification.message,
                        notification.creationDate,
                        notification.id,
                        notification.viewed),
              );
            },
          );
        },
      ),
    );
  }

  Widget buildSeenNotification(BuildContext context, String message,
      DateTime creationDate, int id, bool viewed) {
    final timeAgo = timeago.format(creationDate);
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: white,
        border: Border.all(
          color: secondaryColor,
          width: 1,
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.024,
        left: MediaQuery.of(context).size.width * 0.0385,
        right: MediaQuery.of(context).size.width * 0.0385,
        bottom: MediaQuery.of(context).size.height * 0.024,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Notification",
                style: GoogleFonts.raleway(
                  color: black,
                  fontWeight: FontWeight.w600,
                  fontSize: MediaQuery.of(context).size.width * 0.0385,
                ),
              ),
              // I want it to be time ago
              Text(
                timeAgo,
                style: GoogleFonts.raleway(
                  color: black,
                  fontWeight: FontWeight.w600,
                  fontSize: MediaQuery.of(context).size.width * 0.0385,
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.012),
          Text(
            message,
            style: GoogleFonts.raleway(
              color: black,
              fontWeight: FontWeight.w300,
              fontSize: MediaQuery.of(context).size.width * 0.0385,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildUnseenNotification(BuildContext context, String message,
      DateTime creationDate, int id, bool viewed) {
    final timeAgo = timeago.format(creationDate);
    return Bounceable(
      onTap: () {
        if (!viewed) {
          Provider.of<NotificationProvider>(context, listen: false)
              .markNotificationAsSeen(id);
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: secondaryColorLight,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.024,
          left: MediaQuery.of(context).size.width * 0.0385,
          right: MediaQuery.of(context).size.width * 0.0385,
          bottom: MediaQuery.of(context).size.height * 0.024,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Notification",
                  style: GoogleFonts.raleway(
                    color: black,
                    fontWeight: FontWeight.w600,
                    fontSize: MediaQuery.of(context).size.width * 0.0385,
                  ),
                ),
                // I want it to be time ago
                Text(
                  timeAgo,
                  style: GoogleFonts.raleway(
                    color: black,
                    fontWeight: FontWeight.w600,
                    fontSize: MediaQuery.of(context).size.width * 0.0385,
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.012),
            Text(
              message,
              style: GoogleFonts.raleway(
                color: black,
                fontWeight: FontWeight.w300,
                fontSize: MediaQuery.of(context).size.width * 0.0385,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
