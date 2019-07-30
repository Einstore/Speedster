import Foundation


extension Result {
    
    func get() -> Success? {
        switch self {
        case .success(let success):
            return success
        default:
            return nil
        }
    }
    
    func error() -> Failure? {
        switch self {
        case .failure(let error):
            return error
        default:
            return nil
        }
    }
    
}
