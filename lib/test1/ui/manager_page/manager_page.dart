import 'package:flutter/material.dart';

import 'genre_manager_page.dart';
import 'story_manager_page.dart';

class StoryAndGenreManagerScreen extends StatelessWidget {
  const StoryAndGenreManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Số lượng tab
      child: Scaffold(
        appBar: AppBar(
          title: Text('Quản lý nội dung'),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.book), text: 'Truyện'),
              Tab(icon: Icon(Icons.category), text: 'Thể loại'),
            ],
          ),
        ),
        body: const TabBarView(children: [StoryManagementScreen(), GenreManagementScreen()]),
      ),
    );
  }
}
