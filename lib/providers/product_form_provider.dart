import 'package:flutter/material.dart';
import '../models/models.dart';

class ProductFormProvider extends ChangeNotifier {
  GlobalKey<FormState> formKey = new GlobalKey<FormState>();

  Product cloneProduct;
  ProductFormProvider(this.cloneProduct);

  bool isValidForm () {
    print('El nombre es ${cloneProduct.nom}');
    print('El precio es ${cloneProduct.price}');
    print('La dispo es ${cloneProduct.available}');
    return formKey.currentState?.validate() ?? false; }

  updateCloneAvailability (bool value) {
    print('Availability ha cambiado a $value');
    this.cloneProduct.available = value;
    notifyListeners();
  }
}