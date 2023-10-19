import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'login_page.dart';
import 'detail_page.dart';
import 'post.dart';
import 'writing_page.dart';
import 'star.dart';

String formatTimeAgo(DateTime time) {
  final now = DateTime.now();
  final difference = now.difference(time);

  if (difference.inSeconds < 60) {
    return '${difference.inSeconds}초 전';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}분 전';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}시간 전';
  } else {
    final formatter = DateFormat('MM-dd HH:mm');
    return formatter.format(time);
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
        toolbarHeight: 80,
        leadingWidth: 150,
        leading: Center(
          child: SizedBox(
            width: 150,
            child: TextButton.icon(
              label: Text(
                'Re View',
                style: TextStyle(fontSize: 20),
              ),
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
                size: 40,
              ),
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
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => MainPage()));
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.lightBlue,
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                      side: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                child: Text(
                  '로그아웃',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          else
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.lightBlue,
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                      side: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                child: Text(
                  '로그인',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          SizedBox(width: 10),
          IconButton(
            onPressed: () {
              // 마이페이지는 시간상 생략
            },
            icon: Icon(Icons.account_circle),
            color: Color.fromRGBO(100, 100, 100, 1),
            iconSize: 30,
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
                  ? Center(
                      child: Text('게시물이 없습니다.'),
                    )
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
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(posts[index].title),
                                          SizedBox(height: 12),
                                          Text(posts[index].writerid),
                                          Spacer(),
                                          StarDisplay(
                                              value: posts[index].score),
                                        ],
                                      ),
                                    ),
                                    Spacer(),
                                    Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            formatTimeAgo(
                                                posts[index].createdTime),
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
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

// 메인페이지 상단 검색창
class SearchBar extends StatefulWidget {
  final Function(String, String) onFilter;

  SearchBar({required this.onFilter});

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _textController = TextEditingController();
  List<String> categories = ['전체', '의류', '식사', '주거'];
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
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
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
                  fontSize: 12,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
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
