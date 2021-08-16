import UIKit
import AnytypeCore

extension UIImage {
    static let back = UIImage(named: "TextEditor/Toolbar/Blocks/Back")
    static let more = UIImage(named: "TextEditor/More")
    
    static let searchIcon = UIImage(named: "searchTextFieldIcon")
}

extension UIImage {
    enum edititngToolbar {
        static let addNew = createImage("EditingToolbar/add_new")
        static let style = createImage("EditingToolbar/style")
        static let move = createImage("EditingToolbar/move")
        static let mention = createImage("EditingToolbar/mention")
    }
    
    enum divider {
        static let dots = createImage("TextEditor/Style/Other/Divider/Dots")
    }
    
    enum blockFile {
        static let noImage = createImage("TextEditor/no_image")
        
        enum empty {
            static let image = createImage("TextEditor/BlockFile/Empty/Image")
            static let video = createImage("TextEditor/BlockFile/Empty/Video")
            static let file = createImage("TextEditor/BlockFile/Empty/File")
            static let bookmark = createImage("TextEditor/BlockFile/Empty/Bookmark")
        }
        
        enum content {
            static let text = createImage("TextEditor/BlockFile/Content/Text")
            static let spreadsheet = createImage("TextEditor/BlockFile/Content/Spreadsheet")
            static let presentation = createImage("TextEditor/BlockFile/Content/Presentation")
            static let pdf = createImage("TextEditor/BlockFile/Content/PDF")
            static let image = createImage("TextEditor/BlockFile/Content/Image")
            static let audio = createImage("TextEditor/BlockFile/Content/Audio")
            static let video = createImage("TextEditor/BlockFile/Content/Video")
            static let archive = createImage("TextEditor/BlockFile/Content/Archive")
            static let other = createImage("TextEditor/BlockFile/Content/Other")
        }
    }
    
    enum Title {
        enum TodoLayout {
            static let checkbox = createImage("title_todo_checkbox")
            static let checkmark = createImage("title_todo_checkmark")
        }
    }
    
    enum codeBlock {
        static let arrow = createImage("TextEditor/Toolbar/turn_into_arrow")
    }
    
    enum textAttributes {
        static let code = createImage("TextAttributes/code")
        static let url = createImage("TextAttributes/url")
        static let bold = createImage("TextAttributes/bold")
        static let italic = createImage("TextAttributes/italic")
        static let strikethrough = createImage("TextAttributes/strikethrough")
        static let alignLeft = createImage("TextAttributes/align_left")
        static let alignRight = createImage("TextAttributes/align_right")
        static let alignCenter = createImage("TextAttributes/align_center")
    }
    
    private static func createImage(_ name: String) -> UIImage {
        guard let image = UIImage(named: name) else {
            anytypeAssertionFailure("No image named: \(name)")
            return UIImage()
        }
        
        return image
    }
}
