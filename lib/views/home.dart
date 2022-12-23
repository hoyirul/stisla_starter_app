import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stisla_starter_app/base_url.dart';
import 'package:stisla_starter_app/models/category_model.dart';
import 'package:http/http.dart' as http;
import 'package:stisla_starter_app/views/add.dart';
import 'package:stisla_starter_app/views/auth.dart';
import 'package:stisla_starter_app/views/edit.dart';

class HomeApp extends StatefulWidget {
  const HomeApp({super.key});

  @override
  State<HomeApp> createState() => _HomeAppState();
}

class _HomeAppState extends State<HomeApp> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  var categoryList = <Category>[];

  Future<List<Category>?> getList() async {
    final prefs = await _prefs;
    var token = prefs.getString('token');
    var headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };
    try {
      var url = Uri.parse(
          UrlHelper().baseUrl + UrlHelper().categories);

      final response = await http.get(url, headers: headers);

      print(response.statusCode);
      print(categoryList.length);
      print(jsonDecode(response.body));

      if (response.statusCode == 200) {
        var jsonString = response.body;
        return categoryFromJson(jsonString);
      }
    } catch (error) {
      print('Testing');
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.purple,
        automaticallyImplyLeading: false,
        actions: [
          TextButton.icon(
            onPressed: () async {
              final SharedPreferences prefs = await _prefs;
              var token = prefs.getString('token');
              var headers = {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token'
              };
              try {
                var url =
                    Uri.parse(UrlHelper().baseUrl + UrlHelper().logout);
                http.Response response = await http.post(url, headers: headers);
                // print(response.statusCode);
                print(response.body);
                print(token);
                prefs.clear();
                // ignore: use_build_context_synchronously
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => const AuthLogin()));
              } catch (error) {
                rethrow;
              }
            }, 
            icon: const Icon(Icons.logout, color: Colors.white,), 
            label: const Text('Logout', style: TextStyle(
              color: Colors.white
            ),)
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10,),

            Padding(
              padding: const EdgeInsets.only(left: 25, right: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(0),
                    width: double.infinity,
                    color: Colors.purple,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const AddData()));
                      },
                      child: const Text('Tambah Data', style: TextStyle(
                        color: Colors.white
                      ),),
                    ),
                  ),

                  const SizedBox(height: 10,),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Kategori', style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    ),)
                  ),

                  const SizedBox(height: 10,),

                  FutureBuilder<List<Category>?>(
                    future: getList(),
                    builder: (context, snapshot) {
                      if(snapshot.hasData){
                        return ListView.builder(
                          padding: const EdgeInsets.all(0),
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: ListTile(
                                title: Text(snapshot.data![index].name),
                                trailing: TextButton(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => EditData(id: snapshot.data![index].id, name: snapshot.data![index].name)));
                                  },
                                  child: const Text('Ubah'),
                                ),
                              ),
                            );
                          },
                        );
                      }else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}