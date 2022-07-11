import 'dart:io';

import 'package:covid19_recognition/widgets/textWidget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String output = '';

  late File pickedImage;

  bool isImageLoaded = false;

  late List result;

  late String accuracy = '';

  late String name = '';

  late String numbers = '';

  getImageCamera() async {
    var tempStore = await ImagePicker().getImage(source: ImageSource.gallery);

    setState(() {
      pickedImage = File(tempStore!.path);
      isImageLoaded = true;
      applyModel(File(tempStore.path));
    });
  }

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/model.tflite', labels: 'assets/labels.txt');
  }

  applyModel(File file) async {
    var res = await Tflite.runModelOnImage(
      path: file.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      result = res!;
      print('result:' + result.toString());
      String str = result[0]['label'];

      name = str.substring(2);
      accuracy = result != null
          ? (result[0]['confidence'] * 100.0).toString().substring(0, 2) + '%'
          : '';

      if (result[0]['index'] == 0) {
        dialog(name, accuracy, Icons.error_outline_rounded);
      } else if (result[0]['index'] == 1) {
        dialog(name, accuracy, Icons.warning_amber_rounded);
      } else if (result[0]['index'] == 2) {
        dialog(name, accuracy, Icons.check);
      } else if (result[0]['index'] == 3) {
        dialog(name, accuracy, Icons.warning_amber_rounded);
      } else {
        dialog('Error', 'Error', Icons.error_outline_rounded);
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    loadModel();
  }

  dialog(String scanResult, String confidence, IconData icon) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: TextWidet(
                text: 'Result',
                fw: FontWeight.w100,
                color: Colors.black,
                fontSize: 14.0,
              ),
              content: SizedBox(
                height: 120,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: Colors.red,
                      size: 62.0,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextWidet(
                      text: 'Result: $scanResult',
                      fw: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 18.0,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextWidet(
                      text: 'Confidence: $confidence',
                      fw: FontWeight.w200,
                      color: Colors.black,
                      fontSize: 14.0,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: TextWidet(
                    text: 'Close',
                    fw: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: TextWidet(
            text: 'Lung Condition Recognizer',
            fw: FontWeight.w300,
            color: Colors.white,
            fontSize: 16.0),
        centerTitle: true,
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isImageLoaded
              ? Center(
                  child: Container(
                  height: 450,
                  width: 330,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: FileImage(
                            pickedImage,
                          ),
                          fit: BoxFit.cover)),
                ))
              : SizedBox(
                  height: 350,
                  child: TextWidet(
                      text: 'No Image Selected',
                      fw: FontWeight.w300,
                      color: Colors.black,
                      fontSize: 18.0),
                ),
          const SizedBox(
            height: 30,
          ),
          RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            color: Colors.red,
            onPressed: () {
              getImageCamera();
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(50, 15, 50, 15),
              child: TextWidet(
                text: 'Choose Picture',
                fw: FontWeight.w300,
                color: Colors.white,
                fontSize: 12.0,
              ),
            ),
          ),
        ],
      )),
    );
  }
}
