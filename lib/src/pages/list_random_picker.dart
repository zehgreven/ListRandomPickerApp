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

  TextEditingController itemValueController = TextEditingController();

  void addItem(String value) {
    setState(() {
      items.add(Item(value, false));
      itemValueController.clear();
    });
  }

  void removeItemByIndex(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  void clearItems() {
    setState(() {
      items.clear();
    });
  }

  bool isItemPicked(value) {
    return items[value].picked;
  }

  bool existItemsToBePicked() {
    return items.any((item) => !item.picked);
  }

  int pickNextRandomValidInt() {
    var value = Random().nextInt(items.length);
    if (isItemPicked(value)) {
      value = pickNextRandomValidInt();
    }
    return value;
  }

  int pickRandomValue() {
    if (existItemsToBePicked()) {
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

  void resetPickedItems() {
    for (var item in items) {
      setState(() {
        item.picked = false;
      });
    }
  }

  bool isValueDuplicated(String value) {
    return items.any((item) => item.value == value);
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
                    resetPickedItems();
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
                    controller: itemValueController,
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
                              clearItems();
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
                              String value = itemValueController.text;
                              if (value.isEmpty) {
                                showDialogMessage(context,
                                    'Please, provide a valid value to be added.');
                                return;
                              }

                              if (isValueDuplicated(value)) {
                                showDialogMessage(context,
                                    'The value is already in the list, please provide a not duplicated one.');
                                return;
                              }

                              addItem(value);
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
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.all(2),
                      color:
                          isItemPicked(index) ? Colors.grey : Colors.blue[100],
                      child: ListTile(
                        title: Text(items[index].value,
                            style: const TextStyle(fontSize: 18)),
                        onLongPress: () async {
                          bool result = await showDialogMessage(context,
                              'Do you want to remove the value "${items[index].value}" from the list?',
                              showCancel: true,
                              cancel: 'No',
                              ok: 'Yes, remove');
                          if (result) {
                            removeItemByIndex(index);
                          }
                        },
                      ),
                    );
                  }))
        ]));
  }
}
