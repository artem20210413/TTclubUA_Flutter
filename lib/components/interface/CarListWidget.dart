import 'package:flutter/material.dart';

import '../../api/routs/Dto/Car/CarDto.dart';
import '../../config/default.dart';
import '../../pages/Nav/Admin/User/UpdateCarScreen.dart';
import '../generalModule.dart';

class CarListWidget extends StatelessWidget {
  final List<CarDto> cars;
  final void Function(CarDto car)? onCarTap;
  final VoidCallback? onAddTap;

  const CarListWidget({
    Key? key,
    required this.cars,
    this.onCarTap,
    this.onAddTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: onAddTap != null ? cars.length + 1 : cars.length,
              itemBuilder: (context, index) {
                // Кнопка "Добавить авто"
                if (index == cars.length && onAddTap != null) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: GestureDetector(
                      onTap: onAddTap,
                      child: Container(
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 5),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, size: 50, color: Colors.black),
                            SizedBox(height: 10),
                            Text(
                              "Додати авто",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                // Отображение авто
                final car = cars[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GestureDetector(
                    onTap: onCarTap != null ? () => onCarTap!(car) : null,
                    child: Container(
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 5),
                        ],
                      ),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.network(
                              car.imageUrls.isNotEmpty &&
                                      car.imageUrls.first?.url != null
                                  ? car.imageUrls.first!.url
                                  : CAR_IMAGE_DEFAULT,
                              width: 150,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "${car.model.name} ${car.gene.name} ${car.generalLicensePlate}",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
//
// import '../../api/routs/Dto/Car/CarDto.dart';
// import '../../config/default.dart';
// import '../../pages/Nav/Admin/User/UpdateCarScreen.dart';
// import '../generalModule.dart';
//
// class CarListWidget extends StatelessWidget {
//   final List<CarDto> cars;
//   final bool isInteractive;
//   final void Function(CarDto car)? onCarTap;
//   final VoidCallback? onAddTap;
//
//   const CarListWidget({
//     Key? key,
//     required this.cars,
//     required this.isInteractive,
//     this.onCarTap,
//     this.onAddTap,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 15),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             height: 180,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: isInteractive ? cars.length + 1 : cars.length,
//               itemBuilder: (context, index) {
//                 // Кнопка "Добавить авто"
//                 if (index == cars.length && isInteractive) {
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                     child: GestureDetector(
//                       onTap: onAddTap ??
//                               () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => UpdateCarScreen(),
//                               ),
//                             );
//                           },
//                       child: Container(
//                         width: 150,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(12),
//                           color: Colors.white,
//                           boxShadow: [
//                             BoxShadow(color: Colors.black12, blurRadius: 5),
//                           ],
//                         ),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.add, size: 50, color: Colors.black),
//                             SizedBox(height: 10),
//                             Text(
//                               "Додати авто",
//                               textAlign: TextAlign.center,
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 }
//
//                 // Отображение авто
//                 final car = cars[index];
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                   child: GestureDetector(
//                     onTap: isInteractive
//                         ? () {
//                       if (onCarTap != null) {
//                         onCarTap!(car);
//                       } else {
//                         MessageModule(
//                           context,
//                           'Скоро буде створеня авто ..',
//                           MessageType.success,
//                         );
//                       }
//                     }
//                         : null,
//                     child: Container(
//                       width: 150,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12),
//                         color: Colors.white,
//                         boxShadow: [
//                           BoxShadow(color: Colors.black12, blurRadius: 5),
//                         ],
//                       ),
//                       child: Column(
//                         children: [
//                           ClipRRect(
//                             borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
//                             child: Image.network(
//                               car.imageUrls.isNotEmpty && car.imageUrls.first?.url != null
//                                   ? car.imageUrls.first!.url
//                                   : CAR_IMAGE_DEFAULT,
//                               width: 150,
//                               height: 120,
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Text(
//                               "${car.model.name} ${car.gene.name} ${car.generalLicensePlate}",
//                               textAlign: TextAlign.center,
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
