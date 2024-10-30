import 'package:flutter/material.dart';
import 'package:simple_tools/util/favoritelist.dart';

class CustomCard extends StatefulWidget {
  const CustomCard({
    super.key,
    required this.image,
    required this.title,
    required this.nextScreen,
  });

  final String image;
  final String title;
  final Widget nextScreen;

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadSavedState();
  }

  Future<void> _loadSavedState() async {
    await SavedTools.loadSavedTools();
    setState(() {
      isFavorite =
          SavedTools.savedTools.any((tool) => tool['title'] == widget.title);
    });
  }

  void _toggleFavorite() async {
    setState(() {
      isFavorite = !isFavorite;
    });

    if (isFavorite) {
      await SavedTools.addTool(widget.title, widget.image, widget.nextScreen);
    } else {
      await SavedTools.removeTool(widget.title);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                widget.nextScreen,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Image.asset(
                widget.image,
                width: 24,
                height: 24,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: isFavorite ? Colors.red : null,
              ),
              onPressed: _toggleFavorite,
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Theme.of(context).primaryColor.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
