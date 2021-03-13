import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// class MatchableLists extends StatefulWidget {
//   final List<Widget> leftList, rightList;
//   MatchableLists({this.leftList, this.rightList})
//       : assert(leftList.length == rightList.length,
//             'Given lists have different lengths');
//   _MatchableListsState createState() => _MatchableListsState();
// }

// class _MatchableListsState extends State<MatchableLists> {
//   @override
//   void initState() {}

//   @override
//   Widget build(BuildContext context) {
//     return GridView.count(
//         primary: false,
//         crossAxisCount: 2,
//         crossAxisSpacing: 0,
//         mainAxisSpacing: 0,
//         children: [
//           for (int i = 0; i < widget.leftList.length * 2; i++)
//             i.isEven
//                 ? widget.leftList[(i / 2).floor()]
//                 : widget.rightList[(i / 2).floor()]
//         ]);
//   }
// }
