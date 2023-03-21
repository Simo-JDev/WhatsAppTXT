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
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
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

ItemScrollController _scrollController = ItemScrollController();

// List of files
final List<XFile> chatList = [];
// Is dragging?
bool _dragging = false;
// Index of the selected chat
int selectedIndex = 0;
// List of the csv of the chats
List<List> chatData = List<List<dynamic>>.empty(growable: true);
// Main search controller
final searchController = TextEditingController();
// Main search query
String mainSearchQuery = '';
// Owner of the messages (controller)
final ownerNameController = TextEditingController();
// Owner name string
String ownerName = '';
// Owner name field
bool ownerNameLocked = false;
// List of chat names, also used to check if the chat is a group chat
List<List> senderNames = List<List<dynamic>>.empty(growable: true);
// List of colors
List<Color> senderColors = [
  const Color.fromRGBO(226, 106, 182, 1),
  const Color.fromRGBO(80, 181, 224, 1),
  const Color.fromRGBO(34, 211, 102, 1),
  const Color.fromRGBO(2, 206, 155, 1),
  const Color.fromRGBO(167, 145, 255, 1),
  const Color.fromRGBO(252, 151, 117, 1),
  const Color.fromRGBO(255, 188, 55, 1),
  const Color.fromRGBO(65, 199, 184, 1),
  const Color.fromRGBO(165, 179, 55, 1),
  const Color.fromRGBO(226, 106, 182, 1),
  const Color.fromRGBO(80, 181, 224, 1),
  const Color.fromRGBO(34, 211, 102, 1),
  const Color.fromRGBO(2, 206, 155, 1),
  const Color.fromRGBO(167, 145, 255, 1),
  const Color.fromRGBO(252, 151, 117, 1),
  const Color.fromRGBO(255, 188, 55, 1),
  const Color.fromRGBO(65, 199, 184, 1),
  const Color.fromRGBO(165, 179, 55, 1)
];

// Track the requested index
// int requestedIndex = 0;
// // Change the color for hihglighting search results
// Color highlightColor = Colors.transparent;

class _WhatsAppUIState extends State<WhatsAppUI> {
  openFile(filepath) async {
    File f = File(filepath);
    final input = f.openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter(eol: '\n'))
        .toList();
    setState(() {
      // Remove empty lines that are complicated for rendering
      chatData.add(fields
          .where((element) => element.toString() != '[]')
          .toList()
          .reversed
          .toList());
      senderNames.add(groupNames(fields));
    });
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
    ownerNameController.dispose();
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
      child: (_dragging || chatList.isEmpty)
          ? Container(
              color: const Color.fromRGBO(33, 44, 51, 1),
              width: double.infinity,
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.file_upload_outlined,
                    size: 50,
                    color: _dragging
                        ? const Color.fromRGBO(0, 92, 75, 1.0)
                        : const Color.fromRGBO(98, 112, 120, 1),
                  ),
                  const Text(
                    '\n Drop your .txt WhatsApp chats files here',
                    style: TextStyle(
                        color: Color.fromRGBO(98, 112, 120, 1), fontSize: 20),
                  ),
                ],
              ),
            )
          : (chatList.length != chatData.length)
              ? Container(
                  color: const Color.fromRGBO(33, 44, 51, 1),
                  width: double.infinity,
                  height: double.infinity,
                  child: const Center(
                      child: CircularProgressIndicator(
                    color: Color.fromRGBO(0, 92, 75, 1.0),
                  )))
              : Container(
                  color: const Color.fromRGBO(16, 27, 33, 1),
                  child: Row(
                    children: [
                      Flexible(
                        flex: 2,
                        child: Container(
                          decoration: const BoxDecoration(
                              border: Border(
                                  right: BorderSide(
                                      width: 1,
                                      color: Color.fromRGBO(68, 84, 97, 0.7)))),
                          child: Column(
                            children: [
                              Container(
                                color: const Color.fromRGBO(33, 44, 51, 1),
                                width: double.infinity,
                                height: 58,
                                child: Padding(
                                  padding: (defaultTargetPlatform ==
                                          TargetPlatform.macOS)
                                      ? const EdgeInsets.only(left: 70)
                                      : const EdgeInsets.all(0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            ownerName =
                                                ownerNameController.text;
                                            ownerNameLocked = !ownerNameLocked;
                                          });
                                        },
                                        child: SizedBox(
                                            width: 60,
                                            child: !ownerNameLocked
                                                ? const Icon(
                                                    Icons.lock_open_rounded,
                                                    color: Color.fromRGBO(
                                                        98, 112, 120, 1),
                                                  )
                                                : const Icon(
                                                    Icons.lock_outline_rounded,
                                                    color: Color.fromRGBO(
                                                        98, 112, 120, 1),
                                                  )),
                                      ),
                                      Expanded(
                                        child: ownerNameLocked
                                            ? Text(
                                                ownerName,
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              )
                                            : TextField(
                                                controller: ownerNameController,
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.white70),
                                                cursorColor: Colors.white70,
                                                cursorWidth: 1,
                                                decoration: const InputDecoration
                                                        .collapsed(
                                                    floatingLabelBehavior:
                                                        FloatingLabelBehavior
                                                            .never,
                                                    hintText:
                                                        'Type your name as saved on the .txt',
                                                    hintStyle: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        color: Color.fromRGBO(
                                                            98, 112, 120, 1))),
                                              ),
                                      )
                                    ],
                                  ),
                                ),
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
                                      color:
                                          const Color.fromRGBO(33, 44, 51, 1),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                            width: 60,
                                            child: Icon(
                                              Icons.search,
                                              color: Color.fromRGBO(
                                                  98, 112, 120, 1),
                                            )),
                                        Expanded(
                                          child: TextField(
                                            controller: searchController,
                                            onChanged: (value) {
                                              setState(() {
                                                mainSearchQuery =
                                                    searchController.text;
                                              });
                                            },
                                            style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.white70),
                                            cursorColor: Colors.white70,
                                            cursorWidth: 1,
                                            decoration:
                                                const InputDecoration.collapsed(
                                                    floatingLabelBehavior:
                                                        FloatingLabelBehavior
                                                            .never,
                                                    hintText: 'Search',
                                                    hintStyle: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w300,
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
                                      // if (mainSearchQuery.isNotEmpty)
                                      // {requestedIndex = chatData[selectedIndex].indexWhere(
                                      //             (element) => element
                                      //                 .toString()
                                      //                 .toLowerCase()
                                      //                 .contains(mainSearchQuery
                                      //                     .toLowerCase()));}
                                      // When click, go to the selected
                                      _scrollController.jumpTo(
                                          index: mainSearchQuery.isEmpty
                                              ? 0
                                              : chatData[index].indexWhere(
                                                  (element) => element
                                                      .toString()
                                                      .toLowerCase()
                                                      .contains(mainSearchQuery
                                                          .toLowerCase())));
                                      // setState(() {
                                      //   highlightColor = Colors.white;
                                      //   sleep(Duration(milliseconds: 500));
                                      //   highlightColor = Colors.transparent;
                                      // });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: (chatData[index].indexWhere((element) => element
                                                  .toString()
                                                  .toLowerCase()
                                                  .contains(mainSearchQuery
                                                      .toLowerCase())) !=
                                              -1)
                                          ? BaseChatPreview(
                                              selected: selectedIndex == index,
                                              group:
                                                  senderNames[index].length > 2,
                                              chatName:
                                                  chatName(chatList[index]),
                                              indexOfChat: index,
                                              highlighted: mainSearchQuery,
                                              indexOfMessage: mainSearchQuery.isEmpty
                                                  ? 0
                                                  : chatData[index].indexWhere((element) => element
                                                      .toString()
                                                      .toLowerCase()
                                                      .contains(mainSearchQuery.toLowerCase())))
                                          : Container(),
                                    ),
                                  );
                                },
                              ))
                            ],
                          ),
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
                                Container(
                                  color: const Color.fromRGBO(33, 44, 51, 1),
                                  width: double.infinity,
                                  height: 58,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(15, 0, 15, 0),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            color: const Color.fromRGBO(
                                                107, 112, 117, 1),
                                          ),
                                          child: senderNames[selectedIndex]
                                                      .length >
                                                  2
                                              ? const Icon(
                                                  Icons.group,
                                                  color: Color.fromRGBO(
                                                      207, 212, 214, 1),
                                                  size: 30,
                                                )
                                              : const Icon(
                                                  Icons.person,
                                                  color: Color.fromRGBO(
                                                      207, 212, 214, 1),
                                                  size: 30,
                                                ),
                                        ),
                                        Flexible(
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 15),
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                  border: Border(
                                                      bottom: BorderSide(
                                                          width: 1,
                                                          color: Color.fromRGBO(
                                                              37, 46, 53, 1)))),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  chatName(
                                                      chatList[selectedIndex]),
                                                  style: const TextStyle(
                                                      color: Color.fromRGBO(
                                                          232, 237, 239, 1),
                                                      fontSize: 15),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // GestureDetector(
                                        //   onTap: () {
                                        //     _scrollController.scrollTo(
                                        //         index: 10,
                                        //         duration: const Duration(
                                        //             milliseconds: 200),
                                        //         curve: Curves.easeInOutCubic);
                                        //   },
                                        //   child: const Icon(
                                        //     Icons.search,
                                        //     color:
                                        //         Color.fromRGBO(98, 112, 120, 1),
                                        //   ),
                                        // )
                                      ],
                                    ),
                                  ),
                                ),
                                Flexible(
                                    child: ScrollablePositionedList.builder(
                                  reverse: true,
                                  itemScrollController: _scrollController,
                                  itemCount: chatData[selectedIndex].length,
                                  itemBuilder: (context, index) {
                                    // Message string, has [] around
                                    final messageStr = chatData[selectedIndex]
                                            [index]
                                        .toString();

                                    // Check the previous message to check if need to print date, time
                                    String preAuthor = '';
                                    String preDate = '';
                                    if (index <
                                        chatData[selectedIndex].length - 1) {
                                      // Message string, has [] around
                                      final preMsgStr = chatData[selectedIndex]
                                              [index + 1]
                                          .toString();
                                      // Message raw (contains date - time - sender - text)
                                      final preMessageRaw = preMsgStr.substring(
                                          1, preMsgStr.length - 1);
                                      preDate = msgDate(preMessageRaw);
                                      preAuthor = msgSender(preMessageRaw);
                                    }

                                    // Message raw (contains date - time - sender - text)
                                    final messageRaw = messageStr.substring(
                                        1, messageStr.length - 1);
                                    final date = msgDate(messageRaw);
                                    final time = msgTime(messageRaw);
                                    var sender = msgSender(messageRaw);
                                    final text = msgText(messageRaw);
                                    final isEncrypt = encrypt(messageRaw);
                                    final isAlert = alert(messageRaw);
                                    final isGroup =
                                        senderNames[selectedIndex].length > 2;
                                    var isOwner = isOwnersMsg(messageRaw);
                                    if (newLine(messageRaw)) {
                                      sender = preAuthor;
                                      if (preAuthor == ownerName) {
                                        isOwner = true;
                                      }
                                    }
                                    
                                    
                                    return Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          40, 0, 40, 0),
                                      width: double.infinity,
                                      child: Column(
                                        children: [
                                          if (date != preDate &&
                                              !newLine(messageRaw))
                                            GeneralAlert(text: date),
                                          if (isEncrypt)
                                            EncryptAlert(text: text),
                                          if (isAlert) GeneralAlert(text: text),
                                          if (!isEncrypt && !isAlert)
                                            isOwner
                                                ? OutText(
                                                    text: text,
                                                    isSameSender:
                                                        sender == preAuthor,
                                                    time: time,
                                                  )
                                                : isGroup
                                                    ? InGroupText(
                                                        text: text,
                                                        author: isGroup
                                                            ? sender
                                                            : '',
                                                        isSameSender:
                                                            sender == preAuthor,
                                                        time: time,
                                                        color: senderColors[
                                                            senderNames[
                                                                    selectedIndex]
                                                                .indexOf(
                                                                    sender)],
                                                      )
                                                    : InText(
                                                        text: text,
                                                        author: isGroup
                                                            ? sender
                                                            : '',
                                                        isSameSender:
                                                            sender == preAuthor,
                                                        time: time,
                                                      ),
                                          if (index == 0)
                                            Container(
                                              height: 20,
                                            )
                                        ],
                                      ),
                                    );
                                  },
                                )),
                                Container(
                                  height: 5,
                                ),
                              ],
                            ),
                          ))
                    ],
                  ),
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
    return p
        .split(fileName.path)
        .last
        .replaceAll('WhatsApp Chat with ', '')
        .replaceAll('.txt', '');
  }

// Is it an encryption alert?
  bool encrypt(String messageRaw) {
    return messageRaw.contains('Messages and calls are end-to-end encrypted');
  }

// Is it a general alert?
  bool alert(String messageRaw) {
    final String author = msgSender(messageRaw);
    final String text = msgText(messageRaw);

    if (author == text) {
      if (text.contains('created group') ||
          text.contains('changed') ||
          text.contains('added') ||
          text.contains('left')) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

// Is the message a link?
  bool link(String messageRaw) {
    final message = raw2Msg(messageRaw);
    if (message.startsWith('http')) {
      return true;
    } else {
      return false;
    }
  }

// Is it a new line of the same message
  bool newLine(messageRaw) {
    return msgDate(messageRaw) == '';
  }

// Is it a group chat?
  bool group(chat) {
    int index = 0;
    List<String> senders = [];

    while (senders.length < 3 && index < chat.length) {
      // Message string, has [] around
      final messageStr = chat[index].toString();
      // Message raw (contains date - time - sender - text)
      final messageRaw = messageStr.substring(1, messageStr.length - 1);
      final sender = msgSender(messageRaw);
      final isEncrypt = encrypt(messageRaw);
      final isAlert = alert(messageRaw);
      final isLink = link(messageRaw);
      final date = msgDate(messageRaw);
      if (!isEncrypt && !isAlert && !senders.contains(sender) && date != '') {
        senders.add(sender);
      }
      index += 1;
    }
    if (senders.length < 3) {
      return false;
    } else {
      return true;
    }
  }

// Get the group size
  List<String> groupNames(chat) {
    int index = 0;
    List<String> senders = [];
    while (index < chat.length) {
      // Message string, has [] around
      final messageStr = chat[index].toString();
      // Message raw (contains date - time - sender - text)
      final messageRaw = messageStr.substring(1, messageStr.length - 1);
      final sender = msgSender(messageRaw);
      final isEncrypt = encrypt(messageRaw);
      final isAlert = alert(messageRaw);
      final date = msgDate(messageRaw);
      if (!isEncrypt && !isAlert && !senders.contains(sender) && date != '') {
        senders.add(sender);
      }
      index += 1;
    }
    return senders;
  }
}

// Base widget
// Chat preview widget
class BaseChatPreview extends StatelessWidget {
  final String chatName;
  final bool selected;
  final bool group;
  final int indexOfChat;
  final int indexOfMessage;
  final String highlighted;
  const BaseChatPreview(
      {Key? key,
      required this.chatName,
      required this.selected,
      required this.group,
      required this.indexOfChat,
      required this.indexOfMessage,
      required this.highlighted})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: selected
          ? const Color.fromRGBO(41, 57, 66, 1)
          : const Color.fromRGBO(16, 27, 33, 1),
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
              child: group
                  ? const Icon(
                      Icons.group,
                      color: Color.fromRGBO(207, 212, 214, 1),
                      size: 40,
                    )
                  : const Icon(
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chatName,
                          style: const TextStyle(
                              color: Color.fromRGBO(232, 237, 239, 1),
                              fontSize: 16),
                        ),
                        Directionality(
                            textDirection: TextDirection.ltr,
                            child: SubstringHighlight(
                              overflow: TextOverflow.ellipsis,
                              text: group
                                  ? chatData[indexOfChat][indexOfMessage]
                                      .toString()
                                      .replaceFirst('[', '')
                                      .replaceAll(']', '')
                                      .split(' - ')
                                      .last
                                  : chatData[indexOfChat][indexOfMessage]
                                      .toString()
                                      .replaceFirst('[', '')
                                      .replaceAll(']', '')
                                      .split(': ')
                                      .last,
                              term: highlighted,
                              textStyle: const TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  color: Color.fromRGBO(134, 150, 160, 1),
                                  fontSize: 14),
                              textStyleHighlight: const TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  color: Color.fromRGBO(0, 168, 132, 1.0),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            )),
                        // Text(
                        //   group
                        //       ? chatData[indexOfChat][indexOfMessage]
                        //           .toString()
                        //           .replaceFirst('[', '')
                        //           .replaceAll(']', '')
                        //           .split(' - ')
                        //           .last
                        //       : chatData[indexOfChat][indexOfMessage]
                        //           .toString()
                        //           .replaceFirst('[', '')
                        //           .replaceAll(']', '')
                        //           .split(': ')
                        //           .last,
                        //   style: const TextStyle(
                        //       overflow: TextOverflow.ellipsis,
                        //       color: Color.fromRGBO(134, 150, 160, 1),
                        //       fontSize: 14),
                        // ),
                      ],
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

// Alert widget also used for day
class GeneralAlert extends StatelessWidget {
  final String text;
  const GeneralAlert({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Bubble(
        alignment: Alignment.center,
        color: const Color.fromRGBO(24, 34, 41, 1),
        child: Text(text,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 12.0, color: Color.fromRGBO(133, 149, 159, 1))),
      ),
    );
  }
}

// Encryption alert widget
class EncryptAlert extends StatelessWidget {
  final String text;
  const EncryptAlert({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(15.0),
        child: Bubble(
          alignment: Alignment.center,
          color: const Color.fromRGBO(24, 34, 41, 1),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                const WidgetSpan(
                  child: Padding(
                    padding: EdgeInsets.all(2.0),
                    child: Icon(
                      Icons.lock,
                      size: 12,
                      color: Color.fromRGBO(255, 210, 120, 1),
                    ),
                  ),
                ),
                TextSpan(
                    text: text,
                    style: const TextStyle(
                        height: 2,
                        fontSize: 12.0,
                        color: Color.fromRGBO(255, 210, 120, 1))),
              ],
            ),
          ),
        ));
  }
}

// Outgoing message widget
class OutText extends StatelessWidget {
  final String text;
  final bool isSameSender;
  final String time;

  const OutText(
      {Key? key,
      required this.text,
      required this.isSameSender,
      required this.time})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0),
      child: Column(
        children: [
          if (!isSameSender)
            const SizedBox(
              height: 12,
            ),
          Container(
            // Color for search animation
            // color: const Color.fromRGBO(255, 255, 255, 0.2),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 1, 8, 1),
              child: Bubble(
                color: const Color.fromRGBO(0, 92, 75, 1.0),
                alignment: Alignment.topRight,
                nip: BubbleNip.rightTop,
                showNip: !isSameSender,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        text,
                        style: const TextStyle(
                            color: Color.fromRGBO(232, 237, 239, 1)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          time,
                          style: const TextStyle(
                              fontSize: 11,
                              color: Color.fromRGBO(169, 173, 176, 1)),
                        ),
                      )
                    ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Group incoming message widget
class InGroupText extends StatelessWidget {
  final String text;
  final String author;
  final bool isSameSender;
  final String time;
  final Color color;

  const InGroupText(
      {Key? key,
      required this.text,
      required this.author,
      required this.isSameSender,
      required this.time,
      required this.color})
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
              color: const Color.fromRGBO(33, 44, 51, 1),
              alignment: Alignment.topLeft,
              nip: BubbleNip.leftTop,
              showNip: !isSameSender,
              child: Stack(
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isSameSender)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 6, 0, 6),
                            child: Text(
                              author,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, color: color),
                            ),
                          ),
                        Text(
                          text,
                          style: const TextStyle(
                              color: Color.fromRGBO(232, 237, 239, 1)),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        time,
                        style: const TextStyle(
                            fontSize: 11,
                            color: Color.fromRGBO(169, 173, 176, 1)),
                      ),
                    )
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Incoming message widget
class InText extends StatelessWidget {
  final String text;
  final String author;
  final bool isSameSender;
  final String time;

  const InText(
      {Key? key,
      required this.text,
      required this.author,
      required this.isSameSender,
      required this.time})
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
              color: const Color.fromRGBO(33, 44, 51, 1),
              alignment: Alignment.topLeft,
              nip: BubbleNip.leftTop,
              showNip: !isSameSender,
              child: Stack(
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(
                      text,
                      style: const TextStyle(
                          color: Color.fromRGBO(232, 237, 239, 1)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        time,
                        style: const TextStyle(
                            fontSize: 11,
                            color: Color.fromRGBO(169, 173, 176, 1)),
                      ),
                    )
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
