/// Every screen the app can navigate to. Home is not here: it is the bottom
/// of the navigation stack (the screen shown when nothing has been opened),
/// so it can never be pushed twice. Use `AppRouter.backToHome()` to return.
enum AppRoute: Hashable {
    case learn
    case challenge
    case sandbox
    case profile
    /// The lesson "Tempo and Beats".
    case lesson
}
