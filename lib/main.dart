import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:variacao_ativo_flutter/core/data/datasource/active_local_datajson.dart';
import 'package:variacao_ativo_flutter/core/data/datasource/active_remote_datasource.dart';
import 'package:variacao_ativo_flutter/feature/active/page/active_list_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChangeNotifier>(
            create: (context) => ActiveRemoteDataSource())
      ],
      child: MaterialApp(
        theme: ThemeData(appBarTheme: AppBarTheme(color: Colors.blue[900])),
        debugShowCheckedModeBanner: false,
        home: const ActiveHome(),
      ),
    );
  }
}
