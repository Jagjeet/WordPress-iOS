
import UIKit

// MARK: - UILabel

extension UILabel {

    /// Convenience method that sets text & accessibility label.
    ///
    /// - Parameter value: the text to affix to the label
    func setText(_ value: String) {
        self.text = value
        accessibilityLabel = value
    }
}

// MARK: - UIStackView

extension UIStackView {

    /// Convenience method to add multiple `UIView` instances as arranged subviews en masse.
    ///
    /// - Parameter views: the views to install as arranged subviews
    func addArrangedSubviews(_ views: [UIView]) {
        views.forEach(addArrangedSubview)
    }
}

// MARK: - UIView

extension UIView {

    /// Oftentimes, the readable content guide is used to layout content.
    /// For Site Creation, however, iPhone content is "full bleed."
    /// This computed property implements this fallback logic.
    ///
    var prevailingLayoutGuide: UILayoutGuide {
        let layoutGuide: UILayoutGuide
        if WPDeviceIdentification.isiPad() {
            layoutGuide = readableContentGuide
        } else {
            if #available(iOS 11.0, *) {
                layoutGuide = safeAreaLayoutGuide
            } else {
                layoutGuide = layoutMarginsGuide
            }
        }

        return layoutGuide
    }

    /// Convenience method to add multiple `UIView` instances as subviews en masse.
    ///
    /// - Parameter views: the views to install as subviews
    func addSubviews(_ views: [UIView]) {
        views.forEach(addSubview)
    }
}
