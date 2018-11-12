import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'services/crud.dart';
import 'dart:async';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => new _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  String carModel;
  String carColor;

  Stream cars;

  crudMethods crudObj = new crudMethods();

  Future<bool> addDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text('Add Data', style: TextStyle(fontSize: 15.0),),
          content: Column(
            children: <Widget>[
              TextField(
                decoration: InputDecoration(hintText: 'Enter car name'),
                onChanged: (value) {
                  this.carModel = value;
                },
              ),//TextField
              SizedBox(height: 5.0,),
              TextField(
                decoration: InputDecoration(hintText: 'Enter car color'),
                onChanged: (value) {
                  this.carColor = value;
                },
              ),//TextField
            ],//<Widget>[]
          ),//Column
          actions: <Widget>[
            FlatButton(
              child: Text('Add'),
              textColor: Colors.blue,
              onPressed: (){
                Navigator.of(context).pop();
                Map<String, String> carData = {
                  'carName': this.carModel,
                  'color': this.carColor
                };
                crudObj.addData(carData).then((result){
                  dialogTrigger(context);
                }).whenComplete((){
                  crudObj.getData().then((results){
                    setState(() {
                      cars = results;
                    });
                  });
                }).catchError((e){
                  print(e);
                  print('Here here');
                });
              },
            ),//FlatButton
          ],//<Widget>[]
        );//AlertDialog
      });//showDialog
  }

  Future<bool> updateDialog(BuildContext context, selectedDoc) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text('Update Data', style: TextStyle(fontSize: 15.0),),
            content: Column(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(hintText: 'Enter car name'),
                  onChanged: (value) {
                    this.carModel = value;
                  },
                ),//TextField
                SizedBox(height: 5.0,),
                TextField(
                  decoration: InputDecoration(hintText: 'Enter car color'),
                  onChanged: (value) {
                    this.carColor = value;
                  },
                ),//TextField
              ],//<Widget>[]
            ),//Column
            actions: <Widget>[
              FlatButton(
                child: Text('Update'),
                textColor: Colors.blue,
                onPressed: (){
                  Navigator.of(context).pop();
                  crudObj.updateData(selectedDoc, {
                    'carName': this.carModel,
                    'color' : this.carColor
                  }).then((result){

                  }).catchError((e){
                    print(e);
                  });
                },
              ),//FlatButton
            ],//<Widget>[]
          );//AlertDialog
        });//showDialog
  }

  Future<bool> dialogTrigger(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text('Job Done', style: TextStyle(fontSize: 15.0),),
          content: Text('Added'),
          actions: <Widget>[
            FlatButton(
              child: Text('Alright'),
              textColor: Colors.blue,
              onPressed: () {
                Navigator.of(context).pop();
              },
            )//FlatButton
          ],//<Widget>[]
        );//AlertDialog
      }//showDialog
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    crudObj.getData().then((results){
      setState(() {
        cars = results;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: (){
              addDialog(context);
            },
          ),//IconButton
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: (){
              crudObj.getData().then((results){
                setState(() {
                  cars = results;
                });
              });
            },
          ),//IconButton
        ],//<Widget>[]
      ),//AppBar
      body: _carList(),//Center
    );
  }

  Widget _carList(){
    if(cars != null){
      return StreamBuilder(
        stream: cars,
        builder: (context, snapshot){
          return ListView.builder(
            itemCount: snapshot.data.documents.length,
            padding: EdgeInsets.all(5.0),
            itemBuilder: (context, i) {
              return new ListTile(
                title: Text(snapshot.data.documents[i].data['carName']),
                subtitle: Text(snapshot.data.documents[i].data['color']),
                onTap: (){
                  updateDialog(context, snapshot.data.documents[i].documentID);
                },
                onLongPress: (){
                  crudObj.deleteDate(snapshot.data.documents[i].documentID);
                },
              );//ListTile
            },
          );//ListView.builder
        },
      );
    }
    else{
      return Text('Loading, Please wait..');
    }
  }
}
