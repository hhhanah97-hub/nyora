class Finance {
  final DateTime date;
  final String text;
  final double amount;

  Finance({required this.date, required this.text, required this.amount});

  Map<String, dynamic> toJson() {
    return {'date': date.toIso8601String(), 'text': text, 'amount': amount};
  }

  factory Finance.fromJson(Map<String, dynamic> json) {
    return Finance(
      date: DateTime.parse(json['date']),
      text: json['text'],
      amount: json['amount'],
    );
  }
}
