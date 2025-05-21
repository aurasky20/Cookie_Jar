import 'package:cookie_jar/style.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget cardDataInsight({required String title, required int amount}) {
  return Column(
    children: [
      Container(
        width: 300,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200, width: 2),
          gradient: linearGradientBlueWhite,
          //color: Colors.amber.shade50,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  amount.toString(),
                  style: GoogleFonts.dmSans(
                    color: Colors.black,
                    fontSize: 48,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.dmSans(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            Image.asset(
              'assets/images/cookie.png',
              width: 64,
              height: 64,
              fit: BoxFit.contain
            ),
          ],
        ),
      ),
    ],
  );
}
