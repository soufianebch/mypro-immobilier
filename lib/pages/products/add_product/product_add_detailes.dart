import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mypro_immobilier/pages/products/add_product/product_other_detailes.dart';
import 'package:mypro_immobilier/providers/products.dart';
import 'package:mypro_immobilier/shared/my_theme.dart';

class AddDetailsDuBienScreen extends StatefulWidget {
  static const routeName = 'add-details';
  @override
  _AddDetailsDuBienScreenState createState() => _AddDetailsDuBienScreenState();
}

class _AddDetailsDuBienScreenState extends State<AddDetailsDuBienScreen> {
  late final Product newProduct;
  late TextEditingController nChambreController;
  late TextEditingController nbrSalleDeBainController;
  late TextEditingController nbrCuisineController;
  late TextEditingController nSalonsController;
  late TextEditingController nBalconsController;
  late TextEditingController nFacadesController;
  late TextEditingController nbrEtageController;
  late TextEditingController surfaceTotalController;
  late TextEditingController surfaceHabitableController;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  bool init = true;
  @override
  void didChangeDependencies() {
    if (init) {
      newProduct = ModalRoute.of(context)!.settings.arguments as Product;
      nChambreController =
          TextEditingController(text: '${newProduct.nbrChambres ?? ''}');
      nbrSalleDeBainController =
          TextEditingController(text: '${newProduct.nbrSallesDeBain ?? ''}');
      nbrCuisineController =
          TextEditingController(text: '${newProduct.nbrCuisine ?? ''}');
      nSalonsController =
          TextEditingController(text: '${newProduct.nbrSalons ?? ''}');
      nBalconsController =
          TextEditingController(text: '${newProduct.nbrBalcons ?? ''}');
      nFacadesController =
          TextEditingController(text: '${newProduct.nbrFacades ?? ''}');
      nbrEtageController =
          TextEditingController(text: '${newProduct.nbrEtage ?? ''}');
      surfaceTotalController = TextEditingController(
          text: '${newProduct.surfaceTotal?.toStringAsFixed(0) ?? ''}');
      surfaceHabitableController = TextEditingController(
          text: '${newProduct.surfaceHabitable?.toStringAsFixed(0) ?? ''}');
      init = false;
      super.didChangeDependencies();
    }
  }
  @override
  void dispose() {
    nChambreController.dispose();
    nbrSalleDeBainController.dispose();
    nbrCuisineController.dispose();
    nSalonsController.dispose();
    nBalconsController.dispose();
    nFacadesController.dispose();
    nbrEtageController.dispose();
    surfaceTotalController.dispose();
    surfaceHabitableController.dispose();
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
            'Détails du bien',
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
                  if (!_formKey.currentState!.validate()) return;
                  newProduct.nbrChambres = int.parse(nChambreController.text);
                  newProduct.nbrSallesDeBain =
                      int.parse(nbrSalleDeBainController.text);
                  newProduct.nbrCuisine =
                      int.parse(nbrCuisineController.text);
                  newProduct.nbrSalons = int.parse(nSalonsController.text);
                  newProduct.nbrBalcons = int.parse(nBalconsController.text);
                  newProduct.nbrFacades = int.parse(nFacadesController.text);
                  newProduct.nbrEtage = int.parse(nbrEtageController.text);
                  newProduct.surfaceTotal =
                      double.parse(surfaceTotalController.text);
                  newProduct.surfaceHabitable =
                      double.parse(surfaceHabitableController.text);
                  Navigator.of(context).pushNamed(
                      SelectDetaillesSuplementaireScreen.routeName,
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
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.always,
            child: Container(
              // padding: const EdgeInsets.only(top: 5.0),
              // margin: const EdgeInsets.only(bottom: 5.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AddDetailsFielsWidget(
                    fieldController: nChambreController,
                    text: 'Chambres:',
                    hintText: '1',
                  ),
                  AddDetailsFielsWidget(
                    fieldController: nbrSalleDeBainController,
                    text: 'Salle de bain:',
                    hintText: '1',
                  ),
                  AddDetailsFielsWidget(
                    fieldController: nbrCuisineController,
                    text: 'Cuisine:',
                    hintText: '1',
                  ),
                  AddDetailsFielsWidget(
                    fieldController: nSalonsController,
                    text: 'Salons:',
                    hintText: '1',
                  ),
                  AddDetailsFielsWidget(
                    fieldController: nBalconsController,
                    text: 'Balcons:',
                    hintText: '1',
                  ),
                  AddDetailsFielsWidget(
                    fieldController: nFacadesController,
                    text: 'Facades:',
                    hintText: '1',
                  ),
                  AddDetailsFielsWidget(
                    fieldController: nbrEtageController,
                    text: 'Étages:',
                    labelText: 'R+',
                  ),
                  AddDetailsFielsWidget(
                    fieldController: surfaceTotalController,
                    text: 'Surface totale:',
                    labelText: 'm²',
                  ),
                  AddDetailsFielsWidget(
                    fieldController: surfaceHabitableController,
                    text: 'Surface habitable:',
                    labelText: 'm²',
                    textInputAction: TextInputAction.done,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AddDetailsFielsWidget extends StatelessWidget {
  AddDetailsFielsWidget({
    Key? key,
    required this.fieldController,
    required this.text,
    this.hintText,
    this.labelText,
    this.textInputAction=TextInputAction.next,
  }) : super(key: key);

  final String? labelText;
  final String text;
  final String? hintText;
  final TextEditingController fieldController;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                text,
                style: Theme.of(context).textTheme.headline2!.copyWith(
                      fontFamily: 'Poppins',
                    ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment(0, -0.2),
              child: Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: TextFormField(
                  textInputAction: textInputAction,
                  validator: (value) => value == '' ? '' : null,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  controller: fieldController,
                  obscureText: false,
                  decoration: InputDecoration(
                    errorStyle: TextStyle(
                      fontSize: 0,
                      height: 0,
                    ),
                    isDense: true,
                    hintText: hintText,
                    labelText: labelText,
                    hintStyle: Theme.of(context).textTheme.bodyText1!.copyWith(
                          fontFamily: 'Poppins',
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[400],
                        ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: MyTheme.secondaryColor,
                        width: 1,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4.0),
                        topRight: Radius.circular(4.0),
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: MyTheme.secondaryColor,
                        width: 1,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4.0),
                        topRight: Radius.circular(4.0),
                      ),
                    ),
                    contentPadding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                  ),
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        fontFamily: 'Poppins',
                        fontStyle: FontStyle.italic,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
