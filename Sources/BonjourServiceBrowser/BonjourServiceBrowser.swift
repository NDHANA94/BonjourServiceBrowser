// The Swift Programming Language
// https://docs.swift.org/swift-book


// The Swift Programming Language
// https://docs.swift.org/swift-book

import Network
import Foundation

@available(iOS 13.0, *)
public class BonjourServiceBrowser{
    public var state:State = .not_started
    private var browserQ:NWBrowser?

    private var serviceType:String?
    private var serviceDomain:String?
    private var serviceParameter:NWParameters


    public init(serviceType:String, serviceDomain:String, using:NWParameters){
        self.serviceType = serviceType
        self.serviceDomain = serviceDomain
        self.serviceParameter = using
    }

    public func start(queue: DispatchQueue, browseResultsChangedHandler: @escaping (Set<NWBrowser.Result>, Set<NWBrowser.Result.Change>) -> Void) -> Bool {
        
        if let serviceType = self.serviceType,
           let serviceDomain = self.serviceDomain{
            let descriptor = NWBrowser.Descriptor.bonjour(type:serviceType, domain:serviceDomain)
            browserQ = NWBrowser(for: descriptor, using: self.serviceParameter)
            if let browserQ = browserQ {
                browserQ.stateUpdateHandler = serviceStateUpdateHandler
                browserQ.browseResultsChangedHandler = browseResultsChangedHandler
                browserQ.start(queue: queue)
                state = .started
                return true
            } else {
                state = .error("failed to start")
                return false
            }



        } else {
            state = .error("Not been configured. Please configure using the function config(serviceType:serviceDomain:using:)")
            return false
        }
        
        
    }

    public func stop(){
        if let browserQ = browserQ{
            browserQ.stateUpdateHandler = nil
            browserQ.cancel()
            state = .stopped
        }
    }

    private func serviceStateUpdateHandler(newState:NWBrowser.State){
        print("[BonjourServiceBrowser][State] \(newState)")
    }
}

@available(iOS 13.0, *)
extension BonjourServiceBrowser{
    public enum State {
        case not_started
        case started
        case stopped
        case error(String)
    }

    

    public struct BonjourServer{
        var endpoint:NWEndpoint
        var state:ServerState = .not_connected
    }

    public enum ServerState:String, Equatable {
        case not_connected = "not connected"
        case connecting = "connecting..."
        case connected = "connected"
    }

}