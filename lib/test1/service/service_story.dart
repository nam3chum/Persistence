import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

import '../../test1/model/story_model.dart';

part 'service_story.g.dart';

@RestApi(baseUrl: "https://684fbe32e7c42cfd1795bed4.mockapi.io/api/v1/story/")
abstract class ApiStoryService {
  factory ApiStoryService(Dio dio) = _ApiStoryService;

  @GET("")
  Future<List<Story>> getPagingStories({
    @Query("page") required int page,
    @Query("limit") required int limit,
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET("")
  Future<List<Story>> getStories();

  @GET("/{id}")
  Future<Story> getStoryById(@Path("id") String id);

  @POST("")
  Future<Story> addStory(@Body() Story story);

  @DELETE("/{id}")
  Future<Story> deleteStory(@Path("id") String id);

  @PUT("/{id}")
  Future<Story> updateStory(@Path("id") String? id, @Body() Story story);

  @PATCH("/{id}")
  Future<Story> patchStory(@Path("id") String id, @Body() Map<String, dynamic> data);
}
