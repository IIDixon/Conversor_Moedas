import 'package:conversor_moedas/pages/homepage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'dart:convert';

var request = Uri.parse('https://api.hgbrasil.com/finance?key=437d34fe'); // Link da API

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  double? usd; // Nessas variáveis serão armazenados os valores da moeda convertidos em reais, quantos reais são equivalentes a 1 dólar
  double? euro; // Nessas variáveis serão armazenados os valores da moeda convertidos em reais, quantos reais são equivalentes a 1 euro

  final realController = TextEditingController(); // Controller para o textfield referente ao real
  final dolarController = TextEditingController(); // Controller para o textfield referente ao dolar
  final euroController = TextEditingController(); // Controller para o textfield referente ao euro

  void _realChanged(String text){ // Função que recalcula os demais campos ao alterar o textfield do real
    double real = double.parse(text); // cria uma varíavel a passa o texto digitado no textfield como parâmetro
    dolarController.text = (real / usd!).toStringAsFixed(2); // Exemplo de cálculo: texto digitado em real 5, então faz a divisão pelo valor do dólar,4.77, então, 5 reais é equivalente a 1,04 dólares
    euroController.text = (real / euro!).toStringAsFixed(2); // Exemplo de cáclulo: texto digitado em real 5, então faz a divisão pelo valor do euro, 5.26, então 5 reais é equivalente a 0,95 Euros
  }

  void _dolarChanged(String text){ // Função que recalcula os demais campos ao alterar o textfield do dólar
    double dolar = double.parse(text); // Cria uma variável e passa o texto digitado no textfield como parâmetro
    realController.text = (dolar * usd!).toStringAsFixed(2); // Exemplo de cálculo: texto digitado em dolar 5, então faz a multiplicação pelo valor do dólar em real obtido como resultado da API, 4.77, então 5 dólares é equivalente a 23,85 reais
    euroController.text = (dolar * usd! / euro!).toStringAsFixed(2); // Exemplo de cálculo: texto digitado em dolar 5, então faz a multiplicação pelo valor do dólar em real obtido como resultado da API, 4.77,
  }                                                                  //e então divide pelo valor do euro em reais retornado da API, 5.26, então 5 dolares é equivalente a 4,53 euros

  void _euroChanged(String text){ // Função que recalcula os demais campos ao alterar o textfield do euro
  double eur = double.parse(text); // cria uma varíavel a passa o texto digitado no textfield como parâmetro
  realController.text = (eur * euro!).toStringAsFixed(2); // Exemplo de cálculo: texto digitado em euro 5, então faz a multiplicação pelo valor do euro em real obtido como resultado da API, 5.26, então 5 euros é equivalente a 26,32 reais
  dolarController.text = (eur * euro! / usd!).toStringAsFixed(2); // Exemplo de cálculo: texto digitado em euro 5, então faz a multiplicação pelo valor do euro em real obtido como resultado da API, 5.26
  }                                                               // e então divide pelo valor do dolar em reais retornado da API, 4.76, então 5 euro é equivalente a 5,52 dólares

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('\$ Conversor de Moedas \$'),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>( // Indica que irá retornar uma construção futura do widget
        future: getData(), // Aguardará o retorno da função para retornar a construção futura
        builder: (context, snapshot){ // context seria a construção do widget, snapshot é o resultado do future que estamos aguardando, que seria o retorno do getdata()
          switch(snapshot.connectionState){ // switch para estados da conexão
            case ConnectionState.none: // caso não tenha conexão ainda
            case ConnectionState.waiting: // caso a conexão esteja esperando retorno
              return const Center( // Irá retornar uma tela com informativo de que está aguardando o retorno da solicitação
                child:
                Text('Carregando Dados...',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            default: // Retorno padrão
              if(snapshot.hasError){ // se ocorrer erro na conexão, retornará mensagem de que houve erro ao carregar os dados
                return const Center(
                  child:
                  Text('Erro ao carregar dados =(',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              } else{ // caso contrário, significa que a solicitação ocorreu com sucesso, sendo assim já temos o retorno com os valores solicitados
                usd = snapshot.data!["results"]["currencies"]["USD"]["buy"]; // Atribui o valor a variável de acordo com o valor retornado no JSON da solicitação do link incluso na var request
                euro = snapshot.data!["results"]["currencies"]["EUR"]["buy"]; // Atribui o valor a variável de acordo com o valor retornado no JSON da solicitação do link incluso na var request
                return Padding( // constrói a tela com os campos
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView( // widget que serve para que quando abra o teclado, parte da tela não fique coberta pelo mesmo
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch, // Ocupa sempre o maior espaço disponível no eixo cruzado
                      children: [
                        const Icon(Icons.monetization_on, size: 150, color: Colors.amber),
                        const Divider(), // Separa os campos
                        buildTextField("Reais", "R\$", realController,_realChanged), // Função de construção do widget
                        // Note que na chamado da função que definimos uma string como parâmetro na criação, não foi passado o parâmetro na chamada
                        //  Isso ocorre porque quando passamos essa função no onChanged do textfield, o flutter interpreta que a String a ser passada
                        // é o próprio texto que está sendo digitado no textfield
                        const Divider(), // Separa os campos
                        buildTextField("Dólares", "US\$", dolarController, _dolarChanged), // Função de construção do widget
                        const Divider(), // Separa os campos
                        buildTextField("Euros", "€", euroController, _euroChanged), // Função de construção do widget
                      ],
                    ),
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix, TextEditingController controller, Function(String) function){
  return TextField(
    keyboardType: TextInputType.number,
    onChanged: function, // atribui a função passada por parâmetro
    // Note que na chamado da função que definimos uma string como parâmetro na criação, não foi passado o parâmetro na chamada
    //  Isso ocorre porque quando passamos essa função no onChanged do textfield, o flutter interpreta que a String a ser passada
    // é o próprio texto que está sendo digitado no textfield
    controller: controller, // atribui o controller passado por parâmetro
    decoration: InputDecoration(
      labelText: label, // atribui a label passado por parâmetro
      labelStyle: const TextStyle(
        color: Colors.amber,
      ),
      border: const OutlineInputBorder(),
      prefixText: prefix, // atribui ao prefixo passado por parâmetro
    ),
    style: const TextStyle(
      color: Colors.amber,
      fontSize: 25,
    ),
  );
}

Future<Map> getData() async{ // Função que faz a solicitação dos dados a API e aguarda seu retorno para retornar o valor
  http.Response response = await http.get(request); // atribui o retorno a variável response | É retornado uma string
  return json.decode(response.body); // Estrutura o corpo da string em formato JSON e retorna-o como resultado da função
}