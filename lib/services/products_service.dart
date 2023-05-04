import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/products.dart';

class ProductsService extends ChangeNotifier {

  final String _baseUrl = 'pmdm-ud5-default-rtdb.europe-west1.firebasedatabase.app';
  final List<Product> products = [];
  late Product selectedProduct;
  File? newPicture;

  bool isLoading = true; 
  bool isSaving = false; 

  ProductsService () {
    this.loadProducts();
  }

  Future loadProducts() async {
    isLoading = true;
    notifyListeners();

    final url = Uri.https(_baseUrl, 'products.json');
    final response = await http.get(url);

    final Map<String, dynamic> productsMap = json.decode(response.body);
    productsMap.forEach((key, value) {
      final temporalProduct = Product.fromJson(value);
      temporalProduct.id = key;
      products.add(temporalProduct);
    });

    isLoading = false;
    notifyListeners();
  }

  Future saveOrCreateProduct(Product product) async {
    isSaving = true;
    notifyListeners();

    product.id == null ? await createProduct(product) : await updateProduct(product);

    isSaving = false;
    notifyListeners();
  }

  Future<String> updateProduct(Product product) async {
    final url = Uri.https(_baseUrl, 'products/${product.id}.json');
    final response = await http.put(
      url,
      body: product.toRawJson()
    );

    final index = this.products.indexWhere((element) => element.id == product.id);
    this.products[index] = product;

    return product.id!;
  }

  Future<String> createProduct(Product product) async {
    final url = Uri.https(_baseUrl, 'products.json');
    final response = await http.post(
      url,
      body: product.toRawJson()
    );
    final decodeResponse = json.decode(response.body);
    product.id = decodeResponse['name'];
    this.products.add(product);

    return product.id!;
  }

  void updateSelectedImage(String path) {
    this.newPicture = File.fromUri(Uri(path: path));
    this.selectedProduct.picture = path;
    notifyListeners();
  }

  Future<String?> uploadImage() async {
    if(this.newPicture == null) return null;
    
    this.isSaving = true;
    notifyListeners();

    final url = Uri.parse('https://api.cloudinary.com/v1_1/dvpqm9mmc/image/upload?upload_preset=qdjfoer2');
    final imageUploadRequest = http.MultipartRequest('POST', url);
    final file = await http.MultipartFile.fromPath('file', newPicture!.path);
    imageUploadRequest.files.add(file);

    final streamResponse = await imageUploadRequest.send();
    final response = await http.Response.fromStream(streamResponse);

    if(response.statusCode != 200 && response.statusCode != 201) {
      print(response.statusCode);
      return null;
    }
    this.newPicture = null;
    final decodeResponse = json.decode(response.body);
    return decodeResponse['secure_url'];
  }
}