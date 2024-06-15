import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:butterflies/assets/colors.dart';

class ButterflyDescriptionScreen extends StatelessWidget {
  final String butterflyId;

  const ButterflyDescriptionScreen({required this.butterflyId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
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
      ),
      body: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 600) {
              // Large and medium screen layout
              double sidePadding =
                  constraints.maxWidth * 0.2; // 1/5 of the screen width
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: sidePadding),
                child: _buildContent(context, isSmallScreen: false),
              );
            } else {
              // Small screen layout
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildContent(context, isSmallScreen: true),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, {required bool isSmallScreen}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Butterfly ',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Oswald',
                ),
              ),
              TextSpan(
                text: 'Details',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryOrange,
                  fontFamily: 'Oswald',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('butterflies')
              .doc(butterflyId)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Butterfly not found'));
            }

            var butterfly = snapshot.data!.data() as Map<String, dynamic>;

            return isSmallScreen
                ? _buildSmallScreenLayout(butterfly)
                : _buildLargeScreenLayout(butterfly);
          },
        ),
      ],
    );
  }

  Widget _buildLargeScreenLayout(Map<String, dynamic> butterfly) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 4.0,
          color: AppColors.fieldGreyColor,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildButterflyImage(butterfly),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildButterflyDetails(butterfly),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildChatAndComments(),
      ],
    );
  }

  Widget _buildSmallScreenLayout(Map<String, dynamic> butterfly) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 4.0,
          color: AppColors.fieldGreyColor,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildButterflyImage(butterfly),
                const SizedBox(height: 16),
                _buildButterflyDetails(butterfly),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildChatAndComments(),
      ],
    );
  }

  Widget _buildButterflyImage(Map<String, dynamic> butterfly) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: butterfly['imageUrl'] != null
          ? Image.network(
              butterfly['imageUrl'],
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('Error loading image: $error');
                return Image.asset(
                  'assets/images/butterfly1.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                );
              },
            )
          : Image.asset(
              'assets/images/butterfly1.png',
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
    );
  }

  Widget _buildButterflyDetails(Map<String, dynamic> butterfly) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          butterfly['name'] ?? 'Unknown',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Oswald',
            color: AppColors.blackColor,
          ),
        ),
        const SizedBox(height: 8),
        buildFieldRow(
          title: 'Description',
          value: butterfly['description'] ?? 'No description available',
        ),
        const SizedBox(height: 8),
        buildFieldRow(
          title: 'Classification',
          value: butterfly['classification'] ?? 'Unknown',
        ),
        const SizedBox(height: 8),
        buildFieldRow(
          title: 'Geolocation',
          value: butterfly['geolocation'] ?? 'Unknown',
        ),
        const SizedBox(height: 8),
        buildFieldRow(
          title: 'Caption',
          value: butterfly['caption'] ?? 'Unknown',
        ),
        const SizedBox(height: 8),
        buildFieldRow(
          title: 'PDF URL',
          value: butterfly['pdfUrl'] != null
              ? getPdfNameFromUrl(butterfly['pdfUrl'])
              : 'No PDF available',
        ),
      ],
    );
  }

  Widget buildFieldRow({required String title, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title: ',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.blackColor,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.blackColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChatAndComments() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 4.0,
      color: AppColors.fieldGreyColor,
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Chat and Comments',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.blackColor,
                fontFamily: 'Oswald',
              ),
            ),
            SizedBox(height: 16),
            // Add your chat and comments UI here
          ],
        ),
      ),
    );
  }

  String getPdfNameFromUrl(String url) {
    // Find the last occurrence of '%2F' which represents '/'
    int startIndex = url.lastIndexOf('%2F') + 3;

    // Find the position of the '?' which starts the query parameters
    int endIndex = url.indexOf('?');

    // Extract the substring for the file name
    String fileName = url.substring(startIndex, endIndex);

    // Decode URL encoded characters like '%20' which stands for space
    String decodedFileName = Uri.decodeComponent(fileName);

    // Split on the first underscore and take the second part if it exists
    int underscoreIndex = decodedFileName.indexOf('_');
    if (underscoreIndex != -1) {
      decodedFileName = decodedFileName.substring(underscoreIndex + 1);
    }

    return decodedFileName;
  }
}
