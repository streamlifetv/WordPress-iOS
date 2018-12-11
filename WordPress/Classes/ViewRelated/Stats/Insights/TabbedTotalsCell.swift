import UIKit

struct TabData {
    var tabTitle: String
    var itemSubtitle: String
    var dataSubtitle: String
    var totalCount: String?
    var dataRows: [StatsTotalRowData]

    init(tabTitle: String,
         itemSubtitle: String,
         dataSubtitle: String,
         totalCount: String? = nil,
         dataRows: [StatsTotalRowData]) {
        self.tabTitle = tabTitle
        self.itemSubtitle = itemSubtitle
        self.dataSubtitle = dataSubtitle
        self.totalCount = totalCount
        self.dataRows = dataRows
    }
}

class TabbedTotalsCell: UITableViewCell, NibLoadable {

    // MARK: - Properties

    @IBOutlet weak var filterTabBar: FilterTabBar!
    @IBOutlet weak var totalCountLabel: UILabel!
    @IBOutlet weak var itemSubtitleLabel: UILabel!
    @IBOutlet weak var dataSubtitleLabel: UILabel!
    @IBOutlet weak var rowsStackView: UIStackView!

    @IBOutlet weak var topSeparatorLine: UIView!
    @IBOutlet weak var bottomSeparatorLine: UIView!

    private var tabsData = [TabData]()
    private typealias Style = WPStyleGuide.Stats
    private let maxNumberOfDataRows = 6
    private var siteStatsInsightsDelegate: SiteStatsInsightsDelegate?

    // MARK: - Configure

    func configure(tabsData: [TabData], siteStatsInsightsDelegate: SiteStatsInsightsDelegate) {
        self.tabsData = tabsData
        self.siteStatsInsightsDelegate = siteStatsInsightsDelegate
        setupFilterBar()
        configureSubtitles()
        addRows()
        applyStyles()
    }

    override func prepareForReuse() {
        removeExistingRows()
    }
}

// MARK: - FilterTabBar Support

private extension TabbedTotalsCell {

    func setupFilterBar() {
        WPStyleGuide.Stats.configureFilterTabBar(filterTabBar)
        filterTabBar.items = tabsData.map { $0.tabTitle }
        filterTabBar.addTarget(self, action: #selector(selectedFilterDidChange(_:)), for: .valueChanged)
    }

    @objc func selectedFilterDidChange(_ filterBar: FilterTabBar) {
        configureSubtitles()
        removeExistingRows()
        addRows()
        siteStatsInsightsDelegate?.tabbedTotalsCellUpdated?()
    }

}

// MARK: - Private Methods

private extension TabbedTotalsCell {

    func applyStyles() {
        Style.configureCell(self)
        Style.configureLabelAsTotalCount(totalCountLabel)
        Style.configureViewAsSeperator(topSeparatorLine)
        Style.configureViewAsSeperator(bottomSeparatorLine)
    }

    func configureSubtitles() {
        totalCountLabel.text = tabsData[filterTabBar.selectedIndex].totalCount
        itemSubtitleLabel.text = tabsData[filterTabBar.selectedIndex].itemSubtitle
        dataSubtitleLabel.text = tabsData[filterTabBar.selectedIndex].dataSubtitle
        Style.configureLabelAsSubtitle(itemSubtitleLabel)
        Style.configureLabelAsSubtitle(dataSubtitleLabel)
    }

    func addRows() {
        let dataRows = tabsData[filterTabBar.selectedIndex].dataRows
        let numberOfDataRows = dataRows.count

        if numberOfDataRows == 0 {
            let row = StatsNoDataRow.loadFromNib()
            rowsStackView.addArrangedSubview(row)
            // TODO: hide subtitles and total count
            return
        }

        let numberOfRowsToAdd = numberOfDataRows > maxNumberOfDataRows ? maxNumberOfDataRows : numberOfDataRows

        for index in 0..<numberOfRowsToAdd {
            let dataRow = dataRows[index]
            let row = StatsTotalRow.loadFromNib()
            row.configure(rowData: dataRow)

            // Don't show the separator line on the last row.
            if index == (numberOfRowsToAdd - 1) {
                row.showSeparator = false
            }

            rowsStackView.addArrangedSubview(row)
        }

        // If there are more data rows, show 'View more'.
        if numberOfDataRows > maxNumberOfDataRows {
            addViewMoreRow()
        }
    }

    func addViewMoreRow() {
        let row = ViewMoreRow.loadFromNib()
        rowsStackView.addArrangedSubview(row)
    }

    func removeExistingRows() {
        rowsStackView.arrangedSubviews.forEach {
            rowsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }

}