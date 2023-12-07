import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'take_picture.dart';
import 'list_items.dart';

class NewPost extends StatefulWidget {
  const NewPost({super.key});

  @override
  State<NewPost> createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  final _formKey = GlobalKey<FormState>();

  final itemImages = <String>[];

  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final storageRef =
  FirebaseStorage.instance.ref().child("002127437_finalproject");
  final db = FirebaseFirestore.instance;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  Future<void> takeApicture(BuildContext context) async {
    final cameras = await availableCameras();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => TakePictureScreen(
            camera: cameras.first,
          )),
    );

    if (!mounted) return;

    setState(() {
      itemImages.add(result);
    });
  }

  uploadPost(BuildContext context) async {
    var imgUrls = <String>[];
    for (var img in itemImages) {
      final fileName = basename(img);
      final imgRef = storageRef.child(fileName);
      final imgFile = File(img);
      await imgRef.putFile(imgFile);
      final imgUrl = await imgRef.getDownloadURL();
      imgUrls.add(imgUrl.toString());
    }

    final item = <String, dynamic>{
      "title": titleController.text,
      "price": "\$${priceController.text}",
      "description": descriptionController.text,
      "images": imgUrls
    };
    db
        .collection('002127437_docs')
        .doc(titleController.text)
        .set(item)
        .then((value) => Navigator.pop(context, "New Item Added."));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new Item'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Hyper Garage Sale',
                style: TextStyle(fontSize: 36, color: Color(0xFFFFFFFF)),
              ),
            ),
            ListTile(
              title: const Text("Item List"),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MyHomePage()));
              },
            ),
            ListTile(
              title: const Text("Sign Out"),
              onTap: () async {
                await _firebaseAuth.signOut();
              },
            ),
          ],
        ),
      ),
      //test
      body: Form(
        key: _formKey,
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(hintText: "Enter Title"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid title';
                    }
                    return null;
                  },
                  controller: titleController,
                ),
                TextFormField(
                  decoration: const InputDecoration(hintText: "Enter Price"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    return null;
                  },
                  controller: priceController,
                ),
                TextFormField(
                  decoration:
                  const InputDecoration(hintText: "Enter Description"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                  minLines: 3,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  controller: descriptionController,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          takeApicture(context);
                        },
                        child: Row(
                          children: const [
                            Text("Take a picture and upload  "),
                            Icon(Icons.add_a_photo)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 25),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 300,
                      child:
                      ListView(scrollDirection: Axis.horizontal, children: [
                        for (var img in itemImages)
                          Image.file(
                            File(img),
                            width: MediaQuery.of(context).size.width,
                            height: 300,
                            fit: BoxFit.cover,
                          )
                      ]),
                    )),
                Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        uploadPost(context);
                      }
                    },
                    child: const Text("Submit"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
