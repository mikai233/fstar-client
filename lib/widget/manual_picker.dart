import 'package:flutter/material.dart';

class ManualPicker extends StatefulWidget {
  ManualPicker(this.dialogSemesters, this.courses, this.selected, {Key key})
      : super(key: key);
  final List<String> dialogSemesters;
  final Map<String, Set<String>> courses;
  final Map<String, List<bool>> selected;

  @override
  State createState() => _ManualPickerState();
}

class _ManualPickerState extends State<ManualPicker>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<String> _dialogSemesters;
  Map<String, Set<String>> courseMap;
  Map<String, List<bool>> _selected;

  @override
  void initState() {
    super.initState();
    _dialogSemesters = widget.dialogSemesters;
    courseMap = widget.courses;
    _selected = widget.selected;
    _tabController =
        TabController(length: _dialogSemesters.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TabBar(
            isScrollable: true,
            tabs: _dialogSemesters
                .map(
                  (semester) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      semester,
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                )
                .toList(),
            controller: _tabController,
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _dialogSemesters
                .map(
                  (semester) => ListView.builder(
                    itemBuilder: (BuildContext context, int index) {
                      return CheckboxListTile(
                        title: Text(courseMap[semester].elementAt(index)),
                        value: _selected[semester][index],
                        onChanged: (bool value) {
                          setState(() {
                            _selected[semester][index] =
                                !_selected[semester][index];
                          });
                        },
                      );
                    },
                    itemCount: courseMap[semester].length,
                  ),
                )
                .toList(),
          ),
        ),
//        Container(
//          height: 48,
//          child: SizedBox.expand(
//            child: RaisedButton(
//              child: Text('确定'),
//              onPressed: () {
//                Navigator.of(context).pop();
//              },
//            ),
//          ),
//        )
      ],
    );
  }
}
