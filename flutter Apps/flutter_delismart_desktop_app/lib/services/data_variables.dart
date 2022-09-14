import 'dart:io';

const String appName = 'DeliSmart';

String languageCode = 'fr';
int languageArrayIdentifier = 0;

Future<bool> hasNetwork() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (_) {
    return false;
  }
}
