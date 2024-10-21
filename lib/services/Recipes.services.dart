import 'package:recipes/Communs/zippiri_network_service.dart';


class RecipesService {
  static Future<dynamic> getRecipesWithoutAuth(String url) async {
    dynamic result;
    await ZippiriNetworkService.unauthorizedGet(
      url,
      (response) {
        // Función de éxito
        print('Respuesta exitosa: ${response.body}');
        result = response.body;
      },
      (error) {
        // Función de error
        print('Error en la solicitud: $error');
        result = null;
      },
    );
    return result;
  }
}

