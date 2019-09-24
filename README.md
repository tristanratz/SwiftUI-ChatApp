#  ClientApp

## Server

Before you start a client it is mandatory to start the server.
Make sure python 3.6+ is installed.

```
pip install -r requirements.txt
```

After that you can already install the server. If you want to you can adjust the port the server will be hosted on in the main.py
Starting the server is also very simple:

```python
python main.py
```

That's it.

## Client
The client was tested in XCode Beta 6
It is currently working best on iPhones. You can just open the project in Xcode and run it.

## Other platforms and clients

If you want to implement a matching client just pull and try to connect to the server. After that you need to implement the protocol

### Message protocol
The protocol for sending and receiving messages is very simple. All informations are seperated by a colon: SENDER:TYPE OF MESSAGE:ACTUAL MESSAGE
At the moment the message type is whether "inf" for making a request and sending "information" (it is only used by the sever) or "msg" for sending a message. msg can be used by all parties.

After connecting the sever request you to send a name and will make the next mesage your name.

__Server:__
```
server:inf:name
```
When you send a String back and it is not taken yet, it will take it as your name. Otherwise it will send the same message again (and again)

After that you are free to send messages and receive messages in the following format.

```
YOUR_NAME:msg:YOUR_MESSAGE
```
