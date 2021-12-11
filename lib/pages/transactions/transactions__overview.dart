import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mypro_immobilier/components/add_transaction_widget.dart';
import 'package:mypro_immobilier/providers/transactions.dart';
import 'package:mypro_immobilier/shared/my_theme.dart';

enum TransactionType {
  total,
  incoming,
  outgoing,
  none,
}

class TransactionsOverviewScreen extends StatefulWidget {
  static const routeName = 'transactions-overview';
  TransactionsOverviewScreen({Key? key}) : super(key: key);

  @override
  _TransactionsOverviewScreenState createState() =>
      _TransactionsOverviewScreenState();
}

class _TransactionsOverviewScreenState
    extends State<TransactionsOverviewScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final transactionsRecord = TransactionsRecord();
  TransactionType? selectedTransactionType;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFFDBE2E7),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // await transactionsRecord.addRandom();
            await showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (context) {
                return AddTransactionWidget();
              },
            );
          },
          backgroundColor: MyTheme.primaryColor,
          elevation: 8,
          child: Icon(
            Icons.add,
            color: MyTheme.tertiaryColor,
            size: 24,
          ),
        ),
        body: StreamBuilder<List<Transaction>>(
            stream: transactionsRecord.transactions,
            builder: (context, snapshot) {
              // Customize what your widget looks like when it's loading.
              if (!snapshot.hasData) {
                return Center(
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      color: MyTheme.primaryColor,
                    ),
                  ),
                );
              }
              // Customize what your widget looks like with no query results.
              // if (snapshot.data!.isEmpty) {
              //   return Container(
              //     height: 100,
              //     child: Center(
              //       child: Text('No results.'),
              //     ),
              //   );
              // }

              final transactions = snapshot.data ?? [];
              final groupedTransactions =
                  transactionsRecord.groupByMonth(transactions) ?? {};
              final chartData =
                  transactionsRecord.generateChartData(transactions) ?? [];
              var lineChart = charts.LineChart([
                if (selectedTransactionType == TransactionType.total ||
                    selectedTransactionType == TransactionType.none)
                  charts.Series<MonthlyTransaction, int>(
                    id: 'Totale',
                    colorFn: (_, __) =>
                        charts.MaterialPalette.purple.shadeDefault,
                    domainFn: (MonthlyTransaction monthlyTransaction, i) =>
                        monthlyTransaction.date!.month,
                    measureFn: (MonthlyTransaction monthlyTransaction, _) =>
                        monthlyTransaction.totale,
                    keyFn: (MonthlyTransaction monthlyTransaction, _) =>
                        DateFormat.yMMMM().format(monthlyTransaction.date!),
                    data: chartData,
                  ),
                if (selectedTransactionType == TransactionType.outgoing ||
                    selectedTransactionType == TransactionType.none)
                  charts.Series<MonthlyTransaction, int>(
                    id: 'Total Outgoing',
                    colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
                    domainFn: (MonthlyTransaction monthlyTransaction, i) =>
                        monthlyTransaction.date!.month,
                    measureFn: (MonthlyTransaction monthlyTransaction, _) =>
                        monthlyTransaction.totalOutgoing,
                    keyFn: (MonthlyTransaction monthlyTransaction, _) =>
                        DateFormat.yMMMM().format(monthlyTransaction.date!),
                    data: chartData,
                  ),
                if (selectedTransactionType == TransactionType.incoming ||
                    selectedTransactionType == TransactionType.none)
                  charts.Series<MonthlyTransaction, int>(
                    id: 'Total Incoming',
                    colorFn: (_, __) =>
                        charts.MaterialPalette.green.shadeDefault,
                    domainFn: (MonthlyTransaction monthlyTransaction, i) =>
                        monthlyTransaction.date!.month,
                    measureFn: (MonthlyTransaction monthlyTransaction, _) =>
                        monthlyTransaction.totalIncoming,
                    keyFn: (MonthlyTransaction monthlyTransaction, _) =>
                        DateFormat.yMMMM().format(monthlyTransaction.date!),
                    data: chartData,
                  )
              ]);
              return Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 82,
                    decoration: BoxDecoration(
                      color: MyTheme.tertiaryColor,
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, 34, 0, 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  'Transactions',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline1!
                                      .copyWith(
                                        fontFamily: 'Poppins',
                                        fontSize: 28,
                                        fontWeight: FontWeight.w500,
                                      ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (selectedTransactionType != null)
                            Container(
                              height: MediaQuery.of(context).size.height * .25,
                              margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                              color: Color(0xFFF5F5F5),
                              child: lineChart,
                            ),
                          Container(
                            height: MediaQuery.of(context).size.height * .25,
                            padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
                            child: Column(
                              children: [
                                TransactionOverviewCard(
                                  title: 'Total',
                                  amount: transactionsRecord.getTotal(
                                          transactions: transactions,
                                          type: "+") -
                                      transactionsRecord.getTotal(
                                          transactions: transactions,
                                          type: "-"),
                                  color: Color(0xFF4B39EF),
                                  percentage: ((chartData[chartData.length - 1]
                                                  .totale /
                                              (MonthlyTransaction.average(transactions: chartData,type: 'totale' )??0.0)) -
                                          1) *
                                      100,
                                  onTap: () => setState(() =>
                                      selectedTransactionType =
                                          selectedTransactionType ==
                                                  TransactionType.total
                                              ? TransactionType.none
                                              : TransactionType.total),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    TransactionOverviewCard(
                                      title: 'Outgoing',
                                      amount: transactionsRecord.getTotal(
                                          transactions: transactions,
                                          type: "-"),
                                      color: Colors.red,
                                      percentage:

                                          ((chartData[chartData.length - 1]
                                                          .totalOutgoing /
                                                      (MonthlyTransaction.average(transactions: chartData,type: 'outgoing' )??0.0)) -
                                                  1) *
                                              100,
                                      onTap: () => setState(
                                        () => selectedTransactionType =
                                            selectedTransactionType ==
                                                    TransactionType.outgoing
                                                ? TransactionType.none
                                                : TransactionType.outgoing,
                                      ),
                                    ),
                                    TransactionOverviewCard(
                                      title: 'Incoming',
                                      amount: transactionsRecord.getTotal(
                                          transactions: transactions,
                                          type: "+"),
                                      color: Color(0xFF3BC821),
                                      percentage:
                                          ((chartData[chartData.length - 1]
                                                          .totalIncoming /
                                                      (MonthlyTransaction.average(transactions: chartData,type: 'incoming' )??0.0)) -
                                                  1) *
                                              100,
                                      onTap: () => setState(
                                        () => selectedTransactionType =
                                            selectedTransactionType ==
                                                    TransactionType.incoming
                                                ? TransactionType.none
                                                : TransactionType.incoming,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.all(10),
                          //   child: Row(
                          //     crossAxisAlignment: CrossAxisAlignment.center,
                          //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                          //     children: [
                          //       InkWell(
                          //         onTap: () {},
                          //         child: CircleAvatar(
                          //           backgroundColor: Color(0xFFFFC857),
                          //           child: Text(
                          //             'S',
                          //             style: Theme.of(context)
                          //                 .textTheme
                          //                 .headline1!
                          //                 .copyWith(
                          //                   fontSize: 25,
                          //                   fontWeight: FontWeight.bold,
                          //                   color: Colors.white,
                          //                 ),
                          //           ),
                          //           radius: 30,
                          //         ),
                          //       ),
                          //       CircleAvatar(
                          //         backgroundColor: Color(0xFFBDD9BF),
                          //         child: Text(
                          //           'A',
                          //           style: Theme.of(context)
                          //               .textTheme
                          //               .headline1!
                          //               .copyWith(
                          //                 fontSize: 25,
                          //                 fontWeight: FontWeight.bold,
                          //                 color: Colors.white,
                          //               ),
                          //         ),
                          //         radius: 30,
                          //       ),
                          //       CircleAvatar(
                          //         backgroundColor: Color(0xAA2E4052),
                          //         child: Text(
                          //           'I',
                          //           style: Theme.of(context)
                          //               .textTheme
                          //               .headline1!
                          //               .copyWith(
                          //                 fontSize: 25,
                          //                 fontWeight: FontWeight.bold,
                          //                 color: Colors.white,
                          //               ),
                          //         ),
                          //         radius: 30,
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                              itemCount: groupedTransactions.length,
                                itemBuilder: (_, index) {
                              final monthlyTransactions =
                                  groupedTransactions.values.elementAt(index);
                              List<Transaction> monthlyTransactionsList =
                                  monthlyTransactions['list'];
                              return Column(
                                children: [
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.fromLTRB(16, 8, 0, 12),
                                    child: Row(
                                      children: [
                                        Text(
                                          '${DateFormat.yMMMM().format(groupedTransactions.keys.elementAt(index))}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2!
                                              .copyWith(
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              '${NumberFormat.currency(locale: 'eu', decimalDigits: 0, symbol: '').format(monthlyTransactions['totalIncoming']).replaceAll('.', ' ')} MAD',
                                              textAlign: TextAlign.right,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2!
                                                  .copyWith(
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Color(0xFF3BC821)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: monthlyTransactionsList.length,
                                      itemBuilder: (_,columnIndex) {
                                      final columnTransactionsRecord =
                                          monthlyTransactionsList[columnIndex];
                                      return Dismissible(
                                        key: Key(
                                            '${columnTransactionsRecord.reference}_${DateTime.now().second}'),
                                        onDismissed: (_) async {
                                          try {
                                            await columnTransactionsRecord
                                                .reference!
                                                .delete();
                                          } catch (err) {
                                            print(err);
                                          }
                                        },
                                        direction: DismissDirection.startToEnd,
                                        background: Container(
                                          color: Colors.red,
                                          padding: const EdgeInsets.all(20),
                                          alignment: Alignment.centerLeft,
                                          child: Icon(
                                            Icons.delete,
                                            color: MyTheme.tertiaryColor,
                                            size: 30,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                color: Color(0xFFEEEEEE),
                                                border: Border.all(
                                                  color: Color(0xFFC8CED5),
                                                  width: 1,
                                                ),
                                              ),
                                              child: InkWell(
                                                onLongPress: () async {
                                                  await showModalBottomSheet(
                                                    isScrollControlled: true,
                                                    context: context,
                                                    builder: (context) {
                                                      return Container(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.25,
                                                        child: Container(),
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              8, 0, 8, 0),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Container(
                                                            width: 60,
                                                            height: 60,
                                                            clipBehavior:
                                                                Clip.antiAlias,
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                            child:
                                                                Image.asset(
                                                              columnTransactionsRecord
                                                                          .type ==
                                                                      '+'
                                                                  ? 'assets/images/incoming.png'
                                                                  : 'assets/images/outgoing.png',
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              FittedBox(
                                                                child: Text(
                                                                  '${columnTransactionsRecord.type} ${NumberFormat.currency(
                                                                    locale:
                                                                        'eu',
                                                                    symbol: '',
                                                                  ).format(columnTransactionsRecord.amount ?? 0.0)}Dhs',
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .subtitle1!
                                                                      .copyWith(
                                                                          fontFamily:
                                                                              'Poppins',
                                                                          color: Color(
                                                                              0xFF15212B),
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerRight,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            8.0),
                                                                    child: Text(
                                                                      DateFormat
                                                                              .yMMMd()
                                                                          .format(
                                                                        DateTime
                                                                            .fromMicrosecondsSinceEpoch(
                                                                          columnTransactionsRecord
                                                                              .date!
                                                                              .microsecondsSinceEpoch,
                                                                        ),
                                                                      ),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .end,
                                                                      style:
                                                                          TextStyle(
                                                                        color: Color(
                                                                            0xFF57636C),
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        fontSize:
                                                                            10,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              Expanded(
                                                                child: Padding(
                                                                  padding: EdgeInsets
                                                                      .fromLTRB(
                                                                          10,
                                                                          4,
                                                                          4,
                                                                          0),
                                                                  child: Text(
                                                                    '${columnTransactionsRecord.reason}',
                                                                    style: Theme.of(context).textTheme.bodyText2!.copyWith(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        fontFamily:
                                                                            'Poppins',
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .grey[500]),
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    }),
                                  
                                ],
                              );
                            }),
                          
                        ],
                      ),
                    ),
                  )
                ],
              );
            }),
      ),
    );
  }
}

class TransactionOverviewCard extends StatelessWidget {
  final double amount;
  final String title;
  final Color color;
  final Function()? onTap;
  final double percentage;
  const TransactionOverviewCard({
    Key? key,
    required this.title,
    required this.amount,
    required this.percentage,
    required this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.fromLTRB(2, 4, 4, 4),
        child: InkWell(
          onTap: onTap,
          child: Card(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            color: Color(0xFFF5F5F5),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style:
                              Theme.of(context).textTheme.bodyText2!.copyWith(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ),
                      Card(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        color: color,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(2, 2, 2, 2),
                          child: Row(
                            children: [
                              if (percentage >= 0.0)
                                Padding(
                                  padding: EdgeInsets.only(top: 5),
                                  child: Icon(
                                    FontAwesomeIcons.sortUp,
                                    size: 10,
                                    color: Colors.grey[200],
                                  ),
                                ),
                              if (percentage < 0.0)
                                Padding(
                                  padding: EdgeInsets.only(bottom: 5),
                                  child: Icon(
                                    FontAwesomeIcons.sortDown,
                                    size: 10,
                                    color: Colors.grey[200],
                                  ),
                                ),
                              Text(
                                '${percentage.toStringAsFixed(1).replaceAll('-', '')}%',
                                style: TextStyle(
                                  color: Colors.grey[200],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(8, 0, 0, 8),
                      child: FittedBox(
                        child: Text(
                          '${NumberFormat.compactCurrency(locale: 'eu', decimalDigits: 2, symbol: '').format(amount)} MAD',
                          style:
                              Theme.of(context).textTheme.headline2!.copyWith(
                                    fontFamily: 'Poppins',
                                    color: color,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
