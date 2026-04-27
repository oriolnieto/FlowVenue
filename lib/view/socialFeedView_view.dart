import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/model/users_model.dart';
import 'CreatePostView_view.dart';

class SocialFeedView extends StatefulWidget {
  final Usuari usuari;

  const SocialFeedView({super.key, required this.usuari});

  @override
  _SocialFeedViewState createState() => _SocialFeedViewState();
}

class _SocialFeedViewState extends State<SocialFeedView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE94E77),
        elevation: 5,
        child: const Icon(Icons.add_comment, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreatePostView(usuari: widget.usuari),
            ),
          );
        },
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Background_App.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text("No hi ha posts encara!",
                            style: TextStyle(color: Colors.white70)),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var post = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                        return _buildPostCard(
                          username: post['username'] ?? 'Anònim',
                          content: post['content'] ?? '',
                        );
                      },
                    );
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text("©2026 FlowVenue by Oriol&Jan",
                    style: TextStyle(color: Colors.white54, fontSize: 10)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Image.asset(
            'assets/Logo_FlowVenue.png',
            height: 40,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard({
    required String username,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Colors.white38,
            blurRadius: 10,
            spreadRadius: 1,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundColor: Color(0xFFF1B1CB),
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 15),
              Text(
                "@$username",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            content,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}