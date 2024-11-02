import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:http/http.dart' as http;

enum Difficulty {
  basicFlutter,
  advanceFlutter,
  masterFlutter,
}

var advanceFlutter = """
Generate a JSON file containing 10 unique multiple-choice questions related to advanced Flutter topics, such as state management and animations. Each question should include the question text, four distinct options, and the correct correctAnswer. Please ensure that these questions are varied and not repetitive from any previous requests.
""";

var basicFlutter = """
Generate a JSON file containing 10 unique multiple-choice questions related to basic Flutter topics. Each question should include the question text, four distinct options, and the correct correctAnswer. Please ensure that these questions are varied and not repetitive from any previous requests.
""";

var masterFlutter = """
Generate a JSON file containing 10 unique multiple-choice questions related to master in Flutter topics. Each question should include the question text, four distinct options, and the correct correctAnswer. Please ensure that these questions are varied and not repetitive from any previous requests.
""";

//jsonDecode is use to convert from json data into object in dart, but since our Json Data is nested data, we need multiple function to extract them one by one

List<Quiz> convertJsonToObject(String jsonDatas) {
  // print("check1");
  List<dynamic> jsonDataList = jsonDecode(jsonDatas);
  // print("check2");

  return jsonDataList.map((jsonData) => Quiz.fromjson(jsonData)).toList();
}

class Quiz {
  final String question;
  final List<String> options;
  final String correctAnswer;

  Quiz(
      {required this.question,
      required this.correctAnswer,
      required this.options});

  factory Quiz.fromjson(Map<String, dynamic> json) {
    List<String> optionList = List<String>.from(json['options']);

    return Quiz(
      question: json['question'],
      options: optionList,
      correctAnswer: json['correctAnswer'],
    );
  }
}

// Json sample

// {candidates: [{content: {parts: [{text: ```json
// [
//   {
//     "question": "Which Flutter state management solution uses a single, immutable state tree and is optimized for performance?",
//     "options": [
//       "Provider",
//       "BLoC",
//       "Redux",
//       "GetIt"
//     ],
//     "correctAnswer": "Redux"
//   },

// ]
// ```}], role: model}, finishReason: STOP, index: 0, safetyRatings: [{category: HARM_CATEGORY_SEXUALLY_EXPLICIT, probability: NEGLIGIBLE}, {category: HARM_CATEGORY_HATE_SPEECH, probability: NEGLIGIBLE}, {category: HARM_CATEGORY_HARASSMENT, probability: NEGLIGIBLE}, {category: HARM_CATEGORY_DANGEROUS_CONTENT, probability: NEGLIGIBLE}]}], usageMetadata: {promptTokenCount: 60, candidatesTokenCount: 979, totalTokenCount: 1039}, modelVersion: gemini-1.5-flash-001}

Future<String> requestGPT(String prompt) async {
  final apiKey = 'AIzaSyD1ZduNu_jtY5pZq3T67QHGKLaAltIItWI';
  final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey');
  try {
    var body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ]
    });

    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      // print(data);
      final List<dynamic> candidates = data['candidates'];

      if (candidates.isNotEmpty) {
        //since the respone have header and tailing, wee need (candidates[0]['content']['parts'][0]['text'] ) to redirect to text
        // and we use trim to cut unecessary letter and symbol inorder to store into the list
        String text = candidates[0]['content']['parts'][0]['text'];
        text = text.replaceAll('```', '').trim();
        text = text.replaceAll('json', '').trim();
        return text;
      } else {
        print('No candidates found.');
      }
    } else {
      print('Failed to load data: ${response.statusCode}');
    }
  } catch (e) {
    rethrow;
  }
  return "error No data";
}

class Correction {
  final String question;
  final String correctAnswer;
  Correction({required this.question, required this.correctAnswer});
}

class QuizGame {
  int live = 4;
  final Difficulty level;
  List<Correction> correction = [];
  QuizGame({required this.level});

  void displayCorrectAnswer() {
    print("\n############################");
    print("Correction of your wrong answer");
    print("############################\n\n");
    for (var item in correction) {
      print("Question : ${item.question}");
      print("Answer : ${item.correctAnswer}\n");
    }
  }

  Future<List<Quiz>> prepareQuiz() async {
    late String requestStatement;
    switch (this.level) {
      case Difficulty.basicFlutter:
        requestStatement = basicFlutter;
        break;
      case Difficulty.advanceFlutter:
        requestStatement = advanceFlutter;
        break;
      case Difficulty.masterFlutter:
        requestStatement = masterFlutter;
        break;
    }

    var text = await requestGPT(requestStatement);
    return convertJsonToObject(text);
  }

  void startGame() async {
    int i = 1;
    int j = 1;
    var quiz = await prepareQuiz();

    for (var question in quiz) {
      print("\nLive remainning : $live\n");
      print("$j. ${question.question}");
      j++;
      i = 1;
      for (var option in question.options) {
        print(" $i. $option");
        i++;
      }
      //take user input
      int input = int.parse(stdin.readLineSync()!);

      if (input > 4) {
        correction.add(Correction(
            question: question.question,
            correctAnswer: question.correctAnswer));
        live--;
      } else if (question.options[input - 1] != question.correctAnswer) {
        correction.add(Correction(
            question: question.question,
            correctAnswer: question.correctAnswer));
        live--;
        print("\nWrong!!!\n");
        sleep(Duration(seconds: 1));
      } else {
        print("\nCorrect!!!\n");
        sleep(Duration(seconds: 1));
      }
      if (live == 0) {
        print("You have lost the game");
        displayCorrectAnswer();
        return;
      }
    }

    print("Winner!! you have succesfully crash ${level.name}");
    displayCorrectAnswer();
  }
}

void menu() {
  print("----------------------------------------------------------");
  print("Flutter Quizs");
  print("Choose difficulty");
  print("----------------------------------------------------------");
  print("  1. Basic\n  2. Advance\n  3. Master ");
  int input = int.parse(stdin.readLineSync()!);
  if (input > 3 || input < 1) {
    print("Option not available");
  } else {
    print("----------------------------------------------------------");
    print("Selected ${Difficulty.values[input - 1].name}\nLoading...");
    print("----------------------------------------------------------\n\n");

    QuizGame game = QuizGame(level: Difficulty.values[input - 1]);
    game.startGame();
  }
}

void main() {
  menu();
}
