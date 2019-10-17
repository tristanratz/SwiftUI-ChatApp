//
//  Communication.swift
//  ClientApp
//
//  Created by Tristan Ratz on 22.09.19.
//  Copyright © 2019 Tristan Ratz. All rights reserved.
//

import Foundation

class Socket:NSObject, StreamDelegate {
    let port: Int
    let ip: String
    let textEncoding: String.Encoding

    let connectionTimeout: Double
    var connectionTimer: Timer?
    var inputStreamReady: Bool = false
    var outputStreamReady: Bool = false

    private var inputStream: InputStream!
    private var outputStream: OutputStream!
    private let maxReadLength = 4096

    private var buffer: [Data] = []

    var dataHandler: ((Data, String) -> Void)? // First argument data, second IP
    var stringHandler: ((String, String) -> Void)? // First argument data, second IP

    var connectionCallback: ((Bool) -> Void)?

    init(_ ip: String, _ port: Int, _ textEncoding: String.Encoding) {
        self.port = port
        self.ip = ip
        self.textEncoding = textEncoding
        self.connectionTimeout = 1.0
        
        super.init()
        
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, ip as CFString, UInt32(port),
                                           &readStream, &writeStream)
        
        self.inputStream = readStream!.takeRetainedValue()
        self.outputStream = writeStream!.takeRetainedValue()
        
        self.inputStream.delegate = self
        self.outputStream.delegate = self
        
        self.inputStream.schedule(in: .main, forMode: .default)
        self.outputStream.schedule(in: .main, forMode: .default)
        
        //self.inputStream.open() // deprecated
        //self.outputStream.open() // deprecated
        
        print("Establishing connection..!")
    }

    func connect() {
        self.inputStream.open()
        self.outputStream.open()
        
        print("Establishing connection...")
        
        self.connectionTimer = Timer.scheduledTimer(withTimeInterval: self.connectionTimeout, repeats: false) { _ in
            if !self.inputStreamReady || !self.outputStreamReady {
                print("Timeout \(self.connectionTimeout)s exeeded. Connection failed.")
                if self.connectionCallback != nil {
                    self.connectionCallback?(false)
                }
                self.destroySession()
            } else {
                print("Connection established.")
                if self.connectionCallback != nil {
                    self.connectionCallback?(true)
                }
            }
             self.connectionTimer?.invalidate()
             self.connectionTimer = nil
        }
    }

    func send(data: Data) -> Bool {
        if !outputStream.hasSpaceAvailable {
            print("Loading up buffer...")
            buffer.append(data)
            return false
        }
        
        print("Sending message...")
        _ = data.withUnsafeBytes {
            guard
                let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self)
                else {
                    print("Error sending message")
                    return
                }
            print("Message send: " + String(data: data, encoding: String.Encoding.utf8)!)
            outputStream.write(pointer, maxLength: data.count)
        }
        return true
    }

    func sendText(text: String) -> Bool {
        self.send(data: (text).data(using: textEncoding)!)
    }
    
    private func readAvailableBytes(stream: InputStream) {
      let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)
    
      while stream.hasBytesAvailable {
        let numberOfBytesRead = inputStream.read(buffer, maxLength: maxReadLength)
        
        if numberOfBytesRead < 0, let error = stream.streamError {
          print(error)
          break
        }

        if let (data, string) =
            processedMessageString(buffer: buffer, length: numberOfBytesRead) {
            print (string)
            if self.dataHandler != nil {
                self.dataHandler!(data, self.ip)
            }
            if self.stringHandler != nil {
                self.stringHandler!(string, self.ip)
            }
        }
      }
    }

    private func processedMessageString(buffer: UnsafeMutablePointer<UInt8>,
                                        length: Int) -> (Data, String)? {
        guard
            let string = String(
                bytesNoCopy: buffer,
                length: length,
                encoding: textEncoding,
                freeWhenDone: true)
            else {
                return nil
            }
        
        var bytes:[UInt8] = []
        for iterate in 0 ..< length {
            bytes.append(buffer[iterate])
        }
        // Convert to NSData
        let data = NSData(bytes: bytes, length: bytes.count)
      
        return (Data(data),string)
    }

    func destroySession() {
        inputStream.close()
        outputStream.close()
        
        self.inputStreamReady = false
        self.outputStreamReady = false
        self.buffer.removeAll(keepingCapacity: false)
        self.connectionTimer = nil
        
    }

    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
            case .hasBytesAvailable:
                readAvailableBytes(stream: aStream as! InputStream)
            case .endEncountered:
                destroySession()
            case .openCompleted:
                if aStream === inputStream {
                    print("inputStream opened.")
                    self.inputStreamReady = true
                } else {
                    print("outputStream opened.")
                    self.outputStreamReady = true
                }
            case .errorOccurred:
                print("inputStream: ErrorOccurred: \(aStream.streamError!.localizedDescription)")
            case .hasSpaceAvailable:
                print("Stream has space available")
                if !buffer.isEmpty {
                    send(data: self.buffer.removeFirst())
                }
            default:
                print("some other event...")
        }
    }
}
