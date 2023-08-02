import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

void main() {
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

class User {
  final String id;
  final String password;

  User(this.id, this.password);
}

List<User> mockUsers = [
  User("id", "pw"),
  User("a", "a"),
];

class _LoginFormState extends State<LoginForm> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool _isIDValid(String id) {
    return id.isNotEmpty && id.length >= 6;
  }

  bool _isPasswordValid(String password) {
    return password.isNotEmpty && password.length >= 6;
  }

  bool isIDExists(id) {
    return mockUsers.any((user) => user.id == id);
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
                    String id = _emailController.text;
                    String pw = _passwordController.text;

                    if (_isIDValid(id) && _isPasswordValid(pw)) {
                      if (isIDExists(id)) {
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
                      } else {
                        User newUser = User(id, pw);
                        mockUsers.add(newUser);
                        Navigator.pop(context);
                      }
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('오류'),
                            content: Text('아이디와 비밀번호는 최소 6자리 입니다.'),
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

  void _login() {
    String enteredID = _emailController.text;
    String enteredPassword = _passwordController.text;

    bool loginSuccess = false;
    User? loggedInUser;

    for (User user in mockUsers) {
      if (user.id == enteredID && user.password == enteredPassword) {
        loginSuccess = true;
        loggedInUser = user;
        break;
      }
    }

    if (loginSuccess) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainPage(user: loggedInUser!),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Login Failed'),
            content: Text('Invalid email or password.'),
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
            onPressed: _login,
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
  final User user;

  ShowWritingPage({required this.user});

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
    String userID = widget.user.id;
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
                builder: (context) => MainPage(user: widget.user),
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
                              Navigator.pop(context, List.from(posts));
                            },
                            child: Text('확인'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  addPost(title, category, content, userID, score);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainPage(user: widget.user),
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
  final User? user;

  MainPage({this.user});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Post> filteredPosts = [];

  @override
  void initState() {
    super.initState();
    filteredPosts = List.from(posts);
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = widget.user != null;
    bool isPadMode = MediaQuery.of(context).size.width > 700;
    void filtering(String searchText, String category) {
      setState(
        () {
          filteredPosts = posts.where((post) {
            bool isCategoryMatched =
                category == '전체' || post.category == category;
            bool isTitleMatched =
                post.title.toLowerCase().contains(searchText.toLowerCase());
            return isCategoryMatched && (searchText.isEmpty || isTitleMatched);
          }).toList();
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
                    builder: (context) => MainPage(user: widget.user)),
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
        child: filteredPosts.isEmpty
            ? Text('게시물이 없습니다.')
            : ListView.builder(
                itemCount: filteredPosts.length,
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
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(width: 15),
                              Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('제목: ${filteredPosts[index].title}'),
                                    SizedBox(height: 12),
                                    Text(
                                        '작성자: ${filteredPosts[index].writer_id}'),
                                    SizedBox(height: 12),
                                    StarDisplay(
                                        value: filteredPosts[index].score),
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
                                  post: filteredPosts[index],
                                  user: widget.user),
                            ),
                          );
                        },
                      ),
                    ),
                  );
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
                builder: (context) => ShowWritingPage(user: widget.user!),
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
class ShowDetailPage extends StatelessWidget {
  final Post post;
  final User? user;
  final TextEditingController _commentController = TextEditingController();

  void _submitComment() {
    // String comment = _commentController.text;
    _commentController.clear();
  }

  ShowDetailPage({required this.post, this.user});

  @override
  Widget build(BuildContext context) {
    bool isCurrentUserAuthor = user != null && post.writer_id == user!.id;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MainPage(user: user),
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
                          builder: (context) => MainPage(user: user),
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
                        // 사진 불러오기
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
                      '작성자 : ${post.writer_id}',
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
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4)),
                      child: ListView(
                        children: [
                          Card(
                            child: ListTile(
                              title: Text('댓글1'),
                              subtitle: Text('내용1'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    user != null
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
                                  onPressed: _submitComment,
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
                if (user != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ShowEditPage(post: post, user: user),
                    ),
                  );
                }
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
  final User? user;

  ShowEditPage({required this.post, required this.user});

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
    String userID = widget.post.writer_id;
    String? category = _selectedCategory;
    String content = _contentController.text;

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
                    ShowDetailPage(post: widget.post, user: widget.user),
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
                  updatePost(postid, _titleController.text, _selectedCategory!,
                      _contentController.text, userID, _rating);
                  Post updatedPost = getPost(postid);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ShowDetailPage(post: updatedPost, user: widget.user),
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

List<Post> posts = [];

class Post {
  final String postid;
  final String title;
  final String content;
  final String writer_id;
  final int score;
  final String category;
  final DateTime createdTime;

  Post({
    required this.postid,
    required this.title,
    required this.category,
    required this.content,
    required this.writer_id,
    required this.score,
    required this.createdTime,
  });

  factory Post.createNewPost(String title, String category, String content,
      String writer_id, int score) {
    return Post(
      postid: Uuid().v4(),
      title: title,
      category: category,
      content: content,
      writer_id: writer_id,
      score: score,
      createdTime: DateTime.now(),
    );
  }
}

void addPost(String title, String category, String content, String writer_id,
    int score) {
  posts.add(Post.createNewPost(title, category, content, writer_id, score));
}

Post getPost(String postid) {
  return posts.firstWhere((post) => post.postid == postid);
}

void updatePost(String postid, String title, String category, String content,
    String writer_id, int score) {
  final index = posts.indexWhere((post) => post.postid == postid);
  if (index != -1) {
    posts[index] = Post(
      postid: postid,
      title: title,
      category: category,
      content: content,
      writer_id: posts[index].writer_id,
      score: score,
      createdTime: posts[index].createdTime,
    );
  }
}

void deletePost(postid) {
  posts.removeWhere((post) => post.postid == postid);
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
