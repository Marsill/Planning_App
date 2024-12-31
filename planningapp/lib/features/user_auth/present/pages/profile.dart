import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planningapp/features/user_auth/present/pages/login_page.dart';
import 'home_page.dart';

class ProfilePage extends StatefulWidget {
  final String email;
  final String name;

  const ProfilePage({
    super.key,
    required this.email,
    required this.name,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User details
  String displayName = "Loading...";
  String email = "Loading...";
  String phoneNumber = "Loading...";
  String address = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data when the widget initializes
  }

  // Function to load user data
  Future<void> _loadUserData() async {
    if (currentUser != null) {
      final uid = currentUser?.uid;

      try {
        // Fetch data from Firebase Auth
        await currentUser?.reload();
        final updatedUser = FirebaseAuth.instance.currentUser;

        // Fetch additional details from Firestore
        final docSnapshot = await _firestore.collection("users").doc(uid).get();

        if (docSnapshot.exists) {
          final data = docSnapshot.data();
          setState(() {
            displayName = updatedUser?.displayName ?? "No Name";
            email = updatedUser?.email ?? "No Email";
            phoneNumber = data?['phoneNumber'] ?? "No Phone Number";
            address = data?['address'] ?? "No Address";
          });
        } else {
          // If no data exists in Firestore, use Firebase Auth data
          setState(() {
            displayName = updatedUser?.displayName ?? "No Name";
            email = updatedUser?.email ?? "No Email";
            phoneNumber = "No Phone Number";
            address = "No Address";
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading user data: $e")),
        );
      }
    }
  }

  // Helper function to edit a detail
  void _editDetail(String title, String currentValue, Function(String) onSave) {
    TextEditingController controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit $title"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: title,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                onSave(controller.text);
                Navigator.pop(context); // Close dialog
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // Update user profile in Firebase Auth and Firestore
  Future<void> _updateProfile() async {
    try {
      // Update Firebase Auth display name
      await currentUser?.updateDisplayName(displayName);
      await currentUser?.reload(); // Reload to get updated data

      final updatedUser = FirebaseAuth.instance.currentUser;

      // Update additional details in Firestore
      final uid = updatedUser?.uid;
      await _firestore.collection("users").doc(uid).set({
        "phoneNumber": phoneNumber,
        "address": address,
      }, SetOptions(merge: true));

      setState(() {
        displayName = updatedUser?.displayName ?? "No Name";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating profile: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Page"),
      ),
      drawer: Drawer(
        backgroundColor: Colors.grey[300],
        child: ListView(
          children: [
            const DrawerHeader(
              child: Center(
                child: Icon(
                  Icons.menu,
                  size: 64,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                 Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                // Add functionality to update profile picture
                print("Change Profile Picture");
              },
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              displayName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              email,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "My Details",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text("Display Name"),
              subtitle: Text(displayName),
              trailing: const Icon(Icons.edit),
              onTap: () {
                _editDetail("Display Name", displayName, (value) {
                  setState(() {
                    displayName = value;
                  });
                  _updateProfile();
                });
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text("Phone Number"),
              subtitle: Text(phoneNumber),
              trailing: const Icon(Icons.edit),
              onTap: () {
                _editDetail("Phone Number", phoneNumber, (value) {
                  setState(() {
                    phoneNumber = value;
                  });
                  _updateProfile();
                });
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text("Address"),
              subtitle: Text(address),
              trailing: const Icon(Icons.edit),
              onTap: () {
                _editDetail("Address", address, (value) {
                  setState(() {
                    address = value;
                  });
                  _updateProfile();
                });
              },
            ),
            const Divider(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
