import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:ridewave_cab_rider/models/banner_image_model.dart';

class BannerImageController extends GetxController{
  var bannerimages=<BannerImageModel>[].obs;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchBannerImage();
  }
  void fetchBannerImage()async{
    final snapshot=await FirebaseFirestore.instance
        .collection('banner_image')
        .orderBy('upload_at',descending: true)
        .get();

    final List<BannerImageModel>images=snapshot.docs
        .map((doc) =>BannerImageModel.fromFirestore(doc.id,doc.data()))
        .toList();

    bannerimages.value=images;
  }
}