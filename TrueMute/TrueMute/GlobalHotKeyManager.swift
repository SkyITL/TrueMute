import Cocoa
import Carbon.HIToolbox

class GlobalHotKeyManager {
    private var hotKeyRef: EventHotKeyRef?

    init() {
        registerHotKey()
    }

    deinit {
        unregisterHotKey()
    }

    private func registerHotKey() {
        let hotKeyID = EventHotKeyID(signature: fourCharCode(from: "swft"), id: 1)
        let hotKeyModifiers = UInt32(shiftKey | cmdKey) >> 8
        let hotKeyCode = UInt32(kVK_ANSI_M)
        var eventType = EventTypeSpec(eventClass: OSType(UInt32(kEventClassKeyboard) as UInt32), eventKind: UInt32(kEventHotKeyPressed) as UInt32)

        RegisterEventHotKey(hotKeyCode, hotKeyModifiers, hotKeyID, GetEventDispatcherTarget(), 0, &hotKeyRef)
        
        InstallEventHandler(GetEventDispatcherTarget(), { (_, theEvent, _) -> OSStatus in
            var hkCom = EventHotKeyID()
            GetEventParameter(theEvent, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &hkCom)

            if hkCom.signature == hotKeyID.signature && hkCom.id == hotKeyID.id {
                if VolumeController.isMuted == false{
                    VolumeController.isMuted = true
                }
                else{
                    VolumeController.isMuted = false
                }
            }

            return noErr
        }, 1, &eventType, nil, nil)
    }


    private func unregisterHotKey() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }
    }

    private func fourCharCode(from string: String) -> UInt32 {
        var result: UInt32 = 0
        for char in string.utf8 {
            result = result << 8 + UInt32(char)
        }
        return result
    }
}
