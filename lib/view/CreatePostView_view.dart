import 'package:flutter/material.dart';

class CreatePostView extends StatefulWidget {
  final bool isReply;
  final String? originalUser;
  final String? originalContent;

  const CreatePostView({super.key, this.isReply = false, this.originalUser, this.originalContent});

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
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/Background_App.png'),
                    fit: BoxFit.cover,

                ),
            ),

            child: SafeArea(
                child: Padding(
                    padding: const EdgeInsets.all(20.0),
                child: Column(
                    children: [
                        if (widget.isReply && widget.originalUser != null) ...[
                            _buildPreviewRespuesta(),
                            const SizedBox(height: 20),
                        ],

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
                    decoration: InputDecoration(
                        hintText: widget.isReply
                            ? "Escribe tu respuesta..."
                            : "¿Qué está pasando en la sala?",
                        hintStyle: const TextStyle(color: Colors.white54),
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
                height: 120,
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

                child: Text(widget.isReply ? "RESPONDER" : "PUBLICAR",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white)),

            ),
        ),
                    ],
                ),
                ),
            ),
        ),
    );
  }

  // Mètode nou per mostrar el post que estem contestant
  Widget _buildPreviewRespuesta() {
      return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
              border: const Border(left: BorderSide(color: Color(0xFFE94E77), width: 4)),
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          Text("@${widget.originalUser}",
              style: const TextStyle(
                  color: Color(0xFFE94E77), fontWeight: FontWeight.bold)),

                  const SizedBox(height: 4),
                  Text(widget.originalContent ?? "Post original",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
          ),
      );
  }
}
