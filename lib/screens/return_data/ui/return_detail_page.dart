import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:pharmacy_arrival/data/model/pharmacy_order_dto.dart';
import 'package:pharmacy_arrival/data/model/product_dto.dart';
import 'package:pharmacy_arrival/screens/common/goods_list/cubit/goods_list_screen_cubit.dart';
import 'package:pharmacy_arrival/styles/color_palette.dart';
import 'package:pharmacy_arrival/styles/text_styles.dart';
import 'package:pharmacy_arrival/widgets/app_loader_overlay.dart';
import 'package:pharmacy_arrival/widgets/custom_alert_dialog.dart';
import 'package:pharmacy_arrival/widgets/custom_app_bar.dart';
import 'package:pharmacy_arrival/widgets/custom_button.dart';
import 'package:pharmacy_arrival/widgets/snackbar/custom_snackbars.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ReturnDetailPage extends StatefulWidget {
  final PharmacyOrderDTO? pharmacyOrder;
  const ReturnDetailPage({Key? key, this.pharmacyOrder}) : super(key: key);

  @override
  State<ReturnDetailPage> createState() => _ReturnDetailPageState();
}

class _ReturnDetailPageState extends State<ReturnDetailPage> {
  @override
  void initState() {
    BlocProvider.of<GoodsListScreenCubit>(context)
        .getPharmacyProducts(orderId: widget.pharmacyOrder!.id);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppLoaderOverlay(
      child: Scaffold(
        floatingActionButton: Padding(
          padding: const EdgeInsets.fromLTRB(32, 0, 0, 0),
          child: CustomButton(
            height: 44,
            onClick: () {
              //FIXME Need to change refund status from 1 to 2 through api
            },
            body: const Text(
              'Завершить возврата',
              style: TextStyle(),
            ),
            style: pinkButtonStyle(),
          ),
        ),
        backgroundColor: ColorPalette.main,
        appBar: CustomAppBar(
          title: "Список товаров".toUpperCase(),
          actions: [
            IconButton(
              onPressed: () {
                buildAlertDialog(context);
              },
              icon: const Icon(
                Icons.document_scanner_rounded,
                color: Colors.black,
              ),
            )
          ],
        ),
        body: BlocConsumer<GoodsListScreenCubit, GoodsListScreenState>(
          builder: (context, state) {
            return state.maybeWhen(
              loadingState: () {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.amber,
                  ),
                );
              },
              loadedState: (
                scannedProducts,
                unscannedProducts,
                selectedProduct,
              ) {
                return _BuildBody(
                  orderStatus: widget.pharmacyOrder?.status ?? 0,
                  orderId: widget.pharmacyOrder!.id,
                  scannedProducts: scannedProducts,
                  selectedProduct: selectedProduct,
                  pharmacyOrder: widget.pharmacyOrder,
                );
              },
              errorState: (String message) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        color: Colors.red,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        message,
                        style: const TextStyle(color: Colors.red),
                      )
                    ],
                  ),
                );
              },
              orElse: () {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.red,
                  ),
                );
              },
            );
          },
          listener: (context, state) {
            state.when(
              initialState: () {},
              loadingState: () {},
              successScannedState: (String message) {
                buildSuccessCustomSnackBar(context, message);
              },
              loadedState: (
                scannedProducts,
                unscannedProducts,
                selectedProductId,
              ) {},
              errorState: (String message) {
                buildErrorCustomSnackBar(context, message);
              },
            );
          },
        ),
      ),
    );
  }
}

class _BuildBody extends StatefulWidget {
  final int orderStatus;
  final int orderId;
  final ProductDTO selectedProduct;
  final List<ProductDTO> scannedProducts;
  final PharmacyOrderDTO? pharmacyOrder;
  const _BuildBody({
    Key? key,
    required this.orderId,
    required this.scannedProducts,
    required this.selectedProduct,
    required this.orderStatus,
    this.pharmacyOrder,
  }) : super(key: key);

  @override
  State<_BuildBody> createState() => _BuildBodyState();
}

class _BuildBodyState extends State<_BuildBody> {
  RefreshController controller = RefreshController();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SmartRefresher(
            onRefresh: () {
              BlocProvider.of<GoodsListScreenCubit>(context)
                  .getPharmacyProducts(orderId: widget.orderId);
            },
            controller: controller,
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.only(left: 12.5, right: 12.5, top: 20),
              itemCount: widget.scannedProducts.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // if (currentIndex == 0) {
                    //   AppRouter.push(
                    //     context,
                    //     DefectScreen(
                    //       product: widget.unscannedProducts[index],
                    //       orderId: widget.orderId,
                    //     ),
                    //   );
                    // }
                  },
                  child: _BuildGoodDetails(
                    orderID: widget.orderId,
                    good: widget.scannedProducts[index],
                    selectedProduct: widget.selectedProduct,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _BuildGoodDetails extends StatefulWidget {
  final ProductDTO good;
  final ProductDTO selectedProduct;
  final int orderID;
  const _BuildGoodDetails({
    Key? key,
    required this.good,
    required this.selectedProduct,
    required this.orderID,
  }) : super(key: key);

  @override
  State<_BuildGoodDetails> createState() => _BuildGoodDetailsState();
}

class _BuildGoodDetailsState extends State<_BuildGoodDetails> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: widget.good.id == widget.selectedProduct.id
              ? const Color.fromARGB(255, 183, 244, 215)
              : ColorPalette.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  widget.good.image ??
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
                      "${widget.good.totalCount} шт.",
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
                    children: [
                      Text(
                        "${widget.good.scanCount!}x",
                        style: ThemeTextStyle.textStyle14w400
                            .copyWith(color: ColorPalette.black),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: Text(
                          widget.good.barcode ?? 'null',
                          style: ThemeTextStyle.textStyle14w600
                              .copyWith(color: ColorPalette.grayText),
                        ),
                      ),
                    ],
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
                  Column(
                    children: [
                      const SizedBox(
                        height: 8,
                      ),
                      MaterialButton(
                        color: ColorPalette.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          //FIXME need to update refund in product api
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            'Ввести сумму возравта',
                            style: TextStyle(
                              color: ColorPalette.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Кол-во:   ${widget.good.totalCount}'.toUpperCase()),
                      Text('Скан:   ${widget.good.scanCount}'.toUpperCase()),
                      Text('Просрочен:   ${widget.good.overdue}'.toUpperCase()),
                      Text(
                        'Нетоварный вид:   ${widget.good.netovar}'
                            .toUpperCase(),
                      ),
                      Text('Брак:   ${widget.good.defective}'.toUpperCase()),
                      Text('Излишка:   ${widget.good.surplus}'.toUpperCase()),
                      Text(
                        'Недостача:   ${widget.good.underachievement}'
                            .toUpperCase(),
                      ),
                      Text(
                        'Пересорт серий:   ${widget.good.reSorting}'
                            .toUpperCase(),
                      ),
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

  Future _bottomSheet(Widget widget) {
    return showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      context: context,
      enableDrag: true,
      isDismissible: false,
      isScrollControlled: true,
      builder: (context) {
        return widget;
      },
    );
  }
}
