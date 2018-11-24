import 'package:flutter/material.dart';


Widget buildCardGridview(BuildContext context, List<String> paths, Function cardTypeClosure) {
  return Container(
    padding: EdgeInsets.all(8.0),
    child: GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: MediaQuery.of(context).size.width*0.8, childAspectRatio: 0.72),
      itemCount: paths.length,
      itemBuilder: (context, i) {
        return cardTypeClosure(paths[i]);
      },
    )
  );
}