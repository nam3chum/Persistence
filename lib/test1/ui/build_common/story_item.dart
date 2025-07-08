import 'package:flutter/material.dart';

import '../../../test1/model/genre_model.dart';
import '../../../test1/model/story_model.dart';

class BuildEnhancedStoryItem extends StatelessWidget {
  final Story story;
  final BuildContext context;
  final int index;

  final List<Genre> listGenre;
  final List<Color> gradientColors;

  const BuildEnhancedStoryItem({
    required this.story,
    required this.context,
    required this.index,
    required this.listGenre,
    required this.gradientColors,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = gradientColors[index % gradientColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, accentColor.withValues(alpha: 0.02)],
              ),
            ),
            child: Row(
              children: [
                // Hình ảnh truyện với hiệu ứng
                Container(
                  width: 130,
                  height: 210,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(color: accentColor.withAlpha(77), blurRadius: 10, offset: const Offset(2, 2)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                    child:
                        story.imgUrl.trim().isNotEmpty
                            ? Stack(
                              children: [
                                SizedBox(
                                  width: 130,
                                  height: 210,
                                  child: Image.network(
                                    story.imgUrl,
                                    fit: BoxFit.cover,
                                    width: 130,
                                    height: 210,
                                    alignment: Alignment.topCenter,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildImagePlaceholder(accentColor);
                                    },
                                  ),
                                ),
                                Container(
                                  width: 130,
                                  height: 210,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Colors.transparent, accentColor.withAlpha(25)],
                                    ),
                                  ),
                                ),
                              ],
                            )
                            : _buildImagePlaceholder(accentColor),
                  ),
                ),
                // Nội dung truyện
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tiêu đề
                        Text(
                          story.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Tác giả
                        Row(
                          children: [
                            Icon(Icons.person_outline, size: 16, color: accentColor),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                story.author,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Trạng thái
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(story.status).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _getStatusColor(story.status).withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            story.status,
                            style: TextStyle(
                              fontSize: 12,
                              color: _getStatusColor(story.status),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Số chương
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.menu_book, size: 16, color: accentColor),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${story.numberOfChapter} chương',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Thể loại
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children:
                                story.genreId.map((e) {
                                  final genre = listGenre.firstWhere(
                                    (g) => g.id == e.toString(),
                                    orElse: () => Genre(id: e.toString(), name: 'Không rõ'),
                                  );
                                  final genreColor =
                                      gradientColors[story.genreId.indexOf(e) % gradientColors.length];

                                  return Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          genreColor.withValues(alpha: 0.1),
                                          genreColor.withValues(alpha: 0.05),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: genreColor.withValues(alpha: 0.2)),
                                    ),
                                    child: Text(
                                      genre.name,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: genreColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(Color color) {
    return Container(
      width: 130,
      height: 210,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withAlpha(25), color.withAlpha(15)],
        ),
      ),
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: 130,
          height: 210,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_stories, size: 40, color: color.withAlpha(150)),
              const SizedBox(height: 8),
              Text('Không có ảnh', style: TextStyle(fontSize: 12, color: color.withAlpha(180))),
            ],
          ),
        ),
      ),
    );
  }
}

Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'hoàn thành':
    case 'completed':
      return Colors.green;
    case 'đang tiến hành':
    case 'ongoing':
      return Colors.blue;
    case 'tạm dừng':
    case 'paused':
      return Colors.orange;
    default:
      return Colors.grey;
  }
}
