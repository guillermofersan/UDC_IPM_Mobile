import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:p2/main.dart' as app;

const KEYWORD = "potato";
const START_CALORIES = "200";
const END_CALORIES = "220";

void main(){
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('Empty search, check it does not find recipes',
        (tester) async{
          app.main();
          await tester.pumpAndSettle();

          // Locate search button and tap it, with no keyword inserted
          final Finder searchButton = find.byTooltip('Search');
          await tester.tap(searchButton);

          // Compare the expected screen with the obtained one
          await tester.pumpAndSettle();
          expect (find.text ('Recipes with that keyword were not found'), findsOneWidget);
        });

    testWidgets('Search by keyword and calories, verify the results',
        (tester) async {
          //take the alternative home page to make it easier to input values
          app.altMain();
          await tester.pumpAndSettle();

          final Finder searchButton = find.byTooltip("Search");
          final Finder searchBar = find.byKey(const Key("SearchBar"));
          final Finder startCal = find.byKey(const Key("cal_st"));
          final Finder endCal = find.byKey(const Key("cal_end"));

          await tester.enterText(searchBar, KEYWORD);
          await tester.enterText(startCal, START_CALORIES);
          await tester.enterText(endCal, END_CALORIES);
          await tester.tap(searchButton);
          await tester.pumpAndSettle();

          //Locate a tuple and access it.
          final Finder element = find.byKey(const Key("element_1"));
          await tester.tap(element);
          await tester.pumpAndSettle();

          // Locate the widget containing the title (which must contain keyword)
          var recipeTitle = find.byKey(const Key("RecipeTitle")).evaluate().single.widget as RichText;
          if (!recipeTitle.toString().toLowerCase().contains(KEYWORD)) {
            throw TestFailure("Keyword was not in search results");
          }

          // Locate the part with the calories per serving
          var nutritionalInfo = find.byKey(const Key("NutritionalInfo")).evaluate().single.widget as RichText;
          List<String> splitted = nutritionalInfo.toString().split("Calories per serving: ");
          splitted = splitted[1].split("\\n");

          // Check that calories is between the range
          double calories = double.parse(splitted[0]);
          if (calories>double.parse(END_CALORIES) || calories<double.parse(START_CALORIES)){
            throw TestFailure("Calories of some recipe is not in the specified range");
          }
        }
    );
  });
}
