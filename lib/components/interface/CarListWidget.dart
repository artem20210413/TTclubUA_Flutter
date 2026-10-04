import 'package:flutter/material.dart';

import '../../api/routs/Dto/Car/CarDto.dart';
import '../../config/default.dart';
import '../../pages/Nav/Admin/User/UpdateCarScreen.dart';
import '../TTNeumorphicBox.dart';
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
                      child: TTNeumorphicBox(
                        width: 150,
                        radius: 24,
                        padding: const EdgeInsets.all(8),
                        child: Padding(
                          padding: EdgeInsetsGeometry.only(right: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add,
                                  size: 50, color: TTColors.text_secondary),
                              SizedBox(height: 10),
                              Text(
                                "Додати авто",
                                textAlign: TextAlign.center,
                                style: TTTextStyle.caption,
                              ),
                            ],
                          ),
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
                    child: TTNeumorphicBox(
                      width: 150,
                      radius: 24,
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsetsGeometry.only(right: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24)),
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
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              "${car.model.name} ${car.gene.name} ${car.generalLicensePlate}",
                              textAlign: TextAlign.center,
                              style: TTTextStyle.caption
                                  .copyWith(fontWeight: FontWeight.w600),
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
