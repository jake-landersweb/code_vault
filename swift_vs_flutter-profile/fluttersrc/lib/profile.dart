import 'package:flutter/material.dart';
import 'package:fluttersrc/main.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
          child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _avatar(context),
                  const Spacer(),
                  _stats(context),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Jake Landers",
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Text(
                "Developer and Creator at SapphireNW",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                "Latest Posts",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              _content(context),
            ],
          ),
        ),
      )),
    );
  }

  Widget _avatar(BuildContext context) {
    return Container(
      height: 150,
      width: 150,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 5),
        shape: BoxShape.circle,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(75),
        child: Image.asset(
          "assets/jake.jpg",
          height: 150,
          width: 150,
        ),
      ),
    );
  }

  Widget _stats(BuildContext context) {
    return Row(
      children: [
        Column(
          children: const [
            Text(
              "140",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
            Text(
              "Following",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
        const SizedBox(width: 32),
        Column(
          children: const [
            Text(
              "237",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
            Text(
              "Followers",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _content(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          Row(
            children: [
              for (var j = 0; j < 3; j++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      color: bgColorAccent,
                      child: const AspectRatio(aspectRatio: 1),
                    ),
                  ),
                )
            ],
          ),
      ],
    );
  }
}
