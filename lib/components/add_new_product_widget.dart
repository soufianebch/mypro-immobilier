import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mypro_immobilier/pages/products/add_product/product_select_type.dart';
import 'package:mypro_immobilier/providers/uploaded_videos.dart';
import 'package:mypro_immobilier/shared/my_varriables.dart';
import 'package:mypro_immobilier/providers/products.dart';
import '../shared/my_theme.dart';

class AddNewProduct extends StatefulWidget {
  @override
  _AddNewProductState createState() => _AddNewProductState();
}

class _AddNewProductState extends State<AddNewProduct> {
  late TextEditingController textController;
  late int counter;
  @override
  void initState() {
    textController = TextEditingController();
    super.initState();
  }

  var init = true;
  @override
  void didChangeDependencies() async {
    if (init) {
      counter = 0;
      MyVarriables().counter.then((value) =>
          setState(() => textController.text = '${counter = value}'));
      textController.text = '$counter';
      init = false;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.25 +
          MediaQuery.of(context).viewInsets.bottom,
      padding: EdgeInsets.fromLTRB(
        10,
        10,
        10,
        MediaQuery.of(context).viewInsets.bottom + 10,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(100, 0, 100, 20),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: TextFormField(
                      controller: textController,
                      obscureText: false,
                      decoration: InputDecoration(
                        labelText: '#',
                        labelStyle:
                            Theme.of(context).textTheme.bodyText1!.copyWith(
                                  fontFamily: 'Poppins',
                                  fontSize: 20,
                                ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 1,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4.0),
                            topRight: Radius.circular(4.0),
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
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
                            fontSize: 20,
                          ),
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: FFButtonWidget(
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                  options: FFButtonWidget.styleFrom(
                    width: 150,
                    height: 40,
                    textStyle: Theme.of(context).textTheme.subtitle2!.copyWith(
                          fontFamily: 'Poppins',
                          color: Color(0xFF9E9E9E),
                        ),
                    borderSide: BorderSide(
                      color: Colors.transparent,
                      width: 1,
                    ),
                    borderRadius: 12,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: FFButtonWidget(
                  onPressed: () {
                    var newProduct = Product(
                      hashtag: int.parse(textController.text),
                      uploadedVideoFiles: UploadedVideoFiles(),
                    );

                    Navigator.of(context).pushNamed(
                        SelectTypeDeBienScreen.routeName,
                        arguments: newProduct);
                  },
                  child: Text('Confirm'),
                  options: FFButtonWidget.styleFrom(
                    width: 150,
                    height: 40,
                    textStyle: Theme.of(context).textTheme.subtitle2!.copyWith(
                          fontFamily: 'Poppins',
                          color: Color(0xFF9E9E9E),
                        ),
                    borderSide: BorderSide(
                      color: Color(0x00EEEEEE),
                      width: 1,
                    ),
                    borderRadius: 12,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
