import Foundation
import Network
import Combine

extension Notification.Name {
    static let connectivityStatus = Notification.Name(rawValue: "connectivityStatusChanged")
}

public protocol NetworkMonitorProtocol {
    var isConnected: Bool { get }
    var isConnectedStream: AnyPublisher<Bool, Never> { get }
}

public final class NetworkMonitor: NetworkMonitorProtocol {
    
    public static let shared = NetworkMonitor()

    private let queue = DispatchQueue(label: "NetworkConnectivityMonitor")
    private let monitor: NWPathMonitor

    @Published private var _isConnected = true
    
    // Exposed async getters to conform to protocol
    public var isConnected: Bool {
        get { _isConnected }
    }

    public var isConnectedStream: AnyPublisher<Bool, Never> {
        get { $_isConnected.eraseToAnyPublisher() }
    }

    private init() {
        monitor = NWPathMonitor()
        Task {
            await startMonitoring()
        }
    }

    func startMonitoring() async {
        monitor.pathUpdateHandler = { path in
            let status = path.status != .unsatisfied
            NotificationCenter.default.post(name: .connectivityStatus, object: nil)
            self._isConnected = status
        }
        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        monitor.cancel()
    }
}

extension NetworkMonitor: @unchecked Sendable {}
