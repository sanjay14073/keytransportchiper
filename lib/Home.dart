import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController t1=TextEditingController();
  TextEditingController t2=TextEditingController();
  late final SharedPreferences p;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setInstance();
  }
  Future<void>setInstance()async{
    p=await SharedPreferences.getInstance();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Tansportation algorithm"),
        backgroundColor: AppColors.appBarColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(controller: t1,maxLines: 10,style: TextStyle(color: AppColors.textColor,),decoration: InputDecoration(hintText: "Enter The text To Be encrypted or decrypted",hintStyle: TextStyle(color: AppColors.textColor)),),
              SizedBox(height: 20,),
              MaterialButton(onPressed: ()async{
                var url=Uri.parse("http://192.168.1.40:3300/encrypt");
                var data={
                  "message":t1.text,
                  "key":(t1.text.length-1)>0?(Random().nextInt(150))%(t1.text.length-1):1,
                };
                var body=jsonEncode(data);
                var response=await http.post(url,body: body);
                var result=response.body;
                if(response.statusCode!=200){

                  return;
                }
                t1.clear();
                Map<String,dynamic>m=json.decode(result);
                return showDialog<void>(
                  context: context,
                  barrierDismissible: false, // user must tap button!
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Encrypted message'),
                      content:  SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Text("${m["ans"]}\n"),
                            Text("The Key For your Decryption is ${m["key"]}"),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Save The String and exit'),
                          onPressed: () async{
                            await p.setInt(m["ans"], m["key"]);
                            await Clipboard.setData(ClipboardData(text: m["ans"]));
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text('Do not Save The String and exit'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },child: Text("Encrypt Now with automatic generated key",style: TextStyle(color: Colors.white),),color: AppColors.encryptButtonColor,minWidth: double.infinity,),
              //Another method with custom key
              MaterialButton(onPressed: ()async{
                return showDialog<void>(
                    context: context,
                    barrierDismissible: false, // user must tap button!
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Enter Key'),
                        content: TextField(controller: t2,decoration: InputDecoration(hintText: "Enter the code"),),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Continue'),
                            onPressed: () async{
                              Navigator.of(context).pop();
                              var url=Uri.parse("http://192.168.1.40:3300/encrypt");
                              var data={
                                "message":t1.text,
                                "key":(t1.text.length-1)>0?(int.parse(t2.text))%(t1.text.length-1):1,
                              };
                              var body=jsonEncode(data);
                              var response=await http.post(url,body: body);
                              var result=response.body;
                              if(response.statusCode!=200){

                                return;
                              }
                              t1.clear();
                              t2.clear();
                              Map<String,dynamic>m=json.decode(result);
                              return showDialog<void>(
                                context: context,
                                barrierDismissible: false, // user must tap button!
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Encrypted message'),
                                    content:  SingleChildScrollView(
                                      child: ListBody(
                                        children: <Widget>[
                                          Text("${m["ans"]}\n"),
                                          Text("The Key For your Decryption is ${m["key"]}"),
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Save The String and exit'),
                                        onPressed: () async{
                                          await p.setInt(m["ans"], m["key"]);
                                          await Clipboard.setData(ClipboardData(text: m["ans"]));
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('Do not Save The String and exit'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      );
                    });
              },
                child: Text("Encrypt Now with custom key Now",style: TextStyle(color: Colors.white),),color: AppColors.encryptButtonColor,minWidth: double.infinity,
              ),

              MaterialButton(onPressed: ()async{

                int? key=p.getInt(t1.text);
                if(key==null||t1.text==""){
                  ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text("Sorry Couldn't find the Encrypted text make sure you did save your key"),backgroundColor: Colors.redAccent,));
                  return;
                }
                print(key);
                var url=Uri.parse("http://192.168.1.40:3300/decrypt");
                var data={
                  "message":t1.text,
                  "key":key,
                };
                var body=jsonEncode(data);
                var response=await http.post(url,body: body);
                Map<String,dynamic>m=json.decode(response.body);
              return showDialog<void>(
              context: context,
              barrierDismissible: false, // user must tap button!
              builder: (BuildContext context) {
                      return AlertDialog(
                       title: Text('Decrypted Message'),
                      content:  SingleChildScrollView(
                    child: ListBody(
                  children: <Widget>[
                    Text("Decrypted message\n${m["ans"]}"),

                  ],
                  ),
                  ),
                  actions: <Widget>[
                    TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                    //await p.setInt(m["ans"], m["key"]);
                    Navigator.of(context).pop();
                      },
                      ),
                    ],
                  );
              });},child: Text("Search for key and Decrypt Now",style: TextStyle(color: Colors.white),),color: AppColors.decryptButtonColor,minWidth: double.infinity,),
              MaterialButton(onPressed: ()async{
                 return showDialog<void>(
                    context: context,
                    barrierDismissible: false, // user must tap button!
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Enter Key'),
                        content: TextField(controller: t2,decoration: InputDecoration(hintText: "Enter the code"),),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Continue'),
                            onPressed: () async{
                              Navigator.of(context).pop();
                              var url=Uri.parse("http://192.168.1.40:3300/decrypt");
                              var data={
                                "message":t1.text,
                                "key":int.parse(t2.text),
                              };
                              var body=jsonEncode(data);
                              var response=await http.post(url,body: body);
                              Map<String,dynamic>m=json.decode(response.body);
                               return showDialog<void>(
                                  context: context,
                                  barrierDismissible: false, // user must tap button!
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Decrypted Message'),
                                      content:  SingleChildScrollView(
                                        child: ListBody(
                                          children: <Widget>[
                                            Text("Decrypted message\n${m["ans"]}"),

                                          ],
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('Ok'),
                                          onPressed: () {
                                            //await p.setInt(m["ans"], m["key"]);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  });
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    });
              },child: Text("Enter key Manually and Decrypt Now",style: TextStyle(color: Colors.white),),color: AppColors.decryptButtonColor,minWidth: double.infinity,),
            ],
          ),
        ),
      ),
    );
  }
}
