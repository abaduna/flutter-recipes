import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ZippiriNetworkService {

  static Future<dynamic> get(
      String url, Function successCallback, Function errorCallback,
      {Map<String, String>? queryParams}) async {
    var uri = Uri.parse(url).replace(queryParameters: queryParams);
    print('GET request to: $uri');
    if(queryParams!=null) print('GET params: $queryParams');
    var response = await http.get(uri, headers: await _headers());
    await _processResponse(response, successCallback, errorCallback);
  }

  static Future<dynamic> unauthorizedGet(
      String url, Function successCallback, Function errorCallback,
      {Map<String, String>? queryParams}) async {
    var uri = Uri.parse(url).replace(queryParameters: queryParams);
    final headers = _unauthorizedHeaders();
    print('unauth GET request to: $uri');
    if(queryParams!=null) print('GET params: $queryParams');
    var response = await http.get(uri, headers: headers);
    await _processResponse(response, successCallback, errorCallback);
  }

  static Future<File> download(String url,
      {Map<String, String>? queryParams}) async {
    var uri = Uri.parse(url).replace(queryParameters: queryParams);
    var response = await http.get(uri, headers: await _headers());
    if (response.statusCode == 200) {
      final tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      File file = File('$tempPath/tmp');
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } else {
      throw HttpException('Failed to download file', uri: uri);
    }
  }

  static Future<dynamic> post(String url, Function successCallback, Function errorCallback, {dynamic body, Map<String, String>? queryParams}) async {
      Uri uri = Uri.parse(url);
      print("Request body: $body");
      if (queryParams != null) {
        print("Query parameters: $queryParams");
        uri = uri.replace(queryParameters: queryParams);
      }
      var response = await http.post(uri,
          headers: await _headers(), body: json.encode(body));
      await _processResponse(response, successCallback, errorCallback);
  }

  static Future<dynamic> unauthorizedPost(String url, dynamic body,
    Function successCallback, Function errorCallback) async {
    try {
      print("Enviando POST a: $url");
      print("Body: ${json.encode(body)}");
      
      var response = await http.post(
        Uri.parse(url),
        headers: _unauthorizedHeaders(),
        body: json.encode(body)
      );
      
      print("Código de estado: ${response.statusCode}");
      print("Respuesta: ${response.body}");
      
      await _processResponse(response, successCallback, errorCallback);
    } catch (e) {
      print("Excepción en unauthorizedPost: $e");
      errorCallback('Error: $e');
    }
  }

  static Future<dynamic> put(String url, dynamic body, Function successCallback,
      Function errorCallback) async {
    var response = await http.put(Uri.parse(url),
        headers: await _headers(), body: json.encode(body));
    await _processResponse(response, successCallback, errorCallback);
  }

  static Future<dynamic> patch(String url, dynamic body, Function successCallback,
      Function errorCallback) async {
    try {
      var response = await http.patch(Uri.parse(url),
          headers: await _headers(), body: json.encode(body));
      await _processResponse(response, successCallback, errorCallback);
    } catch (error) {
      errorCallback('$error');
    }
  }

  static Future<dynamic> delete(
      String url, Function successCallback, Function errorCallback,
      {Map<String, String>? queryParams}) async {
    var uri = Uri.parse(url).replace(queryParameters: queryParams);
    var response = await http.delete(uri, headers: await _headers());
    await _processResponse(response, successCallback, errorCallback);
  }

  static Future<Map<String, String>> _headers() async {
    String? token = await _getToken();
    if (token == null || token.isEmpty) {
      print('No token found when trying to make an authorized request');
    }
      return {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };
  }

  static Map<String, String> _unauthorizedHeaders() => {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  static Future<dynamic> _processResponse(http.Response response,
    Function successCallback, Function errorCallback) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      successCallback(response); // Pass the full response object
    } else if (response.statusCode == 401) {
      //clear token and current user and isauthenticated
      //this is temporary until we implement refresh token
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('authToken');
      prefs.remove('currentUser');
      prefs.setBool('isAuthenticated', false);
      //TODO: refresh token logic
      // Token might be expired, try to refresh it
      bool tokenRefreshed = await _refreshToken();
      if (tokenRefreshed) {
        // Retry the request with the new token
        return await _retryRequest(response.request!, successCallback, errorCallback);
      } else {
        errorCallback('Error: solicitud fallida con código ${response.statusCode}');
      }
    } else {
      // Intentar decodificar el cuerpo de la respuesta como JSON
      try {
        final errorBody = json.decode(utf8.decode(response.bodyBytes));
        final errorMessage =errorBody ?? 'errore sconosciuto';
        errorCallback('$errorMessage');
      } catch (e) {
        // Si no se puede decodificar como JSON, usar el cuerpo de la respuesta como está
        errorCallback('${response.body}');
      }
    }
  }

  static Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jwt = prefs.getString('authToken');
    return jwt;
  }

  static Future<bool> _refreshToken() async {
    // Implement your token refresh logic here
    // For example, make a request to refresh the token and update _cachedToken
    // Return true if the token was successfully refreshed, otherwise false
    return false;
  }

  static Future<dynamic> _retryRequest(http.BaseRequest request, Function successCallback, Function errorCallback) async {
    var response = await http.Response.fromStream(await request.send());
    await _processResponse(response, successCallback, errorCallback);
  }
}
