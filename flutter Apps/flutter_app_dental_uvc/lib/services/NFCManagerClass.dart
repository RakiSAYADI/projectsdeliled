/*import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';

class NFCManager {
  void readNFCTags() {
    FlutterNfcReader.read().then((response) {
      print(response.content);
    });
  }

  void readOneNFCTag() async{
    FlutterNfcReader.onTagDiscovered().listen((onData) {
      print(onData.id);
      print(onData.content);
    });
  }

*//*  void writeNFCTags(){
    Stream<NDEFMessage> stream = NFC.readNDEF();

    stream.listen((NDEFMessage message) {
      NDEFMessage newMessage = NDEFMessage.withRecords(
          NDEFRecord.mime("text/plain", "hello world")
      );
      message.tag.write(newMessage);
    });
  }

  void writeOneNFCTag(){
    NDEFMessage newMessage = NDEFMessage.withRecords(
        NDEFRecord.mime("text/plain", "hello world")
    );
    Stream<NDEFTag> stream = NFC.writeNDEF(newMessage);

    stream.listen((NDEFTag tag) {
      print("wrote to tag");
    });
  }*//*
}*/
