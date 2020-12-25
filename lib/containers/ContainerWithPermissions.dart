import 'package:flutter/material.dart';
import '../util/os.dart';

enum Permission {
  extStorage,
}

Map<Permission, Future<bool> Function()> PermissionToRequest = {
  Permission.extStorage: requestExternalStorageAccess,
};

class ContainerWithPermissions extends StatefulWidget {
  final Widget Function(BuildContext) childConstructor;
  final Permission permission;

  ContainerWithPermissions(this.permission, this.childConstructor);

  @override
  _ContainerWithPermissionsState createState() =>
      _ContainerWithPermissionsState();
}

class _ContainerWithPermissionsState extends State<ContainerWithPermissions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: PermissionToRequest[widget.permission](),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data) {
              return widget.childConstructor(context);
            } else {
              return Center(
                child: Column(
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("An important permission was rejected."),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {});
                      },
                      child: Text("Ask again"),
                    )
                  ],
                ),
              );
            }
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
