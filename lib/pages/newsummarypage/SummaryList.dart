import 'package:flutter/material.dart';
import 'package:ta/model/Mark.dart';
import 'package:ta/model/User.dart';
import 'package:ta/pages/detailpage/DetailPage.dart';
import 'package:ta/pages/summarypage/CourseCard.dart';
import 'package:ta/res/Strings.dart';
import 'package:ta/widgets/LinearProgressIndicator.dart' as LPI;

import '../../tools.dart';

class SummaryList extends StatelessWidget {
  final List<Course> courses=getCourseListOf(currentUser.number);

  @override
  Widget build(BuildContext context) {
    var list = List<Widget>();

    var total = 0.0;
    var availableCourseCount = 0;

    courses.forEach((course) {
      if (course.overallMark != null) {
        total += course.overallMark;
        availableCourseCount++;
      }

      list.add(CourseCard(
        showPadding: false,
        course: course,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DetailPage(course)),
          );
        },
      ));
    });

    if (availableCourseCount > 0) {
      var avg = total / availableCourseCount;
      list.insert(
          0,
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  Strings.get("average"),
                  style: Theme.of(context).textTheme.title,
                ),
                Text(
                  num2Str(avg) + "%",
                  style: TextStyle(fontSize: 60),
                ),
                LPI.LinearProgressIndicator(
                  animationDuration: 700,
                  lineHeight: 20.0,
                  value1: avg / 100,
                  value1Color: primaryColorOf(context),
                ),
              ],
            ),
          ));
    }

    return Column(
      children: list,
    );
  }
}
