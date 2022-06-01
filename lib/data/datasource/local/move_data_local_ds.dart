// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:developer';

import 'package:pharmacy_arrival/core/error/excepteion.dart';
import 'package:pharmacy_arrival/data/model/move_data_dto.dart';
import 'package:pharmacy_arrival/data/model/product_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class MoveDataLocalDS {
  Future<List<ProductDTO>> getMoveProductsFromCache();

  Future<void> saveMoveProductsToCache({required List<ProductDTO> products});
  Future<void> deleteMoveProductsFromCache();

  Future<MoveDataDTO> getMoveDataFromCache();

  Future<void> saveMoveDataToCache({
    required MoveDataDTO moveDataDTO,
  });

  Future<void> deleteMoveDataFromCache();
}

const MOVE_DATA_CACHE = 'MOVE_DATA';
const MOVE_PRODUCTS_CACHE = 'MOVE_PRODUCTS_CACHE';

class MoveDataLocalDSImpl extends MoveDataLocalDS {
  final SharedPreferences sharedPreferences;

  MoveDataLocalDSImpl(this.sharedPreferences);
  @override
  Future<void> deleteMoveDataFromCache() async {
    sharedPreferences.remove(
      MOVE_DATA_CACHE,
    );
  }

  @override
  Future<MoveDataDTO> getMoveDataFromCache() async {
    try {
      final user = sharedPreferences.get(MOVE_DATA_CACHE);
      if (user != null) {
        return MoveDataDTO.fromJson(
          jsonDecode(user.toString()) as Map<String, dynamic>,
        );
      } else {
        throw CacheException(message: 'В кэше нет запрашиваемые данные');
      }
    } catch (e) {
      log('getMoveDataFromCache:: $e');
      throw CacheException(message: 'В кэше нет запрашиваемые данные');
    }
  }

  @override
  Future<void> saveMoveDataToCache({
    required MoveDataDTO moveDataDTO,
  }) async {
    sharedPreferences.setString(
      MOVE_DATA_CACHE,
      jsonEncode(moveDataDTO.toJson()),
    );
  }

  @override
  Future<List<ProductDTO>> getMoveProductsFromCache() async {
    final jsonPersonsList =
        sharedPreferences.getStringList(MOVE_PRODUCTS_CACHE);
    if (jsonPersonsList!=null&&jsonPersonsList.isNotEmpty) {
      log('Get Products from Cache: ${jsonPersonsList.length}');
      return Future.value(
        jsonPersonsList
            .map(
              (city) =>
                  ProductDTO.fromJson(jsonDecode(city) as Map<String, dynamic>),
            )
            .toList(),
      );
    } else {
      throw CacheException(message: 'В кэше нет запрашиваемые данные');
    }
  }

  @override
  Future<void> saveMoveProductsToCache({required List<ProductDTO> products}) {
    final List<String> jsonCitiesList =
        products.map((person) => json.encode(person.toJson())).toList();

    sharedPreferences.setStringList(MOVE_PRODUCTS_CACHE, jsonCitiesList);
    log('Products to write Cache: ${jsonCitiesList.length}');
    return Future.value(jsonCitiesList);
  }

  @override
  Future<void> deleteMoveProductsFromCache() async {
    log('Products removed from Cache');
    sharedPreferences.remove(
      MOVE_PRODUCTS_CACHE,
    );
  }
}
