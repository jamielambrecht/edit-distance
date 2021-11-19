// Author: Jamie Lambrecht, CWID (Last 4 digits): 1558
// Programming Project for CPSC 485-01 @ CSUF Fall Semester 2021
// Professor: Dr. Shawn X. Wang

// This code is free software licensed under GPLv2.
// See COPYING file for details.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum EditType { insert, delete, replace }

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edit Distance',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const MyHomePage(title: 'Calculate Edit Distance'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// ============= PRIMARY LOGIC FOR EDIT DISTANCE ALGORITHMS ============= //
class _MyHomePageState extends State<MyHomePage> {
  // Here we are declaring UI elements, text box controllers, etc.
  final field1Controller = TextEditingController();
  final field2Controller = TextEditingController();

  Text wordEntryFormsTitle = const Text(
      'Please enter two words in order to find the edit distance: ',
      style: TextStyle(fontWeight: FontWeight.bold));

  Text editDistanceTableTitle = const Text("");
  Table editDistanceTable = Table();
  Text alignmentTableTitle = const Text("");
  Table alignmentTable = Table();

  // This is a destructor for the forms
  @override
  void dispose() {
    field1Controller.dispose();
    field2Controller.dispose();
    super.dispose();
  }

  // This is the primary "business logic"
  void _calcEditDistance() {
    // This extracts the strings from the input forms
    String s = field1Controller.text;
    String t = field2Controller.text;

    // Initialize table columns / lists of rows
    List<TableRow> rows = [];
    List<TableRow> alignmentRows = [];

    // The following two subroutines build table cells
    // The edit distance table cell builders have a flag for highlighting
    // the critical path and a specified background color
    TableCell makeTableCell(Text textContent,
        {bool highlight = false, Color bg_color = Colors.blue}) {
      return TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Container(
            padding: const EdgeInsets.all(10),
            child: Center(child: textContent),
            color: highlight ? bg_color : null),
      );
    }

    // The alignment display is a table with no border lines
    TableCell makeAlignmentTableCell(Text textContent) {
      return TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Center(child: textContent),
        ),
      );
    }

    // This function is ran when the main page is redrawn. It is automatically
    // called when the containing function is called by pressing the button
    setState(() {
      // Delete UI elements if there is null input
      if (s.isEmpty || t.isEmpty) {
        editDistanceTable = Table();
        alignmentTable = Table();
        editDistanceTableTitle = const Text("");
        alignmentTableTitle = const Text("");
        return;
      } else {
        editDistanceTableTitle = const Text('Dynamic Table for Edit Distance: ',
            style: TextStyle(fontWeight: FontWeight.bold));
        alignmentTableTitle = const Text('Alignment: ',
            style: TextStyle(fontWeight: FontWeight.bold));
      }

      // Set length and width of matrices based on input sizes
      var m = s.length + 1, n = t.length + 1;

      // Initialize table with 0, 1, 2, 3... for first row and column, else 0.
      List<List<int>> _matrix = List<List<int>>.generate(
          m, (i) => List<int>.generate(n, (j) => i == 0 || j == 0 ? i + j : 0));

      // This matrix stores the choice made at each table for the purpose of
      // backtracking when creating the alignment display
      // It would have been nice to include this in a tuple or struct in the
      // original matrix, but this was added afterward, and the way the
      // matrix is initialized would be greatly complicated by combining
      // the two.
      List<List<EditType>> edit_matrix = List<List<EditType>>.generate(
          m,
          (i) => List<EditType>.generate(
              n,
              (j) => i == 0
                  ? EditType.insert
                  : j == 0
                      ? EditType.delete
                      : EditType.replace));

      // This is the common levenshtein distance algorithm
      // There is added logic to store the "EditType" for backtracking
      for (int j = 1; j < n; j++) {
        for (int i = 1; i < m; i++) {
          // Set the substitution cost based on whether the characters match
          int subCost = s[i - 1] != t[j - 1] ? 1 : 0;
          // Find the minimum total cost of the three operations
          var editNodes = {
            EditType.delete: _matrix[i - 1][j] + 1,
            EditType.insert: _matrix[i][j - 1] + 1,
            EditType.replace: _matrix[i - 1][j - 1] + subCost
          };

          var minimumNode = editNodes.entries.first;
          for (var node in editNodes.entries) {
            if (node.value < minimumNode.value) {
              minimumNode = node;
            }
          }

          _matrix[i][j] = minimumNode.value;
          edit_matrix[i][j] = minimumNode.key;

          // _matrix[i][j] = min(_matrix[i - 1][j] + 1, _matrix[i][j - 1] + 1);
          // _matrix[i][j] = min(_matrix[i][j], _matrix[i - 1][j - 1] + subCost);
        }
      }

      // This will store a list of index pairs used for backtracking
      List<List<int>> criticalPathIndices = [];

      // These are the two rows of the alignment table
      List<TableCell> align_s = [];
      List<TableCell> align_t = [];
      // The following code is the backtracking algorithm
      // It uses the choices made from the bottom right cell to backtrack
      // through the optimal path and store indices for each cell visited
      // It also create the alignment table based on the choices made
      {
        double? fontSize = 24;
        int i = m - 1;
        int j = n - 1;
        while (i > 0 || j > 0) {
          criticalPathIndices.add([i + 1, j + 1]);
          switch (edit_matrix[i][j]) {
            case EditType.replace:
              // Diagonal case: store both string elements. Decrement i and j.
              {
                MaterialColor textColor = Colors.red;
                // When the chars are equal, color green instead of red
                if (_matrix[i][j] == _matrix[i - 1][j - 1]) {
                  textColor = Colors.green;
                }
                align_s.insert(
                    0,
                    makeAlignmentTableCell(Text(s[i - 1],
                        style:
                            TextStyle(color: textColor, fontSize: fontSize))));
                align_t.insert(
                    0,
                    makeAlignmentTableCell(Text(t[j - 1],
                        style:
                            TextStyle(color: textColor, fontSize: fontSize))));
                i--;
                j--;
              }
              break;
            case EditType.delete:
              // horizontal case: store a _ across from the deleted character
              // decrement i
              {
                align_s.insert(
                    0,
                    makeAlignmentTableCell(
                        Text(s[i - 1], style: TextStyle(fontSize: fontSize))));
                align_t.insert(
                    0,
                    makeAlignmentTableCell(
                        Text("_", style: TextStyle(fontSize: fontSize))));
                i--;
                // j--;
              }
              break;
            case EditType.insert:
              {
                // vertical case: store a _ across from the inserted character
                // decrement j
                align_s.insert(
                    0,
                    makeAlignmentTableCell(
                        Text("_", style: TextStyle(fontSize: fontSize))));
                align_t.insert(
                    0,
                    makeAlignmentTableCell(
                        Text(t[j - 1], style: TextStyle(fontSize: fontSize))));
                // i--;
                j--;
              }
              break;
          }
        }
      }

      // Instantiate the overall table for aligment using the above data
      alignmentRows.add(TableRow(children: align_s));
      alignmentRows.add(TableRow(children: align_t));

      alignmentTable = Table(
          children: alignmentRows,
          defaultColumnWidth: const FixedColumnWidth(48));

      // This is the logic to build the actual edit distance table
      for (int j = 0; j < n + 1; j++) {
        List<TableCell> rowCells = [];
        for (int i = 0; i < m + 1; i++) {
          if (j == 0) {
            // This is the column with the letters of string s
            if (i > 1) {
              rowCells.add(makeTableCell(Text(s[i - 2],
                  style: TextStyle(fontWeight: FontWeight.bold))));
            } else {
              rowCells.add(makeTableCell(Text("")));
            }
          } else {
            // This creates the cells with numbers in the body of the table
            // The bulk of the code text is for highlighting the path taken
            if (i > 0) {
              List<int> currentIndices = [i, j];
              // Determine whether the current indices were stored by the
              // backtracking algorithm
              bool isCritical =
                  criticalPathIndices.any((e) => listEquals(e, currentIndices));
              if (i == 1 && j == 1) isCritical = true;
              Color bgColor = Colors.blue;
              // Collor the bottom right/final answer green instead of blue
              if (i == m && j == n) {
                bgColor = Colors.green;
              }
              FontWeight? fontWeight =
                  (i == m && j == n) ? FontWeight.bold : null;
              // This is where the cell is built with the number text
              rowCells.add(makeTableCell(
                  Text(_matrix[i - 1][j - 1].toString(),
                      style: TextStyle(fontWeight: fontWeight)),
                  highlight: isCritical,
                  bg_color: bgColor));
            } else {
              // This is the row with the letters of string t
              if (j > 1) {
                rowCells.add(makeTableCell(Text(t[j - 2],
                    style: TextStyle(fontWeight: FontWeight.bold))));
              } else {
                rowCells.add(makeTableCell(Text("")));
              }
            }
          }
        }
        rows.add(TableRow(children: rowCells));
      }

      // Instantiate the table with the data calculated above
      editDistanceTable = Table(
          children: rows,
          defaultColumnWidth: const FixedColumnWidth(48),
          border: TableBorder.all());
    });
  }

  // This build function determines the layout of the UI
  // The calculation function is called by the floating button at the bottom
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              wordEntryFormsTitle,
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 240.0,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Enter the first term',
                        ),
                        controller: field1Controller,
                      ),
                    ),
                  ),
                  Container(
                    width: 240.0,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Enter the second term',
                        ),
                        controller: field2Controller,
                      ),
                    ),
                  ),
                ],
              ),
              editDistanceTableTitle,
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: editDistanceTable),
              alignmentTableTitle,
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: alignmentTable),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _calcEditDistance,
        tooltip: 'Calculate Edit Distance',
        child: const Icon(Icons.forward),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
