import 'package:flutter/cupertino.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:io' show Platform; // 引入 Platform 類別
import 'api_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(TodoApp());
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      home: TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  final ApiService apiService = ApiService();
  List<dynamic> notes = [];

  @override
  void initState() {
    super.initState();
    fetchNotes();
  }

  void authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await _localAuthentication.authenticate(
        localizedReason: '解鎖來重新整理待辦事項',
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: '驗證失敗。\n請按下「重新整理」按鈕重新驗證',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: CupertinoColors.systemGrey.withOpacity(0.8),
        textColor: CupertinoColors.white,
        fontSize: 16.0,
      );
    }
    if (!authenticated) {
      // 在這裡處理驗證失敗的情況
      Fluttertoast.showToast(
        msg: '驗證失敗。\n請按下「重新整理」按鈕重新驗證',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: CupertinoColors.systemGrey.withOpacity(0.8),
        textColor: CupertinoColors.white,
        fontSize: 16.0,
      );
    } else {
      try {
        final fetchedNotes = await apiService.getNotes();
        setState(() {
          notes = fetchedNotes;
        });
      } catch (e) {
        print('無法獲取事件列表: $e');
      }
    }
  }

  void fetchNotes() async {
    if (Platform.isIOS || Platform.isWindows) {
      authenticate(); // 只在 iOS 和 Windows 上進行驗證
    } else {
      try {
        final fetchedNotes = await apiService.getNotes();
        setState(() {
          notes = fetchedNotes;
        });
      } catch (e) {
        print('無法獲取事件列表: $e');
      }
    }
  }

  void addNote() async {
    TextEditingController descriptionController = TextEditingController();
    String importance = '中'; // Default value
    String urgency = '中'; // Default value

    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('新增待辦事項'),
          content: Column(
            children: [
              CupertinoTextField(controller: descriptionController, placeholder: '事項'),
              Text("\n重要嗎？"),
              CupertinoSegmentedControl<String>(
                children: {
                  '低': Padding(padding: EdgeInsets.all(10), child: Text('低')),
                  '中': Padding(padding: EdgeInsets.all(10), child: Text('中')),
                  '高': Padding(padding: EdgeInsets.all(10), child: Text('高')),
                },
                groupValue: importance,
                onValueChanged: (value) {
                  setState(() {
                    importance = value;
                  });
                },
              ),
              Text("\n很急嗎？"),
              CupertinoSegmentedControl<String>(
                children: {
                  '低': Padding(padding: EdgeInsets.all(10), child: Text('低')),
                  '中': Padding(padding: EdgeInsets.all(10), child: Text('中')),
                  '高': Padding(padding: EdgeInsets.all(10), child: Text('高')),
                },
                groupValue: urgency,
                onValueChanged: (value) {
                  setState(() {
                    urgency = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text('完成'),
              onPressed: () async {
                await apiService.addNote(
                  descriptionController.text,
                  importance,
                  urgency,
                );
                fetchNotes();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void updateNoteDialog(String id, String currentDescription, String currentImportance, String currentUrgency) async {
    TextEditingController descriptionController = TextEditingController(text: currentDescription);
    String importance = currentImportance;
    String urgency = currentUrgency;

    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('項目詳情'),
          content: Column(
            children: [
              CupertinoTextField(controller: descriptionController, placeholder: '事項'),
              Text("\n重要嗎？"),
              CupertinoSegmentedControl<String>(
                children: {
                  '低': Padding(padding: EdgeInsets.all(10), child: Text('低')),
                  '中': Padding(padding: EdgeInsets.all(10), child: Text('中')),
                  '高': Padding(padding: EdgeInsets.all(10), child: Text('高')),
                },
                groupValue: importance,
                onValueChanged: (value) {
                  setState(() {
                    importance = value;
                  });
                },
              ),
              Text("\n很急嗎？"),
              CupertinoSegmentedControl<String>(
                children: {
                  '低': Padding(padding: EdgeInsets.all(10), child: Text('低')),
                  '中': Padding(padding: EdgeInsets.all(10), child: Text('中')),
                  '高': Padding(padding: EdgeInsets.all(10), child: Text('高')),
                },
                groupValue: urgency,
                onValueChanged: (value) {
                  setState(() {
                    urgency = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text('完成'),
              onPressed: () async {
                await apiService.updateNote(
                  id,
                  descriptionController.text,
                  importance,
                  urgency,
                );
                fetchNotes();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void deleteNoteDialog(String id) async {
    await apiService.deleteNote(id);
    fetchNotes();
  }

  void refreshNotes() {
    fetchNotes();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('待辦事項'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.refresh),
          onPressed: refreshNotes,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Text("滑動項目條來刪除"),
            Expanded(
              child: ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return Dismissible(
                    key: Key(note['id']),
                    onDismissed: (direction) {
                      deleteNoteDialog(note['id']);
                    },
                    child: CupertinoButton(
                      padding: EdgeInsets.all(0),
                      onPressed: () {
                        updateNoteDialog(note['id'], note['description'], note['importance'][0].split(':')[1], note['importance'][1].split(':')[1]);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        width: MediaQuery.of(context).size.width * 0.99,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note['description'],
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 5),
                            Text(
                              note['importance'][0]+"\t\t|\t\t"+note['importance'][1],
                              style: TextStyle(fontSize: 12, color: CupertinoColors.systemGrey),
                            ),
                            Text(
                              '最後修改: ${note['lastModified']}',
                              style: TextStyle(fontSize: 12, color: CupertinoColors.systemGrey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            CupertinoButton(
              child: Text('新增待辦事項'),
              onPressed: addNote,
            ),
          ],
        ),
      ),
    );
  }
}
