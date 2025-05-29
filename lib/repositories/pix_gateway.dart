import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triacore_mobile/models/asset_catalog.dart';
import 'package:triacore_mobile/models/payments.dart';
import 'package:triacore_mobile/services/triacore_client/user.dart';
import 'package:unique_identifier/unique_identifier.dart';
import 'package:crypto/crypto.dart';

const BACKEND_URL = String.fromEnvironment(
  "BACKEND_URL",
  defaultValue: "basetria.xyz",
);

class PixGatewayRepository {
  Future<PixTransactionResponse?> newPixPayment(
    PixTransaction pixTransaction,
  ) async {
    try {
      if (kDebugMode) {
        print('=== INICIANDO NOVA TRANSAÇÃO PIX ===');
        print('Valor: ${pixTransaction.brlAmount}');
        print('Endereço: ${pixTransaction.address}');
      }
      final userService = UserService(backendUrl: BACKEND_URL);
      if (kDebugMode) {
        print('Obtendo ID do usuário...');
      }
      final userId = await userService.getUserId();
      
      if (userId == null) {
        if (kDebugMode) {
          print('ERRO: ID do usuário não encontrado');
        }
        return null;
      } else {
        if (kDebugMode) {
          print('ID do usuário obtido: $userId');
        }
      }
      
      final identifier = await UniqueIdentifier.serial ?? "unknown";
      final hashedIdentifier = sha256.convert(utf8.encode(identifier)).toString();

      // Obtém o asset LBTC do catálogo
      final lbtcAsset = AssetCatalog.getById('lbtc');
      if (lbtcAsset == null) {
        if (kDebugMode) {
          print('ERRO: Ativo LBTC não encontrado no catálogo');
        }
        return null;
      }
      
      if (lbtcAsset.liquidAssetId == null || lbtcAsset.liquidAssetId!.isEmpty) {
        if (kDebugMode) {
          print('ERRO: ID do ativo LBTC não encontrado');
        }
        return null;
      }
      
      final requestBody = {
        "amount_in_cents": pixTransaction.brlAmount,
        "address": pixTransaction.address,
        "user_id": userId,
        "asset": lbtcAsset.liquidAssetId,  // Usando o asset_id do LBTC do catálogo
        "network": "liquid",
        "device_id": hashedIdentifier,
      };

      if (kDebugMode) {
        print('Enviando requisição para o servidor...');
        print('URL: https://$BACKEND_URL/deposit');
        print('Corpo da requisição: ${jsonEncode(requestBody)}');
      }

      final response = await http.post(
        Uri.https(BACKEND_URL, "/deposit"),
        headers: <String, String>{
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          if (kDebugMode) {
            print('ERRO: Tempo de conexão esgotado');
          }
          throw Exception('Tempo de conexão esgotado');
        },
      );

      if (kDebugMode) {
        print('Resposta do servidor:');
        print('Status code: ${response.statusCode}');
        print('Corpo da resposta: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final jsonResponse = json.decode(response.body);
          
          if (jsonResponse["error"] == null) {
            final data = jsonResponse["data"];
            if (data == null) {
              if (kDebugMode) {
                print('ERRO: Dados da transação não encontrados na resposta');
              }
              return null;
            }
            
            final responseObj = PixTransactionResponse(
              qrImageUrl: data["qr_image_url"]?.toString() ?? '',
              qrCopyPaste: data["qr_copy_paste"]?.toString() ?? '',
              id: data["transaction_id"]?.toString() ?? '',
            );
            
            if (kDebugMode) {
              print('=== TRANSAÇÃO CRIADA COM SUCESSO ===');
              print('ID da transação: ${responseObj.id}');
              print('URL do QR Code: ${responseObj.qrImageUrl}');
            }
            
            return responseObj;
          } else {
            if (kDebugMode) {
              print('ERRO: ${jsonResponse["error"]}');
            }
            return null;
          }
        } catch (e) {
          if (kDebugMode) {
            print('ERRO ao processar resposta do servidor:');
            print(e.toString());
          }
          return null;
        }
      } else {
        if (kDebugMode) {
          print('ERRO: Status code inesperado: ${response.statusCode}');
          print('Resposta: ${response.body}');
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('ERRO NA TRANSAÇÃO PIX:');
        print(e.toString());
      }
      return null;
    }
  }
}
