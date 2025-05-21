import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget cardDataInsight({required String title, required int amount}) {
  return Column(
    children: [
      Container(
        width: 275,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.amber.shade50,
        ),
        child: Column(
          children: [
            Text(
              title,
              style: GoogleFonts.dmSans(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              amount.toString(),
              style: GoogleFonts.dmSans(
                color: Colors.black,
                fontSize: 32,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}