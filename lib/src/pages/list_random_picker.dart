import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:listrandompicker/src/constants/data.dart';
import 'package:listrandompicker/src/model/item.dart';

class ListRandomPickerApp extends StatefulWidget {
  const ListRandomPickerApp({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<ListRandomPickerApp> {
  final List<Item> items = defaultItems;

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

  int pickRandomValue() {
    if (isThereItemToBePicked()) {
      return pickNextRandomValidInt();
    }

    return -1;
  }

  void markItemAsPickedByIndex(int index) {
    setState(() {
      items[index].picked = true;
    });
  }

  void showSnackBarMessage(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  void resetPickedList() {
    for (var item in items) {
      setState(() {
        item.picked = false;
      });
    }
  }

  Future<bool> showDialogMessage(
    BuildContext context,
    String description, {
    String title = 'Alert',
    bool showOk = true,
    bool showCancel = false,
    String cancel = 'Cancel',
    String ok = 'OK',
  }) async {
    var result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(description),
        actions: <Widget>[
          showCancel
              ? TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(cancel),
                )
              : Container(),
          showOk
              ? TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(ok),
                )
              : Container(),
        ],
      ),
    );

    return result != null && result;
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
                  bool result = await showDialogMessage(context,
                      'Do you want to restore all the items to a "not picked" state?',
                      showCancel: true);
                  if (result) {
                    resetPickedList();
                    showSnackBarMessage(
                        'All the items have been restored to a "not picked" state.');
                  }
                },
              ),
              FloatingActionButton(
                child: const Icon(Icons.check),
                onPressed: () async {
                  int index = pickRandomValue();
                  if (index == -1) {
                    return showSnackBarMessage(
                        'The list is empty or it has no items to be picked.');
                  }
                  bool result = await showDialogMessage(
                    context,
                    'Just picked "${items[index].value}"',
                    showCancel: true,
                    cancel: 'Keep',
                    ok: 'Mark as picked',
                  );

                  if (result) {
                    markItemAsPickedByIndex(index);
                  }
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
