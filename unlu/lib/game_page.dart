import 'package:flutter/material.dart';
import 'dart:async';
import 'klavye.dart';
import 'dart:math';

class GamePage extends StatefulWidget {
  final String resimYolu;

  const GamePage({super.key, required this.resimYolu});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  double _factor = 0;
  late Timer _timer;
  late Timer _hintTimer;
  String textfieldici = "";
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;
  bool _isCorrect = false;
  bool _showResult = false;
  String? _dogruIsim;
  Set<int> _revealedIndices =
      {}; // Gösterilen harflerin indekslerini tutacak set
  final Random _random = Random();

  // Ünlü isimleri ve resim yolları eşleştirmesi
  final Map<String, String> _unluIsimleri = {
    'lib/resimler/1.jpg': 'BURAK ÖZÇİVİT',
    'lib/resimler/2.jpg': 'TÜRKAN ŞORAY',
    'lib/resimler/3.jpg': 'SİNEM KOBAL',
    'lib/resimler/4.jpg': 'ARAS BULUT İYNEMLİ',
    'lib/resimler/5.jpg': 'ENGİN ALTAN DÜZYATAN',
    'lib/resimler/6.jpg': 'SİNEM ÜLBEĞİ',
    'lib/resimler/7.jpg': 'FAHRİYE EVCEN',
    'lib/resimler/8.jpg': 'ESRA BİLGİÇ',
    'lib/resimler/9.jpg': 'ÇAĞLAR ERTUĞRUL',
    'lib/resimler/10.jpg': 'KENAN İMİRZALIOĞLU',
    'lib/resimler/11.jpg': 'ÇAĞATAY ULUSOY',
    'lib/resimler/12.jpg': 'MERVE BOLUĞUR',
    'lib/resimler/13.jpg': 'TUNCEL KURTİZ',
    'lib/resimler/14.jpg': 'BENSU SORAL',
    'lib/resimler/15.jpg': 'ONUR TUNA',
    'lib/resimler/16.jpg': 'KENAN ÖZTÜRK',
    'lib/resimler/17.jpg': 'MELİSA ASLI PAMUK',
    'lib/resimler/18.jpg': 'KAAN URGANCIOĞLU',
    'lib/resimler/19.jpg': 'MERT YAZICIOĞLU',
    'lib/resimler/20.jpg': 'ŞAHAN GÖKBAKAR',
    'lib/resimler/21.jpg': 'KEREM BÜRSİN',
    'lib/resimler/22.jpg': 'SERENAY SARIKAYA',
  };

  @override
  void initState() {
    super.initState();
    _startTimer();
    _startHintTimer();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    // Doğru ismi al
    _dogruIsim = _unluIsimleri[widget.resimYolu];
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _factor += 0.004;
        if (_factor >= 1) {
          _timer.cancel();
        }
      });
    });
  }

  void _startHintTimer() {
    _hintTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (_dogruIsim != null &&
          !_showResult &&
          _revealedIndices.length < _dogruIsim!.length) {
        setState(() {
          // Henüz gösterilmemiş ve kullanıcının yazmadığı rastgele bir indeks seç
          int randomIndex;
          int denemeSayisi = 0;
          do {
            randomIndex = _random.nextInt(_dogruIsim!.length);
            denemeSayisi++;
            if (denemeSayisi > 10) break; // Sonsuz döngüyü engelle
          } while (_revealedIndices.contains(randomIndex) ||
              _dogruIsim![randomIndex] == ' ' ||
              (randomIndex < textfieldici.length &&
                  textfieldici[randomIndex] == _dogruIsim![randomIndex]));

          if (denemeSayisi <= 10) {
            _revealedIndices.add(randomIndex);
          }
        });
      } else {
        _hintTimer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _hintTimer.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _handleKeyPress(String key) {
    if (_showResult) return;

    setState(() {
      if (key == 'Backspace' && textfieldici.isNotEmpty) {
        textfieldici = textfieldici.substring(0, textfieldici.length - 1);
        _isCorrect = false;
      } else if (key != 'Backspace') {
        String yeniHarf = key.toUpperCase();
        if (_dogruIsim != null && textfieldici.length < _dogruIsim!.length) {
          // Eğer doğru isimde bu pozisyonda boşluk varsa, otomatik olarak boşluk ekle
          if (textfieldici.length < _dogruIsim!.length &&
              _dogruIsim![textfieldici.length] == ' ') {
            textfieldici += ' ';
          }

          textfieldici += yeniHarf;
          _controller.forward().then((_) => _controller.reverse());

          // Eğer yeni pozisyonda boşluk varsa, onu da otomatik ekle
          if (textfieldici.length < _dogruIsim!.length &&
              _dogruIsim![textfieldici.length] == ' ') {
            textfieldici += ' ';
          }

          // İsmi kontrol et
          if (_dogruIsim != null && textfieldici.length == _dogruIsim!.length) {
            if (textfieldici == _dogruIsim) {
              _isCorrect = true;
              _showResult = true;
              _hintTimer.cancel();
              _revealedIndices.clear();
            }
          }
        }
      }
    });
  }

  void _resetGame() {
    if (_showResult) {
      // Yeni rastgele bir ünlü seç
      final random = Random();
      final randomResim = 'lib/resimler/${random.nextInt(22) + 1}.jpg';

      // Yeni sayfaya git
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GamePage(resimYolu: randomResim),
        ),
      );
    } else {
      // Sadece kullanıcının yazdığı harfleri temizle
      setState(() {
        textfieldici = "";
        _isCorrect = false;
        _showResult = false;
        // _revealedIndices.clear(); // Gösterilen harfleri temizleme
      });
      _startHintTimer(); // Yeni ipucu zamanlayıcısını başlat
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ünlü Bilmece',
          style: TextStyle(
            color: Color(0xFF6C63FF),
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6C63FF)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF6C63FF).withOpacity(0.3),
              const Color(0xFF6C63FF).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Logo Alanı
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: _factor + 0.05,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6C63FF).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          widget.resimYolu,
                          fit: BoxFit.contain,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Sonuç Mesajı
              if (_showResult)
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isCorrect
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isCorrect ? Colors.green : Colors.red,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isCorrect ? Icons.check_circle : Icons.cancel,
                        color: _isCorrect ? Colors.green : Colors.red,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isCorrect
                            ? 'Tebrikler! Doğru bildiniz!'
                            : 'Yanlış! Tekrar deneyin.',
                        style: TextStyle(
                          color: _isCorrect ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

              // Harf Kutucukları
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final boxSize = (constraints.maxWidth - 32 - 24) / 9;
                          // İsmi kelimelere ayır
                          final kelimeler = _dogruIsim?.split(' ') ?? [];

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(kelimeler.length * 2 - 1,
                                (index) {
                              if (index.isOdd) {
                                return const SizedBox(height: 24);
                              }
                              final kelimeIndex = index ~/ 2;
                              final kelime = kelimeler[kelimeIndex];

                              // Önceki kelimelerin toplam uzunluğunu hesapla
                              int oncekiUzunluk = 0;
                              for (int i = 0; i < kelimeIndex; i++) {
                                oncekiUzunluk += kelimeler[i].length;
                                if (i < kelimeIndex)
                                  oncekiUzunluk++; // Boşluk için
                              }

                              return Center(
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  child: GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 6, // Daha az sütun
                                      mainAxisSpacing: 8,
                                      crossAxisSpacing: 8,
                                      childAspectRatio: 1, // Kare kutucuklar
                                    ),
                                    itemCount: kelime.length,
                                    itemBuilder: (context, index) {
                                      final currentIndex =
                                          oncekiUzunluk + index;
                                      String harf = '';
                                      bool isUserEntered = false;
                                      bool isHint = false;

                                      if (currentIndex < textfieldici.length) {
                                        // Kullanıcının girdiği harf
                                        harf = textfieldici[currentIndex];
                                        isUserEntered = true;
                                      } else if (_revealedIndices
                                          .contains(currentIndex)) {
                                        // İpucu olarak gösterilen harf
                                        harf = _dogruIsim![currentIndex];
                                        isHint = true;
                                      }

                                      return AnimatedBuilder(
                                        animation: _bounceAnimation,
                                        builder: (context, child) {
                                          return Transform.scale(
                                            scale: currentIndex ==
                                                    textfieldici.length - 1
                                                ? _bounceAnimation.value
                                                : 1.0,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Colors.white,
                                                    Colors.white
                                                        .withOpacity(0.9),
                                                  ],
                                                ),
                                                border: Border.all(
                                                  color:
                                                      const Color(0xFF6C63FF),
                                                  width: 2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color:
                                                        const Color(0xFF6C63FF)
                                                            .withOpacity(0.2),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: Text(
                                                  harf,
                                                  style: TextStyle(
                                                    fontSize: 28,
                                                    fontWeight: FontWeight.bold,
                                                    color: isUserEntered
                                                        ? const Color(
                                                            0xFF6C63FF) // Kullanıcının yazdığı harfler mavi
                                                        : isHint
                                                            ? Colors
                                                                .green // İpucu harfleri yeşil
                                                            : const Color(
                                                                0xFF6C63FF), // Diğer harfler mavi
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // Alt Butonlar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6C63FF).withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _resetGame,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Temizle'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF6C63FF),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6C63FF).withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _showResult ? _resetGame : null,
                        icon: const Icon(Icons.check),
                        label: const Text('Tamamla'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Klavye(
          onKeyPressed: _handleKeyPress,
        ),
      ),
    );
  }
}
