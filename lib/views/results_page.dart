import 'dart:math';

import 'package:campus_cooks/models/food.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:io';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:swiping_card_deck/swiping_card_deck.dart';

class ResultsPage extends StatefulWidget {
  final XFile picture;
  const ResultsPage({super.key, required this.picture});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Future<List<Food>> foodFetched;
  late Future<List<String>> ingredientsDetected;

  final List<String> titles = [];
  Future<void> generateTitles(int n) async {
    for (int i = 0; i < n; i++) {
      titles.add("");
    }
  }

  bool isDeckEmpty = false;
  final List<Color> cardColors = [];
  Future<void> generateRandomColors(int n) async {
    Random random = Random();
    for (int i = 0; i < n; i++) {
      int r = 200 + random.nextInt(56);
      int g = 200 + random.nextInt(56);
      int b = 200 + random.nextInt(56);
      cardColors.add(Color.fromARGB(255, r, g, b));
    }
  }

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = Tween<double>(
      begin: 0,
      end: 2 * 3.141,
    ).animate(_controller);
    _controller.repeat();
    ingredientsDetected = detectFood();
    foodFetched = callFoodRecognitionAPI();
  }

  Future<List<Food>> callFoodRecognitionAPI() async {
    List<String> ingredientsList = [];
    List<Food> foodList = [];
    try {
      var headers = {
        'accept': 'application/json',
        'Authorization': 'Bearer 3a54e8b31e289208d820cb5c048077374ad41b00'
      };
      var request = http.MultipartRequest(
          'POST',
          Uri.parse(
              'https://api.logmeal.es/v2/image/segmentation/complete/v1.0?language=eng'));
      request.files
          .add(await http.MultipartFile.fromPath('image', widget.picture.path));
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();

        Map<String, dynamic> jsonResponse = json.decode(responseBody);

        List<dynamic> segmentationResults =
            jsonResponse['segmentation_results'];
        for (var i = 0; i < segmentationResults.length; i++) {
          ingredientsList
              .add(segmentationResults[i]['recognition_results'][0]['name']);
        }
        Completer<List<String>> completer = Completer();
        completer.complete(ingredientsList);
        ingredientsDetected = completer.future;
        print(ingredientsDetected);

        foodList = await fetchRecipesFromSpoonacularAPI(ingredientsList);
        Future.delayed(const Duration(seconds: 3));
        return foodList;
      } else {
        print(response.reasonPhrase);
        return foodList;
      }
    } catch (e) {
      print(e);
      return foodList;
    }
  }

  Future<List<String>> detectFood() async {
    List<String> ingredientsList = [];
    try {
      var headers = {
        'accept': 'application/json',
        'Authorization': 'Bearer 3a54e8b31e289208d820cb5c048077374ad41b00'
      };
      var request = http.MultipartRequest(
          'POST',
          Uri.parse(
              'https://api.logmeal.es/v2/image/segmentation/complete/v1.0?language=eng'));
      request.files
          .add(await http.MultipartFile.fromPath('image', widget.picture.path));
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();

        Map<String, dynamic> jsonResponse = json.decode(responseBody);

        List<dynamic> segmentationResults =
            jsonResponse['segmentation_results'];
        for (var i = 0; i < segmentationResults.length; i++) {
          ingredientsList
              .add(segmentationResults[i]['recognition_results'][0]['name']);
        }
        print(ingredientsList);
        return ingredientsList;
      } else {
        print(response.reasonPhrase);
        return ingredientsList;
      }
    } catch (e) {
      print(e);
      return ingredientsList;
    }
  }

  Future<List<Food>> fetchRecipesFromSpoonacularAPI(
      List<String> ingredients) async {
    List<Food> recipesFetched = [];
    var ingredientsString = ingredients.join(',');
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://api.spoonacular.com/recipes/findByIngredients?ingredients=$ingredientsString&number=10&limitLicense=true&ranking=1&ignorePantry=false&apiKey=e7cf93381c2642d78d0de82007dfc421'));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var jsonResponse = await response.stream.bytesToString();
      List<dynamic> dataList = json.decode(jsonResponse);
      for (var item in dataList) {
        if (item.containsKey('id')) {
          Food food = await fetchRecipeDetails(item['id']);
          recipesFetched.add(food);
        }
      }
      for (var food in recipesFetched) {
        print('ID: ${food.id}');
        print('Name: ${food.name}');
        print('Image URL: ${food.imageUrl}');
        print('Calories: ${food.calories}');
        print('Ready in Minutes: ${food.readyInMinutes}');
        print('Fiber: ${food.fiber}');
        print('Protein: ${food.protein}');
        print('Sugar: ${food.sugar}');
        print('');
      }
      await generateRandomColors(recipesFetched.length);
      await generateTitles(recipesFetched.length);
      return recipesFetched;
    } else {
      print(response.reasonPhrase);
      return recipesFetched;
    }
  }

  Future<Food> fetchRecipeDetails(int id) async {
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://api.spoonacular.com/recipes/$id/information?includeNutrition=true&instructionsRequired=true&apiKey=e7cf93381c2642d78d0de82007dfc421'));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var jsonResponse = await response.stream.bytesToString();
      var data = json.decode(jsonResponse);

      Food food = Food.fromJson(data);
      return food;
    } else {
      return Food(
          id: -1,
          name: '',
          imageUrl: '',
          calories: '',
          readyInMinutes: '',
          fiber: '',
          protein: '',
          sugar: '',
          vegetarian: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Food>>(
        future: foodFetched,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        // Use Transform.rotate to rotate the Image based on the animation value
                        return Transform.rotate(
                          angle: _animation.value,
                          child: Image.asset(
                            'assets/images/loading_icon.png', // Replace with your image asset
                            width: 200,
                            height: 100,
                          ),
                        );
                      },
                    ),
                    FutureBuilder<List<String>>(
                        future: ingredientsDetected,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return AnimatedTextKit(
                              repeatForever: true,
                              animatedTexts: [
                                TyperAnimatedText(
                                    'Exploring tasty recipes for you !',
                                    textStyle: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center),
                              ],
                            );
                          } else {
                            final ingredients = snapshot.data as List<String>;
                            return Column(
                              children: <Widget>[
                                AnimatedTextKit(
                                  repeatForever: true,
                                  animatedTexts: [
                                    TyperAnimatedText(
                                        'Exploring tasty recipes for you !',
                                        textStyle: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center),
                                  ],
                                ),
                                const SizedBox(height: 10.0),
                                const Text("With",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center),
                                const SizedBox(height: 5.0),
                                SizedBox(
                                    height: 30,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        DefaultTextStyle(
                                          style: const TextStyle(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Horizon',
                                              color: Colors.black),
                                          child: AnimatedTextKit(
                                            animatedTexts: [
                                              for (String ingredient
                                                  in ingredients)
                                                RotateAnimatedText(ingredient),
                                            ],
                                          ),
                                        )
                                      ],
                                    ))
                              ],
                            );
                          }
                        })
                  ],
                ),
              ),
            );
          } else {
            final foodList = snapshot.data as List<Food>;

            return Scaffold(
                appBar: AppBar(title: Text("The results")),
                body: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SwipingCardDeck(
                        cardDeck: List.generate(
                          foodList.length,
                          (index) => Card(
                            color: cardColors[currentIndex],
                            child: SizedBox(
                                height: 500,
                                width: 500,
                                child: Column(children: [
                                  SizedBox(
                                      height: 250,
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            top: 40.0,
                                            left: 40.0,
                                            child: Transform.rotate(
                                              angle: -0.2,
                                              child: Image.file(
                                                  File(widget.picture.path),
                                                  width: 180.0,
                                                  height: 180.0,
                                                  fit: BoxFit.cover),
                                            ),
                                          ),
                                          Positioned(
                                            top: 50.0,
                                            right: 40.0,
                                            child: Transform.rotate(
                                              angle: 0.3,
                                              child: Image.network(
                                                foodList[currentIndex].imageUrl,
                                                width: 180.0,
                                                height: 180.0,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          )
                                        ],
                                      )),
                                  const SizedBox(height: 20),
                                  Column(children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                            child: Text(
                                          foodList[currentIndex].name,
                                          softWrap: true,
                                          style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.06,
                                              fontWeight: FontWeight.bold),
                                        )),
                                        const SizedBox(width: 10),
                                        foodList[currentIndex].vegetarian
                                            ? const Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.crop_square_sharp,
                                                    color: Colors.green,
                                                    size: 40,
                                                  ),
                                                  Icon(Icons.circle,
                                                      color: Colors.green,
                                                      size: 14),
                                                ],
                                              )
                                            : const Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.crop_square_sharp,
                                                    color: Colors.red,
                                                    size: 40,
                                                  ),
                                                  Icon(Icons.circle,
                                                      color: Colors.red,
                                                      size: 14),
                                                ],
                                              )
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Column(children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons
                                                .local_fire_department_outlined,
                                            size: 30,
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(foodList[currentIndex].calories,
                                              style: const TextStyle(
                                                fontSize: 22,
                                              )),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.av_timer_sharp,
                                            size: 30,
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                              "${foodList[currentIndex].readyInMinutes} minutes",
                                              style: const TextStyle(
                                                fontSize: 22,
                                              )),
                                        ],
                                      )
                                    ]),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    IntrinsicHeight(
                                        child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Column(
                                          children: [
                                            Text(foodList[currentIndex].fiber,
                                                style: const TextStyle(
                                                  fontSize: 22,
                                                )),
                                            const Text("Fiber",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                ))
                                          ],
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        const VerticalDivider(
                                          color: Colors.black,
                                          thickness: 2,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Column(
                                          children: [
                                            Text(foodList[currentIndex].protein,
                                                style: const TextStyle(
                                                  fontSize: 22,
                                                )),
                                            const Text("Protein",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                ))
                                          ],
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        const VerticalDivider(
                                          color: Colors.black,
                                          thickness: 2,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Column(
                                          children: [
                                            Text(foodList[currentIndex].sugar,
                                                style: const TextStyle(
                                                  fontSize: 22,
                                                )),
                                            const Text("Sugar",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                ))
                                          ],
                                        ),
                                      ],
                                    )),
                                  ])
                                ])),
                          ),
                        ),
                        onDeckEmpty: () {
                          debugPrint("Card deck empty");
                        },
                        onLeftSwipe: (Card card) {
                          if (currentIndex > 3) {
                            setState(() {
                              currentIndex = 0;
                            });
                            debugPrint("Swiped left on first card!");
                          } else {
                            setState(() {
                              currentIndex++;
                            });
                            debugPrint("Swiped left!");
                          }
                        },
                        onRightSwipe: (Card card) {
                          if (currentIndex <= 0) {
                            setState(() {
                              currentIndex = 4;
                            });
                          } else {
                            setState(() {
                              currentIndex--;
                            });
                          }
                        },
                        swipeThreshold: MediaQuery.of(context).size.width / 4,
                        minimumVelocity: 1000,
                        cardWidth: 200,
                        rotationFactor: 0.8 / 3.14,
                        swipeAnimationDuration:
                            const Duration(milliseconds: 300),
                        disableDragging:
                            false, // Disable dragging when deck is empty
                      )
                    ]));
            // appBar: AppBar(title: Text("Results")),
            //   body:  Padding(
            //       padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            //       child:
            //             Column(children: [
            //                Flexible(flex: 8, child:
            //                 SizedBox(
            //                     // height: 210,
            //                     child: Stack(
            //                       children: [
            //                         Positioned(
            //                           top: 40.0,
            //                           left: 60.0,
            //                           child: Transform.rotate(
            //                             angle: -0.2,
            //                             child: Image.asset('assets/images/recipe.jpg',
            //                                 // Image.file(
            //                                 //     File(widget.picture.path),
            //                                 width: 180.0,
            //                                 height: 180.0,
            //                                 fit: BoxFit.cover),
            //                           ),
            //                         ),
            //                         Positioned(
            //                           top: 50.0,
            //                           right: 60.0,
            //                           child: Transform.rotate(
            //                             angle: 0.3,
            //                             child: Image.asset(
            //                               'assets/images/recipe.jpg',
            //                               width: 180.0,
            //                               height: 180.0,
            //                             ),
            //                           ),
            //                         ),
            //                       ],
            //                     ))),
            //               // ]),
            //           Flexible(flex:20, child:
            //           SizedBox(
            //               height: double.infinity,
            //               width: double.infinity,
            //               child:  VerticalCardPager(
            //                 initialPage: 0,
            //                 titles: titles,
            //                 images: [
            //                   Container(
            //                       decoration: BoxDecoration(
            //                           color: cardColors[0],
            //                           borderRadius: const BorderRadius.all(
            //                               Radius.circular(10))),
            //                       child: FittedBox(
            //                         fit: BoxFit.fitWidth,
            //                         child: currentPageIndex == 0
            //                             ? const SizedBox(
            //                                 width: 200,
            //                                 height: 180,
            //                                 child: Padding(
            //                                     padding: EdgeInsets.all(8),
            //                                     child: Column(
            //                                         mainAxisAlignment:
            //                                             MainAxisAlignment.spaceAround,
            //                                         children: [Row(
            //                                             mainAxisAlignment:
            //                                                 MainAxisAlignment
            //                                                     .spaceAround,
            //                                             children: [ Text(
            //                                                     "Tomato Basil Pasta",
            //                                                     softWrap: true,
            //                                                     style: TextStyle(
            //                                                         fontSize: 18,
            //                                                         fontWeight:
            //                                                             FontWeight
            //                                                                 .bold),
            //                                                   ), Stack(
            //                                                     alignment:
            //                                                         Alignment
            //                                                             .center,
            //                                                     children: [
            //                                                       Icon(
            //                                                         Icons
            //                                                             .crop_square_sharp,
            //                                                         color: Colors
            //                                                             .green,
            //                                                         size: 40,
            //                                                       ),
            //                                                       Icon(
            //                                                           Icons
            //                                                               .circle,
            //                                                           color: Colors
            //                                                               .green,
            //                                                           size: 14),
            //                                                     ],
            //                                                   )
            //                                             ],
            //                                           ),Column(children: [
            //                                             Row(
            //                                               mainAxisAlignment:
            //                                                   MainAxisAlignment
            //                                                       .center,
            //                                               children: [
            //                                                 Icon(
            //                                                   Icons
            //                                                       .local_fire_department_outlined,
            //                                                   size: 20,
            //                                                 ),
            //                                                 SizedBox(
            //                                                   width: 10,
            //                                                 ),
            //                                                 Text("150 calories",
            //                                                     style: TextStyle(
            //                                                       fontSize: 18,
            //                                                     )),
            //                                               ],
            //                                             ), Row(
            //                                               mainAxisAlignment:
            //                                                   MainAxisAlignment
            //                                                       .center,
            //                                               children: [
            //                                                 Icon(
            //                                                   Icons
            //                                                       .av_timer_sharp,
            //                                                   size: 20,
            //                                                 ),
            //                                                 SizedBox(
            //                                                   width: 10,
            //                                                 ),
            //                                                 Text("30 minutes",
            //                                                     style: TextStyle(
            //                                                       fontSize: 18,
            //                                                     )),
            //                                               ],
            //                                             )
            //                                           ]),
            //                                           SizedBox(height: 5),IntrinsicHeight(
            //                                                   child: Row(
            //                                             mainAxisAlignment:
            //                                                 MainAxisAlignment
            //                                                     .center,
            //                                             children: [
            //                                               Column(
            //                                                 children: [
            //                                                   Text("10g",
            //                                                       style:
            //                                                           TextStyle(
            //                                                         fontSize: 18,
            //                                                       )),
            //                                                   Text("Fiber",
            //                                                       style:
            //                                                           TextStyle(
            //                                                         fontSize: 14,
            //                                                       ))
            //                                                 ],
            //                                               ),
            //                                               SizedBox(
            //                                                 width: 10,
            //                                               ),
            //                                               VerticalDivider(
            //                                                 color: Colors.black,
            //                                                 thickness: 2,
            //                                               ),
            //                                               SizedBox(
            //                                                 width: 10,
            //                                               ),
            //                                               Column(
            //                                                 children: [
            //                                                   Text("10g",
            //                                                       style:
            //                                                           TextStyle(
            //                                                         fontSize: 18,
            //                                                       )),
            //                                                   Text("Protein",
            //                                                       style:
            //                                                           TextStyle(
            //                                                         fontSize: 14,
            //                                                       ))
            //                                                 ],
            //                                               ),
            //                                               SizedBox(
            //                                                 width: 10,
            //                                               ),
            //                                               VerticalDivider(
            //                                                 color: Colors.black,
            //                                                 thickness: 2,
            //                                               ),
            //                                               SizedBox(
            //                                                 width: 10,
            //                                               ),
            //                                               Column(
            //                                                 children: [
            //                                                   Text("1g",
            //                                                       style:
            //                                                           TextStyle(
            //                                                         fontSize: 18,
            //                                                       )),
            //                                                   Text("Sugar",
            //                                                       style:
            //                                                           TextStyle(
            //                                                         fontSize: 14,
            //                                                       ))
            //                                                 ],
            //                                               ),
            //                                             ],
            //                                           )),
            //                                         ])))
            //                             : null,
            //                       )),
            //                   Container(
            //                     decoration: BoxDecoration(
            //                       color: cardColors[1],
            //                       borderRadius:
            //                           BorderRadius.all(Radius.circular(10)),
            //                     ),
            //                   ),
            //                   Container(
            //                     decoration: BoxDecoration(
            //                       color: cardColors[2],
            //                       borderRadius:
            //                           BorderRadius.all(Radius.circular(10)),
            //                     ),
            //                   ),
            //                   Container(
            //                     decoration: BoxDecoration(
            //                       color: cardColors[3],
            //                       borderRadius:
            //                           BorderRadius.all(Radius.circular(10)),
            //                     ),
            //                   )
            //                 ],
            //                 onPageChanged: (page) {
            //                   setState(() {
            //                     currentPageIndex = page!.toInt().round();
            //                   });
            //                 },
            //                 align: ALIGN.CENTER,
            //                 onSelectedItem: (index) {
            //                   print("Hello");
            //                 },
            //                 )))])
            //         )
            // ]));
          }
        });
  }
}
