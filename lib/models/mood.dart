class Mood {
  final String name;
  final String emoji;
  final List<String> relatedMoods;

  const Mood({
    required this.name,
    required this.emoji,
    required this.relatedMoods,
  });
}

class MoodData {
  static const List<Mood> moods = [
    Mood(
      name: 'Very Sad',
      emoji: '😢',
      relatedMoods: ['Depressed', 'Hopeless', 'Miserable', 'Gloomy'],
    ),
    Mood(
      name: 'Sad',
      emoji: '😔',
      relatedMoods: ['Down', 'Blue', 'Unhappy', 'Disappointed'],
    ),
    Mood(
      name: 'Slightly Sad',
      emoji: '🙁',
      relatedMoods: ['Melancholic', 'Upset', 'Disheartened', 'Low'],
    ),
    Mood(
      name: 'Neutral',
      emoji: '😐',
      relatedMoods: ['Okay', 'Fine', 'Average', 'Indifferent'],
    ),
    Mood(
      name: 'Slightly Happy',
      emoji: '🙂',
      relatedMoods: ['Pleasant', 'Content', 'Satisfied', 'Decent'],
    ),
    Mood(
      name: 'Happy',
      emoji: '😊',
      relatedMoods: ['Cheerful', 'Glad', 'Pleased', 'Upbeat'],
    ),
    Mood(
      name: 'Very Happy',
      emoji: '😄',
      relatedMoods: ['Joyful', 'Ecstatic', 'Delighted', 'Thrilled'],
    ),
  ];
}