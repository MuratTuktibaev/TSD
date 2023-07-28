import 'dart:developer';
import 'dart:io' show Platform;

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:pharmacy_arrival/core/styles/color_palette.dart';
import 'package:pharmacy_arrival/core/styles/text_styles.dart';
import 'package:pharmacy_arrival/core/utils/app_router.dart';
import 'package:pharmacy_arrival/core/utils/constants.dart';
import 'package:pharmacy_arrival/data/model/pharmacy_order_dto.dart';
import 'package:pharmacy_arrival/screens/common/signature/cubit/signature_screen_cubit.dart';
import 'package:pharmacy_arrival/screens/common/signature/fill_invoice_screen.dart';
import 'package:pharmacy_arrival/screens/common/signature/fill_invoice_vmodel.dart';
import 'package:pharmacy_arrival/screens/pharmacy_arrival/cubit/pharmacy_arrival_cat_cubit.dart';
import 'package:pharmacy_arrival/screens/pharmacy_arrival/cubit/pharmacy_arrival_screen_cubit.dart';
import 'package:pharmacy_arrival/screens/pharmacy_arrival/ui/pharmacy_filter_page.dart';
import 'package:pharmacy_arrival/screens/pharmacy_arrival/ui/pharmacy_generated_qr_screen.dart';
import 'package:pharmacy_arrival/screens/pharmacy_arrival/ui/pharmacy_qr_screen.dart';
import 'package:pharmacy_arrival/screens/pharmacy_arrival/vmodel/pharmacy_filter_vmodel.dart';
import 'package:pharmacy_arrival/widgets/app_loader_overlay.dart';
import 'package:pharmacy_arrival/widgets/custom_app_bar.dart';
import 'package:pharmacy_arrival/widgets/filter/pharmacy_filter_widget.dart';
import 'package:pharmacy_arrival/widgets/main_text_field/app_text_field.dart';
import 'package:pharmacy_arrival/widgets/snackbar/custom_snackbars.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../goods_list/ui/move_goods_list_screen.dart';

class PharmacyArrivalScreen extends StatefulWidget {
  const PharmacyArrivalScreen();

  @override
  State<PharmacyArrivalScreen> createState() => _PharmacyArrivalScreenState();
}

class _PharmacyArrivalScreenState extends State<PharmacyArrivalScreen> {
  RefreshController refreshController = RefreshController();
  TextEditingController searchController = TextEditingController();
  int currentIndex = 0;
  int status = 1;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<PharmacyFilterVmodel>(
        context,
        listen: false,
      ).clear();
    });
    BlocProvider.of<PharmacyArrivalCatCubit>(context).changeToNewOrdersCat();
    BlocProvider.of<PharmacyArrivalScreenCubit>(context)
        .onRefreshOrders(status: status);
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    FocusNode().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PharmacyFilterVmodel>(
      builder: (BuildContext context, model, Widget? child) {
        return AppLoaderOverlay(
          child: Scaffold(
            appBar: CustomAppBar(
              title: "Приход аптека".toUpperCase(),
              actions: [
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: SvgPicture.asset("assets/images/svg/new_qr.svg"),
                  onPressed: () {
                    AppRouter.push(context, const PharmacyQrScreen());
                  },
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 15,
              ),
              child: Column(
                children: [
                  AppTextField(
                    focusNode: FocusNode(),
                    onFieldSubmitted: (value) {
                      final productCubit =
                          BlocProvider.of<PharmacyArrivalScreenCubit>(context);

                      if (value.isNotEmpty) {
                        productCubit.onRefreshOrders(
                          number: searchController.text,
                          status: status,
                          senderId: model.sender?.id,
                          departureDate: model.departureDate,
                          sortType: model.sortType,
                          amountStart: model.amountStart,
                          amountEnd: model.amountEnd,
                        );
                      } else {
                        productCubit.onRefreshOrders(
                          status: status,
                          senderId: model.sender?.id,
                          departureDate: model.departureDate,
                          sortType: model.sortType,
                          amountStart: model.amountStart,
                          amountEnd: model.amountEnd,
                        );
                      }
                    },
                    onChanged: (String? text) {
                      final productCubit =
                          BlocProvider.of<PharmacyArrivalScreenCubit>(context);

                      if (text != null) {
                        productCubit.onRefreshOrders(
                          number: searchController.text,
                          status: status,
                          senderId: model.sender?.id,
                          departureDate: model.departureDate,
                          sortType: model.sortType,
                          amountStart: model.amountStart,
                          amountEnd: model.amountEnd,
                        );
                      }
                      if (text == null || text.isEmpty) {
                        productCubit.onRefreshOrders(
                          status: status,
                          senderId: model.sender?.id,
                          departureDate: model.departureDate,
                          sortType: model.sortType,
                          amountStart: model.amountStart,
                          amountEnd: model.amountEnd,
                        );
                      }
                    },
                    controller: searchController,
                    hintText: "Искать по номеру заказа",
                    hintStyle: ThemeTextStyle.textStyle14w400
                        .copyWith(color: ColorPalette.grey400),
                    fillColor: ColorPalette.white,
                    prefixIcon: SvgPicture.asset(
                      "assets/images/svg/search.svg",
                      colorFilter: const ColorFilter.mode(
                        ColorPalette.grey400,
                        BlendMode.srcIn,
                      ),
                    ),
                    contentPadding: const EdgeInsets.only(
                      top: 18,
                      bottom: 18,
                      left: 13,
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  PharmacyFilterWidget(
                    onTap: () {
                      AppRouter.push(
                        context,
                        PharmacyFilterPage(
                          isFromPharmacyPage: true,
                          callback: () {
                            BlocProvider.of<PharmacyArrivalScreenCubit>(
                              context,
                            ).onRefreshOrders(
                              number: searchController.text.isEmpty
                                  ? null
                                  : searchController.text,
                              status: status,
                              senderId: model.sender?.id,
                              departureDate: model.departureDate,
                              sortType: model.sortType,
                              amountStart: model.amountStart,
                              amountEnd: model.amountEnd,
                            );
                          },
                        ),
                      );
                    },
                    trailingCloseTap: () {
                      model.clear();
                      BlocProvider.of<PharmacyArrivalScreenCubit>(
                        context,
                      ).onRefreshOrders(
                        number: searchController.text.isEmpty
                            ? null
                            : searchController.text,
                        status: status,
                        senderId: model.sender?.id,
                        departureDate: model.departureDate,
                        sortType: model.sortType,
                        amountStart: model.amountStart,
                        amountEnd: model.amountEnd,
                      );
                    },
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.5,
                    ),
                    scrollDirection: Axis.horizontal,
                    child: BlocConsumer<PharmacyArrivalCatCubit,
                        PharmacyArrivalCatState>(
                      listener: (context, state) {
                        state.when(
                          newOrdersCatState: () {
                            currentIndex = 0;
                            status = 1;
                            BlocProvider.of<PharmacyArrivalScreenCubit>(
                              context,
                            ).onRefreshOrders(
                              number: searchController.text.isEmpty
                                  ? null
                                  : searchController.text,
                              status: status,
                              senderId: model.sender?.id,
                              departureDate: model.departureDate,
                              sortType: model.sortType,
                              amountStart: model.amountStart,
                              amountEnd: model.amountEnd,
                            );
                          },
                          discrepancyCatState: () {
                            currentIndex = 1;
                            status = 2;
                            BlocProvider.of<PharmacyArrivalScreenCubit>(
                              context,
                            ).onRefreshOrders(
                              number: searchController.text.isEmpty
                                  ? null
                                  : searchController.text,
                              status: status,
                              senderId: model.sender?.id,
                              departureDate: model.departureDate,
                              sortType: model.sortType,
                              amountStart: model.amountStart,
                              amountEnd: model.amountEnd,
                            );
                          },
                        );
                      },
                      builder: (context, state) {
                        return Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                BlocProvider.of<PharmacyArrivalCatCubit>(
                                  context,
                                ).changeToNewOrdersCat();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: currentIndex == 0
                                      ? ColorPalette.white
                                      : ColorPalette.main,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "Новые заказы",
                                  style:
                                      ThemeTextStyle.textStyle14w500.copyWith(
                                    color: currentIndex == 0
                                        ? ColorPalette.grayText
                                        : ColorPalette.grayTextDisabled,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 25,
                            ),
                            GestureDetector(
                              onTap: () {
                                BlocProvider.of<PharmacyArrivalCatCubit>(
                                  context,
                                ).changeToDiscrepanyCat();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: currentIndex == 1
                                      ? ColorPalette.white
                                      : ColorPalette.main,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      "Незавершенные заказы",
                                      style: ThemeTextStyle.textStyle14w500
                                          .copyWith(
                                        color: currentIndex == 1
                                            ? ColorPalette.grayText
                                            : ColorPalette.grayTextDisabled,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: BlocConsumer<PharmacyArrivalScreenCubit,
                          PharmacyArrivalScreenState>(
                        listener: (context, state) {
                          state.when(
                            initialState: () {},
                            loadingState: () {},
                            loadedState: (orders) {},
                            bySearch: (orders) {},
                            errorState: (String message) {
                              buildErrorCustomSnackBar(context, message);
                            },
                          );
                        },
                        builder: (context, state) {
                          return state.maybeWhen(
                            loadingState: () {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.amber,
                                ),
                              );
                            },
                            bySearch: (orders) {
                              return ListView.builder(
                                itemCount: orders.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return _BuildOrderData(
                                    orderData: orders[index],
                                  );
                                },
                              );
                            },
                            loadedState: (orders) {
                              return SmartRefresher(
                                enablePullUp: true,
                                onLoading: () {
                                  BlocProvider.of<PharmacyArrivalScreenCubit>(
                                    context,
                                  ).onLoadOrders(status: status);
                                  refreshController.loadComplete();
                                },
                                onRefresh: () {
                                  BlocProvider.of<PharmacyArrivalScreenCubit>(
                                    context,
                                  ).onRefreshOrders(
                                    number: searchController.text.isEmpty
                                        ? null
                                        : searchController.text,
                                    status: status,
                                    senderId: model.sender?.id,
                                    departureDate: model.departureDate,
                                    sortType: model.sortType,
                                    amountStart: model.amountStart,
                                    amountEnd: model.amountEnd,
                                  );
                                  refreshController.refreshCompleted();
                                },
                                controller: refreshController,
                                child: orders.isEmpty
                                    ? ListView(
                                        children: [
                                          SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.1,
                                          ),
                                          Center(
                                            child: Lottie.asset(
                                              'assets/lotties/empty_box.json',
                                            ),
                                          )
                                        ],
                                      )
                                    : ListView.builder(
                                        itemCount: orders.length,
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          return _BuildOrderData(
                                            orderData: orders[index],
                                          );
                                        },
                                      ),
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
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BuildOrderData extends StatelessWidget {
  final PharmacyOrderDTO orderData;

  const _BuildOrderData({required this.orderData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: ColorPalette.white,
        ),
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "№ ${orderData.number}",
                    style: ThemeTextStyle.textStyle20w600,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: orderData.status == 1
                        ? ColorPalette.lightGreen
                        : ColorPalette.lightYellow,
                    border: Border.all(
                      color: orderData.status == 1
                          ? ColorPalette.borderGreen
                          : ColorPalette.borderYellow,
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Center(
                    child: Text(
                      orderData.status == 1 ? "Новый заказ" : "Активный заказ",
                      style: ThemeTextStyle.textStyle12w600.copyWith(
                        color: orderData.status == 1
                            ? ColorPalette.textGreen
                            : ColorPalette.textYellow,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 27,
            ),
            if (orderData.status != 1)
              const _BuildOrderDetailItem(
                icon: "divergence",
                title: "Товары на расхождении",
                data: "5",
              ),
            _BuildOrderDetailItem(
              icon: "container_ic",
              title: "Контейнеров",
              data: (orderData.container ?? 0).toString(),
            ),
            _BuildOrderDetailItem(
              icon: "calendar_ic",
              title: "Время отпр.",
              data: orderData.createdAt != null
                  ? DateFormat("dd.MM.yyyy; hh:mm")
                      .format(DateTime.parse('${orderData.createdAt}'))
                  : "No data",
            ),
            _BuildOrderDetailItem(
              icon: "user_star_ic",
              title: orderData.status == 1 ? "Отправитель" : "Контрагент",
              data: "${orderData.sender?.name}",
              hasImage: true,
            ),
            _BuildOrderDetailItem(
              icon: "document",
              title: "Сумма",
              data: "${moneyFormatter(orderData.amount.toString())} ₸",
            ),
            const SizedBox(
              height: 24,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: ColorPalette.white,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            width: 5,
                            color: ColorPalette.textYellow,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "${orderData.fromAddress}, ",
                                style: ThemeTextStyle.textStyle16w500,
                              ),
                              TextSpan(
                                text: orderData.fromCityName,
                                style: ThemeTextStyle.textStyle14w400.copyWith(
                                  color: ColorPalette.grey400,
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  // SizedBox(
                  //   height: 20,
                  // ),
                  Container(
                    padding: const EdgeInsets.only(left: 7),
                    height: 20,
                    child: const DottedLine(
                      dashColor: ColorPalette.dashGrey,
                      direction: Axis.vertical,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: ColorPalette.white,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            width: 5,
                            color: ColorPalette.orange,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "${orderData.toAddress}, ",
                                style: ThemeTextStyle.textStyle14w400,
                              ),
                              TextSpan(
                                text: orderData.toCityName,
                                style: ThemeTextStyle.textStyle14w400.copyWith(
                                  color: ColorPalette.grey400,
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 21,
            ),
            _BuildOrderDetailItem(
              icon: "messages",
              title: "Статус",
              data: "${totalStatuses[orderData.totalStatus]}",
            ),
            _BuildOrderDetailItem(
              icon: "clock",
              title: "Время доставки",
              data: "${orderData.yandexTime}",
            ),
            const SizedBox(
              height: 12,
            ),
            if (orderData.totalStatus == 3 || orderData.totalStatus == 4)
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      BlocProvider.of<SignatureScreenCubit>(context)
                          .updatePharmacyOrderStatus(
                        orderId: orderData.id,
                        status: 2,
                      );
                      context.read<FillInvoiceVModel>().init();
                      AppRouter.push(
                        context,
                        FillInvoiceScreen(
                          isFromPharmacyPage: true,
                          pharmacyOrder: orderData,
                        ),
                      );
                      // TODO: First goods list
                      // AppRouter.push(
                      //   context,
                      //   GoodsListScreen(
                      //     isFromPharmacyPage: true,
                      //     pharmacyOrder: orderData,
                      //   ),
                      // );
                    },
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: ColorPalette.orange,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          "Оприходовать",
                          style: ThemeTextStyle.textStyle14w600
                              .copyWith(color: ColorPalette.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  GestureDetector(
                    onTap: () async {
                      AppRouter.push(
                        context,
                        PharmacyGeneratedQrScreen(
                          order: orderData,
                        ),
                      );
                    },
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: ColorPalette.orange,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          "Подписать",
                          style: ThemeTextStyle.textStyle14w600
                              .copyWith(color: ColorPalette.white),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              const SizedBox(),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  ///
  ///CROSS SIGNING METHOD
  ///
  Future<void> crossSigning() async {
    const String path = 'https://mgovsign.page.link';
    String platformPath = '';
    String platformPathLabel = '';
    if (Platform.isAndroid) {
      platformPath = 'kz.mobile.mgov';
      platformPathLabel = 'apn';
    } else if (Platform.isIOS) {
      platformPath = '1476128386&ibi=kz.egov.mobile';
      platformPathLabel = 'isi';
    }
    // log(ourEncodedUrl,name:"ENCODED DATA");
    log('$path/?link=https://tsd-aqnietgroup.kz/api/ecp/first/&$platformPathLabel=$platformPath');
    await _launchUrl(
      Uri.parse(
        "$path/?link=https://tsd-aqnietgroup.kz/api/ecp/first/&$platformPathLabel=$platformPath",
      ),
    );
  }
}

class _BuildOrderDetailItem extends StatelessWidget {
  final String icon;
  final String title;
  final String data;
  final bool hasImage;

  const _BuildOrderDetailItem({
    required this.icon,
    required this.title,
    required this.data,
    this.hasImage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Row(
            children: [
              SvgPicture.asset(
                "assets/images/svg/$icon.svg",
                height: 18,
                width: 18,
              ),
              const SizedBox(
                width: 14,
              ),
              Text(
                title,
                style: ThemeTextStyle.textStyle14w400
                    .copyWith(color: ColorPalette.grey400),
              ),
            ],
          ),
          const SizedBox(
            width: 14,
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    data,
                    style: ThemeTextStyle.textStyle16w500,
                    textAlign: TextAlign.end,
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                if (hasImage)
                  Image.asset(
                    "assets/images/png/akniet_stock.png",
                    width: 32,
                    height: 32,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
