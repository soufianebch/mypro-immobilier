import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mypro_immobilier/components/detailles_suplementaire_list_widget.dart';
import 'package:mypro_immobilier/components/image_scroll_view_widget.dart';
import 'package:mypro_immobilier/components/product_more_actions_widget.dart';
import 'package:mypro_immobilier/providers/google_drive.dart';
import 'package:mypro_immobilier/shared/my_varriables.dart';
import 'package:mypro_immobilier/providers/products.dart';
import 'package:mypro_immobilier/shared/my_theme.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:provider/provider.dart';
import 'package:share_extend/share_extend.dart';

class ProductDetailsScreen extends StatefulWidget {
  static const routeName = '/product-details';
  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final Map<String, List<String>> villes = MyVarriables.villes;
  final _formKey = GlobalKey<FormState>();
  final _descriptionFocusNode = FocusNode();
  final _descriptionArFocusNode = FocusNode();
  Product product = Product();
  late GoogleDrive googleDrive;
  final pageViewController = PageController();
  late ImageScrollView imageScrollView;
  List<String> deleteList = [];
  late TextEditingController prixController;
  late TextEditingController titleController;
  late TextEditingController titleArController;
  late TextEditingController descriptionController;
  late TextEditingController descriptionArController;
  late TextEditingController textFieldController;
  late TextEditingController surfaceController;
  late TextEditingController nbrChambresController;
  late TextEditingController salleDeBainController;
  late TextEditingController nbrEtageController;
  late TextEditingController nbrSalonsController;
  late TextEditingController nbrCuisineController;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime? _longPressStart;
  double? _longPressDownloadProgress;
  bool isArabic=false;


  bool init = true;
  @override
  void didChangeDependencies() {
    if (init) {
      googleDrive = Provider.of<GoogleDrive>(context);
      product = (ModalRoute.of(context)!.settings.arguments as Product).clone;
      imageScrollView = ImageScrollView(
        product: product,
        pageViewController: pageViewController,
        callBack: () => setState(() {}),
        refresh: () => Navigator.of(context).pushReplacementNamed(
            ProductDetailsScreen.routeName,
            arguments: product),
      );
      product.ville = villes.containsKey(product.ville) ? product.ville : null;
      product.secteur = product.ville == null
          ? null
          : (villes[product.ville]!.contains(product.secteur)
              ? product.secteur
              : null);

      prixController = MoneyMaskedTextController(
          initialValue: product.prix ?? 0.0,
          decimalSeparator: ',',
          thousandSeparator: ' ');
      titleController = TextEditingController(text: product.title);
      titleArController = TextEditingController(text: product.title_ar);
      descriptionController = TextEditingController(text: product.description);
      descriptionArController = TextEditingController(text: product.description_ar);
      textFieldController = TextEditingController(text: product.address);
      surfaceController = TextEditingController(
          text: product.surfaceTotal == null
              ? '0'
              : product.surfaceTotal!.toStringAsFixed(0));
      nbrChambresController = TextEditingController(
          text: product.nbrChambres == null
              ? '0'
              : product.nbrChambres.toString());
      salleDeBainController = TextEditingController(
          text: product.nbrSallesDeBain == null
              ? '0'
              : product.nbrSallesDeBain.toString());
      nbrEtageController = TextEditingController(
          text: product.nbrEtage == null ? '0' : product.nbrEtage.toString());
      nbrSalonsController = TextEditingController(
          text: product.nbrSalons == null ? '0' : product.nbrSalons.toString());
      nbrCuisineController = TextEditingController(
          text: product.nbrCuisine == null ? '0' : product.nbrCuisine.toString());
      init = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
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
            product.typedebien ?? 'Produit',
            style: Theme.of(context).textTheme.headline3!.copyWith(
                  fontFamily: 'Poppins',
                  fontSize: 20,
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
                  product.address = textFieldController.text;
                  product.nbrChambres = int.parse(nbrChambresController.text);
                  product.nbrSallesDeBain =
                      int.parse(salleDeBainController.text);
                  product.nbrSalons = int.parse(nbrSalonsController.text);
                  product.nbrCuisine = int.parse(nbrCuisineController.text);
                  product.nbrEtage = int.parse(nbrEtageController.text);
                  product.surfaceTotal = double.parse(surfaceController.text);

                  product.title = titleController.text;
                  product.title_ar = titleArController.text;
                  product.description = descriptionController.text;
                  product.description_ar = descriptionArController.text;
                  product.prix = double.parse(prixController.text
                      .replaceAll(',', '.')
                      .replaceAll(' ', ''));
                  deleteList.forEach((imageId) {
                    googleDrive.deleteFileFromDrive(imageId).onError(
                        (error, stackTrace) => print(error.toString()));
                  });
                  product.changed = true;
                  product.reference!.update(product.toMap());
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.check,
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
      floatingActionButton: imageScrollView.deleteList.length > 0
          ? FloatingActionButton(
              onPressed: () async {
                imageScrollView.deleteList.forEach((imageIndex) {
                  final imageId = (product.images![imageIndex] as String)
                      .replaceAll(
                          'https://drive.google.com/uc?export=view&id=', '');

                  deleteList.add(imageId);
                });
                product.images!.removeWhere((imageLink) {
                  bool exist = false;
                  deleteList.forEach((imageId) {
                    if ((imageLink as String).replaceAll(
                            'https://drive.google.com/uc?export=view&id=',
                            '') ==
                        imageId) exist = true;
                  });
                  return exist;
                });

                setState(() {
                  imageScrollView.deleteList = [];
                  imageScrollView.pageViewController.animateToPage(0,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.ease);
                });
              },
              backgroundColor: Colors.red,
              elevation: 8,
              child: Icon(
                Icons.delete,
                color: Colors.white,
                size: 24,
              ),
            )
          : GestureDetector(
              onLongPressStart: (details) => _longPressStart = DateTime.now(),
              onLongPressMoveUpdate: (details) async {
                if (_longPressStart == null) return;
                final counter =
                    DateTime.now().difference(_longPressStart!).inSeconds;
                print(counter);
                if (counter > 5) {
                  _longPressStart = null;
                  print('Pass..');
                  Fluttertoast.showToast(
                    msg: "Pass!",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                  );
                  HapticFeedback.vibrate();
                  List<String> images = [];
                  Clipboard.setData(
                      ClipboardData(text: 'https://drive.google.com/folderview?id=${product.googleDriveFolderId}'));
                  Clipboard.setData(ClipboardData(text: '${product.prix}'));
                  Clipboard.setData(ClipboardData(text:''' 
▻▻▻▻▻▻ +212 628-921611 ◅◅◅◅◅◅
►WHATSAPP: https://wa.me/212628921611
►TELEPHONE: https://l.linklyhq.com/l/JlOd
►YOUTUBE: www.youtube.com/c/MYPROIMMOBILIER
#agence #immobilier #kenitra #appartement #شقة'
'''));
                  Clipboard.setData(ClipboardData(text: product.description));
                  Clipboard.setData(ClipboardData(text: product.title));
                  Clipboard.setData(ClipboardData(text: product.description_ar));
                  Clipboard.setData(ClipboardData(text: product.title_ar));
                  for (var image in product.images ?? []) {
                    final id = googleDrive.getIdfromLink(image);
                    final path = await googleDrive.downloadGoogleDriveFile(
                        fNameWithExt: '$id.png',
                        gdID: id,
                        callBack: (prg) =>
                            setState(() => _longPressDownloadProgress = prg));
                    if (path != null) images.add(path);
                  }
                  Fluttertoast.showToast(
                    msg: "Sharing..",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                  );
                  ShareExtend.shareMultiple(images, "image");
                  _longPressDownloadProgress = null;
                }
              },
              child: FloatingActionButton(
                onPressed: () async {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (context) {
                      return MoreActionsWidget(
                          contact: product.contact, product: product);
                      // MoreActionsWidget(
                      //   contact: product.entrepreneur,
                      //   product: product.reference,
                      // );
                    },
                  );
                },
                backgroundColor: MyTheme.primaryColor,
                elevation: 8,
                child: _longPressDownloadProgress == null
                    ? Icon(
                        Icons.more_vert,
                        color: Colors.white,
                        size: 24,
                      )
                    : Text(
                        '${_longPressDownloadProgress!.toStringAsFixed(0)}%',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: SafeArea(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.always,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  imageScrollView,
                  Padding(
                    padding: EdgeInsets.fromLTRB(40, 0, 40, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        
                        Padding(
                          padding: EdgeInsets.fromLTRB(60, 10, 60, 0),
                          child: TextFormField(
                            onChanged: (value) 
                            {
                              descriptionController.text =
                                descriptionController.text.replaceRange(
                                    descriptionController.text.indexOf('Prix:'),
                                    descriptionController.text.indexOf('Dhs') +
                                        3,
                                    'Prix: ${prixController.text.split(',')[0]} Dhs');
                                    descriptionArController.text =
                                descriptionArController.text.replaceRange(
                                    descriptionArController.text.indexOf('التمن:'),
                                    descriptionArController.text.indexOf('درهم') +
                                        4,
                                    'التمن: ${prixController.text.split(',')[0]} درهم');
                                    },
                            controller: prixController,
                            obscureText: false,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              labelText: 'Dhs',
                              labelStyle: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(
                                    fontFamily: 'Poppins',
                                    color: MyTheme.secondaryColor,
                                  ),
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.fromLTRB(10, 10, 10, 10),
                            ),
                            style:
                                Theme.of(context).textTheme.bodyText1!.copyWith(
                                      fontFamily: 'Poppins',
                                      color: MyTheme.secondaryColor,
                                    ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(icon: Icon(Icons.translate,size: 14,color: isArabic?Colors.blue:Colors.black,),onPressed: ()=>setState(()=>isArabic=isArabic==true?false:true),),
                          ],
                        ),
                        if(!isArabic)
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                          child: TextFormField(
                            onChanged: (_) => setState(() {}),
                            onFieldSubmitted: (_) => FocusScope.of(context)
                                .requestFocus(_descriptionFocusNode),
                            controller: titleController,
                            maxLength: 50,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(
                                  RegExp('[!=":;_,%+]'))
                            ],
                            maxLengthEnforcement: MaxLengthEnforcement
                                .truncateAfterCompositionEnds,
                            validator: (value) => (value == null ||
                                    value.length < 10 ||
                                    value.length > 50)
                                ? 'Titre doit etre entre 10 et 50 caractères.'
                                : null,
                            obscureText: false,
                            decoration: InputDecoration(
                              hintText: 'Titre de l\'annonce*',
                              hintStyle: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(
                                    fontFamily: 'Poppins',
                                    color: Colors.grey[400],
                                  ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 1,
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4.0),
                                  topRight: Radius.circular(4.0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 1,
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4.0),
                                  topRight: Radius.circular(4.0),
                                ),
                              ),
                              suffixIcon: titleController.text.isNotEmpty
                                  ? InkWell(
                                      onTap: () => setState(
                                        () => titleController.clear(),
                                      ),
                                      child: Icon(
                                        Icons.clear,
                                        size: 15,
                                      ),
                                    )
                                  : null,
                            ),
                            style:
                                Theme.of(context).textTheme.bodyText1!.copyWith(
                                      fontFamily: 'Poppins',
                                    ),
                            maxLines: 1,
                          ),
                        ),
                        if(isArabic)
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                          child: TextFormField(
                            onChanged: (_) => setState(() {}),
                            onFieldSubmitted: (_) => FocusScope.of(context)
                                .requestFocus(_descriptionArFocusNode),
                            controller: titleArController,
                            maxLength: 50,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(
                                  RegExp('[!=":;_,%+]'))
                            ],
                            maxLengthEnforcement: MaxLengthEnforcement
                                .truncateAfterCompositionEnds,
                            validator: (value) => (value == null ||
                                    value.length < 10 ||
                                    value.length > 50)
                                ? 'Titre doit etre entre 10 et 50 caractères.'
                                : null,
                            obscureText: false,
                            decoration: InputDecoration(
                              hintText: 'Titre de l\'annonce*',
                              hintStyle: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(
                                    fontFamily: 'Poppins',
                                    color: Colors.grey[400],
                                  ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 1,
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4.0),
                                  topRight: Radius.circular(4.0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 1,
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4.0),
                                  topRight: Radius.circular(4.0),
                                ),
                              ),
                              suffixIcon: titleArController.text.isNotEmpty
                                  ? InkWell(
                                      onTap: () => setState(
                                        () => titleArController.clear(),
                                      ),
                                      child: Icon(
                                        Icons.clear,
                                        size: 15,
                                      ),
                                    )
                                  : null,
                            ),
                            style:
                                Theme.of(context).textTheme.bodyText1!.copyWith(
                                      fontFamily: 'Poppins',
                                    ),
                            maxLines: 1,
                          ),
                        ),
                        if(!isArabic)
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: TextFormField(
                            focusNode: _descriptionFocusNode,
                            onChanged: (_) => setState(() {}),
                            controller: descriptionController,
                            obscureText: false,
                            validator: (value) =>
                                value == null || value.length < 10
                                    ? 'Minimum 10 caractères.'
                                    : null,
                            textInputAction: TextInputAction.newline,
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: 'Texte de l’annonce*',
                              hintStyle: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(
                                    fontFamily: 'Poppins',
                                    color: Colors.grey[400],
                                  ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 1,
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4.0),
                                  topRight: Radius.circular(4.0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 1,
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4.0),
                                  topRight: Radius.circular(4.0),
                                ),
                              ),
                              suffixIcon: descriptionController.text.isNotEmpty
                                  ? InkWell(
                                      onTap: () => setState(
                                        () => descriptionController.clear(),
                                      ),
                                      child: Icon(
                                        Icons.clear,
                                        size: 15,
                                      ),
                                    )
                                  : null,
                            ),
                            style:
                                Theme.of(context).textTheme.bodyText1!.copyWith(
                                      fontFamily: 'Poppins',
                                    ),
                            maxLines: 10,
                            keyboardType: TextInputType.multiline,
                          ),
                        ),
                        if(isArabic)
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: TextFormField(
                            focusNode: _descriptionArFocusNode,
                            onChanged: (_) => setState(() {}),
                            controller: descriptionArController,
                            obscureText: false,
                            validator: (value) =>
                                value == null || value.length < 10
                                    ? 'Minimum 10 caractères.'
                                    : null,
                            textInputAction: TextInputAction.newline,
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: 'Texte de l’annonce*',
                              hintStyle: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(
                                    fontFamily: 'Poppins',
                                    color: Colors.grey[400],
                                  ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 1,
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4.0),
                                  topRight: Radius.circular(4.0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 1,
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4.0),
                                  topRight: Radius.circular(4.0),
                                ),
                              ),
                              suffixIcon: descriptionArController.text.isNotEmpty
                                  ? InkWell(
                                      onTap: () => setState(
                                        () => descriptionArController.clear(),
                                      ),
                                      child: Icon(
                                        Icons.clear,
                                        size: 15,
                                      ),
                                    )
                                  : null,
                            ),
                            style:
                                Theme.of(context).textTheme.bodyText1!.copyWith(
                                      fontFamily: 'Poppins',
                                    ),
                            maxLines: 10,
                            keyboardType: TextInputType.multiline,
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(40, 10, 40, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(5, 15, 0, 0),
                          child: Text(
                            'Ville:',
                            style:
                                Theme.of(context).textTheme.headline2!.copyWith(
                                      fontFamily: 'Poppins',
                                      fontSize: 22,
                                    ),
                          ),
                        ),
                        SizedBox(width: 50),
                        Container(
                          margin: EdgeInsets.fromLTRB(8, 4, 8, 4),
                          width: 190,
                          height: 40,
                          child: DropdownButtonFormField(
                            items: villes.entries.map(
                              (e) {
                                var ville = e.key;
                                return new DropdownMenuItem(
                                    value: ville,
                                    child: Row(
                                      children: <Widget>[
                                        Icon(Icons.location_city, size: 17),
                                        SizedBox(width: 5),
                                        Container(
                                            width: 123,
                                            child: FittedBox(
                                                alignment: Alignment.centerLeft,
                                                fit: BoxFit.scaleDown,
                                                child: Text(ville))),
                                      ],
                                    ));
                              },
                            ).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                product.ville = value;
                                product.secteur = null;
                              });
                            },
                            value: product.ville,
                            style:
                                Theme.of(context).textTheme.bodyText1!.copyWith(
                                      fontFamily: 'Poppins',
                                      color: Colors.black,
                                      fontStyle: FontStyle.italic,
                                    ),
                            elevation: 2,
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    width: 0,
                                    color: Colors.transparent,
                                  )),
                              fillColor: MyTheme.tertiaryColor,
                              contentPadding:
                                  EdgeInsets.fromLTRB(10, 10, 10, 10),
                              errorStyle: TextStyle(fontSize: 0, height: 0),
                            ),
                            validator: (value) => value == null ? '' : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (villes[product.ville] != null &&
                      villes[product.ville]!.length > 0)
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 20, 40, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(5, 15, 0, 0),
                            child: Text(
                              'Secteur:',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline2!
                                  .copyWith(
                                    fontFamily: 'Poppins',
                                    fontSize: 22,
                                  ),
                            ),
                          ),
                          SizedBox(width: 15),
                          Container(
                            margin: EdgeInsets.fromLTRB(8, 0, 8, 4),
                            width: 190,
                            height: 40,
                            child: DropdownButtonFormField(
                              items: villes[product.ville]?.map((secteur) {
                                return new DropdownMenuItem(
                                    value: secteur,
                                    child: Row(
                                      children: <Widget>[
                                        Icon(Icons.location_on, size: 17),
                                        SizedBox(width: 5),
                                        Container(
                                          width: 123,
                                          child: FittedBox(
                                              alignment: Alignment.centerLeft,
                                              fit: BoxFit.scaleDown,
                                              child: Text(secteur)),
                                        ),
                                      ],
                                    ));
                              }).toList(),
                              onChanged: (String? value) {
                                setState(() => product.secteur = value);
                              },
                              value: product.secteur,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(
                                    fontFamily: 'Poppins',
                                    color: Colors.black,
                                    fontStyle: FontStyle.italic,
                                  ),
                              elevation: 2,
                              decoration: InputDecoration(
                                border: UnderlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      width: 0,
                                      color: Colors.transparent,
                                    )),
                                fillColor: MyTheme.tertiaryColor,
                                contentPadding:
                                    EdgeInsets.fromLTRB(10, 10, 10, 10),
                                errorStyle: TextStyle(fontSize: 0, height: 0),
                              ),
                              validator: (value) => value == null ? '' : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(40, 20, 40, 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                          child: Text(
                            'Address:',
                            style:
                                Theme.of(context).textTheme.headline2!.copyWith(
                                      fontFamily: 'Poppins',
                                      fontSize: 22,
                                    ),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment(0, -0.2),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: TextFormField(
                                onChanged: (_) => setState(() {}),
                                controller: textFieldController,
                                obscureText: false,
                                decoration: InputDecoration(
                                  isDense: true,
                                  hintText: 'Address du bien..',
                                  hintStyle: Theme.of(context)
                                      .textTheme
                                      .bodyText1!
                                      .copyWith(
                                        fontFamily: 'Poppins',
                                        fontStyle: FontStyle.italic,
                                        // fontWeight: FontWeight.w200,
                                        color: Colors.grey[400],
                                      ),
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.fromLTRB(15, 15, 3, 10),
                                  suffixIcon: textFieldController
                                          .text.isNotEmpty
                                      ? InkWell(
                                          onTap: () => setState(
                                            () => textFieldController.clear(),
                                          ),
                                          child: Icon(
                                            Icons.clear,
                                            size: 20,
                                          ),
                                        )
                                      : null,
                                ),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(
                                      fontFamily: 'Poppins',
                                      fontStyle: FontStyle.italic,
                                    ),
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 0.5,
                    indent: 50,
                    endIndent: 50,
                    color: MyTheme.secondaryColor,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
                    child: Container(
                      width: 100,
                      height: 180,
                      constraints: BoxConstraints(
                        maxWidth: double.infinity,
                        maxHeight: double.infinity,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0x00FFFFFF),
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: GridView(
                          padding: EdgeInsets.zero,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 15,
                            childAspectRatio: 1,
                            mainAxisExtent: 90,
                          ),
                          scrollDirection: Axis.horizontal,
                          children: [
                            DetaitsDuBienWidget(
                              controller: surfaceController,
                              icon: Icon(Icons.architecture),
                            ),
                            DetaitsDuBienWidget(
                              controller: nbrCuisineController,
                              icon: Icon(
                                Icons.room_service_sharp,
                                color: Colors.black,
                                size: 24,
                              ),
                            ),
                            DetaitsDuBienWidget(
                              controller: nbrChambresController,
                              icon: FaIcon(
                                FontAwesomeIcons.bed,
                                color: Colors.black,
                                size: 22,
                              ),
                            ),
                            DetaitsDuBienWidget(
                              controller: nbrSalonsController,
                              icon: Icon(
                                Icons.chair,
                                color: Colors.black,
                                size: 24,
                              ),
                            ),
                            DetaitsDuBienWidget(
                              controller: salleDeBainController,
                              icon: FaIcon(
                                FontAwesomeIcons.shower,
                                color: Colors.black,
                                size: 22,
                              ),
                            ),
                            DetaitsDuBienWidget(
                              controller: nbrEtageController,
                              icon: Icon(
                                Icons.stairs,
                                color: Colors.black,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    thickness: 0.5,
                    indent: 50,
                    endIndent: 50,
                    color: MyTheme.secondaryColor,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: SingleChildScrollView(
                      child: DetaillesSuplementaireListWidget(
                        product: product,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DetaitsDuBienWidget extends StatelessWidget {
  const DetaitsDuBienWidget(
      {Key? key, required this.controller, required this.icon})
      : super(key: key);

  final TextEditingController controller;
  final icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Color(0x00FFFFFF),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          icon,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextFormField(
              controller: controller,
              obscureText: false,
              textInputAction: TextInputAction.next,
              validator: (value) => value == '' ? '' : null,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                isDense: true,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0x00000000),
                    width: 1,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4.0),
                    topRight: Radius.circular(4.0),
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0x00000000),
                    width: 1,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4.0),
                    topRight: Radius.circular(4.0),
                  ),
                ),
              ),
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    fontFamily: 'Poppins',
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
              keyboardType: TextInputType.number,
            ),
          )
        ],
      ),
    );
  }
}
