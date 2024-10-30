import 'package:flutter/material.dart';
import 'dart:async';

// Main widget for the Chess Clock screen
class ChessHome extends StatefulWidget {
  const ChessHome({super.key});

  @override
  ChessHomeState createState() => ChessHomeState();
}

class ChessHomeState extends State<ChessHome> {
  // Time variables for both players (in seconds)
  int _player1Time = 5 * 60; // 5 minutes in seconds
  int _player2Time = 5 * 60;

  // Game settings
  int _delay = 0;
  String _gameMode = 'Sudden death';
  bool _isPlayer1Turn = true;
  bool _isGameRunning = false;

  // Timers for game clock and delay
  Timer? _timer;
  Timer? _delayTimer;

  // Variables for stage-based games
  int _currentStage = 0;
  int _movesPlayed = 0;
  int _player1Stage = 0;
  int _player2Stage = 0;

  // Define different game modes with their respective settings
  final Map<String, Map<String, dynamic>> _gameModes = {
    'Sudden death': {'time': 5},
    'Increment': {'time': 3, 'increment': 2},
    'Increment with handicap': {
      'player1Time': 5,
      'player2Time': 5,
      'player1Increment': 5,
      'player2Increment': 5
    },
    'Simple delay': {'time': 5, 'delay': 5},
    'Bronstein': {'time': 5, 'delay': 5},
    'Hourglass': {'time': 3},
    'Stage': {
      'stages': [
        {'time': 5, 'increment': 0, 'moves': 40},
        {'time': 3, 'increment': 3, 'moves': 20},
      ]
    },
  };

  @override
  void dispose() {
    // Cancel timers when widget is disposed
    _timer?.cancel();
    _delayTimer?.cancel();
    super.dispose();
  }

  // Start the game
  void _startGame(bool isPlayer1) {
    setState(() {
      _isGameRunning = true;
      _isPlayer1Turn = isPlayer1;
      if (_gameMode == 'Stage') {
        // Initialize stage-based game
        _currentStage = 0;
        _movesPlayed = 0;
        _player1Stage = 0;
        _player2Stage = 0;
        _player1Time = _gameModes[_gameMode]!['stages'][0]['time'] * 60;
        _player2Time = _gameModes[_gameMode]!['stages'][0]['time'] * 60;
      }
    });
    if (_gameMode == 'Simple delay' || _gameMode == 'Bronstein') {
      _startDelayTimer();
    } else {
      _startTimer();
    }
  }

  // Start the main game timer
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_gameMode == 'Hourglass') {
          // In Hourglass mode, one player's time decreases while the other increases
          if (_isPlayer1Turn) {
            _player1Time--;
            _player2Time++;
          } else {
            _player2Time--;
            _player1Time++;
          }
        } else {
          // For other modes, decrease the current player's time
          if (_isPlayer1Turn) {
            _player1Time--;
          } else {
            _player2Time--;
          }
        }

        // End the game if either player's time runs out
        if (_player1Time <= 0 || _player2Time <= 0) {
          _endGame();
        }
      });
    });
  }

  // Switch turns between players
  void _switchTurn() {
    _delayTimer?.cancel();
    setState(() {
      _isPlayer1Turn = !_isPlayer1Turn;
      if (_gameMode == 'Increment') {
        // Add increment to the player who just finished their turn
        if (_isPlayer1Turn) {
          _player2Time += (_gameModes[_gameMode]!['increment'] as int);
        } else {
          _player1Time += (_gameModes[_gameMode]!['increment'] as int);
        }
      } else if (_gameMode == 'Increment with handicap') {
        // Add different increments for each player
        if (_isPlayer1Turn) {
          _player2Time += (_gameModes[_gameMode]!['player2Increment'] as int);
        } else {
          _player1Time += (_gameModes[_gameMode]!['player1Increment'] as int);
        }
      } else if (_gameMode == 'Simple delay' || _gameMode == 'Bronstein') {
        // Start delay timer
        _delay = (_gameModes[_gameMode]!['delay'] as int);
        _startDelayTimer();
      } else if (_gameMode == 'Stage') {
        // Handle stage-based game logic
        _movesPlayed++;
        var currentStageSettings =
            _gameModes[_gameMode]!['stages'][_currentStage];
        if (_movesPlayed >= currentStageSettings['moves']) {
          // Move to next stage if moves requirement is met
          if (_isPlayer1Turn) {
            _player1Stage++;
          } else {
            _player2Stage++;
          }
          _movesPlayed = 0;
          if (_player1Stage < _gameModes[_gameMode]!['stages'].length &&
              _player2Stage < _gameModes[_gameMode]!['stages'].length) {
            _currentStage =
                (_player1Stage > _player2Stage) ? _player1Stage : _player2Stage;
            var nextStageSettings =
                _gameModes[_gameMode]!['stages'][_currentStage];
            // Add time for the new stage
            if (_isPlayer1Turn) {
              _player1Time += (nextStageSettings['time'] as int) * 60;
            } else {
              _player2Time += (nextStageSettings['time'] as int) * 60;
            }
          } else {
            // End game if all stages are completed
            _endGame();
            return;
          }
        }
        // Add increment for the current stage
        if (_isPlayer1Turn) {
          _player2Time += (currentStageSettings['increment'] as int);
        } else {
          _player1Time += (currentStageSettings['increment'] as int);
        }
      }
    });
  }

  // Start the delay timer for delay-based game modes
  void _startDelayTimer() {
    _timer?.cancel();
    _delayTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_delay > 0) {
          _delay--;
        } else {
          _delayTimer?.cancel();
          _startTimer();
        }
      });
    });
  }

  // End the game and show the winner
  void _endGame() {
    _timer?.cancel();
    _delayTimer?.cancel();
    setState(() {
      _isGameRunning = false;
    });
    String winner;
    if (_gameMode == 'Stage') {
      winner = (_player1Stage >= _gameModes[_gameMode]!['stages'].length)
          ? 'Player 1'
          : 'Player 2';
    } else {
      winner = _player1Time <= 0 ? 'Player 2' : 'Player 1';
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Game Over', style: TextStyle(color: Colors.white)),
          content: Text('$winner wins!', style: TextStyle(color: Colors.white)),
          actions: <Widget>[
            TextButton(
              child: Text('OK', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Reset the game to initial state
  void _resetGame() {
    setState(() {
      if (_gameMode == 'Increment with handicap') {
        _player1Time = (_gameModes[_gameMode]!['player1Time'] as int) * 60;
        _player2Time = (_gameModes[_gameMode]!['player2Time'] as int) * 60;
      } else if (_gameMode == 'Hourglass') {
        int totalTime = (_gameModes[_gameMode]!['time'] as int) * 60;
        _player1Time = totalTime ~/ 2;
        _player2Time = totalTime ~/ 2;
      } else if (_gameMode == 'Stage') {
        _player1Time =
            (_gameModes[_gameMode]!['stages'][0]['time'] as int) * 60;
        _player2Time =
            (_gameModes[_gameMode]!['stages'][0]['time'] as int) * 60;
        _currentStage = 0;
        _movesPlayed = 0;
        _player1Stage = 0;
        _player2Stage = 0;
      } else {
        _player1Time = (_gameModes[_gameMode]!['time'] as int) * 60;
        _player2Time = (_gameModes[_gameMode]!['time'] as int) * 60;
      }
      _delay = (_gameModes[_gameMode]!['delay'] ?? 0);
      _isPlayer1Turn = true;
      _isGameRunning = false;
    });
    _timer?.cancel();
    _delayTimer?.cancel();
  }

  // Format time in minutes:seconds
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Show dialog to select game mode
  void _showGameModeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title:
              Text('Select Game Mode', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                for (var mode in _gameModes.keys)
                  ListTile(
                    title: Text(mode, style: TextStyle(color: Colors.white)),
                    subtitle: Text(_getGameModeDetails(mode),
                        style: TextStyle(color: Colors.grey[400])),
                    onTap: () {
                      Navigator.of(context).pop();
                      _showCustomizeGameModeDialog(mode);
                    },
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Get details of each game mode for display
  String _getGameModeDetails(String mode) {
    switch (mode) {
      case 'Sudden death':
        return 'Time: ${_gameModes[mode]!['time']} minutes';
      case 'Increment':
        return 'Time: ${_gameModes[mode]!['time']} minutes, Increment: ${_gameModes[mode]!['increment']} seconds';
      case 'Increment with handicap':
        return 'Player 1: ${_gameModes[mode]!['player1Time']} minutes, Player 2: ${_gameModes[mode]!['player2Time']} minutes, Increments: ${_gameModes[mode]!['player1Increment']} / ${_gameModes[mode]!['player2Increment']} seconds';
      case 'Simple delay':
      case 'Bronstein':
        return 'Time: ${_gameModes[mode]!['time']} minutes, Delay: ${_gameModes[mode]!['delay']} seconds';
      case 'Hourglass':
        return 'Total Time: ${_gameModes[mode]!['time']} minutes';
      case 'Stage':
        return 'Multiple stages with customizable time, increment, and moves';
      default:
        return '';
    }
  }

  // Show dialog to customize selected game mode
  void _showCustomizeGameModeDialog(String mode) {
    Map<String, dynamic> customSettings = Map.from(_gameModes[mode]!);
    Map<String, TextEditingController> controllers = {};

    // Initialize controllers for each field
    customSettings.forEach((key, value) {
      if (value is int) {
        controllers[key] = TextEditingController(text: value.toString());
      } else if (value is List) {
        for (int i = 0; i < value.length; i++) {
          value[i].forEach((k, v) {
            controllers['$key[$i][$k]'] =
                TextEditingController(text: v.toString());
          });
        }
      }
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Colors.grey[900],
              title: Text('Customize $mode',
                  style: TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Time input for most game modes
                    if (mode == 'Sudden death' ||
                        mode == 'Increment' ||
                        mode == 'Simple delay' ||
                        mode == 'Bronstein' ||
                        mode == 'Hourglass')
                      TextField(
                        controller: controllers['time'],
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Time (minutes)',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[700]!),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          customSettings['time'] =
                              int.tryParse(value) ?? customSettings['time'];
                        },
                      ),
                    // Increment input for Increment mode
                    if (mode == 'Increment')
                      TextField(
                        controller: controllers['increment'],
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Increment (seconds)',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[700]!),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          customSettings['increment'] = int.tryParse(value) ??
                              customSettings['increment'];
                        },
                      ),
                    // Inputs for Increment with handicap mode
                    if (mode == 'Increment with handicap') ...[
                      TextField(
                        controller: controllers['player1Time'],
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Player 1 Time (minutes)',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[700]!),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          customSettings['player1Time'] = int.tryParse(value) ??
                              customSettings['player1Time'];
                        },
                      ),
                      TextField(
                        controller: controllers['player2Time'],
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Player 2 Time (minutes)',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[700]!),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          customSettings['player2Time'] = int.tryParse(value) ??
                              customSettings['player2Time'];
                        },
                      ),
                      TextField(
                        controller: controllers['player1Increment'],
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Player 1 Increment (seconds)',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[700]!),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          customSettings['player1Increment'] =
                              int.tryParse(value) ??
                                  customSettings['player1Increment'];
                        },
                      ),
                      TextField(
                        controller: controllers['player2Increment'],
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Player 2 Increment (seconds)',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[700]!),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          customSettings['player2Increment'] =
                              int.tryParse(value) ??
                                  customSettings['player2Increment'];
                        },
                      ),
                    ],
                    // Delay input for Simple delay and Bronstein modes
                    if (mode == 'Simple delay' || mode == 'Bronstein')
                      TextField(
                        controller: controllers['delay'],
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Delay (seconds)',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[700]!),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          customSettings['delay'] =
                              int.tryParse(value) ?? customSettings['delay'];
                        },
                      ),
                    // Inputs for Stage mode
                    if (mode == 'Stage')
                      for (int i = 0;
                          i < (customSettings['stages'] as List).length;
                          i++)
                        ExpansionTile(
                          title: Text('Stage ${i + 1}',
                              style: TextStyle(color: Colors.white)),
                          children: [
                            TextField(
                              controller: controllers['stages[$i][time]'],
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Time (minutes)',
                                labelStyle: TextStyle(color: Colors.grey[400]),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey[700]!),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                customSettings['stages'][i]['time'] =
                                    int.tryParse(value) ??
                                        customSettings['stages'][i]['time'];
                              },
                            ),
                            TextField(
                              controller: controllers['stages[$i][increment]'],
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Increment (seconds)',
                                labelStyle: TextStyle(color: Colors.grey[400]),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey[700]!),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                customSettings['stages'][i]['increment'] =
                                    int.tryParse(value) ??
                                        customSettings['stages'][i]
                                            ['increment'];
                              },
                            ),
                            TextField(
                              controller: controllers['stages[$i][moves]'],
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Moves',
                                labelStyle: TextStyle(color: Colors.grey[400]),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey[700]!),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                customSettings['stages'][i]['moves'] =
                                    int.tryParse(value) ??
                                        customSettings['stages'][i]['moves'];
                              },
                            ),
                          ],
                        ),
                    // Button to add a new stage in Stage mode
                    if (mode == 'Stage' &&
                        (customSettings['stages'] as List).length < 5)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                        ),
                        onPressed: () {
                          setState(() {
                            customSettings['stages']
                                .add({'time': 5, 'increment': 0, 'moves': 20});
                            int newIndex = customSettings['stages'].length - 1;
                            controllers['stages[$newIndex][time]'] =
                                TextEditingController(text: '5');
                            controllers['stages[$newIndex][increment]'] =
                                TextEditingController(text: '0');
                            controllers['stages[$newIndex][moves]'] =
                                TextEditingController(text: '20');
                          });
                        },
                        child: const Text('Add Stage'),
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Save', style: TextStyle(color: Colors.blue)),
                  onPressed: () {
                    try {
                      setState(() {
                        _gameModes[mode] =
                            Map<String, dynamic>.from(customSettings);
                        _gameMode = mode;
                        _resetGame();
                      });
                      Navigator.of(context).pop();
                    } catch (e) {
                      debugPrint('Error saving game mode: $e');
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: Colors.grey[900],
                            title: Text('Error',
                                style: TextStyle(color: Colors.white)),
                            content: Text('Failed to save game mode: $e',
                                style: TextStyle(color: Colors.white)),
                            actions: <Widget>[
                              TextButton(
                                child: Text('OK',
                                    style: TextStyle(color: Colors.blue)),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                ),
                TextButton(
                  child: Text('Cancel', style: TextStyle(color: Colors.blue)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chess Clock'),
      ),
      body: Column(
        children: [
          Expanded(
            child: RotatedBox(
              quarterTurns: 2,
              child: _buildPlayerClock(2),
            ),
          ),
          _buildControls(),
          Expanded(
            child: _buildPlayerClock(1),
          ),
        ],
      ),
    );
  }

  // Build the clock display for a player
  Widget _buildPlayerClock(int playerNumber) {
    bool isCurrentPlayer = (playerNumber == 1 && _isPlayer1Turn) ||
        (playerNumber == 2 && !_isPlayer1Turn);
    return GestureDetector(
      onTap: () {
        if (!_isGameRunning) {
          _startGame(playerNumber == 1);
        } else if (isCurrentPlayer) {
          _switchTurn();
        }
      },
      child: Container(
        color: isCurrentPlayer
            ? Colors.green.withOpacity(0.3)
            : Colors.grey.withOpacity(0.1),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formatTime(playerNumber == 1 ? _player1Time : _player2Time),
                style: Theme.of(context).textTheme.displayMedium,
              ),
              if ((_gameMode == 'Simple delay' || _gameMode == 'Bronstein') &&
                  isCurrentPlayer &&
                  _delay > 0)
                Text(
                  'Delay: $_delay',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              if (_gameMode == 'Stage')
                Text(
                  'Stage: ${(playerNumber == 1 ? _player1Stage : _player2Stage) + 1}, Moves: $_movesPlayed / ${_gameModes[_gameMode]!['stages'][_currentStage]['moves']}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Build the control buttons
  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: _isGameRunning
                ? () {
                    setState(() {
                      _isGameRunning = false;
                      _timer?.cancel();
                      _delayTimer?.cancel();
                    });
                  }
                : null,
            child: const Text('Pause'),
          ),
          ElevatedButton(
            onPressed: _resetGame,
            child: const Text('Reset'),
          ),
          ElevatedButton(
            onPressed: _isGameRunning ? null : _showGameModeDialog,
            child: const Text('Game Mode'),
          ),
        ],
      ),
    );
  }
}
