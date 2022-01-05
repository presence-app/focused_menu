import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Focused Menu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.lightGreenAccent,
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: <Widget>[
              Text(
                'Music Albums',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...List.generate(
                8,
                (e) => Align(
                  alignment:
                      e.isEven ? Alignment.centerLeft : Alignment.centerRight,
                  child: FocusedMenuHolder(
                    right: e.isOdd,
                    blurSize: 5.0,
                    menuItems: <FocusedMenuItem>[
                      FocusedMenuItem(
                        title: Text('Reply'),
                        trailingIcon: Icon(Icons.open_in_new),
                        onPressed: () {},
                      ),
                      FocusedMenuItem(
                        title: Text('Copy'),
                        trailingIcon: Icon(Icons.share),
                        onPressed: () {},
                      ),
                      FocusedMenuItem(
                        title: Text('Forward'),
                        trailingIcon: Icon(Icons.favorite_border),
                        onPressed: () {},
                      ),
                      FocusedMenuItem(
                        title: Text('Show stickers set'),
                        trailingIcon: Icon(Icons.favorite_border),
                        onPressed: () {},
                      ),
                      FocusedMenuItem(
                        title: Text('Report'),
                        trailingIcon: Icon(Icons.report),
                        onPressed: () {},
                      ),
                      FocusedMenuItem(
                        title: Text(
                          'Delete',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                        trailingIcon: Icon(
                          Icons.delete,
                          color: Colors.redAccent,
                        ),
                        onPressed: () {},
                      ),
                    ],
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text('$e - Hello, is it this one?'),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
