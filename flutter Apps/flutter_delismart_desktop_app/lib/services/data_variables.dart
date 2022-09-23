import 'package:flutter_delismart_desktop_app/classes/tuya_token.dart';
import 'package:flutter_delismart_desktop_app/services/request_api.dart';

const String appName = 'DeliSmart';

String languageCode = 'fr';
int languageArrayIdentifier = 0;

const String url = 'https://openapi.tuyaeu.com';
const String clientId = 'qdkwarm5edyqy7cpvx9d';
const String secret = 'dffb252cae434376a7ed10084d021130';
const String signMethod = 'HMAC-SHA256';
const String nonce = '';
const String schema = 'applicationsdelismartoemapp';

const emptyBodyEncrypted = 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';

const String getMethod = 'GET';
const String postMethod = 'POST';
const String putMethod = 'PUT';
const String deleteMethod = 'DELETE';

bool requestResponse = false;

String easySign = '';
String easyAccessToken = '';
String easyRefreshToken = '';

List<String> uidList = [];
List<String> homeIds = [];
List<String> roomIds = [];
List<String> groupId = [];

final TokenClass tokenClass = TokenClass();

final APIRequest tokenAPIRequest = APIRequest();
