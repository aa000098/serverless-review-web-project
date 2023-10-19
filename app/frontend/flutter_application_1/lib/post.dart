import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'api.dart';

class Post {
  final String postid;
  final String title;
  final String content;
  final String writerid;
  final int score;
  final String category;
  final DateTime createdTime;
  final List<dynamic> imagefiles;

  Post({
    required this.postid,
    required this.title,
    required this.category,
    required this.content,
    required this.writerid,
    required this.score,
    required this.createdTime,
    required this.imagefiles,
  });
}

final postRequestUrl = '$apiUrl/$apipost';
// 게시글 쓰는 함수
Future<void> addPost(String title, String category, String content,
    String writerid, int score, List<XFile> images) async {
  final request = http.MultipartRequest('POST', Uri.parse(postRequestUrl));
  request.headers['x-api-key'] = apiKey!;

  request.fields['title'] = title;
  request.fields['category'] = category;
  request.fields['content'] = content;
  request.fields['writerid'] = writerid;
  request.fields['score'] = score.toString();

  for (int i = 0; i < images.length; i++) {
    XFile imageFile = images[i];
    http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
      'image$i',
      imageFile.path,
      contentType: MediaType('image', 'jpeg'),
    );
    request.files.add(multipartFile);
  }

  final response = await request.send();
  print(response.statusCode);
  final responseString = await response.stream.bytesToString();
  print(responseString);
}

// 게시글 읽는 함수
Future<List<Post>> readPost() async {
  final response = await http.get(
    Uri.parse(postRequestUrl),
    headers: {
      'x-api-key': apiKey!,
    },
  );
  List<Post> posts = [];

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);

    posts = data
        .map((item) => Post(
              postid: item['post_ID'],
              title: item['title'],
              category: item['category'],
              content: item['content'],
              writerid: item['writerid'],
              score: item['score'].toInt(),
              createdTime: DateTime.parse(item['createdTime']),
              imagefiles: item['image_files'],
            ))
        .toList();
  }
  print(response.statusCode);
  posts.sort((a, b) => b.createdTime.compareTo(a.createdTime));
  return posts;
}

Future<Post> getPost(String postid) async {
  List<Post> postlist = await readPost();
  return postlist.firstWhere((post) => post.postid == postid);
}

Future<void> updatePost(
    String postid,
    String title,
    String category,
    String content,
    int score,
    List<dynamic> imagefiles,
    List<XFile> images) async {
  final request = http.MultipartRequest('PATCH', Uri.parse(postRequestUrl));
  request.headers['x-api-key'] = apiKey!;

  request.fields['post_ID'] = postid;
  request.fields['title'] = title;
  request.fields['category'] = category;
  request.fields['content'] = content;
  request.fields['score'] = score.toString();
  String imageFilesAsString = imagefiles.join(',');
  request.fields['imagefiles'] = imageFilesAsString;

  for (int i = 0; i < images.length; i++) {
    XFile imageFile = images[i];
    http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
      'image$i',
      imageFile.path,
      contentType: MediaType('image', 'jpeg'),
    );
    request.files.add(multipartFile);
  }
  final response = await request.send();
  print(response.statusCode);
  final responseString = await response.stream.bytesToString();
  print(responseString);
}

Future<void> deletePost(postid) async {
  final Map<String, dynamic> data = {
    'post_ID': postid,
  };
  final response = await http.delete(
    Uri.parse(postRequestUrl),
    headers: {
      'x-api-key': apiKey!,
    },
    body: json.encode(data),
  );

  print(response.statusCode);
  print(response.body);
}
