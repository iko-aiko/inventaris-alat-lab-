
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'detail_item_page.dart';

// WARNA
const Color creamColor = Color(0xFFF5EBDD);
const Color maroonColor = Color(0xFF8D2222);
const Color darkMaroonColor = Color(0xFF5F0F0F);

// GAMBAR KECIL
Widget buildItemImage(String image) {
  final path = image.trim();

  if (path.isEmpty) {
    return Container(
      width: 60,
      height: 60,
      color: creamColor,
      child: const Icon(Icons.science, color: maroonColor),
    );
  }

  if (path.startsWith('http')) {
    return Image.network(
      path,
      width: 60,
      height: 60,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.science),
    );
  }

  return Image.asset(
    path,
    width: 60,
    height: 60,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) =>
        const Icon(Icons.science),
  );
}

// GAMBAR BESAR UNTUK DAFTAR ALAT
Widget buildLargeItemImage(String image) {
  final path = image.trim();

  if (path.isEmpty) {
    return const Center(
      child: Icon(
        Icons.science,
        size: 80,
        color: maroonColor,
      ),
    );
  }

  if (path.startsWith('http')) {
    return Image.network(
      path,
      width: double.infinity,
      height: 230,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.broken_image, size: 60),
    );
  }

  return Image.asset(
    path,
    width: double.infinity,
    height: 230,
    fit: BoxFit.contain,
    errorBuilder: (_, __, ___) =>
        const Icon(Icons.broken_image, size: 60),
  );
}

// IKON KATEGORI
IconData getCategoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'mikroskop':
    case 'optik':
      return Icons.biotech;
    case 'kimia':
      return Icons.science;
    case 'komputer':
      return Icons.computer;
    case 'elektronik':
      return Icons.electrical_services;
    default:
      return Icons.category;
  }
}

// HALAMAN HOME
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchController =
      TextEditingController();

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  final List<String> banners = [
    'assets/images/banner1.jpg',
    'assets/images/banner2.jpg',
    'assets/images/banner3.jpg',
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // BANNER
  Widget buildBanner() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 275,
        autoPlay: true,
        enlargeCenterPage: false,
        viewportFraction: 0.96,
        autoPlayInterval: const Duration(seconds: 3),
      ),
      items: banners.map((image) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(
              image,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: creamColor),
            ),
          ),
        );
      }).toList(),
    );
  }

  // TOMBOL KATEGORI
  Widget buildCategoryButton(
    String category,
    int total,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                CategoryItemsPage(category: category),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              category == 'Semua Data'
                  ? Icons.inventory_2
                  : getCategoryIcon(category),
              color: maroonColor,
              size: 28,
            ),
            const SizedBox(height: 5),
            Text(
              category,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: darkMaroonColor,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '$total alat',
              style: const TextStyle(
                fontSize: 9,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // HASIL PENCARIAN
  Widget buildSearchItem(QueryDocumentSnapshot doc) {
    final item = doc.data() as Map<String, dynamic>;

    return ListTile(
      leading: buildItemImage(
        (item['image'] ?? '').toString(),
      ),
      title: Text(
        (item['item_name'] ?? '').toString(),
      ),
      subtitle: Text(
        '${item['category'] ?? ''} • ${item['status'] ?? ''}',
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailItemPage(
              itemId: doc.id,
              itemName:
                  (item['item_name'] ?? '').toString(),
              category:
                  (item['category'] ?? '').toString(),
              code: (item['code'] ?? '').toString(),
              status: (item['status'] ?? '').toString(),
              image: (item['image'] ?? '').toString(),
              spesification:
                  (item['spesification'] ?? '').toString(),
            ),
          ),
        );
      },
    );
  }

  // KARTU ALAT HORIZONTAL
  Widget buildHorizontalItem(QueryDocumentSnapshot doc) {
    final item = doc.data() as Map<String, dynamic>;

    final image = (item['image'] ?? '').toString().trim();
    final name = (item['item_name'] ?? '').toString();
    final category = (item['category'] ?? '').toString();
    final status = (item['status'] ?? '').toString();

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailItemPage(
              itemId: doc.id,
              itemName: name,
              category: category,
              code: (item['code'] ?? '').toString(),
              status: status,
              image: image,
              spesification:
                  (item['spesification'] ?? '').toString(),
            ),
          ),
        );
      },
      child: Container(
        width: 165,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              child: image.isEmpty
                  ? Container(
                      height: 115,
                      width: 165,
                      color: creamColor,
                      child: const Icon(
                        Icons.science,
                        size: 45,
                        color: maroonColor,
                      ),
                    )
                  : image.startsWith('http')
                      ? Image.network(
                          image,
                          height: 115,
                          width: 165,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image),
                        )
                      : Image.asset(
                          image,
                          height: 115,
                          width: 165,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image),
                        ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: darkMaroonColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: status == 'Available'
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamColor,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: firestore.collection('items').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'Terjadi kesalahan mengambil data',
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final documents = snapshot.data!.docs;

            // KATEGORI DARI FIRESTORE
            final categories = documents
                .map((doc) {
                  final data =
                      doc.data() as Map<String, dynamic>;
                  return (data['category'] ?? '').toString();
                })
                .where((category) => category.isNotEmpty)
                .toSet()
                .toList();

            // PENCARIAN
            final searchText =
                searchController.text.toLowerCase();

            final searchResults = documents.where((doc) {
              final data =
                  doc.data() as Map<String, dynamic>;

              final name =
                  (data['item_name'] ?? '')
                      .toString()
                      .toLowerCase();

              final category =
                  (data['category'] ?? '')
                      .toString()
                      .toLowerCase();

              final code =
                  (data['code'] ?? '')
                      .toString()
                      .toLowerCase();

              return name.contains(searchText) ||
                  category.contains(searchText) ||
                  code.contains(searchText);
            }).toList();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Lab Inventory',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: darkMaroonColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // BANNER
                  buildBanner(),

                  const SizedBox(height: 20),

                  // SEARCH
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Cari alat laboratorium...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: maroonColor,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // HASIL PENCARIAN
                  if (searchText.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      child: Text(
                        'Hasil Pencarian',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: darkMaroonColor,
                        ),
                      ),
                    ),

                    ...searchResults.map(buildSearchItem),

                    if (searchResults.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Text('Alat tidak ditemukan'),
                        ),
                      ),
                  ] else ...[
                    // KATEGORI
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      child: Text(
                        'Kategori Alat',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: darkMaroonColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),
                        itemCount: categories.length + 1,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.15,
                        ),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return buildCategoryButton(
                              'Semua Data',
                              documents.length,
                            );
                          }

                          final category =
                              categories[index - 1];

                          final total = documents.where((doc) {
                            final data = doc.data()
                                as Map<String, dynamic>;

                            return (data['category'] ?? '')
                                    .toString() ==
                                category;
                          }).length;

                          return buildCategoryButton(
                            category,
                            total,
                          );
                        },
                      ),
                    ),
                  ],

                  // DAFTAR ALAT HORIZONTAL
                  if (searchText.isEmpty) ...[
                    const SizedBox(height: 25),

                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      child: Text(
                        'Daftar Alat Laboratorium',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: darkMaroonColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        itemCount: documents.length,
                        itemBuilder: (context, index) {
                          return buildHorizontalItem(
                            documents[index],
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 25),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// HALAMAN DAFTAR ALAT BERDASARKAN KATEGORI
class CategoryItemsPage extends StatelessWidget {
  final String category;

  const CategoryItemsPage({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamColor,
      appBar: AppBar(
        backgroundColor: maroonColor,
        foregroundColor: Colors.white,
        title: Text(category),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('items')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Gagal mengambil data alat'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // SEMUA DATA ATAU KATEGORI TERTENTU
          final items = snapshot.data!.docs.where((doc) {
            if (category == 'Semua Data') {
              return true;
            }

            final data =
                doc.data() as Map<String, dynamic>;

            return (data['category'] ?? '').toString() ==
                category;
          }).toList();

          if (items.isEmpty) {
            return const Center(
              child: Text('Belum ada alat di kategori ini'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final doc = items[index];

              final item =
                  doc.data() as Map<String, dynamic>;

              final itemName =
                  (item['item_name'] ?? '').toString();

              final itemCategory =
                  (item['category'] ?? '').toString();

              final code =
                  (item['code'] ?? '').toString();

              final status =
                  (item['status'] ?? '').toString();

              final image =
                  (item['image'] ?? '').toString();

              final specification =
                  (item['spesification'] ?? '').toString();

              final isAvailable =
                  status == 'Available';

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // GAMBAR BESAR
                    Container(
                      width: double.infinity,
                      height: 240,
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF9F4EB),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(18),
                        ),
                      ),
                      child: buildLargeItemImage(image),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            itemName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: darkMaroonColor,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'Kategori: $itemCategory',
                            style: const TextStyle(
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            'Kode alat: $code',
                            style: const TextStyle(
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: isAvailable
                                  ? Colors.green.withOpacity(0.12)
                                  : Colors.red.withOpacity(0.12),
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: isAvailable
                                    ? Colors.green.shade800
                                    : Colors.red.shade800,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          // TOMBOL DETAIL
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: maroonColor,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        DetailItemPage(
                                      itemId: doc.id,
                                      itemName: itemName,
                                      category: itemCategory,
                                      code: code,
                                      status: status,
                                      image: image,
                                      spesification:
                                          specification,
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                'Lihat Detail',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
