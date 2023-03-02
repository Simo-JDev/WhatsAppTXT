import 'package:bubble/bubble.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: WhatsAppUI(),
        backgroundColor: Color.fromRGBO(33, 44, 51, 1),
      ),
    );
  }
}

class WhatsAppUI extends StatefulWidget {
  const WhatsAppUI({Key? key}) : super(key: key);

  @override
  State<WhatsAppUI> createState() => _WhatsAppUIState();
}

final List<XFile> chatList = [];
bool _dragging = false;
int selectedIndex = 0;
List<List> chatData = List<List<dynamic>>.empty(growable: true);

const String ownerName = 'Simone Lauria';

class _WhatsAppUIState extends State<WhatsAppUI> {
  openFile(filepath) async {
    File f = File(filepath);
    final input = f.openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter(eol: '\n'))
        .toList();
    setState(() {
      chatData.add(fields);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragEntered: (detail) {
        setState(() {
          _dragging = true;
        });
      },
      onDragExited: (detail) {
        setState(() {
          _dragging = false;
        });
      },
      onDragDone: (detail) async {
        setState(() {
          chatList.addAll(detail.files);
        });
        for (final file in detail.files) {
          await openFile(file.path);
        }
        setState(() {
          _dragging = false;
        });
      },
      child: _dragging
          ? Container(
              color: const Color.fromRGBO(33, 44, 51, 1),
              width: double.infinity,
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.file_upload_outlined,
                    size: 50,
                    color: Color.fromRGBO(98, 112, 120, 1),
                  ),
                  Text(
                    '\n Drop .txt file here',
                    style: TextStyle(
                        color: Color.fromRGBO(98, 112, 120, 1), fontSize: 20),
                  ),
                ],
              ),
            )
          : Row(
              children: [
                Flexible(
                  flex: 2,
                  child: Column(
                    children: [
                      Container(
                        color: const Color.fromRGBO(33, 44, 51, 1),
                        width: double.infinity,
                        height: 58,
                      ),
                      Container(
                        color: const Color.fromRGBO(16, 27, 33, 1),
                        width: double.infinity,
                        height: 49,
                        child: FractionallySizedBox(
                          widthFactor: 0.85,
                          heightFactor: 0.7,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color.fromRGBO(33, 44, 51, 1),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                SizedBox(
                                    width: 60,
                                    child: Icon(
                                      Icons.search,
                                      color: Color.fromRGBO(98, 112, 120, 1),
                                    )),
                                Expanded(
                                  child: TextField(
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Color.fromRGBO(98, 112, 120, 1)),
                                    cursorColor: Colors.white70,
                                    cursorWidth: 1,
                                    decoration: InputDecoration.collapsed(
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.never,
                                        hintText: 'Search',
                                        hintStyle: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            color: Color.fromRGBO(
                                                98, 112, 120, 1))),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                          child: ListView.builder(
                        controller: ScrollController(),
                        itemCount: chatList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndex = index;
                              });
                            },
                            child: BaseChatPreview(
                                chatName: chatName(chatList[index])),
                          );
                        },
                      ))
                    ],
                  ),
                ),
                Flexible(
                    flex: 3,
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/bg_dark.png'),
                              fit: BoxFit.cover)),
                      child: Column(
                        children: [
                          if (chatData.isNotEmpty)
                            Flexible(
                                child: ListView.builder(
                              itemCount: chatData[selectedIndex].length,
                              itemBuilder: (context, index) {
                                // Check the previous message to check if need to print date, time
                                String preAuthor = '';
                                String preDate = '';
                                if (index > 0) {
                                  // Message string, has [] around
                                  final preMsgStr = chatData[selectedIndex]
                                          [index - 1]
                                      .toString();
                                  // Message raw (contains date - time - sender - text)
                                  final preMessageRaw = preMsgStr.substring(
                                      1, preMsgStr.length - 1);
                                  preDate = msgDate(preMessageRaw);
                                  preAuthor = msgSender(preMessageRaw);
                                }
                                // Message string, has [] around
                                final messageStr =
                                    chatData[selectedIndex][index].toString();
                                // Message raw (contains date - time - sender - text)
                                final messageRaw = messageStr.substring(
                                    1, messageStr.length - 1);
                                final date = msgDate(messageRaw);
                                final sender = msgSender(messageRaw);
                                final text = msgText(messageRaw);
                                return SizedBox(
                                  width: double.infinity,
                                  child: isOwnersMsg(messageRaw)
                                      ? OutText(
                                          text: text,
                                          isSameSender: sender == preAuthor,
                                        )
                                      : InText(
                                          text: text,
                                          author: sender,
                                          isSameSender: sender == preAuthor,
                                        ),
                                );
                              },
                            )),
                        ],
                      ),
                    ))
              ],
            ),
    );
  }

// Is the message by the owner?
  bool isOwnersMsg(String messageRaw) {
    final message = raw2Msg(messageRaw);
    return message.startsWith('$ownerName: ');
  }

// Get msg from raw
  String raw2Msg(String messageRaw) {
    final String message;
    if (messageRaw
        .startsWith(RegExp(r'[0-9][0-9]\/[0-9][0-9]\/[0-9][0-9][0-9][0-9]'))) {
      message = messageRaw.substring(21, messageRaw.length);
    } else if (messageRaw.startsWith(RegExp(r'[0-9]. '))) {
      message = messageRaw.substring(3, messageRaw.length);
    } else {
      message = messageRaw;
    }
    return message;
  }

// Get text of the message
  String msgText(String messageRaw) {
    final message = raw2Msg(messageRaw);
    final String prefix = message.split(':')[0];
    final text = message.replaceAll('$prefix: ', '');
    return text;
  }

// Get sender of the message
  String msgSender(String messageRaw) {
    final message = raw2Msg(messageRaw);
    final String sender = message.split(':')[0];
    return sender;
  }

// Get time of the message
  String msgTime(String messageRaw) {
    if (messageRaw
        .startsWith(RegExp(r'[0-9][0-9]\/[0-9][0-9]\/[0-9][0-9][0-9][0-9]'))) {
      final time = messageRaw.split(' - ')[0].split(', ').last;
      return time;
    } else {
      return '';
    }
  }

// Get date of message
  String msgDate(String messageRaw) {
    if (messageRaw
        .startsWith(RegExp(r'[0-9][0-9]\/[0-9][0-9]\/[0-9][0-9][0-9][0-9]'))) {
      final time = messageRaw.split(', ').first;
      return time;
    } else {
      return '';
    }
  }

  // Get chat name
  String chatName(XFile fileName) {
    return fileName.path
        .split('/')
        .last
        .replaceAll('WhatsApp Chat with ', '')
        .replaceAll('.txt', '');
  }
}

// Chat preview widget
class BaseChatPreview extends StatelessWidget {
  final String chatName;
  const BaseChatPreview({Key? key, required this.chatName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(16, 27, 33, 1),
      width: double.infinity,
      height: 71,
      child: Padding(
        padding: const EdgeInsets.only(left: 13, right: 13),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: const Color.fromRGBO(107, 112, 117, 1),
              ),
              child: const Icon(
                Icons.person,
                color: Color.fromRGBO(207, 212, 214, 1),
                size: 40,
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Container(
                  decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              width: 1, color: Color.fromRGBO(37, 46, 53, 1)))),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      chatName,
                      style: const TextStyle(
                          color: Color.fromRGBO(232, 237, 239, 1),
                          fontSize: 15),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class InText extends StatelessWidget {
  final String text;
  final String author;
  final bool isSameSender;

  const InText(
      {Key? key,
      required this.text,
      required this.author,
      required this.isSameSender})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 70),
      child: Column(
        children: [
          if (!isSameSender)
            const SizedBox(
              height: 12,
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 1, 8, 1),
            child: Bubble(
              alignment: Alignment.topLeft,
              nip: BubbleNip.leftTop,
              showNip: !isSameSender,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              
                if (!isSameSender)
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 6, 0, 6),
                  child: Text(author, textAlign: TextAlign.left, style: const TextStyle(fontWeight: FontWeight.w600),),
                ),
                 Text(text)
                ]),
            ),
          ),
        ],
      ),
    );
  }
}

class OutText extends StatelessWidget {
  final String text;
  final bool isSameSender;

  const OutText({Key? key, required this.text, required this.isSameSender})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 70),
      child: Column(
        children: [
          if (!isSameSender)
            const SizedBox(
              height: 12,
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 1, 8, 1),
            child: Bubble(
              color: const Color.fromRGBO(225, 255, 199, 1.0),
              alignment: Alignment.topRight,
              nip: BubbleNip.rightTop,
              showNip: !isSameSender,
              child: Column(children: [Text(text)]),
            ),
          ),
        ],
      ),
    );
  }
}
