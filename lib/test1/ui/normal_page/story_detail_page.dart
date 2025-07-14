import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:presient/test1/database/database_controller.dart';

import '../../model/genre_model.dart';
import '../../model/story_model.dart';
import '../../service/service_genre.dart';
import '../../service/service_story.dart';
import 'genre_list_page.dart';

class StoryDetailPage extends StatefulWidget {
  final String id;

  const StoryDetailPage({super.key, required this.id});

  @override
  State<StatefulWidget> createState() => StoryDetailPageState();
}

class StoryDetailPageState extends State<StoryDetailPage> with TickerProviderStateMixin {
  late Story story;
  List<Genre> genreList = [];
  bool isLoading = true;
  bool isBookmarked = false;
  bool showFullDescription = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final genreService = ApiGenreService(Dio());
  final storyService = ApiStoryService(Dio());
  final DatabaseController dbController = DatabaseController();
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    fetchStory();
    loadGenres();
    checkBookMarked();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> loadGenres() async {
    try {
      final genres = await genreService.getGenres();
      setState(() {
        genreList = genres.cast<Genre>();
      });
    } catch (e) {
      final localGenres = await dbController.getAllGenres();
      setState(() {
        genreList = localGenres;
      });
    }
  }

  Future<void> checkBookMarked() async {
    final bookMarked = await dbController.getStoryById(widget.id);
    setState(() {
      isBookmarked = bookMarked != null;
    });
    print("check bookmark = $isBookmarked");
  }

  Future<void> fetchStory() async {
    try {
      final result = await storyService.getStoryById(widget.id);

      setState(() {
        story = result;
        isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      debugPrint('Lỗi tải từ API: $e');

      // Thử lấy từ local DB
      try {
        final localStory = await dbController.getStoryById(widget.id);

        if (localStory != null) {
          setState(() {
            story = localStory;
            isLoading = false;
          });
          _animationController.forward();
        } else {
          // Không có luôn trong DB
          setState(() {
            isLoading = false;
            hasError = true;
          });
        }
      } catch (e2) {
        debugPrint('Lỗi tải từ DB local: $e2');

        // Cả 2 cùng lỗi
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    }
  }

  Future<void> toggleBookmark(Story story) async {
    setState(() {
      isBookmarked = !isBookmarked;
    });
    if (isBookmarked) {
      await dbController.createStory(story);
    } else {
      await dbController.deleteStory(story.id);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isBookmarked ? 'Đã thêm vào kệ sách' : 'Đã xóa khỏi kệ sách'),
        backgroundColor: isBookmarked ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void readStory() {}

  void loadTableOfContents() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 20),
                const Text('Mục lục', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                const Text('Tính năng đang được phát triển...'),
                const SizedBox(height: 40),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.orange),
              const SizedBox(height: 20),
              Text('Đang tải...', style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
            ],
          ),
        ),
      );
    }

    if (hasError) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        body: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[800]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Error Icon với animation
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3), width: 2),
                  ),
                  child: Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                ),

                const SizedBox(height: 24),

                // Error Title
                const Text(
                  "Oops! Có lỗi xảy ra",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Error Message
                Text(
                  "Không thể tải truyện. Vui lòng kiểm tra kết nối mạng và thử lại.",
                  style: TextStyle(fontSize: 16, color: Colors.grey[300], height: 1.5),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [

                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Colors.orange, Colors.deepOrange]),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              setState(() {
                                isLoading = true;
                                hasError = false;
                              });
                              fetchStory();
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.refresh, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  "Thử lại",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[700]!),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => Navigator.pop(context),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.arrow_back, color: Colors.white, size: 20),
                                SizedBox(height: 2),
                                Text(
                                  "Quay lại",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 400,
              pinned: true,
              stretch: true,
              backgroundColor: Colors.black,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: isBookmarked ? Colors.orange : Colors.white,
                    ),
                    onPressed: () async {
                      await toggleBookmark(story);
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(icon: const Icon(Icons.share, color: Colors.white), onPressed: () {}),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'story_${story.id}',
                      child: Image.network(
                        story.imgUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[800],
                            child: const Icon(Icons.broken_image, size: 64, color: Colors.white54),
                          );
                        },
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                            Colors.black.withValues(alpha: 0.9),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    _buildStoryInfo(),
                    const SizedBox(height: 20),
                    _buildGenreTags(),
                    const SizedBox(height: 25),
                    _buildStoryStats(),
                    const SizedBox(height: 25),
                    _buildDescription(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  Widget _buildStoryInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            story.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          if (story.author.isNotEmpty)
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey[400]),
                const SizedBox(width: 8),
                Text(story.author, style: TextStyle(fontSize: 16, color: Colors.grey[300])),
              ],
            ),
          if (story.originName.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.translate, size: 16, color: Colors.grey[400]),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    story.originName,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.orangeAccent,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGenreTags() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        children:
            story.genreId.map((e) {
              final genre = genreList.firstWhere(
                (g) => g.id == e.toString(),
                orElse: () => Genre(id: e.toString(), name: 'Không rõ'),
              );
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.withValues(alpha: .8), Colors.deepOrange.withValues(alpha: 0.8)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => GenreStoryListScreen(genreId: genre.id, genreName: genre.name),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        genre.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildStoryStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[800]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(Icons.visibility, "999+", "Lượt xem"),
            Container(width: 1, height: 40, color: Colors.grey[700]),
            _buildStatItem(Icons.favorite, "4.8", "Đánh giá"),
            Container(width: 1, height: 40, color: Colors.grey[700]),
            _buildStatItem(Icons.menu_book, story.numberOfChapter.toString(), "Chương"),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.orange, size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
      ],
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Giới thiệu',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[800]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Html(
                  data: story.content,
                  style: {
                    "body": Style(
                      color: Colors.grey[300],
                      fontSize: FontSize(15),
                      lineHeight: LineHeight(1.6),
                    ),
                    "p": Style(margin: Margins.only(bottom: 12)),
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, -5)),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.menu_book,
                label: "Mục lục",
                onTap: loadTableOfContents,
                isPrimary: false,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _buildActionButton(
                icon: Icons.play_circle_fill,
                label: "Đọc truyện",
                onTap: readStory,
                isPrimary: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                label: "Kệ sách",
                onTap: () async {
                  await toggleBookmark(story);
                },
                isPrimary: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: isPrimary ? LinearGradient(colors: [Colors.orange, Colors.deepOrange]) : null,
        color: isPrimary ? null : Colors.grey[800],
        borderRadius: BorderRadius.circular(16),
        boxShadow:
            isPrimary
                ? [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
                : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: isPrimary ? 24 : 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isPrimary ? 14 : 12,
                  fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
