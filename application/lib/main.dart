import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'api_service.dart';

final ApiService apiService = ApiService(backendUrl: 'http://79.76.53.111:8002/identify');

void main() {
  runApp(ChangeNotifierProvider(create: (context) => UserData(), child: const MaterialApp(home: PlantListView())));
}

class UserPlantData {
  final int id;
  final String name;
  final Image image;
  final DateTime dateAdded;
  String notes;

  UserPlantData({required this.id, required this.name, required this.image, required this.dateAdded, required this.notes});
}

class UserData extends ChangeNotifier {
  final List<UserPlantData> _items = [];
  int itemCount = 0;

  List<UserPlantData> get items => _items;

  void addPlant(UserPlantData itemID) {
    _items.add(itemID);
    itemCount++;
    notifyListeners();
  }

  void removePlant(UserPlantData itemID) {
    _items.remove(itemID);
    if (itemCount > 0) {
      itemCount--;
    }
    notifyListeners();
  }

  void updateDescription(UserPlantData itemID, String note) {
    itemID.notes = note;
    notifyListeners();
  }
}

class PlantListView extends StatefulWidget {
  const PlantListView({super.key});

  @override
  PlantListViewState createState() => PlantListViewState();
}
// 0 for list view, 1 for add camera view
//PlantListView({super.key});

class PlantListViewState extends State<PlantListView> {
  int _activePageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plant Photo App 🌱')),
        body: Builder(
          builder: (context) {
            switch (_activePageIndex) {
              // ----------[LIST PAGE]------------
              case 0:
                return ListView.builder(
                  itemCount: userData.items.length,
                  itemBuilder: (context, index) {
                    final plant = userData.items[index];
                    // Format the raw timestamp into a more friendly format
                    final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(plant.dateAdded);
                    return ListTile(
                      title: Text(plant.name),
                      subtitle: Text(formattedDate),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => PlantDetailView(plant: plant)));
                      },
                    );
                  },
                );
              // -----------[SETTINGS PAGE]------------
              case 1:
                return const Scaffold(body: Center(child: Text('Settings')));
              // ----------[PROFILE PAGE]------------
              case 2:
                return Scaffold(
                  body: Column(
                    children: [
                      Center(
                        child: Container(
                          margin: const EdgeInsets.all(16.0),
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(color: Colors.transparent, border: Border.all(color: Colors.black)),
                          child: const Icon(Icons.person, size: 128),
                        ),
                      ),
                      const Center(child: Text('[Username]', style: TextStyle(fontSize: 24.0))),
                    ],
                  ),
                );
              default:
                return const Scaffold();
            }
          },
        ),
        floatingActionButton:
            (_activePageIndex == 0)
                ? FloatingActionButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPlantView()));
                  },
                  child: const Icon(Icons.add),
                )
                : null,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _activePageIndex,
          onTap: (index) {
            setState(() {
              _activePageIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Notes'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class PlantDetailView extends StatelessWidget {
  final UserPlantData plant;

  const PlantDetailView({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    final TextEditingController descriptionController = TextEditingController(text: plant.notes);

    void updateDescription(String newDescription) {
      final userData = Provider.of<UserData>(context, listen: false);
      userData.updateDescription(plant, newDescription);
    }

    return Scaffold(
      appBar: AppBar(title: Text(plant.name)),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.height / 2.0,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                /*
								*   Placeholder for the actual picture taken by the user.
								*/
                image: const DecorationImage(image: AssetImage('placeholders/plant_placeholder.jpg'), fit: BoxFit.fill),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: Container(
                alignment: Alignment.center,
                //margin: const EdgeInsets.symmetric(horizontal: 32.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.black),
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                ),
                child: TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Plant Notes'),
                  maxLines: null,
                  expands: true,
                  onSubmitted: updateDescription,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  updateDescription(descriptionController.text);
                },
                child: const Icon(Icons.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddPlantView extends StatelessWidget {
  const AddPlantView({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController notesController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Add Plant')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image Taken!'), duration: Duration(seconds: 1)));
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take a photo'),
              ),
            ),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () async {
                  // 1. load image asset as bytes
                  final byteData = await rootBundle.load('placeholders/runner_bean.jpg');
                  // 2. write bytes to temp file
                  final imageFile = await File('${Directory.systemTemp.path}/runner_bean.jpg').writeAsBytes(byteData.buffer.asUint8List(), flush: true);
                  // 3. call API with temp file

                  apiService
                      .sendImage(imageFile)
                      .then((response) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('API Response: $response')));
                        }
                      })
                      .catchError((error) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('API Error: $error')));
                        }
                      });
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Identify Plant'),
              ),
            ),
            TextField(decoration: const InputDecoration(labelText: 'Plant Name'), controller: nameController),
            const SizedBox(height: 16),
            TextField(decoration: const InputDecoration(labelText: 'Notes'), controller: notesController),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Provider.of<UserData>(context, listen: false).addPlant(
                  UserPlantData(
                    id: Provider.of<UserData>(context, listen: false).itemCount,
                    name: nameController.text,
                    image: Image.asset('assets/plant.jpg'),
                    dateAdded: DateTime.now(),
                    notes: notesController.text,
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Add Plant'),
            ),
            //const SnackBar(content: Text('Image Taken!'))
          ],
        ),
      ),
    );
  }
}
