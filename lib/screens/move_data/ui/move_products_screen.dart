import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pharmacy_arrival/data/model/move_data_dto.dart';
import 'package:pharmacy_arrival/data/model/product_dto.dart';
import 'package:pharmacy_arrival/screens/common/fill_move_details/fill_number.dart';
import 'package:pharmacy_arrival/screens/move_data/move_products_cubit/move_products_screen_cubit.dart';
import 'package:pharmacy_arrival/screens/move_data/ui/move_barcode_screen.dart';
import 'package:pharmacy_arrival/styles/color_palette.dart';
import 'package:pharmacy_arrival/styles/text_styles.dart';
import 'package:pharmacy_arrival/utils/app_router.dart';
import 'package:pharmacy_arrival/widgets/app_loader_overlay.dart';
import 'package:pharmacy_arrival/widgets/custom_app_bar.dart';
import 'package:pharmacy_arrival/widgets/snackbar/custom_snackbars.dart';

class MoveProductsScreen extends StatefulWidget {
  final MoveDataDTO moveDataDTO;
  const MoveProductsScreen({Key? key, required this.moveDataDTO})
      : super(key: key);

  @override
  State<MoveProductsScreen> createState() => _MoveProductsScreenState();
}

class _MoveProductsScreenState extends State<MoveProductsScreen> {
  @override
  void initState() {
    BlocProvider.of<MoveProductsScreenCubit>(context)
        .getProducts(moveOrderId: widget.moveDataDTO.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppLoaderOverlay(
      child: Scaffold(
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 75),
          child: SizedBox(
            height: 80,
            width: 80,
            child: FloatingActionButton(
              onPressed: () {
                AppRouter.push(
                  context,
                  MoveBarcodeScreen(
                    moveDataDTO: widget.moveDataDTO,
                    isFromProductsPage: true,
                  ),
                );
              },
              backgroundColor: ColorPalette.orange,
              child: SvgPicture.asset("assets/images/svg/move_plus.svg"),
            ),
          ),
        ),
        appBar: CustomAppBar(
          title: "Отсканированные".toUpperCase(),
          // actions: [
          //   Padding(
          //     padding: const EdgeInsets.only(right: 12.0),
          //     child: GestureDetector(
          //       child: SvgPicture.asset("assets/images/svg/delete_scanned.svg"),
          //     ),
          //   ),
          // ],
        ),
        body: BlocConsumer<MoveProductsScreenCubit, MoveProductsScreenState>(
          listener: (context, state) {
            state.maybeWhen(
              
              finishedState: () {
                Navigator.pop(context);
                buildSuccessCustomSnackBar(context, "Успешно завершен");
              },
              orElse: () {},
            );
          },
          builder: (context, state) {
            return state.maybeWhen(
              loadedState: (products, isFinishable) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 27.0,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: _BuildGoodDetails(
                                good: products[index],
                                moveDataId: widget.moveDataDTO.id,
                              ),
                            );
                          },
                          itemCount: products.length,
                          shrinkWrap: true,
                        ),
                      ),
                      MaterialButton(
                        height: 40,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        color: ColorPalette.orange,
                        disabledColor: ColorPalette.orangeInactive,
                        padding: EdgeInsets.zero,
                        onPressed: isFinishable == true
                            ? () {
                                BlocProvider.of<MoveProductsScreenCubit>(
                                  context,
                                ).updateMovingOrderStatus(
                                  moveOrderId: widget.moveDataDTO.id,
                                  status: 2,
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
                    ],
                  ),
                );
              },
              loadingState: () {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.amber),
                );
              },
              orElse: () {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.red),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _BuildGoodDetails extends StatefulWidget {
  final ProductDTO good;
  final int moveDataId;

  const _BuildGoodDetails({
    Key? key,
    required this.good,
    required this.moveDataId,
  }) : super(key: key);

  @override
  State<_BuildGoodDetails> createState() => _BuildGoodDetailsState();
}

class _BuildGoodDetailsState extends State<_BuildGoodDetails> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: ColorPalette.white,
      ),
      child: Row(
        children: [
          Stack(
            children: [
              SizedBox(
                width: 104,
                height: 104,
                child: Image.network(
                  widget.good.image ?? 'null',
                  errorBuilder: (context, child, stacktrace) {
                    return const Center(
                      child: Icon(Icons.error),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: ColorPalette.white,
                    border: Border.all(
                      color: ColorPalette.green,
                    ),
                  ),
                  child: Text(
                    "${widget.good.totalCount??0} шт.",
                    style: ThemeTextStyle.textStyle12w600.copyWith(
                      color: ColorPalette.green,
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
                Text(
                  "${widget.good.barcode}",
                  style: ThemeTextStyle.textStyle14w400
                      .copyWith(color: ColorPalette.black),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  '${widget.good.name}',
                  overflow: TextOverflow.fade,
                  style: ThemeTextStyle.textStyle20w600,
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  "${widget.good.producer}",
                  style: ThemeTextStyle.textStyle14w400.copyWith(
                    color: ColorPalette.grayText,
                  ),
                ),
                if (widget.good.isReady == true)
                  Column(
                    children: [
                      const SizedBox(
                        height: 14,
                      ),
                      GestureDetector(
                        onTap: () {
                          AppRouter.push(
                            context,
                            FillNumberScreen(
                              moveData: widget.good,
                              moveOrderId: widget.moveDataId,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15.5,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F6FB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Ввести серию',
                            style: ThemeTextStyle.textStyle14w600
                                .copyWith(color: const Color(0xFF5CA7FF)),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  const SizedBox()
              ],
            ),
          )
        ],
      ),
    );
  }

}
