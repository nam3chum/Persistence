// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../test1/model/genre_model.dart';
import '../../../test1/model/story_model.dart';
import '../../service/service_genre.dart';
import '../../service/service_story.dart';

class StoryManagementScreen extends StatefulWidget {
  const StoryManagementScreen({super.key});

  @override
  StoryManagementScreenState createState() => StoryManagementScreenState();
}

class StoryManagementScreenState extends State<StoryManagementScreen> with SingleTickerProviderStateMixin {
  List<Story> stories = [];
  List<Genre> genres = [];
  bool isLoading = true;
  String searchQuery = '';
  late AnimationController _animationController;
  final genreService = ApiGenreService(Dio());
  final storyService = ApiStoryService(Dio());
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final storiesData = await storyService.getStories();
      final genresData = await genreService.getGenres();
      setState(() {
        stories = storiesData;
        genres = genresData;
        isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar('Lỗi khi tải dữ liệu: $e', isError: true);
    }
  }

  Future<void> _deleteStory(String id) async {
    try {
      await storyService.deleteStory(id);
      _loadData();
      _showSnackBar('Xóa truyện thành công!');
    } catch (e) {
      _showSnackBar('Lỗi khi xóa truyện: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  List<Story> get filteredStories {
    if (searchQuery.isEmpty) return stories;
    return stories
        .where(
          (story) =>
              story.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              story.author.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Đang tiến hành':
        return Colors.blue;
      case 'Hoàn thành':
        return Colors.green;
      case 'Tạm ngưng':
        return Colors.orange;
      case 'Đã drop':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm truyện...',
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: Colors.grey[600]),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.blue[600]),
                onPressed: _loadData,
                tooltip: 'Làm mới',
              ),
            ],
          ),
        ),
      ),
      body:
          isLoading
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)),
                    SizedBox(height: 16),
                    Text('Đang tải dữ liệu...', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ],
                ),
              )
              : filteredStories.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.library_books_outlined, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      searchQuery.isEmpty ? 'Chưa có truyện nào' : 'Không tìm thấy truyện phù hợp',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      searchQuery.isEmpty ? 'Nhấn nút + để thêm truyện mới' : 'Thử tìm kiếm với từ khóa khác',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
              : AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _animationController,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredStories.length,
                      itemBuilder: (context, index) {
                        final story = filteredStories[index];
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 300 + (index * 50)),
                          curve: Curves.easeOutBack,
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Colors.grey[200]!, width: 1),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {},
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    // Story Image
                                    Container(
                                      width: 80,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child:
                                            story.imgUrl.isNotEmpty
                                                ? Image.network(
                                                  story.imgUrl,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (context, error, stackTrace) => Container(
                                                        color: Colors.grey[200],
                                                        child: Icon(
                                                          Icons.book,
                                                          size: 40,
                                                          color: Colors.grey[500],
                                                        ),
                                                      ),
                                                )
                                                : Container(
                                                  color: Colors.grey[200],
                                                  child: Icon(Icons.book, size: 40, color: Colors.grey[500]),
                                                ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Story Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            story.name,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  story.author,
                                                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: _getStatusColor(
                                                      story.status,
                                                    ).withValues(alpha: 0.1),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    story.status,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: _getStatusColor(story.status),
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue.withValues(alpha: 0.1),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    '${story.numberOfChapter} chương',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.blue,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Action Buttons
                                    Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.blue),
                                            onPressed: () async {
                                              final result = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          StoryFormScreen(story: story, genres: genres),
                                                ),
                                              );
                                              if (result == true) _loadData();
                                            },
                                            tooltip: 'Chỉnh sửa',
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.red.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (context) => AlertDialog(
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(16),
                                                      ),
                                                      title: const Text(
                                                        'Xóa Truyện',
                                                        style: TextStyle(fontWeight: FontWeight.bold),
                                                      ),
                                                      content: Text(
                                                        'Bạn có chắc chắn muốn xóa truyện "${story.name}"?',
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () => Navigator.pop(context),
                                                          child: const Text('Hủy'),
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            Navigator.pop(context);
                                                            _deleteStory(story.id);
                                                          },
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: Colors.red,
                                                            foregroundColor: Colors.white,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(8),
                                                            ),
                                                          ),
                                                          child: const Text('Xóa'),
                                                        ),
                                                      ],
                                                    ),
                                              );
                                            },
                                            tooltip: 'Xóa',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.blue.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => StoryFormScreen(genres: genres)),
            );
            if (result == true) _loadData();
          },
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Thêm Truyện', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterFloat,
    );
  }
}

class StoryFormScreen extends StatefulWidget {
  final Story? story;
  final List<Genre> genres;

  const StoryFormScreen({super.key, this.story, required this.genres});

  @override
  StoryFormScreenState createState() => StoryFormScreenState();
}

class StoryFormScreenState extends State<StoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _originNameController = TextEditingController();
  final _contentController = TextEditingController();
  final _authorController = TextEditingController();
  final _imgUrlController = TextEditingController();
  final _numberOfChapterController = TextEditingController();
  final genreService = ApiGenreService(Dio());
  final storyService = ApiStoryService(Dio());

  String _status = 'Đang tiến hành';
  List<String> _selectedGenres = [];
  late File _selectedImage;
  bool _useImageUrl = true;
  bool _isLoading = false;
  List<String> statuses = ['Đang tiến hành', 'Hoàn thành', 'Tạm ngưng', 'Đã drop'];
  final ImagePicker _picker = ImagePicker();
  List<Genre> listGenre = [];

  @override
  void initState() {
    super.initState();
    listGenre = List.from(widget.genres);
    if (widget.story != null) {
      _nameController.text = widget.story?.name ?? '';
      _originNameController.text = widget.story?.originName ?? '';
      _contentController.text = widget.story?.content ?? '';
      _authorController.text = widget.story?.author ?? '';
      _imgUrlController.text = widget.story?.imgUrl ?? '';
      _numberOfChapterController.text = widget.story?.numberOfChapter.toString() ?? '';
      _status = widget.story?.status ?? '';
      _selectedGenres = List.from(widget.story?.genreId ?? []);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _originNameController.dispose();
    _contentController.dispose();
    _authorController.dispose();
    _imgUrlController.dispose();
    _numberOfChapterController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _saveStory() async {
    final currentState = _formKey.currentState;
    if (currentState == null || !currentState.validate()) return;

    setState(() => _isLoading = true);

    try {
      String imageUrl = _imgUrlController.text;

      if (!_useImageUrl) {
        imageUrl = "";
      }

      final story = Story(
        id: widget.story?.id ?? '',
        name: _nameController.text,
        originName: _originNameController.text,
        content: _contentController.text,
        author: _authorController.text,
        genreId: _selectedGenres,
        imgUrl: imageUrl,
        status: _status,
        updatedAt: DateTime.now(),
        numberOfChapter: int.tryParse(_numberOfChapterController.text) ?? 0,
      );

      if (widget.story == null) {
        await storyService.addStory(story);
        _showSnackBar('Thêm truyện thành công!');
      } else {
        await storyService.updateStory(widget.story?.id, story);
        _showSnackBar('Cập nhật truyện thành công!');
      }

      Navigator.pop(context, true);
    } catch (e) {
      _showSnackBar('Lỗi khi lưu truyện: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    Widget? prefixIcon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label + (required ? ' *' : ''),
          hintText: hint,
          prefixIcon: prefixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: required ? (value) => value?.isEmpty == true ? 'Trường này là bắt buộc' : null : null,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Đang tiến hành':
        return Colors.blue;
      case 'Hoàn thành':
        return Colors.green;
      case 'Tạm ngưng':
        return Colors.orange;
      case 'Đã drop':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.story == null ? 'Thêm Truyện Mới' : 'Chỉnh Sửa Truyện',
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveStory,
              icon:
                  _isLoading
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                      : const Icon(Icons.save, size: 18),
              label: Text(_isLoading ? 'Đang lưu...' : 'Lưu'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Basic Information Section
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey[200]!),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.info_outline, color: Colors.blue),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Thông tin cơ bản',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _nameController,
                      label: 'Tên truyện',
                      hint: 'Nhập tên truyện',
                      required: true,
                      prefixIcon: const Icon(Icons.book),
                    ),
                    _buildTextField(
                      controller: _originNameController,
                      label: 'Tên gốc',
                      hint: 'Nhập tên gốc (nếu có)',
                      prefixIcon: const Icon(Icons.translate),
                    ),
                    _buildTextField(
                      controller: _authorController,
                      label: 'Tác giả',
                      hint: 'Nhập tên tác giả',
                      required: true,
                      prefixIcon: const Icon(Icons.person),
                    ),
                    _buildTextField(
                      controller: _contentController,
                      label: 'Nội dung',
                      hint: 'Mô tả ngắn về truyện',
                      maxLines: 4,
                      prefixIcon: const Icon(Icons.description),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _numberOfChapterController,
                            label: 'Số chương',
                            hint: '0',
                            keyboardType: TextInputType.number,
                            prefixIcon: const Icon(Icons.format_list_numbered),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            child: DropdownButtonFormField<String>(
                              value: _status,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: 'Trạng thái',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
                                ),
                                filled: false,
                                fillColor: Colors.grey[50],
                                contentPadding: const EdgeInsets.all(16),
                              ),
                              items:
                                  statuses
                                      .map(
                                        (status) => DropdownMenuItem(
                                          value: status,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min, // Thêm dòng này
                                            children: [
                                              Container(
                                                width: 10,
                                                height: 10,
                                                decoration: BoxDecoration(
                                                  color: _getStatusColor(status),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Flexible(
                                                // Thay thế Text bằng Flexible
                                                child: Text(
                                                  status,
                                                  style: const TextStyle(fontSize: 13),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _status = value);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Image', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Radio<bool>(
                          value: true,
                          groupValue: _useImageUrl,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _useImageUrl = value);
                            }
                          },
                        ),
                        Text('Image URL'),
                        SizedBox(width: 20),
                        Radio<bool>(
                          value: false,
                          groupValue: _useImageUrl,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _useImageUrl = value);
                            }
                          },
                        ),
                        Text('Upload Image'),
                      ],
                    ),
                    if (_useImageUrl)
                      TextFormField(
                        controller: _imgUrlController,
                        decoration: InputDecoration(labelText: 'Image URL', border: OutlineInputBorder()),
                      )
                    else
                      Column(
                        children: [
                          SizedBox(
                            height: 200,
                            width: double.infinity,
                            child: Image.file(_selectedImage, fit: BoxFit.cover),
                          ),
                          SizedBox(height: 8),
                          ElevatedButton(onPressed: _pickImage, child: Text('Select Image')),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Genres Section
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey[200]!),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.category, color: Colors.orange),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Thể loại',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_selectedGenres.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: Colors.blue, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Đã chọn ${_selectedGenres.length} thể loại',
                              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          listGenre.map((genre) {
                            bool isSelected = _selectedGenres.contains(genre.id);
                            return AnimatedScale(
                              scale: isSelected ? 1.05 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              child: FilterChip(
                                label: Text(
                                  genre.name,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.grey[700],
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedGenres.add(genre.id);
                                    } else {
                                      _selectedGenres.remove(genre.id);
                                    }
                                  });
                                },
                                backgroundColor: Colors.grey[100],
                                selectedColor: Colors.blue[600],
                                showCheckmark: false,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            );
                          }).toList(),
                    ),
                    if (widget.genres.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.category_outlined, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 8),
                              Text(
                                'Chưa có thể loại nào',
                                style: TextStyle(color: Colors.grey[600], fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
