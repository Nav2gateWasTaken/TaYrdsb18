import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ta/model/User.dart';
import 'package:ta/pages/InitPage.dart';
import 'package:ta/pages/LoginPage.dart';
import 'package:ta/pages/archivedpage/ArchivedCoursesPage.dart';
import 'package:ta/pages/calendarpage/CalendarPage.dart';
import 'package:ta/pages/detailpage/DetailPage.dart';
import 'package:ta/pages/detailpage/whatifpage/WhatIfWelcomePage.dart';
import 'package:ta/pages/drawerpages/AboutPage.dart';
import 'package:ta/pages/drawerpages/AccountsList.dart';
import 'package:ta/pages/drawerpages/EditAccount.dart';
import 'package:ta/pages/drawerpages/FeedbackPage.dart';
import 'package:ta/pages/settingspage/SettingsPage.dart';
import 'package:ta/pages/setuppage/SetupPage.dart';
import 'package:ta/pages/summarypage/SummaryPage.dart';
import 'package:ta/pages/updatespage/UpdatesPage.dart';
import 'package:ta/plugins/dataStore.dart';
import 'package:ta/res/Themes.dart';
import 'package:ta/tools.dart';
import 'package:ta/widgets/ZoomPageTransition.dart';

void main() async {
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  runZoned(() {
    runApp(InitPage());
  }, onError: Crashlytics.instance.recordError);
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();

  static Function updateBrightness;
  static Function updateColor;
}

class _AppState extends State<App> {
  _updateBrightness(int v) {
    setState(() {
      Config.darkMode = v;
      updateNavigationBarBrightness();
    });
  }

  _updateColor(MaterialColor color) {
    setState(() {
      Config.primaryColor = color;
    });
  }

  @override
  void initState() {
    super.initState();
    App.updateBrightness = _updateBrightness;
    App.updateColor = _updateColor;
  }

  @override
  Widget build(BuildContext context) {
    var color = Config.primaryColor;
    ThemeData lightTheme;
    ThemeData darkTheme;
    switch (Config.darkMode) {
      case 0:
        {
          lightTheme = getLightTheme(color);
          darkTheme = getLightTheme(color);
        }
        break;
      case 1:
        {
          lightTheme = getLightTheme(color);
          darkTheme = getDarkTheme(color);
        }
        break;
      case 2:
        {
          lightTheme = getDarkTheme(color);
          darkTheme = getDarkTheme(color);
        }
        break;
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "YRDSB Teach Assist Pro",
      theme: lightTheme,
      darkTheme: darkTheme,
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: DisableGlow(),
          child: child,
        );
      },
      initialRoute: "/",
      onGenerateRoute: generateRoute,
      localizationsDelegates: [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [const Locale('en'), const Locale.fromSubtags(languageCode: 'zh')],
    );
  }

  Route generateRoute(RouteSettings settings) {
    final args = settings.arguments as List;

    switch (settings.name) {
      case "/":
        return _createRoute(userList.length == 0 ? LoginPage() : SummaryPage(), showEnterAnimation: false);
      case "/summary":
        return _createRoute(SummaryPage());
      case "/login":
        return _createRoute(LoginPage());
      case "/updates":
        return _createRoute(UpdatesPage());
      case "/calendar":
        return _createRoute(CalendarPage());
      case "/accounts_list":
        return _createRoute(AccountsList());
      case "/accounts_list/edit":
        return _createRoute(EditAccount(args[0], args[1]));
      case "/about":
        return _createRoute(AboutPage());
      case "/feedback":
        return _createRoute(FeedbackPage());
      case "/detail":
        return _createRoute(DetailPage(args[0]));
      case "/detail/whatif_welcome":
        return _createRoute(WhatIfWelcomePage());
      case "/archived":
        return _createRoute(ArchivedCoursesPage());
      case "/settings":
        return _createRoute(SettingsPage());
      case "/setup":
        return _createRoute(SetupPage());
    }
  }

  Route _createRoute(Widget page, {bool showEnterAnimation = true}) {
    return isAndroid()
        ? PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => page,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return ZoomPageTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: child,
                showEnterAnimation: showEnterAnimation,
              );
            },
          )
        : MaterialPageRoute(
            builder: (context) => page,
            duration: showEnterAnimation ? const Duration(milliseconds: 300) : Duration.zero,
          );
  }

  ThemeData getLightTheme(MaterialColor color) {
    return ThemeData(
      brightness: Brightness.light,
      pageTransitionsTheme: PageTransitionsTheme(builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
      colorScheme: ColorScheme.light(
        primary: color,
        secondary: color[200],
      ),
      accentColor: color,
      primaryColor: color,
      primaryColorDark: color[700],
      toggleableActiveColor: color,
      appBarTheme: AppBarTheme(
        color: ThemeData.light().canvasColor,
        brightness: Brightness.light,
        elevation: 0,
      ),
      textSelectionColor: color[200],
      textSelectionHandleColor: color,
      cursorColor: color,
      buttonTheme: ButtonThemeData(
        colorScheme: ColorScheme.light(
          primary: color[400],
          secondary: color[200],
        ),
      ),
      sliderTheme: SliderThemeData(
        disabledActiveTrackColor: Colors.grey[400],
        disabledInactiveTrackColor: Colors.grey[400],
        disabledThumbColor: Colors.grey[500],
        activeTrackColor: color[200],
        inactiveTrackColor: color[200],
        thumbColor: color,
      ),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
      ),
    );
  }

  ThemeData getDarkTheme(MaterialColor color) {
    return ThemeData(
      brightness: Brightness.dark,
      pageTransitionsTheme: PageTransitionsTheme(builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
      colorScheme: ColorScheme.dark(
        primary: color,
        secondary: color[300],
      ),
      accentColor: color,
      toggleableActiveColor: color[300],
      appBarTheme: AppBarTheme(
        color: ThemeData.dark().canvasColor,
        brightness: Brightness.dark,
        elevation: 0,
      ),
      textSelectionColor: color,
      textSelectionHandleColor: color[300],
      cursorColor: color,
      buttonTheme: ButtonThemeData(
        colorScheme: ColorScheme.dark(
          primary: color[400],
          secondary: color[200],
        ),
      ),
      primarySwatch: color,
      sliderTheme: SliderThemeData(
        disabledActiveTrackColor: Colors.grey[500],
        disabledInactiveTrackColor: Colors.grey[500],
        disabledThumbColor: Colors.grey[600],
        activeTrackColor: color[300],
        inactiveTrackColor: color[300],
        thumbColor: color,
      ),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
      ),
    );
  }
}
