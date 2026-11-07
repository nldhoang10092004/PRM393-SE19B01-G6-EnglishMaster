import 'package:english_master/features/quiz/data/models/quiz.dart';

/// Representative QuizDetailDto including acronym IDs and a shared passage.
Map<String, dynamic> quizJson() => {
  'quizID': 7,
  'title': 'Reading practice',
  'description': 'Everyday English',
  'quizType': 2,
  'isActive': true,
  'groups': [
    {
      'groupID': 3,
      'instruction': 'Read the passage.',
      'assets': [
        {
          'assetID': 8,
          'assetType': 1,
          'contentText': 'Anna goes to school by bus.',
          'url': null,
          'caption': 'A school day',
          'mimeType': 'text/plain',
        },
      ],
      'questions': [
        {
          'questionID': 10,
          'content': 'How does Anna travel?',
          'questionType': 1,
          'scoreWeight': 1,
          'metaJson': null,
          'assets': null,
          'options': [
            {'optionID': 11, 'content': 'By bus', 'isCorrect': true},
            {'optionID': 12, 'content': 'On foot', 'isCorrect': false},
          ],
        },
        {
          'questionID': 20,
          'content': 'Where does Anna go?',
          'questionType': 1,
          'options': [
            {'optionID': 21, 'content': 'School', 'isCorrect': true},
            {'optionID': 22, 'content': 'The park', 'isCorrect': false},
          ],
        },
      ],
    },
  ],
};

/// Result scores deliberately come from the server, not the detail answer key.
Map<String, dynamic> resultJson() => {
  'autoScore': 50.0,
  'totalQuestions': 2,
  'correctCount': 1,
  'wrongCount': 1,
  'essayCount': 0,
  'status': 'SUBMITTED',
  'results': [
    {
      'questionId': 10,
      'content': 'How does Anna travel?',
      'questionType': 1,
      'isCorrect': true,
      'submittedOptionId': 11,
      'submittedAnswerText': null,
      'correctOptions': [],
    },
    {
      'questionId': 20,
      'content': 'Where does Anna go?',
      'questionType': 1,
      'isCorrect': false,
      'submittedOptionId': 22,
      'correctOptions': [
        {'optionId': 21, 'content': 'School'},
      ],
    },
  ],
};

/// Builds a fresh immutable quiz for every test.
Quiz fixtureQuiz() => Quiz.fromJson(quizJson());
