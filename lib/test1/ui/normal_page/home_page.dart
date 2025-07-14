import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:presient/test1/ui/normal_page/setting_page.dart';
import 'package:presient/test1/ui/personal_page/my_list_story.dart';
import '../../model/genre_model.dart';
import '../../model/story_model.dart';
import '../../service/dio_client.dart';
import '../../service/service_genre.dart';
import '../../service/service_story.dart';
import '../build_common/story_item.dart';
import '../manager_page/manager_page.dart';
import '../skeleton_ui/skeleton_list.dart';
import 'genre_list_page.dart';
import 'story_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<Story> listStory = [];
  List<Genre> listGenre = [];
  bool isLoading = false;
  bool showGenres = false;
  final genreService = ApiGenreService(Dio());
  final storyService = ApiStoryService(DioClient.createDio());
  String selectedSlug = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late List<String> moreButtonOptions;

  final List<Color> gradientColors = [
    Colors.deepPurple,
    Colors.purple,
    Colors.pink,
    Colors.indigo,
    Colors.blue,
    Colors.teal,
  ];

  void gotoManagerScreen() {
    FocusManager.instance.primaryFocus?.unfocus();

    Navigator.push(context, MaterialPageRoute(builder: (context) => StoryAndGenreManagerScreen()));
  }

  void gotoMyListScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => MyListStory()));
  }

  void goToSettingsScreen() {
    FocusManager.instance.primaryFocus?.unfocus();

    Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingPage()));
  }

  Future<void> _invokeThreeDotMenuOption(String choice) async {
    await Future.delayed(const Duration(milliseconds: 0));

    if (!mounted) return;

    if (choice == moreButtonOptions[0]) {
      gotoManagerScreen();
    } else if (choice == moreButtonOptions[1]) {
      gotoMyListScreen();
    } else if (choice == moreButtonOptions[2]) {
      goToSettingsScreen();
    }
  }

  Future<void> loadStories() async {
    setState(() => isLoading = true);
    try {
      final loaded = await storyService.getStories();
      final loadGenre = await genreService.getGenres();
      print(" ${loaded.length} stories fetched");
      setState(() {
        listGenre = loadGenre.cast<Genre>();
        listStory = loaded.cast<Story>();
        isLoading = false;
      });
      _animationController.forward();
    } on DioException catch (e) {
      print(' Error loading stories: ${e.requestOptions}');
      setState(() => isLoading = false);
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
    loadStories();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    moreButtonOptions = ["Quản lý truyện và thể loại", "Kệ sách cá nhân", "Thiết lập"];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.deepPurple.shade400, Colors.purple.shade300, Colors.pink.shade300],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 50,
                      right: 20,
                      child: Icon(Icons.auto_stories, size: 100, color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Icon(Icons.book, size: 80, color: Colors.white.withValues(alpha: 0.1)),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              PopupMenuButton<String>(
                onSelected: (_) {},
                itemBuilder: (_) {
                  return moreButtonOptions.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                      onTap: () => _invokeThreeDotMenuOption(choice),
                    );
                  }).toList();
                },
              ),
            ],
          ),
          isLoading
              ? const SliverToBoxAdapter(
                child: SkeletonList(
                  itemCount: 6,
                  minOpacity: 0.5,

                  maxOpacity: 1.0,
                  animationDuration: Duration(milliseconds: 1200),
                ),
              )
              : SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.trending_up, color: Colors.deepPurple, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Truyện nổi bật',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                      ),
                      const Spacer(),
                      Text(
                        '${listStory.length} truyện',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
          isLoading
              ? const SliverToBoxAdapter(child: SkeletonList())
              : SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final story = listStory[index];
    return FadeTransition(
    opacity: _fadeAnimation,
    child: SlideTransition(
    position: Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero).animate(
    CurvedAnimation(
    parent: _animationController,
    curve: Interval(index * 0.1, 1.0, curve: Curves.easeOutCubic),
    ),
    ),
    child: GestureDetector(
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
                  }, childCount: listStory.length),
                ),
              ),
        ],
      ),
      drawer: _buildEnhancedDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => loadStories(),
        icon: const Icon(Icons.refresh),
        label: const Text('Làm mới'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEnhancedDrawer() {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.deepPurple.shade400, Colors.purple.shade300],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.category, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Thể loại',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Khám phá ${listGenre.length} thể loại',
                      style: TextStyle(fontSize: 16, color: Colors.white.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: listGenre.length,
              itemBuilder: (context, index) {
                final genre = listGenre[index];
                final isSelected = selectedSlug == genre.id;
                final color = gradientColors[index % gradientColors.length];

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
                    border: isSelected ? Border.all(color: color, width: 2) : null,
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.bookmark, color: color, size: 20),
                    ),
                    title: Text(
                      genre.name,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? color : Colors.grey[800],
                        fontSize: 16,
                      ),
                    ),
                    trailing:
                        isSelected
                            ? Icon(Icons.check_circle, color: color)
                            : Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    onTap: () {
                      setState(() {
                        selectedSlug = genre.id;
                      });
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => GenreStoryListScreen(genreId: selectedSlug, genreName: genre.name),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
