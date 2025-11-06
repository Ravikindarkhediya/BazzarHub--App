// // test/features/product_detail/controllers/product_controller_test.dart
//
// import 'package:bazzarhub/presentation/modules/product/controllers/product_controller.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/mockito.dart';
//
// import '../../home/model/proiduct_model.dart';
//
// void main() {
//   group('ProductController Tests', () {
//     late ProductController controller;
//     late ProductModel mockProduct;
//
//     setUp(() {
//       mockProduct = ProductModel(
//         productId: 1,
//         productName: 'Test Product',
//         price: 1000,
//         images: ['image1.jpg', 'image2.jpg'], ownerName: 'prodwnerContact: '', addedDate: '', detail: '', description: '', address: '', likes: null, categoryId: null,
//         // ... other fields
//       );
//       controller = ProductController(product: mockProduct);
//     });
//
//     tearDown(() {
//       controller.dispose();
//     });
//
//     test('Should initialize with correct product', () {
//       expect(controller.product, equals(mockProduct));
//       expect(controller.currentImageIndex, equals(0));
//       expect(controller.isFavorite, equals(false));
//     });
//
//     test('Should update image index correctly', () {
//       controller.updateImageIndex(1);
//       expect(controller.currentImageIndex, equals(1));
//     });
//
//     test('Should not update index out of bounds', () {
//       controller.updateImageIndex(999);
//       expect(controller.currentImageIndex, equals(0));
//     });
//
//     test('Should toggle description state', () {
//       expect(controller.isDescriptionExpanded, equals(false));
//       controller.toggleDescription();
//       expect(controller.isDescriptionExpanded, equals(true));
//     });
//
//     test('Should toggle favorite optimistically', () async {
//       final initialState = controller.isFavorite;
//       await controller.toggleFavorite(mockContext);
//       expect(controller.isFavorite, equals(!initialState));
//     });
//
//     test('Should debounce favorite toggles', () async {
//       await controller.toggleFavorite(mockContext);
//       await controller.toggleFavorite(mockContext); // Should be ignored
//       await Future.delayed(Duration(milliseconds: 100));
//       // Verify only one API call was made
//     });
//   });
// }