import 'package:flutter/material.dart';
import 'package:smart_bus/models/User.dart';
import 'package:smart_bus/services/local_storage_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? currentUser;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void loadUser(){
    currentUser = LocalStorageService().getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: 50, bottom: 40, left: 20, right: 20),
            decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1B3C83), Color(0xFF76BC41)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
           ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back,color: Colors.white,)
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.white24,
                        child: const Text("JD", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentUser != null ?
                              '${currentUser?.nom}  ${currentUser?.prenom}'
                                  : "User",
                            style: TextStyle(
                                color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold
                            ),
                            ),Text(
                              currentUser != null ?
                              '${currentUser?.email}'
                                  : "User",
                              style: TextStyle(color: Colors.white70, fontSize: 14)
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
