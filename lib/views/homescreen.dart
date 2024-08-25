import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isOnline = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green[50],
        elevation: 0,
        title: Row(
          children: [
            Text(
              "AYOOB PS",
              style:
              TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            Text(
              isOnline ? "Online" : "Offline", // Use ternary operator
              style: TextStyle(color: Colors.black45),
            ),
            Switch(
              value: isOnline,
              onChanged: (value) {
                setState(() {
                  isOnline = value;
                });
              },
              activeColor: Colors.green,
              inactiveTrackColor: Colors.red[100],
              inactiveThumbColor: Colors.red,
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 10.h,
            ),

            CarouselSlider(
              items: [
                //1st Image of Slider
                Container(
                  margin: EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    image: DecorationImage(
                      image: NetworkImage("https://picsum.photos/250?image=15"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                //2nd Image of Slider
                Container(
                  margin: EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    image: DecorationImage(
                      image: NetworkImage("https://picsum.photos/250?image=19"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                //3rd Image of Slider
                Container(
                  margin: EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    image: DecorationImage(
                      image: NetworkImage("https://picsum.photos/250?image=16"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                //4th Image of Slider
                Container(
                  margin: EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    image: DecorationImage(
                      image: NetworkImage("https://picsum.photos/250?image=17"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                //5th Image of Slider
                Container(
                  margin: EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    image: DecorationImage(
                      image: NetworkImage("https://picsum.photos/250?image=18"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],

              //Slider Container properties
              options: CarouselOptions(
                height: 180.0,
                enlargeCenterPage: true,
                autoPlay: true,
                aspectRatio: 16 / 9,
                autoPlayCurve: Curves.slowMiddle,
                scrollDirection: Axis.horizontal,
                enableInfiniteScroll: true,
                autoPlayAnimationDuration: Duration(seconds: 3),
                viewportFraction: 0.8,
              ),
            ),

            SizedBox(
              height: 30.h,
            ),

            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                // primary: Colors.white,
                // onPrimary: Colors.green,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.green),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                "WAITING FOR NEW TRIP",
                style: TextStyle(
                  color: Colors.green,
                ),
              ),
            ),
            SizedBox(height: 30),
            IconButton(
                onPressed: () {
                  Get.offNamedUntil(
                      '/newtripalert', (Route<dynamic> route) => route.isFirst);
                },
                icon: Icon(
                  Icons.refresh,
                  color: Colors.green,
                  size: 40,
                )),

            SizedBox(
              height: 180.h,
            ),

            Lottie.asset('assets/lotties/lottie1.json'),
            //Lottie.asset('assets/lotties/lottie2.json'),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(

        backgroundColor: Colors.green[50],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.black54,
        items: [
          BottomNavigationBarItem(
            icon: IconButton(
              icon: Icon(Icons.home),
              onPressed: () => Get.toNamed('/homescreen'),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () => Get.toNamed('/triphistory'),
            ),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => Get.toNamed('/settings'),
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
