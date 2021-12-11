import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mypro_immobilier/providers/auth.dart';
import 'package:mypro_immobilier/shared/my_theme.dart';
import 'package:provider/provider.dart';

class AuthenticateScreen extends StatefulWidget {
  AuthenticateScreen({Key? key}) : super(key: key);

  @override
  _AuthenticateScreenState createState() => _AuthenticateScreenState();
}

class _AuthenticateScreenState extends State<AuthenticateScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _waiting = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: MyTheme.tertiaryColor,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 1,
        decoration: BoxDecoration(
          color: MyTheme.tertiaryColor,
          image: DecorationImage(
            fit: BoxFit.none,
            image: AssetImage(
              'assets/images/auth_bg.jpg',
            ),
          ),
        ),
        child: Align(
          alignment: Alignment(0, 1),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(0, 70, 0, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 240,
                decoration: BoxDecoration(
                  color: MyTheme.tertiaryColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 16, 0),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: MyTheme.tertiaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Color(0xFFDBE2E7),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(7, 6, 0, 0),
                                child: InkWell(
                                  // onTap: () async {
                                  //   Navigator.pop(context);
                                  // },
                                  child: FaIcon(
                                    FontAwesomeIcons.google,
                                    color: Color(0xFF090F13),
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Sign In',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline1!
                                  .copyWith(
                                    fontFamily: 'Poppins',
                                  ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 60, 20, 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FFButtonWidget(
                            onPressed: () async {
                              setState(() {
                                _waiting = true;
                              });

                              final auth =
                                  Provider.of<Auth>(context, listen: false);
                              await auth.googleLogin();
                              // final googleDrive = Provider.of<GoogleDrive>(
                              //     context,
                              //     listen: false);
                              // await googleDrive.initialise();
                              setState(() {
                                _waiting = false;
                              });
                            },
                            child: _waiting
                                ? Container(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator())
                                : Text('Sign In'),
                            options: FFButtonWidget.styleFrom(
                              width: 250,
                              height: 50,
                              backgroundColor: MyTheme.primaryColor,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .subtitle2!
                                  .copyWith(
                                    fontFamily: 'Poppins',
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                              elevation: 3,
                              borderSide: BorderSide(
                                color: Colors.transparent,
                                width: 1,
                              ),
                              borderRadius: 8,
                            ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment(Alignment.bottomCenter.x,
                            Alignment.bottomCenter.y - 0.2),
                        child: Text(
                          '@MYPRO_IMMOBILIER',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
