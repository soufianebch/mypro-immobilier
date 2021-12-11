import 'package:flutter/material.dart';
import 'package:mypro_immobilier/components/contacts_list.dart';
import 'package:mypro_immobilier/pages/products/add_product/product_upload_images.dart';
import 'package:mypro_immobilier/providers/google_drive.dart';
import 'package:mypro_immobilier/providers/products.dart';
import 'package:mypro_immobilier/shared/my_theme.dart';
import 'package:mypro_immobilier/shared/my_varriables.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as Firebase;
import 'package:fluttertoast/fluttertoast.dart';

class SelectProductContact extends StatefulWidget {
  static const routeName = 'select-product-contact';
  const SelectProductContact({Key? key}) : super(key: key);

  @override
  _SelectProductContactState createState() => _SelectProductContactState();

  static _SelectProductContactState? of(BuildContext context) =>
      context.findAncestorStateOfType<_SelectProductContactState>();
}

class _SelectProductContactState extends State<SelectProductContact> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late final Product newProduct;
  late final GoogleDrive googleDrive;

  bool init = true;
  @override
  void didChangeDependencies() {
    if (init) {
      newProduct = ModalRoute.of(context)!.settings.arguments as Product;
      googleDrive = Provider.of<GoogleDrive>(context);
      init = false;
    }
    super.didChangeDependencies();
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
              'Propriétaire',
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
                    if (newProduct.contact == null) return;
                    // if (newProduct.googleDriveFolderId == null)
                    //   newProduct.googleDriveFolderId = await googleDrive
                    //       .createNewDriveFolder('${newProduct.hashtag}');
                    if (newProduct.createdTimeStamp == null) {
                      final myVarriables = MyVarriables();
                      newProduct.createdTimeStamp = Firebase.Timestamp.now();
                      ProductsRecord()
                          .addProduct(newProduct)
                          .then((value) async{
                        newProduct.reference = value;
                        myVarriables
                          .setCounter(await myVarriables.counter + 1);
                      });
                    }
                    if(await MyVarriables().hasNetwork()){
                      Navigator.of(context).pushNamed(
                        UploadImagesScreen.routeName,
                        arguments: newProduct,
                      );
                    }else{
                      Fluttertoast.showToast(
                          msg: "Check your internet connection!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                      );
                      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                    }
                    
                  },
                  icon: Icon(
                    Icons.arrow_forward,
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
        body: ContactListWidget(
          changeBackGroundColorOnTap: true,
        ) //changeBackGroundColorOnTap: true),
        );
  }
}
