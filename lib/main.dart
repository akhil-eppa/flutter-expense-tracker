import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

void main() {
  runApp(myApp());
}

class myApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Expense Tracker",
      theme: new ThemeData(
          primarySwatch: Colors.red,
          backgroundColor: Colors.black,
          accentColor: Colors.redAccent,
          appBarTheme: AppBarTheme(elevation: 1.0)),
      home: new homePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class homePage extends StatefulWidget {
  @override
  _homePageState createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  DocumentReference documentReference =
  Firestore.instance.document("expenses/bwjoyeBCIPj8MtBdUp5R");

  double total = 0;

  void queryValues() {
    Firestore.instance.collection('expenses').snapshots().listen((snapshot) {
      double tempTotal =
      snapshot.documents.fold(0, (tot, doc) => tot + doc.data['exp']);
      setState(() {
        total = tempTotal;
      });
      debugPrint(total.toString());
    });
  }

  void Add(double x) {
    setState(() {
      total = total + x;
    });
  }

  TextEditingController expenseDescInputController;
  TextEditingController expenseExpInputController;
  @override
  void initState() {
    expenseDescInputController = new TextEditingController();
    expenseExpInputController = new TextEditingController();
    super.initState();
    queryValues();
  }

  _showDialog() async {
    await showDialog<String>(
        context: context,
        child: new AlertDialog(
          actions: <Widget>[
            FlatButton(
              child: Text("CANCEL",
                  style: TextStyle(
                      fontSize: 17.0,
                      color: Colors.red,
                      fontWeight: FontWeight.bold)),
              onPressed: () {
                expenseDescInputController.clear();
                expenseExpInputController.clear();
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text("ADD",
                  style: TextStyle(
                      fontSize: 17.0,
                      color: Colors.red,
                      fontWeight: FontWeight.bold)),
              onPressed: () {
                if (expenseExpInputController.text.isNotEmpty &&
                    expenseDescInputController.text.isNotEmpty) {
                  Add(double.parse(expenseExpInputController.text));
                  Firestore.instance
                      .collection("expenses")
                      .document(expenseDescInputController.text)
                      .setData({
                    "desc": expenseDescInputController.text,
                    "exp": double.parse(expenseExpInputController.text)
                  })
                      .then((result) => {
                    expenseDescInputController.clear(),
                    expenseExpInputController.clear(),
                    Navigator.pop(context)
                  })
                      .catchError((err) => print(err));
                  //Firestore.instance.collection("expenses").add(
                  //{"desc":expenseDescInputController.text,
                  //"exp":double.parse(expenseExpInputController.text)
                  //}
                  //).then((result)=>{
                  //expenseExpInputController.clear(),
                  //expenseDescInputController.clear(),
                  //Navigator.pop(context)
                  //}).catchError((err)=>print(err));
                }
              },
            ),
          ],
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.all(15.0),
          content: Column(
            children: <Widget>[
              Text(
                "ENTER NEW EXPENSE",
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 17.0),
              ),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: "Description*"),
                  controller: expenseDescInputController,
                ),
              ),
              Expanded(
                child: new TextField(
                  keyboardType: TextInputType.numberWithOptions(decimal: false),
                  decoration: InputDecoration(labelText: "Amount*"),
                  controller: expenseExpInputController,
                ),
              )
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      drawer: new Drawer(
        elevation: 7.0,
        child: new ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(
                "Total Expenditure",
                style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white70,
                child: Icon(
                  Icons.account_balance_wallet,
                  color: Colors.black,
                ),
              ),
            ),
            new ListTile(
              selected: false,
              contentPadding: EdgeInsets.all(15.0),
              dense: true,
              onTap: () {},
              leading: CircleAvatar(
                child: Icon(Icons.arrow_forward),
              ),
              title: Text(
                "Rs $total",
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
      appBar: new AppBar(
        centerTitle: true,
        toolbarOpacity: 0.75,
        primary: true,
        title: Text(
          "EXPTRAK",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: new Center(
        child: new Container(
          color: Colors.white70,
          padding: EdgeInsets.all(10.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection("expenses").snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return new Text("Error: ${snapshot.error}");
              }
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return new Text("Loading...");
                default:
                  return new ListView(
                    children: snapshot.data.documents
                        .map((DocumentSnapshot document) {
                      return new CustomCard(
                          desc: document['desc'], exp: document['exp']);
                    }).toList(),
                  );
              }
            },
          ),
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        elevation: 6.0,
        focusColor: Colors.indigo,
        backgroundColor: Colors.red,

        onPressed: _showDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}

/*
class CustomCard extends StatelessWidget {
  CustomCard({@required this.desc,this.exp});
  void _delete(String x)
  {
    DocumentReference documentReference=Firestore.instance.document("expenses/"+x);
    documentReference.delete().whenComplete((){print("Deleted Successfully!");
    setState(() {});

    }).catchError((e)=>print(e));

  }
  final desc;
  final exp;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Text(desc),
            Padding(padding: EdgeInsets.only(top:20.0)),
            Text("Rs : $exp"),
            Padding(padding: EdgeInsets.only(top:20.0),),
            RaisedButton(onPressed: (){},child: Text("Delete"),)

          ],
        ),
      ),
    );
  }
}
*/

class CustomCard extends StatefulWidget {
  final desc;
  final exp;
  CustomCard({@required this.desc, this.exp});
  @override
  _CustomCardState createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  @override
  void dispose() {
    super.dispose();
  }

  void _delete() {
    DocumentReference documentReference =
    Firestore.instance.document("expenses/" + widget.desc);
    documentReference.delete().whenComplete(() {
      print("Deleted Successfully!");
      setState(() {});
    }).catchError((e) => print(e));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3.0,
      color: Colors.lightBlueAccent,
      child: Container(
        padding: EdgeInsets.all(15.0),
        child: Column(
          children: <Widget>[
            Text(
              widget.desc,
              style: TextStyle(
                color: Colors.black,
                fontSize: 22.0,
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 10.0)),
            Text("Rs : ${widget.exp}",
                style: TextStyle(color: Colors.black, fontSize: 20.0)),
            Padding(
              padding: EdgeInsets.only(top: 10.0),
            ),
            RaisedButton(
              focusColor: Colors.redAccent,
              splashColor: Colors.redAccent,
              child: Text(
                "Delete",
                style: TextStyle(fontSize: 15.0, color: Colors.grey),
              ),
              onPressed: _delete,
              color: Colors.black87,
              elevation: 5.0,
            )
          ],
        ),
      ),
    );
  }
}
