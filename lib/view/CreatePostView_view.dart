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
    bool _isLoading = false;

    final Color primaryPink = const Color(0xFFE94E77);

    Future<void> _enviarPost() async {
        if (_textController.text.trim().isEmpty) { // comprovació rapida per evitar problems!
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Escriu alguna cosa per publicar")),
            );
            return;
        }

        setState(() => _isLoading = true);

        bool success = await _dbServices.crearPost(
            username: widget.usuari.username,
            content: widget.isReply
                ? "Re: @${widget.originalUser} -> ${_textController.text}"
                : _textController.text,
        );

        setState(() => _isLoading = false);

        if (success) {
            if (!mounted) return;
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
                title: Text(
                    widget.isReply ? "Respondre" : "Nou Post",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                leading: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
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
                                            color: Colors.white38,
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: const [
                                                BoxShadow(color: Colors.black12, blurRadius: 10)
                                            ],
                                        ),
                                        child: TextField(
                                            controller: _textController,
                                            maxLines: null,
                                            expands: true,
                                            style: const TextStyle(color: Colors.black87),
                                            decoration: InputDecoration(
                                                hintText: widget.isReply
                                                    ? "Escriu una resposta..."
                                                    : "Què vols dir?",
                                                hintStyle: const TextStyle(color: Colors.black38),
                                                border: InputBorder.none,
                                            ),
                                        ),
                                    ),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: primaryPink,
                                            padding: const EdgeInsets.symmetric(vertical: 15),
                                            shape: const StadiumBorder(),
                                            elevation: 5,
                                        ),
                                        onPressed: _isLoading ? null : _enviarPost,
                                        child: _isLoading
                                            ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                                color: Colors.white, strokeWidth: 2))
                                            : Text(
                                            widget.isReply ? "Respondre" : "Publicar",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontSize: 16),
                                        ),
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
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.circular(15),
                border: Border(left: BorderSide(color: primaryPink, width: 5)),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text("@${widget.originalUser}",
                        style: TextStyle(color: primaryPink, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                        widget.originalContent ?? "Post original",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                ],
            ),
        );
    }
}