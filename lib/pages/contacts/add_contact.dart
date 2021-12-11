import 'package:flutter/material.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart'
    as contactPicker;
import 'package:mypro_immobilier/providers/contacts.dart';
import 'package:mypro_immobilier/shared/my_theme.dart';

class AddContactScreen extends StatefulWidget {
  static const routeName = '/add-contact';
  AddContactScreen({Key? key}) : super(key: key);

  @override
  _AddContactScreenState createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  final _phoneFocusNode = FocusNode();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    phoneController = TextEditingController();
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
            'CONTACT INFOS',
            style: Theme.of(context).textTheme.headline2!.copyWith(
                  fontFamily: 'Poppins',
                ),
          ),
        ),
        actions: [
          Container(
            width: 53,
            height: 100,
            decoration: BoxDecoration(),
            alignment: Alignment(0.8, 0),
            child: IconButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                Contacts().addContact(Contact(
                    name: nameController.text, phone: phoneController.text));
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.done_sharp,
                color: Colors.black,
                size: 37,
              ),
              iconSize: 37,
            ),
          )
        ],
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: Container(
            padding: const EdgeInsets.only(top: 40.0, bottom: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Name',
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                              fontFamily: 'Poppins',
                            ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: TextFormField(
                          onChanged: (_) => setState(() {}),
                          validator: (value) =>
                              value == '' ? 'this field is required' : null,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) => FocusScope.of(context)
                              .requestFocus(_phoneFocusNode),
                          controller: nameController,
                          obscureText: false,
                          decoration: InputDecoration(
                            hintText: 'Full name',
                            hintStyle:
                                Theme.of(context).textTheme.bodyText1!.copyWith(
                                      fontFamily: 'Poppins',
                                      color: Colors.grey[400],
                                    ),
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
                            filled: true,
                            suffixIcon: nameController.text.isNotEmpty
                                ? InkWell(
                                    onTap: () => setState(
                                      () => nameController.clear(),
                                    ),
                                    child: Icon(
                                      Icons.clear,
                                      color: Color(0xFF757575),
                                      size: 22,
                                    ),
                                  )
                                : null,
                          ),
                          style:
                              Theme.of(context).textTheme.bodyText1!.copyWith(
                                    fontFamily: 'Poppins',
                                  ),
                          textAlign: TextAlign.start,
                          keyboardType: TextInputType.name,
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Phone',
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                              fontFamily: 'Poppins',
                            ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: TextFormField(
                          focusNode: _phoneFocusNode,
                          onChanged: (_) => setState(() {}),
                          validator: (value) =>
                              value == '' ? 'this field is required' : null,
                          controller: phoneController,
                          obscureText: false,
                          decoration: InputDecoration(
                            hintText: 'Phone number',
                            hintStyle:
                                Theme.of(context).textTheme.bodyText1!.copyWith(
                                      fontFamily: 'Poppins',
                                      color: Colors.grey[400],
                                    ),
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
                            filled: true,
                            suffixIcon: phoneController.text.isNotEmpty
                                ? InkWell(
                                    onTap: () => setState(
                                      () => phoneController.clear(),
                                    ),
                                    child: Icon(
                                      Icons.clear,
                                      color: Color(0xFF757575),
                                      size: 22,
                                    ),
                                  )
                                : null,
                          ),
                          style:
                              Theme.of(context).textTheme.bodyText1!.copyWith(
                                    fontFamily: 'Poppins',
                                  ),
                          textAlign: TextAlign.start,
                          keyboardType: TextInputType.phone,
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 50),
                  child: Text(
                    'Or',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(
                          fontFamily: 'Poppins',
                        ),
                  ),
                ),
                Container(
                  // color: Colors.amber,
                  alignment: Alignment.topCenter,
                  width: 100,
                  height: 40,
                  child: FittedBox(
                    child: Container(
                      width: 170,
                      height: 50,
                      child: TextButton(
                        onPressed: () async {
                          try {
                            final contactPicker.PhoneContact selectedContact =
                                await contactPicker.FlutterContactPicker
                                    .pickPhoneContact(askForPermission: true);
                            setState(() {
                              nameController.text = selectedContact.fullName ??
                                  nameController.text;
                              phoneController.text =
                                  selectedContact.phoneNumber?.number ??
                                      phoneController.text;
                            });
                          } catch (err) {
                            print(err);
                          }
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Color(0xE6EE8B60),
                          elevation: 0.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                              child: Text(
                                'Upload Contact',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(
                                      fontFamily: 'Poppins',
                                      color: Colors.white,
                                    ),
                              ),
                            ),
                            Icon(
                              Icons.upload_file,
                              color: Colors.white,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
