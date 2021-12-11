import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faker/faker.dart';
import 'package:collection/collection.dart' as collection;

class Transaction {
  DocumentReference? reference;
  double? amount;
  String? reason;
  String? type;
  Timestamp? date;

  Transaction({this.reason, this.amount, this.type, this.date, this.reference});

  Map<String, Object> toMap() {
    return {
      if (amount != null) 'amount': amount!,
      if (reason != null) 'reason': reason!,
      if (type != null) 'type': type!,
      if (date != null) 'date': date!,
    };
  }
}

class TransactionsRecord {
  final _transactions = FirebaseFirestore.instance.collection('transactions');

  Future<DocumentReference?> addTransaction(Transaction transactions) async {
    try {
      return await _transactions.add(transactions.toMap());
    } catch (err) {
      print(err);
      return null;
    }
  }

  Stream<List<Transaction>>? get transactions {
    try {
      return _transactions
          .orderBy('date', descending: false)
          .snapshots()
          .map(_transactionFromSnapshot);
    } catch (err) {
      print(err);
      return null;
    }
  }

  Stream<List<Transaction>>? transactionsOrderedBy(String field) {
    try {
      return _transactions
          .orderBy(field, descending: false)
          .snapshots()
          .map(_transactionFromSnapshot);
    } catch (err) {
      print(err);
      return null;
    }
  }

  List<Transaction> _transactionFromSnapshot(QuerySnapshot query) {
    try {
      return query.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Transaction(
          reference: doc.reference,
          amount: data['amount'],
          reason: data['reason'],
          type: data['type'],
          date: data['date'],
        );
      }).toList();
    } catch (err) {
      print(err);
      throw err;
    }
  }

  double getTotal({required List<Transaction> transactions, String? type}) {
    double totale = 0.0;
    transactions.forEach((transaction) {
      if (transaction.amount != null && transaction.type == type)
        totale += transaction.amount!;
    });
    return totale;
  }

  Future<Transaction> getFromReference(
      DocumentReference transactionReference) async {
    final result = await transactionReference.get();
    final transactionData = result.data() as Map;
    return Transaction(
      reference: transactionReference,
      amount: transactionData['amount'],
      reason: transactionData['reason'],
      type: transactionData['type'],
      date: transactionData['date'],
    );
  }

  addRandom() {
    addTransaction(Transaction(
      amount: Random().nextDouble() * 10000,
      date: Timestamp.fromDate(
          DateTime(2021, Random().nextInt(12), Random().nextInt(25))),
      reason: faker.lorem.word(),
      type: ['+', '-'][Random().nextInt(2)],
    ));
  }

  Map<DateTime, Map<String, dynamic>>? groupByMonth(
      List<Transaction>? transactions,
      {bool onlyThisYear = false}) {
    if (transactions == null) return null;
    final groupedTransactions = collection.groupBy(
      transactions.reversed,
      (transaction) {
        final date = (transaction as Transaction).date!.toDate();
        return DateTime(date.year, date.month, 1);
      },
    );
    if (onlyThisYear)
      groupedTransactions
          .removeWhere((key, value) => key.year != DateTime.now().year);
    return groupedTransactions.map((key, value) {
      double totalIncoming = 0.0;
      double totalOutgoing = 0.0;
      value.forEach((transaction) {
        if (transaction.type == '+') totalIncoming += transaction.amount!;
        if (transaction.type == '-') totalOutgoing += transaction.amount!;
      });
      return MapEntry(key, {
        'list': value,
        'totalIncoming': totalIncoming,
        'totalOutgoing': totalOutgoing,
        'totale': totalIncoming - totalOutgoing,
      });
    });
  }

  List<MonthlyTransaction>? generateChartData(List<Transaction>? transactions) {
    final chartData = groupByMonth(transactions, onlyThisYear: true)
        ?.map((key, value) {
          return MapEntry(
            key,
            MonthlyTransaction(
              date: key,
              list: value['list'],
              totalIncoming: value['totalIncoming'],
              totalOutgoing: value['totalOutgoing'],
              totale: value['totale'],
            ),
          );
        })
        .values
        .toList();
    if (chartData == null) return null;
    List<int>.generate(DateTime.now().month, (i) => i + 1).forEach((m) {
      final date = DateTime(DateTime.now().year, m);
      int r = chartData.indexWhere((mt) => mt.date == date);
      if (r == -1) {
        chartData.add(MonthlyTransaction(
            list: [],
            date: date,
            totalIncoming: 0.0,
            totalOutgoing: 0.0,
            totale: 0.0));
      }
    });
    chartData.sortBy((d) => d.date!);
    return chartData;
  }
}

class MonthlyTransaction {
  DateTime? date;
  List<Transaction> list;
  double totalIncoming;
  double totalOutgoing;
  double totale;

  MonthlyTransaction(
      {this.list = const [],
      this.date,
      this.totalIncoming = 0.0,
      this.totalOutgoing = 0.0,
      this.totale = 0.0});

  ///[type] : 'totale', 'incoming', 'outgoing'
  static double? average(
      {required List<MonthlyTransaction> transactions, required String type}) {
    double avr = 0.0;
    switch (type) {
      case 'totale':
        transactions.forEach((transaction) {
          avr += transaction.totale;
        });
        return avr / transactions.length;
      case 'incoming':
        transactions.forEach((transaction) {
          avr += transaction.totalIncoming;
        });
        return avr / transactions.length;
      case 'outgoing':
        transactions.forEach((transaction) {
          avr += transaction.totalOutgoing;
        });
        return avr / transactions.length;
      default:
        return null;
    }
  }
}
