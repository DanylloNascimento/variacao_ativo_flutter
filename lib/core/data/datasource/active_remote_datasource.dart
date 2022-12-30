import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:variacao_ativo_flutter/core/conectivy/checkConnectivy.dart';
import 'package:variacao_ativo_flutter/core/data/dto/active_dto.dart';
import 'package:variacao_ativo_flutter/core/enums/enums.dart';
import 'package:variacao_ativo_flutter/feature/active/page/active_view_results.dart';

class ActiveRemoteDataSource with ChangeNotifier {
  List<Result>? active = [];
  late ActiveDTO activeDTO;
  late String filterSelected;
  viewState _state = viewState.Done;
  viewState get state => _state;
  CheckConnectivy checkConnectivy = CheckConnectivy();

  void setFilterSelected(String filter) {
    filterSelected = filter;
    notifyListeners();
  }

  void setState(viewState currentState) {
    _state = currentState;
    notifyListeners();
  }

  loadDataActivs(BuildContext context) async {
    setState(viewState.IsLoading);
    active = [];

    setState(viewState.Done);

    return await getDataApi(context);
  }

  double calculatePriceVariation(double priceToday, double priceYesterday) {
    return (priceToday - priceYesterday) / priceYesterday;
  }

  double getInitialPrice(ActiveDTO activeDTO) {
    List<double>? openPrices =
        activeDTO.chart.result[0].indicators.quote[0].open;
    return openPrices.first;
  }

  Future getDataApi(BuildContext context) async {
    if (await checkConnectivy.checkConnectivy()) {
      final url = await http.get(Uri.parse(
          'https://query2.finance.yahoo.com/v8/finance/chart/$filterSelected.SA'));

      activeDTO = ActiveDTO.fromJson(jsonDecode(url.body));

      // print(url.body);
      List<double>? prices =
          activeDTO.chart.result[0].indicators.quote[0].close;
      List<int>? timestamps = activeDTO.chart.result[0].timestamp;

      prices = prices.sublist(prices.length - 30, prices.length);
      timestamps =
          timestamps.sublist(timestamps.length - 30, timestamps.length);
      List<PriceData> priceDataList = [];

      for (int i = 0; i < prices.length; i++) {
        double price = prices[i];
        int timestamp = timestamps[i];
        double variation;

        if (i > 0) {
          double previousPrice = prices[i - 1];
          variation = calculatePriceVariation(price, previousPrice);
        } else {
          variation = 0.0;
        }

        priceDataList.add(
          PriceData(
            timestamp: timestamp,
            price: price,
            variation: variation,
          ),
        );
      }

      return priceDataList;
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Error: No connection"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: const <Widget>[Text("Check your internet connection")],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStatePropertyAll(Colors.blue[900])),
                child: const Text("Ok"),
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.red)),
                  child: const Text("Cancel")),
            ],
          );
        },
      );
    }
  }
}

class PriceData {
  final int timestamp;
  final double price;
  final double variation;

  PriceData({
    required this.timestamp,
    required this.price,
    required this.variation,
  });

  String formatPrice(double price) {
    final formatter = NumberFormat.currency(symbol: '\$');
    return formatter.format(price);
  }

  String formatVariation(double variation) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return formatter.format(variation);
  }

  String formatTimestamp(int timestamp) {
    final df = DateFormat('dd/MM/yyyy hh:mm');
    return df.format(DateTime.fromMillisecondsSinceEpoch(timestamp * 1000));
  }
}
