from twisted.internet.protocol import Factory,Protocol
from twisted.internet import reactor
import argparse

class Chat(Protocol):

    def __init__(self, users):
        self.users = users
        self.name = None
        self.state = "GETNAME"

    def connectionMade(self):
        print("Connection made")
        self.transport.write('server:inf:name'.encode("utf8"))

    def makeConnection(self, transport):
        super().makeConnection(transport)

    def connectionLost(self, reason):
        if self.name in self.users:
            print(self.name + ' left the chat')
            del self.users[self.name]
            
            for name, protocol in self.users.items():
                if self != protocol:
                    message = "server:msg:%s left the chat." % self.name
                    protocol.transport.write(message.encode("utf8"))
        else:
            print('Somebody left the chat')

    def dataReceived(self, line):
        print("Data input")
        if self.state == "GETNAME":
            self.handle_get_name(line.decode())
        else:
            self.handle_chat(line.decode())

    def handle_get_name(self, name):
        if name.upper() == "SERVER" or name.upper() == "YOU":
            print("Not allowed username (%s)" % name)
            self.transport.write("server:inf:name".encode("utf8"))
            return
        for peerName, protocol in self.users.items():
            if name.upper() == peerName.upper():
                print("Username already taken (%s)" % name)
                self.transport.write("server:inf:name".encode("utf8"))
                return
        #if name in self.users:
            #print("Username already taken (%s)" % name)
            #self.transport.write("server:inf:name".encode("utf8"))
            #return
        print("New user signed up (%s)" % name)
        self.transport.write(("server:msg:Welcome, %s!" % (name)).encode("utf8"))
        self.name = name
        self.users[name] = self
        self.state = "CHAT"

        for name, protocol in self.users.items():
            if name != self.name:
                protocol.transport.write(("server:msg:%s joined." % self.name).encode("utf8"))

    def handle_chat(self, message):
        print("New message")
        m = message.split(":")
        if m[0] != self.name:
            return
        message = "%s:msg:%s" % (self.name, m[2])
        for name, protocol in self.users.items():
            if self != protocol:
                protocol.transport.write(message.encode("utf8"))


class ChatFactory(Factory):

    def __init__(self):
        self.users = {} # maps user names to Chat instances

    def buildProtocol(self, addr):
        return Chat(self.users)

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("-p", "--port", default=8000, type=int,
    help="Port to open server to")
    args = vars(ap.parse_args())
    reactor.listenTCP(args["port"], ChatFactory())
    reactor.run()


# this only runs if the module was *not* imported
if __name__ == '__main__':
    main()
