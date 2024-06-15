import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:butterflies/components/screens/add_butterfly.dart';
import 'package:butterflies/data/repository/firebase_auth_repository.dart';
import 'package:butterflies/assets/colors.dart';
import '../../assets/sizing_utils.dart';
import 'butterfly_description_screen.dart'; // Import the ButterflyDescriptionScreen

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Auth _authRepository = Auth();
  String _username = 'Loading...';

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    try {
      Map<String, String>? userData = await _authRepository.getCurrentUser();
      if (userData != null) {
        setState(() {
          _username = userData['displayName'] ?? 'No Username';
        });
      } else {
        setState(() {
          _username = 'User not found';
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        _username = 'Error';
      });
    }
  }

  void _navigateToAddButterfly() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddButterflyScreen()),
    );
  }

  Future<void> _logout() async {
    try {
      await _authRepository.logout(context);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', false);
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    SizingData sizing = SizingUtil.getSizingData(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF333333),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/mask.png'),
              fit: BoxFit.cover,
              opacity: 0.5,
            ),
          ),
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 60,
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CircleAvatar(
              backgroundColor: AppColors.primaryOrange,
              child: Text(
                _username[0],
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
          Center(
            child: Text(
              _username,
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
              ),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: Container(
          color: const Color(0xFF333333),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color(0xFF333333),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primaryOrange,
                      child: Text(
                        _username[0],
                        style:
                            const TextStyle(fontSize: 22, color: Colors.white),
                      ),
                    ),
                    Center(
                      child: Text(
                        _username,
                        style:
                            const TextStyle(fontSize: 22, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton.icon(
                  onPressed: _navigateToAddButterfly,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(
                    'Add Butterfly',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: sizing.buttonFontSize,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: sizing.buttonPadding,
                    minimumSize: Size(double.infinity, sizing.buttonHeight),
                    backgroundColor: AppColors.primaryOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: AppColors.primaryOrange),
                    ),
                    elevation: 5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _logout();
                  },
                  icon: const Icon(Icons.exit_to_app, color: Colors.white),
                  label: Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: sizing.buttonFontSize,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: sizing.buttonPadding,
                    minimumSize: Size(double.infinity, sizing.buttonHeight),
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: AppColors.primaryRed),
                    ),
                    elevation: 5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Row(
        children: [
          if (!sizing.isSmallScreen) // Hide left menu on small screens
            Container(
              width: sizing.drawerWidth,
              color: const Color(0xFF333333),
              child: Column(
                children: [
                  const DrawerHeader(
                    decoration: BoxDecoration(
                      color: Color(0xFF333333),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.collections,
                          size: 50,
                          color: Colors.white,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Collection',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ElevatedButton.icon(
                      onPressed: _navigateToAddButterfly,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: Text(
                        'Add Butterfly',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: sizing.buttonFontSize,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: sizing.buttonPadding,
                        minimumSize: Size(double.infinity, sizing.buttonHeight),
                        backgroundColor: AppColors.primaryOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side:
                              const BorderSide(color: AppColors.primaryOrange),
                        ),
                        elevation: 5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('butterflies')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error fetching data'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No butterflies found'));
                  }

                  var butterflies = snapshot.data!.docs;

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: sizing.gridCrossAxisCount,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                    ),
                    itemCount: butterflies.length,
                    itemBuilder: (context, index) {
                      var butterfly =
                          butterflies[index].data() as Map<String, dynamic>;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ButterflyDescriptionScreen(
                                butterflyId: butterflies[index].id,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 4.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(10.0)),
                                  child: butterfly['imageUrl'] != null
                                      ? Image.network(
                                          butterfly['imageUrl'],
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            print(
                                                'Error loading image: $error');
                                            return Image.asset(
                                              'assets/images/butterfly1.png',
                                              fit: BoxFit.cover,
                                            );
                                          },
                                        )
                                      : Image.asset(
                                          'assets/images/butterfly1.png',
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  butterfly['name'] ?? 'Unknown',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
