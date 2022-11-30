import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:repime/app/blocs/vaga/db/vaga_db.dart';
import 'package:repime/app/blocs/vaga/vaga.dart';

import 'widgtes/cabecalho.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * .05, vertical: size.height * .03),
          child: Column(
            children: [
              Cabecalho(),
            ],
          ),
        ),
      ),
    );
  }
}
