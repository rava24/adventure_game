import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(MaterialApp(
  title: 'Choose Your Adventure Game',
  home: AdventureGame(),
));

class AdventureGame extends StatefulWidget {
  @override
  _AdventureGameState createState() => _AdventureGameState();
}

class _AdventureGameState extends State<AdventureGame> {
  int _currentRoom = 1; // Starting in the hallway
  List<String> collectedItems = [];
  int trapRoom = 0; // Variable to store the trap room

  Map<int, Map<String, dynamic>> rooms = {
    1: {
      'description': 'You are in a hallway. There are doors to the north and south.',
      'exits': {'north': 2, 'south': 3},
      'item': 'None', // Hallway initially has no item
    },
    2: {
      'description': 'You are in a bedroom. There is a door to the south.',
      'exits': {'south': 1},
      'item': 'Gun',
    },
    3: {
      'description': 'You are in a kitchen. There is a door to the north.',
      'exits': {'north': 1},
      'item': 'Smartphone',
    },
    4: {
      'description': 'You are in a garden. There are doors to the north and east.',
      'exits': {'north': 5, 'east': 6},
      'item': 'Money',
    },
    5: {
      'description': 'You are in a library. There is a door to the south.',
      'exits': {'south': 4},
      'item': 'Laptop',
    },
    6: {
      'description': 'You are in a secret room. There is a door to the west.',
      'exits': {'west': 4},
      'item': 'None', // No item in this room initially
    },
    7: {
      'description': 'You entered the exit room! Congratulations!',
      'exits': {}, // No exits, it's the exit room.
      'winCondition': true,
    },
  };

  int generateRandomRoom() {
    Random random = Random();
    return random.nextInt(rooms.length) + 1; // Generate a random room number
  }

  void setTrapRoom() {
    trapRoom = generateRandomRoom(); // Set one room as a trap when the game starts
    rooms[trapRoom]!['trap'] = true;
  }

  @override
  void initState() {
    super.initState();
    setTrapRoom();
  }

  void _move(String direction) {
    setState(() {
      if (rooms.containsKey(_currentRoom) && rooms[_currentRoom]!['exits']!.containsKey(direction)) {
        int? nextRoom = rooms[_currentRoom]!['exits']![direction];

        if (nextRoom != null) {
          if (nextRoom == trapRoom) {
            _currentRoom = -1; // Game over, trapped
          } else {
            _currentRoom = nextRoom;
          }

          if (rooms[nextRoom]!['winCondition'] == true &&
              collectedItems.length >= 4 &&
              _currentRoom != 7) {
            _currentRoom = -2; // Win condition met
          }
        }
      }
    });
  }

  void _exitGame() {
    setState(() {
      _currentRoom = -1; // Exit game without winning
    });
  }

  void _pickUpItem() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pick Up Item'),
          content: Text('Do you want to pick up the item in this room?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                String? currentItem = rooms[_currentRoom]!['item'];
                if (currentItem != null && !collectedItems.contains(currentItem) && currentItem != 'None') {
                  collectedItems.add(currentItem);
                  rooms[_currentRoom]!.remove('item'); // Remove picked-up item from the room
                }
                setState(() {}); // To update the UI after item collection
                Navigator.of(context).pop();
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Your Adventure Game'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              _currentRoom == -2
                  ? 'Congratulations! You Won!'
                  : _currentRoom == -1
                  ? 'Game Over'
                  : 'Room $_currentRoom:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              _currentRoom >= 0 && rooms.containsKey(_currentRoom)
                  ? rooms[_currentRoom]!['description']
                  : _currentRoom == -2
                  ? 'You found the exit room and collected all items. You Win!'
                  : _currentRoom == -1
                  ? 'Oops! You triggered a trap. Better luck next time!'
                  : 'This room has no description.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            if (_currentRoom != -1 && _currentRoom != -2)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  if (rooms.containsKey(_currentRoom) && rooms[_currentRoom]!['exits'] != null)
                    if (rooms[_currentRoom]!['exits']!.containsKey('north'))
                      ElevatedButton(
                        onPressed: () {
                          _move('north');
                        },
                        child: Text('North'),
                      ),
                  if (rooms.containsKey(_currentRoom) && rooms[_currentRoom]!['exits'] != null)
                    if (rooms[_currentRoom]!['exits']!.containsKey('south'))
                      ElevatedButton(
                        onPressed: () {
                          _move('south');
                        },
                        child: Text('South'),
                      ),
                  if (rooms.containsKey(_currentRoom) && rooms[_currentRoom]!['exits'] != null)
                    if (rooms[_currentRoom]!['exits']!.containsKey('east'))
                      ElevatedButton(
                        onPressed: () {
                          _move('east');
                        },
                        child: Text('East'),
                      ),
                  if (rooms.containsKey(_currentRoom) && rooms[_currentRoom]!['exits'] != null)
                    if (rooms[_currentRoom]!['exits']!.containsKey('west'))
                      ElevatedButton(
                        onPressed: () {
                          _move('west');
                        },
                        child: Text('West'),
                      ),
                ],
              ),
            SizedBox(height: 20),
            if (_currentRoom != -1 && _currentRoom != -2)
              ElevatedButton(
                onPressed: _pickUpItem,
                child: Text('Pick Up Item'),
              ),
            SizedBox(height: 20),
            if (_currentRoom != -2)
              ElevatedButton(
                onPressed: _exitGame,
                child: Text('Exit Game'),
              ),
            SizedBox(height: 20),
            if (collectedItems.isNotEmpty)
              Text(
                'Collected Items: ${collectedItems.join(", ")}',
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
          ],
        ),
      ),
    );
  }
}
