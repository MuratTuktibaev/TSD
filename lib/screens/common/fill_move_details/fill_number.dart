import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharmacy_arrival/data/model/product_dto.dart';
import 'package:pharmacy_arrival/screens/move_data/move_products_cubit/move_products_screen_cubit.dart';
import 'package:pharmacy_arrival/styles/color_palette.dart';
import 'package:pharmacy_arrival/styles/text_styles.dart';
import 'package:pharmacy_arrival/widgets/app_loader_overlay.dart';
import 'package:pharmacy_arrival/widgets/custom_app_bar.dart';
import 'package:pharmacy_arrival/widgets/main_text_field/app_text_field.dart';
import 'package:pharmacy_arrival/widgets/snackbar/custom_snackbars.dart';

class FillNumberScreen extends StatefulWidget {
  final ProductDTO moveData;
  final int moveOrderId;

  const FillNumberScreen({
    Key? key,
    required this.moveData,
    required this.moveOrderId,
  }) : super(key: key);

  @override
  _FillNumberScreenState createState() => _FillNumberScreenState();
}

class _FillNumberScreenState extends State<FillNumberScreen> {
  late final ProductDTO productInfo;
  TextEditingController numberController = TextEditingController();
  int count = 0;

  @override
  void initState() {
    productInfo = widget.moveData;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppLoaderOverlay(
      child: Scaffold(
        backgroundColor: ColorPalette.white,
        appBar: CustomAppBar(
          title: productInfo.barcode ?? 'No data',
          showLogo: false,
        ),
        body: BlocConsumer<MoveProductsScreenCubit, MoveProductsScreenState>(
          listener: (context, state) {
            state.when(
              initialState: () {
                context.loaderOverlay.hide();
              },
              loadingState: () {
                context.loaderOverlay.show();
              },
              loadedState: (products, isFinishable) {
                context.loaderOverlay.hide();
                Navigator.pop(context);
              },
              errorState: (String message) {
                buildErrorCustomSnackBar(context, message);
                context.loaderOverlay.hide();
              },
              finishedState: () {
                context.loaderOverlay.hide();
              },
            );
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  productInfo.name ?? "No data",
                                  style: ThemeTextStyle.textTitleDella20w400
                                      .copyWith(color: ColorPalette.black),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  productInfo.producer ?? "No data",
                                  style: ThemeTextStyle.textStyle14w400
                                      .copyWith(color: ColorPalette.grayText),
                                ),
                              ],
                            ),
                          ),
                          Image.network(
                            productInfo.image ?? "null",
                            width: 240,
                            height: 240,
                            errorBuilder: (_, child, stackTrace) {
                              return const Center(
                                child: Icon(Icons.error),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 20.0,
                        left: 29,
                        bottom: 48,
                        right: 29,
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Количество",
                            style: ThemeTextStyle.textStyle14w600
                                .copyWith(color: ColorPalette.white),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (count > 0) count--;
                                  });
                                },
                                child: Image.asset(
                                  "assets/images/svg/minus.png",
                                  width: 48,
                                  height: 48,
                                ),
                              ),
                              const SizedBox(
                                width: 18,
                              ),
                              Text(
                                "$count",
                                style: ThemeTextStyle.textStyle48w300
                                    .copyWith(color: ColorPalette.black),
                              ),
                              const SizedBox(
                                width: 18,
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    //if (count < widget.moveData.totalCount!) {
                                    count++;
                                    //}
                                  });
                                },
                                child: Image.asset(
                                  "assets/images/svg/plus.png",
                                  width: 48,
                                  height: 48,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    AppTextField(
                      showErrorMessages: false,
                      hintText: "№ Серии",
                      controller: numberController,
                      fillColor: ColorPalette.background,
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 24.0,
                        right: 24.0,
                        bottom: 24.0,
                        top: 24,
                      ),
                      child: MaterialButton(
                        height: 40,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        color: ColorPalette.orange,
                        disabledColor: ColorPalette.orangeInactive,
                        padding: EdgeInsets.zero,
                        onPressed:
                            (count != 0 && numberController.text.isNotEmpty)
                                ? () {
                                    BlocProvider.of<MoveProductsScreenCubit>(
                                      context,
                                    ).addMoveDataProduct(
                                      moveOrderId: widget.moveOrderId,
                                      addingProduct: widget.moveData.copyWith(
                                        totalCount: count,
                                        series: numberController.text,
                                      ),
                                    );
                                  }
                                : null,
                        child: Center(
                          child: Text(
                            "Завершить",
                            style: ThemeTextStyle.textStyle14w600
                                .copyWith(color: ColorPalette.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}