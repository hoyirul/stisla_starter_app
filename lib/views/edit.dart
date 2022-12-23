import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stisla_starter_app/base_url.dart';
import 'package:stisla_starter_app/views/home.dart';
import 'package:http/http.dart' as http;

class EditData extends StatefulWidget {
  final int id;
  final String name;
  const EditData({super.key, required this.id, required this.name});

  @override
  State<EditData> createState() => _EditDataState();
}

class _EditDataState extends State<EditData> {
  TextEditingController categoryController = TextEditingController();
  final Future<SharedPreferences> prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    setState(() {
      categoryController.text = widget.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Kategori'), backgroundColor: Colors.purple,),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 25, right: 25),
          child: Column(
            children: [
              const SizedBox(height: 20,),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Nama Kategori', style: TextStyle(
                  fontSize: 16
                ),)
              ),

              const SizedBox(height: 10,),
              
              TextFormField(
                controller: categoryController,
                decoration: const InputDecoration(
                  hintText: 'Nama Kategori',
                  hintStyle: TextStyle(
                    fontSize: 14
                  )
                ),
              ),

              const SizedBox(height: 20,), 

              Container(
                padding: const EdgeInsets.only(left: 20, right: 20),
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.purple,
                ),
                child: TextButton(
                  onPressed: () async {
                    final _prefs = await prefs;
                    var token = _prefs.getString('token');
                    var headers = {
                      'Content-Type': 'application/json',
                      'Accept': 'application/json',
                      'Authorization': 'Bearer $token'
                    };

                    Map body = {
                      'name': categoryController.text.trim(),
                    };

                    final url = Uri.parse('${UrlHelper().baseUrl + UrlHelper().categories}/${widget.id}');

                    try{
                      final response = await http.put(url, body: jsonEncode(body), headers: headers);
                      print(response.statusCode);
                      print(response.body);

                      if(response.statusCode == 200){
                        categoryController.clear();
                        print(response.body);
                        // ignore: use_build_context_synchronously
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => const HomeApp()));
                      }else if(response.statusCode == 422){
                        throw jsonDecode(response.body)['message'] ?? 'Unknown Error Occured';
                      }else if(response.statusCode == 400){
                        throw jsonDecode(response.body)['errors'] ?? 'Unknown Error Occured';
                      }
                    }catch(error){
                      showDialog(
                        context: context,
                        builder: (context) {
                          return SimpleDialog(
                            title: const Text('Info', style: TextStyle(
                              color: Colors.black,
                            ),),
                            contentPadding: const EdgeInsets.all(20),
                            children: [Text(error.toString())],
                          );
                        });
                    }
                  },
                  child: const Text('Ubah', style: TextStyle(
                    color: Colors.white,
                    fontSize: 16
                  ),),
                ),
              ),

              const SizedBox(height: 10,),

              Container(
                padding: const EdgeInsets.only(left: 20, right: 20),
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.red,
                ),
                child: TextButton(
                  onPressed: () async {
                    final _prefs = await prefs;
                    var token = _prefs.getString('token');
                    var headers = {
                      'Content-Type': 'application/json',
                      'Accept': 'application/json',
                      'Authorization': 'Bearer $token'
                    };

                    final url = Uri.parse('${UrlHelper().baseUrl + UrlHelper().categories}/${widget.id}');

                    try{
                      final response = await http.delete(url, headers: headers);
                      print(response.statusCode);
                      print(response.body);

                      if(response.statusCode == 204){
                        categoryController.clear();
                        print(response.body);
                        // ignore: use_build_context_synchronously
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => const HomeApp()));
                      }else if(response.statusCode == 422){
                        throw jsonDecode(response.body)['message'] ?? 'Unknown Error Occured';
                      }else if(response.statusCode == 400){
                        throw jsonDecode(response.body)['errors'] ?? 'Unknown Error Occured';
                      }
                    }catch(error){
                      showDialog(
                        context: context,
                        builder: (context) {
                          return SimpleDialog(
                            title: const Text('Info', style: TextStyle(
                              color: Colors.black,
                            ),),
                            contentPadding: const EdgeInsets.all(20),
                            children: [Text(error.toString())],
                          );
                        });
                    }
                  },
                  child: const Text('Hapus', style: TextStyle(
                    color: Colors.white,
                    fontSize: 16
                  ),),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}