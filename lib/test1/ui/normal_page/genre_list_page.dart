import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../test1/model/genre_model.dart';
import '../../../test1/model/story_model.dart';
import '../../service/service_genre.dart';
import '../../service/service_story.dart';
import '../build_common/story_item.dart';
import '../skeleton_ui/skeleton_list.dart';
import 'story_detail_page.dart';

class GenreStoryListScreen extends StatefulWidget {
  final String genreId;
  final String genreName;

  const GenreStoryListScreen({super.key, required this.genreId, required this.genreName});

  @override
  State<StatefulWidget> createState() {
    return GenreStoryListScreenState();
  }
}

class GenreStoryListScreenState extends State<GenreStoryListScreen> with TickerProviderStateMixin {
  List<Genre> listGenre = [];
  List<Story> listStory = [];
  bool isLoading = false;
  final genreService = ApiGenreService(Dio());
  final storyService = ApiStoryService(Dio());
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Color> gradientColors = [
    Colors.deepPurple,
    Colors.purple,
    Colors.pink,
    Colors.indigo,
    Colors.blue,
    Colors.teal,
    Colors.cyan,
    Colors.lightBlue,
  ];

  Color get genreColor {
    final hash = widget.genreName.hashCode;
    return gradientColors[hash.abs() % gradientColors.length];
  }

  Future<void> loadGenres() async {
    final genres = await genreService.getGenres();
    setState(() {
      listGenre = genres.cast<Genre>();
    });
  }

  Future<void> loadStories() async {
    setState(() {
      isLoading = true;
    });
    try {
      List<Story> loadedStories = (await storyService.getStories()).cast<Story>();
      setState(() {
        listStory = loadedStories;
        isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    loadGenres();
    loadStories();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Story> filteredStories =
        listStory.where((story) => story.genreId.any((g) => g == widget.genreId)).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Enhanced SliverAppBar với gradient
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.genreName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
                  ),
                  Text(
                    '${filteredStories.length} truyện',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      genreColor,
                      genreColor.withValues(alpha: 0.8),
                      genreColor.withValues(alpha: 0.6),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned(
                      top: 50,
                      right: 20,
                      child: Icon(Icons.category, size: 120, color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    Positioned(
                      bottom: 30,
                      left: 20,
                      child: Icon(Icons.auto_stories, size: 80, color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    // Floating particles effect
                    ...List.generate(8, (index) {
                      return Positioned(
                        top: 60 + (index * 20.0),
                        left: 30 + (index * 30.0) % 300,
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () => loadStories(),
                ),
              ),
            ],
          ),

          // Loading or Content
          isLoading
              ? SliverToBoxAdapter(child: SkeletonList())
              : filteredStories.isEmpty
              ? SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Không có truyện nào',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Thể loại "${widget.genreName}" chưa có truyện',
                          style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
              : SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final story = filteredStories[index];
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
                          CurvedAnimation(
                            parent: _animationController,
                            curve: Interval(index * 0.1, 1.0, curve: Curves.easeOutCubic),
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => StoryDetailPage(id: story.id)),
                            );
                          },
                          child: BuildEnhancedStoryItem(
                            index: index,
                            context: context,
                            gradientColors: gradientColors,
                            listGenre: listGenre,
                            story: story,
                          ),
                        ),
                      ),
                    );
                  }, childCount: filteredStories.length),
                ),
              ),
        ],
      ),
    );
  }
}
