import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mypro_immobilier/providers/google_drive.dart';
import 'package:mypro_immobilier/providers/products.dart';
import 'package:mypro_immobilier/shared/my_theme.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:exif/exif.dart';

class ImageScrollView extends StatefulWidget {
  ImageScrollView({
    Key? key,
    required this.product,
    required this.pageViewController,
    this.callBack,
    this.refresh,
  }) : super(key: key);

  final Product product;
  final PageController pageViewController;
  final Function? callBack;
  final Function? refresh;
  List<int> deleteList = [];
  @override
  _ImageScrollViewState createState() => _ImageScrollViewState();
}

class _ImageScrollViewState extends State<ImageScrollView> {
  late final GoogleDrive googleDrive;
  var _isLoading = false;

  int currentPageIndex = 0;
  bool init = true;
  @override
  void didChangeDependencies() {
    if (init) {
      googleDrive = Provider.of<GoogleDrive>(context);
      init = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Builder(
        builder: (context) {
          final images = widget.product.images ?? [];
          return Container(
            width: double.infinity,
            height: 500,
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 50),
                  child: PageView.builder(
                    onPageChanged: (pageIndex) => setState(() {
                      currentPageIndex = pageIndex;
                    }),
                    controller: widget.pageViewController,
                    scrollDirection: Axis.horizontal,
                    itemCount: images.length + 1,
                    itemBuilder: (context, imagesIndex) {
                      return imagesIndex < images.length
                          ? InkWell(
                              onLongPress: () {
                                setState(() {
                                  if (!widget.deleteList.remove(imagesIndex))
                                    widget.deleteList.add(imagesIndex);
                                });
                                widget.callBack?.call();
                              },
                              onTap: widget.deleteList.length > 0
                                  ? () {
                                      setState(() {
                                        if (!widget.deleteList
                                            .remove(imagesIndex))
                                          widget.deleteList.add(imagesIndex);
                                      });
                                      widget.callBack?.call();
                                    }
                                  : null,
                              child: Stack(
                                children: [
                                  CachedNetworkImage(
                                    // memCacheHeight: 300,
                                    // maxHeightDiskCache: 300,
                                    imageUrl: images[imagesIndex],
                                    placeholder: (ctx, _) => SpinKitThreeBounce(
                                      color: MyTheme.primaryColor,
                                      size: 25,
                                    ),
                                    height: 500,
                                    width: MediaQuery.of(context).size.width,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, text, _) =>
                                        Container(
                                      height: 130,
                                      alignment: Alignment.center,
                                      child: IconButton(
                                          onPressed: () {
                                            // setState(() {});
                                            widget.refresh?.call();
                                          },
                                          icon: Icon(Icons.refresh)),
                                    ),
                                  ),
                                  if (widget.deleteList.contains(imagesIndex))
                                    Container(
                                      color: Colors.red.withAlpha(150),
                                    ),
                                ],
                              ))
                          : InkWell(
                              onTap: () async {
                                setState(() {
                                  _isLoading = true;
                                });
                                try {
                                  // final pickFileResult =
                                  //     await FilePicker.platform.pickFiles(
                                  //   withReadStream: true,
                                  //   allowMultiple: true,
                                  //   type: FileType.image,
                                  // );
                                  final pickFileResult = await ImagePicker().pickMultiImage();// .pickImage(source: ImageSource.gallery)
                                  if (pickFileResult != null) {
                                    final images = pickFileResult;
                                    if (widget.product.location == null) {
                                      for(var image in images) {
                                        Map<String, IfdTag> data =await readExifFromBytes(await image.readAsBytes());
                                        if (data.isEmpty) {
                                          print('no exif data!');
                                          continue;
                                        }
                                        try{
                                          var listCordLatitude=data['GPS GPSLatitude']?.values.toList() as List<Ratio>?;
                                          var listCordlongitude=data['GPS GPSLongitude']?.values.toList() as List<Ratio>?;
                                          if(listCordLatitude==null || listCordlongitude==null) continue;
                                          final double latitude=(listCordLatitude[0].toDouble()+listCordLatitude[1].toDouble()/60+listCordLatitude[2].toDouble()/3600)*('${data['GPS GPSLatitudeRef']}'=='N'?1:-1);
                                          final double longitude=(listCordlongitude[0].toDouble()+listCordlongitude[1].toDouble()/60+listCordlongitude[2].toDouble()/3600)*('${data['GPS GPSLongitudeRef']}'=='W'?-1:1);
                                          print('GPS GPSLatitude: $latitude');
                                          print('GPS GPSLongitude: $longitude');
                                          widget.product.location=GeoPoint(latitude,longitude);
                                        }catch(err){
                                          print(err);//https://www.google.com/maps/dir/?api=1&travelmode=driving&layer=traffic&destination=[YOUR_LAT],[YOUR_LNG]
                                        }
                                      }
                                    }
                                    //upload to google drive
                                    for (var i = 0; i < images.length; i++) {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      final result = await googleDrive
                                          .uploadFilesToGoogleDrive(
                                        files: [
                                          PlatformFile.fromMap(
                                            {
                                              'path': images[i].path,
                                              'name': images[i].path.split('/').last,
                                              // 'bytes': await videoFile.readAsBytes(),
                                              'size': await images[i].length(),
                                            },
                                            readStream: images[i].openRead(),
                                          )
                                          ],
                                        product: widget.product,
                                      );
                                      if (result != null) {
                                        widget.product.images =
                                            widget.product.images ?? [];
                                        widget.product.images!.add(result[0]!);
                                      }
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                    widget.product.changed = true;
                                    widget.product.reference?.update(
                                        Product(images: widget.product.images)
                                            .toMap());
                                  }
                                } catch (err) {
                                  print(err);
                                }
                                setState(() {
                                  _isLoading = false;
                                });
                                widget.callBack?.call();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  image: widget.product.miniature == null
                                      ? null
                                      : DecorationImage(
                                          image: CachedNetworkImageProvider(
                                            widget.product.miniature!,
                                            maxHeight: 500,
                                            errorListener: () {},
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                child: BackdropFilter(
                                  filter:
                                      ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: _isLoading
                                        ? CircularProgressIndicator()
                                        : Icon(
                                            Icons.add_a_photo,
                                            size: 70,
                                          ),
                                  ),
                                ),
                              ),
                            );
                    },
                  ),
                ),
                if (images.length > 0 && currentPageIndex < images.length)
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      margin: EdgeInsets.only(right: 10),
                      child: widget.deleteList.contains(currentPageIndex)
                          ? null
                          : IconButton(
                              onPressed: () {
                                setState(() => widget.product.miniature =
                                    images[currentPageIndex]);
                              },
                              icon: widget.product.miniature ==
                                      images[currentPageIndex]
                                  ? Icon(
                                      Icons.favorite,
                                      size: 40,
                                      color: Colors.red[800],
                                    )
                                  : Icon(
                                      Icons.favorite_outline_sharp,
                                      size: 40,
                                      color: Colors.red[800],
                                    )),
                    ),
                  ),
                Align(
                  alignment: Alignment(0, 1),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: SmoothPageIndicator(
                      controller: widget.pageViewController,
                      count: images.length + 1,
                      axisDirection: Axis.horizontal,
                      onDotClicked: (i) {
                        widget.pageViewController.animateToPage(
                          i,
                          duration: Duration(milliseconds: 500),
                          curve: Curves.ease,
                        );
                      },
                      effect: ExpandingDotsEffect(
                        expansionFactor: 2,
                        spacing: 8-((images.length+1)*20/100),
                        radius: 16-((images.length+1)*30/100),
                        dotWidth: 16-((images.length+1)*30/100),
                        dotHeight: 16-((images.length+1)*30/100),
                        dotColor: Color(0xFF9E9E9E),
                        activeDotColor: widget.deleteList.length > 0 &&
                                widget.deleteList.contains(
                                    widget.pageViewController.page?.round())
                            ? Colors.red
                            : Color(0xFF3F51B5),
                        paintStyle: PaintingStyle.fill,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
