import 'package:cloud_firestore/cloud_firestore.dart' as cloudFirestore;
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:mypro_immobilier/providers/transactions.dart';
import 'package:mypro_immobilier/shared/my_theme.dart';

class AddTransactionWidget extends StatefulWidget {
  AddTransactionWidget({Key? key}) : super(key: key);

  @override
  _AddTransactionWidgetState createState() => _AddTransactionWidgetState();
}

class _AddTransactionWidgetState extends State<AddTransactionWidget> {
  late TextEditingController reasonController;
  late TextEditingController amountController;
  final transactionsRecord = TransactionsRecord();

  @override
  void initState() {
    super.initState();
    reasonController = TextEditingController();
    amountController = MoneyMaskedTextController(
        initialValue: 0.0, decimalSeparator: ',', thousandSeparator: ' ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.35 +
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
              padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Reason:      ',
                    style: Theme.of(context).textTheme.headline2!.copyWith(
                          fontFamily: 'Poppins',
                        ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment(0, -0.2),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: TextFormField(
                          controller: reasonController,
                          obscureText: false,
                          decoration: InputDecoration(
                            isDense: true,
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
                            contentPadding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                          ),
                          style:
                              Theme.of(context).textTheme.bodyText1!.copyWith(
                                    fontFamily: 'Poppins',
                                    fontStyle: FontStyle.italic,
                                  ),
                          textAlign: TextAlign.start,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Amount:   ',
                    style: Theme.of(context).textTheme.headline2!.copyWith(
                          fontFamily: 'Poppins',
                        ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment(0, -0.2),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: TextFormField(
                          controller: amountController,
                          obscureText: false,
                          decoration: InputDecoration(
                            isDense: true,
                            labelText: 'Dhs',
                            labelStyle:
                                Theme.of(context).textTheme.bodyText1!.copyWith(
                                      fontFamily: 'Poppins',
                                      fontStyle: FontStyle.italic,
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
                            contentPadding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                          ),
                          style:
                              Theme.of(context).textTheme.bodyText1!.copyWith(
                                    fontFamily: 'Poppins',
                                    fontStyle: FontStyle.italic,
                                  ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FFButtonWidget(
                    onPressed: () async {
                      transactionsRecord.addTransaction(Transaction(
                        amount: double.parse(amountController.text
                            .replaceAll(',', '.')
                            .replaceAll(' ', '')),
                        reason: reasonController.text,
                        type: '-',
                        date: cloudFirestore.Timestamp.now(),
                      ));
                      Navigator.pop(context);
                    },
                    child: Text('Outgoing'),
                    options: FFButtonWidget.styleFrom(
                      width: 150,
                      height: 50,
                      backgroundColor: Color(0xC63474E0),
                      textStyle:
                          Theme.of(context).textTheme.subtitle2!.copyWith(
                                fontFamily: 'Poppins',
                                color: Colors.white,
                              ),
                      borderSide: BorderSide(
                        color: Colors.transparent,
                        width: 1,
                      ),
                      borderRadius: 12,
                    ),
                  ),
                  FFButtonWidget(
                    onPressed: () async {
                      transactionsRecord.addTransaction(Transaction(
                        amount: double.parse(amountController.text
                            .replaceAll(',', '.')
                            .replaceAll(' ', '')),
                        reason: reasonController.text,
                        type: '+',
                        date: cloudFirestore.Timestamp.now(),
                      ));
                      Navigator.pop(context);
                    },
                    child: Text('Incoming'),
                    options: FFButtonWidget.styleFrom(
                      width: 150,
                      height: 50,
                      backgroundColor: Color(0xFF6AC821),
                      textStyle:
                          Theme.of(context).textTheme.subtitle2!.copyWith(
                                fontFamily: 'Poppins',
                                color: Colors.white,
                              ),
                      borderSide: BorderSide(
                        color: Colors.transparent,
                        width: 1,
                      ),
                      borderRadius: 12,
                    ),
                  )
                ],
              ),
            )
          ],
        ));
  }
}
