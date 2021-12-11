import 'package:flutter/material.dart';
import 'package:mypro_immobilier/pages/products/add_product/product_select_city.dart';
import 'package:mypro_immobilier/shared/my_varriables.dart';
import 'package:mypro_immobilier/providers/products.dart';
import 'package:mypro_immobilier/shared/my_theme.dart';

class SelectTypeDeBienScreen extends StatefulWidget {
  static const routeName = '/type-de-bien';
  @override
  _SelectTypeDeBienWidgeScreen createState() => _SelectTypeDeBienWidgeScreen();
}

class _SelectTypeDeBienWidgeScreen extends State<SelectTypeDeBienScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final newProduct = ModalRoute.of(context)!.settings.arguments as Product;
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: MyTheme.tertiaryColor,
        automaticallyImplyLeading: false,
        leading: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(),
          child: IconButton(
            onPressed: () async {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_outlined,
              color: Colors.black,
              size: 30,
            ),
            iconSize: 30,
          ),
        ),
        title: FittedBox(
          child: Text(
            'Type de bien',
            style: Theme.of(context).textTheme.headline3!.copyWith(
                  fontFamily: 'Poppins',
                ),
          ),
        ),
        actions: [],
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Wrap(
          children: [
            Container(
              height: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  100,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: MyVarriables.typesDeBien
                    .map((text) => Padding(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: FFButtonWidget(
                            onPressed: () {
                              newProduct.typedebien = text;
                              Navigator.of(context).pushNamed(
                                  SelectVilleScreen.routeName,
                                  arguments: newProduct);
                            },
                            child: Text(text),
                            options: FFButtonWidget.styleFrom(
                              width: double.infinity,
                              height: 50,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .subtitle2!
                                  .copyWith(
                                    fontFamily: 'Poppins',
                                    color: MyTheme.secondaryColor,
                                  ),
                              elevation: 0,
                              borderSide: BorderSide(
                                color: MyTheme.tertiaryColor,
                                width: 0,
                              ),
                              borderRadius: 0,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
