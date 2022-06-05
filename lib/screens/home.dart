import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schat/controllers/auth_controller.dart';
import 'package:schat/controllers/search_controller.dart';
import 'package:schat/controllers/theme_controller.dart';
import 'package:schat/models/chat_model.dart';
import 'package:schat/models/user_model.dart';
import 'package:schat/screens/chat_item_screen.dart';
import 'package:schat/screens/contacts_screen.dart';
import 'package:schat/screens/profile_screen.dart';
import 'package:schat/screens/stories_screen.dart';
import 'package:schat/screens/test_screen.dart';
import 'package:schat/services/database.dart';
import 'package:schat/widgets/drawer_widget.dart';
import 'package:schat/screens/home_chats_screen.dart';

late TextEditingController searchTextEditingController;
ThemeController themeController = Get.put(ThemeController());
String searchQuery='';
SearchController searchController = Get.put(SearchController());

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  AuthController authController = Get.put(AuthController());
  ThemeController themeController = Get.put(ThemeController());

  Database db = Database();

  List<TabItem> navBarItems=[
    TabItem(icon: CupertinoIcons.chat_bubble_text,title: 'Chats'),
    TabItem(icon: CupertinoIcons.arrow_2_circlepath_circle,title: 'Stories'),
    TabItem(icon: CupertinoIcons.add, title: 'Add'),
    TabItem(icon: CupertinoIcons.phone,title: 'Contacts'),
    TabItem(icon: CupertinoIcons.person,title: 'Profile'),
  ];

  int curNavBarItem=0;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    searchTextEditingController = TextEditingController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    searchTextEditingController.dispose();
  }

  void _startSearching(){
    ModalRoute.of(context)!
        .addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));

    searchController.isSearchEnabled.value=true;

  }

  void _stopSearching() {
    searchTextEditingController.clear();
    searchQuery='';

    searchController.isSearchEnabled.value=false;

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Obx(()=>
        searchController.isSearchEnabled.value==false? Text.rich(
                TextSpan(
                    children: [
                      TextSpan(text:'S',style: GoogleFonts.lato(
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue
                      )),
                      TextSpan(text:'Chat',style:GoogleFonts.lato(
                          fontSize: 25,
                          fontWeight: FontWeight.w500,
                          color: themeController.isDarkModeEnabled.value==false? Colors.black:Colors.white
                      )),
                    ]
                )
            )
        :Searchbar()
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: Builder(builder: (context)=>IconButton(onPressed: (){
          print('Localization');
          Scaffold.of(context).openDrawer();
        }, icon: Obx(()=>
            ImageIcon(AssetImage('assets/images/menu0.png'),color: themeController.isDarkModeEnabled.value==true?
            Colors.white:Colors.black,
              size: 30,),
        ))),

        actions: [
              Obx(()=>
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: searchController.isSearchEnabled.value==false? IconButton(onPressed: (){

                    searchController.isSearchEnabled.value=true;

                    _startSearching();

                  }, icon: Icon(CupertinoIcons.search,
                    color: themeController.isDarkModeEnabled.value==true?Colors.white:Colors.black ,)
                  ):IconButton(onPressed: (){

                    searchController.isSearchEnabled.value=false;


                  }, icon: Icon(CupertinoIcons.right_chevron,
                    color: themeController.isDarkModeEnabled.value==true?Colors.white:Colors.black ,)
                  ),
                ),
              )
        ],

      ),

      drawer: DrawerWidget(),

      bottomNavigationBar: ConvexAppBar(
        items: navBarItems,
        initialActiveIndex: 0,
        backgroundColor: Colors.black.withOpacity(0.8),
        activeColor: Colors.blue.withOpacity(0.7),
        onTap: (index)async{
          print('index is:$index');
          if(index != 2) {
            curNavBarItem = index;
            setState(() {});
          }else{
            String? s = await db.getRandomID();
            if(s != null){

              DocumentSnapshot documentSnapshot = await db.getUser(s);
              print('peerID home: ${documentSnapshot.id}');
              UserModel peer = UserModel.getUserModelFromJson(documentSnapshot.data() as Map<String,dynamic>);
              String userID = authController.firebaseUser.value!.uid;
              ChatModel chatModel = ChatModel(
                  groupId: '$userID-$s', userId: userID, peerId: s, peer: peer, messages: [],unreadCount: 0);

              Get.to(ChatItemScreen(chatData: chatModel));

            }else{
             Fluttertoast.showToast(msg: 'No Persons Available now',toastLength: Toast.LENGTH_SHORT,
                 gravity: ToastGravity.BOTTOM,backgroundColor: Colors.blue);
            }
            print('s: $s');
          }
        },
      ),

      body: curNavBarItem==0? HomeChatWidgets()
      //Center(child: Text('Home',style: TextStyle(fontSize: 30),),)
          :curNavBarItem==1? StoriesScreen()
        : curNavBarItem==3? ContactsScreen()
      : curNavBarItem==4?ProfileScreen()
          :Center(child: Text('Choosing a Random Contact to Chat With',style: GoogleFonts.abel(
        fontSize: 18
      ),),)

    );
  }
}

class Searchbar extends StatefulWidget {
  const Searchbar({Key? key}) : super(key: key);

  @override
  State<Searchbar> createState() => _SearchbarState();
}

class _SearchbarState extends State<Searchbar> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: searchTextEditingController,
      textInputAction: TextInputAction.search,
      onSubmitted: (value) {
        print('Submitted: ${value}');
        if (value.isEmpty) {
          Fluttertoast.showToast(msg: 'Sorry, The field is empty',gravity: ToastGravity.BOTTOM,backgroundColor: Colors.blue,
            toastLength: Toast.LENGTH_SHORT,
            fontSize: 16,
          );
        }  else {
          print('Showing search Results....');
        }
      },
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Search...',
        border: InputBorder.none,
        hintStyle: TextStyle(
            color: themeController.isDarkModeEnabled.value==false
                ? Colors.black
                : Colors.white),
      ),
      style: TextStyle(
        color: themeController.isDarkModeEnabled.value==false
            ? Colors.black
            : Colors.white,
        fontSize: 18.0,
      ),
      maxLines: 1,
      onChanged: (query){
        print('query: ${query}');
        },
    );
  }
}


