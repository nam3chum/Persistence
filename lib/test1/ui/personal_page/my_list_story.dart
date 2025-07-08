import 'package:flutter/material.dart';
import 'package:presient/test1/database/database_controller.dart';
import 'package:presient/test1/ui/normal_page/story_detail_page.dart';

import '../../model/story_model.dart';

class MyListStory extends StatefulWidget {
  const MyListStory({super.key});

  @override
  State<MyListStory> createState() => _MyListStoryState();
}

class _MyListStoryState extends State<MyListStory> {
  final dbController = DatabaseController();
  bool isLoading = false;
  List<Story> _stories = [];

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  Future<void> _loadStories() async {
    setState(() {
      isLoading = true;
    });
    final storiesData = await dbController.getAllStories();
    setState(() {
      _stories = storiesData.map((data) => data).toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kệ sách của tôi'),
        backgroundColor: Colors.purple[600],
        // actions: [IconButton(icon: Icon(Icons.add), onPressed: () => _showAddStoryDialog(context))],
      ),
      body:
          isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)),
                    SizedBox(height: 16),
                    Text('Đang tải dữ liệu...', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              )
              : _stories.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.book_outlined, size: 80, color: Colors.grey[400]),
                    SizedBox(height: 16),
                    Text('Chưa có truyện nào', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                    SizedBox(height: 8),
                    Text(
                      'Kệ chưa có truyện, hãy thêm truyện mới',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: _stories.length,
                itemBuilder: (context, index) {
                  final story = _stories[index];
                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.purple[100],
                        child: Image.network(story.imgUrl,fit: BoxFit.cover,)
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          _deleteStory(story.id);
                        },
                        icon: Icon(Icons.delete),
                      ),
                      title: Text(story.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            story.content.length > 50
                                ? '${story.content.substring(0, 50)}...'
                                : story.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tạo: ${story.updatedAt}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => StoryDetailPage(id: story.id)),
                        );
                      },
                    ),
                  );
                },
              ),
    );
  }

  Future<void> _deleteStory(String id) async {
    await dbController.deleteStory(id);
    _loadStories();
  }
}
