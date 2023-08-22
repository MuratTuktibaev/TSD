import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharmacy_arrival/core/styles/color_palette.dart';
import 'package:pharmacy_arrival/core/styles/text_styles.dart';
import 'package:pharmacy_arrival/core/utils/constants.dart';
import 'package:pharmacy_arrival/data/model/product_dto.dart';
import 'package:pharmacy_arrival/screens/goods_list/cubit/goods_list_screen_cubit.dart';
import 'package:pharmacy_arrival/screens/goods_list/ui/widgets/specifying_number_manually.dart';

class BuildPharmacyGoodDetails extends StatelessWidget {
  final TextEditingController searchController;
  final int currentIndex;
  final ProductDTO good;
  final ProductDTO selectedProduct;
  final int orderID;
  const BuildPharmacyGoodDetails({
    super.key,
    required this.good,
    required this.selectedProduct,
    required this.orderID,
    required this.currentIndex,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: (good.status == 1 &&
                  good.scanCount != null &&
                  good.scanCount! > 0)
              ? const Color.fromARGB(255, 183, 244, 215)
              : ColorPalette.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  good.image ??
                      'https://teelindy.com/wp-content/uploads/2019/03/default_image.png',
                  width: 104,
                  height: 104,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/png/not_found.png',
                      width: 104,
                      height: 104,
                    );
                  },
                ),
                Positioned(
                  bottom: 8,
                  left: 24,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: ColorPalette.white,
                      border: Border.all(
                        color: ColorPalette.red,
                      ),
                    ),
                    child: Text(
                      "${good.totalCount} шт.",
                      style: ThemeTextStyle.textStyle12w600.copyWith(
                        color: ColorPalette.red,
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (good.barcode?.length ?? 0) <= 2
                              ? "${good.scanCount!}"
                              : "${good.scanCount!.toStringAsFixed(0)}x",
                          style: ThemeTextStyle.textStyle14w400
                              .copyWith(color: ColorPalette.black),
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Expanded(
                          child: Text(
                            good.barcode ?? 'null',
                            style: ThemeTextStyle.textStyle14w600
                                .copyWith(color: ColorPalette.grayText),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox( //Мурат убрал не нужный
                    height: 8,
                  ),
                  Text(
                    'Серия № ${good.series ?? 'null'}',
                    style: ThemeTextStyle.textStyle13w300
                        .copyWith(color: ColorPalette.grayText),
                  ),
                  // Text(
                  //   'Серийный № ${good.serialCode ?? 'null'}',
                  //   style: ThemeTextStyle.textStyle14w600
                  //       .copyWith(color: ColorPalette.grayText),
                  // ),
                  const SizedBox( //Мурат
                    height: 8,
                  ),
                  Text(
                    '${good.name}',
                    overflow: TextOverflow.fade,
                    style: ThemeTextStyle.textStyle20w600,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    "${good.producer}",
                    style: ThemeTextStyle.textStyle14w400.copyWith(
                      color: ColorPalette.grayText,
                    ),
                  ),
                  if (currentIndex == 0)
                    Column(
                      children: [
                        const SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (good.totalCount! <=
                                good.scanCount! +
                                    good.defective! +
                                    good.underachievement! +
                                    good.reSorting! +
                                    good.overdue! +
                                    good.netovar!)
                              MaterialButton(
                                color: ColorPalette.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  BlocProvider.of<GoodsListScreenCubit>(context)
                                      .updatePharmacyProductById(
                                    status: "2",
                                    search: searchController.text.isNotEmpty
                                        ? searchController.text
                                        : null,
                                    orderId: orderID,
                                    productId: good.id,
                                    scanCount: good.scanCount?.toDouble(),
                                    defective: good.defective,
                                    surplus: good.surplus,
                                    underachievement: good.underachievement,
                                    reSorting: good.reSorting,
                                    overdue: good.overdue,
                                    netovar: good.netovar,
                                  );
                                  BlocProvider.of<GoodsListScreenCubit>(context)
                                      .savePharmacySelectedProductToCache(
                                    selectedProduct: ProductDTO(
                                      id: -1,
                                      orderID: orderID,
                                    ),
                                  );
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    'Завершить',
                                    style: TextStyle(
                                      color: ColorPalette.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            MaterialButton(
                              color: ColorPalette.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                bottomSheet(
                                  SpecifyingNumberManually(
                                    callback: (controller) {
                                      Navigator.pop(context);
                                      BlocProvider.of<GoodsListScreenCubit>(
                                        context,
                                      ).scannerBarCode(
                                        productId: good.id,
                                        scannedResult: good.barcode!,
                                        orderId: orderID,
                                        search: searchController.text.isNotEmpty
                                            ? searchController.text
                                            : null,
                                        quantity: double.parse(controller.text),
                                        scanType: 1,
                                      );
                                      controller.clear();
                                    },
                                    productDTO: good,
                                    orderID: orderID,
                                  ),
                                  context,
                                );
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Text(
                                  "Указать вручную",
                                  style: TextStyle(
                                    color: ColorPalette.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                      ],
                    )
                  else
                    const SizedBox(
                      height: 8,
                    ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Кол-во:   ${good.totalCount}'.toUpperCase()),
                      Text(
                        (good.barcode?.length ?? 0) <= 2
                            ? "СКАН: ${good.scanCount!}"
                            : "СКАН: ${good.scanCount!.toStringAsFixed(0)}",
                      ),
                      Text('Просрочен:   ${good.overdue}'.toUpperCase()),
                      Text(
                        'Нетоварный вид:   ${good.netovar}'.toUpperCase(),
                      ),
                      Text('Брак:   ${good.defective}'.toUpperCase()),
                      Text('Излишка:   ${good.surplus}'.toUpperCase()),
                      Text(
                        'Недостача:   ${good.underachievement}'.toUpperCase(),
                      ),
                      Text(
                        'Пересорт серий:   ${good.reSorting}'.toUpperCase(),
                      ),
                      // Text(
                      //   'Неподходящий срок:   ${good.srok}'.toUpperCase(),
                      // ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
