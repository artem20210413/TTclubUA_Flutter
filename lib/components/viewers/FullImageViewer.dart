import 'package:flutter/material.dart';

class FullImageViewer {
  static void show(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) {
        double drag = 0;

        return GestureDetector(
          onTap: () => Navigator.pop(context),

          // свайп по ФОНУ также закрывает
          onVerticalDragUpdate: (details) {
            drag += details.delta.dy;
          },

          onVerticalDragEnd: (_) {
            if (drag.abs() > 80) {
              Navigator.pop(context);
            }
            drag = 0;
          },

          child: Center(
            child: GestureDetector(
              // свайп именно ПО КАРТИНКЕ
              onVerticalDragUpdate: (details) {
                drag += details.delta.dy;
              },
              onVerticalDragEnd: (_) {
                if (drag.abs() > 80) {
                  Navigator.pop(context);
                }
                drag = 0;
              },

              child: InteractiveViewer(
                panEnabled: true,
                minScale: 1,
                maxScale: 4,
                child: Hero(
                  tag: imageUrl,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}


// import 'package:flutter/material.dart';
//
// class FullImageViewer {
//
//   static void show(BuildContext context, String imageUrl) {
//     showDialog(
//       context: context,
//       barrierColor: Colors.black87,
//       builder: (_) {
//         return GestureDetector(
//           onTap: () => Navigator.pop(context),
//           child: InteractiveViewer(
//             panEnabled: true,
//             minScale: 1,
//             maxScale: 4,
//             child: Center(
//               child: Hero(
//                 tag: imageUrl,
//                 child: Image.network(
//                   imageUrl,
//                   fit: BoxFit.contain,
//                   loadingBuilder: (context, child, progress) {
//                     if (progress == null) return child;
//                     return Center(
//                       child: CircularProgressIndicator(
//                         value: progress.expectedTotalBytes != null
//                             ? progress.cumulativeBytesLoaded /
//                             (progress.expectedTotalBytes ?? 1)
//                             : null,
//                         color: Colors.white,
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
