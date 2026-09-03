import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const DesafioCTBApp());
}

class DesafioCTBApp extends StatelessWidget {
  const DesafioCTBApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:'Desafio CTB - Resoluções e Atualizações',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B5CAD),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF2F4F7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF102A43),
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
        cardTheme: const CardThemeData(
          elevation: 1,
          margin: EdgeInsets.zero,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class Category {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String key;

  const Category({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.key,
  });
}

const categories = [
  Category(
    title: 'Multas e Infrações',
    description: 'Infrações, pontos, multas e penalidades.',
    icon: Icons.warning_rounded,
    color: Color(0xFFC62828),
    key: 'multas',
  ),
  Category(
    title: 'Código de Trânsito Brasileiro',
    description: 'Estude os principais temas e artigos do CTB.',
    icon: Icons.menu_book_rounded,
    color: Color(0xFF1565C0),
    key: 'ctb',
  ),
  Category(
    title: 'Sistema Nacional de Trânsito',
    description: 'Órgãos, competências, fiscalização e SNT.',
    icon: Icons.account_balance_rounded,
    color: Color(0xFF6A1B9A),
    key: 'snt',
  ),
  Category(
    title: 'Circulação e Conduta',
    description: 'Regras de circulação e comportamento.',
    icon: Icons.directions_car_rounded,
    color: Color(0xFF00695C),
    key: 'circulacao',
  ),
  Category(
    title: 'Resoluções do CONTRAN',
    description: 'Resoluções, alterações e normas do CONTRAN.',
    icon: Icons.gavel_rounded,
    color: Color(0xFFEF6C00),
    key: 'contran',
  ),
];

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _openCategory(BuildContext context, Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizPage(
          category: category,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DESAFIO CTB',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Atualizar resoluções',
            icon: const Icon(Icons.system_update_alt_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const UpdatesPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 30),
          children: [
            _HeaderCard(),
            const SizedBox(height: 22),
            const Text(
              'Escolha uma área',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF172B4D),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Estude legislação de trânsito e teste seus conhecimentos.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF5B677A),
              ),
            ),
            const SizedBox(height: 16),
            ...categories.map(
              (category) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CategoryCard(
                  category: category,
                  onTap: () => _openCategory(context, category),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _UpdateBanner(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UpdatesPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 18),
            const Center(
              child: Text(
                'Desafio CTB • Preparação em legislação de trânsito',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF7A869A),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF102A43),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.traffic_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DESAFIO CTB',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Conhecimento • Legislação • Trânsito',
                  style: TextStyle(
                    color: Color(0xFFD9E2EC),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE1E6ED),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  category.icon,
                  color: category.color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF172B4D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B778C),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF7A869A),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpdateBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _UpdateBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE8F1FB),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              const Icon(
                Icons.update_rounded,
                color: Color(0xFF1565C0),
                size: 30,
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Atualizações',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: Color(0xFF123A63),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Verifique se há novas normas e questões.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF486581),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Color(0xFF1565C0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UpdatesPage extends StatelessWidget {
  const UpdatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Atualizações',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFE1E6ED),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.cloud_download_rounded,
                  size: 40,
                  color: Color(0xFF1565C0),
                ),
                SizedBox(height: 16),
                Text(
                  'Legislação do aplicativo',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF172B4D),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Esta área será usada para verificar e instalar '
                  'novas questões, alterações do CTB e atualizações '
                  'das Resoluções do CONTRAN.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Color(0xFF5B677A),
                  ),
                ),
                SizedBox(height: 20),
                Divider(),
                SizedBox(height: 14),
                Text(
                  'Versão do conteúdo',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7A869A),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Base inicial • 2026',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF172B4D),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: () {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Verificando atualizações das Resoluções do CONTRAN...',
      ),
    ),
  );
},
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
                'VERIFICAR ATUALIZAÇÕES',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Objetivo da atualização',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF172B4D),
            ),
          ),
          const SizedBox(height: 10),
          _UpdateItem(
            icon: Icons.menu_book_rounded,
            title: 'CTB',
            text: 'Atualizar questões e referências legais.',
          ),
          _UpdateItem(
            icon: Icons.gavel_rounded,
            title: 'Resoluções do CONTRAN',
            text: 'Adicionar novas resoluções e alterações.',
          ),
          _UpdateItem(
            icon: Icons.quiz_rounded,
            title: 'Banco de questões',
            text: 'Adicionar novas perguntas ao desafio.',
          ),
        ],
      ),
    );
  }
}

class _UpdateItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _UpdateItem({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE1E6ED),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF1565C0),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF172B4D),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B778C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;
  final String legalBasis;
  final String module;
  final String difficulty;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.legalBasis,
    required this.module,
    required this.difficulty,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];

    return QuizQuestion(
      question: '${json['question'] ?? ''}',
      options: rawOptions is List
          ? rawOptions.map((e) => '$e').toList()
          : const [],
      correctAnswer: int.tryParse('${json['correct_index'] ?? json['correctAnswer'] ?? 0}') ?? 0,
      explanation: '${json['explanation'] ?? ''}',
      legalBasis: '${json['legalBasis'] ?? ''}',
      module: '${json['module'] ?? ''}',
      difficulty: '${json['difficulty'] ?? 'Médio'}',
    );
  }
}

class QuizPage extends StatefulWidget {
  final Category category;

  const QuizPage({
    super.key,
    required this.category,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<QuizQuestion> questions = [];
  bool loading = true;
  int current = 0;
  int? selected;
  int score = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final data = await rootBundle.loadString('assets/questions.json');
      final decoded = jsonDecode(data);

      final list = decoded is List
          ? decoded
          : decoded is Map && decoded['questions'] is List
              ? decoded['questions']
              : [];

      final all = list
          .whereType<Map>()
          .map(
            (item) => QuizQuestion.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();

      final filtered = all.where(_matchesCategory).toList();

      setState(() {
        questions = filtered.isNotEmpty ? filtered : all;
        loading = false;
      });
    } catch (_) {
      setState(() {
        loading = false;
      });
    }
  }

  bool _matchesCategory(QuizQuestion q) {
    final text = '${q.module} ${q.question}'.toLowerCase();

    switch (widget.category.key) {
      case 'multas':
        return text.contains('multa') ||
            text.contains('infração') ||
            text.contains('infracao') ||
            text.contains('penalidade');
      case 'ctb':
        return text.contains('ctb') ||
            text.contains('código') ||
            text.contains('codigo');
      case 'snt':
        return text.contains('sistema nacional') ||
            text.contains('contran') ||
            text.contains('senatran') ||
            text.contains('cetran');
      case 'circulacao':
        return text.contains('circulação') ||
            text.contains('circulacao') ||
            text.contains('conduta') ||
            text.contains('ultrapassagem');
      case 'contran':
        return text.contains('resolução') ||
            text.contains('resolucao') ||
            text.contains('contran');
      default:
        return true;
    }
  }

  void _selectAnswer(int index) {
    if (selected != null) return;

    setState(() {
      selected = index;
      if (index == questions[current].correctAnswer) {
        score++;
      }
    });
  }

  void _next() {
    if (current >= questions.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultPage(
            score: score,
            total: questions.length,
          ),
        ),
      );
      return;
    }

    setState(() {
      current++;
      selected = null;
    });
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

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.category.title),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Nenhuma questão disponível nesta categoria.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17),
            ),
          ),
        ),
      );
    }

    final question = questions[current];
    final progress = (current + 1) / questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'QUESTÃO ${current + 1} DE ${questions.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF52606D),
                ),
              ),
              Text(
                'Pontos: $score',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1565C0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _Chip(
                text: widget.category.title,
                icon: widget.category.icon,
              ),
              const SizedBox(width: 8),
              _Chip(
                text: question.difficulty,
                icon: Icons.speed_rounded,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            question.question,
            style: const TextStyle(
              fontSize: 20,
              height: 1.35,
              fontWeight: FontWeight.w800,
              color: Color(0xFF172B4D),
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(
            question.options.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _AnswerCard(
                letter: String.fromCharCode(65 + index),
                text: question.options[index],
                selected: selected == index,
                correct: selected != null &&
                    index == question.correctAnswer,
                wrong: selected == index &&
                    index != question.correctAnswer,
                onTap: () => _selectAnswer(index),
              ),
            ),
          ),
          if (selected != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFD9E2EC),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'EXPLICAÇÃO',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    question.explanation.isEmpty
                        ? 'Confira a alternativa correta e a legislação aplicável.'
                        : question.explanation,
                    style: const TextStyle(
                      height: 1.45,
                      color: Color(0xFF364152),
                    ),
                  ),
                  if (question.legalBasis.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const Text(
                      'BASE LEGAL',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      question.legalBasis,
                      style: const TextStyle(
                        height: 1.4,
                        color: Color(0xFF52606D),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _next,
                child: Text(
                  current == questions.length - 1
                      ? 'VER RESULTADO'
                      : 'PRÓXIMA QUESTÃO',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final IconData icon;

  const _Chip({
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1FB),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: const Color(0xFF1565C0),
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF123A63),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  final String letter;
  final String text;
  final bool selected;
  final bool correct;
  final bool wrong;
  final VoidCallback onTap;

  const _AnswerCard({
    required this.letter,
    required this.text,
    required this.selected,
    required this.correct,
    required this.wrong,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color background = Colors.white;
    Color border = const Color(0xFFD9E2EC);
    Color circle = const Color(0xFF102A43);

    if (correct) {
      background = const Color(0xFFE8F5E9);
      border = const Color(0xFF43A047);
      circle = const Color(0xFF2E7D32);
    } else if (wrong) {
      background = const Color(0xFFFFEBEE);
      border = const Color(0xFFE53935);
      circle = const Color(0xFFC62828);
    }

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: border, width: 1.2),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: circle,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  letter,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    color: Color(0xFF27364B),
                  ),
                ),
              ),
              if (correct)
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF2E7D32),
                ),
              if (wrong)
                const Icon(
                  Icons.cancel_rounded,
                  color: Color(0xFFC62828),
                ),
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

  @override
  Widget build(BuildContext context) {
    final percentage = total == 0 ? 0 : (score / total * 100).round();

    String message;

    if (percentage >= 80) {
      message = 'Excelente desempenho.';
    } else if (percentage >= 60) {
      message = 'Bom resultado. Continue estudando.';
    } else {
      message = 'Revise o conteúdo e tente novamente.';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Resultado',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                size: 78,
                color: Color(0xFFEF6C00),
              ),
              const SizedBox(height: 18),
              const Text(
                'DESAFIO CONCLUÍDO',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF172B4D),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '$score / $total',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1565C0),
                ),
              ),
              Text(
                '$percentage% de aproveitamento',
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF6B778C),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF364152),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () {
                    Navigator.popUntil(
                      context,
                      (route) => route.isFirst,
                    );
                  },
                  child: const Text(
                    'VOLTAR AO INÍCIO',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
