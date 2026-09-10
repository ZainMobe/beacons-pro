import SwiftUI
import StoreKit

/// Presents the system rating prompt when `ReviewPromptService` signals
/// that an earned calm moment has arrived, waiting briefly so the UI can
/// settle before the sheet appears.
private struct ReviewPromptModifier: ViewModifier {
    @Environment(ReviewPromptService.self) private var reviewPrompt
    @Environment(\.requestReview) private var requestReview

    func body(content: Content) -> some View {
        content
            .task(id: reviewPrompt.promptPending) {
                guard reviewPrompt.promptPending else { return }
                try? await Task.sleep(for: .seconds(1.5))
                guard !Task.isCancelled else { return }
                requestReview()
                reviewPrompt.markPrompted()
            }
    }
}

extension View {
    /// Presents the App Store rating prompt at earned calm moments.
    func reviewPromptHost() -> some View {
        modifier(ReviewPromptModifier())
    }
}
