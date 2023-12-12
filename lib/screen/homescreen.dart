import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _quantityControler = new TextEditingController();

  List<Map<String, dynamic>> _items = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshItems();
  }

  final _shoppingBox = Hive.box('shopping_box');
  void _refreshItems() {
    final data = _shoppingBox.keys.map((key) {
      final item = _shoppingBox.get(key);
      return {"key": key, "name": item["name"], "quantity": item["quantity"]};
    }).toList();
    setState(() {
      _items = data.reversed.toList();
      print(_items.length);
    });
  }

  Future<void> _createItem(Map<String, dynamic> newItem) async {
    await _shoppingBox.add(newItem);
    print("Amount data is ${_shoppingBox.length}");
    _refreshItems();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Item added")));
  }

  Future<void> _updateItem(int itemKey, Map<String, dynamic> item) async {
    await _shoppingBox.put(itemKey, item);
    print("Amount data is ${_shoppingBox.length}");
    _refreshItems();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Item Updated")));
  }

  Future<void> _deleteItem(int itemKey) async {
    await _shoppingBox.delete(itemKey);
    _refreshItems();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Item Deleted")));
  }

  void _showForm(BuildContext ctx, int? itemKey) async {
    if (itemKey != null) {
      final existingItems =
          _items.firstWhere((element) => element['key'] == itemKey);
      _nameController.text = existingItems['name'];
      _quantityControler.text = existingItems['quantity'];
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
                    controller: _nameController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(hintText: "Name"),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _quantityControler,
                    keyboardType: TextInputType.text,
                    maxLines: 10,
                    decoration: InputDecoration(hintText: "Quantity"),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        if (itemKey == null) {
                          _createItem({
                            "name": _nameController.text,
                            "quantity": _quantityControler.text
                          });
                        }
                        if (itemKey != null) {
                          _updateItem(itemKey, {
                            'name': _nameController.text.trim(),
                            'quantity': _quantityControler.text.trim(),
                          });
                        }
                        _nameController.text = '';
                        _quantityControler.text = '';
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hive Box example"),
      ),
      body: ListView.builder(
          itemCount: _items.length,
          itemBuilder: (_, index) {
            final _currentItem = _items[index];
            return Card(
              color: Colors.orange.shade100,
              margin: EdgeInsets.all(10),
              elevation: 3,
              child: ListTile(
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: () =>
                            _showForm(context, _currentItem["key"]),
                        icon: Icon(Icons.edit)),
                    IconButton(
                        onPressed: () => _deleteItem(_currentItem['key']),
                        icon: Icon(Icons.delete)),
                  ],
                ),
                title: Text(_currentItem["name"]),
                subtitle: Text(_currentItem["quantity"].toString()),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, null),
        child: Icon(Icons.add),
      ),
    );
  }
}
