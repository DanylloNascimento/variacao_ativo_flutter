// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:variacao_ativo_flutter/core/data/datasource/active_local_datajson.dart';
import 'package:variacao_ativo_flutter/core/data/datasource/active_remote_datasource.dart';
import 'package:variacao_ativo_flutter/core/data/dto/active_dto.dart';
import 'package:variacao_ativo_flutter/core/enums/enums.dart';
import 'dart:convert';

import 'package:variacao_ativo_flutter/feature/active/page/active_view_results.dart';
import 'package:variacao_ativo_flutter/feature/active/page/active_view_results_graph.dart';

class ActiveHome extends StatefulWidget {
  const ActiveHome({Key? key}) : super(key: key);

  @override
  State<ActiveHome> createState() => _ActiveHomeState();
}

class _ActiveHomeState extends State<ActiveHome> {
  late ActiveDTO activeDTO;
  late List<Result> list = [];
  late List<Cotacoes> cotas = [];
  dynamic dropDownValue = "";
  Activs activs = Activs();
  late Future future;
  List<Cotacoes> cotacoes = [];
  TextEditingController editingController = TextEditingController();
  viewState _state = viewState.Done;
  viewState get state => _state;

  @override
  void initState() {
    fetchData();

    _foundCotacoes = cotacoes;
    super.initState();
  }

  Future<String> fetchData() async {
    String data =
        await DefaultAssetBundle.of(context).loadString("assets/ativos.json");

    final jsonResult = json.decode(data);

    setState(() {
      jsonResult['cotacoes'].forEach((v) {
        cotacoes.add(Cotacoes.fromJson(v));
      });
    });

    return "Success!";
  }

  List<Cotacoes> _foundCotacoes = [];
  void _runFilter(String enteredKeyword) {
    List<Cotacoes> results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = cotacoes;
    } else {
      results = cotacoes
          .where((active) =>
              active.cod!.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
    }

    // Refresh the UI
    setState(() {
      _foundCotacoes = results;
    });
  }

  double getInitialPrice(ActiveDTO activeDTO) {
    List<double>? openPrices =
        activeDTO.chart.result[0].indicators.quote[0].open;
    return openPrices.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("App Variação Ativos"),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) => _runFilter(value),
              controller: editingController,
              decoration: const InputDecoration(
                  labelText: "Search",
                  hintText: "Search",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)))),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _foundCotacoes.length,
              itemBuilder: (context, index) {
                final cota = _foundCotacoes[index];

                return editingController.text.isEmpty
                    ? Container()
                    : ListTile(
                        onTap: () async {
                          ActiveRemoteDataSource activeRemoteDataSource =
                              ActiveRemoteDataSource();
                          activeRemoteDataSource
                              .setFilterSelected("${cota.cod}");
                          List<PriceData> list = await activeRemoteDataSource
                              .loadDataActivs(context);

                          // print(activeRemoteDataSource.filterSelected);

                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("${cota.cod} - Variação Ativo:"),
                                actions: [
                                  ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStatePropertyAll(
                                                  Colors.blue[900])),
                                      onPressed: () async {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ActiveResults(
                                                  data: list,
                                                  initialPrice: getInitialPrice(
                                                      activeRemoteDataSource
                                                          .activeDTO)),
                                            ));
                                      },
                                      child: const Text("Tabela")),
                                  ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStatePropertyAll(
                                                  Colors.blue[900])),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    PriceVariationChart(
                                                        data: list)));
                                      },
                                      child: const Text("Gráfico")),
                                ],
                              );
                            },
                          );
                        },
                        title: Text('${cota.cod}'),
                        trailing: const Icon(Icons.auto_graph_outlined),
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}
