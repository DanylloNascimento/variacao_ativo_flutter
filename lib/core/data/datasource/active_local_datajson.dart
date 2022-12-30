import 'dart:convert';
import 'dart:async' show Future;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class Activs with ChangeNotifier {
  List<Cotacoes>? cotacoes;

  Activs({this.cotacoes});

  Activs.fromJson(Map<String, dynamic> json) {
    if (json['cotacoes'] != null) {
      cotacoes = <Cotacoes>[];

      json['cotacoes'].forEach((v) {
        cotacoes!.add(Cotacoes.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (cotacoes != null) {
      data['cotacoes'] = cotacoes!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  Future<String> _refreshActivJson() async {
    return await rootBundle.loadString('assets/ativos.json');
  }

  Future refreshActivs() async {
    String jsonString = await _refreshActivJson();
    final jsonResponse = json.decode(jsonString);

    return Activs.fromJson(jsonResponse);
  }
}

class Cotacoes {
  String? cod;

  Cotacoes({this.cod});

  Cotacoes.fromJson(Map<String, dynamic> json) {
    cod = json['cod'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cod'] = cod;
    return data;
  }
}
