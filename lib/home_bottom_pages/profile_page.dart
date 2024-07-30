import 'dart:io';
import 'package:e_book/framework/colors/appcolors.dart';
import 'package:e_book/login/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; //web
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File? _profileImage;
  String? _savedImagePath;

  @override
  void dispose() {
    if (_profileImage != null) {
      _profileImage!.delete();
    }
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (!kIsWeb) {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        setState(() {
          _profileImage = File(pickedImage.path);
        });
        await _saveImage(_profileImage!);
      }
    }
  }

  Future<void> _saveImage(File image) async {
    if (!kIsWeb) {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/profile_image.png';
      await image.copy(imagePath);
      setState(() {
        _savedImagePath = imagePath;
      });
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.appbuttombar(),
          title:  Text(
            'Success',
            style: TextStyle(
              color: AppColors.text(),
            ),
          ),
          content:  Text(
            'Profile image saved successfully.',
            style: TextStyle(
              color: AppColors.text(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:  Text('OK',
                  style: TextStyle(color:  AppColors.text())),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteImage() async {
    if (!kIsWeb) {
      if (_profileImage != null) {
        await _profileImage!.delete();}
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/profile_image.png';
      final savedImage = File(imagePath);
      if (await savedImage.exists()) {
        await savedImage.delete();}
      setState(() {
        _profileImage = null;
        _savedImagePath = null;
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor:  AppColors.appbuttombar(),
            title:  Text('Success',
                style: TextStyle(color: AppColors.text(),)),
            content: Text('Profile image deleted successfully.',
                style: TextStyle(color:  AppColors.text(),)),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child:  Text('OK',
                    style: TextStyle(color: AppColors.text(),)),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _loadSavedImage();
    }
  }

  Future<void> _loadSavedImage() async {
    if (!kIsWeb) {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/profile_image.png';
      final savedImage = File(imagePath);
      if (await savedImage.exists()) {
        setState(() {
          _savedImagePath = imagePath;
        });
      }
    }
  }

  final user = FirebaseAuth.instance.currentUser!;

  Future<void> _changePassword() async {
    final TextEditingController currentPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();

    await showDialog(
      
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:   AppColors.appbuttombar(),
          title:  Text('Change Password',style: TextStyle(color:  AppColors.text())),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                decoration: const InputDecoration(labelText: 'Current Password',),
                obscureText: true,
              ),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(labelText: 'New Password'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:  Text('Cancel',style: TextStyle(color:  AppColors.text())),
            ),
            TextButton(
              onPressed: () async {
                try {
                  // Re-authenticate the user
                  final credential = EmailAuthProvider.credential(
                    email: user.email!,
                    password: currentPasswordController.text,
                  );
                  await user.reauthenticateWithCredential(credential);
                  // Change the password
                  await user.updatePassword(newPasswordController.text);
                  
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                  showDialog(
                    // ignore: use_build_context_synchronously
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor:  AppColors.appbuttombar(),
                        title: Text('Success',style: TextStyle(color:  AppColors.text())),
                        content: Text('Password changed successfully.',style: TextStyle(color:  AppColors.text())),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child:  Text('OK',style: TextStyle(color:  AppColors.text())),
                          ),
                        ],
                      );
                    },
                  );
                } catch (e) {
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                  showDialog(
                    // ignore: use_build_context_synchronously
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor:  AppColors.appbuttombar(),
                        title:  Text('Error',style: TextStyle(color:  AppColors.text(),),),
                        content: Text("Password is incorrect",style: TextStyle(color:  AppColors.text(),),),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK', style: TextStyle(color:  AppColors.text()),),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child:  Text('Change',style: TextStyle(color:  AppColors.text(),),),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgrouncolor(),
      appBar: AppBar(
        backgroundColor: AppColors.appbuttombar(),
        title: Text(
          'User Profile',
          style: TextStyle(color: AppColors.text()),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.icon(),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      
      body:SingleChildScrollView(
        child: 
       Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.appbuttombar(),
                width: 8.0,
              ),
            ),
            child: CircleAvatar(
              radius: 120,
              backgroundColor:  AppColors.text(),
              backgroundImage: _profileImage != null
                  ? FileImage(_profileImage!)
                  : _savedImagePath != null
                      ? FileImage(File(_savedImagePath!))
                      : const AssetImage('images/resimp.jpg') as ImageProvider,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            FirebaseAuth.instance.currentUser!.email!,
            style:  TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.appbuttombar(),
            ),
          ),
          const SizedBox(height: 40),
          _buildCard(
            context,
            'Change Profile Picture',
            () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor:  AppColors.appbuttombar(),
                    title: Text(
                      'Change Profile Picture',
                      style: TextStyle(color: AppColors.text()),
                    ),
                    content: Text(
                      'Choose an option to change your profile picture:',
                      style: TextStyle(color: AppColors.text()),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _pickImage(ImageSource.camera);
                        },
                        child: Text('Camera',
                            style: TextStyle(color: AppColors.text())),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _pickImage(ImageSource.gallery);
                        },
                        child: Text('Gallery',
                            style: TextStyle(color: AppColors.text())),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 8),
          _buildCard(
            context,
            'Delete Profile Picture',
            _deleteImage,
          ),
          const SizedBox(height: 8),
          _buildCard(
            context,
            'Change Password',
            _changePassword,
          ),
          const SizedBox(height: 8),
          _buildCard(
            context,
            'Sign Out',
            () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Auth()),
              );
            },
          ),
          const SizedBox(height: 8),
          _buildCard(
            context,
            'Exit',
            () {
              SystemNavigator.pop();
            },
          ),
        ],
      ),
    ));
  }

  Widget _buildCard(BuildContext context, String title, VoidCallback onPressed) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 4,
      color: AppColors.button(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.backgrouncolor(),
            minimumSize: const Size.fromHeight(50),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.appbuttombar(),
            ),
          ),
        ),
      ),
    );
  }
}
