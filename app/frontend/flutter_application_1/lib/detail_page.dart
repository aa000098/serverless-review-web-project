import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'main_page.dart';
import 'post.dart';
import 'comment.dart';
import 'star.dart';
import 'edit_page.dart';

// 리뷰 상세 페이지
class ShowDetailPage extends StatefulWidget {
  final Post post;
  final String? userid;

  ShowDetailPage({required this.post, this.userid});

  @override
  _ShowDetailPageState createState() => _ShowDetailPageState();
}

class _ShowDetailPageState extends State<ShowDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _editedContentController =
      TextEditingController();
  int _currentPage = 0;
  Future<List<Comment>> comments = Future<List<Comment>>.value([]);

  Future<void> _submitComment(postid, content, userid) async {
    await addComment(postid, content, userid);
    await fetchComments();
    _commentController.clear();
  }

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  Future<void> fetchComments() async {
    List<Comment> commentlist = await readComment();
    if (mounted) {
      setState(() {
        comments = Future<List<Comment>>.value(commentlist);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String? userid = widget.userid;
    final post = widget.post;
    bool isCurrentUserAuthor = userid != null && post.writerid == userid;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MainPage(userid: userid),
              ),
            );
          },
          icon: Icon(
            Icons.arrow_back,
            size: 30,
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('게시물 상세'),
          ],
        ),
        actions: [
          isCurrentUserAuthor
              ? PopupMenuButton(
                  onSelected: (value) {
                    if (value == 'delete') {
                      deletePost(post.postid).then((_) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MainPage(userid: userid),
                          ),
                        );
                      });
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('삭제'),
                    ),
                  ],
                )
              : SizedBox(),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 500,
                child: Text(
                  post.title,
                  style: TextStyle(
                    fontSize: 40,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
              post.imagefiles.isEmpty
                  ? SizedBox(
                      height: 300,
                      width: 400,
                      child: Container(
                        color: Colors.grey,
                        child: Center(
                          child: Text('사진이 없습니다.'),
                        ),
                      ),
                    )
                  : Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        SizedBox(
                          height: 300,
                          width: 400,
                          child: GestureDetector(
                            onHorizontalDragEnd: (details) {
                              if (details.velocity.pixelsPerSecond.dx < 0) {
                                if (_currentPage < post.imagefiles.length - 1) {
                                  setState(() {
                                    _currentPage += 1;
                                  });
                                }
                              } else if (details.velocity.pixelsPerSecond.dx >
                                  0) {
                                if (_currentPage > 0) {
                                  setState(() {
                                    _currentPage -= 1;
                                  });
                                }
                              }
                            },
                            child: Image.network(
                              post.imagefiles[_currentPage],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(500)),
                          child: Text(
                            '${_currentPage + 1}/${post.imagefiles.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              post.imagefiles.length,
                              (index) {
                                return Container(
                                  width: 8.0,
                                  height: 8.0,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 10.0,
                                    horizontal: 5.0,
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentPage == index
                                        ? Colors.black //Colors.white
                                        : Colors.grey.withOpacity(
                                            0.4), //Colors.white.withOpacity(0.4),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
              SizedBox(height: 15),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(width: 1, color: Colors.grey),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 450,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        Text(
                          '작성시간 : ${DateFormat('yyyy-MM-dd HH:mm').format(post.createdTime)}',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '작성자 : ${post.writerid}',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '카테고리 : ${post.category}',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 10),
                        StarDisplay(value: post.score),
                        SizedBox(height: 20),
                        Text(
                          '내용',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          post.content,
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
              SizedBox(
                width: 400,
                child: Column(
                  children: [
                    Container(
                      height: 200,
                      width: 400,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4)),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: FutureBuilder<List<Comment>>(
                          future: comments,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('오류 발생: ${snapshot.error}');
                            } else {
                              List<Comment> allComments = snapshot.data ?? [];
                              List<Comment> commentlist = allComments
                                  .where((comment) =>
                                      comment.postid == post.postid)
                                  .toList();
                              return commentlist.isEmpty
                                  ? Text('댓글이 없습니다.')
                                  : Card(
                                      child: ListView.builder(
                                      itemCount: commentlist.length,
                                      itemBuilder: (context, index) {
                                        return SizedBox(
                                          height: 100,
                                          child: Card(
                                            child: InkWell(
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 5),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      width: 40,
                                                      height: 40,
                                                      child: IconButton(
                                                        onPressed: () {},
                                                        icon: Icon(
                                                          Icons.account_circle,
                                                          size: 30,
                                                        ),
                                                        color: Color.fromRGBO(
                                                            100, 100, 100, 1),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 300,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              SizedBox(
                                                                width: 300,
                                                                child: Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(commentlist[
                                                                            index]
                                                                        .writerid),
                                                                    Spacer(),
                                                                    Text(
                                                                      DateFormat(
                                                                              'MM-dd HH:mm')
                                                                          .format(
                                                                              commentlist[index].createdTime),
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            10,
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                        width:
                                                                            5),
                                                                    commentlist[index].writerid ==
                                                                            userid
                                                                        ? PopupMenuButton<
                                                                            String>(
                                                                            itemBuilder: (BuildContext context) =>
                                                                                <PopupMenuEntry<String>>[
                                                                              PopupMenuItem<String>(
                                                                                value: 'edit',
                                                                                child: Text('수정'),
                                                                              ),
                                                                              PopupMenuItem<String>(
                                                                                value: 'delete',
                                                                                child: Text('삭제'),
                                                                              ),
                                                                            ],
                                                                            onSelected:
                                                                                (String value) async {
                                                                              if (value == 'edit') {
                                                                                _editedContentController.text = commentlist[index].content;
                                                                                await showDialog(
                                                                                  context: context,
                                                                                  builder: (context) => AlertDialog(
                                                                                    title: Text('댓글 수정'),
                                                                                    content: TextFormField(
                                                                                      controller: _editedContentController,
                                                                                      decoration: InputDecoration(
                                                                                        border: InputBorder.none,
                                                                                      ),
                                                                                    ),
                                                                                    actions: [
                                                                                      TextButton(
                                                                                        onPressed: () {
                                                                                          Navigator.pop(context);
                                                                                        },
                                                                                        child: Text('취소'),
                                                                                      ),
                                                                                      TextButton(
                                                                                        onPressed: () {
                                                                                          Navigator.pop(context);
                                                                                        },
                                                                                        child: Text('저장'),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                );
                                                                                await updateComment(commentlist[index].postid, _editedContentController.text, commentlist[index].commentid);
                                                                                await fetchComments();
                                                                              } else if (value == 'delete') {
                                                                                await deleteComment(commentlist[index].commentid);
                                                                                await fetchComments();
                                                                              }
                                                                            },
                                                                          )
                                                                        : SizedBox(
                                                                            width:
                                                                                10),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    right: 10),
                                                            child: SizedBox(
                                                              width: 300,
                                                              child: Text(
                                                                  commentlist[
                                                                          index]
                                                                      .content),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ));
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    userid != null
                        ? SizedBox(
                            child: Column(
                              children: [
                                TextField(
                                  controller: _commentController,
                                  decoration: InputDecoration(
                                    hintText: '댓글을 입력하세요.',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () async {
                                    if (_commentController.text.isEmpty) {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text('오류'),
                                            content: Text('댓글을 입력해주세요.'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text('확인'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    } else {
                                      _submitComment(post.postid,
                                          _commentController.text, userid);
                                    }
                                  },
                                  child: Text('제출'),
                                ),
                              ],
                            ),
                          )
                        : Text('로그인 후 댓글을 작성할 수 있습니다.'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: isCurrentUserAuthor
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ShowEditPage(post: post, userid: userid),
                  ),
                );
              },
              backgroundColor: Color.fromARGB(255, 73, 6, 218),
              label: const Text('수정'),
              icon: const Icon(Icons.edit),
            )
          : null,
    );
  }
}
