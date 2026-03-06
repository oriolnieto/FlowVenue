import 'package:flutter/material.dart';

class SocialFeedView extends StatefulWidget {
  const SocialFeedView({super.key});
  @override
  _SocialFeedViewState createState() => _SocialFeedViewState();
}

class _SocialFeedViewState extends State<SocialFeedView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Fons amb el gradient corporatiu o la imatge Background_App
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
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Post de text pur (com el del 'premo')
                    _buildPostCard(
                      username: "yuseef_ramadan",
                      likes: "3",
                      content: "ola premo me dejas tu cargador de telefono aifon istoy in la sala tris nesesito comulncarme con me familia de maroco grasia",
                    ),
                    // Post amb imatge (Subclasse POST del teu UML)
                    _buildPostCard(
                      username: "kimjonganal",
                      likes: "7",
                      imageUrl: "https://images.squarespace-cdn.com/content/v1/5521b64ae4b045339678c3b1/1545035252511-L6O9B72U3V9V4U6U6U6U/image-asset.jpeg",
                    ),
                    _buildPostCard(
                      username: "yuseef_ramadan",
                      likes: "1",
                      content: "segarroooooo viva viva viva io soi ispaniolll ein dirham siusplau",
                    ),
                  ],
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
            // Botó de tornar enrere segons el teu mockup
            CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),

            ),
        ),

        Image.network(
            'https://h-chef.com/wp-content/uploads/2018/04/Razzmatazz.png',
            height: 40,
            fit: BoxFit.contain,

        ),
            ],
        ),
    );
}

  Widget _buildPostCard({
  required String username,
  required String likes,
  String? content,
  String? imageUrl,

  }) {
    return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
        BoxShadow(
        color: Colors.pinkAccent.withOpacity(0.2),
        blurRadius: 10,
        spreadRadius: 2,

        )
            ],
        ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
      // Capçalera del Post (Avatar + User + Likes)
      Row(
      children: [
      const CircleAvatar(
      radius: 15,
        backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=yuseef'),
      ),
      const SizedBox(width: 10),
      Text("@$username",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
      const Spacer(),
      const Icon(Icons.favorite, size: 18, color: Colors.black),
      const SizedBox(width: 5),
      Text(likes, style: const TextStyle(color: Colors.black)),
      ],
    ),
    const SizedBox(height: 12),

    // Contingut: Text o Imatge (Basat en la teva classe POST de l'UML)
    if (content != null)
    Text(content, style: const TextStyle(color: Colors.black87, fontSize: 13)),

          if (imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                // Això evita que l'app mostre l'error 404 a la pantalla
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
                  );
                },
              ),
            ),

    const SizedBox(height: 15),

    // Botó Responde (Visualment actiu, però no fa res com demanaves)
    Align(
    alignment: Alignment.centerRight,
    child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    decoration: BoxDecoration(
    color: const Color(0xFFF1B1CB),
    borderRadius: BorderRadius.circular(20),
    ),
    child: const Text(
    "Responde →",
    style: TextStyle(
    color: Color(0xFFE94E77),
    fontWeight: FontWeight.bold,
    fontSize: 12

    ),
    ),
    ),
    ),
        ],
      ),
    );
  }
  }