import Foundation
import OSLog
import SwiftUI

@MainActor
final class ErrorHandler: ObservableObject {
    @Published var currentError: AppError?
    private let logger = Logger(subsystem: "com.endurafit", category: "ErrorHandler")
    
    func handle(_ error: Error) async {
        // Log the error
        logger.error("Error occurred: \(error.localizedDescription)")
        
        // Convert to AppError if needed
        if let appError = error as? AppError {
            currentError = appError
        } else {
            // Wrap unknown errors
            currentError = BaseError(
                title: "Unexpected Error",
                description: error.localizedDescription,
                code: 999
            )
        }
    }
    
    func clear() {
        currentError = nil
    }
}

// Helper for presenting errors in SwiftUI views
struct ErrorAlert: ViewModifier {
    @ObservedObject var errorHandler: ErrorHandler
    
    func body(content: Content) -> some View {
        content
            .alert(
                errorHandler.currentError?.title ?? "Error",
                isPresented: .constant(errorHandler.currentError != nil)
            ) {
                Button("OK") {
                    errorHandler.clear()
                }
            } message: {
                if let errorDescription = errorHandler.currentError?.errorDescription {
                    Text(errorDescription)
                }
            }
    }
}

extension View {
    func handleErrors(_ errorHandler: ErrorHandler) -> some View {
        modifier(ErrorAlert(errorHandler: errorHandler))
    }
} 