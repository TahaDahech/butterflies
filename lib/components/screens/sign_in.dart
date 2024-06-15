import 'package:butterflies/assets/colors.dart';
import 'package:flutter/material.dart';
import 'package:butterflies/data/repository/firebase_auth_repository.dart';
import 'package:butterflies/assets/sizing_utils.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  String? errorMessage = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    SizingData sizing = SizingUtil.getSizingData(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: screenHeight,
          ),
          child: IntrinsicHeight(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF333333),
                image: DecorationImage(
                  image: AssetImage('assets/images/mask.png'),
                  fit: BoxFit.cover,
                  opacity: 0.5,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 40),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            height: sizing.logoHeight,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      sizing.paddingHorizontal,
                      sizing.paddingVertical,
                      sizing.paddingRight,
                      sizing.paddingHorizontal,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 70),
                        Text(
                          'Welcome to Butterflies',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: AppColors.primaryOrange,
                            fontSize: sizing.welcomeFontSize,
                            fontFamily: 'Oswald',
                          ),
                        ),
                        const SizedBox(height: 50),
                        Text(
                          'Your first destination to collect and chat about your butterflies collections.',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontFamily: 'Oswald',
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: sizing.descriptionFontSize,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          'Sign in to a great community of like-minded collectors who appreciate butterflies from all geolocations and classifications.',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontFamily: 'Oswald',
                            color: Colors.white,
                            fontSize: sizing.subtitleFontSize,
                          ),
                        ),
                        const SizedBox(height: 50),
                        _buildLoginButton(sizing.buttonPadding),
                        if (errorMessage != '') _buildErrorMessage(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(EdgeInsets padding) {
    return _isLoading
        ? const CircularProgressIndicator.adaptive()
        : ElevatedButton(
            onPressed: () async {
              setState(() {
                _isLoading = true;
              });

              String? error = await Auth().signInWithGoogle(context);
              setState(() {
                errorMessage = error;
                _isLoading = false;
              });
            },
            style: ElevatedButton.styleFrom(
              padding: padding,
              backgroundColor: AppColors.primaryOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(
                    color: AppColors.primaryOrange), // Border color
              ),
              elevation: 5,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 10),
                Text(
                  'Sign in with Google',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Text(
        errorMessage!,
        textAlign: TextAlign.left,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }
}
