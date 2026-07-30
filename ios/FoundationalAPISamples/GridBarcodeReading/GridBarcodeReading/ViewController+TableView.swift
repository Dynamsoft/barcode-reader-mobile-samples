//
//  ViewController+TableView.swift
//  GridBarcodeReading
//

import UIKit

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GridResultCell.reuseIdentifier, for: indexPath) as? GridResultCell else {
            return UITableViewCell()
        }
        cell.configure(with: results[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .secondarySystemBackground

        func makeHeaderLabel(_ text: String, width: CGFloat? = nil) -> UILabel {
            let alignment: NSTextAlignment = width == GridResultCell.rowColumnWidth ? .center : .left
            let label = GridResultCell.makeLabel(alignment: alignment, weight: .semibold)
            label.text = text
            label.textColor = .secondaryLabel
            if let width {
                label.widthAnchor.constraint(equalToConstant: width).isActive = true
            }
            return label
        }

        let stackView = UIStackView(arrangedSubviews: [
            makeHeaderLabel("ROW", width: GridResultCell.rowColumnWidth),
            makeHeaderLabel("COL", width: GridResultCell.rowColumnWidth),
            makeHeaderLabel("STATUS", width: GridResultCell.statusWidth),
            makeHeaderLabel("TEXT")
        ])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8

        let separator = UIView()
        separator.backgroundColor = .separator

        headerView.addSubview(stackView)
        headerView.addSubview(separator)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        separator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -12),
            stackView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8),
            separator.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 12),
            separator.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -12),
            separator.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale)
        ])

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        results.isEmpty ? 0 : 36
    }
}
