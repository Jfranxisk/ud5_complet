import 'dart:convert';

class Product {
  bool available;
  String nom;
  String? picture;
  double price;
  String ? id;

  Product({
    required this.available,
    required this.nom,
    this.picture,
    required this.price,
    this.id
  });

  factory Product.fromRawJson(String str) => Product.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    available: json["available"],
    nom: json["nom"],
    picture: json["picture"],
    price: json["price"].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "available": available,
    "nom": nom,
    "picture": picture,
    "price": price,
  };

  Product clone() => Product(
    available: this.available, 
    nom: this.nom, 
    price: this.price, 
    picture: this.picture, 
    id: this.id
  );
}