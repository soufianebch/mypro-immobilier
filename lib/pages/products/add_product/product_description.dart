import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mypro_immobilier/pages/products/add_product/product_add_contact.dart';
import 'package:mypro_immobilier/providers/products.dart';
import 'package:mypro_immobilier/shared/my_theme.dart';

class AddDescriptionScreen extends StatefulWidget {
  static const routeName = 'add-description';
  @override
  _AddDescriptionScreenState createState() => _AddDescriptionScreenState();
}

class _AddDescriptionScreenState extends State<AddDescriptionScreen> {
  late final Product newProduct;
  final _formKey = GlobalKey<FormState>();
  final FocusNode _descriptionFocusNode = FocusNode();
  final FocusNode _descriptionArFocusNode = FocusNode();
  late TextEditingController titleController;
  late TextEditingController titleArController;
  late TextEditingController descriptionController;
  late TextEditingController descriptionArController;
  late TextEditingController prixController;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool init = true;
  @override
  void didChangeDependencies() {
    if (init) {
      newProduct = ModalRoute.of(context)!.settings.arguments as Product;
      titleController = TextEditingController(text: newProduct.title ?? newProduct.generateTitle());
      titleArController = TextEditingController(text: newProduct.title_ar ?? newProduct.generateTitleAr());
      descriptionController =
          TextEditingController(text: newProduct.description ?? newProduct.generateDescription());
      descriptionArController =
          TextEditingController(text: newProduct.description_ar ?? newProduct.generateDescriptionAr());
      prixController = MoneyMaskedTextController(
          initialValue: newProduct.prix ?? 0.0,
          decimalSeparator: ',',
          thousandSeparator: ' ');
      init = false;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    titleController.dispose();
    titleArController.dispose();
    descriptionController.dispose();
    descriptionArController.dispose();
    prixController.dispose();
    _descriptionFocusNode.dispose();
    _descriptionArFocusNode.dispose();
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
            'Description',
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
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  newProduct.title=titleController.text;
                  newProduct.title_ar=titleArController.text;
                  newProduct.description=descriptionController.text;
                  newProduct.description_ar=descriptionArController.text;
                  Navigator.of(context).pushNamed(
                      SelectProductContact.routeName,
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
      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.always,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 30, 0, 20),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(60, 10, 60, 70),
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      onChanged: (value) {
                        descriptionController.text=descriptionController.text.replaceRange(descriptionController.text.indexOf('Prix:'), descriptionController.text.indexOf('Dhs')+3, 'Prix: ${prixController.text.split(',')[0]} Dhs');
                        descriptionArController.text=descriptionArController.text.replaceRange(descriptionArController.text.indexOf('التمن:'), descriptionArController.text.indexOf('درهم')+4, 
                        'التمن: ${prixController.text.split(',')[0].replaceAll(' ', '.')} درهم');
                        newProduct.prix = double.parse(prixController.text
                            .replaceAll(',', '.')
                            .replaceAll(' ', ''));
                      },
                      controller: prixController,
                      obscureText: false,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        labelText: 'Dhs',
                        labelStyle:
                            Theme.of(context).textTheme.bodyText1!.copyWith(
                                  fontFamily: 'Poppins',
                                ),
                        hintStyle:
                            Theme.of(context).textTheme.bodyText1!.copyWith(
                                  fontFamily: 'Poppins',
                                  color: Colors.grey[400],
                                ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: MyTheme.secondaryColor,
                            width: 2,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4.0),
                            topRight: Radius.circular(4.0),
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: MyTheme.secondaryColor,
                            width: 2,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4.0),
                            topRight: Radius.circular(4.0),
                          ),
                        ),
                        contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      ),
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            fontFamily: 'Poppins',
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0,top: 20),
                    child: Text('Francais:',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500),),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: TextFormField(
                      onChanged: (value) =>
                          setState(() => newProduct.title = value),
                      onFieldSubmitted: (value) => FocusScope.of(context)
                          .requestFocus(_descriptionFocusNode),
                      controller: titleController,
                      maxLength: 50,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp('[!=":;_,%+]'))
                      ],
                      maxLengthEnforcement:
                          MaxLengthEnforcement.none,
                      validator: (value) => (value == null ||
                              value.length < 10 ||
                              value.length > 50)
                          ? 'Titre doit etre entre 10 et 50 caractères.'
                          : null,
                      obscureText: false,
                      decoration: InputDecoration(
                        hintText: 'Titre de l\'annonce*',
                        hintStyle:
                            Theme.of(context).textTheme.bodyText1!.copyWith(
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
                        suffixIcon: titleController.text.isNotEmpty
                            ? InkWell(
                                onTap: () => setState(
                                  () => titleController.clear(),
                                ),
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
                    ),
                  ),
                  
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: TextFormField(
                      focusNode: _descriptionFocusNode,
                      onChanged: (value) =>
                          setState(() => newProduct.description = value),
                      controller: descriptionController,
                      obscureText: false,
                      validator: (value) => value == null || value.length < 10
                          ? 'Minimum 10 caractères.'
                          : null,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText: 'Texte de l’annonce*',
                        hintStyle:
                            Theme.of(context).textTheme.bodyText1!.copyWith(
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
                        suffixIcon: descriptionController.text.isNotEmpty
                            ? InkWell(
                                onTap: () => setState(
                                  () => descriptionController.clear(),
                                ),
                                child: Icon(
                                  Icons.clear,
                                  size: 20,
                                ),
                              )
                            : null,
                      ),
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            fontFamily: 'Poppins',
                          ),
                      maxLines: 10,
                      keyboardType: TextInputType.multiline,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0,top: 20),
                    child: Text('Arabe:',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500),),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: TextFormField(
                      onChanged: (value) =>
                          setState(() => newProduct.title_ar = value),
                      onFieldSubmitted: (value) => FocusScope.of(context)
                          .requestFocus(_descriptionArFocusNode),
                      controller: titleArController,
                      maxLength: 50,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp('[!=":;_,%+]'))
                      ],
                      maxLengthEnforcement:
                          MaxLengthEnforcement.none,
                      validator: (value) => (value == null ||
                              value.length < 10 ||
                              value.length > 50)
                          ? 'Titre doit etre entre 10 et 50 caractères.'
                          : null,
                      obscureText: false,
                      decoration: InputDecoration(
                        hintText: 'Titre de l\'annonce*',
                        hintStyle:
                            Theme.of(context).textTheme.bodyText1!.copyWith(
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
                        suffixIcon: titleArController.text.isNotEmpty
                            ? InkWell(
                                onTap: () => setState(
                                  () => titleArController.clear(),
                                ),
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
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: TextFormField(
                      focusNode: _descriptionArFocusNode,
                      onChanged: (value) =>
                          setState(() => newProduct.description_ar = value),
                      controller: descriptionArController,
                      obscureText: false,
                      validator: (value) => value == null || value.length < 10
                          ? 'Minimum 10 caractères.'
                          : null,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText: 'Texte de l’annonce*',
                        hintStyle:
                            Theme.of(context).textTheme.bodyText1!.copyWith(
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
                        suffixIcon: descriptionArController.text.isNotEmpty
                            ? InkWell(
                                onTap: () => setState(
                                  () => descriptionArController.clear(),
                                ),
                                child: Icon(
                                  Icons.clear,
                                  size: 20,
                                ),
                              )
                            : null,
                      ),
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            fontFamily: 'Poppins',
                          ),
                      maxLines: 10,
                      keyboardType: TextInputType.multiline,
                    ),
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
