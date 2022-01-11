import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:async' show Future;

import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as img;

class HexImageString {
  String hexImage;
  double totalBytes;
  double widthBytes;

  HexImageString({@required this.hexImage, @required this.totalBytes, @required this.widthBytes});
}

class ZPLConverter {
  int blackLimit = 380;
  bool compressHex = false;
  int total;
  int widthBytes;
  int printerWidth = 609;
  int printerHeight = 406;
  int printerResolution = 203;
  final Map<int, String> mapCode = {
    1: 'G',
    2: 'H',
    3: 'I',
    4: 'J',
    5: 'K',
    6: 'L',
    7: 'M',
    8: 'N',
    9: 'O',
    10: 'P',
    11: 'Q',
    12: 'R',
    13: 'S',
    14: 'T',
    15: 'U',
    16: 'V',
    17: 'W',
    18: 'X',
    19: 'Y',
    20: 'g',
    40: 'h',
    60: 'i',
    80: 'j',
    100: 'k',
    120: 'l',
    140: 'm',
    160: 'n',
    180: 'o',
    200: 'p',
    220: 'q',
    240: 'r',
    260: 's',
    280: 't',
    300: 'u',
    320: 'v',
    340: 'w',
    360: 'x',
    380: 'y',
    400: 'z'
  };

  Future<String> convertImgToZpl(Uint8List imageAsU8) async {
    HexImageString tuple = await _getHexBody(imageAsU8);
    if (compressHex) tuple.hexImage = _encodeHexAscii(tuple.hexImage);
    return _headDoc() + tuple.hexImage + _footDoc();
  }

  void setBlacknessLimitPercentage(int percentage) {
    blackLimit = (percentage * 768 ~/ 100);
  }

  void setCompressHex(bool compressHex) {
    this.compressHex = compressHex;
  }

  void setPrinterWidth(int width) {
    this.printerWidth = width;
  }

  void setPrinterHeight(int height) {
    this.printerHeight = height;
  }

  Future<HexImageString> _getHexBody(Uint8List imageAsU8) async {
    var photo = img.decodeImage(imageAsU8);
    if (printerWidth > printerHeight) {
      photo = img.copyResize(photo, height: printerWidth, width: printerHeight);
      photo = img.copyRotate(photo, 270);
    } else {
      photo = img.copyResize(photo, width: printerWidth, height: printerHeight);
    }

    int width = photo.width;
    int height = photo.height;
    widthBytes = width ~/ 8;
    if (width % 8 > 0) {
      widthBytes = (((width / 8).floor()) + 1);
    } else {
      widthBytes = width ~/ 8;
    }
    total = widthBytes * height;
    int index = 0;
    var colorByte = ['0', '0', '0', '0', '0', '0', '0', '0'];
    var hexString = '';
    for (int h = 0; h < height; h++) {
      for (int w = 0; w < width; w++) {
        var rgb = photo?.getPixelSafe(w, h);
        var red = (rgb >> 16) & 0x000000FF;
        var green = (rgb >> 8) & 0x000000FF;
        var blue = (rgb) & 0x000000FF;
        var currentChar = '1';
        int totalColor = red + green + blue;
        if (totalColor > blackLimit) {
          currentChar = '0';
        }
        colorByte[index] = currentChar;
        index++;
        if (index == 8 || w == (width - 1)) {
          hexString += _fourByteBinary(colorByte.join());
          colorByte = ['0', '0', '0', '0', '0', '0', '0', '0'];
          index = 0;
        }
      }
      hexString += "\n";
    }
    return HexImageString(hexImage: hexString, totalBytes: total.toDouble(), widthBytes: widthBytes.toDouble());
  }

  String _headDoc() => "^XA " + "^PW600^LL400^PON^GFA, $total , $total , $widthBytes , ";

  String _footDoc() => "^FS" + "^XZ";

  String _encodeHexAscii(String code) {
    int maxLinea = widthBytes * 2;
    StringBuffer sbCode = new StringBuffer();
    StringBuffer sbLinea = new StringBuffer();
    String previousLine = null;
    int counter = 1;
    String aux = code[0];
    bool firstChar = false;
    for (int i = 1; i < code.length; i++) {
      if (firstChar) {
        aux = code[i];
        firstChar = false;
        continue;
      }
      if (code[i] == '\n') {
        if (counter >= maxLinea && aux == '0') {
          sbLinea.write(",");
        } else if (counter >= maxLinea && aux == 'F') {
          sbLinea.write("!");
        } else if (counter > 20) {
          int multi20 = (counter ~/ 20) * 20;
          int rest20 = (counter % 20);
          sbLinea.write(mapCode[multi20]);
          if (rest20 != 0) {
            sbLinea.write(mapCode[rest20] + aux);
          } else {
            sbLinea.write(aux);
          }
        } else {
          sbLinea.write(mapCode[counter] + aux);
          if (mapCode[counter] == null) {}
        }
        counter = 1;
        firstChar = true;
        if (sbLinea.toString() == (previousLine)) {
          sbCode.write(":");
        } else {
          sbCode.write(sbLinea.toString());
        }
        previousLine = sbLinea.toString();
        sbLinea.clear();
        continue;
      }
      if (aux == code[i]) {
        counter++;
      } else {
        if (counter > 20) {
          int multi20 = (counter ~/ 20) * 20;
          int rest20 = (counter % 20);

          sbLinea.write(mapCode[multi20]);
          if (rest20 != 0) {
            sbLinea.write(mapCode[rest20] + aux);
          } else {
            sbLinea.write(aux);
          }
        } else {
          sbLinea.write(mapCode[counter] + aux);
        }
        counter = 1;
        aux = code[i];
      }
    }
    return sbCode.toString();
  }

  String _fourByteBinary(String binaryStr) {
    int decimal = int.parse(binaryStr, radix: 2);
    if (decimal > 15) {
      return decimal.toRadixString(16).toUpperCase();
    } else {
      return '0' + decimal.toRadixString(16).toUpperCase();
    }
  }
}
