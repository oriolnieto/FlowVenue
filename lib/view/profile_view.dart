import 'package:flutter/material.dart';

class profile_view extends StatefulWidget {
  const profile_view({super.key});

  @override
  State<profile_view> createState() => _profile_viewState();
}

class _profile_viewState extends State<profile_view> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Background_App.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 75,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 70,
                      backgroundImage: AssetImage('assets/defaultPfp.jpg'),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'username',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: 390,
              left: 60,
              child: Container(
                width: 500,
                height: 500,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/pfpToca.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}