import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:random_quote_generator_intern/model/quote.dart';


class QuoteService {
  static Future<List<Quote>> loadQuotes() async {
    final String response = await rootBundle.loadString('assets/quotes.json');
    final List<dynamic> data = json.decode(response);
    return data.map((q) => Quote(text: q['text'], author: q['author'])).toList();
  }
}