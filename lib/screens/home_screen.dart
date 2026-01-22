import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_crud_practice/app.dart';
import 'package:firebase_crud_practice/data/models/match_model.dart';
import 'package:firebase_crud_practice/screens/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../app.dart';
import '../data/models/match_model.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onThemeChanged;
  const HomeScreen({super.key, required this.onThemeChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _team1Controller = TextEditingController();
  final TextEditingController _team2Controller = TextEditingController();
  final TextEditingController _team1ScoreController = TextEditingController();
  final TextEditingController _team2ScoreController = TextEditingController();

  bool isLoading = false;
  bool isDeleting = false;

  BannerAd? _bannerAd;

  /// Loads a banner ad.
  void _loadAd() {
    final bannerAd = BannerAd(
      size: AdSize.getCurrentOrientationInlineAdaptiveBannerAdSize(
        MediaQuery.sizeOf(context).width.truncate(),
      ),
      adUnitId: "ca-app-pub-3940256099942544/6300978111",
      request: const AdRequest(),
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    );

    // Start loading.
    bannerAd.load();
  }

  @override
  void initState() {
    FirebaseCrashlytics.instance.log("Entering home screen");
    super.initState();
  }

  @override
  void dispose() {
    _team1Controller.dispose();
    _team2Controller.dispose();
    _team1ScoreController.dispose();
    _team2ScoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_bannerAd == null) {
      _loadAd();
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorScheme.of(context).primary,
        foregroundColor: Colors.white,
        title: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, asyncSnapshot) {
            final user = asyncSnapshot.data;
            if (ConnectionState == AsyncSnapshot.waiting()) {
              return SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(),
              );
            }
            if (!asyncSnapshot.hasData) {
              return Text("User not found");
            }
            return Row(
              spacing: 10,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.grey,
                  child: (user?.photoURL != null)
                      ? Image.network(user!.photoURL.toString())
                      : Icon(Icons.person),
                ),
                Column(
                  crossAxisAlignment: .start,
                  mainAxisAlignment: .start,
                  children: [
                    Text(user!.displayName.toString()),
                    Text(user.email.toString(), style: TextStyle(fontSize: 14)),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          Switch(
            value: FirebaseCrud.isLight,
            onChanged: (value) {
              FirebaseCrud.isLight = value;
              setState(() {});
              widget.onThemeChanged();
              FirebaseAnalytics.instance.logEvent(name: "Theme Changed");
            },
            activeTrackColor: Colors.greenAccent,
            inactiveTrackColor: Colors.black,
            inactiveThumbColor: Colors.greenAccent,
          ),
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => SignInScreen()),
                (route) => false,
              );
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: .spaceAround,
        children: [
          FloatingActionButton(
            onPressed: () {
              _matchDialog(update: false);
              FirebaseAnalytics.instance.logEvent(name: "Match create fired");
            },
            child: Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: () {
              FirebaseAnalytics.instance.logEvent(name: "Thrown_error");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Exception thrown for crashlytics test"),
                ),
              );
              throw Exception("My Execution");
            },
            child: Icon(Icons.bug_report_outlined),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _firestore.collection("football").snapshots(),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (asyncSnapshot.hasData) {
            return Column(
              children: [
                if (_bannerAd != null)
                  SizedBox(
                    height: 100,
                    width: .maxFinite,
                    child: AdWidget(ad: _bannerAd!),
                  ),
                Expanded(
                  child: ListView.separated(
                    padding: .symmetric(horizontal: 20),
                    itemBuilder: (context, index) {
                      final match = MatchModel.fromJson({
                        "id": asyncSnapshot.data?.docs[index].id,
                        ...asyncSnapshot.data!.docs[index].data(),
                      });
                      return ListTile(
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (context) => Stack(
                              children: [
                                AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: .circular(10),
                                  ),
                                  title: Column(
                                    children: [
                                      Icon(
                                        Icons.warning_amber_outlined,
                                        size: 80,
                                        color: Colors.orange,
                                      ),
                                      Text(
                                        "Choose Action",
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                  content: Row(
                                    mainAxisAlignment: .spaceBetween,
                                    children: [
                                      FilledButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _matchDialog(
                                            update: true,
                                            match: match,
                                          );
                                        },
                                        child: Row(
                                          spacing: 5,
                                          children: [
                                            Icon(Icons.edit),
                                            Text("Update"),
                                          ],
                                        ),
                                      ),
                                      FilledButton(
                                        style: FilledButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return StatefulBuilder(
                                                builder: (context, setState) {
                                                  ///--------------------delete match-------------
                                                  Future<void>
                                                  deleteMatch() async {
                                                    isDeleting = true;
                                                    setState(() {});
                                                    try {
                                                      await _firestore
                                                          .collection(
                                                            "football",
                                                          )
                                                          .doc((match.id))
                                                          .delete();
                                                    } catch (e) {
                                                      debugPrint(
                                                        "delete match failed $e",
                                                      );
                                                    } finally {
                                                      isDeleting = false;
                                                    }
                                                  }

                                                  return AlertDialog(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                              .circular(10),
                                                        ),
                                                    title: Column(
                                                      mainAxisSize: .min,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .warning_amber_outlined,
                                                          size: 80,
                                                          color: Colors.orange,
                                                        ),
                                                        Text(
                                                          "Delete match",
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ],
                                                    ),
                                                    content: Row(
                                                      mainAxisAlignment:
                                                          .spaceBetween,
                                                      children: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                          },
                                                          child: Row(
                                                            spacing: 5,
                                                            children: [
                                                              Icon(Icons.close),
                                                              Text("Cancel"),
                                                            ],
                                                          ),
                                                        ),
                                                        FilledButton(
                                                          style:
                                                              FilledButton.styleFrom(
                                                                backgroundColor:
                                                                    Colors.red,
                                                              ),
                                                          onPressed: () {
                                                            deleteMatch();
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                          },
                                                          child: Row(
                                                            mainAxisSize: .min,
                                                            spacing: 5,
                                                            children: [
                                                              Icon(
                                                                Icons.delete,
                                                              ),
                                                              isDeleting
                                                                  ? SizedBox(
                                                                      width: 16,
                                                                      height:
                                                                          16,
                                                                      child: CircularProgressIndicator(
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    )
                                                                  : Text(
                                                                      "Confirm",
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
                                          );
                                        },
                                        child: Row(
                                          spacing: 5,
                                          children: [
                                            Icon(Icons.delete),
                                            Text("Delete"),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top:
                                      MediaQuery.of(context).size.height / 2 -
                                      115,
                                  right:
                                      MediaQuery.of(context).size.width / 2 -
                                      130,
                                  child: IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon: Icon(Icons.close),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        leading: CircleAvatar(
                          radius: 5,
                          backgroundColor: match.isRunning
                              ? Colors.green
                              : Colors.red,
                        ),
                        title: Text("${match.team1} vs ${match.team2}"),
                        subtitle: Text("Winner : ${match.winner}"),

                        trailing: Text(
                          "${match.team1Score} : ${match.team2Score}",
                          style: TextTheme.of(context).titleMedium,
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => SizedBox(height: 10),
                    itemCount: asyncSnapshot.data!.docs.length,
                  ),
                ),
              ],
            );
          }
          return SizedBox();
        },
      ),
    );
  }

  void _matchDialog({bool update = false, MatchModel? match}) {
    bool isRunning = true;

    if (update) {
      _team1Controller.text = match!.team1;
      _team2Controller.text = match.team2;
      _team1ScoreController.text = match.team1Score.toString();
      _team2ScoreController.text = match.team2Score.toString();
      isRunning = match.isRunning;
    } else {
      _team1Controller.clear();
      _team2Controller.clear();
      _team1ScoreController.clear();
      _team2ScoreController.clear();
      isRunning = isRunning;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          Future<void> createOrUpdateMatch() async {
            isLoading = true;

            setState(() {});
            final matchData = MatchModel(
              team2: _team2Controller.text,
              team1Score: int.parse(_team1ScoreController.text),
              team2Score: int.parse(_team2ScoreController.text),
              isRunning: isRunning,
              winner: update
                  ? isRunning
                        ? "pending"
                        : (int.parse(_team1ScoreController.text) >
                                  int.parse(_team2ScoreController.text)
                              ? _team1Controller.text
                              : _team2Controller.text)
                  : isRunning
                  ? "pending"
                  : (int.parse(_team1ScoreController.text) >
                            int.parse(_team2ScoreController.text)
                        ? _team1Controller.text
                        : _team2Controller.text),
              team1: _team1Controller.text,
            );
            try {
              if (update) {
                FirebaseAnalytics.instance.logEvent(
                  name: "match ${match?.id} update fired",
                );
                await _firestore
                    .collection("football")
                    .doc((match?.id))
                    .update(matchData.toJson());
              } else {
                FirebaseAnalytics.instance.logEvent(
                  name: "match ${match?.id} create fired",
                );

                await _firestore.collection("football").add(matchData.toJson());
              }

              debugPrint("Match created successfully");
              _team1Controller.clear();
              _team2Controller.clear();
              _team1ScoreController.clear();
              _team2ScoreController.clear();

              Navigator.pop(context);
            } catch (e) {
              debugPrint("Create match failed");
            } finally {
              isLoading = false;
              setState(() {});
            }
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Text("${update ? "Update" : "Create"} match"),

            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  spacing: 10,
                  mainAxisSize: .min,
                  children: [
                    TextFormField(
                      controller: _team1Controller,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter Team 1 name';
                        }
                        return null;
                      },
                      decoration: InputDecoration(hintText: "Team 1 name"),
                    ),
                    TextFormField(
                      controller: _team2Controller,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter Team 2 name';
                        }
                        return null;
                      },
                      decoration: InputDecoration(hintText: "Team 2 name"),
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: _team1ScoreController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter Team 1 score';
                        }
                        return null;
                      },
                      decoration: InputDecoration(hintText: "Team 1 score"),
                    ),
                    TextFormField(
                      controller: _team2ScoreController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter Team 2 score';
                        }
                        return null;
                      },
                      decoration: InputDecoration(hintText: "Team 2 score"),
                    ),
                    DropdownMenu<bool>(
                      onSelected: (value) => isRunning = value!,
                      width: double.infinity,
                      initialSelection: isRunning,
                      menuStyle: const MenuStyle(
                        side: WidgetStatePropertyAll(BorderSide.none),
                        minimumSize: WidgetStatePropertyAll(
                          Size(double.infinity, 56),
                        ),
                      ),
                      inputDecorationTheme: const InputDecorationTheme(
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                        ),
                      ),
                      dropdownMenuEntries: const [
                        DropdownMenuEntry(value: true, label: "Running"),
                        DropdownMenuEntry(value: false, label: "Finished"),
                      ],
                    ),

                    SizedBox(height: 10),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: .circular(10),
                          ),
                          minimumSize: Size(
                            MediaQuery.of(context).size.width,
                            50,
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            createOrUpdateMatch();
                          }
                        },
                        child: isLoading
                            ? Center(
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : Text("${update ? "Update" : "Create"} Match"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
