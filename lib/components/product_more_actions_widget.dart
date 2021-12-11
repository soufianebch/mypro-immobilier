import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mypro_immobilier/pages/products/product_studio.dart';
import 'package:mypro_immobilier/providers/products.dart';
import 'package:mypro_immobilier/providers/uploaded_videos.dart';
import 'package:mypro_immobilier/shared/my_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class MoreActionsWidget extends StatefulWidget {
  MoreActionsWidget({
    Key? key,
    required this.contact,
    required this.product,
  }) : super(key: key);

  final DocumentReference? contact;
  final Product product;

  @override
  _MoreActionsWidgetState createState() => _MoreActionsWidgetState();
}

class _MoreActionsWidgetState extends State<MoreActionsWidget> {
  double? downloadProgressPercentage;
  String? phone;

  DateTime? _longPressStart;
  @override
  void initState() {
    widget.contact?.get().then(
        (value) => setState(() => phone = (value.data() as Map?)?['phone']));

    super.initState();
  }

  launchURL(String url) async {
    if (await canLaunch(url))
      await launch(url);
    else
      // can't launch url, there is some error
      throw "Could not launch $url";
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(0, 0),
      child: downloadProgressPercentage == null
          ? Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.product.inStock != -1 && widget.contact != null)
                  FutureBuilder(
                      future: widget.contact?.get(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          phone = (((snapshot.data as DocumentSnapshot<Object?>)
                              .data() as Map<String, dynamic>)['phone']);
                          return Padding(
                            padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                            child: phone != null
                                ? GestureDetector(
                                    onLongPressStart: (details) =>
                                        _longPressStart = DateTime.now(),
                                    onLongPressMoveUpdate: (details) async {
                                      if (_longPressStart == null) return;
                                      final counter = DateTime.now()
                                          .difference(_longPressStart!)
                                          .inSeconds;
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
                                        if (widget.product.location == null) {
                                          Fluttertoast.showToast(
                                            msg: "no location!",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                          );
                                          return;
                                        }
                                        print(
                                            'https://www.google.com/maps/dir/?api=1&travelmode=driving&layer=traffic&destination=${widget.product.location?.latitude},${widget.product.location?.longitude}');
                                        await launchURL(
                                            'https://www.google.com/maps/dir/?api=1&travelmode=driving&layer=traffic&destination=${widget.product.location?.latitude},${widget.product.location?.longitude}');
                                      }
                                    },
                                    onTap: () async {
                                      await launchURL('tel:$phone');
                                    },
                                    child: FFButtonWidget(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.call,
                                            color: Colors.white,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Text(
                                              'Call',
                                              textAlign: TextAlign.start,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1!
                                                  .copyWith(
                                                    fontFamily: 'Poppins',
                                                    color: Colors.white,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      options: FFButtonWidget.styleFrom(
                                        backgroundColor: Colors.green,
                                        width: 200,
                                        height: 40,
                                        borderRadius: 15,
                                      ),
                                    ),
                                  )
                                : null,
                          );
                        }
                        return Container();
                      }),
                if (widget.product.inStock != -1)
                  Padding(
                    padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                    child: InkWell(
                      onTap: () async {
                        if (widget.product.uploadedVideoFiles == null) {
                          try {
                            setState(() {
                              downloadProgressPercentage = 0;
                            });
                            widget.product.uploadedVideoFiles =
                                UploadedVideoFiles();
                            // backgroundMusic
                            final backgroundMusic = await widget
                                .product.uploadedVideoFiles!
                                .copyOfAsset(
                                    'assets/for_video_editing/audio/jazz.mp3');

                            widget.product.uploadedVideoFiles!.backgroundMusic =
                                {
                              'audioPath': backgroundMusic,
                              'audioName': 'myproimmobilier_jazz.mp3',
                              'audioDuration': await widget
                                  .product.uploadedVideoFiles!
                                  .getAudioDuration(backgroundMusic),
                            };
                            //mainVideo
                            if (widget.product.mainVideo != null)
                              try {
                                final video = {
                                  'videoPath': widget.product.mainVideo,
                                  'driveLink': widget.product.mainVideo,
                                  'videoName': 'mainVideoGoogleDrive.mp4',
                                  'progressPercentage': null,
                                  'changed': false,
                                  'hasPadding': true,
                                };
                                await widget.product.uploadedVideoFiles!
                                    .downloadVideos(
                                  videos: [video],
                                  callBack: () => setState(() =>
                                      downloadProgressPercentage =
                                          (video['progressPercentage']
                                                  as double?) ??
                                              100),
                                );
                                video['thumbnail'] =
                                    await VideoThumbnail.thumbnailData(
                                  video: '${video['videoPath']}',
                                  timeMs: 200,
                                  imageFormat: ImageFormat.JPEG,
                                  maxWidth: 700,
                                  quality: 25,
                                );
                                widget.product.uploadedVideoFiles!.mainVideos
                                    .insert(0, video);
                              } catch (err) {
                                print(err);
                              }
                            //intro video
                            if (widget.product.introVideo != null)
                              try {
                                final video = {
                                  'videoPath': widget.product.introVideo,
                                  'driveLink': widget.product.introVideo,
                                  'videoName': 'introVideoGoogleDrive.mp4',
                                  'progressPercentage': null,
                                  'changed': false,
                                  'hasPadding': true,
                                };
                                await widget.product.uploadedVideoFiles!
                                    .downloadVideos(
                                  videos: [video],
                                  callBack: () => setState(() =>
                                      downloadProgressPercentage =
                                          (video['progressPercentage']
                                                  as double?) ??
                                              100),
                                );
                                video['thumbnail'] =
                                    await VideoThumbnail.thumbnailData(
                                  video: '${video['videoPath']}',
                                  timeMs: 200,
                                  imageFormat: ImageFormat.JPEG,
                                  maxWidth: 700,
                                  quality: 25,
                                );
                                widget.product.uploadedVideoFiles!.introVideos
                                    .insert(0, video);
                              } catch (err) {
                                print(err);
                              }
                          } catch (err) {
                            widget.product.uploadedVideoFiles = null;
                          }
                        }

                        Navigator.of(context).pushNamed(StudioScreen.routeName,
                            arguments: widget.product);
                        setState(() {
                          downloadProgressPercentage = null;
                        });
                      },
                      child: Container(
                        width: 200,
                        height: 40,
                        decoration: BoxDecoration(
                          color: MyTheme.primaryColor,
                          borderRadius: BorderRadius.circular(15),
                          shape: BoxShape.rectangle,
                        ),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.video_collection,
                                color: Colors.white,
                                size: 20,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  'Studio',
                                  textAlign: TextAlign.start,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1!
                                      .copyWith(
                                        fontFamily: 'Poppins',
                                        color: Colors.white,
                                      ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (widget.product.inStock == -1)
                  Padding(
                    padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                    child: InkWell(
                      onTap: () async {
                        widget.product.inStock = 1;
                        widget.product.changed = true;
                        await widget.product.reference!
                            .update(widget.product.toMap());
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/', (route) => false);
                      },
                      child: FFButtonWidget(
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restore,
                              color: Colors.white,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                'Restore',
                                textAlign: TextAlign.start,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(
                                      fontFamily: 'Poppins',
                                      color: Colors.white,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        options: FFButtonWidget.styleFrom(
                          backgroundColor: MyTheme.primaryColor.withAlpha(200),
                          width: 200,
                          height: 40,
                          borderRadius: 15,
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                  child: InkWell(
                    onTap: () async {
                      await showDialog(
                        context: context,
                        builder: (alertDialogContext) {
                          return AlertDialog(
                            title: Text('Delete product!'),
                            content: Text(
                                'Do you really want to delete this product?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(alertDialogContext),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(alertDialogContext);
                                  if (widget.product.inStock != -1) {
                                    widget.product.inStock = -1;
                                    widget.product.changed = true;
                                    await widget.product.reference!
                                        .update(widget.product.toMap());
                                  } else {
                                    await ProductsRecord().delete(widget.product);
                                  }
                                  // Navigator.of(context)..pop()..pop();
                                  Navigator.pushNamedAndRemoveUntil(
                                      context, '/', (route) => false);
                                },
                                child: Text('Confirm'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: FFButtonWidget(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              'Delete',
                              textAlign: TextAlign.start,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(
                                    fontFamily: 'Poppins',
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      options: FFButtonWidget.styleFrom(
                        backgroundColor: Colors.red,
                        width: 200,
                        height: 40,
                        borderRadius: 15,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                  child: InkWell(
                    onTap: () async {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 200,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(0xFF607D8B),
                        borderRadius: BorderRadius.circular(15),
                        shape: BoxShape.rectangle,
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 20,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                'Back',
                                textAlign: TextAlign.start,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(
                                      fontFamily: 'Poppins',
                                      color: Colors.white,
                                    ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            )
          : Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 155,
                  height: 155,
                  child: CircularProgressIndicator(
                    strokeWidth: 15,
                    value: downloadProgressPercentage! / 100,
                  ),
                ),
                Text(
                  '${downloadProgressPercentage!.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
    );
  }
}
