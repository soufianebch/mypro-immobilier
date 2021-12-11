import 'package:flutter/material.dart';
import 'package:mypro_immobilier/providers/products.dart';
import 'package:mypro_immobilier/shared/my_theme.dart';

class DetaillesSuplementaireListWidget extends StatefulWidget {
  final Product product;

  const DetaillesSuplementaireListWidget({Key? key, required this.product})
      : super(key: key);

  @override
  _DetaillesSuplementaireListWidgetState createState() =>
      _DetaillesSuplementaireListWidgetState();
}

class _DetaillesSuplementaireListWidgetState
    extends State<DetaillesSuplementaireListWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DetailsSupplementairesWiget(
          checkboxValue: widget.product.ascensseur,
          title: 'Ascensseur',
          toggleValue: (newVal) =>
              setState(() => widget.product.ascensseur = newVal),
        ),
        DetailsSupplementairesWiget(
          checkboxValue: widget.product.terrasse,
          title: 'Terrase',
          toggleValue: (newVal) =>
              setState(() => widget.product.terrasse = newVal),
        ),
        DetailsSupplementairesWiget(
          checkboxValue: widget.product.meuble,
          title: 'Meublé',
          toggleValue: (newVal) =>
              setState(() => widget.product.meuble = newVal),
        ),
        DetailsSupplementairesWiget(
          checkboxValue: widget.product.climatisation,
          title: 'Climatisation',
          toggleValue: (newVal) =>
              setState(() => widget.product.climatisation = newVal),
        ),
        DetailsSupplementairesWiget(
          checkboxValue: widget.product.chauffage,
          title: 'Chauffage',
          toggleValue: (newVal) =>
              setState(() => widget.product.chauffage = newVal),
        ),
        DetailsSupplementairesWiget(
          checkboxValue: widget.product.cuisineEquipee,
          title: 'Cuisine équipée',
          toggleValue: (newVal) =>
              setState(() => widget.product.cuisineEquipee = newVal),
        ),
        DetailsSupplementairesWiget(
          checkboxValue: widget.product.concierge,
          title: 'Concierge',
          toggleValue: (newVal) =>
              setState(() => widget.product.concierge = newVal),
        ),
        DetailsSupplementairesWiget(
          checkboxValue: widget.product.securite,
          title: 'Sécurité',
          toggleValue: (newVal) =>
              setState(() => widget.product.securite = newVal),
        ),
        DetailsSupplementairesWiget(
          checkboxValue: widget.product.parking,
          title: 'Parking',
          toggleValue: (newVal) =>
              setState(() => widget.product.parking = newVal),
        ),
        DetailsSupplementairesWiget(
          checkboxValue: widget.product.duplex,
          title: 'Duplex',
          toggleValue: (newVal) =>
              setState(() => widget.product.duplex = newVal),
        ),
      ],
    );
  }
}

class DetailsSupplementairesWiget extends StatelessWidget {
  const DetailsSupplementairesWiget({
    Key? key,
    this.checkboxValue,
    required this.toggleValue,
    required this.title,
  }) : super(key: key);

  final bool? checkboxValue;
  final Function toggleValue;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: CheckboxListTile(
          value: checkboxValue ?? false,
          onChanged: (newValue) => toggleValue(newValue),
          title: Text(
            title,
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.headline3!.copyWith(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
          ),
          tileColor: MyTheme.tertiaryColor,
          activeColor: MyTheme.primaryColor,
          checkColor: MyTheme.tertiaryColor,
          dense: false,
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ),
    );
  }
}
