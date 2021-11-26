import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'data.dart';

class Cadastro extends StatefulWidget {
  const Cadastro({Key? key}) : super(key: key);

  @override
  _CadastroState createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {

  //Variáveis
  TextEditingController nomeController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController nivelController = TextEditingController();
  TextEditingController pontosController = TextEditingController();
  List<Data> _empresas = [];

  final _gKey = new GlobalKey<ScaffoldState>();

  //Funções
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => _listarEmpresas());
  }

  void _listarEmpresas() async {
    http.Response response =
    await http.get(Uri.parse('http://localhost:8000/api/empresas'));

    var dadosJson = json.decode(response.body);
    var empresa = Json.fromJson(dadosJson);
    List<Data> empresas = [];
    for(var valor in empresa.data){
      empresas.add(Data(id: valor.id, companyname: valor.companyname, email: valor.email, nivel: valor.nivel, pontos: valor.pontos));
    }

    setState(() {
      _empresas = empresas;
    });
  }

  mostrarBottomSheet(){
    _gKey.currentState!.showBottomSheet((context) {
      return Container(
        height: MediaQuery.of(context).size.height * 1.0,
        width: MediaQuery.of(context).size.width * 1.0,
        color: Colors.white70,
        child: _cadastroForm(),
      );
    }
    );
  }

  _salvar() async {
    http.Response response = await http.post(
        Uri.parse('http://localhost:8000/api/empresa/'),
        headers: {"Content-type": "application/json; charset=UTF-8"},
        body: jsonEncode(<String, String>{
          'companyname': nomeController.text,
          'email': nomeController.text,
          'nivel': nivelController.text,
          'pontos': pontosController.text,
        }),
    );
    String texto = "";
    if(response.statusCode==200){
      texto = "Sucesso!";
    }else{
      texto = "Não foi possivel cadastrar!";
    }
    //limpar texto
    nomeController.clear();
    emailController.clear();
    nivelController.clear();
    pontosController.clear();
    //navega para pagina anterior
    Navigator.pop(context);
    //recarrega as empresas
    _listarEmpresas();
    //apresenta mensagem de sucesso ou não
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: Colors.green,
      ),
    );
  }

  _excluir(Data empresa, int index)async{
    http.Response response = await http.delete(
      Uri.parse('http://localhost:8000/api/empresa/'+empresa.id.toString()),
      headers: {"Content-type": "application/json; charset=UTF-8"},
      // body: jsonEncode(<String, String>{
      //   'id': empresa.id.toString(),
      // }),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Deletado'
        ),
        backgroundColor: Colors.red,
      ),
    );
    setState(() {
      _empresas.removeAt(index);
    });
    _listarEmpresas();
    print(response.body);
    // Then show a snackbar.


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _gKey,
      drawer: _drawer(),
      backgroundColor: Colors.white70,
      appBar: _appBar("EcoWay"),
      body: _corpo(),
    );
  }

  _appBar(var titulo){
    return AppBar(
      title: Text(titulo),
      centerTitle: false,
      actions: [
        _iconAdicionar(),
      ],
    );
  }

  _corpo(){
    return Container(
      child: ListView.builder(
          itemCount: _empresas.length,
          itemBuilder: (context, index){
            final empresa = _empresas[index];
            print(_empresas.length);
            return Dismissible(
                key: Key(empresa.toString()),
                child: _cardEmpresa(context, empresa),
              background: _direitaDeletar(),
                secondaryBackground: _esquerdaDeletar(),
              onDismissed:(direction){
                  _excluir(empresa, index);
              }
            );//_cardEmpresa(context, empresa);
          }
      ),
    );
  }

  _iconAdicionar(){
    return Padding(
        padding: EdgeInsets.only(right: 20.0),
        child: GestureDetector(
          onTap: mostrarBottomSheet,
          child: Icon(
            CupertinoIcons.add,
            size: 26.0,
          ),
        )
    );
  }

  _iconFechar(){
    return Padding(
        padding: EdgeInsets.only(right: 20.0),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            CupertinoIcons.xmark,
            size: 20.0,
            color: Colors.black,
          ),
        )
    );
  }

  _botao(String texto){
    return ElevatedButton(
        onPressed: _salvar,//() => Navigator.pop(context),
        child: Text(
            texto,
        ),
    );
  }

  _cardEmpresa(context, empresa){
      return Card(
        child: ListTile(
            title: Text(
              empresa.companyname.toString(),
            ),
            subtitle: Row(
              children: [
                Text(empresa.nivel.toString()),
                SizedBox(width: 5,),
                Icon(CupertinoIcons.star_fill,size: 12,color: Colors.amber,),
              ],
            ),
            leading: Icon(CupertinoIcons.leaf_arrow_circlepath,color: Colors.greenAccent,size: 35,),
        ),
      );
  }

  _cadastroForm(){
    return Scaffold(
      appBar: AppBar(
        leading: _iconFechar(),
        backgroundColor: Colors.white10,
        elevation: 0,
        title: _titulo(),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
       body: Container(
          margin: EdgeInsetsDirectional.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _campoTexto("Nome Empresa", TextInputType.text, nomeController),
              SizedBox(height: 10,),
              _campoTexto("Email", TextInputType.emailAddress, emailController),
              SizedBox(height: 10,),
              _campoTexto("Nivel", TextInputType.number, nivelController),
              SizedBox(height: 10,),
              _campoTexto("Pontos", TextInputType.number, pontosController),
              SizedBox(height: 10,),
              _botao("Salvar"),
            ],
          ),
        ),
    );
  }

  _titulo(){
    return Text(
        "Novo cadastro",
      style: TextStyle(
        color: Colors.green,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  _drawer(){
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green,
            ),
            child: Icon(CupertinoIcons.leaf_arrow_circlepath,color: Colors.greenAccent,size: 100,),
          ),
          ListTile(
            title: const Text('Novo Cadastro'),
            onTap: () {
              Navigator.pop(context);
              mostrarBottomSheet();
            },
          ),
          ListTile(
            title: const Text('Lista Empresas'),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  _campoTexto(String texto, TextInputType tecladoTipo, TextEditingController controleValor){
    return TextField(
      keyboardType: tecladoTipo,
      controller: controleValor,
      decoration: InputDecoration(
        labelText: texto,
      ),
    );
  }

  _direitaDeletar() {
    return Container(
      color: Colors.red,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 20,
            ),
            Icon(
              Icons.delete,
              color: Colors.white,
            ),
            Text(
              " Apagar",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
        alignment: Alignment.centerLeft,
      ),
    );
  }

  _esquerdaDeletar() {
    return Container(
      color: Colors.red,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(
              Icons.delete,
              color: Colors.white,
            ),
            Text(
              " Apagar",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
            SizedBox(
              width: 20,
            ),
          ],
        ),
        alignment: Alignment.centerRight,
      ),
    );
  }

}