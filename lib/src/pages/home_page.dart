import 'package:blog/src/pages/photoUpload.dart';
import 'package:blog/src/widgets/posts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Posts> postList = [];
  @override
  void initState() {
    super.initState();
    DatabaseReference postRef =
        FirebaseDatabase.instance.reference().child('Posts');
    print('llave de la referencia al post: ' + postRef.key);
    postRef.once().then((DataSnapshot snapshot) {
      print('estas son las keys: ${snapshot.value}');
      var keys = snapshot.value.keys;
      var data = snapshot.value;

      postList.clear();
      for (var individualKey in keys) {
        Posts posts = Posts(
          data[individualKey]['image'],
          data[individualKey]['description'],
          data[individualKey]['date'],
          data[individualKey]['time'],
        );
        postList.add(posts);
      }
      setState(() {
        print('Length: ${postList.length}');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HOME'),
      ),
      body: Container(
        child: postList.length == 0
            ? Text('No Blog available')
            : ListView.builder(
                itemCount: postList.length,
                itemBuilder: (context, index) {
                  return postsUI(
                    postList[index].image,
                    postList[index].description,
                    postList[index].date,
                    postList[index].time,
                  );
                },
              ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.pink,
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.add_a_photo),
                iconSize: 40,
                color: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return PhotoUpload();
                      },
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget postsUI(String image, String description, String date, String time) {
    return Card(
      elevation: 10.0,
      margin: EdgeInsets.all(14.0),
      child: Container(
        padding: EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  date,
                  style: Theme.of(context).textTheme.subtitle2,
                  textAlign: TextAlign.center,
                ),
                Text(
                  time,
                  style: Theme.of(context).textTheme.subtitle2,
                  textAlign: TextAlign.center,
                )
              ],
            ),
            SizedBox(height: 10.0),
            Image.network(
              image,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 10.0),
            Text(
              description,
              style: Theme.of(context).textTheme.subtitle1,
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
