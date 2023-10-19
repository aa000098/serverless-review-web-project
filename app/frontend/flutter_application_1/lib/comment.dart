import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api.dart';

// 댓글 기능
class Comment {
  final String postid;
  final String content;
  final String commentid;
  final DateTime createdTime;
  final String writerid;

  Comment({
    required this.postid,
    required this.content,
    required this.commentid,
    required this.createdTime,
    required this.writerid,
  });
}

final commentRequestUrl = '$apiUrl/$apicomment';

Future<void> addComment(String postid, String content, String writerid) async {
  final Map<String, String> data = {
    'postid': postid,
    'content': content,
    'writerid': writerid,
  };

  final response = await http.post(
    Uri.parse(commentRequestUrl),
    headers: {
      'x-api-key': apiKey!,
    },
    body: json.encode(data),
  );
  print(response.statusCode);
  print(response.body);
}

Future<List<Comment>> readComment() async {
  final response = await http.get(
    Uri.parse(commentRequestUrl),
    headers: {
      'x-api-key': apiKey!,
    },
  );
  List<Comment> comments = [];
  print(response.statusCode);

  if (response.statusCode == 200) {
    List data = json.decode(response.body);

    comments = data
        .map(
          (item) => Comment(
            commentid: item['comment_ID'],
            content: item['content'],
            postid: item['post_ID'],
            writerid: item['writerid'],
            createdTime: DateTime.parse(item['createdTime']),
          ),
        )
        .toList();
  }
  comments.sort((a, b) => b.createdTime.compareTo(a.createdTime));
  return comments;
}

Future<void> updateComment(
    String postid, String content, String commentid) async {
  final Map<String, String> data = {
    'content': content,
    'comment_ID': commentid,
  };
  final response = await http.patch(
    Uri.parse(commentRequestUrl),
    headers: {
      'x-api-key': apiKey!,
    },
    body: json.encode(data),
  );
  print(response.statusCode);
}

Future<void> deleteComment(commentid) async {
  final Map<String, String> data = {
    'comment_ID': commentid,
  };
  final response = await http.delete(
    Uri.parse(commentRequestUrl),
    headers: {
      'x-api-key': apiKey!,
    },
    body: json.encode(data),
  );
  print(response.statusCode);
}
