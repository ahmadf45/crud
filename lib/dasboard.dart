import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'calendar_helper.dart';
import 'calendar_model.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Future<List<Calendar>> calendars;
  TextEditingController controller = TextEditingController();
  String name;
  int id;
  DateTime tgl = DateTime.now();
  int tglInt;

  String c1 = '2020-12-03';
  DateTime c2 = DateTime.tryParse('2020-12-03');
  int c3 = DateTime.tryParse(DateFormat('yyyy-MM-dd').format(DateTime.now()))
      .millisecondsSinceEpoch;
  String c4 = DateFormat('yyyy-MM-dd').format(DateTime.now());

  // int now;
  // String substring;
  // String ss =
  //     DateTime.now().millisecondsSinceEpoch.toString().substring(1, 10) + '000';
  // int nnn = int.parse(
  //     DateTime.now().millisecondsSinceEpoch.toString().substring(0, 10) +
  //         '000');
  // DateTime format = DateTime(now.)

  final formKey = new GlobalKey<FormState>();
  var calendarHelper;
  bool isUpdating;

  @override
  void initState() {
    super.initState();
    calendarHelper = CalendarHelper();
    isUpdating = false;
    refreshList();
  }

  refreshList() {
    setState(() {
      calendars = calendarHelper.getCalendars();
    });
  }

  clearName() {
    controller.text = '';
  }

  validate() {
    // if (formKey.currentState.validate()) {
    formKey.currentState.save();
    //   if (isUpdating) {
    //     Calendar e = Calendar(id, name, "${tgl.toLocal()}".split(' ')[0]);
    //     calendarHelper.update(e);
    //     setState(() {
    //       isUpdating = false;
    //     });
    //   } else {
    Calendar e = Calendar(null, name, tglInt);
    calendarHelper.save(e);
    //   }
    clearName();
    refreshList();
    // }
  }

  _pickDate() async {
    final DateTime date = await showDatePicker(
        context: context,
        initialDate: tgl,
        firstDate: DateTime(DateTime.now().year - 5),
        lastDate: DateTime(DateTime.now().year + 5),
        builder: (BuildContext context, Widget child) {
          return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: ColorScheme.dark(
                  primary: Colors.reddd,
                  onPrimary: Colors.white,
                  surface: Colors.tosca,
                  onSurface: Colors.black,
                ),
                dialogBackgroundColor: Colors.white,
              ),
              child: child);
        });

    if (date != null && date != tgl)
      setState(() {
        tgl = date;
        tglInt = date.millisecondsSinceEpoch;
        FocusScope.of(context).requestFocus(new FocusNode());
      });
  }

  form() {
    return Form(
      key: formKey,
      child: Padding(
        padding: EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          verticalDirection: VerticalDirection.down,
          children: <Widget>[
            TextFormField(
              controller: controller,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(labelText: 'Name'),
              validator: (val) => val.length == 0 ? 'Enter Name' : null,
              onSaved: (val) => name = val,
            ),
            ListTile(
              onTap: () => _pickDate(),
              title: Text("${tgl.toLocal()}".split(' ')[0]),
              trailing: Icon(
                Icons.arrow_drop_down,
                size: 28,
              ),
            ),
            Text('to int :' + tglInt.toString()),
            Text('contoh :' + c3.toString()),
            Text('test :' + c4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FlatButton(
                  onPressed: validate,
                  child: Text(isUpdating ? 'UPDATE' : 'ADD'),
                ),
                FlatButton(
                  onPressed: () {
                    setState(() {
                      isUpdating = false;
                    });
                    clearName();
                  },
                  child: Text('CANCEL'),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  SingleChildScrollView dataTable(List<Calendar> calendars) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columns: [
          DataColumn(
            label: Text('ID'),
          ),
          DataColumn(
            label: Text('NAME'),
          ),
          DataColumn(label: Text("TGL")),
          DataColumn(
            label: Text('DELETE'),
          )
        ],
        rows: calendars
            .map(
              (calendar) => DataRow(cells: [
                DataCell(Text(calendar.id.toString())),
                DataCell(
                  Text(calendar.name),
                  onTap: () {
                    setState(() {
                      isUpdating = true;
                      id = calendar.id;
                    });
                    controller.text = calendar.name;
                  },
                ),
                DataCell(Text(
                    "${DateTime.fromMillisecondsSinceEpoch(calendar.tgl)}"
                        .split(' ')[0])),
                DataCell(IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    calendarHelper.delete(calendar.id);
                    refreshList();
                  },
                )),
              ]),
            )
            .toList(),
      ),
    );
  }

  list() {
    return Expanded(
      child: FutureBuilder(
        future: calendars,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return dataTable(snapshot.data);
          }

          if (null == snapshot.data || snapshot.data.length == 0) {
            return Text("No Data Found");
          }

          return CircularProgressIndicator();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [form(), list()],
          ),
        ),
      ),
    );
  }
}
