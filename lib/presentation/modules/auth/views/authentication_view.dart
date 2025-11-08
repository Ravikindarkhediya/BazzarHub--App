// import 'dart:io';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
//
// import '../../../../app/data/constants/app_colors.dart';
//
// class AuthenticationView extends StatefulWidget {
//   const AuthenticationView({super.key});
//
//   @override
//   State<AuthenticationView> createState() => _AuthenticationViewState();
// }
//
// class _AuthenticationViewState extends State<AuthenticationView>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   File? _selectedImage;
//   final ImagePicker _picker = ImagePicker();
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _tabController.addListener(() {
//       setState(() {});
//     });
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _pickImageFromGallery() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _selectedImage = File(pickedFile.path);
//       });
//     }
//   }
//
//   void _showActionSheet(BuildContext context) {
//     showCupertinoModalPopup(
//       context: context,
//       builder: (context) => CupertinoActionSheet(
//         title: const Text('Choose an option'),
//         actions: <CupertinoActionSheetAction>[
//           CupertinoActionSheetAction(
//             child: Text('Gallery', style: boldTextStyle(18, AppColors.silver)),
//             onPressed: () async {
//               await _pickImageFromGallery();
//               Navigator.pop(context);
//             },
//           ),
//           CupertinoActionSheetAction(
//             child: Text('Camera', style: boldTextStyle(18, AppColors.white)),
//             onPressed: () {
//               // TODO: Implement camera functionality
//               Navigator.pop(context);
//             },
//           ),
//         ],
//         cancelButton: CupertinoActionSheetAction(
//           isDestructiveAction: true,
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           child: Text('Cancel', style: boldTextStyle(18, AppColors.red)),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 10),
//         child: Column(
//           children: [
//             const SizedBox(height: 50),
//             if (_tabController.index == 0)
//               _buildProfileImage()
//             else
//               _buildWelcomeSection(),
//             const SizedBox(height: 20),
//             _buildTabBar(),
//             const SizedBox(height: 20),
//             Expanded(
//               child: TabBarView(
//                 controller: _tabController,
//                 children: const [
//                   RegisterTab(),
//                   SocialTab(),
//                   LoginTab(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: _buildBottomNavigationBar(),
//     );
//   }
//
//   Widget _buildProfileImage() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Align(
//           alignment: Alignment.center,
//           child: Container(
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(width: 2, color: AppColors.red),
//             ),
//             padding: const EdgeInsets.all(4),
//             child: Container(
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(width: 2, color: AppColors.lightYellow),
//               ),
//               child: CircleAvatar(
//                 radius: 50,
//                 backgroundColor: AppColors.background,
//                 backgroundImage:
//                 _selectedImage != null ? FileImage(_selectedImage!) : null,
//                 child: _selectedImage == null
//                     ? const Icon(Icons.person, color: AppColors.silver, size: 50)
//                     : null,
//               ),
//             ),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.only(top: 70.0),
//           child: GestureDetector(
//             onTap: () => _showActionSheet(context),
//             child: Container(
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(width: 1, color: AppColors.red),
//               ),
//               child: const Icon(Icons.add, color: AppColors.red),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildWelcomeSection() {
//     return Column(
//       children: [
//         Assets.icons.ic7nights.svg(height: 90),
//         const SizedBox(height: 30),
//         Text('Welcome to 7Nights', style: boldTextStyle(25, AppColors.silver)),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 40.0),
//           child: Text(
//             'Sign up or Login to enjoy our best offers and features',
//             style: regularTextStyle(14, AppColors.silver),
//             textAlign: TextAlign.center,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildTabBar() {
//     return ClipRRect(
//       borderRadius: const BorderRadius.all(Radius.circular(10)),
//       child: Container(
//         height: 40,
//         decoration: const BoxDecoration(
//           borderRadius: BorderRadius.all(Radius.circular(20)),
//           color: AppColors.lightBlack,
//         ),
//         child: TabBar(
//           controller: _tabController,
//           indicatorSize: TabBarIndicatorSize.tab,
//           dividerColor: Colors.transparent,
//           indicator: const BoxDecoration(
//             color: AppColors.lightGray,
//             borderRadius: BorderRadius.all(Radius.circular(20)),
//           ),
//           labelColor: AppColors.silver,
//           unselectedLabelColor: AppColors.silver,
//           tabs: [
//             _tabItem(title: 'Register'),
//             _tabItem(title: 'Social'),
//             _tabItem(title: 'Login'),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBottomNavigationBar() {
//     return BottomAppBar(
//       color: AppColors.background,
//       padding: EdgeInsets.zero,
//       height: 42,
//       child: Align(
//         alignment: Alignment.center,
//         child: Text.rich(
//           TextSpan(
//             text: 'Refer to our ',
//             style: regularTextStyle(13, AppColors.lightGray),
//             children: <TextSpan>[
//               TextSpan(
//                 text: 'Privacy Policy ',
//                 style: mediumTextStyle(12, AppColors.red).copyWith(
//                   decoration: TextDecoration.underline,
//                   decorationColor: AppColors.red,
//                 ),
//                 recognizer: TapGestureRecognizer()
//                   ..onTap = () async {
//                     const url = 'https://7nightsuae.com/privacy-policy';
//                     if (await canLaunch(url)) {
//                       await launch(url);
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                             content: Text('Could not launch Privacy Policy')),
//                       );
//                     }
//                   },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   static Widget _tabItem({required String title}) {
//     return Tab(
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             title,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     );
//   }
// }
