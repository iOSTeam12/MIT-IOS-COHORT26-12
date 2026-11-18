import Observation

/// Holds the navigation stack: the list of screens opened on top of Home.
/// The root NavigationStack reads `path`; screens call these methods.
/// Back always removes the top screen, never jumps to a fixed destination.
@Observable
final class AppRouter {
    /// Screens on top of Home, oldest first. Empty means Home is showing.
    var path: [AppRoute] = []

    /// Opens a screen on top of the current one.
    func open(_ route: AppRoute) {
        path.append(route)
    }

    /// Closes the top screen and shows the one underneath.
    func back() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    /// Closes every screen and shows Home.
    func backToHome() {
        path.removeAll()
    }
}
