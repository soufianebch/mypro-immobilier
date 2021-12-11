import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mypro_immobilier/components/add_new_product_widget.dart';
import 'package:mypro_immobilier/components/end-drawer.dart';
import 'package:mypro_immobilier/components/product_more_actions_widget.dart';
import 'package:mypro_immobilier/pages/products/product_details.dart';
import 'package:mypro_immobilier/providers/products.dart';
import 'package:mypro_immobilier/providers/uploaded_videos.dart';

import '../../shared/my_theme.dart';

class ProductsOverviewScreen extends StatefulWidget {
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  UploadedVideoFiles uploadedVideoFiles = UploadedVideoFiles();
  final _mainScaffoldKey = GlobalKey<ScaffoldState>();
  final _childScaffoldKey = GlobalKey<ScaffoldState>();
  final _productsRecord = ProductsRecord();
  bool _showDeletedProducts = false;

  /// [filters] is a Map of:
  /// hashtag, typedebien, ville, secteur, nbrChambres, nbrSallesDeBain, nbrSalons, nbrEtage, nbrFacades, ascensseur, terrasse, meuble, climatisation, chauffage, cuisineEquipee, concierge, securite, parking, duplex, prixMin, prixMax, surfaceTotalMin, surfaceTotalMax, surfaceHabitable, surfaceHabitable, inStock, contact
  Map<String, dynamic> filters = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _mainScaffoldKey,
      appBar: AppBar(
        backgroundColor: MyTheme.tertiaryColor,
        automaticallyImplyLeading: false,
        actions: [
          // IconButton(
          //   onPressed: () async {
          //     print('>>>> test btn pressed');
 
          //     var image = await ImagePicker().pickImage(source: ImageSource.gallery);
          //     if(image==null)return;
          //     var bytes = await image.readAsBytes();
          //     var tags = await readExifFromBytes(bytes.toList());
          //     Map<String, String> mTags = HashMap();
          //     try {
          //           // mTags.addAll(exifToGPS(tags));
          //     }catch(e){
          //       print("noexif");
          //     }finally{
          //       tags.forEach((key, value) {
          //       print({"$key":"$value"});
          //       mTags.addAll({"$key":"$value"});
          //     });
          //     // await Fluttertoast.showToast(
          //     //     msg: "Connection? ${await MyVarriables().hasNetwork()}",
          //     //     toastLength: Toast.LENGTH_SHORT,
          //     //     gravity: ToastGravity.CENTER,
          //     //     timeInSecForIosWeb: 1);
          //     // final googleDrive = GoogleDrive();
          //     // await googleDrive.initialise();
          //     // await googleDrive.uploadToYoutube();
          //   }
          //   },
          //   icon: Icon(Icons.ac_unit),
          //   iconSize: 30,
          //   color: Colors.red,
          // ),
          // IconButton(
          //   onPressed: () async {
          //     final auth = Provider.of<Auth>(context, listen: false);
          //     auth.signOut();
          //   },
          //   icon: Icon(Icons.logout),
          //   iconSize: 30,
          //   color: Colors.red,
          // ),
          // IconButton(
          //   onPressed: () async {
          //     _productsRecord.addProduct(Product().randomData());
          //   },
          //   icon: Icon(Icons.add),
          //   iconSize: 30,
          //   color: Colors.red,
          // ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
            child: IconButton(
              onPressed: () {
                setState(() {
                  if (_showDeletedProducts)
                    _showDeletedProducts = false;
                  else
                    _showDeletedProducts = true;
                });
              },
              icon: FaIcon(
                FontAwesomeIcons.trashAlt,
                color: _showDeletedProducts?Colors.red:Colors.black,
                size: 20,
              ),
              iconSize: 20,
            ),
          ),
          if (!(_childScaffoldKey.currentState?.isEndDrawerOpen ?? false))
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: IconButton(
                onPressed: () =>
                    _childScaffoldKey.currentState?.openEndDrawer(),
                icon: Icon(
                  Icons.filter_alt_sharp,
                  color: Color(0x8D000000),
                  size: 25,
                ),
                iconSize: 25,
              ),
            ),
          if (_childScaffoldKey.currentState?.isEndDrawerOpen ?? false)
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: IconButton(
                onPressed: () {
                  filters = {};
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.restore,
                  color: Color(0x8D000000),
                  size: 25,
                ),
                iconSize: 25,
              ),
            )
        ],
        centerTitle: true,
        elevation: 0,
      ),
      body: Scaffold(
        key: _childScaffoldKey,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            //test-btn
            print('test-btn pressed');

            //print(MyVarriables.villes);
            //
            showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (bContext) {
                return AddNewProduct();
              },
            );
          },
          backgroundColor: MyTheme.primaryColor,
          elevation: 8,
          child: Icon(
            Icons.add,
            color: MyTheme.tertiaryColor,
            size: 24,
          ),
        ),
        endDrawer: EndDrawer(
            filters: filters, callBack: (flt) => setState(() => filters = flt)),
        onEndDrawerChanged: (_) => setState(() {}),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: StreamBuilder(
                  stream: _productsRecord.products(),
                  builder: (context, snapshot) {
                    // Customize what your widget looks like when it's loading.
                    if (!snapshot.hasData) {
                      return Center(
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                            color: MyTheme.primaryColor,
                          ),
                        ),
                      );
                    }
                    // Customize what your widget looks like with no query results.
                    final productsList = _productsRecord
                        .filterProductsList(
                            snapshot.data as List<Product>, filters)
                        .where((product) {
                      if (_showDeletedProducts)
                        return product.inStock == -1;
                      else
                        return product.inStock != -1;
                    }).toList();
                    if (productsList.isEmpty) {
                      return Container(
                        height: 100,
                        child: Center(
                          child: Text('No results.'),
                        ),
                      );
                    }
                    return GridView.builder(
                      padding: EdgeInsets.zero,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 0,
                        mainAxisSpacing: 0,
                        childAspectRatio: 0.85,
                      ),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: productsList.length,
                      itemBuilder: (context, gridViewIndex) {
                        return Stack(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                    ProductDetailsScreen.routeName,
                                    arguments: productsList[gridViewIndex]);
                              },
                              onLongPress: () {
                                showModalBottomSheet(
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (context) {
                                    return MoreActionsWidget(
                                        contact:
                                            productsList[gridViewIndex].contact,
                                        product: productsList[gridViewIndex]);
                                  },
                                );
                              },
                              borderRadius: BorderRadius.circular(7),
                              child: Card(
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                color: Color(0xFFF5F5F5),
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    productsList[gridViewIndex].miniature ==
                                            null
                                        ? Container(height: 130)
                                        : CachedNetworkImage(
                                            imageUrl:
                                                productsList[gridViewIndex]
                                                    .miniature!,
                                            errorWidget: (context, text, _) =>
                                                Container(height: 130),
                                            placeholder: (buildContext, text) =>
                                                SpinKitThreeBounce(
                                              color: MyTheme.primaryColor,
                                              size: 25,
                                            ),
                                            width: double.infinity,
                                            height: 130,
                                            fit: BoxFit.cover,
                                          ),
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(5, 5, 5, 0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Icon(
                                                    Icons.architecture,
                                                    color: Colors.black,
                                                    size: 24,
                                                  ),
                                                  SizedBox(
                                                    child: Text(
                                                      productsList[gridViewIndex]
                                                                  .surfaceTotal ==
                                                              null
                                                          ? '-'
                                                          : productsList[
                                                                  gridViewIndex]
                                                              .surfaceTotal!
                                                              .toStringAsFixed(
                                                                  0),
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText1!
                                                          .copyWith(
                                                            fontFamily:
                                                                'Poppins',
                                                          ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  FaIcon(
                                                    FontAwesomeIcons.bed,
                                                    color: Colors.black,
                                                    size: 24,
                                                  ),
                                                  Text(
                                                    productsList[gridViewIndex]
                                                                .nbrChambres ==
                                                            null
                                                        ? '-'
                                                        : productsList[
                                                                gridViewIndex]
                                                            .nbrChambres
                                                            .toString(),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1!
                                                        .copyWith(
                                                          fontFamily: 'Poppins',
                                                        ),
                                                  )
                                                ],
                                              ),
                                              Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  FaIcon(
                                                    FontAwesomeIcons.shower,
                                                    color: Colors.black,
                                                    size: 24,
                                                  ),
                                                  Text(
                                                    productsList[gridViewIndex]
                                                                .nbrSallesDeBain ==
                                                            null
                                                        ? '-'
                                                        : productsList[
                                                                gridViewIndex]
                                                            .nbrSallesDeBain
                                                            .toString(),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1!
                                                        .copyWith(
                                                          fontFamily: 'Poppins',
                                                        ),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 10, 0, 10),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                productsList[gridViewIndex]
                                                            .prix ==
                                                        null
                                                    ? '-'
                                                    : NumberFormat.currency(
                                                            customPattern:
                                                                "#,##0.00",
                                                            locale: 'eu',
                                                            decimalDigits: 0)
                                                        .format(productsList[
                                                                gridViewIndex]
                                                            .prix),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1!
                                                    .copyWith(
                                                      fontFamily: 'Poppins',
                                                    ),
                                              ),
                                              Text(
                                                ' Dhs',
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1!
                                                    .copyWith(
                                                      fontFamily: 'Poppins',
                                                      color:
                                                          MyTheme.primaryColor,
                                                    ),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment(0.01, -0.85),
                              child: Text(
                                productsList[gridViewIndex].hashtag == null
                                    ? ' - '
                                    : ' #${productsList[gridViewIndex].hashtag.toString()} ',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(
                                      fontFamily: 'Roboto',
                                      color: MyTheme
                                          .tertiaryColor, //Color(0xFF607D8B),
                                      backgroundColor: MyTheme.secondaryColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            )
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
