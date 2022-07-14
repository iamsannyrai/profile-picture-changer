import 'dart:io';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'amplifyconfiguration.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Picture Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Profile Picture'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? image;
  bool loading = false;
  final picker = ImagePicker();

  Future<void> _configureAmplify() async {
    final auth = AmplifyAuthCognito();
    final storage = AmplifyStorageS3();
    await Amplify.addPlugins([storage, auth]);
    try {
      await Amplify.configure(amplifyconfig);
    } on Exception catch (e) {
      debugPrint('Tried to configure Amplify and following error occurred: $e');
    }
  }

  Future<void> uploadImageAndSetImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      return;
    }

    final key = DateTime.now().toString();
    final file = File(pickedFile.path);
    try {
      final UploadFileResult result = await Amplify.Storage.uploadFile(
        local: file,
        key: key,
        onProgress: (progress) {
          debugPrint(
              "${progress.currentBytes}, total: ${progress.totalBytes}, ${progress.getFractionCompleted()}");
        },
      );
      final imageUrl = await getImageUrl(result.key);
      setState(() {
        image = imageUrl;
      });
    } on StorageException catch (e) {
      debugPrint('Error uploading image: $e');
    }
  }

  Future<String> getImageUrl(String bucketKey) async {
    try {
      final result = await Amplify.Storage.getUrl(key: bucketKey);
      return result.url;
    } on StorageException catch (e) {
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () async {
            setState(() {
              loading = true;
            });
            await uploadImageAndSetImage();
            setState(() {
              loading = false;
            });
          },
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: CircleAvatar(
                  radius: 100,
                  backgroundColor: Colors.grey,
                  backgroundImage: image != null ? NetworkImage(image!) : null,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: loading ? const CircularProgressIndicator() : null,
              )
            ],
          ),
        ),
      ),
    );
  }
}
