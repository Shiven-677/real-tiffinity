import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.title, //send the title
  });

  final String title;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController controller = TextEditingController();
  bool? isChecked = false;
  bool isSwitched = false;
  double sliderValue = 0.0;
  String? dropdownValue = 'e1'; //default value for dropdown

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title), //title
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context); //go back to previous page
          },
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: Duration(seconds: 2), //snackbar duration
                      behavior: SnackBarBehavior.floating,
                      content: Text("Hello"), //display snackbar
                    ),
                  );
                },
                child: Text("Open Snackbar"),
              ),

              Divider(
                color: Colors.teal,
                thickness: 2, //divider color and thickness
              ),

              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Alert Title"),
                        content: Text("Alert Content"), //dialog content
                        actions: [
                          FilledButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('close'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text("Open Dialog"),
              ),

              DropdownButton(
                value: dropdownValue,
                items: [
                  DropdownMenuItem(value: 'e1', child: Text("Elemen1")), //i1
                  DropdownMenuItem(value: 'e2', child: Text("Elemen2")), //i2
                  DropdownMenuItem(value: 'e3', child: Text("Elemen3")), //i3
                ],
                onChanged: (String? value) {
                  setState(() {
                    dropdownValue = value; //update the state
                  });
                },
              ),

              TextField(
                controller: controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(), //bs
                ),
                onEditingComplete: () {
                  setState(() {});
                },
              ),

              TextField(
                controller: controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(), //bs
                ),
                onEditingComplete: () {
                  setState(() {});
                },
              ),

              Text(controller.text), //display the text

              Checkbox(
                value: isChecked,
                onChanged: (bool? value) {
                  setState(() {
                    isChecked = value; //update the state
                  });
                },
              ),

              CheckboxListTile(
                value: isChecked,
                title: Text("Click me"),
                onChanged: (bool? value) {
                  setState(() {
                    isChecked = value; //update the state
                  });
                },
              ),

              Switch(
                value: isSwitched,
                onChanged: (bool value) {
                  setState(() {
                    isSwitched = value; //update the state
                  });
                },
              ),

              SwitchListTile(
                title: Text("Switch me"),
                value: isSwitched,
                onChanged: (bool value) {
                  setState(() {
                    isSwitched = value; //update the state
                  });
                },
              ),

              Slider(
                value: sliderValue,
                max: 10,
                divisions: 10,
                onChanged: (value) {
                  setState(() {
                    sliderValue = value;
                  });
                },
              ),

              InkWell(
                child: Container(
                  height: 50,
                  width: double.infinity,
                  color: Colors.white12,
                ),
                onTap: () {
                  print("Image tapped");
                },
              ),

              ElevatedButton(
                onPressed: () {}, //logic
                child: Text("Submit"),
              ),

              FilledButton(
                onPressed: () {}, //logic
                child: Text("Submit"),
              ),

              TextButton(
                onPressed: () {}, //logic
                child: Text("Submit"),
              ),

              OutlinedButton(
                onPressed: () {}, //logic
                child: Text("Submit"),
              ),

              CloseButton(),
              BackButton(),
            ],
          ),
        ),
      ),
    );
  }
}
