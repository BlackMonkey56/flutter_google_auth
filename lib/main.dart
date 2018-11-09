import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String myText = null;
  StreamSubscription<DocumentSnapshot> subscription;

  final DocumentReference documentReference = Firestore.instance.document("myData/dummy");

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = new GoogleSignIn();
  
  Future<FirebaseUser> _signIn() async{
    GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
    GoogleSignInAuthentication gSA = await googleSignInAccount.authentication;

    FirebaseUser user = await _auth.signInWithGoogle(
        idToken: gSA.idToken, accessToken: gSA.accessToken);

    print("User Name : ${user.displayName}");
    return user;
  }

  void _signOut() {
    _googleSignIn.signOut();
    print("User Signed out");
  }
  
  void _add(){
    Map<String, String> data = <String, String>{
      "name" : "Lee Seokwon",
      "desc" : "Flutter beginner"
    };
    
    documentReference.setData(data).whenComplete((){
      print("Document Added");
    }).catchError((e)=>print(e));
  }
  
  void _delete(){
    documentReference.delete().whenComplete((){
      print("Document Deleted");
    }).catchError((e)=>print(e));
  }
  
  void _update(){
    Map<String, String> data = <String, String>{
      "name" : "Seokwon Lee Update",
      "desc" : "Flutter professional"
    };

    documentReference.updateData(data).whenComplete((){
      print("Document Updated");
    }).catchError((e)=>print(e));
  }
  
  void _fetch(){
    documentReference.get().then((datasnapshot){
      if(datasnapshot.exists){
        setState(() {
          myText = datasnapshot.data['desc'];
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    subscription = documentReference.snapshots().listen((datasnapshot){
      if(datasnapshot.exists){
        setState(() {
          myText = datasnapshot.data['desc'];
        });
      }else{
        myText = "Hello!";
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    subscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Firebase Auth"),
      ),
      body: new Padding(
        padding: const EdgeInsets.all(20.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new RaisedButton(
                onPressed: () => _signIn()
                    .then((FirebaseUser user)=>print(user))
                    .catchError((err) => print(err)),
                child: new Text("Sign In"),
                color: Colors.green,
            ),//RaisedButton
            new Padding(
              padding: const EdgeInsets.all(10.0),
            ),//Padding
            new RaisedButton(
                onPressed: () => _signOut(),
                child: new Text("Sign out"),
                color: Colors.red,
            ),//RaisedButton
            new Padding(
              padding: const EdgeInsets.all(10.0),
            ),//Padding
            new RaisedButton(
              onPressed: () => _add(),
              child: new Text("Add"),
              color: Colors.blue,
            ),//RaisedButton
            new Padding(
              padding: const EdgeInsets.all(10.0),
            ),//Padding
            new RaisedButton(
              onPressed: () => _update(),
              child: new Text("Update"),
              color: Colors.orange,
            ),//RaisedButton
            new Padding(
              padding: const EdgeInsets.all(10.0),
            ),//Padding
            new RaisedButton(
              onPressed: () => _delete(),
              child: new Text("Delete"),
              color: Colors.blueGrey,
            ),//RaisedButton
            new Padding(
              padding: const EdgeInsets.all(10.0),
            ),//Padding
            new RaisedButton(
              onPressed: () => _fetch(),
              child: new Text("Fetch"),
              color: Colors.purpleAccent,
            ),//RaisedButton
            new Padding(
                padding: EdgeInsets.all(20.0),
            ),//Padding
            myText == null ?
              new Container() :
              new Text(
                  myText,
                  style: new TextStyle(fontSize: 20.0),
              ),//Text
          ],//<Widget>[]
        ),//Column
      ),//Padding
    );//Scaffold
  }
}
