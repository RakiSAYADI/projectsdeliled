import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_universe.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class UniverseCard extends StatelessWidget {
  final UniverseClass universeClass;
  final Function() connect;

  const UniverseCard({required this.universeClass, required this.connect});

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    Color accessTypeIconColor = Colors.white;
    IconData accessTypeIcon = Icons.accessibility;
    String accessTypeText = 'default';
    switch (universeClass.role) {
      case 'OWNER':
        accessTypeIconColor = Colors.amber;
        accessTypeText = universeOwnerTextLanguageArray[languageArrayIdentifier];
        break;
      case 'ADMIN':
        accessTypeIconColor = Colors.blue;
        accessTypeText = universeAdminDeviceTextLanguageArray[languageArrayIdentifier];
        break;
      case 'MEMBER':
        accessTypeIconColor = Colors.black;
        accessTypeText = universeMemberDeviceTextLanguageArray[languageArrayIdentifier];
        break;
    }
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Slidable(
        // Specify a key if the Slidable is dismissible.
        key: const ValueKey(0),

        // The start action pane is the one at the left or the top side.
        startActionPane: ActionPane(
          // A motion is a widget used to control how the pane animates.
          motion: const ScrollMotion(),

          // A pane can dismiss the Slidable.
          dismissible: DismissiblePane(onDismissed: () {}),

          // All actions are defined in the children parameter.
          children: [
            // A SlidableAction can have an icon and/or a label.
            SlidableAction(
              backgroundColor: const Color(0xFFFE4A49),
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
              onPressed: (BuildContext context) {},
            ),
          ],
        ),

        // The end action pane is the one at the right or the bottom side.
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              // An action can be bigger than the others.
              flex: 2,
              onPressed: (BuildContext context) {},
              backgroundColor: const Color(0xFF7BC043),
              foregroundColor: Colors.white,
              icon: Icons.archive,
              label: 'Archive',
            ),
            SlidableAction(
              onPressed: (BuildContext context) {},
              backgroundColor: const Color(0xFF0392CF),
              foregroundColor: Colors.white,
              icon: Icons.save,
              label: 'Save',
            ),
          ],
        ),

        // The child of the Slidable is what the user sees when the
        // component is not dragged.
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 9,
                child: Column(
                  //crossAxisAlignment: CrossAxisAlignment.stretch,
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      universeClass.name,
                      style: TextStyle(fontSize: heightScreen * 0.013 + widthScreen * 0.013, color: Colors.grey[800]),
                    ),
                    Text(
                      universeClass.geoName,
                      style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.grey[600]),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'lon : ${universeClass.lon}',
                          style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.grey[800]),
                        ),
                        Text(
                          ' lat : ${universeClass.lat}',
                          style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.grey[800]),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: connect,
                          icon: Icon(Icons.supervised_user_circle, size: heightScreen * 0.009 + widthScreen * 0.009),
                          label: Text(
                            usersButtonTextLanguageArray[languageArrayIdentifier],
                            style: TextStyle(fontSize: heightScreen * 0.009 + widthScreen * 0.009),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: connect,
                          icon: Icon(Icons.devices, size: heightScreen * 0.009 + widthScreen * 0.009),
                          label: Text(
                            devicesButtonTextLanguageArray[languageArrayIdentifier],
                            style: TextStyle(fontSize: heightScreen * 0.009 + widthScreen * 0.009),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: connect,
                          icon: Icon(Icons.check_box_outlined, size: heightScreen * 0.009 + widthScreen * 0.009),
                          label: Text(
                            scenesButtonTextLanguageArray[languageArrayIdentifier],
                            style: TextStyle(fontSize: heightScreen * 0.009 + widthScreen * 0.009),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(accessTypeIcon, size: heightScreen * 0.01 + widthScreen * 0.01, color: accessTypeIconColor),
                    Text(
                      accessTypeText,
                      style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: accessTypeIconColor),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
