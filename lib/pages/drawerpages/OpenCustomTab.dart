import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:ta/tools.dart';

void openCustomTab(BuildContext context,String url) async {
  await launch(
    url,
    option: new CustomTabsOption(
      toolbarColor: primaryColorOf(context),
      enableDefaultShare: false,
      enableUrlBarHiding: true,
      showPageTitle: true,
      animation: new CustomTabsAnimation.slideIn(),
      extraCustomTabs: <String>[
        'org.mozilla.firefox',
        'com.microsoft.emmx',
      ],
    ),
  );
}