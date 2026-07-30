//
//  GridResultCell.swift
//  GridBarcodeReading
//

import UIKit

final class GridResultCell: UITableViewCell {
    static let reuseIdentifier = "GridResultCell"
    static let rowColumnWidth: CGFloat = 42
    static let statusWidth: CGFloat = 120

    private let rowLabel = GridResultCell.makeLabel(alignment: .center)
    private let colLabel = GridResultCell.makeLabel(alignment: .center)
    private let statusLabel = GridResultCell.makeLabel(weight: .semibold)
    private let textValueLabel = GridResultCell.makeLabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        let stackView = UIStackView(arrangedSubviews: [rowLabel, colLabel, statusLabel, textValueLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8

        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            rowLabel.widthAnchor.constraint(equalToConstant: GridResultCell.rowColumnWidth),
            colLabel.widthAnchor.constraint(equalToConstant: GridResultCell.rowColumnWidth),
            statusLabel.widthAnchor.constraint(equalToConstant: GridResultCell.statusWidth)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with result: GridCellResult) {
        rowLabel.text = "\(result.row)"
        colLabel.text = "\(result.col)"
        statusLabel.text = result.status.rawValue
        statusLabel.textColor = result.status.color
        textValueLabel.text = result.text
    }

    static func makeLabel(alignment: NSTextAlignment = .left,
                          weight: UIFont.Weight = .regular) -> UILabel {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 14, weight: weight)
        label.textColor = .label
        label.textAlignment = alignment
        label.numberOfLines = 0
        return label
    }
}
