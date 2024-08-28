import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gpspro/model/NotificationType.dart';
import 'package:gpspro/theme/CustomColor.dart';

class NotificationTypePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _NotificationTypeState();
}

class _NotificationTypeState extends State<NotificationTypePage> {
  StreamController<int>? _postsController;
  List<NotificationTypeModel> notificationTypeList = [];
  bool isLoading = true;

  @override
  void initState() {
    _postsController = new StreamController();
    getNotificationList();
    super.initState();
  }

  void getNotificationList() {
    _postsController!.add(1);
    // APIService.getNotificationTypes().then((value) => {
    //       notificationTypeList.addAll(value),
    //       value.forEach((element) {
    //         _postsController.add(element);
    //       })
    //     });
    // notificationTypeList.sort((a, b) {
    //   return a.type.toLowerCase().compareTo(b.type.toLowerCase());
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(('notification').tr,
              style: TextStyle(color: CustomColor.secondaryColor)),
        ),
        body: loadNotificationType());
  }

  Widget loadNotificationType() {
    return StreamBuilder<int>(
        stream: _postsController!.stream,
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          if (snapshot.hasData) {
            return loadNotifyTypes();
          } else if (isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Center(
              child: Text(('noData').tr),
            );
          }
        });
  }

  Widget loadNotifyTypes() {
    if (notificationTypeList.isNotEmpty) {
      return ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: notificationTypeList.length,
          itemBuilder: (context, index) {
            final notificationType = notificationTypeList[index];
            return new Card(
              elevation: 3.0,
              child: Column(
                children: <Widget>[
                  new ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Text(notificationType.type!,
                            style: TextStyle(
                                fontSize: 13.0, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                ],
              ),
            );
          });
    } else {
      return Center(
        child: Text(('noData').tr),
      );
    }
  }
}
