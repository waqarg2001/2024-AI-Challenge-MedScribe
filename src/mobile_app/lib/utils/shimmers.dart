import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medscribe_app/utils/themes.dart';
import 'package:medscribe_app/utils/widgets.dart';
import 'package:shimmer/shimmer.dart';

class MedScribe_Shimmers {
  static Widget profileScreenShimmer({required BuildContext context}) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(children: [
        Container(
            margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.02),
            padding: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.05),
            alignment: Alignment.bottomRight,
            child: Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width * 0.25,
              height: MediaQuery.of(context).size.height * 0.04,
              decoration: BoxDecoration(
                color: MedScribe_Theme.secondary_color,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Text(
                textAlign: TextAlign.center,
                "View PDF",
                style: GoogleFonts.inter(
                  color: MedScribe_Theme.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.20,
          child: Container(
            padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.height * 0.02,
              right: MediaQuery.of(context).size.height * 0.05,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            height: MediaQuery.of(context).size.width * 0.045,
                            color: Colors.grey[300],
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            height: MediaQuery.of(context).size.width * 0.045,
                            color: Colors.grey[300],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            height: MediaQuery.of(context).size.width * 0.045,
                            color: Colors.grey[300],
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            height: MediaQuery.of(context).size.width * 0.045,
                            color: Colors.grey[300],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SizedBox(),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
        Container(
            margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.03,
                bottom: MediaQuery.of(context).size.height * 0.02),
            padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.height * 0.02,
              right: MediaQuery.of(context).size.height * 0.02,
            ),
            child: MedScribe_Widgets.underline()),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.20,
          child: Container(
            padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.height * 0.02,
              right: MediaQuery.of(context).size.height * 0.05,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            height: MediaQuery.of(context).size.width * 0.045,
                            color: Colors.grey[300],
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            height: MediaQuery.of(context).size.width * 0.045,
                            color: Colors.grey[300],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            height: MediaQuery.of(context).size.width * 0.045,
                            color: Colors.grey[300],
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            height: MediaQuery.of(context).size.width * 0.045,
                            color: Colors.grey[300],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SizedBox(),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
