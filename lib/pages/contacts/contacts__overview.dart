import 'package:flutter/material.dart';
import 'package:mypro_immobilier/components/contacts_list.dart';

class ContactOverviewScreen extends StatefulWidget {
  static const routeName = 'contact-overview';
  ContactOverviewScreen({Key? key}) : super(key: key);

  @override
  _ContactOverviewScreenState createState() => _ContactOverviewScreenState();
}

class _ContactOverviewScreenState extends State<ContactOverviewScreen> {
  @override
  Widget build(BuildContext context) {
    return ContactListWidget(
      showSellsAndProductsOnTap: true,
    );
  }
}
