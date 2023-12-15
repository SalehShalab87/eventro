// ignore_for_file: file_names, non_constant_identifier_names

import 'package:eventro/screens/onboard1.dart';
import 'package:eventro/screens/onboard2.dart';
import 'package:eventro/screens/onboard3.dart';
import 'package:eventro/pages/authpages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  //controller to kepp track pages
  final PageController _controller = PageController();

  // keep track if we are in the last page or not
  bool OnLastPage = false;

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
              //page1
              Onboard1(),
              //page2
              Onboard2(),
              //page3
              Onboard3(),
            ],
          ),

          //dot indicator
          Container(
              alignment: const Alignment(0, 0.75),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //left side skip button
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const LoginPage();
                      }));
                    },
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

                  //right side next or get started button
                  OnLastPage
                      ? GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return const LoginPage();
                            }));
                          },
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
