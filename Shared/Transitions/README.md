# Feed Transition Layer

This folder contains all transition-related logic for the Feed feature, including gesture handling and animated dismiss transitions.

---

## Structure

| File | Role |
|:----|:-----|
| `FeedDismissControllable.swift` | Defines the public interface (protocol) for a controller that can be dismissed with a swipe gesture. |
| `FeedDismissGestureHandler.swift` | Manages the pan gesture, swipe detection, and communicates with the controller via the protocol. |
| `HeroDismissAnimator.swift` | Manages the custom animated dismiss transition. |
| `HeroDismissConfig.swift` | Defines the configuration needed for the dismiss animation. |

---

## Design Principles

- `FeedController` **delegates** gesture handling to `FeedDismissGestureHandler`.
- `FeedController` **implements** `FeedDismissControllable`, exposing only minimal API (`triggerDismiss`, `resetDismissAnimation`) for transition management.
- `FeedDismissGestureHandler` **never** accesses internal logic directly. It only communicates via the `FeedDismissControllable` protocol.
- `HeroDismissAnimator` is fully **decoupled** and uses a config object (`HeroDismissConfig`) to animate dismiss transitions.
  
This ensures:
- Clear separation of concerns
- Better scalability
- Easier maintenance

---

## Usage Example

```swift
final class FeedController: UIViewController, FeedDismissControllable {
    
    private var dismissGestureHandler: FeedDismissGestureHandler!

    override func viewDidLoad() {
        super.viewDidLoad()
        dismissGestureHandler = FeedDismissGestureHandler(view: contentView, backgroundOverlay: backgroundOverlayView)
        dismissGestureHandler.delegate = self
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        dismissGestureHandler.handlePan(gesture)
    }
    
    func triggerDismiss() {
        // Triggers a custom animated dismiss
    }
    
    func resetDismissAnimation(to position: CGPoint?) {
        // Resets UI if dismiss is cancelled
    }
}
