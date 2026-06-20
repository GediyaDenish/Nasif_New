//
//  SocketService.swift
//  Nasif
//
//  Created by Denish Gediya on 18/09/25.
//

import Foundation
import SocketIO

class SocketService{
    let manager = SocketManager(
        socketURL: URL(string: "\(WebService.APIConfig.API)")!,
        config: [
            .log(false),
            .compress,
            .connectParams(["token": UserDefaultsHelper.shared.token]),
            .secure(true),
            .reconnects(false),
            //            .reconnectWait(2),
            //            .reconnectAttempts(-1),
                .forceWebsockets(true),
            //            .forceNew(true)
        ])
    var socket:SocketIOClient!
    static var shared: SocketService?
    var pingTimer: Timer?
    var reconnectTimer: Timer?
    
    init(){
        SocketService.shared = self
        self.socket = manager.defaultSocket
        self.socketHandlers()
        self.startReconnectMonitoring() // 🔄 Manual reconnect loop
        self.startPinging()             // 📶 Optional latency monitoring
    }
    
    func sendDealMessage(dealId:String?, message:MessageModel ){
        guard self.socket.status == .connected else { return }
        guard let userId = UserDefaultsHelper.getUserFromDefaults()?.userId else { return }
        guard let dId = dealId else { return }
        var data:[String:Any] = [:]
        data["deal"] = dId
        data["sender"] = userId
        data["type"] = message.type
        data["text"] = message.text
        data["fileType"] = message.fileType
        data["fileName"] = message.fileName
        data["file"] = message.file
        self.socket.emit("dealMessage",data)
    }
    
    func sendChatMessage(chatId:String?, message:MessageModel ){
        guard self.socket.status == .connected else { return }
        guard let userId = UserDefaultsHelper.getUserFromDefaults()?.userId else { return }
        guard let cId = chatId else { return }
        var data:[String:Any] = [:]
        data["chat"] = cId
        data["property"] = message.property
        data["sender"] = userId
        data["type"] = message.type
        data["text"] = message.text
        data["fileType"] = message.fileType
        data["fileName"] = message.fileName
        data["file"] = message.file
        self.socket.emit("chatMessage",data)
    }
    
    func startReconnectMonitoring() {
        self.reconnectTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.socket.status == .disconnected || self.socket.status == .notConnected {
                print("Attempting manual connect...")
                self.socket.connect()
            }
        }
    }
    
    private func startPinging() {
        self.pingTimer = Timer.scheduledTimer(withTimeInterval: 5.0 , repeats: true) { [weak self] _ in
            self?.sendPing()
        }
    }
    
    func sendPing() {
        let startTime = Date().timeIntervalSince1970
        if self.socket.status == .connected  {
            self.socket.emitWithAck("pingCheck").timingOut(after: 5) { data in
                let endTime = Date().timeIntervalSince1970
                let latency = (endTime - startTime) * 1000
                print("Socket latency: \(Int(latency)) ms")
            }
        }
    }
    
    func socketHandlers(){
        
        self.socket.on(clientEvent: .reconnect) {data, ack in
            print("socket reconnect")
        }
        
        self.socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
        }
        
        self.socket.on(clientEvent: .disconnect) { data, ack in
            print("socket dis-connected")
        }
        
        self.socket.on(clientEvent: .reconnectAttempt) { data, ack in
            print("Attempting to reconnect...")
        }
        
        self.socket.on(clientEvent: .error) {data, ack in
            print("Socket encountered an error: \(data)")
        }
        
        self.socket.on(clientEvent: .statusChange) { data, ack in
            print("Socket status changed: \(self.socket.status.rawValue)")
        }
    }
}

