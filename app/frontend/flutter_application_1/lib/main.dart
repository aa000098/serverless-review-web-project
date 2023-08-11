import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: "assets/config/.env");
  runApp(ReviewApp());
}

// 페이지 시작
class ReviewApp extends StatelessWidget {
  const ReviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Main Page',
      home: MainPage(),
    );
  }
}

// 로그인 페이지
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: LoginForm(),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

final apiUrl = dotenv.env['API_URL'];
final apiKey = dotenv.env['API_KEY'];
final apilogin = dotenv.env['API_LOGIN'];
final apipost = dotenv.env['API_POST'];
final apicomment = dotenv.env['API_COMMENT'];

class _LoginFormState extends State<LoginForm> {
  final String loginRequestUrl = '$apiUrl/$apilogin';

  Future<bool> _isCreateUserSuccess(entered_id, entered_pw) async {
    final Map<String, String> data = {
      'method': 'create_user',
      'entered_id': entered_id,
      'entered_pw': entered_pw,
    };

    final response = await http.post(
      Uri.parse(loginRequestUrl),
      headers: {
        'x-api-key': apiKey!,
      },
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      print(response.statusCode);
      return false;
    }
  }

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool _isIDValid(String entered_id) {
    return entered_id.isNotEmpty && entered_id.length >= 5;
  }

  bool _isPasswordValid(String entered_pw) {
    return entered_pw.isNotEmpty && entered_pw.length >= 5;
  }

  void _showSignUpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Sign Up'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: '아이디를 입력하세요',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: '비밀번호를 입력하세요',
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('취소'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    String entered_id = _emailController.text;
                    String entered_pw = _passwordController.text;
                    if (_isIDValid(entered_id) &&
                        _isPasswordValid(entered_pw)) {
                      _isCreateUserSuccess(entered_id, entered_pw).then(
                        (isSuccess) {
                          if (isSuccess) {
                            Navigator.pop(context);
                          } else {
                            Future.delayed(
                              Duration.zero,
                              () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('오류'),
                                      content: Text('이미 존재하는 아이디 입니다.'),
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('확인'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          }
                        },
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('오류'),
                            content: Text('아이디와 비밀번호는 최소 5자리 입니다.'),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('확인'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: Text('회원가입'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<bool> _login() async {
    String entered_id = _emailController.text;
    String entered_pw = _passwordController.text;

    final Map<String, String> data = {
      'method': 'read_user',
      'entered_id': entered_id,
      'entered_pw': entered_pw,
    };

    final response = await http.post(
      Uri.parse(loginRequestUrl),
      headers: {
        'x-api-key': apiKey!,
      },
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      print(response.statusCode);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.all_inclusive,
                color: Colors.lightBlue,
                size: 80,
              ),
              SizedBox(width: 8),
              Text(
                'Re View',
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 80.0),
          SizedBox(
            height: 50,
            width: 250,
            child: TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
              ),
            ),
          ),
          SizedBox(height: 16.0),
          SizedBox(
            height: 50,
            width: 250,
            child: TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
            ),
          ),
          SizedBox(height: 15.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 250),
              ElevatedButton(
                  onPressed: () {
                    _showSignUpDialog(context);
                  },
                  child: Text('Sign Up'))
            ],
          ),
          SizedBox(height: 12.0),
          ElevatedButton(
            onPressed: () {
              _login().then((isLoggedIn) {
                if (isLoggedIn) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MainPage(userid: _emailController.text),
                    ),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Login Failed'),
                        content: Text('아이디 비밀번호가 틀렸습니다.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              });
            },
            child: SizedBox(
              width: 150,
              height: 40,
              child: Center(
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 별점 보여주기
class StarDisplay extends StatelessWidget {
  final int value;
  const StarDisplay({this.value = 0});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < value ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }
}

// 별점 매기기
class StarRating extends StatelessWidget {
  final int value;
  final IconData filledStar;
  final IconData unfilledStar;
  final void Function(int index) onChanged;

  const StarRating({
    this.value = 0,
    required this.filledStar,
    required this.unfilledStar,
    required this.onChanged,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        return IconButton(
          onPressed: () {
            onChanged(value == index + 1 ? index : index + 1);
          },
          color: Colors.amber,
          iconSize: 30,
          icon: Icon(
            index < value ? filledStar : unfilledStar,
          ),
          padding: EdgeInsets.zero,
          tooltip: "${index + 1} of 5",
        );
      }),
    );
  }
}

// 리뷰쓰기 페이지
class ShowWritingPage extends StatefulWidget {
  final String userid;

  ShowWritingPage({required this.userid});

  @override
  _PostReviewState createState() => _PostReviewState();
}

class _PostReviewState extends State<ShowWritingPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String? _selectedCategory;
  int _rating = 0;
  List<XFile> _selectedImage = [];

  void _selectImage() async {
    final picker = ImagePicker();
    final List<XFile> pickedImage = await picker.pickMultiImage();
    setState(() {
      _selectedImage = pickedImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isPadMode = MediaQuery.of(context).size.width > 900;

    String title = _titleController.text;
    String userID = widget.userid;
    String? category = _selectedCategory;
    String content = _contentController.text;
    int score = _rating;

    List<Widget> _boxContents = [
      IconButton(
        onPressed: () {
          _selectImage();
        },
        icon: Container(
          alignment: Alignment.center,
          decoration:
              BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Icon(
            Icons.camera_alt_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      Container(),
      Container(),
      _selectedImage.length <= 4
          ? Container()
          : FittedBox(
              child: Container(
                padding: EdgeInsets.all(6),
                decoration:
                    BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Text(
                  '+${(_selectedImage.length - 4).toString()}',
                ),
              ),
            ),
    ];

    return Scaffold(
      // 상단바
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MainPage(userid: widget.userid),
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
            Text('리뷰쓰기'),
          ],
        ),
        actions: [
          SizedBox(
            child: TextButton(
              onPressed: () {
                if (title.isEmpty || category == null || content.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('오류'),
                        content: Text('모든 정보를 입력해주세요.'),
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
                  addPost(
                      title, category, content, userID, score, _selectedImage);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainPage(userid: widget.userid),
                    ),
                  );
                }
              },
              child: Text(
                '제출',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      // 입력란
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
            vertical: 40, horizontal: isPadMode ? 280 : 100),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: '제목'),
              ),
              SizedBox(height: 60),
              Container(
                height: 130,
                width: 400,
                child: GridView.count(
                  padding: EdgeInsets.all(2),
                  crossAxisCount: 4,
                  crossAxisSpacing: 5,
                  childAspectRatio: 0.9,
                  shrinkWrap: true,
                  children: List.generate(
                    4,
                    (index) => DottedBorder(
                      color: Colors.blue,
                      dashPattern: [5, 3],
                      borderType: BorderType.RRect,
                      radius: Radius.circular(10),
                      child: Container(
                        decoration: index <= _selectedImage.length - 1
                            ? BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: FileImage(
                                    File(_selectedImage[index].path),
                                  ),
                                ),
                              )
                            : null,
                        child: Center(child: _boxContents[index]),
                      ),
                    ),
                  ).toList(),
                ),
              ),
              SizedBox(height: 30),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(labelText: '카테고리'),
                items: ['의', '식', '주']
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(
                    () {
                      _selectedCategory = value;
                    },
                  );
                },
              ),
              SizedBox(height: 50),
              TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: '내용',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              SizedBox(height: 50),
              Row(
                children: [
                  Text('별점:'),
                  StarRating(
                    value: _rating, // 현재 선택된 별점
                    filledStar: Icons.star, // 채워진 별 아이콘
                    unfilledStar: Icons.star_border, // 빈 별 아이콘
                    onChanged: (index) {
                      setState(() {
                        _rating = index; // 선택된 별점을 상태로 저장
                      });
                    },
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

// 메인 페이지
class MainPage extends StatefulWidget {
  final String? userid;

  MainPage({this.userid});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Future<List<Post>> filteredPosts = Future<List<Post>>.value([]);

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    List<Post> posts = await readPost();
    if (mounted) {
      setState(() {
        filteredPosts = Future<List<Post>>.value(posts);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = widget.userid != null;
    bool isPadMode = MediaQuery.of(context).size.width > 700;

    Future<void> filtering(String searchText, String category) async {
      await fetchPosts();
      List<Post> posts = await filteredPosts;
      List<Post> filtered = posts.where((post) {
        bool isCategoryMatched = category == '전체' || post.category == category;
        bool isTitleMatched =
            post.title.toLowerCase().contains(searchText.toLowerCase());
        return isCategoryMatched && (searchText.isEmpty || isTitleMatched);
      }).toList();

      setState(
        () {
          filteredPosts = Future.value(filtered);
        },
      );
    }

    return Scaffold(
      // 메인 페이지 상단 바
      appBar: AppBar(
        leadingWidth: 100,
        leading: SizedBox(
          width: 100,
          child: TextButton.icon(
            label: Text('Re View'),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => MainPage(userid: widget.userid)),
              );
            },
            icon: Icon(
              Icons.all_inclusive,
              color: Colors.lightBlue,
              size: 20,
            ),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SearchBar(
              onFilter: filtering,
            ),
          ],
        ),
        actions: [
          if (isLoggedIn)
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => MainPage()));
              },
              child: Text(
                '로그아웃',
                style: TextStyle(
                    color: Color.fromRGBO(100, 100, 100, 1),
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
              ),
            )
          else
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                );
              },
              child: Text(
                '로그인',
                style: TextStyle(
                    color: Color.fromRGBO(100, 100, 100, 1),
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
              ),
            ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.account_circle),
            color: Color.fromRGBO(100, 100, 100, 1),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 1,
      ),

      // 메인 페이지 리스트
      body: Padding(
        padding: EdgeInsets.all(isPadMode ? 40 : 15),
        child: FutureBuilder<List<Post>>(
          future: filteredPosts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('오류 발생: ${snapshot.error}');
            } else {
              List<Post> posts = snapshot.data ?? [];
              return posts.isEmpty
                  ? Text('게시물이 없습니다.')
                  : ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        return SizedBox(
                          height: 180,
                          child: Card(
                            child: InkWell(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 150,
                                      height: 150,
                                      child: Card(
                                          child: posts[index].imagefiles.isEmpty
                                              ? Container(
                                                  color: Colors.grey,
                                                )
                                              : Image.network(
                                                  posts[index].imagefiles[0],
                                                  fit: BoxFit.cover,
                                                )),
                                    ),
                                    SizedBox(width: 15),
                                    Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text('제목: ${posts[index].title}'),
                                          SizedBox(height: 12),
                                          Text('작성자: ${posts[index].writerid}'),
                                          SizedBox(height: 12),
                                          StarDisplay(
                                              value: posts[index].score),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ShowDetailPage(
                                        post: posts[index],
                                        userid: widget.userid),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
            }
          },
        ),
      ),
      // 메인 페이지 리뷰쓰기 버튼
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (isLoggedIn) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ShowWritingPage(userid: widget.userid!),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ),
            );
          }
        },
        backgroundColor: Color.fromARGB(255, 73, 6, 218),
        label: const Text('리뷰쓰기'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

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
        title: Text('게시물 상세'),
        actions: [
          isCurrentUserAuthor
              ? PopupMenuButton(
                  onSelected: (value) {
                    if (value == 'delete') {
                      deletePost(post.postid);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainPage(userid: userid),
                        ),
                      );
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
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    post.title,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    height: 300,
                    width: 400,
                    child: Card(
                      child: post.imagefiles.isEmpty
                          ? Container(
                              color: Colors.grey,
                            )
                          : Image.network(
                              post.imagefiles[0],
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 350,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 30),
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
                    SizedBox(height: 20),
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
                  ],
                ),
              ),
              SizedBox(height: 50),
              SizedBox(
                width: 400,
                child: Column(
                  children: [
                    Container(
                      height: 200,
                      width: 350,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4)),
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
                                .where(
                                    (comment) => comment.postid == post.postid)
                                .toList();
                            return commentlist.isEmpty
                                ? Text('댓글이 없습니다.')
                                : Card(
                                    child: ListView.builder(
                                    itemCount: commentlist.length,
                                    itemBuilder: (context, index) {
                                      return SizedBox(
                                        height: 50,
                                        child: Card(
                                          child: InkWell(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 5),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: 50,
                                                    height: 60,
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
                                                  SizedBox(width: 5),
                                                  Text(commentlist[index]
                                                      .writerid),
                                                  Spacer(),
                                                  Text(commentlist[index]
                                                      .content),
                                                  Spacer(),
                                                  Text(
                                                    DateFormat('MM-dd HH:mm')
                                                        .format(
                                                            commentlist[index]
                                                                .createdTime),
                                                    style: TextStyle(
                                                      fontSize: 8,
                                                    ),
                                                  ),
                                                  SizedBox(width: 5),
                                                  commentlist[index].writerid ==
                                                          userid
                                                      ? PopupMenuButton<String>(
                                                          itemBuilder:
                                                              (BuildContext
                                                                      context) =>
                                                                  <PopupMenuEntry<
                                                                      String>>[
                                                            PopupMenuItem<
                                                                String>(
                                                              value: 'edit',
                                                              child: Text('수정'),
                                                            ),
                                                            PopupMenuItem<
                                                                String>(
                                                              value: 'delete',
                                                              child: Text('삭제'),
                                                            ),
                                                          ],
                                                          onSelected: (String
                                                              value) async {
                                                            if (value ==
                                                                'edit') {
                                                              _editedContentController
                                                                      .text =
                                                                  commentlist[
                                                                          index]
                                                                      .content;
                                                              await showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) =>
                                                                        AlertDialog(
                                                                  title: Text(
                                                                      '댓글 수정'),
                                                                  content:
                                                                      TextFormField(
                                                                    controller:
                                                                        _editedContentController,
                                                                    decoration:
                                                                        InputDecoration(
                                                                      border: InputBorder
                                                                          .none,
                                                                    ),
                                                                  ),
                                                                  actions: [
                                                                    TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child: Text(
                                                                          '취소'),
                                                                    ),
                                                                    TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child: Text(
                                                                          '저장'),
                                                                    ),
                                                                  ],
                                                                ),
                                                              );

                                                              await updateComment(
                                                                  commentlist[
                                                                          index]
                                                                      .postid,
                                                                  _editedContentController
                                                                      .text,
                                                                  commentlist[
                                                                          index]
                                                                      .commentid);

                                                              await fetchComments();
                                                            } else if (value ==
                                                                'delete') {
                                                              await deleteComment(
                                                                  commentlist[
                                                                          index]
                                                                      .commentid);
                                                              await fetchComments();
                                                            }
                                                          },
                                                        )
                                                      : SizedBox(width: 10),
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

// 리뷰 수정 페이지
class ShowEditPage extends StatefulWidget {
  final Post post;
  final String? userid;

  ShowEditPage({required this.post, required this.userid});

  @override
  _PostEditState createState() => _PostEditState();
}

class _PostEditState extends State<ShowEditPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String? _selectedCategory;
  int _rating = 0;
  List<XFile> _selectedImage = [];

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.post.title;
    _contentController.text = widget.post.content;
    _selectedCategory = widget.post.category;
    _rating = widget.post.score;
  }

  void _selectImage() async {
    final picker = ImagePicker();
    final List<XFile> pickedImage = await picker.pickMultiImage();
    setState(() {
      _selectedImage = pickedImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isPadMode = MediaQuery.of(context).size.width > 900;

    String postid = widget.post.postid;
    String title = _titleController.text;
    String? category = _selectedCategory;
    String content = _contentController.text;
    List<dynamic> imagefiles = widget.post.imagefiles;

    List<Widget> _boxContents = [
      IconButton(
        onPressed: () {
          _selectImage();
        },
        icon: Container(
          alignment: Alignment.center,
          decoration:
              BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Icon(
            Icons.camera_alt_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      Container(),
      Container(),
      _selectedImage.length <= 4
          ? Container()
          : FittedBox(
              child: Container(
                padding: EdgeInsets.all(6),
                decoration:
                    BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Text(
                  '+${(_selectedImage.length - 4).toString()}',
                ),
              ),
            ),
    ];

    return Scaffold(
      // 상단바
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ShowDetailPage(post: widget.post, userid: widget.userid),
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
            Text('리뷰쓰기'),
          ],
        ),
        actions: [
          SizedBox(
            child: TextButton(
              onPressed: () {
                if (title.isEmpty || category == null || content.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('오류'),
                        content: Text('모든 정보를 입력해주세요.'),
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
                  updatePost(
                      postid,
                      _titleController.text,
                      _selectedCategory!,
                      _contentController.text,
                      _rating,
                      imagefiles,
                      _selectedImage);
                  getPost(postid).then((updatedPost) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShowDetailPage(
                            post: updatedPost, userid: widget.userid),
                      ),
                    );
                  });
                }
              },
              child: Text(
                '제출',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      // 입력란
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
            vertical: 40, horizontal: isPadMode ? 280 : 100),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: '제목'),
              ),
              SizedBox(height: 60),
              Container(
                height: 130,
                width: 400,
                child: GridView.count(
                  padding: EdgeInsets.all(2),
                  crossAxisCount: 4,
                  crossAxisSpacing: 5,
                  childAspectRatio: 0.9,
                  shrinkWrap: true,
                  children: List.generate(
                    4,
                    (index) => DottedBorder(
                      color: Colors.blue,
                      dashPattern: [5, 3],
                      borderType: BorderType.RRect,
                      radius: Radius.circular(10),
                      child: Container(
                        decoration: index <= _selectedImage.length - 1
                            ? BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: FileImage(
                                    File(_selectedImage[index].path),
                                  ),
                                ),
                              )
                            : null,
                        child: Center(child: _boxContents[index]),
                      ),
                    ),
                  ).toList(),
                ),
              ),
              SizedBox(height: 30),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(labelText: '카테고리'),
                items: ['의', '식', '주']
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(
                    () {
                      _selectedCategory = value;
                    },
                  );
                },
              ),
              SizedBox(height: 50),
              TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: '내용',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              SizedBox(height: 50),
              Row(
                children: [
                  Text('별점:'),
                  StarRating(
                    value: _rating, // 현재 선택된 별점
                    filledStar: Icons.star, // 채워진 별 아이콘
                    unfilledStar: Icons.star_border, // 빈 별 아이콘
                    onChanged: (index) {
                      setState(() {
                        _rating = index; // 선택된 별점을 상태로 저장
                      });
                    },
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

// 이미지 기능

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

Future<void> addComment(String postid, String content, String writerid) async {
  final Map<String, String> data = {
    'method': 'create_comment',
    'postid': postid,
    'content': content,
    'writerid': writerid,
  };

  final response = await http.post(
    Uri.parse(postRequestUrl),
    headers: {
      'x-api-key': apiKey!,
    },
    body: json.encode(data),
  );
  print(response.statusCode);
}

final commentRequestUrl = '$apiUrl/$apicomment';

Future<List<Comment>> readComment() async {
  final Map<String, String> data = {
    'method': 'read_comment',
  };

  final response = await http.post(
    Uri.parse(commentRequestUrl),
    headers: {
      'x-api-key': apiKey!,
    },
    body: json.encode(data),
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
  return comments;
}

Future<void> updateComment(
    String postid, String content, String commentid) async {
  final Map<String, String> data = {
    'method': 'update_comment',
    'content': content,
    'comment_ID': commentid,
  };
  final response = await http.post(
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
    'method': 'delete_comment',
    'comment_ID': commentid,
  };
  final response = await http.post(
    Uri.parse(commentRequestUrl),
    headers: {
      'x-api-key': apiKey!,
    },
    body: json.encode(data),
  );
  print(response.statusCode);
}

// 메인페이지 상단 검색창
class SearchBar extends StatefulWidget {
  final Function(String, String) onFilter;

  SearchBar({required this.onFilter});

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _textController = TextEditingController();
  List<String> categories = ['전체', '의', '식', '주'];
  String selectedCategory = '전체';

  @override
  Widget build(BuildContext context) {
    int mediaSize = MediaQuery.of(context).size.width.toInt();
    return Row(
      children: [
        SizedBox(
          width: mediaSize / 3,
          height: 30,
          child: TextField(
            style: TextStyle(fontSize: 12),
            controller: _textController,
            decoration: InputDecoration(
              hintText: '검색어를 입력하세요',
              prefixIcon: Icon(Icons.search),
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onChanged: (value) {
              widget.onFilter(value, selectedCategory);
            },
          ),
        ),
        SizedBox(width: 15),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 20,
              child: DropdownButton<String>(
                value: selectedCategory,
                iconSize: 15,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.black,
                ),
                underline: SizedBox(),
                items: categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCategory = newValue ?? '전체';
                    widget.onFilter('', selectedCategory);
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
