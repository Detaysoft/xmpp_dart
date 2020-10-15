import 'package:xml/xml.dart' as xml;
import 'package:xmpp_stone/src/data/Jid.dart';
import 'package:xmpp_stone/src/elements/XmppElement.dart';
import 'package:xmpp_stone/src/elements/XmppAttribute.dart';
import 'package:xmpp_stone/src/elements/stanzas/AbstractStanza.dart';
import 'package:xmpp_stone/src/elements/stanzas/IqStanza.dart';
import 'package:xmpp_stone/src/elements/stanzas/MessageStanza.dart';
import 'package:xmpp_stone/src/elements/stanzas/PresenceStanza.dart';
import 'package:xmpp_stone/src/features/servicediscovery/Feature.dart';
import 'package:xmpp_stone/src/features/servicediscovery/Identity.dart';

class StanzaParser {
  static AbstractStanza parseStanza(xml.XmlElement element) {
    //print("parsing stanza: ${element.toXmlString(pretty: true)}");
    AbstractStanza stanza;
    String id = element.getAttribute('id');
    if (id == null) {
      print("No id found for stanza");
    }
    if (element.name.local == 'iq') {
      stanza = _parseIqStanza(id, element);
    } else if (element.name.local == 'message') {
      stanza = _parseMessageStanza(id, element);
    } else if (element.name.local == 'presence') {
      stanza = _parsePresenceStanza(id, element);
    }
    String fromString = element.getAttribute('from');
    if (fromString != null) {
      Jid from = Jid.fromFullJid(fromString);
      stanza.fromJid = from;
    }
    String toString = element.getAttribute('to');
    if (toString != null) {
      Jid to = Jid.fromFullJid(toString);
      stanza.toJid = to;
    }
    element.attributes.forEach((xmlAtribute) {
      stanza.addAttribute(
          XmppAttribute(xmlAtribute.name.local, xmlAtribute.value));
    });
    ;
    element.children.forEach((child) {
      if (child is xml.XmlElement) stanza.addChild(parseElement(child));
    });
    //print("parsed as stanza: ${stanza.buildXmlString()}");
    return stanza;
  }

  static IqStanza _parseIqStanza(String id, xml.XmlElement element) {
    String typeString = element.getAttribute('type');
    IqStanzaType type;
    if (typeString == null) {
      print("No id found for iq stanza");
    } else {
      switch (typeString) {
        case 'error':
          type = IqStanzaType.ERROR;
          break;
        case 'set':
          type = IqStanzaType.SET;
          break;
        case 'result':
          type = IqStanzaType.RESULT;
          break;
        case 'get':
          type = IqStanzaType.GET;
          break;
        case 'invalid':
          type = IqStanzaType.INVALID;
          break;
        case 'timeout':
          type = IqStanzaType.TIMEOUT;
          break;
      }
    }
    return IqStanza(id, type);
  }

  static MessageStanza _parseMessageStanza(String id, xml.XmlElement element) {
    String typeString = element.getAttribute('type');
    MessageStanzaType type;
    if (typeString == null) {
      print("No id found for iq stanza");
    } else {
      switch (typeString) {
        case 'chat':
          type = MessageStanzaType.CHAT;
          break;
        case 'error':
          type = MessageStanzaType.ERROR;
          break;
        case 'groupchat':
          type = MessageStanzaType.GROUPCHAT;
          break;
        case 'headline':
          type = MessageStanzaType.HEADLINE;
          break;
        case 'normal':
          type = MessageStanzaType.NORMAL;
          break;
      }
    }
    MessageStanza stanza = MessageStanza(type, id: id);

    return stanza;
  }

  static PresenceStanza _parsePresenceStanza(
      String id, xml.XmlElement element) {
    PresenceStanza presenceStanza = PresenceStanza();
    presenceStanza.id = id;
    return presenceStanza;
  }

  static XmppElement parseElement(xml.XmlElement xmlElement) {
    XmppElement xmppElement;
    String parentName =
        (xmlElement.parent as xml.XmlElement)?.name?.local ?? "";
    String name = xmlElement.name.local;
    if (parentName == 'query' && name == 'identity') {
      xmppElement = Identity();
    } else if (parentName == 'query' && name == 'feature') {
      xmppElement = Feature();
    } else {
      xmppElement = XmppElement();
    }
    xmppElement.name = xmlElement.name.local;
    xmlElement.attributes.forEach((xmlAtribute) {
      xmppElement.addAttribute(
          XmppAttribute(xmlAtribute.name.local, xmlAtribute.value));
    });
    xmlElement.children.forEach((xmlChild) {
      if (xmlChild is xml.XmlElement) {
        xmppElement.addChild(parseElement(xmlChild));
      } else if (xmlChild is xml.XmlText) {
        xmppElement.textValue = xmlChild.text;
      }
    });
    return xmppElement;
  }
}
