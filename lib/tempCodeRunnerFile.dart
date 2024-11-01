class Quiz {
//   final String question;
//   final List<Options> options;
//   final String correctAnswer;
  
//   Quiz({required this.question, required this.correctAnswer,required this.options})
  
//   factory Quiz.fromjson(Map<String,dynamic> json){
//     var optionList = json['options'].toList();
//   	List<Options> option = optionList.Map((options)=> Options.fromJson(options)).toList();
//     return Quiz(
//       question: json['question'], 
//       options: option, 
//       correctAnswer : json['correctAnswer'], 
// );
//   }

// }
// class Options{
//   final String answer;
//   final String option; 
//   Options({required this.answer, required this.option})
//   factory Options.fromjson(List<String,String> jsonObject){
//     return Options(
//       answer: jsonObject.keys,
//       option: jsonObject.values
//       );
//   }
// }
