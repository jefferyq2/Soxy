//
//  Server.swift
//  SoxProxy
//
//  Created by Luo Sheng on 15/10/3.
//  Copyright © 2015年 Pop Tap. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

public class Server: GCDAsyncSocketDelegate, ConnectionDelegate {
    
    private let socket: GCDAsyncSocket
    private var connections = Set<Connection>()
    public var proxyAddress: Address?
    
    public var host: String! {
        get {
            return socket.localHost
        }
    }
    
    public var port: UInt16 {
        get {
            return socket.localPort
        }
    }
    
    init(port: UInt16) throws {
        socket = GCDAsyncSocket(delegate: nil, delegateQueue: dispatch_get_global_queue(0, 0))
        socket.delegate = self
        try socket.acceptOnPort(port)
    }
    
    deinit {
        self.disconnectAll()
    }
    
    func disconnectAll() {
        for connection in connections {
            connection.disconnect()
        }
    }
    
    // MARK: - GCDAsyncSocketDelegate
    
    @objc public func socket(sock: GCDAsyncSocket!, didAcceptNewSocket newSocket: GCDAsyncSocket!) {
        let connection = Connection(socket: newSocket)
        connection.delgate = self
        connection.proxyAddress = proxyAddress
        connections.insert(connection)
    }
    
    // MARK: - SOCKSConnectionDelegate
    
    func connectionDidClose(connection: Connection) {
        connections.remove(connection)
    }
}