//
//  Communication.swift
//  ClientApp
//
//  Created by Tristan Ratz on 22.09.19.
//  Copyright © 2019 Tristan Ratz. All rights reserved.
//

import Foundation

class Socket:NSObject {
    let port:Int
    let ip:String
    let textEncoding:String.Encoding
    
    var inputStream: InputStream!
    var outputStream: OutputStream!
    
    let maxReadLength = 4096
    
    private var dataHandler:((Data,String) -> Void)?
    private var stringHandler:((String,String) -> Void)?
    
    init(_ ip:String, _ port:Int, _ textEncoding:String.Encoding) {
        self.port = port
        self.ip = ip
        self.textEncoding = textEncoding
        
        super.init()
        
        var writeStream: Unmanaged<CFWriteStream>?
        var readStream: Unmanaged<CFReadStream>?
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, ip as CFString, UInt32(port),
                                           &readStream, &writeStream)
        
        self.inputStream = readStream!.takeRetainedValue()
        self.outputStream = writeStream!.takeRetainedValue()
        
        self.inputStream.delegate = self
        
        self.inputStream.schedule(in: .current, forMode: .common)
        self.outputStream.schedule(in: .current, forMode: .common)
        
        self.inputStream.open()
        self.outputStream.open()
        
        print("Establishing connection..!")
    }
    
    func send(data:Data) -> Bool {
        _ = data.withUnsafeBytes {
            guard
                let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self)
                else {
                    print("Error joining chat")
                    return
                }
          outputStream.write(pointer, maxLength: data.count)
        }
        return true
    }
    
    func sendText(text:String) -> Bool {
        self.send(data: text.data(using: textEncoding)!)
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
        for i in 0..<length {
            bytes.append(buffer[i])
        }
        // Convert to NSData
        let data = NSData(bytes: bytes, length: bytes.count)
      
        return (Data(data),string)
    }
    
    func destroySession() {
      inputStream.close()
      outputStream.close()
    }
}

extension Socket : StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case .hasBytesAvailable:
          readAvailableBytes(stream: inputStream)
        case .endEncountered:
          destroySession()
        case .errorOccurred:
          print("error occurred")
        case .hasSpaceAvailable:
          print("has space available")
        default:
          print("some other event...")
        }
    }
}
