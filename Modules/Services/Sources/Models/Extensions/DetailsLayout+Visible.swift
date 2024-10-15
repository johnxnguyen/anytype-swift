import AnytypeCore

public extension DetailsLayout {

    static let editorLayouts: [DetailsLayout] = [ .note, .basic, .profile, .todo ]
    static let listLayouts: [DetailsLayout] = [ .collection, .set ]
    
    static let fileLayouts: [DetailsLayout] = [ .file, .pdf ]
    static let mediaLayouts: [DetailsLayout] = [ .image, .audio, .video ]
    static let fileAndMediaLayouts = DetailsLayout.fileLayouts + DetailsLayout.mediaLayouts
    
    static let layoutsWithIcon: [DetailsLayout] = listLayouts + fileAndMediaLayouts + [.basic, .profile]
    static let layoutsWithCover: [DetailsLayout] = layoutsWithIcon + [.bookmark, .todo]
    
    static let visibleLayouts: [DetailsLayout] = listLayouts + editorLayouts + [.bookmark] + [.participant]
    static let visibleLayoutsWithFiles = visibleLayouts + fileAndMediaLayouts
    
    static let supportedForCreationInSets: [DetailsLayout] = editorLayouts + [.bookmark]
    
    
    var isTemplatesAvailable: Bool {
        DetailsLayout.editorLayouts.contains(self)
    }
    
}
