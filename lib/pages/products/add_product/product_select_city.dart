import 'package:flutter/material.dart';
import 'package:mypro_immobilier/pages/products/add_product/product_add_address.dart';
import 'package:mypro_immobilier/shared/my_varriables.dart';
import 'package:mypro_immobilier/providers/products.dart';
import 'package:mypro_immobilier/shared/my_theme.dart';

class SelectVilleScreen extends StatefulWidget {
  static const routeName = 'select-ville';
  @override
  _SelectVilleWidgeScreen createState() => _SelectVilleWidgeScreen();
}

class _SelectVilleWidgeScreen extends State<SelectVilleScreen>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  // final _scrollController = ScrollController();
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
            'Ville',
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
                children: MyVarriables.villes.entries
                    .map((e) => Column(
                          children: [
                            Container(
                              width: double.infinity,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                child: FFButtonWidget(
                                  onPressed: () {
                                    setState(() {
                                      newProduct.ville = e.key;
                                    });
                                  },
                                  child: Text(e.key),
                                  options: FFButtonWidget.styleFrom(
                                    width: double.infinity,
                                    height: 50,
                                    backgroundColor: e.key == newProduct.ville
                                        ? MyTheme.secondaryColor
                                            .withOpacity(0.15)
                                        : null,
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
                              ),
                            ),
                            AnimatedSize(
                              curve: Curves.fastOutSlowIn,
                              vsync: this,
                              duration: Duration(seconds: 2),
                              child: MyVarriables.villes[e.key]!.length < 1
                                  ? Container(
                                      alignment: Alignment.topCenter,
                                      width: double.infinity,
                                      height:
                                          e.key == newProduct.ville ? 300 : 0,
                                      child: Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 10, 0, 10),
                                        child: FFButtonWidget(
                                          onPressed: () {
                                            // newProduct.secteur =
                                            //     MyVarriables.villes[e.key]![index];
                                            Navigator.of(context).pushNamed(
                                                AddAddressScreen.routeName,
                                                arguments: newProduct);
                                          },
                                          child: Text(' - '),
                                          options: FFButtonWidget.styleFrom(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: 50,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .subtitle2!
                                                .copyWith(
                                                  fontFamily: 'Poppins',
                                                  color: MyTheme.primaryColor,
                                                  fontSize: 35,
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
                                  : Container(
                                      alignment: Alignment.center,
                                      width: double.infinity,
                                      height:
                                          e.key == newProduct.ville ? 300 : 0,
                                      child: Scrollbar(
                                        // controller: _scrollController,
                                        interactive: true,
                                        isAlwaysShown: true,
                                        child: ListView.builder(
                                          itemCount: MyVarriables
                                              .villes[e.key]!.length,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 10, 0, 10),
                                              child: FFButtonWidget(
                                                onPressed: () {
                                                  newProduct.secteur =
                                                      MyVarriables.villes[
                                                          e.key]![index];
                                                  Navigator.of(context)
                                                      .pushNamed(
                                                          AddAddressScreen
                                                              .routeName,
                                                          arguments:
                                                              newProduct);
                                                },
                                                child: Text(MyVarriables
                                                    .villes[e.key]![index]),
                                                options:
                                                    FFButtonWidget.styleFrom(
                                                  width: double.infinity,
                                                  height: 50,
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .subtitle2!
                                                      .copyWith(
                                                        fontFamily: 'Poppins',
                                                        color: MyTheme
                                                            .primaryColor,
                                                      ),
                                                  elevation: 0,
                                                  borderSide: BorderSide(
                                                    color:
                                                        MyTheme.tertiaryColor,
                                                    width: 0,
                                                  ),
                                                  borderRadius: 0,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                            )
                          ],
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
