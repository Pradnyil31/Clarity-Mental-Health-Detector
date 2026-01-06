class Quote {
  final String text;
  final String author;

  const Quote({required this.text, required this.author});
}

class DailyQuotes {
  static const List<Quote> _quotes = [
    Quote(
      text: "The only journey is the one within.",
      author: "Rainer Maria Rilke",
    ),
    Quote(
      text: "Healing takes courage, and we all have courage, even if we have to dig a little to find it.",
      author: "Tori Amos",
    ),
    Quote(
      text: "You are not your illness. You have an individual story to tell.",
      author: "Julian Seifter",
    ),
    Quote(
      text: "There is hope, even when your brain tells you there isn't.",
      author: "John Green",
    ),
    Quote(
      text: "Your present circumstances don't determine where you can go; they merely determine where you start.",
      author: "Nido Qubein",
    ),
    Quote(
      text: "Out of suffering have emerged the strongest souls; the most massive characters are seared with scars.",
      author: "Khalil Gibran",
    ),
    Quote(
      text: "Recovery is not one and done. It is a lifelong journey that takes place one day, one step at a time.",
      author: "Unknown",
    ),
    Quote(
      text: "What mental health needs is more sunlight, more candor, and more unashamed conversation.",
      author: "Glenn Close",
    ),
    Quote(
      text: "Happiness can be found even in the darkest of times, if one only remembers to turn on the light.",
      author: "Albus Dumbledore",
    ),
    Quote(
      text: "You don't have to be positive all the time. It's perfectly okay to feel sad, angry, annoyed, frustrated, scared and anxious.",
      author: "Lori Deschene",
    ),
    Quote(
      text: "It is during our darkest moments that we must focus to see the light.",
      author: "Aristotle",
    ),
    Quote(
      text: "Self-care is how you take your power back.",
      author: "Lalah Delia",
    ),
    Quote(
      text: "One small crack does not mean that you are broken, it means that you were put to the test and you didn't fall apart.",
      author: "Linda Poindexter",
    ),
    Quote(
      text: "Believe you can and you're halfway there.",
      author: "Theodore Roosevelt",
    ),
    Quote(
      text: "Act as if what you do makes a difference. It does.",
      author: "William James",
    ),
    Quote(
      text: "Success is not final, failure is not fatal: it is the courage to continue that counts.",
      author: "Winston Churchill",
    ),
    Quote(
      text: "Life is like riding a bicycle. To keep your balance, you must keep moving.",
      author: "Albert Einstein",
    ),
    Quote(
      text: "You are never too old to set another goal or to dream a new dream.",
      author: "C.S. Lewis",
    ),
    Quote(
      text: "The only limit to our realization of tomorrow will be our doubts of today.",
      author: "Franklin D. Roosevelt",
    ),
    Quote(
      text: "It always seems impossible until it's done.",
      author: "Nelson Mandela",
    ),
    Quote(
      text: "Keep your face always toward the sunshine—and shadows will fall behind you.",
      author: "Walt Whitman",
    ),
    Quote(
      text: "You are stronger than you know.",
      author: "Unknown",
    ),
    Quote(
      text: "Every day may not be good, but there is something good in every day.",
      author: "Alice Morse Earle",
    ),
    Quote(
      text: "Don't watch the clock; do what it does. Keep going.",
      author: "Sam Levenson",
    ),
    Quote(
      text: "Everything you've ever wanted is on the other side of fear.",
      author: "George Addair",
    ),
    Quote(
      text: "Hardships often prepare ordinary people for an extraordinary destiny.",
      author: "C.S. Lewis",
    ),
    Quote(
      text: "The best way out is always through.",
      author: "Robert Frost",
    ),
    Quote(
      text: "Fall seven times, stand up eight.",
      author: "Japanese Proverb",
    ),
    Quote(
      text: "Stars can't shine without darkness.",
      author: "D.H. Sidebottom",
    ),
    Quote(
      text: "Be gentle with yourself. You're doing the best you can.",
      author: "Unknown",
    ),
  ];

  static Quote getDailyQuote() {
    final now = DateTime.now();
    // Create a seed based on the day of the year to ensure the same quote for the whole day
    final dayOfYear = int.parse("${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}");
    final index = dayOfYear % _quotes.length;
    return _quotes[index];
  }
}
