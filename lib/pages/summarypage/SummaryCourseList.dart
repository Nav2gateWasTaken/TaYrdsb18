import 'package:flutter/material.dart' hide LinearProgressIndicator;
import 'package:ta/model/HiddenCourse.dart';
import 'package:ta/model/Mark.dart';
import 'package:ta/model/User.dart';
import 'package:ta/pages/summarypage/CourseCard.dart';
import 'package:ta/res/Strings.dart';
import 'package:ta/tools.dart';
import 'package:ta/widgets/CrossFade.dart';
import 'package:ta/widgets/LinearProgressIndicator.dart';
import 'package:ta/widgets/WithContextMenu.dart';

class SummaryCourseList extends StatefulWidget {
  @override
  _SummaryCourseListState createState() => _SummaryCourseListState();
}

class _SummaryCourseListState extends State<SummaryCourseList> {
  final List<Course> courses = getCourseListOf(currentUser.number);

  @override
  Widget build(BuildContext context) {
    var list = List<Widget>();

    var total = 0.0;
    var availableCourseCount = 0;
    var hiddenCourseList = HiddenCourse.getAll();

    courses.forEach((course) {
      if (course.overallMark != null) {
        total += course.overallMark;
        availableCourseCount++;
      }

      list.add(CrossFade(
        showFirst: !HiddenCourse.isInList(hiddenCourseList, course),
        firstChild: WithContextMenu(
          menuItems: {
            "Hide this course": () {
              setState(() {
                HiddenCourse.add(course);
              });
              Navigator.pop(context);
            },
          },
          child: CourseCard(
            showPadding: false,
            course: course,
            onTap: () {
              Navigator.pushNamed(
                context,
                "/detail",
                arguments: [course],
              );
            },
          ),
        ),
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
                LinearProgressIndicator(
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
