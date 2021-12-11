import 'package:flutter/material.dart';
import 'package:mypro_immobilier/components/detailles_suplementaire_list_widget.dart';
import 'package:mypro_immobilier/pages/products/add_product/product_description.dart';
import 'package:mypro_immobilier/providers/products.dart';
import 'package:mypro_immobilier/shared/my_theme.dart';

class SelectDetaillesSuplementaireScreen extends StatefulWidget {
  static const routeName = 'select-details-suplementaire';

  @override
  _SelectDetaillesSuplementaireScreenState createState() =>
      _SelectDetaillesSuplementaireScreenState();
}

class _SelectDetaillesSuplementaireScreenState
    extends State<SelectDetaillesSuplementaireScreen> {
  @override
  Widget build(BuildContext context) {
    final newProduct = ModalRoute.of(context)!.settings.arguments as Product;
    return Scaffold(
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
            'Détails supplémentaires',
            style: Theme.of(context).textTheme.headline3!.copyWith(
                  fontFamily: 'Poppins',
                ),
          ),
        ),
        actions: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(),
            child: Align(
              alignment: Alignment(0.85, 0),
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                      AddDescriptionScreen.routeName,
                      arguments: newProduct);
                },
                icon: Icon(
                  Icons.arrow_forward_outlined,
                  color: Colors.black,
                  size: 31,
                ),
                iconSize: 31,
              ),
            ),
          )
        ],
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: SingleChildScrollView(
            child: DetaillesSuplementaireListWidget(product: newProduct),
          ),
        ),
      ),
    );
  }
}
