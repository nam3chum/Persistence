import 'package:flutter/material.dart';
import 'package:presient/test1/database/database_controller.dart';
import 'package:presient/test1/ui/normal_page/story_detail_page.dart';

import '../../model/story_model.dart';

class MyListStory extends StatefulWidget {
  const MyListStory({super.key});

  @override
  State<MyListStory> createState() => _MyListStoryState();
}

class _MyListStoryState extends State<MyListStory> with TickerProviderStateMixin {
  final dbController = DatabaseController();
  bool isLoading = false;
  List<Story> _stories = [];
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));
    _loadStories();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
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
    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple[50]!, Colors.white],
          ),
        ),
        child: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple[600]!, Colors.purple[400]!],
          ),
        ),
      ),
      title: Row(
        children: [
          Icon(Icons.auto_stories, color: Colors.white, size: 28),
          SizedBox(width: 8),
          Text(
            'Kệ sách của tôi',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (_stories.isEmpty) {
      return _buildEmptyState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          _buildStatsHeader(),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _stories.length,
              itemBuilder: (context, index) {
                return _buildStoryCard(context, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.purple.withValues(alpha: 0.1), blurRadius: 20, offset: Offset(0, 10)),
              ],
            ),
            child: Column(
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.purple[600]!),
                  strokeWidth: 3,
                ),
                SizedBox(height: 16),
                Text(
                  'Đang tải dữ liệu...',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.purple.withValues(alpha: 0.1), blurRadius: 20, offset: Offset(0, 10)),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.purple[50], shape: BoxShape.circle),
                  child: Icon(Icons.auto_stories_outlined, size: 64, color: Colors.purple[400]),
                ),
                SizedBox(height: 24),
                Text(
                  'Chưa có truyện nào',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                ),
                SizedBox(height: 8),
                Text(
                  'Kệ chưa có truyện, hãy thêm truyện mới\nđể bắt đầu hành trình khám phá!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  icon: Icon(Icons.add),
                  label: Text('Thêm truyện mới'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[600],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.purple.withValues(alpha: 0.1), blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tổng số truyện', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                SizedBox(height: 4),
                Text(
                  '${_stories.length}',
                  style: TextStyle(color: Colors.purple[600], fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.purple[50], shape: BoxShape.circle),
            child: Icon(Icons.library_books, color: Colors.purple[600], size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryCard(BuildContext context, int index) {
    final story = _stories[index];

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => StoryDetailPage(id: story.id)));
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Hero(
                  tag: 'story_${story.id}',
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        story.imgUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.purple[100],
                            child: Icon(Icons.book, color: Colors.purple[600], size: 35),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        story.name,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey[800]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6),
                      Text(
                        story.content.length > 60 ? '${story.content.substring(0, 60)}...' : story.content,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.3),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Tạo: ${story.updatedAt}',
                              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),

                Container(
                  decoration: BoxDecoration(color: Colors.red[50], shape: BoxShape.circle),
                  child: IconButton(
                    onPressed: () => _showDeleteDialog(story),
                    icon: Icon(Icons.delete_outline, color: Colors.red[600], size: 18),
                    constraints: BoxConstraints(minWidth: 36, minHeight: 36),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(Story story) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [Icon(Icons.warning, color: Colors.red[600]), SizedBox(width: 8), Text('Xác nhận xóa')],
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa truyện "${story.name}"?\nHành động này không thể hoàn tác.',
            style: TextStyle(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteStory(story.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteStory(String id) async {
    await dbController.deleteStory(id);
    _loadStories();
  }
}
