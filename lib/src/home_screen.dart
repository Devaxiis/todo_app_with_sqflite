import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sqlflite/src/sql_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _jurnals = [];
  bool _isLoading = true;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  void _refreshJournals() async {
    final data = await SqlHelper.getItems();
    setState(() {
      _jurnals = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals();
    log("... number of items: ${_jurnals.length}");
  }

  void _deleteItem(int id) async {
    await SqlHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: const Text("Succesfully deleted.")));
    _refreshJournals();
  }

  Future<void> _addItem() async {
    await SqlHelper.createItem(
        _titleController.text, _descriptionController.text);
    _refreshJournals();
  }

  Future<void> _updateItem(id) async {
    await SqlHelper.updateItem(
        id, _titleController.text, _descriptionController.text);
    _refreshJournals();
  }

  void _showForm(int? id) async {
    if (id != null) {
      final existingJournal =
          _jurnals.firstWhere((element) => element["id"] == id);
      _titleController.text = existingJournal["title"];
      _descriptionController.text = existingJournal["description"];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        builder: (_) {
          return Container(
            padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: "title",
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    hintText: "description",
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () async {
                      if (id == null) {
                        await _addItem();
                      }

                      if (id != null) {
                        await _updateItem(id);
                      }

                      _titleController.text = "";
                      _descriptionController.text = "";

                      Navigator.of(context).pop();
                    },
                    child: Text(
                      id == null ? "Create new" : "Update",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w500),
                    )),
                const SizedBox(height: 20),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SQL"),
        automaticallyImplyLeading: false,
        centerTitle: false,
      ),
      body: SafeArea(
          child: ListView.builder(
              itemCount: _jurnals.length,
              itemBuilder: (_, index) {
                final data = _jurnals[index];
                return Card(
                  color: Colors.amber,
                  margin: const EdgeInsets.all(20),
                  child: SizedBox(
                    height: 100,
                    child: ListTile(
                      leading: Text("${data["id"]}"),
                      title: Text("${data["title"]}"),
                      subtitle: Text("${data["description"]}"),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  _showForm(data["id"]);
                                },
                                icon: const Icon(Icons.edit)),
                            IconButton(
                                onPressed: () {
                                  _deleteItem(data["id"]);
                                },
                                icon: const Icon(Icons.delete)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              })),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showForm(null);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
