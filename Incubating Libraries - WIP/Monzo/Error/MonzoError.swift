import Foundation

enum MonzoError: LocalizedError {
    case accessTokenExpired // self explanatory
    case accessTokenEvicted // unauthorized.bad_access_token.evicted  Access token has been evicted due to a login elsewhere
    case server(ErrorResponse)
    case unknown((Data,URLResponse))
    
    init(_ errorResponse: ErrorResponse) {
        switch errorResponse.code {
        case "unauthorized.bad_access_token.evicted":
            self = .accessTokenEvicted
        case "unauthorized.bad_access_token.expired":
            self = .accessTokenExpired
        default:
            self = .server(errorResponse)
        }
    }
    
    //   - some : "{\"code\":\"forbidden.insufficient_permissions\",\"message\":\"Access forbidden due to insufficient permissions\",\"params\":{\"client_id\":\"oauth2client_00009i2VDp54jhKi3dY0jR\",\"user_id\":\"user_0000955lL5epsYYAmeh8Xx\"}}\n"
    
    //             // happens alot - maybe retry?
    //Error Domain=NSURLErrorDomain Code=-1005 "The network connection was lost." UserInfo={NSUnderlyingError=0x283d96df0 {Error Domain=kCFErrorDomainCFNetwork Code=-1005 "(null)" UserInfo={_kCFStreamErrorCodeKey=57, _kCFStreamErrorDomainKey=1}}, NSErrorFailingURLStringKey=https://api.monzo.com/oauth2/token, NSErrorFailingURLKey=https://api.monzo.com/oauth2/token, _kCFStreamErrorDomainKey=1, _kCFStreamErrorCodeKey=57, NSLocalizedDescription=The network connection was lost.}
    

}
