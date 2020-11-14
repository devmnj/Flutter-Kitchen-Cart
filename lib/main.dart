import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(new GetMaterialApp(
    home: new MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
        seconds: 5,
        navigateAfterSeconds: new LiveCart(),
        title: new Text(
          'Welcome In SplashScreen',
          style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
        image:
            Image.asset('assets/images/brooke-lark-08bOYnH_r_E-unsplash.jpg'),
        backgroundColor: Colors.white,
        styleTextUnderTheLoader: new TextStyle(),
        photoSize: 200.0,
        routeName: '/',
        onClick: () => print("Flutter Egypt"),
        loaderColor: Colors.red);
  }
}

class LiveCart extends StatefulWidget {
  @override
  _LiveCartState createState() => new _LiveCartState();
}

enum Pref { Urgent, LazyBox, Today }

class Kart {
  String item;
  Pref pref;
  double qty;
  bool status;
  DateTime kDate;
  String chefNote;

  Map<String, dynamic> toMap() {
    return {
      'item': item,
      'preference': pref.toString(),
      'qty': qty,
      'status': status,
      'kdate': kDate,
      'chefNote': chefNote
    };
  }

  Kart(this.item, this.qty, this.pref, this.status, this.kDate, this.chefNote);
}

listItem(DocumentSnapshot documentSnapshot, [Color headCol]) {
  bool isDone = false;
  bool today, flaGed, lazy;
  today = false;
  flaGed = false;
  lazy = false;
  switch (documentSnapshot['preference']) {
    case "pref.Urgent":
      flaGed = true;
      break;
    case "pref.Today":
      today = true;
      break;
    case "pref.LazyBox":
      lazy = true;
      break;
  }

  if (documentSnapshot['status'] == true) isDone = true;
  return Builder(
    builder: (context) {
      return GestureDetector(
        onTap: () {},
        child: Card(

          margin: EdgeInsets.symmetric(vertical: 1.2, horizontal: 10),

          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    color: headCol ?? Colors.green),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      today
                          ? Icon(Icons.date_range)
                          : flaGed
                              ? Icon(Icons.flag)
                              : Icon(Icons.hourglass_empty),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        documentSnapshot['item'],
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      isDone
                          ? Icon(
                              Icons.check_box,
                              color: Colors.white,
                            )
                          : Icon(
                              Icons.check_box_outline_blank,
                              color: Colors.white,
                            ),
                      Text(
                        documentSnapshot['qty'].toString(),
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    documentSnapshot['chefNote'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )
                ],
              )
            ],
          ),
        ),
      );
    },
  );
}

class _LiveCartState extends State<LiveCart> {
  final style1 = TextStyle(fontSize: 22, color: Colors.white);
  final diskey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Your Kart'),
          actions: [
            IconButton(
              splashColor: Colors.deepPurple,
              icon: Icon(
                Icons.check_box,
                size: 35,
                color: CupertinoColors.white,
              ),
              onPressed: () {},
            ),
            Icon(
              Icons.check_box_outline_blank,
              size: 35,
            ),
            Icon(
              Icons.all_out,
              size: 35,
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          backgroundColor: Colors.deepOrange,
        ),
        bottomNavigationBar: _bottomNav(context, actIndex: 0),
        body: Container(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('karts').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Text('loading ...');
              return ListView.builder(
                itemExtent: 80,
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                      onDismissed: (direction) {
                        if (direction == DismissDirection.startToEnd) {
                          FirebaseFirestore.instance
                              .runTransaction((transaction) async {
                            DocumentSnapshot fresh = await transaction
                                .get(snapshot.data.documents[index].reference);
                            transaction
                                .update(fresh.reference, {'status': true});
                            Get.snackbar('Info', 'Updated');
                          });
                        } else if (direction == DismissDirection.endToStart) {
                          FirebaseFirestore.instance
                              .runTransaction((transaction) async {
                            DocumentSnapshot fresh = await transaction
                                .get(snapshot.data.documents[index].reference);
                            transaction.delete(fresh.reference);
                            Get.snackbar('Info', 'Item removed');
                          });
                        }
                      },
                      key: UniqueKey(),
                      secondaryBackground: Container(
                        color: Colors.redAccent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Remove',
                              style:
                                  TextStyle(fontSize: 22, color: Colors.white),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Icon(
                                Icons.remove_shopping_cart,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ),
                      background: Container(
                          color: Colors.green,
                          child: Row(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Icon(
                                  Icons.check,
                                  size: 40,
                                ),
                              ),
                              Text(
                                'Finish',
                                style: TextStyle(
                                    fontSize: 22, color: Colors.white),
                              )
                            ],
                          )),
                      child: listItem(snapshot.data.documents[index]));
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

_bottomNav(BuildContext context, {int actIndex = 2}) {
  return ConvexAppBar(
    items: [
      TabItem(icon: Icons.home, title: 'Home'),
      TabItem(icon: Icons.map, title: 'History'),
      TabItem(icon: Icons.add, title: 'Add'),
      TabItem(icon: Icons.message, title: 'Today'),
      TabItem(icon: Icons.people, title: 'Finished'),
    ],
    initialActiveIndex: actIndex, //optional, default as 0
    onTap: (int i) {
      switch (i) {
        case 2:
          Get.to(NewKart());
          // Navigator.push(context,
          //     new MaterialPageRoute(builder: (context) => (AfterSplash())));
          break;
        case 3:
          Get.to(KartToday());
          break;
          case 4:
          Get.to(KartFinished());
          break;

        default:
          {
            Get.to(LiveCart());
          }
      }
    },
  );
}

class NewKart extends StatelessWidget {
  final itemController = TextEditingController();
  final noteController = TextEditingController();

  Pref pref = Pref.Today;

  final controller = Get.put(Controller());

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
            title: new Text("Welcome In SplashScreen Package"),
            automaticallyImplyLeading: false),
        bottomNavigationBar: _bottomNav(context),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text('Your Kart'),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.yellow),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          style: TextStyle(fontSize: 18),
                          controller: itemController,
                          decoration: InputDecoration(
                              labelText: 'Cart Item',
                              hintText: 'Vegetables 1KG'),
                        ),
                      ),
                      Row(
                        children: [
                          Text(''),
                          Column(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.add,
                                  size: 50,
                                  color: Colors.deepOrangeAccent,
                                ),
                                onPressed: () {
                                  controller.qty++;
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.remove,
                                  size: 50,
                                  color: Colors.deepOrangeAccent,
                                ),
                                onPressed: () {
                                  controller.qty--;
                                  controller.qty.value = 0;
                                },
                              ),
                            ],
                          ),
                          Spacer(
                            flex: 1,
                          ),
                          Flexible(
                            child: Obx(() => Text(
                                  '${controller.qty}',
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold),
                                )),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: noteController,
                          decoration: InputDecoration(
                              labelText: 'Note', hintText: 'Vegetables 1KG'),
                        ),
                      ),
                      ToggleSwitch(
                        minWidth: 190,
                        initialLabelIndex: 0,
                        activeBgColor: Colors.deepOrange,
                        activeFgColor: Colors.black,
                        inactiveBgColor: Colors.green,
                        inactiveFgColor: Colors.white,
                        labels: ['Urgent', 'Today', 'Lazy Box'],
                        fontSize: 18,

                        // icons: [FontAwesomeIcons.check, FontAwesomeIcons.times],
                        onToggle: (index) {
                          switch (index) {
                            case 0:
                              pref = Pref.Urgent;
                              break;
                            case 1:
                              pref = Pref.Today;
                              break;
                            case 2:
                              pref = Pref.LazyBox;
                              break;
                          }
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 50,
                            color: Colors.blue,
                          ),
                          Obx(
                            () => Text(
                              '${controller.tot}',
                              style: TextStyle(fontSize: 25),
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              //Save to Online cart - FireStore
                              try {
                                if (controller.qty > 0 &&
                                    itemController.text.isEmpty == false) {
                                  Kart newKart = new Kart(
                                      itemController.text,
                                      double.parse(
                                          controller.qty.value.toString()),
                                      pref,
                                      false,
                                      DateTime.now(),
                                      noteController.text);
                                  Map<String, dynamic> newItem =
                                      newKart.toMap();
                                  final fireKart = FirebaseFirestore.instance
                                      .collection('karts');
                                  // await fireKart.doc().set({
                                  //   'item': itemController.text,
                                  //   'qty': controller.qty.value,
                                  //   'preferance': pref.toString(),
                                  //   'status': 'false'
                                  // });
                                  await fireKart.doc().set(newItem);
                                  Get.snackbar('Kart', 'Item added');
                                  controller.qty.value = 0;
                                  itemController.text = "";
                                  noteController.text = "";
                                } else {
                                  Get.snackbar(
                                      'Error', 'Please fill all the fields');
                                }
                              } on Exception catch (e) {
                                print(e);
                              }
                            },
                            icon: Icon(
                              Icons.add_shopping_cart,
                              size: 50,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.clear_all,
                              size: 50,
                            ),
                            onPressed: () {
                              try {
                                controller.qty.value = 0;
                                itemController.text = "";
                                noteController.text = "";
                              } on Exception catch (e) {
                                print(e);
                              }
                            },
                          )
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

class Controller extends GetxController {
  var qty = 0.obs;
  var tot = 0.obs;
// void reFresh()=>update();
}

class KartToday extends StatefulWidget {
  @override
  _KartTodayState createState() => new _KartTodayState();
}

class _KartTodayState extends State<KartToday> {
  final style1 = TextStyle(fontSize: 22, color: Colors.white);
  final diskey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          shadowColor: Colors.blueAccent,
          title: Text('Todays Kart'),
          actions: [],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          backgroundColor: Colors.deepOrange,
        ),
        bottomNavigationBar: _bottomNav(context, actIndex: 0),
        body: Container(
          child: FutureBuilder(
            future: FirebaseFirestore.instance.collection('karts').where('preference',isEqualTo: 'Pref.Today').get(),
            builder: (context, snapshot) {
              return snapshot.hasData
                  ?   ListView.builder(
                      itemExtent: 80,
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (context, index) {
                        return   Dismissible(
                                onDismissed: (direction) {
                                  try {
                                    if (direction ==
                                        DismissDirection.startToEnd) {
                                      FirebaseFirestore.instance
                                          .runTransaction((transaction) async {
                                        DocumentSnapshot fresh =
                                            await transaction.get(snapshot
                                                .data.documents[index].reference);
                                        transaction.update(
                                            fresh.reference, {'status': true});
                                        Get.snackbar('Info', 'Updated');
                                      });
                                    } else if (direction ==
                                        DismissDirection.endToStart) {
                                      FirebaseFirestore.instance
                                          .runTransaction((transaction) async {
                                        DocumentSnapshot fresh =
                                            await transaction.get(snapshot
                                                .data.documents[index].reference);
                                        transaction.delete(fresh.reference);
                                        Get.snackbar('Info', 'Item removed');
                                      });
                                    }
                                  } on Exception catch (e) {
                                    // TODO
                                  }
                                },
                                key: UniqueKey(),
                                secondaryBackground: Container(
                                  color: Colors.redAccent,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Remove',
                                        style: TextStyle(
                                            fontSize: 22, color: Colors.white),
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Icon(
                                          Icons.remove_shopping_cart,
                                          size: 40,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                background: Container(
                                    color: Colors.green,
                                    child: Row(
                                      children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Icon(
                                            Icons.check,
                                            size: 40,
                                          ),
                                        ),
                                        Text(
                                          'Finish',
                                          style: TextStyle(
                                              fontSize: 22,
                                              color: Colors.white),
                                        )
                                      ],
                                    )),
                                child: listItem(snapshot.data.documents[index],
                                    Colors.blue));

                      },
                    )
                  : LinearProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}

class KartFinished extends StatefulWidget {
  @override
  _KartFinished createState() => new _KartFinished();
}

class _KartFinished extends State<KartFinished> {
  final style1 = TextStyle(fontSize: 22, color: Colors.white);
  final diskey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          shadowColor: Colors.blueAccent,
          title: Text('Finished Kart'),
          actions: [],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          backgroundColor: Colors.deepOrange,
        ),
        bottomNavigationBar: _bottomNav(context, actIndex: 0),
        body: Container(
          child: FutureBuilder(
            future: FirebaseFirestore.instance.collection('karts').where('status',isEqualTo: true).get(),
            builder: (context, snapshot) {
              return snapshot.hasData
                  ?   ListView.builder(
                itemExtent: 80,
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  return   Dismissible(
                      onDismissed: (direction) {
                        if (direction ==
                            DismissDirection.startToEnd) {
                          FirebaseFirestore.instance
                              .runTransaction((transaction) async {
                            DocumentSnapshot fresh =
                            await transaction.get(snapshot
                                .data.documents[index].reference);
                            transaction.update(
                                fresh.reference, {'status': true});
                            Get.snackbar('Info', 'Updated');
                          });
                        } else if (direction ==
                            DismissDirection.endToStart) {
                          FirebaseFirestore.instance
                              .runTransaction((transaction) async {
                            DocumentSnapshot fresh =
                            await transaction.get(snapshot
                                .data.documents[index].reference);
                            transaction.delete(fresh.reference);
                            Get.snackbar('Info', 'Item removed');
                          });
                        }
                      },
                      key: UniqueKey(),
                      secondaryBackground: Container(
                        color: Colors.redAccent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Remove',
                              style: TextStyle(
                                  fontSize: 22, color: Colors.white),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Icon(
                                Icons.remove_shopping_cart,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ),
                      background: Container(
                          color: Colors.green,
                          child: Row(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Icon(
                                  Icons.check,
                                  size: 40,
                                ),
                              ),
                              Text(
                                'Finish',
                                style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.white),
                              )
                            ],
                          )),
                      child: listItem(snapshot.data.documents[index],
                          Colors.blue));

                },
              )
                  : LinearProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
