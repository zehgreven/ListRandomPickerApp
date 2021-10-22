import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: ListRandomPickerApp(),
  ));
}

class ListRandomPickerApp extends StatefulWidget {
  const ListRandomPickerApp({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class Item {
  String value;
  bool picked;

  Item(this.value, this.picked);
}

class _State extends State<ListRandomPickerApp> {
  final List<Item> items = <Item>[
    Item('Alexandre', false),
    Item('Bijit', false),
    Item('Christian', false),
    Item('Daniel', false),
    Item('Fábio', false),
    Item('Israel', false),
    Item('João', false),
    Item('José', false),
    Item('Lionel', false),
    Item('Lucas', false),
    Item('Luiz', false),
    Item('Mark', false),
    Item('Rafael', false),
    Item('Tim', false),
  ];

  TextEditingController nameController = TextEditingController();

  void addItemToList() {
    setState(() {
      items.add(Item(nameController.text, false));
      nameController.clear();
    });
  }

  void clearList() {
    setState(() {
      items.clear();
    });
  }

  bool isItemPicked(value) {
    return items[value].picked;
  }

  bool isThereItemToBePicked() {
    return items.indexWhere((name) => !name.picked) != -1;
  }

  int pickNextRandomValidInt() {
    var value = Random().nextInt(items.length);
    if (isItemPicked(value)) {
      value = pickNextRandomValidInt();
    }
    return value;
  }

  void markItemAsPickedByIndex(int index) {
    setState(() {
      items[index].picked = true;
    });
  }

  void presentValue(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  void pickRandomValueAndMarkAsPickedAndPresentIt() {
    var value = 'No items are available to be picked';

    if (isThereItemToBePicked()) {
      var index = pickNextRandomValidInt();
      markItemAsPickedByIndex(index);
      value = items[index].value;
    }

    presentValue(value);
  }

  void resetPickedList() {
    for (var item in items) {
      setState(() {
        item.picked = false;
      });
    }
    presentValue('All the items have been restored to a "not picked" state.');
  }

  Future<String> showDialogMessage(
    BuildContext context,
    String description,
    {
      String title = 'Alert',
      bool showOk = true,
      bool showCancel = false,
      String cancel = 'Cancel',
      String ok = 'OK',
    }
  ) async {
    var result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(description),
        actions: <Widget>[
          showCancel
              ? TextButton(
                  onPressed: () => Navigator.pop(context, cancel),
                  child: Text(cancel),
                )
              : Container(),
          showOk
              ? TextButton(
                  onPressed: () => Navigator.pop(context, ok),
                  child: Text(ok),
                )
              : Container(),
        ],
      ),
    );
    return result.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('List - Random Picker'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FloatingActionButton(
                child: const Icon(Icons.restore),
                onPressed: () async {
                  String result = await showDialogMessage(context,
                      'Do you want to restore all the items to a "not picked" state?',
                      showCancel: true);
                  if (result == 'OK') {
                    resetPickedList();
                  } else {
                    presentValue('Action canceled');
                  }
                },
              ),
              FloatingActionButton(
                child: const Icon(Icons.check),
                onPressed: () {
                  pickRandomValueAndMarkAsPickedAndPresentIt();
                },
              ),
            ],
          ),
        ),
        body: Column(children: <Widget>[
          Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'New Item',
                    ),
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 40,
                          child: ElevatedButton(
                            child: const Text('Clear List'),
                            onPressed: () {
                              clearList();
                            },
                          ),
                        ),
                        const Spacer(
                          flex: 10,
                        ),
                        Expanded(
                          flex: 40,
                          child: ElevatedButton(
                            child: const Text('Add'),
                            onPressed: () {
                              addItemToList();
                            },
                          ),
                        ),
                      ]),
                ],
              )),
          Expanded(
              child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      height: 50,
                      margin: const EdgeInsets.all(2),
                      color:
                          isItemPicked(index) ? Colors.grey : Colors.blue[100],
                      child: Center(
                          child: Text(items[index].value,
                              style: const TextStyle(fontSize: 18))),
                    );
                  }))
        ]));
  }
}
