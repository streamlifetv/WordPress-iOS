import MGSwipeTableCell

/// Encapsulates logic to approve a cooment
final class ApproveComment: DefaultNotificationActionCommand {
    private enum TitleStrings {
        static let approve = NSLocalizedString("Approve", comment: "Approves a Comment")
        static let unapprove = NSLocalizedString("Unapprove", comment: "Unapproves a Comment")
    }

    private enum TitleHints {
        static let approve = NSLocalizedString("Approves a Comment.", comment: "VoiceOver accessibility hint, informing the user the button can be used to approve a comment")
        static let unapprove = NSLocalizedString("Unapproves a Comment.", comment: "VoiceOver accessibility hint, informing the user the button can be used to unapprove a comment")
    }

    override var on: Bool {
        willSet {
            let newTitle = newValue ? TitleStrings.approve : TitleStrings.unapprove
            setIconTitle(newTitle)
            setAccessibilityLabel(newTitle)

            let newHint = newValue ? TitleHints.approve : TitleHints.unapprove
            setAccessibilityHint(newHint)
        }
    }

    let approveIcon: UIButton = {
        let title = TitleStrings.approve
        let button = MGSwipeButton(title: title, backgroundColor: WPStyleGuide.wordPressBlue())
        button.accessibilityLabel = title
        button.accessibilityTraits = UIAccessibilityTraitButton
        button.accessibilityHint = TitleHints.approve
        return button
    }()

    override var icon: UIButton? {
        return approveIcon
    }

    override func execute(context: ActionContext) {
        let block = context.block
        if on {
            unApprove(block: block)
        } else {
            approve(block: block)
        }
    }

    private func unApprove(block: ActionableObject) {
        setIconTitle(TitleStrings.unapprove)
        setAccessibilityLabel(TitleStrings.unapprove)
        setAccessibilityHint(TitleHints.unapprove)

        ReachabilityUtils.onAvailableInternetConnectionDo {
            actionsService?.unapproveCommentWithBlock(block)
        }
    }

    private func approve(block: ActionableObject) {
        setIconTitle(TitleStrings.approve)
        setAccessibilityLabel(TitleStrings.approve)
        setAccessibilityHint(TitleHints.approve)

        ReachabilityUtils.onAvailableInternetConnectionDo {
            actionsService?.approveCommentWithBlock(block)
        }
    }
}
