import 'package:xmpp_stone/src/Connection.dart';
import 'package:xmpp_stone/src/data/Jid.dart';
import 'package:xmpp_stone/src/elements/stanzas/AbstractStanza.dart';
import 'package:xmpp_stone/src/elements/stanzas/MessageStanza.dart';
import 'package:xmpp_stone/src/messages/MessageApi.dart';

class MessageHandler implements MessageApi {
  static Map<Connection, MessageHandler> instances =
      Map<Connection, MessageHandler>();

  Stream<MessageStanza> get messagesStream {
    return _connection.inStanzasStream
        .where((abstractStanza) => abstractStanza is MessageStanza)
        .map((stanza) => stanza as MessageStanza);
  }

  static getInstance(Connection connection) {
    MessageHandler manager = instances[connection];
    if (manager == null) {
      manager = MessageHandler(connection);
      instances[connection] = manager;
    }

    return manager;
  }

  Connection _connection;

  MessageHandler(Connection connection) {
    _connection = connection;
  }

  @override
  void sendMessage(Jid to, String text) {
    _sendTextMessage(to, text);
  }

  @override
  void sendMessageStanza(MessageStanza stanza) {
    _connection.writeStanza(stanza);
  }

  void _sendTextMessage(Jid jid, String text) {
    MessageStanza stanza =
        MessageStanza(MessageStanzaType.CHAT, id: AbstractStanza.getRandomId());
    stanza.toJid = jid;
    stanza.fromJid = _connection.fullJid;
    stanza.body = text;
    _connection.writeStanza(stanza);
  }
}
