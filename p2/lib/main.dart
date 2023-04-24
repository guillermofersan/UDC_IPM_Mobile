import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'edamam.dart';
import 'dart:core';
import 'dart:async';


void main() {
  runApp(const MyApp());
}

void altMain(){
  runApp(const MyAltApp());
}

Map<int, Color> color =
{
50: const Color.fromRGBO(106,204,0, .1),
100: const Color.fromRGBO(106,204,0, .2),
200: const Color.fromRGBO(106,204,0, .3),
300: const Color.fromRGBO(106,204,0, .4),
400: const Color.fromRGBO(106,204,0, .5),
500: const Color.fromRGBO(106,204,0, .6),
600: const Color.fromRGBO(106,204,0, .7),
700: const Color.fromRGBO(106,204,0, .8),
800: const Color.fromRGBO(106,204,0, .9),
900: const Color.fromRGBO(106,204,0, 1),
};

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edamam',
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFF6ACC00, color),
      ),
      home: const HomeScreen(title: 'Edamam Recipes - Home'),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  RangeValues _currentRangeValues = const RangeValues(0, 1000);
  final myController = TextEditingController();

  void changeToResults(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => ResultsListScreen(keyword: myController.text, rangeValues: _currentRangeValues)));
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(  
      body: Container(
          constraints: const BoxConstraints.expand(),
          decoration: const BoxDecoration(
          image: DecorationImage(
          image: AssetImage("Media/background.jpg"), 
          fit: BoxFit.cover),
          ),
          child: Container(
            margin: const EdgeInsets.only(left: 30.0, right: 30.0),
            child: Center(  
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 30.0, top: 15.0),
                    child: Image.asset(
                    "Media/edamam_white_crop.png"
                   ),
                  ),
                ),
                const Text(
                  'Enter a keyword to search recipes:',
                  style: TextStyle(color: Colors.white),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 50.0, right: 50.0, bottom: 25.0),
                 child: TextField(
                    controller: myController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                    onSubmitted: (_) {
                    changeToResults();
                    },
                  ),
                ),
                const Text(
                  'Enter the range of calories:',
                  style: TextStyle(color: Colors.white),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                  child: RangeSlider(
                    key: const Key("calories_range"),
                    values: _currentRangeValues,
                    min: 0,
                    max: 1000,
                    divisions: 50,
                    labels: RangeLabels(
                      _currentRangeValues.start.round().toString(),
                      _currentRangeValues.end.round().toString(),
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        _currentRangeValues = values;
                      });
                    }
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          changeToResults();
        },
        tooltip: 'Search',
        child: const Icon(Icons.search),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class ResultsListScreen extends StatelessWidget {
  //ResultsListScreen({super.key, required this.keyword, dynamic listNames});
  final String keyword;
  final RangeValues rangeValues;

  ResultsListScreen({required this.keyword, required RangeValues this.rangeValues});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(
        "Results of \"$keyword\"",
        style: const TextStyle(color: Color(0xffffffff)),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: ResultsList(
        keyword: keyword,
        rangeValues: rangeValues,
      ),
    );
  }
}

class RecipeScreen extends StatelessWidget {
  final Recipe recipe;
  const RecipeScreen({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          recipe.label!,
          style: const TextStyle(color: Color(0xffffffff)),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
    body: Padding(
        padding: const EdgeInsets.only(top:15, left: 20.0, right: 10.0),
        child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
          Image.network(recipe.image!),
          const Divider(color: Colors.white),
          RichText(
            key: const Key("RecipeTitle"),
            text: TextSpan(
              text: recipe.label,
              style: const TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold),
            ),
            textAlign: TextAlign.center,
          ),
          const Divider(color: Colors.white),
          RichText(
            text: const TextSpan(
              text: "Ingredients",
              style: TextStyle(color: Colors.black, fontSize: 23, fontStyle: FontStyle.italic),
            ),
          textAlign: TextAlign.center,
          ),
          RichText(
            text:  TextSpan(
              text: getIngredients(recipe.ingredients!),
              style: const TextStyle(color: Colors.black, fontSize: 20),
            ),
            textAlign: TextAlign.left,
          ),
          const Divider(color: Colors.white),
          RichText(
            text: const TextSpan(
              text: "Nutritional info:",
              style: TextStyle(color: Colors.black, fontSize: 23, fontStyle: FontStyle.italic),
            ),
            textAlign: TextAlign.center,
          ),
          RichText(
            key: const Key("NutritionalInfo"),
            text:  TextSpan(
              children:[
                const TextSpan(text: "Calories per serving: "),
                TextSpan(text: ((){
                  if (recipe.calories==null || recipe.servings == null) return "Not provided";
                  return (recipe.calories!/recipe.servings!).toStringAsFixed(3);
                })()),
                const TextSpan(text: "\nGlycemic index: "),
                TextSpan(text: ((){
                  if (recipe.glycemicIndex==null) return "Not provided";
                  return recipe.glycemicIndex!.toStringAsFixed(3);
               }) ()),
              ],
          style: const TextStyle(color: Colors.black, fontSize: 20),
          ),
        textAlign: TextAlign.left,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 30.0, top: 15.0),
          child :UnconstrainedBox(
              child: SizedBox( 
              width: 200.0,
              height: 30.0,
              child: ElevatedButton(
                onPressed: () => _launchURL(recipe.sourceUrl!),
                child: const Text(
                  'Show more',
                    style: TextStyle(color: Colors.white),
                  ),
              ),
            ),
          ),
        ),
      ],
    ),
    ),
    ),
    );
  }

  _launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

  String getIngredients(List<String> ingredients){
    String ingr = "";
    for (String ingredient in recipe.ingredients!){
      ingr += "- $ingredient\n";
    }
    return ingr;
  }
}


/*
 * Widgets con el contenido de las pantallas
 */

class ResultsList extends StatefulWidget {
  //final void Function(String keyword) onKeywordSearched;
  //const ResultsList({required this.onKeywordSearched});

  final String keyword;
  final RangeValues rangeValues;
  const ResultsList({required this.keyword, required this.rangeValues, key}) : super(key: key);

  @override
  State<ResultsList> createState() => _ResultsListState();
}

class _ResultsListState extends State<ResultsList> {
  Future<RecipeBlock>? _recipeBlock;

  @override
  void initState(){
    super.initState();
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle fontStyle = TextStyle(
        fontSize: Theme.of(context).textTheme.
        headline5?.fontSize
    );

    return FutureBuilder<RecipeBlock>(
      future: _recipeBlock,
      builder: (BuildContext context, AsyncSnapshot<RecipeBlock> snapshot){
        if (snapshot.hasError){
          return Center(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  const Text("There was a network error"),
                  ElevatedButton(
                      child: const Text("Try again"),
                      onPressed: () {_reload(); },
                  )
                ],
              ),
            ),
          );
        }
        else if (snapshot.connectionState != ConnectionState.done){
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        else if (snapshot.data?.count==0){
          return Center(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  const Text("Recipes with that keyword were not found"),
                    ElevatedButton(
                      child: const Text("Go home"),
                      onPressed: () {Navigator.pop(context); },
                    )
                ],
              )
            )
          );
        }
        else{
          List? data = snapshot.data?.recipes!;
          if (data==null){
            return Center(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    const Text("There was an error obtaining the list"),
                    ElevatedButton(
                      child: const Text("Try again"),
                      onPressed: () {_reload(); },
                    )
                  ],
                ),
              ),
            );
          }
          //Call function to build the list
          bool tablet = (
            MediaQuery.of(context).orientation == Orientation.landscape
          );
        if (tablet){
          return Padding(
            padding: const EdgeInsets.only(left:15, top: 15.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 500,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: data.length,
              itemBuilder: (BuildContext context, int i) => InkWell(
                  key: Key("element_$i"),
                  enableFeedback: true,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RecipeScreen(recipe: data[i]))),               
                  child: Column(
                      children: <Widget>[
                        CircleAvatar(
                          backgroundImage: NetworkImage(data[i].image),
                          radius: 65,
                        ),
                        Text(data[i].label, style: fontStyle,),
                  ],
                  ),
              ),
            ),
          );}
          else {
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (BuildContext context, int i) => ListTile(
                key: Key("element_$i"),
                leading: CircleAvatar(
                 backgroundImage: NetworkImage(data[i].image),
               ),
                title: Text(data[i].label, style: fontStyle,),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RecipeScreen(recipe: data[i]))),
            )
          );
          }
        }
      },
    );
  }
  void _reload(){
    Future<RecipeBlock>? block = search_recipes(widget.keyword, widget.rangeValues.start, widget.rangeValues.end);
    setState(() {_recipeBlock = block;});
  }
  void findMore(String url){
    Future<RecipeBlock>? block = findByUrl(url);
    setState(() {_recipeBlock = block;});
  }
}



/* Only for testing */

class MyAltApp extends StatelessWidget {
  const MyAltApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edamam',
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFF6ACC00, color),
      ),
      home: const AltHomeScreen(title: 'Edamam Recipes - Home'),
    );
  }
}

class AltHomeScreen extends StatefulWidget {
  const AltHomeScreen({super.key, required this.title});

  final String title;

  @override
  State<AltHomeScreen> createState() => _AltHomeScreenState();
}

class _AltHomeScreenState extends State<AltHomeScreen> {
  RangeValues _currentRangeValues = const RangeValues(0, 1000);
  final myController = TextEditingController();
  final calStController = TextEditingController();
  final calEndController = TextEditingController();

  void changeToResults(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => ResultsListScreen(keyword: myController.text, rangeValues: _currentRangeValues)));
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("Media/background.jpg"),
              fit: BoxFit.cover),
        ),
        child: Container(
          margin: const EdgeInsets.only(left: 30.0, right: 30.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 30.0, top: 15.0),
                    child: Image.asset(
                        "Media/edamam_white_crop.png"
                    ),
                  ),
                ),
                const Text(
                  'Enter a keyword to search recipes:',
                  style: TextStyle(color: Colors.white),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 50.0, right: 50.0, bottom: 25.0),
                  child: TextField(
                    key: const Key("SearchBar"),
                    controller: myController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                    onSubmitted: (_) {
                      changeToResults();
                    },
                  ),
                ),
                const Text(
                  'Enter the range of calories:',
                  style: TextStyle(color: Colors.white),
                ),
                Row(
                  children:[
                    const SizedBox(width: 20),
                    Flexible(
                      child: TextFormField(
                        key: const Key("cal_st"),
                        controller: calStController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 30),
                    Flexible(
                      child: TextFormField(
                        key: const Key("cal_end"),
                        controller: calEndController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 20),
                  ]
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _currentRangeValues = RangeValues(double.parse(calStController.text.toString()), double.parse(calEndController.text.toString()));
          changeToResults();
        },
        tooltip: 'Search',
        child: const Icon(Icons.search),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
