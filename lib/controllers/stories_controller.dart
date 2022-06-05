import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:schat/controllers/auth_controller.dart';
import 'package:schat/models/story_model.dart';

class StoriesController extends GetxController{

  var storiesList = Rx<List<StoryModel>>([]);
  AuthController authController = Get.put(AuthController());

  Future<void> getMyStatuses()async{
    List<StoryModel> stories=[];
    QuerySnapshot querySnapshot = await  FirebaseFirestore.instance.collection('Stories')
        .doc(authController.firebaseUser.value!.uid).collection('UserStories').get();

    querySnapshot.docs.forEach((element) {
        stories.add(StoryModel.fromJson(element.data() as Map<String,dynamic>));
    });

    storiesList.value = stories;

  }

  Future<void> deleteStatus(int timeStamp,String sender)async{
    await FirebaseFirestore.instance.collection("Stories").doc(sender).collection('UserStories')
        .doc(timeStamp.toString()).delete();

  }

}