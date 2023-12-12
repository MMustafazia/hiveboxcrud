import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class HomeScreen2 extends StatefulWidget {
  const HomeScreen2({super.key});

  @override
  State<HomeScreen2> createState() => _HomeScreen2State();
}

class _HomeScreen2State extends State<HomeScreen2> {
  TextEditingController nameController = new TextEditingController();
  TextEditingController rollnoController = new TextEditingController();
  TextEditingController deptController = new TextEditingController();

  final _shoppingBox2 = Hive.box('shopping_box2');
  List<Map<String, dynamic>> _items = [];

  void _refreshItems() {
    final data = _shoppingBox2.keys.map((key) {
      final item = _shoppingBox2.get(key);
      return {
        "key": key,
        "name": item["name"],
        "rollno": item["rollno"],
        "dept": item["dept"]
      };
    }).toList();
    setState(() {
      _items = data.reversed.toList();
      print(_items.length);
    });
  }

  Future<void> _createItem(Map<String, dynamic> newItem) async {
    await _shoppingBox2.add(newItem);
    print("Amount data is ${_shoppingBox2.length}");
    _refreshItems();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Item added")));
  }

  Future<void> _updateItem(int itemKey, Map<String, dynamic> item) async {
    await _shoppingBox2.put(itemKey, item);
    print("Amount data is ${_shoppingBox2.length}");
    _refreshItems();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Item Updated")));
  }

  Future<void> _deleteItem(int itemKey) async {
    await _shoppingBox2.delete(itemKey);
    _refreshItems();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Item Deleted")));
  }

  void _showForm(BuildContext ctx, int? itemKey) async {
    if (itemKey != null) {
      final existingItems =
          _items.firstWhere((element) => element['key'] == itemKey);
      nameController.text = existingItems['name'];
      rollnoController.text = existingItems['rollno'];
      deptController.text = existingItems['dept'];
    }

    showModalBottomSheet(
        context: ctx,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom,
                  top: 15,
                  right: 15,
                  left: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: nameController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(hintText: "Name"),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: rollnoController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(hintText: "Roll No"),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        if (itemKey == null) {
                          _createItem({
                            "name": nameController.text,
                            "rollno": rollnoController.text,
                            "dept": deptController,
                          });
                        }
                        if (itemKey != null) {
                          _updateItem(itemKey, {
                            'name': nameController.text.trim(),
                            'rollno': rollnoController.text.trim(),
                            'dept': deptController.text.trim(),
                          });
                        }
                        nameController.text = '';
                        rollnoController.text = '';
                        deptController.text = '';
                        Navigator.of(context).pop();
                      },
                      child: Text(itemKey == null ? "Create New" : "Update")),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshItems();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
