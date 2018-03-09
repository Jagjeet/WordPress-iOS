import UIKit
import Gridicons

/// Displays a simple table view picker list to choose between author filters
/// for a post.
///
class AuthorFilterViewController: UITableViewController {
    private typealias AuthorFilter = PostListFilterSettings.AuthorFilter

    /// An optional gravatar email address. If provided, this will be used to
    /// display a gravatar icon alongside the "Only Me" posts
    var gravatarEmail: String? = nil

    /// The currently selected author filer
    var currentSelection: PostListFilterSettings.AuthorFilter

    /// An optional block, which will be called whenever the user selects an
    /// item in the filter list.
    var onSelectionChanged: ((PostListFilterSettings.AuthorFilter) -> Void)? = nil

    private var selectedIndexPath: IndexPath? {
        guard let row = rows.index(of: currentSelection) else {
            return nil
        }

        return IndexPath(row: row, section: 0)
    }

    private let rows = [
        AuthorFilter.mine,
        AuthorFilter.everyone
    ]

    init(initialSelection: PostListFilterSettings.AuthorFilter,
         gravatarEmail: String? = nil,
         onSelectionChanged: ((PostListFilterSettings.AuthorFilter) -> Void)? = nil) {
        self.gravatarEmail = gravatarEmail
        self.onSelectionChanged = onSelectionChanged
        self.currentSelection = initialSelection

        super.init(style: .plain)

        tableView.register(AuthorFilterCell.self, forCellReuseIdentifier: Identifiers.authorFilterCell)

        tableView.rowHeight = Metrics.rowHeight
        tableView.separatorInset = .zero
        tableView.separatorColor = WPStyleGuide.greyLighten20()
        tableView.isScrollEnabled = false
        tableView.showsVerticalScrollIndicator = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var preferredContentSize: CGSize {
        set {}
        get {
            let height = CGFloat(tableView(self.tableView, numberOfRowsInSection: 0)) * Metrics.rowHeight
            return CGSize(width: Metrics.preferredWidth, height: height)
        }
    }

    // MARK: - Table View Delegate / Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.authorFilterCell, for: indexPath)


        if let cell = cell as? AuthorFilterCell,
            let filter = PostListFilterSettings.AuthorFilter(rawValue: UInt(indexPath.row)) {
            if filter == .mine {
                cell.gravatarEmail = gravatarEmail
            }

            cell.accessoryType = (filter == currentSelection) ? .checkmark : .none

            cell.title = filter.stringValue
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let filter = PostListFilterSettings.AuthorFilter(rawValue: UInt(indexPath.row)) else {
            return
        }

        if let selectedIndexPath = selectedIndexPath {
            setRow(at: selectedIndexPath, selected: false)
        }

        currentSelection = filter

        setRow(at: indexPath, selected: true)

        onSelectionChanged?(filter)
    }

    private func setRow(at indexPath: IndexPath, selected: Bool) {
        if let cell = tableView.cellForRow(at: indexPath) as? AuthorFilterCell {
            cell.accessoryType = selected ? .checkmark : .none
        }
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        // Prevents extra separators being drawn at the bottom of the table
        return UIView()
    }

    // MARK: - Constants

    private enum Identifiers {
        static let authorFilterCell: String = "AuthorFilterCell"
    }

    private enum Metrics {
        static let rowHeight: CGFloat = 44.0
        static let preferredWidth: CGFloat = 220.0
    }
}

/// Table cell used in the authors filter table. Displays a text label and
/// an optional gravatar in a circular image view.
///
private class AuthorFilterCell: UITableViewCell {

    private let gravatarImageView: CircularImageView = {
        let imageView = CircularImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        imageView.backgroundColor = WPStyleGuide.greyLighten20()
        imageView.tintColor = .white
        return imageView
    }()

    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = Fonts.titleFont
        return titleLabel
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10.0
        return stackView
    }()

    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.horizontalPadding),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.horizontalPadding),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            gravatarImageView.widthAnchor.constraint(equalToConstant: Metrics.gravatarSize.width),
            gravatarImageView.heightAnchor.constraint(equalToConstant: Metrics.gravatarSize.height),
            ])

        stackView.addArrangedSubview(titleLabel)

        tintColor = WPStyleGuide.mediumBlue()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var gravatarEmail: String? = nil {
        didSet {
            if let gravatarEmail = gravatarEmail {
                stackView.insertArrangedSubview(gravatarImageView, at: 0)
                gravatarImageView.downloadGravatarWithEmail(gravatarEmail,
                                                            placeholderImage: Gridicon.iconOfType(.user, withSize: Metrics.gravatarSize))
            } else {
                gravatarImageView.removeFromSuperview()
            }
        }
    }

    // MARK: - Constants

    private enum Fonts {
        static let titleFont = UIFont.systemFont(ofSize: 16.0)
    }

    private enum Metrics {
        static let horizontalPadding: CGFloat = 16.0
        static let gravatarSize = CGSize(width: 28.0, height: 28.0)
    }
}
