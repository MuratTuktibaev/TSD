import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharmacy_arrival/domain/usecases/auth_check.dart';
import 'package:pharmacy_arrival/locator_serviece.dart';
import 'package:pharmacy_arrival/main/counteragent_cubit/counteragent_cubit.dart';
import 'package:pharmacy_arrival/main/login_bloc/login_bloc.dart';
import 'package:pharmacy_arrival/main/organization_cubit/organization_cubit.dart';
import 'package:pharmacy_arrival/screens/auth/bloc/bloc_auth.dart';
import 'package:pharmacy_arrival/screens/auth/bloc/sign_in_cubit.dart';
import 'package:pharmacy_arrival/screens/goods_list/cubit/goods_list_screen_cubit.dart';
import 'package:pharmacy_arrival/screens/move_data/move_cubit/move_cubit.dart';
import 'package:pharmacy_arrival/screens/move_data/move_data_cubit/move_barcode_screen_cubit.dart';
import 'package:pharmacy_arrival/screens/move_data/move_data_cubit/move_data_screen_cubit.dart';
import 'package:pharmacy_arrival/screens/move_data_products/move_products_cubit/move_products_screen_cubit.dart';
import 'package:pharmacy_arrival/screens/pharmacy_arrival/cubit/pharmacy_arrival_screen_cubit.dart';
import 'package:pharmacy_arrival/screens/signature/cubit/signature_screen_cubit.dart';
import 'package:pharmacy_arrival/screens/warehouse_arrival/cubit/warehouse_arrival_screen_cubit.dart';

///Providers for global blocs
class TopLevelBlocs extends StatelessWidget {
  final Widget child;

  const TopLevelBlocs({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              LoginBloc(sl<AuthCheck>())..add(InitialLoginEvent()),
        ),
        BlocProvider(create: (context) => BlocAuth()),
        BlocProvider<SignInCubit>(
          create: (context) => sl<SignInCubit>(),
        ),
        BlocProvider<WarehouseArrivalScreenCubit>(
          create: (context) => sl<WarehouseArrivalScreenCubit>(),
        ),
        BlocProvider<PharmacyArrivalScreenCubit>(
          create: (context) => sl<PharmacyArrivalScreenCubit>(),
        ),
         BlocProvider<GoodsListScreenCubit>(
          create: (context) => sl<GoodsListScreenCubit>(),
        ),
         BlocProvider<SignatureScreenCubit>(
          create: (context) => sl<SignatureScreenCubit>(),
        ),
         BlocProvider<OrganizationCubit>(
          create: (context) => sl<OrganizationCubit>(),
        ),
         BlocProvider<CounteragentsCubit>(
          create: (context) => sl<CounteragentsCubit>(),
        ),
        BlocProvider<MoveCubit>(
          create: (context) => sl<MoveCubit>(),
        ),
         BlocProvider<MoveDataScreenCubit>(
          create: (context) => sl<MoveDataScreenCubit>(),
        ),
         BlocProvider<MoveBarcodeScreenCubit>(
          create: (context) => sl<MoveBarcodeScreenCubit>(),
        ),
         BlocProvider<MoveProductsScreenCubit>(
          create: (context) => sl<MoveProductsScreenCubit>(),
        ),
        
      ],
      child: child,
    );
  }
}
