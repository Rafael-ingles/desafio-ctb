import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const  DesafioCTBApp());
}

class  DesafioCTBApp  extends StatelessWidget {
  const DesafioCTBApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desafio CTB',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      home: const HomePage(),
    );
  }
}

class Question {
  final String id;
  final String module;
  final String difficulty;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String legalBasis;

  Question({
    required this.id,
    required this.module,
    required this.difficulty,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.legalBasis,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id']?.toString() ?? '',
      module: json['module']?.toString() ?? '',
      difficulty: json['difficulty']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctIndex: json['correct_index'] is int
          ? json['correct_index']
          : int.tryParse(json['correct_index']?.toString() ?? '0') ?? 0,
      explanation: json['explanation']?.toString() ?? '',
      legalBasis: json['legal_basis']?.toString() ?? '',
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Question> questions = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    try {
      final data = await rootBundle.loadString('assets/questions.json');
      final decoded = jsonDecode(data);

      final List<dynamic> list = decoded['questions'];

      setState(() {
        questions = list
            .map((item) => Question.fromJson(item))
            .toList();
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = 'Não foi possível carregar as questões.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Desafio CTB'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Desafio CTB',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              const Icon(
                Icons.directions_car,
                size: 80,
                color: Colors.blue,
              ),

              const SizedBox(height: 20),

              const Text(
                'Desafio CTB',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Aprenda e teste seus conhecimentos '
                'sobre a legislação de trânsito brasileira.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 35),

               _InfoCard( 
                icon: Icons.quiz,
                title: 'Questões disponíveis',
                value: '${questions.length}',
              ),

              const SizedBox(height: 14),

              _InfoCard(
                icon: Icons.school,
                title: 'Modo de estudo',
                value: 'Quiz',
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton.icon(
                  onPressed: questions.isEmpty
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QuizPage(
                                questions: questions,
                              ),
                            ),
                          );
                        },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text(
                    'COMEÇAR DESAFIO',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Desafio CTB • Versão 0.2',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const  _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class QuizPage extends StatefulWidget {
  final List<Question> questions;

  const QuizPage({
    super.key,
    required this.questions,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentIndex = 0;
  int score = 0;
  int? selectedAnswer;
  bool answered = false;

  Question get currentQuestion => widget.questions[currentIndex];

  void selectAnswer(int index) {
    if (answered) return;

    setState(() {
      selectedAnswer = index;
      answered = true;

      if (index == currentQuestion.correctIndex) {
        score++;
      }
    });
  }

  void nextQuestion() {
    if (currentIndex == widget.questions.length - 1) {
      Navigator.pushReplacement(
        context,
          MaterialPageRoute(  
          builder: (_) => ResultPage(
            score: score,
            total: widget.questions.length,
          ),
        ),
      );
      return;
    }

    setState(() {
      currentIndex++;
      selectedAnswer = null;
      answered = false;
    });
  }

  Color optionColor(int index) {
    if (!answered) {
      return Colors.white;
    }

    if (index == currentQuestion.correctIndex) {
      return Colors.green.shade100;
    }

    if (index == selectedAnswer) {
      return Colors.red.shade100;
    }

    return Colors.white;
  }

  IconData? optionIcon(int index) {
    if (!answered) return null;

    if (index == currentQuestion.correctIndex) {
      return    Icons.check_circle;  
    }

    if (index == selectedAnswer) {
      return Icons.cancel;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final question = currentQuestion;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Questão ${currentIndex + 1} de ${widget.questions.length}',
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
              children: [  
              LinearProgressIndicator(
                value:
                    (currentIndex + 1) / widget.questions.length,
              ),

              const SizedBox(height: 18),

              Row(
                  children: [  
                  Chip(
                    label: Text(question.module),
                  ),
                  const SizedBox(width: 8),
                   Chip( 
                    label: Text(question.difficulty),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Text(
                question.question,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: ListView.builder(
                  itemCount: question.options.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: optionColor(index),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                              borderRadius: BorderRadius.circular(      12),
                        onTap: () => selectAnswer(index),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                             children: [ 
                              CircleAvatar(
                                child: Text(
                                  String.fromCharCode(
                                    65 + index,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  question.options[index],
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              if (optionIcon(index) != null)
                                Icon(
                                  optionIcon(index),
                                  color: index ==
                                          question.correctIndex
                                      ? Colors.green
                                      : Colors.red,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              if (answered) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                               crossAxisAlignment:         
                          CrossAxisAlignment.start,
                        children: [  
                        Text(
                          selectedAnswer ==
                                  question.correctIndex
                              ? 'Resposta correta! ✅'
                              : 'Resposta incorreta. ❌',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (question.explanation.isNotEmpty)
                          Text(question.explanation),
                        if (question.legalBasis.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                              'Base legal: ${question.legalBasis}', 'Base legal: ${question.legalBasis}', 'Base legal: ${question.legalBasis}', 'Base legal: ${question.legalBasis}',
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: nextQuestion,
                    child: Text(
                      currentIndex ==
                              widget.questions.length - 1
                                                                   ?   RESULTADO                   'VER RESULTADO'VER RESULTADO' 'VER RESULTADO'      'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'   'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'    'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'   'VE 'VER RESULTADO'VER RESULTADO' 'VER RESULTADO'      'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'   'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'    'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'   'VER   'VER RESULTADO'VER RESULTADO' 'VER RESULTADO'      'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'   'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'    'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'   'VER R E S U L T ADO 'VER RESULTADO'VER RESULTADO' 'VER RESULTADO'      'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'   'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'    'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'   'VER RESULTADO'  'VER 'VER RESULTADO'VER RESULTADO' 'VER RESULTADO'      'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'   'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'    'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'   'VER RESULTADO' 'VER RESU 'VER RESULTADO'VER RESULTADO' 'VER RESULTADO'      'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'   'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'    'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'   'VER RESULTADO' 'VER RESUL 'VER RESULTADO'VER RESULTADO' 'VER RESULTADO'      'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'   'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'    'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'   'VER RESULTADO' 'VER RESULTADOTADO'   '  VER    'VER RESULTADO'VER RESULTADO' 'VER RESULTADO'      'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'   'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'    'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'   'VER RESULTADO' 'VER RESULTADO' 'VER   RESULTADO  RESULTADO' 'VER  VER    'VER RESULTADO'VER RESULTADO' 'VER RESULTADO'      'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  'VER RESULTADO' 'VER RESULTADO' 'VER RESU                                                      ?   RESULTADO          'VER RESULTADO'VER RESULTADO' 'VER RESULTADO'      'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'   'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'    'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  'VER                                                         ?   RESULTADO          'VER RESULTADO'VER RESULTADO' 'VER RESULTADO'      'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'   'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'    'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'                                                          ?   RESULTADO          'VER                                                                 ?   RESULTADO                'VER RESULTADO' 'VER RESULTADO'      'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'   'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'    'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'                                                                ?   RESULTADO              RES SULTADO'  'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'   'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'    'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'   'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  'O'  'VER RESULTADO' 'VER  'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'   'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'    'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'   'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  ''VER RESULTADO'' 'VER  RES'  'VER RESULTADO' 'VER  'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'   'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'    'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'   'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO' 'VER RESULTADO'  ''VER RESULTADO'' 'VER  RESULTADO' 'VER RESULTADO' 'VER RESULTADO'     ' 'VER  RESULTADO' 'VER RESULTADO' 'VER RESULTADO'    
                                                                        :                                                                 :  'PRÓXIMA QUESTÃO', PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA  :                                                                 :  'PRÓXIMA QUESTÃO', PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA Q U 'PRÓXIMA QUESTÃO', PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUE S T Ã O,  'PRÓXIMA QUESTÃO', PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  IMA QUESTÃOPRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  IMA QUESTÃO',  'PRÓXIMA QUESTÃO , PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  IMA QUESTÃO',  ', PRÓXIMA QUESTÃO, PRÓXIMA QUEPRÓXIMA QUESTÃO , PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  IMA QUESTÃO',  TÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QU                                                                     :                                                                 :  'PRÓXIMA QUESTÃO', PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, P                                                                       :                                                                 :  'PRÓXIMA QUESTÃO', PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃ                                                                       :                                                                 :  'PRÓXIMA QUESTÃO', PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUEST                                                                        :                                                                 :  'PRÓXIMA QUESTÃO', PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA  A QUESTÃO', 'PRÓXIMA QUESTÃO',  'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO',  'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO',  'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO',  'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO',  PRÓXIMA QUESTÃO  PRÓXIMA QUESTÃOPRÓXIMA QUESTÃOPRÓXIMA QUESTÃO', ',  PRÓXIMA QUESTÃO  PRÓXIMA QUESTÃOPRÓXIMA QUESTÃOPRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO',  'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO',  'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO',  'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO',  'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO',  'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO',  'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTPRÓXIMA QUESTÃO',  'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO',  'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO',  'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO',  'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO',  'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO',  'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO',  'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO', 'PRÓXIMA QUESTÃO', 
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ResultPage extends StatelessWidget {
  final int score;
  final int total;

  const ResultPage({
    super.key,
    required this.score,
    required this.total,
  });

  String get message {
    final percentage = score / total;

    if         (percentage >=         0.9) {
                return ''Excelente! Você domina o conteúdo.''; return ''Excelente! Você domina o conteúdo.'';   return 'Excelente! Você domina o conteúdo.'; return 'Excelente! Você domina o conteúdo.';   return 'Excelente! Você domina o conteúdo.'; return 'Excelente! Você domina o conteúdo.';   return 'Excelente! Você domina o conteúdo.'; return 'Excelente! Você domina o conteúdo.';   return 'Excelente! Você domina o conteúdo.'; return 'Excelente! Você domina o conteúdo.';   return 'Excelente! Você domina o cont  return 'Excelente! Você domina o conteúdo.'; Excelente! Você domina o conteúdo.  'Excelente! Você domina o conteúdo.';   Excelente! Você domina o conteúdo.  'Excelente! Você domina o conteúdo.'; Excelente! Você domina o conteúdo.  'Excelente! Você domina o conteúdo.';   Excelente! Você domina o conteúdo.  'Excelente! Você domina o conteúdo.'; Excelente! Você domina o conteúdo.  'Excelente! Você domina o conteúdo.';   Excelente! Você domina o conteúdo.  'Excelente! Você domina o conteúdo.'; Excelente! Você domina o conteúdo.  'Excelente! Você domina o conteúdo.';   Excelente! Você domina o conteúdo.  'Excelente! Você domina o conteúdo.'; Excelente! Você domina o conteúdo.  'Excelente! Você domina o conteúdo.';   Excelente! Você domina o conteúdo.  'Excelente! Você domina o conte  return 'Exc                                                                  :                                                                 :  'PRÓXIMA QUESTÃO', PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃO,  PRÓXIMA QUESTÃO, PRÓXIMA QUESTÃ ê domina o conteúdo.PRÓXIMA QUESTÃOExcelente! Você domina o conteúdo.';   return 'Excelente! Você domina o conteúdo.'; return 'Excelente! Você domina o conteúdo.';   return 'Excelente! Você domina o conteúdo.'; return 'Excelente! Você domina o conteúdo.';   return 'Excelente! Você domina o conteúdo.'; return 'Excelente! Você domina o conteúdo.';   return 'Excelente! Você domina o conteúdo.'; return 'Excelente! Você domina o conteúdo.';   return '  Excelente! Você domina o conteúd    return 'Excelente! Você domina o conteúdo.'; Excelente! Você domina o conteúdo. 'Excelente! Você domina o conteúdo.';   Excelente! Você domina o conteúdo. 'Excelente! Você domina o conteúdo.'; Excelente! Você domina o conteúdo. 'Excelente! Você domina o conteúdo.';   Excelente! Você domina o conteúdo. 'Excelente! Você domina o conteúdo.'; Excelente! Você domina o conteúdo. 'Excelente! Você domina o conteúdo.';   Excelente! Você domina o conteúdo. 'Excelente! Você domina o conteúdo.'; Excelente! Você domina o conteúdo. 'Excelente! Você domina o conteúdo.'údo. 'Excelente! Você domina o conteúdo.';   Excelente! Você domina o conteúdo. '  na o conteúdo.  'Excelente! Você domina o conteúdo.';   Excelente! Você domina o conteúdo.  'Excelente! Você domina o conteúdo.'; Excelente! Você domina o conteúdo.  'Excelente! Você domina o conteúdo.';   Excelente! Você domina o conteúdo.  'Excelente! Você domina o conteúdo.';  o.'; return 'Excelente! Você domina o conteúdo.';   return 'Excelente! Você domina o conteúdo.'; return 'Excelente! Você domina o conteúdo.';   retu'  na o conteúdo.  'Excelente! Você domina o conteúdo.';   Excelente! Você domina o conteúdo.  'Excelente! Você domina o conteúdo.'; Excelente! Você domina o conteúdo.  'Excelente! Você domina o conteúdo.';   Excelente! Você domina o conteúdo.  'Excelente! Você domina o conteúdo.';  o.'; return 'Excelente! Você domina o conteúdo.';   return 'Excelente! Você domina o conteúdo.'; return 'Excelente! Você domina o conteúdo.';   return 'Excelente! Você domina o conteúdo.'; return 'Excelente! Você domina o conteúdo.';   '; Excelente! Você domina o conteúdo.  'Excelente! Você domina o conteúdo.';   Excelente! Você domina o conteúdo.  'Excelente! Você domina o conteúdo.';  o.'; return 'Excelente! Você domina o conteúdo.';   return 'Excelente! Você domina o conteúdo.'; return 'Excelente! Você domina o conteúdo.';   return 'Excelente! Você domina o conteúdo.'; return 'Excelente! Você domina o conteúdo.';    'Excelente! Você domina o conteúdo.';   return 'Excelente! Você domina o conteúdo.'; return 'Excelente! Você domina o conteúdo.';   return 'Excelente! Você domina o conteúdo.'; return 'Excelente! Você domina o conteúdo.';  
Excelente! Você domina o conteúdo.}

      Excelente! Você domina o conteúdo. Excelente! Você domina o conteúdo. 
                 return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; retu return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; retur n   return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return ' return 'Muito bom! Continue estudando.'          ; Muito bom! Continue estudando.            'Muito bom! Continue estudando.'          ; Muito bom! Continue estudando.            'Muito bom! Continue estudando.'; Muito bom! Continue estudando. 'Muito bom! Continue estudando.'; Muito bom! Continue estudando. 'Muito bom! Continue estudando.'; Muito bom! Continue estudando. 'Muito bom! Continue estudando.'; Muito bom! Continue estudando. 'Muito bom! Continue estudando.'; Muito bom! Continue estudando. 'Muito bom! Continue estudando.'; Muito bom! Continue estudando. 'Muito bom! Continue estudando.'; Muito bom! Continue estudando. 'Muito bom! Continue estudando.'; Muito bom! Continue estudando. tinue estudando. 'Muito bom! Continue estudando.'; Muito bom! Continue estudando. 'Muito bom! Continue estudando.'; Muito bom! Continue estudando. 'Muito bom! Continue estudando.'; Muito bom! Continue estudando.               return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return  ; Muito bom! Continue estudando. 'M return ''Muito bom! Continue estudando.''; return ''Muito bom! Continue estudando.''; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Cont; Muito bom! Continue estudando. 'Muito bom! Continue estudando.'; Muito bom! Continue estudando. 'M return ''Muito bom! Continue estudando.''; return ''Muito bom! Continue estudando.''; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'u returnMuito bom! Continue estudando.'Muito bom! Continue estudando.'Muito bom! Continue estudando.'Muito bom! Continue estudando.' 'Muito bom! Continue estudando.'; 'Muito bom! Continue estudando.' 'Muito bom! Continue estudando.'; 'Muito bom! Continue estudando.' 'Muito bom! Continue estudando.'; 'Muito bom! Continue estudando.' 'Muito bom! Continue estudando.'; 'Muito bom! Continue estudando.' 'Muito bom! Continue estudando.'; 'Muito bom! Continue estudando.' 'Muito bom! Continue estudando.'; 'Muito bom! Continue estudando.' 'Muito bom! Continue estudando.'; 'Muito bom! Continue estudando.' 'Muito bom! Continue estudando.'; 'Muito bom! Continue estudando.' 'Muito bom! Continue estudando.'; 'Muito bom! Continue estudando.' 'Muito bom! Continue estudando.'; 'Muito bom! Continue estudando.' 'Muito bom! Continue estudando.'; 'Muito bom! Continue estudando.' 'ito bom! Creturn 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'ito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.'; return 'Muito bom! Continue estudando.';'Muito bom! Continue estudando.'Muito bom! Continue estudando.' ; Muito bom! Continue estudando.   
   
