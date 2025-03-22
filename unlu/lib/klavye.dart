import 'package:flutter/material.dart';

class Klavye extends StatelessWidget {
  const Klavye({super.key, required this.onKeyPressed});

  final Function(String) onKeyPressed;

  @override
  Widget build(BuildContext context) {
    // Klavye tuşları
    List<String> keys = [
      'Q',
      'W',
      'E',
      'R',
      'T',
      'Y',
      'U',
      'I',
      'O',
      'P',
      "Ğ",
      "Ü",
      'A',
      'S',
      'D',
      'F',
      'G',
      'H',
      'J',
      'K',
      'L',
      "Ş",
      "İ",
      'Z',
      'X',
      'C',
      'V',
      'B',
      'N',
      'M',
      'Ö',
      'Ç',
      'Sil'
    ];

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 12,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: keys.length,
        itemBuilder: (context, index) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (keys[index] == 'Sil') {
                  onKeyPressed("Backspace");
                } else {
                  onKeyPressed(keys[index]);
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.white.withOpacity(0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF6C63FF).withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    keys[index],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: keys[index] == 'Sil'
                          ? Colors.red
                          : const Color(0xFF6C63FF),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
