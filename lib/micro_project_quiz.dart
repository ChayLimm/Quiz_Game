import 'dart:convert';
import 'package:http/http.dart' as http;

var advance_flutter = """
Generate a JSON file containing 10 unique multiple-choice of 4 (A - D) using map questions related to advanced Flutter topics, such as state management and animations. Each question should include the question text, four distinct options, and the correct correctAnswer. Please ensure that these questions are varied and not repetitive from any previous requests.
""";

class Quiz {
  final String question;
  final String correctAnswer;
  final List<Options> options;
  Quiz({required this.question, required this.correctAnswer,required this.options})
  
  factory Quiz.fromjson(Map<String,dynamic> json){
    var optionList = json['options'].toList();
  	List<Options> option = optionList.Map((optionList)=> Options.fromJson(optionList)).toList();
    return Quiz(
      question: json['question'], 
      options: optionList, 
      correctAnswer : json['correctAnswer'], 
);
  }

}
class Options{
  final String answer;
  final String option; 
  Options({required this.answer, required this.option})
  Options.fromjson(Map<String,String> jsonObject){
    return Options(
      answer: jsonObject.keys,
      answerOption: jsonObject.values
      );
  }
}





Future<void> requestGPT(String prompt) async {
  final apiKey = 'AIzaSyD1ZduNu_jtY5pZq3T67QHGKLaAltIItWI'; 
  final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey');
    
  var body = jsonEncode({
    'contents': [
      {
        'parts': [
          {'text': advance_flutter}
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
  final data = jsonDecode(response.body);

  if (data != null) {
    print('Response: $data');
  } else {
    print('Unexpected response structure: $data');
  }
} else {
  print('Failed to get response: ${response.statusCode}');
  print('Error: ${response.body}');
}


}  

class ConvertToObject{
  late String question;
  late List<String> options;
  late String correctAnswer;
  
  ConvertToObject.fromJson(Map<String,dynamic>json){
    question = json["question"];
    options = json["options"];
    correctAnswer = json["correctAnswer"];
  }

  void testData(){
    print(question);
    print(options);
    print(correctAnswer);
  }

}


void main(){
  requestGPT(advance_flutter);
  
}