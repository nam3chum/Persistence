import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../model/genre_model.dart';
import '../../service/dio_client.dart';
import '../../service/service_genre.dart';
import '../../service/service_story.dart';

class GenreManagementScreen extends StatefulWidget {
  const GenreManagementScreen({super.key});

  @override
  GenreManagementScreenState createState() => GenreManagementScreenState();
}

class GenreManagementScreenState extends State<GenreManagementScreen> with TickerProviderStateMixin {
  final genreService = ApiGenreService(DioClient.createDio());
  final storyService = ApiStoryService(DioClient.createDio());
  List<Genre> genres = [];
  List<Genre> filteredGenres = [];
  bool isLoading = true;
  bool isDeleting = false;
  String searchQuery = '';
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    _loadGenres();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _searchController.text.toLowerCase();
      _filterGenres();
    });
  }

  void _filterGenres() {
    if (searchQuery.isEmpty) {
      filteredGenres = List.from(genres);
    } else {
      filteredGenres = genres.where((genre) => genre.name.toLowerCase().contains(searchQuery)).toList();
    }
  }

  Future<void> _loadGenres() async {
    setState(() => isLoading = true);
    try {
      // Mock data for demo
      await Future.delayed(Duration(seconds: 1));
      final mockGenres = await genreService.getGenres();

      setState(() {
        genres = mockGenres;
        _filterGenres();
      });
      _animationController.forward();
    } catch (e) {
      _showErrorSnackBar('Lỗi tải dữ liệu: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteGenre(String id, String name) async {
    setState(() {
      isLoading = true;
      isDeleting = true;
    });
    try {
      deleteGenre(id);
      await removeGenreFromStories(id);
      await _loadGenres();
      _showSuccessSnackBar('Đã xóa thể loại "$name" thành công');
    } catch (e) {
      _showErrorSnackBar('Lỗi xóa thể loại: $e');
    } finally {
      setState(() => isDeleting = false);
    }
  }

  Future<void> deleteGenre(String id) async {
    await Future.delayed(Duration(seconds: 10));
    genreService.deleteGenre(id);
  }

  Future<void> removeGenreFromStories(String id) async {
    //
    final listStory = await storyService.getStories();
    for (final story in listStory) {
      if (story.genreId.contains(id) == true) {
        final updatedGenreId = story.genreId.where((e) => e != id).toList();
        await storyService.patchStory(story.id, {"genreId": updatedGenreId});
      }
    }
  }

  void _showDeleteDialog(Genre genre) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
                SizedBox(width: 12),
                Text('Xác nhận xóa', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bạn có chắc chắn muốn xóa thể loại này?'),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.category, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          genre.name,
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Thao tác này sẽ xóa thể loại khỏi tất cả truyện liên quan và không thể hoàn tác.',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
                child: Text('Hủy'),
              ),
              ElevatedButton(
                onPressed:
                    isDeleting
                        ? null
                        : () {
                          Navigator.pop(context);
                          _deleteGenre(genre.id, genre.name);
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child:
                    isDeleting
                        ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                        : Text('Xóa'),
              ),
            ],
          ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Row(
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm thể loại...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    suffixIcon:
                        searchQuery.isNotEmpty
                            ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey[400]),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                            : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.refresh_rounded),
              onPressed: isLoading ? null : _loadGenres,
              tooltip: 'Làm mới',
            ),
            SizedBox(width: 8),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Search Bar

          // Content
          Expanded(
            child:
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
                    : filteredGenres.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            searchQuery.isNotEmpty ? Icons.search_off : Icons.category_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            searchQuery.isNotEmpty ? 'Không tìm thấy thể loại nào' : 'Chưa có thể loại nào',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            searchQuery.isNotEmpty
                                ? 'Thử tìm kiếm với từ khóa khác'
                                : 'Nhấn + để thêm thể loại mới',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                    : AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredGenres.length,
                          itemBuilder: (context, index) {
                            final genre = filteredGenres[index];
                            return SlideTransition(
                              position: Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero).animate(
                                CurvedAnimation(
                                  parent: _animationController,
                                  curve: Interval(index * 0.1, 1.0, curve: Curves.easeOutCubic),
                                ),
                              ),
                              child: FadeTransition(
                                opacity: CurvedAnimation(
                                  parent: _animationController,
                                  curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
                                ),
                                child: _buildGenreCard(genre, index),
                              ),
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GenreFormScreen()),
          );
          if (result == true) _loadGenres();
        },
        icon: Icon(Icons.add),
        label: Text('Thêm thể loại'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterFloat,
    );
  }

  Widget _buildGenreCard(Genre genre, int index) {
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red, Colors.teal];
    final color = colors[index % colors.length];

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.category_rounded, color: color, size: 24),
        ),
        title: Text(genre.name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        subtitle: Text('ID: ${genre.id}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(Icons.edit_rounded, color: Colors.blue, size: 20),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GenreFormScreen(genre: genre)),
                  );
                  if (result == true) _loadGenres();
                },
                tooltip: 'Chỉnh sửa',
              ),
            ),
            SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(Icons.delete_rounded, color: Colors.red, size: 20),
                onPressed: () => _showDeleteDialog(genre),
                tooltip: 'Xóa',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Genre Form Screen
class GenreFormScreen extends StatefulWidget {
  final Genre? genre;

  const GenreFormScreen({super.key, this.genre});

  @override
  GenreFormScreenState createState() => GenreFormScreenState();
}

class GenreFormScreenState extends State<GenreFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  final genreService = ApiGenreService(Dio());

  @override
  void initState() {
    super.initState();
    if (widget.genre != null) {
      _nameController.text = widget.genre!.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveGenre() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final genre = Genre(id: widget.genre?.id ?? '', name: _nameController.text.trim());

      if (widget.genre == null) {
        await genreService.addGenre(genre);
      } else {
        await genreService.updateGenre(widget.genre!.id, genre);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text(widget.genre == null ? 'Thêm thể loại thành công' : 'Cập nhật thể loại thành công'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Lỗi lưu thể loại: $e'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.genre != null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Text(
          isEditing ? 'Chỉnh sửa thể loại' : 'Thêm thể loại mới',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveGenre,
              icon:
                  _isLoading
                      ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                      : Icon(Icons.save_rounded, size: 18),
              label: Text(_isLoading ? 'Đang lưu...' : 'Lưu'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.category_rounded, color: Colors.blue, size: 24),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEditing ? 'Chỉnh sửa thông tin' : 'Tạo thể loại mới',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                isEditing
                                    ? 'Cập nhật thông tin thể loại "${widget.genre!.name}"'
                                    : 'Nhập thông tin thể loại mới',
                                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Form Field
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thông tin thể loại',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800]),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Tên thể loại',
                        hintText: 'Ví dụ: Hành động, Lãng mạn, Khoa học viễn tưởng...',
                        prefixIcon: Icon(Icons.label_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (value) {
                        if (value?.trim().isEmpty == true) {
                          return 'Vui lòng nhập tên thể loại';
                        }
                        if (value!.trim().length < 2) {
                          return 'Tên thể loại phải có ít nhất 2 ký tự';
                        }
                        return null;
                      },
                      textCapitalization: TextCapitalization.words,
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.grey[500]),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tên thể loại sẽ được hiển thị công khai cho người đọc',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: Text('Hủy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveGenre,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child:
                          _isLoading
                              ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Đang lưu...'),
                                ],
                              )
                              : Text(
                                isEditing ? 'Cập nhật' : 'Tạo thể loại',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
}
