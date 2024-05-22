// ignore_for_file: file_names, non_constant_identifier_names, use_build_context_synchronously

import 'package:eventro/components/show_loadingcircle.dart';
import 'package:eventro/pages/authpages/register_page.dart';
import 'package:eventro/screens/onboard1.dart';
import 'package:eventro/screens/onboard2.dart';
import 'package:eventro/screens/onboard3.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool OnLastPage = false;

  void navigateToRegister() async {
    showLoadingCircle(context); // Show loading indicator
    // Adding a delay to ensure the loading indicator is visible
    await Future.delayed(const Duration(milliseconds: 700));
    await Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) {
      return const RegitserPage();
    }));
    Navigator.of(context, rootNavigator: true)
        .pop(); // Make sure to pop the loading dialog
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                OnLastPage = (index == 2);
              });
            },
            children: const [
              Onboard1(),
              Onboard2(),
              Onboard3(),
            ],
          ),
          Container(
              alignment: const Alignment(0, 0.75),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: navigateToRegister,
                    child: const Text(
                      'Skip',
                      style: TextStyle(fontFamily: "Gilroy", fontSize: 16),
                    ),
                  ),
                  SmoothPageIndicator(
                    controller: _controller,
                    count: 3,
                    effect: const ExpandingDotsEffect(
                      dotColor: Color(0xffEC6408),
                      activeDotColor: Color(0xffEC6408),
                    ),
                  ),
                  OnLastPage
                      ? GestureDetector(
                          onTap: navigateToRegister,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                                color: Color(0xffEC6408),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15.0))),
                            child: const Text('Get Started',
                                style: TextStyle(
                                    fontFamily: "Gilroy", fontSize: 16)),
                          ))
                      : GestureDetector(
                          onTap: () {
                            _controller.nextPage(
                                duration: const Duration(microseconds: 500),
                                curve: Curves.bounceInOut);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                                color: Color(0xffEC6408),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15.0))),
                            child: const Text('Next',
                                style: TextStyle(
                                    fontFamily: "Gilroy", fontSize: 16)),
                          )),
                ],
              )),
        ]),
      ),
    );
  }
}
