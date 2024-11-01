import 'dart:convert';
import 'package:http/http.dart' as http;

var advance_flutter = """
Generate a JSON file containing 10 unique multiple-choice questions related to advanced Flutter topics, such as state management and animations. Each question should include the question text, four distinct options, and the correct correctAnswer. Please ensure that these questions are varied and not repetitive from any previous requests.
""";

//jsonDecode is use to convert from json data into object in dart, but since our Json Data is nested data, we need multiple function to extract them one by one

List<Quiz> convertJsonToObject(String jsonDatas) {  
  print("check1");
  List<dynamic> jsonDataList = jsonDecode(jsonDatas);
  print("check2");

  return jsonDataList.map((jsonData) => Quiz.fromjson(jsonData)).toList();
}

class Quiz {
  final String question;
  final List<String> options;
  final String correctAnswer;
  
  Quiz({required this.question, required this.correctAnswer,required this.options});
  
  factory Quiz.fromjson(Map<String,dynamic> json){
    
    List<String> optionList = List<String>.from(json['options']);
    
    return Quiz(
      question: json['question'], 
      options: optionList, 
      correctAnswer : json['correctAnswer'], 
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
  final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey');
  try{
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
  }} catch (e){
    rethrow;
  }
  return "error No data";
}  

void main() async{
 var text = await requestGPT('advance_flutter'); 
 List<Quiz> quizzes = convertJsonToObject(text);

  for (var quiz in quizzes) {
    print('Question: ${quiz.question}');
    print('Options: ${quiz.options[1]}');
    print('Correct Answer: ${quiz.correctAnswer}');
    print('---');
  }
}