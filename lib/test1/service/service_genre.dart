
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../test1/model/genre_model.dart';
part 'service_genre.g.dart';
@RestApi(baseUrl: "https://684fbe32e7c42cfd1795bed4.mockapi.io/api/v1/genre")
abstract class ApiGenreService{
  factory ApiGenreService(Dio dio) = _ApiGenreService;

  @GET("")
  Future<List<Genre>> getGenres();

  @POST("")
  Future<Genre> addGenre(@Body() Genre genre);

  @DELETE("/{id}")
  Future<Genre> deleteGenre(@Path("id") String id);

  @PUT("/{id}")
  Future<Genre> updateGenre(@Path("id") String id, @Body() Genre genre);

  @GET("/{id}")
  Future<Genre> getGenreById(@Path("id") String id);
}