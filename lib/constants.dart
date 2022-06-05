import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';


final String USERS_COLLECTION = 'USERS';
final String MESSAGES_COLLECTION="MESSAGES";
final String CHATS_COLLECTION="CHATS";
final String MEDIA_COLLECTION="MEDIA";

final String CHATS_MEDIA_STORAGE_REF = 'ChatsMedia';


enum MediaType {
  Photo,
  Video,
  Audio,
}

enum MessageType {
  Text,
  Media,
}

enum StatusType {
  Text,
  Media,
}



Color kBorderColor1 = Colors.white.withOpacity(0.1);
Color kBorderColor2 = Colors.white.withOpacity(0.07);
Color kBorderColor3 = Colors.white.withOpacity(0.2);
Color kBorderColor4 = Colors.white.withOpacity(0.2);
Color kBaseWhiteColor = Colors.white.withOpacity(0.87);

Color kBlackColor = Colors.black; //('#1C1C1E');
Color kBlackColor2 = HexColor('#121212');// getColorFromHex('#161616');
Color kBlackColor3 = HexColor('#1C1C1E');// getColorFromHex('#2C2C2E');

TextStyle kWhatsAppStyle = TextStyle(
  fontSize: 21,
  fontWeight: FontWeight.bold,
);

TextStyle kSelectedTabStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w500,
);

TextStyle kUnselectedTabStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w500,
);

TextStyle kChatItemTitleStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
);

TextStyle kChatItemSubtitleStyle = TextStyle(
  fontSize: 14,
  color: Colors.white.withOpacity(0.7),
);

TextStyle kAppBarTitleStyle = TextStyle(
  fontSize: 20,
  color: Colors.blue,
  fontWeight: FontWeight.w600,
);

TextStyle kChatBubbleTextStyle = TextStyle(
  fontSize: 17,
);

TextStyle kReplyTitleStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: HexColor('#FF0266'),
);

TextStyle kReplySubtitleStyle = TextStyle(
  fontSize: 14,
);

class ReplyColorPair {
  final Color user;
  final Color peer;
  ReplyColorPair({required this.user,required this.peer});
}

List<ReplyColorPair> replyColors = [
  ReplyColorPair(user: HexColor('#09af00'), peer: HexColor('#FF0266')),
  ReplyColorPair(user: HexColor('#C62828'), peer: HexColor('#d602ee')),
  ReplyColorPair(user: HexColor('#f47100'), peer: HexColor('#61d800')),
  ReplyColorPair(user: HexColor('#4E342E'), peer: HexColor('#BF360C')),

];

String anonPic = 'https://www.google.com/search?q=anonymous+person+image&sxsrf=ALiCzsY3DVM40zHgmSGBKGXVTXKW4tMmKw:1652695851530&tbm=isch&source=iu&ictx=1&vet=1&fir=eYg4IQZr3KmaaM%252CbzHV6TfD9Id4nM%252C_%253BsoD-YC4OEahyRM%252CbzHV6TfD9Id4nM%252C_%253Bz4_ymOoMunZsbM%252CanUwATO1smTapM%252C_%253BlXv3_jRY9qWheM%252CLYqMdcmEk0j6MM%252C_%253BUyoQHxgVqOPywM%252C3w6uUmgbrvm2vM%252C_%253BW5ECtoHqT02WgM%252CgChivy9fz_sDMM%252C_%253BXFg_D12xMEMPpM%252CUL7aOQ2jeJz-uM%252C_%253B4CfuXQtBf8N7-M%252CMo7bcw2Q6FkNNM%252C_%253BG3k6eF8BqsjVyM%252Cqo4yFMu1YLgylM%252C_%253B4Q3HOJrFExmu6M%252C20GtdAvLFVxpoM%252C_%253B9frOWkNutC7N4M%252C6lvEt-0ZsXpzjM%252C_%253BOdEbw13DLaVTdM%252CX7glGi8ceN4sYM%252C_%253B970qyCzTu1ZL8M%252Cf5rlP55YYsZnOM%252C_%253BP51rxfaM4xtAzM%252Ci7Acg_NDMQhUeM%252C_%253BHJyIw0EF35oLwM%252CUZfnywLpGYqsPM%252C_&usg=AI4_-kTBgAPdGUOUNHvWAtKkA_OX3HVYTA&sa=X&ved=2ahUKEwj1s5vp4-P3AhWj7rsIHaVOB_sQ9QF6BAgHEAE&biw=1366&bih=625&dpr=1#imgrc=970qyCzTu1ZL8M';