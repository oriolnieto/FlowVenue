import 'package:flutter/material.dart';
import '/model/users_model.dart';
import '/services/db_services.dart';

class CreatePostView extends StatefulWidget {
    final Usuari usuari;
    final bool isReply;
    final String? originalUser;
    final String? originalContent;

    const CreatePostView({
        super.key,
        required this.usuari,
        this.isReply = false,
        this.originalUser,
        this.originalContent,
    });

    @override
    State<CreatePostView> createState() => _CreatePostViewState();
}

class _CreatePostViewState extends State<CreatePostView> {
    final TextEditingController _textController = TextEditingController();
    final DbServices _dbServices = DbServices();
    bool _imageSelected = false;
    bool _isLoading = false;

    Future<void> _enviarPost() async {
        if (_textController.text.isEmpty && !_imageSelected) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Escribe algo o añade una foto")),
            );
            return;
        }

        setState(() => _isLoading = true);
        
        String? imageUrl = _imageSelected ? "https://images.unsplash.com/photo-1514525253361-bee8718a7439?q=80&w=1000&auto=format&fit=crop" : null;

        bool success = await _dbServices.crearPost(
            username: widget.usuari.username,
            content: widget.isReply
                ? "Re: @${widget.originalUser} -> ${_textController.text}"
                : _textController.text,
            imageUrl: imageUrl,
        );

        setState(() => _isLoading = false);

        if (success) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(widget.isReply ? "Resposta enviada!" : "Post publicat!")),
            );
            Navigator.pop(context);
        } else {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Error al publicar el post")),
            );
        }
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text(widget.isReply ? "Respondre" : "Nou Post", style: const TextStyle(color: Colors.white)),
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
                                    _buildPreviewResposta(),
                                    const SizedBox(height: 20),
                                ],
                                Expanded(
                                    child: Container(
                                        padding: const EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: TextField(
                                            controller: _textController,
                                            maxLines: 10,
                                            style: const TextStyle(color: Colors.white),
                                            decoration: InputDecoration(
                                                hintText: widget.isReply ? "Escriu una resposta..." : "Que passa?",
                                                hintStyle: const TextStyle(color: Colors.white54),
                                                border: InputBorder.none,
                                            ),
                                        ),
                                    ),
                                ),
                                const SizedBox(height: 20),
                                GestureDetector(
                                    onTap: () => setState(() => _imageSelected = !_imageSelected),
                                    child: Container(
                                        height: 100,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: Colors.white24, width: 2),
                                        ),
                                        child: _imageSelected
                                            ? const Icon(Icons.image, color: Colors.greenAccent, size: 40)
                                            : const Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                                Icon(Icons.add_a_photo, color: Colors.white54),
                                                Text("Afegir foto (opcional)", style: TextStyle(color: Colors.white54))
                                            ],
                                        ),
                                    ),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFE94E77),
                                            padding: const EdgeInsets.symmetric(vertical: 15),
                                            shape: const StadiumBorder(),
                                        ),
                                        onPressed: _isLoading ? null : _enviarPost,
                                        child: _isLoading
                                            ? const CircularProgressIndicator(color: Colors.white)
                                            : Text(widget.isReply ? "Respondre" : "Publicar",
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                    ),
                                ),
                            ],
                        ),
                    ),
                ),
            ),
        );
    }

    Widget _buildPreviewResposta() {
        return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: const Border(left: BorderSide(color: Color(0xFFE94E77), width: 4)),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text("@${widget.originalUser}", style: const TextStyle(color: Color(0xFFE94E77), fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(widget.originalContent ?? "Post original",
                        maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
            ),
        );
    }
}