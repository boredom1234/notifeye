import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:crime/account/components/color.dart';
import 'package:crime/onboarding_data.dart';
import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final controller = OnboardingData();
  final pageController = PageController();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: 3.0, // Adjust blur intensity as desired
              sigmaY: 3.0,
            ),
            child: CachedNetworkImage(
              imageUrl: controller.items[currentIndex].imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // Black Overlay
          Container(
            color: Colors.black.withOpacity(0.5), // Adjust opacity as needed
          ),
          Column(
            children: [
              Expanded(
                child: body(),
              ),
              buildDots(),
              button(),
            ],
          ),
        ],
      ),
    );
  }

  // Body
  Widget body() {
    return PageView.builder(
      onPageChanged: (value) {
        setState(() {
          currentIndex = value;
        });
      },
      itemCount: controller.items.length,
      itemBuilder: (context, index) {
        return Stack(
          fit: StackFit.expand, // Expand the Stack to fill the whole PageView
          children: [
            // Text at center of the screen showing Notifeye
            const Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Text(
                "Notifeye",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Spacer to push content down
                  const Spacer(),
                  // Title
                  Text(
                    controller.items[currentIndex].title,
                    style: const TextStyle(
                      fontSize: 25,
                      color: Colors.white70,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Text(
                      controller.items[currentIndex].description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 50), // Adjust spacing as needed
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // Dots
  Widget buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        controller.items.length,
        (index) => AnimatedContainer(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: currentIndex == index ? primaryColor : Colors.grey,
          ),
          height: 7,
          width: currentIndex == index ? 30 : 7,
          duration: const Duration(milliseconds: 700),
        ),
      ),
    );
  }

  // Button
  Widget button() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      width: MediaQuery.of(context).size.width * .9,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50), // Set the borderRadius here
        color: primaryColor,
      ),
      child: TextButton(
        onPressed: () {
          if (currentIndex == controller.items.length - 1) {
            // Navigate to the phone screen
            Navigator.pushNamed(context, '/homescreen');
          } else {
            setState(() {
              currentIndex++; // Move to the next page if not on the last page
            });
          }
        },
        child: Text(
          currentIndex == controller.items.length - 1
              ? "Get started"
              : "Continue",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
