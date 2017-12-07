import Foundation

@objc(MBTextType)
public enum TextType: UInt, CustomStringConvertible {
    
    case text
    
    case ssml
    
    public init?(description: String) {
        let type: TextType
        switch description {
        case "text":
            type = .text
        case "ssml":
            type = .ssml
        default:
            return nil
        }
        self.init(rawValue: type.rawValue)
    }
    
    public var description: String {
        switch self {
        case .text:
            return "text"
        case .ssml:
            return "ssml"
        }
    }
}

@objc(MBAudioFormat)
public enum AudioFormat: UInt, CustomStringConvertible {

    case mp3
    
    case oggVorbis
    
    case pcm
    
    public init?(description: String) {
        let format: AudioFormat
        switch description {
        case "mp3":
            format = .mp3
        case "ogg_vorbis":
            format = .oggVorbis
        case "pcm":
            format = .pcm
        default:
            return nil
        }
        self.init(rawValue: format.rawValue)
    }
    
    public var description: String {
        switch self {
        case .mp3:
            return "mp3"
        case .oggVorbis:
            return "ogg_vorbis"
        case .pcm:
            return "pcm"
        }
    }
}

@objc(MBSpeechOptions)
open class SpeechOptions: NSObject, NSSecureCoding {
    
    @objc public init(text: String) {
        self.text = text
        self.textType = .text
    }
    
    @objc public init(ssml: String) {
        self.text = ssml
        self.textType = .ssml
    }
    
    public required init?(coder decoder: NSCoder) {
        text = decoder.decodeObject(of: [NSArray.self, NSString.self], forKey: "text") as? String ?? ""
        
        guard let textType = TextType(description: decoder.decodeObject(of: NSString.self, forKey: "textType") as String? ?? "") else {
            return nil
        }
        self.textType = textType
        
        guard let outputFormat = AudioFormat(description: decoder.decodeObject(of: NSString.self, forKey: "outputFormat") as String? ?? "") else {
            return nil
        }
        self.outputFormat = outputFormat
        
        guard let voiceId = VoiceId(description: decoder.decodeObject(of: NSString.self, forKey: "voiceId") as String? ?? "") else {
            return nil
        }
        self.voiceId = voiceId
    }
    
    open static var supportsSecureCoding = true
    
    public func encode(with coder: NSCoder) {
        coder.encode(text, forKey: "text")
        coder.encode(textType, forKey: "textType")
        coder.encode(voiceId, forKey: "voiceId")
        coder.encode(outputFormat, forKey: "outputFormat")
    }
    
    /**
     `String` to create audiofile for. Can either be plain text or [`SSML`](https://en.wikipedia.org/wiki/Speech_Synthesis_Markup_Language).
     
     If `SSML` is provided, `TextType` must be `TextType.ssml`.
     */
    @objc open var text: String
    
    
    /**
     Type of text to synthesize.
     
     `SSML` text must be valid `SSML` for request to work.
     */
    @objc var textType: TextType = .text
    
    
    /**
     Type of voice to use to say text.
     
     Note, `VoiceId` are specific to a `Locale`.
     */
    @objc var voiceId: VoiceId = .joanna
    
    
    /**
     Audio format for outputted audio file.
     */
    @objc open var outputFormat: AudioFormat = .mp3
    
    /**
     The locale in which the audio is spoken.
     
     By default, the user's system locale will be used to decide upon an appropriate voice.
     */
    @objc open var locale: Locale = Locale.autoupdatingCurrent
    
    /**
     The path of the request URL, not including the hostname or any parameters.
     */
    internal var path: String {
        let disallowedCharacters = (CharacterSet(charactersIn: "\\!*'();:@&=+$,/<>?%#[]\" ").inverted)
        return "voice/v1/speak/\(text.addingPercentEncoding(withAllowedCharacters: disallowedCharacters)!)"
    }
    
    /**
     An array of URL parameters to include in the request URL.
     */
    internal var params: [URLQueryItem] {
        let params: [URLQueryItem] = [
            URLQueryItem(name: "textType", value: String(describing: textType)),
            URLQueryItem(name: "voiceId", value: String(describing: voiceId)),
            URLQueryItem(name: "outputFormat", value: String(describing: outputFormat))
        ]
        
        return params
    }
    
    @objc func voiceIdForLocale() -> VoiceId {
        let langs = locale.identifier.components(separatedBy: "-")
        let langCode = langs[0]
        var countryCode = ""
        if langs.count > 1 {
            countryCode = langs[1]
        }
        
        switch (langCode, countryCode) {
        case ("de", _):
            return .marlene
        case ("en", "CA"):
            return .joanna
        case ("en", "GB"):
            return .brian
        case ("en", "AU"):
            return .nicole
        case ("en", "IN"):
            return .raveena
        case ("en", _):
            return .joanna
        case ("es", "ES"):
            return .enrique
        case ("es", _):
            return .miguel
        case ("fr", _):
            return .celine
        case ("it", _):
            return .giorgio
        case ("nl", _):
            return .lotte
        case ("ro", _):
            return .carmen
        case ("ru", _):
            return .maxim
        case ("sv", _):
            return .astrid
        case ("tr", _):
            return .filiz
        default:
            return.joanna
        }
    }
}
