import 'package:flutter/material.dart';
import 'package:variacao_ativo_flutter/core/data/datasource/active_remote_datasource.dart';

class ActiveResults extends StatefulWidget {
  final List<PriceData> data;
  final double initialPrice;

  const ActiveResults(
      {super.key, required this.data, required this.initialPrice});

  @override
  State<ActiveResults> createState() => _ActiveResultsState();
}

class _ActiveResultsState extends State<ActiveResults> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Variação de Preço'),
      ),
      body: SafeArea(
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: DataTable(
                    border: TableBorder.all(color: Colors.black),
                    columns: const [
                      DataColumn(
                        label: Text('Data'),
                      ),
                      DataColumn(
                        label: Text('Preço'),
                      ),
                      DataColumn(
                        label: Text('Variação'),
                      ),
                    ],
                    rows: widget.data.map((priceData) {
                      return DataRow(
                        cells: [
                          DataCell(Text(
                              priceData.formatTimestamp(priceData.timestamp))),
                          DataCell(
                            Text(priceData.formatPrice(priceData.price)),
                          ),
                          DataCell(
                            Text(priceData.variation.toStringAsFixed(5)),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Rentabilidade: ${((widget.data.last.price - widget.initialPrice) / widget.initialPrice * 100).toStringAsFixed(2)}%',
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
