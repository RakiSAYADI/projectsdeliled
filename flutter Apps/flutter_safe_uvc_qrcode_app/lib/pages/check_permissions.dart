import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/uvcToast.dart';

class CheckPermissions extends StatefulWidget {
  @override
  _CheckPermissionsState createState() => _CheckPermissionsState();
}

class _CheckPermissionsState extends State<CheckPermissions> with TickerProviderStateMixin {
  ToastyMessage myUvcToast;

  bool firstDisplayMainWidget = true;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    myUvcToast = ToastyMessage(toastContext: context);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.blue[400],
        appBar: AppBar(
          title: const Text('Permissions'),
          centerTitle: true,
        ),
        body: Container(
          decoration: BoxDecoration(color: Colors.grey[200]),
          child: Builder(
            builder: (context) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Merci de vous connecter à internet pour que l\'application fonctionne correctement.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    Image.asset(
                      'assets/telephone-internet.gif',
                      height: screenHeight * 0.3,
                      width: screenWidth * 0.8,
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    FlatButton(
                      color: Colors.blue[400],
                      child: Text(
                        'COMPRIS',
                        style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/Qr_code_Generate');
                      },
                    ),
                    SizedBox(height: screenHeight * 0.05),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      onWillPop: () => stopActivity(context),
    );
  }

  Future<void> stopActivity(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Attention'),
        content: Text('Voulez-vous vraiment quitter l\'application ?'),
        actions: [
          FlatButton(
            child: Text('Oui'),
            onPressed: () {
              Navigator.pop(c, true);
            },
          ),
          FlatButton(
            child: Text('Non'),
            onPressed: () => Navigator.pop(c, false),
          ),
        ],
      ),
    );
  }
}