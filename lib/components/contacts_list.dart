import 'package:flutter/material.dart';
import 'package:mypro_immobilier/pages/contacts/add_contact.dart';
import 'package:mypro_immobilier/pages/contacts/contact_info.dart';
import 'package:mypro_immobilier/pages/products/add_product/product_add_contact.dart';
import 'package:mypro_immobilier/providers/contacts.dart';
import 'package:mypro_immobilier/shared/my_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactListWidget extends StatefulWidget {
  ContactListWidget({
    Key? key,
    this.showSellsAndProductsOnTap = false,
    this.changeBackGroundColorOnTap = false,
  }) : super(key: key);
  final bool showSellsAndProductsOnTap;
  final bool changeBackGroundColorOnTap;

  @override
  _ContactListWidgetState createState() => _ContactListWidgetState();
}

class _ContactListWidgetState extends State<ContactListWidget>
    with TickerProviderStateMixin {
  late TextEditingController searchController;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  int? selectedContactIndex;
  String? hintText = 'Search..';
  launchURL(String url) async {
    if (await canLaunch(url))
      await launch(url);
    else
      // can't launch url, there is some error
      throw "Could not launch $url";
  }

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    selectedContactIndex = null;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.of(context).pushNamed(AddContactScreen.routeName);
        },
        backgroundColor: MyTheme.primaryColor,
        elevation: 8,
        child: Icon(
          Icons.add,
          color: MyTheme.tertiaryColor,
          size: 24,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints:
                BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
                  child: TextFormField(
                    onChanged: (_) => setState(() {
                      selectedContactIndex = null;
                    }),
                    onTap: () => setState(() => hintText = null),
                    controller: searchController,
                    obscureText: false,
                    decoration: InputDecoration(
                      hintText: hintText,
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
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(5),
                          bottomRight: Radius.circular(5),
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5),
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(5),
                          bottomRight: Radius.circular(5),
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5),
                        ),
                      ),
                      filled: true,
                      contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      suffixIcon: searchController.text.isNotEmpty
                          ? InkWell(
                              onTap: () => setState(
                                () => searchController.clear(),
                              ),
                              child: Icon(
                                Icons.clear,
                                color: Color(0xFF757575),
                                size: 22,
                              ),
                            )
                          : null,
                    ),
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                ),
                StreamBuilder<List<Contact>>(
                  stream: Contacts().contactsOrderedBy('name'),
                  builder: (context, snapshot) {
                    // Customize what your widget looks like when it's loading.
                    if (!snapshot.hasData) {
                      return Container(
                        height: 500,
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                            color: MyTheme.primaryColor,
                          ),
                        ),
                      );
                    }
                    List<Contact> contactList = snapshot.data!
                        .where((contact) => contact.name!
                            .toLowerCase()
                            .contains(searchController.text.toLowerCase()))
                        .toList();

                    // Customize what your widget looks like with no query results.
                    if (contactList.isEmpty) {
                      return Container(
                        height: 100,
                        child: Center(
                          child: Text('No results.'),
                        ),
                      );
                    }

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 100.0),
                        child: ListView.builder(
                            itemCount: contactList.length,
                            itemBuilder: (context, index) {
                              final contact = contactList[index];
                              return Padding(
                                padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                                child: Column(
                                  children: [
                                    Container(
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Card(
                                        clipBehavior:
                                            Clip.antiAliasWithSaveLayer,
                                        color:
                                            widget.changeBackGroundColorOnTap &&
                                                    index ==
                                                        selectedContactIndex
                                                ? Colors.orange[100]
                                                : Colors.white,
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Dismissible(
                                          key: Key(
                                              '${contact.reference}_${DateTime.now().second}'),
                                          onDismissed: (_) async {
                                            try {
                                              await launchURL(
                                                  'tel:${contact.phone}');
                                            } catch (err) {
                                              print(err);
                                            }
                                            setState(() {});
                                          },
                                          direction:
                                              DismissDirection.startToEnd,
                                          background: Container(
                                            padding: const EdgeInsets.all(20),
                                            alignment: Alignment.centerLeft,
                                            color: MyTheme.callColor,
                                            child: Icon(
                                              Icons.phone,
                                              color: MyTheme.tertiaryColor,
                                              size: 30,
                                            ),
                                          ),
                                          child: InkWell(
                                            onLongPress: () {
                                              Navigator.of(context).pushNamed(
                                                  ContactInfoScreen.routeName,
                                                  arguments: contact);
                                            },
                                            onTap: () {
                                              setState(() {
                                                FocusScope.of(context)
                                                    .requestFocus(FocusNode());
                                                hintText = 'Search..';
                                                if (selectedContactIndex !=
                                                    index) {
                                                  selectedContactIndex = index;
                                                  SelectProductContact.of(
                                                          context)
                                                      ?.newProduct
                                                      .contact = contactList[
                                                          selectedContactIndex!]
                                                      .reference;
                                                } else {
                                                  selectedContactIndex = null;
                                                  SelectProductContact.of(
                                                          context)
                                                      ?.newProduct
                                                      .contact = null;
                                                }
                                              });
                                            },
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      16, 0, 0, 0),
                                                  child: Stack(
                                                    children: [
                                                      Align(
                                                        alignment: Alignment(
                                                            -0.1, -0.5),
                                                        child: Text(
                                                          contact.name ?? '',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .subtitle2!
                                                                  .copyWith(
                                                                    fontFamily:
                                                                        'Montserrat',
                                                                    color: Color(
                                                                        0xFF15212B),
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment: Alignment(
                                                            2.64, 0.55),
                                                        child: Text(
                                                          contact.phone ?? '',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyText2!
                                                                  .copyWith(
                                                                    fontFamily:
                                                                        'Montserrat',
                                                                    color: Color(
                                                                        0xFF8B97A2),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Align(
                                                    alignment: Alignment(1, 0),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              0, 0, 20, 0),
                                                      child: Container(
                                                        width: 40,
                                                        height: 40,
                                                        clipBehavior:
                                                            Clip.antiAlias,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Image.asset(
                                                            'assets/images/contact_profile.png'),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (widget.showSellsAndProductsOnTap &&
                                        false)
                                      AnimatedSize(
                                        duration: Duration(milliseconds: 500),
                                        alignment: Alignment.center,
                                        curve: Curves.easeIn,
                                        vsync: this,
                                        child: Container(
                                          height:
                                              (index == selectedContactIndex)
                                                  ? 60
                                                  : 0,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      child: Icon(
                                                        Icons
                                                            .home_work_outlined,
                                                        size: 40,
                                                        color: Colors.grey[400],
                                                      ),
                                                    ),
                                                    Text(
                                                      '${contact.products.length}',
                                                      style: TextStyle(
                                                        color: Colors.grey[500],
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      child: Icon(
                                                        Icons
                                                            .attach_money_outlined,
                                                        size: 40,
                                                        color: Colors.grey[400],
                                                      ),
                                                    ),
                                                    Text(
                                                      '${contact.sells.length}',
                                                      style: TextStyle(
                                                        color: Colors.grey[500],
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                  ],
                                ),
                              );
                            }),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
