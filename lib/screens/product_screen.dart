import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:productes_app/providers/product_form_provider.dart';
import 'package:productes_app/services/products_service.dart';
import 'package:productes_app/widgets/widgets.dart';
import 'package:provider/provider.dart';

import '../ui/input_decorations.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<ProductsService>(context);

    return ChangeNotifierProvider(
        create: ( _ ) => ProductFormProvider(productService.selectedProduct),
        child: _ProductScreenBody(productService: productService)
    );
  }
}

class _ProductScreenBody extends StatelessWidget {
  const _ProductScreenBody({
    Key? key,
    required this.productService,
  }) : super(key: key);

  final ProductsService productService;

  @override
  Widget build(BuildContext context) {
    final productForm = Provider.of<ProductFormProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                ProductImage(url_image: productService.selectedProduct.picture),
                Positioned(
                  top: 60,
                  left: 20,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  top: 60,
                  right: 20,
                  child: IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      // Pick an image.
                      //final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                      // Capture a photo.
                      final XFile? photo = await picker.pickImage(source: ImageSource.camera);
                      print(photo!.path);
                      productService.updateSelectedImage(photo.path);
                    },
                    icon: Icon(
                      Icons.camera_alt_outlined,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            _ProductForm(),
            SizedBox(
              height: 100,
            )
          ],
        ),
      ),      
      floatingActionButton: FloatingActionButton(
          child: productService.isSaving
            ? CircularProgressIndicator(color: Colors.white)
            : Icon(Icons.save_outlined),          
          onPressed: productService.isSaving
            ? null
            : () async {
            if(!productForm.isValidForm()) return;
            final String? secure_url = await productService.uploadImage();
            if(secure_url != null) productForm.cloneProduct.picture = secure_url;
            productService.saveOrCreateProduct(productForm.cloneProduct);
          })
    );
  }
}

class _ProductForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productForm = Provider.of<ProductFormProvider>(context);
    final cloneProduct = productForm.cloneProduct;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        decoration: _buildBoxDecoration(),
        child: Form(
          key: productForm.formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              SizedBox(height: 10),
              TextFormField(
                initialValue: cloneProduct.nom,
                onChanged: ( value ) => cloneProduct.nom = value,
                validator: ( value ) {
                  if(value == null || value.length < 1)
                    return 'El nom és obligatori';
                },
                decoration: InputDecorations.authInputDecoration(
                    hintText: 'Nom del producte', labelText: 'Nom:'),
              ),
              SizedBox(height: 30),
              TextFormField(
                initialValue: '${cloneProduct.price}',
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^(\d+)?\.?\d{0,2}')
                  )
                ],
                onChanged: ( value ) { 
                  double.tryParse(value) == null 
                    ? cloneProduct.price = 0 
                    : cloneProduct.price = double.parse(value);
                },
                validator: ( value ) {
                  if(value == null || value.length < 1)
                    return 'El preu és obligatori';
                },
                keyboardType: TextInputType.number,
                decoration: InputDecorations.authInputDecoration(
                    hintText: '99€', labelText: 'Preu:'),
              ),
              SizedBox(height: 30),
              SwitchListTile.adaptive(
                value: cloneProduct.available,
                title: Text('Disponible'),
                activeColor: Colors.indigo,
                onChanged: productForm.updateCloneAvailability,
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBoxDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(25),
          bottomLeft: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: Offset(0, 5),
              blurRadius: 5),
        ],
      );
}
