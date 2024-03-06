import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: false).copyWith(),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class Bucket {
  final String job;
  bool isDone;

  Bucket({required this.job, this.isDone = false});

  void setFinish() {
    isDone = true;
  }

  void setUnfinish() {
    isDone = false;
  }

  void toggleFinish() {
    if (isDone) {
      setUnfinish();
    } else {
      setFinish();
    }
  }
}

/// 홈 페이지
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Bucket> bucketList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("버킷 리스트"),
      ),
      body: bucketList.isEmpty
          ? const Center(child: Text("버킷 리스트를 작성해 주세요."))
          : ListView.builder(
              itemCount: bucketList.length, // bucketList 개수 만큼 보여주기
              itemBuilder: (context, index) {
                Bucket bucket = bucketList[index]; // index에 해당하는 bucket 가져오기
                return ListTile(
                  // 버킷 리스트 할 일
                  title: Text(
                    bucket.job,
                    style: TextStyle(
                      fontSize: 24,
                      color: bucket.isDone ? Colors.grey : Colors.black,
                      decoration: bucket.isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  // 삭제 아이콘 버튼
                  trailing: IconButton(
                    icon: const Icon(CupertinoIcons.delete),
                    onPressed: () {
                      // 삭제 버튼 클릭시
                      showDeleteDialog(context, bucket);
                    },
                  ),
                  onTap: () {
                    // 아이템 클릭시
                    setState(() => bucket.toggleFinish());
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          // + 버튼 클릭시 버킷 생성 페이지로 이동
          Bucket? newBucket = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CreatePage(),
            ),
          );

          if (newBucket != null) {
            setState(() => bucketList.add(newBucket));
          }
        },
      ),
    );
  }

  void showDeleteDialog(BuildContext context, Bucket bucket) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("정말 삭제하시겠습니까?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                '취소',
                style: TextStyle(color: Colors.pink),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  bucketList.remove(bucket);
                });
              },
              child: const Text('확인'),
            )
          ],
        );
      },
    );
  }
}

/// 버킷 생성 페이지
class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final TextEditingController _textEditingController = TextEditingController();
  String? error;

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("버킷리스트 작성"),
        // 뒤로가기 버튼
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 텍스트 입력창
            TextField(
              controller: _textEditingController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "하고 싶은 일을 입력하세요",
                errorText: error,
              ),
            ),
            const SizedBox(height: 32),
            // 추가하기 버튼
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                child: const Text(
                  "추가하기",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                onPressed: () {
                  String enteredText = _textEditingController.text;

                  if (enteredText.isEmpty) {
                    setState(() => error = "입력란을 채워주세요.");
                    return;
                  }

                  setState(() => error = null);
                  Navigator.of(context).pop(Bucket(job: enteredText));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
