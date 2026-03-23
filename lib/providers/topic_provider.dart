import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TopicState {
  final Set<String> subscriptions;
  final bool soundEnabled;
  final bool notifyEnabled;

  const TopicState({
    this.subscriptions = const {},
    this.soundEnabled = true,
    this.notifyEnabled = false,
  });

  TopicState copyWith({
    Set<String>? subscriptions,
    bool? soundEnabled,
    bool? notifyEnabled,
  }) {
    return TopicState(
      subscriptions: subscriptions ?? this.subscriptions,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      notifyEnabled: notifyEnabled ?? this.notifyEnabled,
    );
  }

  /// Check if message text contains any subscribed topic
  bool matchesTopic(String text) {
    final lowerText = text.toLowerCase();
    return subscriptions.any((topic) => lowerText.contains(topic.toLowerCase()));
  }

  /// Get all matching topics in a message
  List<String> getMatchingTopics(String text) {
    final lowerText = text.toLowerCase();
    return subscriptions
        .where((topic) => lowerText.contains(topic.toLowerCase()))
        .toList();
  }
}

class TopicNotifier extends StateNotifier<TopicState> {
  TopicNotifier() : super(const TopicState()) {
    _loadFromStorage();
  }

  static const _subsKey = 'topic_subscriptions';
  static const _soundKey = 'topic_sound';
  static const _notifyKey = 'topic_notify';

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final subs = prefs.getStringList(_subsKey) ?? [];
    final sound = prefs.getBool(_soundKey) ?? true;
    final notify = prefs.getBool(_notifyKey) ?? false;

    state = state.copyWith(
      subscriptions: subs.toSet(),
      soundEnabled: sound,
      notifyEnabled: notify,
    );
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_subsKey, state.subscriptions.toList());
    await prefs.setBool(_soundKey, state.soundEnabled);
    await prefs.setBool(_notifyKey, state.notifyEnabled);
  }

  void subscribe(String topic) {
    if (topic.isEmpty) return;
    final trimmed = topic.trim().toLowerCase();
    if (trimmed.isEmpty) return;

    final newSubs = {...state.subscriptions, trimmed};
    state = state.copyWith(subscriptions: newSubs);
    _saveToStorage();
  }

  void unsubscribe(String topic) {
    final trimmed = topic.trim().toLowerCase();
    final newSubs = {...state.subscriptions}..remove(trimmed);
    state = state.copyWith(subscriptions: newSubs);
    _saveToStorage();
  }

  void toggleSound(bool enabled) {
    state = state.copyWith(soundEnabled: enabled);
    _saveToStorage();
  }

  void toggleNotify(bool enabled) {
    state = state.copyWith(notifyEnabled: enabled);
    _saveToStorage();
  }

  List<String> get topicList => state.subscriptions.toList()..sort();
}

final topicProvider = StateNotifierProvider<TopicNotifier, TopicState>((ref) {
  return TopicNotifier();
});
