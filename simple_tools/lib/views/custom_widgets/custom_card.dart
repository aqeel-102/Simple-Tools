import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Image(
          image: AssetImage(image),
          height: 50.0,
          width: 50.0,
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onTap: () => Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secondaryAnimation) {
              return nextScreen;
            },
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);
              return SlideTransition(
                // Apply slide transition
                position: offsetAnimation,
                child: child,
              );
            },
          ),
        ),
      ),
    );
  }
}
