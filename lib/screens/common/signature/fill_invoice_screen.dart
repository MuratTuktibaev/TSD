import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:pharmacy_arrival/core/styles/color_palette.dart';
import 'package:pharmacy_arrival/core/styles/text_styles.dart';
import 'package:pharmacy_arrival/core/utils/app_router.dart';
import 'package:pharmacy_arrival/data/model/pharmacy_order_dto.dart';
import 'package:pharmacy_arrival/data/model/warehouse_order_dto.dart';
import 'package:pharmacy_arrival/screens/common/signature/cubit/signature_screen_cubit.dart';
import 'package:pharmacy_arrival/screens/common/signature/fill_invoice_vmodel.dart';
import 'package:pharmacy_arrival/screens/goods_list/ui/goods_list_screen.dart';
import 'package:pharmacy_arrival/screens/pharmacy_arrival/cubit/pharmacy_arrival_screen_cubit.dart';
import 'package:pharmacy_arrival/screens/warehouse_arrival/cubit/warehouse_arrival_screen_cubit.dart';
import 'package:pharmacy_arrival/widgets/app_loader_overlay.dart';
import 'package:pharmacy_arrival/widgets/custom_app_bar.dart';
import 'package:pharmacy_arrival/widgets/main_text_field/app_text_field.dart';
import 'package:pharmacy_arrival/widgets/snackbar/custom_snackbars.dart';

//TODO страница подписания накладная
class FillInvoiceScreen extends StatefulWidget {
  final bool isFromPharmacyPage;
  final PharmacyOrderDTO? pharmacyOrder;
  final WarehouseOrderDTO? warehouseOrder;
  const FillInvoiceScreen({
    super.key,
    this.warehouseOrder,
    this.pharmacyOrder,
    required this.isFromPharmacyPage,
  });

  @override
  State<FillInvoiceScreen> createState() => _FillInvoiceScreenState();
}

class _FillInvoiceScreenState extends State<FillInvoiceScreen> {
  TextEditingController numberController = TextEditingController();
  FocusNode focusNode1 = FocusNode();

  String? recipient;
  int recipientId = -1;

  @override
  void dispose() {
    focusNode1.dispose();
    numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FillInvoiceVModel vmodel = context.read<FillInvoiceVModel>();

    if (widget.pharmacyOrder?.incomingDate != null) {
      vmodel.incomeNumberDateController.text =
          DateFormat("yyyy-MM-dd").format((DateTime.tryParse((widget.pharmacyOrder?.incomingDate as String) + " 00:00:00") as DateTime));
    }
    if (widget.pharmacyOrder?.incomingNumber != null) {
      vmodel.incomeNumber.controller.text =
      widget.pharmacyOrder?.incomingNumber as String;
    }
    
    return AppLoaderOverlay(
      child: BlocConsumer<SignatureScreenCubit, SignatureScreenState>(
        listener: (context, state) {
          state.when(
            initialState: () {
              context.loaderOverlay.hide();
            },
            loadingState: () {
              context.loaderOverlay.show();
            },
            loadedState: () {
              context.loaderOverlay.hide();
              // buildSuccessCustomSnackBar(
              //   context,
              //   'Накладная будет загружена в 1С в течении 15 минут !',
              // );
              widget.isFromPharmacyPage
                  ? BlocProvider.of<PharmacyArrivalScreenCubit>(context)
                      .onRefreshOrders(status: 1)
                  : BlocProvider.of<WarehouseArrivalScreenCubit>(context)
                      .onRefreshOrders(status: 1);

              // AppRouter.push(
              //   context,
              //   GoodsListScreen(
              //     isFromPharmacyPage: true,
              //     pharmacyOrder: widget.pharmacyOrder,
              //   ),
              // );
              //
              // TODO: First goods list
              // AppRouter.pushAndRemoveUntilRoot(
              //   context,
              //   const PharmacyArrivalScreen(),
              // );
            },
            errorState: (message) {
              context.loaderOverlay.hide();
              buildErrorCustomSnackBar(context, message);
            },
          );
        },
        builder: (context, state) {
          return Scaffold(
            appBar: CustomAppBar(
              title: widget.isFromPharmacyPage
                  ? '№.${widget.pharmacyOrder?.id} ${widget.pharmacyOrder?.number}'
                  : '№.${widget.warehouseOrder?.id} ${widget.warehouseOrder?.number}',
            ),
            body: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 15.0, horizontal: 16.5),
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Заполните накладную",
                          style: ThemeTextStyle.textTitleDella16w400,
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: ColorPalette.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              vmodel.incomeNumber,
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: Divider(
                                  color: ColorPalette.borderGrey,
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  final DateTime? date = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2019),
                                    lastDate: DateTime.now(),
                                    helpText: "Дата входящего номера",
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: const ColorScheme.light(
                                            primary: ColorPalette.greyDark,
                                          ),
                                          textTheme: TextTheme(
                                            headlineSmall: ThemeTextStyle
                                                .textTitleDella24w400,
                                            labelSmall:
                                                ThemeTextStyle.textStyle16w600,
                                          ),
                                          textButtonTheme: TextButtonThemeData(
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.black,
                                              textStyle: ThemeTextStyle
                                                  .textStyle14w600
                                                  .copyWith(
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (widget.pharmacyOrder?.createdAt != null) {
                                    var currentDate =  DateTime.tryParse(widget.pharmacyOrder?.createdAt as String);
                                    if (currentDate != null) {
                                    if(date!.isBefore(currentDate.add(Duration(hours:-24))!)){
                                      buildErrorCustomSnackBar(
                                        context,
                                        "Укажите корректную дату.",
                                      );
                                    } else {
                                      if (date != null) {
                                        vmodel.incomeNumberDateController.text =
                                            DateFormat("yyyy-MM-dd").format(date);
                                      }
                                    }
                                    }
                                  }

                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Дата вх. номера",
                                      style: ThemeTextStyle.textStyle14w400
                                          .copyWith(
                                        color: ColorPalette.grey400,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 16,
                                    ),
                                    Flexible(
                                      child: AppTextField(
                                        focusNode: focusNode1,
                                        contentPadding: EdgeInsets.zero,
                                        capitalize: false,
                                        controller:
                                            vmodel.incomeNumberDateController,
                                        readonly: true,
                                        textAlign: TextAlign.right,
                                        showErrorMessages: false,
                                        suffixIcon: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: GestureDetector(
                                            onTap: () async {
                                              final DateTime? date =
                                                  await showDatePicker(
                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime(2019),
                                                lastDate: DateTime.now(),
                                                helpText:
                                                    "Дата входящего номера",
                                                builder: (context, child) {
                                                  return Theme(
                                                    data: Theme.of(context)
                                                        .copyWith(
                                                      colorScheme:
                                                          const ColorScheme
                                                              .light(
                                                        primary: ColorPalette
                                                            .greyDark,
                                                      ),
                                                      textTheme: TextTheme(
                                                        headlineSmall:
                                                            ThemeTextStyle
                                                                .textTitleDella24w400,
                                                        labelSmall:
                                                            ThemeTextStyle
                                                                .textStyle16w600,
                                                      ),
                                                      textButtonTheme:
                                                          TextButtonThemeData(
                                                        style: TextButton
                                                            .styleFrom(
                                                          foregroundColor:
                                                              Colors.black,
                                                          textStyle:
                                                              ThemeTextStyle
                                                                  .textStyle14w600
                                                                  .copyWith(
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    child: child!,
                                                  );
                                                },
                                              );
                                              if (date != null) {
                                                vmodel
                                                    .incomeNumberDateController
                                                    .text = DateFormat(
                                                  "yyyy-MM-dd",
                                                ).format(date);
                                              }
                                            },
                                            child: SvgPicture.asset(
                                              "assets/images/svg/calendar_circle_ic.svg",
                                              width: 24,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        MaterialButton(
                          height: 40,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          color: ColorPalette.orange,
                          disabledColor: ColorPalette.orangeInactive,
                          padding: EdgeInsets.zero,
                          onPressed: () {

                            if (vmodel
                                    .incomeNumber.controller.text.isNotEmpty &&
                                vmodel.incomeNumberDateController.text
                                    .isNotEmpty) {
                              widget.isFromPharmacyPage
                                  ? BlocProvider.of<SignatureScreenCubit>(
                                      context,
                                    )
                                      .updatePharmacyOrderStatus(
                                        orderId: widget.isFromPharmacyPage
                                            ? widget.pharmacyOrder!.id
                                            : widget.warehouseOrder!.id,
                                        status: 2,
                                        incomingNumber: vmodel.incomeNumber
                                                .controller.text.isEmpty
                                            ? null
                                            : vmodel
                                                .incomeNumber.controller.text,
                                        incomingDate: vmodel
                                                .incomeNumberDateController
                                                .text
                                                .isEmpty
                                            ? null
                                            : vmodel.incomeNumberDateController
                                                .text,
                                        bin: vmodel.bin.controller.text.isEmpty
                                            ? null
                                            : vmodel.bin.controller.text,
                                        invoiceDate:
                                            vmodel.invoiceDate.text.isEmpty
                                                ? null
                                                : vmodel.invoiceDate.text,
                                        recipientId: vmodel.recipientId == -1
                                            ? null
                                            : vmodel.recipientId,
                                      )
                                      .onError((error, stackTrace) =>
                                          buildErrorCustomSnackBar(
                                            context,
                                            "Укажите корректную дату.",
                                          ))
                                  : BlocProvider.of<SignatureScreenCubit>(
                                      context,
                                    ).updateWarehouseOrderStatus(
                                      orderId: widget.isFromPharmacyPage
                                          ? widget.pharmacyOrder!.id
                                          : widget.warehouseOrder!.id,
                                      status: 2,
                                      incomingNumber: vmodel.incomeNumber
                                              .controller.text.isEmpty
                                          ? null
                                          : vmodel.incomeNumber.controller.text,
                                      incomingDate: vmodel
                                              .incomeNumberDateController
                                              .text
                                              .isEmpty
                                          ? null
                                          : vmodel
                                              .incomeNumberDateController.text,
                                      bin: vmodel.bin.controller.text.isEmpty
                                          ? null
                                          : vmodel.bin.controller.text,
                                      invoiceDate:
                                          vmodel.invoiceDate.text.isEmpty
                                              ? null
                                              : vmodel.invoiceDate.text,
                                      counteragentId: vmodel.recipientId == -1
                                          ? null
                                          : vmodel.recipientId,

                                    );

                              AppRouter.push(
                              context,
                              GoodsListScreen(
                              isFromPharmacyPage: true,
                              pharmacyOrder: widget.pharmacyOrder,
                              ),
                              );



                            } else {
                              buildErrorCustomSnackBar(
                                context,
                                'Не все поля заполнены!!!',
                              );
                            }

                            // AppRouter.push(
                            //   context,
                            //   const DigitalSignatureLoadScreen(),
                            // );
                            // }
                          },
                          child: Center(
                            child: Text(
                              "ДАЛЕЕ",
                              style: ThemeTextStyle.textStyle14w600
                                  .copyWith(color: ColorPalette.white),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
