// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:nearme/working_services.dart';
//
// class Category {
//   final String title;
//   final String imageURL;
//
//   Category({required this.title, required this.imageURL});
//
//   factory Category.fromFirestore(DocumentSnapshot doc) {
//     return Category(
//       title: doc['title'],
//       imageURL: doc['imageURL'],
//     );
//   }
// }
//
// class WorkingCategories extends StatefulWidget {
//   const WorkingCategories({Key? key}) : super(key: key);
//
//   @override
//   State<WorkingCategories> createState() => _WorkingCategoriesState();
// }
//
// class _WorkingCategoriesState extends State<WorkingCategories> {
//   List<Category> categories = [];
//   List<Category> filteredCategories = [];
//   final TextEditingController _searchController = TextEditingController();
//   final FocusNode _searchFocusNode = FocusNode();
//   bool isTextFieldVisible = false;
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchCategories();
//   }
//
//   Future<void> fetchCategories() async {
//     try {
//       final snapshot =
//           await FirebaseFirestore.instance.collection('workingImages').get();
//       setState(() {
//         categories =
//             snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();
//         filteredCategories = categories.toList();
//         isLoading = false;
//       });
//     } catch (e) {
//       print('Error fetching categories: $e');
//       setState(() => isLoading = false);
//     }
//   }
//
//   void filterCategories(String query) {
//     setState(() {
//       filteredCategories = query.isNotEmpty
//           ? categories
//               .where((category) =>
//                   category.title.toLowerCase().contains(query.toLowerCase()))
//               .toList()
//           : categories.toList();
//     });
//   }
//
//   void navigateToCategoryDetails(Category category) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) =>
//             WorkingServices.WorkingServicesShow(category: category),
//       ),
//     );
//   }
//
//   void toggleTextFieldVisibility() {
//     setState(() {
//       isTextFieldVisible = !isTextFieldVisible;
//       if (isTextFieldVisible) {
//         _searchFocusNode.requestFocus();
//       } else {
//         _searchFocusNode.unfocus();
//         _searchController.clear();
//         filterCategories('');
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     _searchFocusNode.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//
//       appBar: AppBar(
//         title: isTextFieldVisible
//             ? TextField(
//           focusNode: _searchFocusNode,
//           controller: _searchController,
//           onChanged: filterCategories,
//           decoration: InputDecoration(
//             hintText: 'Search Services',
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(30),
//               borderSide: BorderSide.none,
//             ),
//             filled: true,
//             fillColor: Colors.white.withOpacity(0.1),
//           ),
//         )
//             : const Text('Services'),
//         actions: [
//           IconButton(
//             icon: Icon(isTextFieldVisible ? Icons.close : Icons.search),
//             onPressed: toggleTextFieldVisibility,
//           ),
//         ],
//       ),
//
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           :
//
//       GridView.builder(
//         padding: const EdgeInsets.all(8.0),
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           crossAxisSpacing: 10,
//           mainAxisSpacing: 10,
//         ),
//         itemCount: filteredCategories.length,
//         itemBuilder: (context, index) {
//           Category category = filteredCategories[index];
//           return GestureDetector(
//             onTap: () => navigateToCategoryDetails(category),
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(15),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.4),
//                     spreadRadius: 2,
//                     blurRadius: 6,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   ClipRRect(
//                     borderRadius: const BorderRadius.only(
//                       topLeft: Radius.circular(15),
//                       topRight: Radius.circular(15),
//                     ),
//                     child: Image.network(
//                       category.imageURL,
//                       width: double.infinity,
//                       height: 120,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Text(
//                       category.title,
//                       style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
// class CategoryCard extends StatelessWidget {
//   final Category category;
//   final VoidCallback onTap;
//
//   const CategoryCard({Key? key, required this.category, required this.onTap})
//       : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Card(
//         elevation: 4,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(15),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             ClipRRect(
//               borderRadius:
//                   const BorderRadius.vertical(top: Radius.circular(15)),
//               child: Image.network(
//                 category.imageURL,
//                 height: 125,
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) =>
//                     const Icon(Icons.broken_image, size: 50),
//                 loadingBuilder: (context, child, progress) {
//                   return progress == null
//                       ? child
//                       : const Center(child: CircularProgressIndicator());
//                 },
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                 category.title,
//                 textAlign: TextAlign.center,
//                 style:
//                     const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nearme/working_services.dart';

class Category {
  final String title;
  final String imageURL;

  Category({required this.title, required this.imageURL});

  factory Category.fromFirestore(DocumentSnapshot doc) {
    return Category(
      title: doc['title'],
      imageURL: doc['imageURL'],
    );
  }
}

class WorkingCategories extends StatefulWidget {
  const WorkingCategories({Key? key}) : super(key: key);

  @override
  State<WorkingCategories> createState() => _WorkingCategoriesState();
}

class _WorkingCategoriesState extends State<WorkingCategories> {
  List<Category> categories = [];
  List<Category> filteredCategories = [];
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool isTextFieldVisible = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('workingImages').get();
      setState(() {
        categories =
            snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();
        filteredCategories = List.from(categories);
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching categories: $e');
      setState(() => isLoading = false);
    }
  }

  void filterCategories(String query) {
    setState(() {
      filteredCategories = query.isNotEmpty
          ? categories
              .where((category) =>
                  category.title.toLowerCase().contains(query.toLowerCase()))
              .toList()
          : List.from(categories);
    });
  }

  void toggleTextFieldVisibility() {
    setState(() {
      isTextFieldVisible = !isTextFieldVisible;
      if (!isTextFieldVisible) {
        _searchFocusNode.unfocus();
        _searchController.clear();
        filterCategories('');
      } else {
        _searchFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isTextFieldVisible
            ? TextField(
                focusNode: _searchFocusNode,
                controller: _searchController,
                onChanged: filterCategories,
                decoration: InputDecoration(
                  hintText: 'Search Services',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                ),
              )
            : const Text('Services'),
        actions: [
          IconButton(
            icon: Icon(isTextFieldVisible ? Icons.close : Icons.search),
            onPressed: toggleTextFieldVisibility,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: filteredCategories.length,
              itemBuilder: (context, index) {
                return CategoryCard(
                  category: filteredCategories[index],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkingServices.WorkingServicesShow(
                        category: filteredCategories[index],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const CategoryCard({Key? key, required this.category, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(
                category.imageURL,
                height: 125,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 50),
                loadingBuilder: (context, child, progress) {
                  return progress == null
                      ? child
                      : const Center(child: CircularProgressIndicator());
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                category.title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
