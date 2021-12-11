import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyTheme {
  static const primaryColor = Color(0xff3474e0);
  static const secondaryColor = Color(0xffee8b60);
  static const tertiaryColor = Colors.white;
  static final callColor = Color(0xff66BB6A);

  static final headline1 = GoogleFonts.poppins(
    textStyle: headline1,
    color: Color(0xff303030),
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );
  static final headline2 = GoogleFonts.poppins(
    textStyle: headline2,
    color: Color(0xff303030),
    fontSize: 22,
    fontWeight: FontWeight.w500,
  );
  static final headline3 = GoogleFonts.poppins(
    textStyle: headline3,
    color: Color(0xff303030),
    fontSize: 20,
    fontWeight: FontWeight.w500,
  );
  static final subtitle1 = GoogleFonts.poppins(
    textStyle: subtitle1,
    color: Color(0xff757575),
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );
  static final subtitle2 = GoogleFonts.poppins(
    textStyle: subtitle2,
    color: Color(0xff616161),
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );
  static final bodyText1 = GoogleFonts.poppins(
    textStyle: bodyText1,
    color: Color(0xff303030),
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );
  static final bodyText2 = GoogleFonts.poppins(
    textStyle: bodyText2,
    color: Color(0xff424242),
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );
}

class FFButtonWidget extends StatelessWidget {
  final Widget child;
  final ButtonStyle? options;
  final void Function()? onPressed;
  FFButtonWidget({required this.child, this.onPressed, this.options});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: child,
      onPressed: onPressed,
      style: options,
    );
  }

  static ButtonStyle styleFrom(
      {double? width,
      double? height,
      Color? backgroundColor,
      double? elevation,
      TextStyle? textStyle,
      double? borderRadius,
      BorderSide? borderSide}) {
    return TextButton.styleFrom(
      fixedSize: Size(width ?? 150, height ?? 40),
      elevation: elevation,
      backgroundColor: backgroundColor,
      primary: textStyle?.color,
      textStyle: textStyle,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 0)),
        side: borderSide ??
            BorderSide(
              width: 0,
              color: Color(0x003474E0),
            ),
      ),
    );
  }
}

class CommingSoonWidget extends StatelessWidget {
  final String msg;
  CommingSoonWidget({Key? key, this.msg = ''}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child: FittedBox(child: Text('Comming soon!\n($msg)')));
  }
}
