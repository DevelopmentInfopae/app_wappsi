import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/constant.dart';

// ignore: must_be_immutable
class CategoryList extends StatefulWidget {
  CategoryList({Key? key, required this.routeName}) : super(key: key);
  String routeName;

  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Categories',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 20.0,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: AppTextField(
                    textFieldType: TextFieldType.NAME,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: 'Search',
                      prefixIcon: Icon(
                        Icons.search,
                        color: kGreyTextColor.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                    height: 60.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(color: kGreyTextColor),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: kGreyTextColor,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20.0,
                ),
              ],
            ),
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: const [
                  // ...List.generate(
                  //   demoCategory.length,
                  //   (index) => CategoryCard(
                  //     product: demoCategory[index],
                  //     pressed: (){
                  //       SaleProducts(catName: demoCategory[index].title).launch(context);
                  //     },
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
