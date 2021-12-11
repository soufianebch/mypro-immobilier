import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mypro_immobilier/components/image_scroll_view_widget.dart';
import 'package:mypro_immobilier/pages/products/add_product/product_upload_videos.dart';
import 'package:mypro_immobilier/providers/products.dart';
import 'package:mypro_immobilier/shared/my_theme.dart';

class UploadImagesScreen extends StatefulWidget {
  static const routeName = 'upload-product-images';
  @override
  _UploadImagesScreenState createState() => _UploadImagesScreenState();
}

class _UploadImagesScreenState extends State<UploadImagesScreen> {
  String uploadedFileUrl = '';
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late final Product newProduct;
  final pageViewController = PageController();
  late ImageScrollView imageScrollView;
  List<String> deleteList = [];
  bool init = true;

  String imagePath = '';
  @override
  void didChangeDependencies() {
    if (init) {
      newProduct = ModalRoute.of(context)!.settings.arguments as Product;
      imageScrollView = ImageScrollView(
        product: newProduct,
        pageViewController: pageViewController,
        refresh: () => Navigator.of(context).pushReplacementNamed(
          UploadImagesScreen.routeName,
          arguments: newProduct,
        ),
        callBack: () => setState(() {}),
      );
      init = false;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    pageViewController.dispose();
    super.dispose();
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
        title: Text(
          'Photos',
          style: Theme.of(context).textTheme.headline3!.copyWith(
                fontFamily: 'Poppins',
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
                  if ((newProduct.images ?? []).length > 0 &&
                      newProduct.miniature == null) return;
                  ProductsRecord().addProduct(newProduct);
                  Navigator.of(context).pushNamed(
                    UploadVideosScreen.routeName,
                    arguments: newProduct,
                  );
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
      floatingActionButton: imageScrollView.deleteList.length > 0
          ? FloatingActionButton(
              onPressed: () async {
                imageScrollView.deleteList.forEach((imageIndex) {
                  final imageId = (newProduct.images![imageIndex] as String)
                      .replaceAll(
                          'https://drive.google.com/uc?export=view&id=', '');

                  deleteList.add(imageId);
                });
                newProduct.images!.removeWhere((imageLink) {
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
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          imageScrollView,
          Container(
            color: Colors.grey[200],
            height: 80,
            width: MediaQuery.of(context).size.width,
            child: newProduct.images != null
                ? ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: newProduct.images!.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () => pageViewController.animateToPage(index,
                            duration: Duration(seconds: 1),
                            curve: Curves.linearToEaseOut),
                        child: Container(
                          margin: const EdgeInsets.only(
                              top: 5, bottom: 5, left: 5, right: 0),
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            //Colors.grey[500]
                            border:
                                Border.all(color: Color(0xffbdbdbd), width: 2),
                          ),
                          child: CachedNetworkImage(
                            height: 70,
                            width: 90,
                            fit: BoxFit.cover,
                            imageUrl: newProduct.images![index],
                            errorWidget: (context, text, _) => Container(
                              alignment: Alignment.center,
                              child: IconButton(
                                  onPressed: () => Navigator.of(context)
                                          .pushReplacementNamed(
                                        UploadImagesScreen.routeName,
                                        arguments: newProduct,
                                      ),
                                  icon: Icon(Icons.refresh)),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : null,
          ),

          // Expanded(child: Image.file(File(imagePath))),
          // Expanded(
          //   child: Container(
          //     alignment: Alignment.center,
          //     child: IconButton(
          //       onPressed: () async {
          //         final List<XFile>? images = await _picker.pickMultiImage();
          //         print(images?.first.path);
          //         setState(() {
          //           imagePath = images?.first.path ?? '';
          //         });
          //       },
          //       padding: const EdgeInsets.all(50),
          //       icon: Icon(Icons.add_a_photo),
          //       iconSize: 50,
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }
}
