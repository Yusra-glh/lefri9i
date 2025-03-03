import 'package:flutter/material.dart';
import 'package:gark_academy/models/event_model.dart';
import 'package:gark_academy/models/test_model.dart';
import 'package:gark_academy/models/user_model.dart';
import 'package:gark_academy/services/event_service.dart';
import 'package:gark_academy/services/utilities/functions.dart';

class EventProvider with ChangeNotifier {
  List<Event> _events = [];
  List<Event> get events => _events;
  List<Event> _allEvents = [];
  List<Event> get allEvents => _allEvents;
  DateTime now = DateTime.now();
  List<User> _members = [];
  List<User> get members => _members;
  Test? _testData;
  Test? get testData => _testData;
   bool _isLoading = false;
  bool get isLoading => _isLoading;
  int? _eventInProgress;
  int? get eventInProgress => _eventInProgress;


  final EventService _eventService = EventService();

  Future<void> fetchAdherantEvents() async {
    try {
      _events = await _eventService.getAdherantEvents();
      // _events = _events
      //     .where((event) =>
      //         DateTime.parse(event.date).isAfter(now) ||
      //         isSameDate(DateTime.parse(event.date), now))
      //     .toList();
      // ..sort(
      //     (a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));
      notifyListeners();
    } catch (e) {
      print('Failed to load events: $e');
    }
  }
Future<void> fetchAdherantAllEvents() async {
    try {
      _allEvents = await _eventService.getAdherantAllEvents();
      _allEvents = _allEvents
          .where((event) =>
              DateTime.parse(event.date).isAfter(now) ||
              isSameDate(DateTime.parse(event.date), now))
          .toList()
        ..sort(
            (a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));
      notifyListeners();
    } catch (e) {
      print('Failed to load events: $e');
    }
  }
  Future<void> fetchCoachEvents() async {
    try {
      _events = await _eventService.getCoachEvents();
      // _events = _events
      //     .where((event) =>
      //         DateTime.parse(event.date).isAfter(now) ||
      //         isSameDate(DateTime.parse(event.date), now))
      //     .toList();
      // ..sort(
      //     (a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));
      notifyListeners();
    } catch (e) {
      print('Failed to load events: $e');
    }
  }

  Future<void> fetchEventMembers(int eventId) async {
    try {
      _members = await _eventService.fetchEventMembers(eventId);
      notifyListeners();
    } catch (e) {
      print('Failed to fetch event members: $e');
    }
  }

  Future<void> updateEventAttendance(int attendanceId, bool isPresent) async {
    try {
      await _eventService.updateEventAttendance(attendanceId, isPresent);
      notifyListeners();
    } catch (e) {
      print('Failed to update attendance: $e');
    }
  }

  Future<void> fetchEventDetails(int eventId) async {
    try {
      final event = await _eventService.getEventDetails(eventId);
      _events = _events.map((e) => e.id == eventId ? event : e).toList();
      notifyListeners();
    } catch (e) {
      print('Failed to fetch event details: $e');
    }
  }

  //Test evaluation
  Future<void> fetchTestData(int attendanceId) async {
    try {
      _testData = await _eventService.fetchTestData(attendanceId);
      notifyListeners();
    } catch (e) {
      print('Failed to fetch test data: $e');
    }
  }

  Future<void> updateTestData(int testId, Test testData) async {
    try {
      await _eventService.updateTestData(testId, testData);
      _testData = testData;
      notifyListeners();
    } catch (e) {
      print('Failed to update test data: $e');
    }
  }

  Future<void> toggleParticipation(int eventId) async {
    _isLoading = true;
    _eventInProgress = eventId;
    notifyListeners();
    try {
      await _eventService.toggleParticipation(eventId);
      await fetchAdherantEvents(); // For the list view
      await fetchAdherantAllEvents(); // For the calendar view
      _isLoading = false;
       _eventInProgress = null;
      notifyListeners();
    } catch (e) {
      print('Failed to fetch test data: $e');
      _isLoading = false;
      _eventInProgress = null;
      notifyListeners();
    }
  }
}
