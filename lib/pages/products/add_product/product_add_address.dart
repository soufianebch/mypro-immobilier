import 'package:flutter/material.dart';
import 'package:mypro_immobilier/pages/products/add_product/product_add_detailes.dart';
import 'package:mypro_immobilier/providers/products.dart';
import 'package:mypro_immobilier/shared/my_theme.dart';

class AddAddressScreen extends StatefulWidget {
  static const routeName = 'add-address';
  @override
  _AddAddressScreenState createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  late final Product newProduct;
  late TextEditingController textController;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool init = true;
  @override
  void didChangeDependencies() {
    if (init) {
      newProduct = ModalRoute.of(context)!.settings.arguments as Product;
      newProduct.address = newProduct.address ?? 'Lot Alliance Mehdia';
      textController = TextEditingController(text: newProduct.address);
      init = false;
      super.didChangeDependencies();
    }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
            'Adresse',
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
                      AddDetailsDuBienScreen.routeName,
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: SafeArea(
          child: Form(
            child: Container(
              alignment: Alignment.center,
              height: 300,
              child: Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: TextFormField(
                  onChanged: (value) =>
                      setState(() => newProduct.address = value),
                  controller: textController,
                  obscureText: false,
                  decoration: InputDecoration(
                    hintText: 'Num??ro et nom de la rue',
                    hintStyle: Theme.of(context).textTheme.bodyText1!.copyWith(
                          fontFamily: 'Poppins',
                          color: Colors.grey[400],
                        ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                        width: 2,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4.0),
                        topRight: Radius.circular(4.0),
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                        width: 2,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4.0),
                        topRight: Radius.circular(4.0),
                      ),
                    ),
                    filled: true,
                    suffixIcon: textController.text.isNotEmpty
                        ? InkWell(
                            onTap: () => setState(() {
                              textController.clear();
                              newProduct.address = '';
                            }),
                            child: Icon(
                              Icons.clear,
                              size: 24,
                            ),
                          )
                        : null,
                  ),
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        fontFamily: 'Poppins',
                      ),
                  maxLines: 1,
                  keyboardType: TextInputType.streetAddress,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
