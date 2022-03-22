import 'package:flutter/material.dart';
import 'package:flutter_app_dmx_maestro/services/DataVariables.dart';

class MyIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final BoxShape shape;
  final Widget icon;
  final Color iconColor;

  const MyIconButton({
    Key key,
    @required this.onPressed,
    @required this.icon,
    this.iconColor,
    this.shape = BoxShape.circle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconColorFinal = this.iconColor ?? Colors.white;
    final shapeFinal = this.shape ?? BoxShape.circle;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: modeColor[backGroundColorSelect]),
        shape: shapeFinal,
        boxShadow: [
          BoxShadow(
            color: Color(0xFF000000).withOpacity(0.45),
            blurRadius: 6,
            offset: Offset(0, 5), // changes position of shadow
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        color: iconColorFinal,
        icon: icon,
      ),
    );
  }
}
