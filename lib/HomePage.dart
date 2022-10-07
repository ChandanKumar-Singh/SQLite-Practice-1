import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:first_sqlite_app/database_helper.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _desController = TextEditingController();
  var myItems = [];

  String? validateForm(String? val) {
    if (val!.isEmpty) return 'Field is Required';
    return null;
  }

  Future<void> addItem() async {
    await DatabaseHelper.createItem(_titleController.text, _desController.text);
    _refreshData();
  }

  Future<void> updateItem(int id) async {
    await DatabaseHelper.updateItem(
        id, _titleController.text, _desController.text);
    _refreshData();
  }

  Future<void> deleteItem(int id) async {
    await DatabaseHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('successfully deleted!'),
      backgroundColor: Colors.green,
    ));
    _refreshData();
  }

  _refreshData() async {
    var data = await DatabaseHelper.getItems();
    setState(() {
      myItems = data;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQLite Example'),
      ),
      body: myItems.isEmpty
          ? const Center(
              child: Text('No Data Available!!!'),
            )
          : ListView.builder(
              itemCount: myItems.length,
              itemBuilder: (context, i) {
                return Card(
                  color: i % 2 == 0 ? Colors.grey[300] : Colors.yellow[100],
                  margin: const EdgeInsets.all(15),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              myItems[i]['title'],
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Row(
                        children: [
                          Expanded(
                            child: Text(
                              myItems[i]['description'],
                              maxLines: 2,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ],
                      ),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: () {
                                showMyForm(id: myItems[i]['id']);
                              },
                              icon: const Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: () {
                                AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.warning,
                                        headerAnimationLoop: true,
                                        animType: AnimType.bottomSlide,
                                        title:
                                            'Are you sure to delete this item?',
                                        reverseBtnOrder: false,
                                        btnCancelOnPress: () {
                                          // Navigator.pop(context);
                                        },
                                        btnOkOnPress: () async {
                                          await deleteItem(myItems[i]['id']);
                                        },
                                        desc: 'Item will be deleted forever.')
                                    .show();
                              },
                              icon: const Icon(Icons.delete),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showMyForm();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void showMyForm({int? id}) async {
    if (id != null) {
      final existingData = myItems.firstWhere((element) => element['id'] == id);
      // setState(() {
      _titleController.text = existingData['title'];
      _desController.text = existingData['description'];
      print(id);
      print(_titleController.text);
      print(_desController.text);

      // });
    } else {
      _titleController.clear();
      _desController.clear();
    }
    showModalBottomSheet(
        context: context,
        elevation: 5,
        isDismissible: false,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: const BorderRadius.only(
          topLeft: const Radius.circular(15),
          topRight: Radius.circular(15),
        )),
        builder: (context) {
          return BottomSheet(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(15),
              topRight: const Radius.circular(15),
            )),
            builder: (context) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.6,
                decoration: const BoxDecoration(
                    // borderRadius: BorderRadius.circular(15),
                    ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Form(
                          key: formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                validator: validateForm,
                                controller: _titleController,
                                decoration:
                                    const InputDecoration(hintText: 'Title'),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                validator: validateForm,
                                controller: _desController,
                                decoration: const InputDecoration(
                                    hintText: 'Description'),
                                maxLines: 5,
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  RaisedButton(
                                    color: Colors.red,
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  RaisedButton(
                                    color: Colors.blue,
                                    onPressed: () async {
                                      if (formKey.currentState!.validate()) {
                                        id != null
                                            ? await updateItem(id)
                                            : await addItem();
                                        setState(() {
                                          _titleController.clear();
                                          _desController.clear();
                                        });
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: Text(
                                      id != null ? 'Update' : 'Add Item',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            onClosing: () {},
          );
        });
  }
}
