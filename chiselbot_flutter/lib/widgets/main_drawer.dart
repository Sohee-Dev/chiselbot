import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_notifier.dart';
import 'user_avatar.dart';

class MainDrawer extends ConsumerWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (userName, userEmail) = ref.watch(currentUserInfoProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    return Drawer(
      backgroundColor: Colors.grey[900],
      width: screenWidth * .85,
      child: Column(
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              child: Row(
                children: [
                  UserAvatar(radius: 24),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        userEmail,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Divider(color: Colors.grey.shade800, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  '면접 보관함',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                )),
          ),
          Expanded(
              child: ListView(
            padding: EdgeInsets.only(left: 8),
            children: [
              TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(alignment: Alignment.centerLeft),
                  child: Text(
                    "자바에서 객체지향 설계 원칙(SOLID) 중 단일 책임 원칙(SRP)과 개방-폐쇄 원칙(OCP)의 개념을 설명해주세요.",
                    style: const TextStyle(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )),
            ],
          )),
          Divider(color: Colors.grey.shade800, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Align(
              alignment: Alignment.bottomRight,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed(
                    '/settings',
                  );
                },
                child: const Icon(Icons.settings),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
