import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mypro_immobilier/pages/contacts/add_contact.dart';
import 'package:mypro_immobilier/pages/contacts/contact_info.dart';
import 'package:mypro_immobilier/pages/products/add_product/product_add_address.dart';
import 'package:mypro_immobilier/pages/products/add_product/product_add_contact.dart';
import 'package:mypro_immobilier/pages/products/add_product/product_add_detailes.dart';
import 'package:mypro_immobilier/pages/products/add_product/product_description.dart';
import 'package:mypro_immobilier/pages/products/add_product/product_other_detailes.dart';
import 'package:mypro_immobilier/pages/products/add_product/product_select_city.dart';
import 'package:mypro_immobilier/pages/products/add_product/product_select_type.dart';
import 'package:mypro_immobilier/pages/products/add_product/product_upload_images.dart';
import 'package:mypro_immobilier/pages/products/add_product/product_upload_videos.dart';
import 'package:mypro_immobilier/pages/products/product_details.dart';
import 'package:mypro_immobilier/pages/products/product_studio.dart';
import 'package:mypro_immobilier/pages/transactions/transactions__overview.dart';
import 'package:mypro_immobilier/pages/wrapper.dart';
import 'package:mypro_immobilier/providers/auth.dart';
import 'package:mypro_immobilier/providers/google_drive.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // MyVarriables().initialise;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ListenableProvider<Auth>(create: (_) => Auth()),
        ListenableProvider<GoogleDrive>(create: (_) => GoogleDrive()),
      ],
      child: MaterialApp(
        title: 'MYPRO IMMOBILIER',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: Color(0xff3474e0),
          accentColor: Color(0xffee8b60),
          textTheme: TextTheme(
            headline3: Theme.of(context).textTheme.headline3!.copyWith(
                  fontSize: 20,
                ),
            headline2: Theme.of(context).textTheme.headline2!.copyWith(
                  fontSize: 22,
                ),
            headline1: Theme.of(context).textTheme.headline2!.copyWith(
                  fontSize: 24,
                ),
          ),
        ),
        routes: {
          '/': (_) => FirstScreen(),
          ProductDetailsScreen.routeName: (_) => ProductDetailsScreen(),
          SelectTypeDeBienScreen.routeName: (_) => SelectTypeDeBienScreen(),
          SelectVilleScreen.routeName: (_) => SelectVilleScreen(),
          AddAddressScreen.routeName: (_) => AddAddressScreen(),
          AddDetailsDuBienScreen.routeName: (_) => AddDetailsDuBienScreen(),
          SelectDetaillesSuplementaireScreen.routeName: (_) =>
              SelectDetaillesSuplementaireScreen(),
          AddDescriptionScreen.routeName: (_) => AddDescriptionScreen(),
          AddContactScreen.routeName: (_) => AddContactScreen(),
          SelectProductContact.routeName: (_) => SelectProductContact(),
          UploadImagesScreen.routeName: (_) => UploadImagesScreen(),
          ContactInfoScreen.routeName: (_) => ContactInfoScreen(),
          UploadVideosScreen.routeName: (_) => UploadVideosScreen(),
          StudioScreen.routeName: (_) => StudioScreen(),
          TransactionsOverviewScreen.routeName: (_) =>
              TransactionsOverviewScreen(),
        },
      ),
    );
  }
}
