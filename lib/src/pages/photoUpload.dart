import 'dart:io';
import 'package:blog/src/pages/home_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class PhotoUpload extends StatefulWidget {
  @override
  _PhotoUploadState createState() => _PhotoUploadState();
}

class _PhotoUploadState extends State<PhotoUpload> {
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  File sampleImage; //Imgane
  String _myValue; //descripcion
  String url; //variable que conte el url de la imagen
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Image'),
        centerTitle: true,
      ),
      body: Center(
        child: sampleImage == null ? Text('Select an Image') : enableUpload(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Add Image',
        child: Icon(
          Icons.add_a_photo,
        ),
      ),
    );
  }

  Widget enableUpload() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              Image.file(
                sampleImage,
                height: 300.0,
                width: 600.0,
              ),
              SizedBox(
                height: 15.0,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: ' Description'),
                validator: (value) {
                  return value.isEmpty ? 'Description is required' : null;
                },
                onSaved: (newValue) {
                  return _myValue = newValue;
                },
              ),
              SizedBox(
                height: 15.0,
              ),
              TextButton(
                child: Text(
                  'Add a new post',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: uploadStatusImage,
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> uploadStatusImage() async {
    //validamos si es que la imagen es valida
    if (validateAndSave()) {
      // subir imagen a firebase storaged
      firebase_storage.Reference postImageRef =
          firebase_storage.FirebaseStorage.instance.ref().child('Post Images');
      print('Image URl' + postImageRef.toString());
      var timeKey = DateTime.now();
      firebase_storage.UploadTask uploadTask =
          postImageRef.child(timeKey.toString() + ".jpg").putFile(sampleImage);
      var imageUrl = await (await uploadTask).ref.getDownloadURL();
      url = imageUrl.toString();
      // Guardar el post a firebase database: database realtime database
      saveToDatabase(url);

      // Regresar a home
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return HomePage();
          },
        ),
      );
    }
  }

  void saveToDatabase(String url) {
    //Guardar un post (imagen, descripcion, fecha,hora)
    //imagen en la variable url
    //descripcion en la variable _myValue
    var dbTimeKey = DateTime.now();
    var formatDate = DateFormat('MMM d, yyyy');
    var formatTime = DateFormat('EEEE, hh:mm aaa');
    String date = formatDate.format(dbTimeKey);
    String time = formatTime.format(dbTimeKey);

    DatabaseReference ref = FirebaseDatabase.instance.reference();
    var data = {
      "image": url,
      "description": _myValue,
      "date": date,
      "time": time,
    };
    ref.child('Posts').push().set(data);
  }

  bool validateAndSave() {
    // creo una variable de tipo form que obtendra el actual estado del formKey
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  Future getImage() async {
    var tempImage = await ImagePicker().getImage(source: ImageSource.camera);
    setState(() {
      sampleImage = File(tempImage.path);
    });
  }
}
