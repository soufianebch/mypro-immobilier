import 'package:flutter/material.dart';
import 'package:mypro_immobilier/pages/contacts/contacts__overview.dart';
import 'package:mypro_immobilier/pages/products/products_overview.dart';
import 'package:mypro_immobilier/pages/transactions/transactions__overview.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> _pages = [
    {
      'page': ContactOverviewScreen(),
    },
    {
      'page': ProductsOverviewScreen(),
    },
    {
      'page': TransactionsOverviewScreen(),
    },
  ];
  int _selectedPageIndex = 1;
  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: _pages[_selectedPageIndex]['appBar'] as PreferredSizeWidget,
      body: _pages[_selectedPageIndex]['page'] as Widget,
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: _selectPage,
        currentIndex: _selectedPageIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.assignment_ind_rounded,
            ),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_work_outlined,
            ),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.attach_money_outlined,
            ),
            label: 'Transactions',
          ),
        ],
      ),
    );
  }
}
