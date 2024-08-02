import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  _ReminderPageState createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  String selectedDay = 'Monday';
  TimeOfDay selectedTime = TimeOfDay.now();
  String selectedActivity = 'Wake up';
  List<Map<String, dynamic>> reminders = [];
  AudioPlayer audioPlayer = AudioPlayer();

  List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  List<String> activities = [
    'Wake up',
    'Go to gym',
    'Breakfast',
    'Meetings',
    'Lunch',
    'Quick nap',
    'Go to library',
    'Dinner',
    'Go to sleep'
  ];

  @override
  void initState() {
    super.initState();
    // Start checking reminders every minute
    Future.delayed(const Duration(minutes: 1), checkReminders);
  }

  void checkReminders() async {
    DateTime now = DateTime.now();
    String currentDay = DateFormat('EEEE').format(now);
    TimeOfDay currentTime = TimeOfDay.fromDateTime(now);

    for (var reminder in reminders) {
      if (reminder['day'] == currentDay &&
          reminder['time'].hour == currentTime.hour &&
          reminder['time'].minute == currentTime.minute) {
        // Play sound
        await audioPlayer.play(AssetSource('assets/notification_ding.mp3'));

        // Show notification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reminder: ${reminder['activity']}'),
            duration:const Duration(seconds: 5),
          ),
        );
      }
    }

    // Check again after 1 minute
    Future.delayed(const Duration(minutes: 1), checkReminders);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
        title:const Text('Set Reminder'),
      ),
      body: Padding(
        padding:const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(

              value: selectedDay,
              items: days.map((String day) {
                return DropdownMenuItem<String>(
                  value: day,
                  child: Text(day),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedDay = newValue!;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.teal,
                  elevation: 4
              ),
              child: Text('Select Time: ${selectedTime.format(context)}'),
              onPressed: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                );
                if (picked != null && picked != selectedTime) {
                  setState(() {
                    selectedTime = picked;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: selectedActivity,
              items: activities.map((String activity) {
                return DropdownMenuItem<String>(
                  value: activity,
                  child: Text(activity),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedActivity = newValue!;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(

              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 120, vertical: 10),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  elevation: 4
              ),
              child:const Text('Set Reminder',style: TextStyle(fontSize: 16),),
              onPressed: () {
                setState(() {
                  reminders.add({
                    'day': selectedDay,
                    'time': selectedTime,
                    'activity': selectedActivity,
                  });
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reminder set successfully')),
                );
              },
            ),
            const SizedBox(height: 32),
            const Text('Current Reminders:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: reminders.length,
                itemBuilder: (context, index) {
                  final reminder = reminders[index];
                  return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text('${reminder['day']} - ${reminder['time'].format(context)}'),
                      subtitle: Text(reminder['activity']),
                      trailing: IconButton(
                        icon:const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            reminders.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}