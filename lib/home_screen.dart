import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_database/models/notes_model.dart';
import 'package:hive_flutter/adapters.dart';

import 'boxes/boxes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Flutter Hive'),
        ),
        body: ValueListenableBuilder<Box<NotesModel>>(
            valueListenable: Boxes.getData().listenable(),
            builder: (context, box, _) {
              var data = box.values.toList().cast<NotesModel>();
              return ListView.builder(
                  reverse: true,
                  shrinkWrap: true,
                  itemCount: box.length,
                  itemBuilder: (context, index) => Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    data[index].title.toString(),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const Spacer(),
                                  InkWell(
                                      onTap: () {
                                        delete(data[index]);
                                      },
                                      child: const Icon(Icons.delete,
                                          color: Colors.red)),
                                  const SizedBox(width: 15),
                                  InkWell(
                                      onTap: () {
                                        _editNotes(
                                          data[index],
                                          data[index].title.toString(),
                                          data[index].description.toString(),
                                        );
                                      },
                                      child: Icon(Icons.edit)),
                                ],
                              ),
                              Text(
                                data[index].description.toString(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ));
            }),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async {
            showDialogAlert();
          },
        ));
  }

  Future<void> showDialogAlert() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Add Notes'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: "Title",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      hintText: "Description",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Icon(Icons.cancel),
              ),
              TextButton(
                onPressed: () {
                  final data = NotesModel(
                      title: titleController.text.toString(),
                      description: descriptionController.text.toString());

                  final box = Boxes.getData();
                  box.add(data);
                  print(box);

                  data.save();

                  titleController.clear();
                  descriptionController.clear();

                  Navigator.pop(context);
                },
                child: const Icon(Icons.add),
              ),
            ],
          );
        });
  }

  void delete(NotesModel notesModel) async {
    await notesModel.delete();
  }

  Future<void> _editNotes(
      NotesModel notesModel, String title, String description) {
    titleController.text = title;
    descriptionController.text = description;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Edit Notes'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: "Title",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      hintText: "Description",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  notesModel.title = titleController.text.toString();

                  notesModel.description =
                      descriptionController.text.toString();

                  notesModel.save();

                  Navigator.pop(context);
                },
                child: const Icon(Icons.cancel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Icon(Icons.add),
              ),
            ],
          );
        });
  }
}
