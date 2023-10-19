import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'post.dart';
import 'detail_page.dart';
import 'star.dart';

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
    bool isPadMode = MediaQuery.of(context).size.width > 1000;

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
            Text('리뷰 수정'),
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
                items: ['의류', '식사', '주거']
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
