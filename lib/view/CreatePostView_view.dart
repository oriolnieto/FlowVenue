import 'package:flutter/material.dart';

class CreatePostView extends StatefulWidget {
  final bool isReply;
  const CreatePostView({super.key, this.isReply = false});

  @override
  State<CreatePostView> createState() => _CreatePostViewState();
}

class _CreatePostViewState extends State<CreatePostView> {
  final TextEditingController _textController = TextEditingController();
  bool _imageSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(widget.isReply ? "Responder" : "Nuevo Post",
                style: const TextStyle(color: Colors.white)),
            leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),

            ),
        ),

        body: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFE94E77), Color(0xFF6A1B9A), Color(0xFF000000)],

                ),
            ),

            child: SafeArea(
                child: Column(
                    children: [
                // Àrea de text
                Expanded(
                child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                    controller: _textController,
                    maxLines: 10,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                        hintText: "¿Qué está pasando en la sala?",
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,

                    ),
                ),
            ),
        ),

        const SizedBox(height: 20),

        // Preview de la imatge o botó per afegir
        GestureDetector(
            onTap: () => setState(() => _imageSelected = !_imageSelected),
            child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24, width: 2, style: BorderStyle.solid),

                ),
                child: _imageSelected
                    ? const Icon(Icons.image, color: Colors.greenAccent, size: 50)
                    : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Icon(Icons.add_a_photo, color: Colors.white54),
                Text("Añadir foto (opcional)", style: TextStyle(color: Colors.white54))

                    ],
                ),
            ),
        ),

        const SizedBox(height: 20),

        // Botó de publicar
        SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE94E77),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: const StadiumBorder(),

                ),
                onPressed: () {
                  // Aquí aniria la lògica d'enviar al servidor
                  Navigator.pop(context);
                },

                child: const Text("PUBLICAR",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),

            ),
        ),
                    ],
                ),
            ),
        ),
    );
  }
  }











