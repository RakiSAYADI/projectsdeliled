import 'package:flutter/material.dart';
import 'package:flutter_app_dmx_maestro/services/DataVariables.dart';

class MyCustomWhiteContainer extends StatelessWidget {
  final BoxShape shape;
  final Widget child;
  final double radius;

  const MyCustomWhiteContainer({
    Key key,
    @required this.child,
    this.shape = BoxShape.circle,
    this.radius = 80.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final child = this.child ?? LimitedBox(maxWidth: 0.0, maxHeight: 0.0, child: ConstrainedBox(constraints: const BoxConstraints.expand()));
    BorderRadius borderRadius;
    if (shape == BoxShape.circle) {
      borderRadius = null;
    } else {
      borderRadius = BorderRadius.circular(radius);
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: shape,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Color(0xFF000000).withOpacity(0.45),
            blurRadius: 6,
            offset: Offset(0, 5), // changes position of shadow
          ),
        ],
      ),
      child: child,
    );
  }
}
