import UIKit
import Foundation

class BottomBorderTextField: UITextField {
    
    // MARK: - Configuration
    
    @IBInspectable var leftInset: CGFloat = 15 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var rightInset: CGFloat = 15 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var bottomLineWidth: CGFloat = 1 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var bottomLineColor = UIColor.lightGray {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var placeholderFont = UIFont.systemFont(ofSize: 17.0) {
        didSet {
            replacePlaceholderAttributte(attrubute: NSFontAttributeName, toObject: placeholderFont)
        }
    }
    
    @IBInspectable var topPlaceholderFont = UIFont.systemFont(ofSize: 12) {
        didSet {
            updateTopPlaceholderAppearance()
        }
    }
    
    @IBInspectable var placeholderColor = UIColor.gray.withAlphaComponent(0.8) {
        didSet {
            replacePlaceholderAttributte(attrubute: NSForegroundColorAttributeName, toObject: placeholderColor)
        }
    }
    
    @IBInspectable var errorColor = UIColor.red
    
    // MARK: - Properties
    
    private let topPlaceholderLabel = UILabel()
    private var topPlaceholderPined = false
    
    private var showingError = false
    
    override var placeholder: String? {
        didSet {
            setPlaceholder(placeholder: placeholder)
        }
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupWithPlaceholder(placeholder: placeholder)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupWithPlaceholder(placeholder: placeholder)
    }
    
    private func setupWithPlaceholder(placeholder: String?) {
        addSubview(topPlaceholderLabel)
        updateTopPlaceholderAppearance()
        
        setPlaceholder(placeholder: placeholder)
        setNeedsUpdateConstraints()
    }
    
    private func setPlaceholder(placeholder: String?) {
        topPlaceholderLabel.text = placeholder
        
        guard let placeholder = placeholder else {
            attributedPlaceholder = nil
            return
        }
        
        let attrubuttedString = NSMutableAttributedString(string: placeholder)
        let attributes = [
            NSFontAttributeName: placeholderFont,
            NSForegroundColorAttributeName: placeholderColor
        ] as [String : Any]
        
        let range = NSRange(location: 0, length: placeholder.characters.count)
        attrubuttedString.setAttributes(attributes, range: range)
        
        attributedPlaceholder = attrubuttedString
    }
    
    private func updateTopPlaceholderAppearance() {
        topPlaceholderLabel.textColor = showingError ? errorColor : placeholderColor
        topPlaceholderLabel.font = placeholderFont.withSize(12)
    }
    
    // MARK: - Drawing
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        
        let startPoint = CGPoint(x: 0 + 0.5, y: rect.size.height - 0.5)
        let endPoint = CGPoint(x: rect.size.width - 0.5, y: rect.size.height - 0.5)
        
        path.lineWidth = bottomLineWidth
        path.lineCapStyle = .round
        
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        
        if showingError {
            errorColor.setStroke()
        } else {
            bottomLineColor.setStroke()
        }
        
        path.stroke()
    }
    
    // MARK: - Overrides
    
    override func updateConstraints() {
        if !topPlaceholderPined {
            pinTopPlaceholderLabel()
        }
        
        super.updateConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        topPlaceholderLabel.isHidden = text?.characters.count == 0 && !showingError
        
        setNeedsDisplay()
    }
    
    override public var intrinsicContentSize: CGSize {
        get {
            var size = super.intrinsicContentSize
            let topPlaceholderSize = topPlaceholderLabel.intrinsicContentSize
            
            size.width += leftInset + rightInset
            size.height += topPlaceholderSize.height
            
            return size
        }
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return filledTextRectForBounds(bounds: bounds)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let hasText = (text?.characters.count)! > 0
        let insetFunction = (hasText || showingError) ? filledTextRectForBounds : emptyTextRectForBounds
        return insetFunction(bounds)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return showingError ? filledTextRectForBounds(bounds: bounds) : emptyTextRectForBounds(bounds: bounds)
    }
    
    private func emptyTextRectForBounds(bounds: CGRect) -> CGRect {
        let topLabelSize = topPlaceholderLabel.intrinsicContentSize
        let horizontalInset = topLabelSize.height / 2
        let insets = UIEdgeInsets(top: horizontalInset, left: leftInset,
                                  bottom: horizontalInset, right: rightInset)
        return UIEdgeInsetsInsetRect(bounds, insets)
    }
    
    private func filledTextRectForBounds(bounds: CGRect) -> CGRect {
        let topLabelSize = topPlaceholderLabel.intrinsicContentSize
        var availableRect = bounds
        
        availableRect.size.height -= topLabelSize.height
        availableRect.origin.y += topLabelSize.height
        
        let insets = UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
        return UIEdgeInsetsInsetRect(availableRect, insets)
    }
    
    // MARK: - Placeholder
    
    private func replacePlaceholderAttributte(attrubute: String, toObject object: AnyObject) {
        guard let placeholder = attributedText?.mutableCopy() as? NSMutableAttributedString else {
            return
        }
        
        var attributes = placeholder.attributes(at: 0, effectiveRange: nil)
        attributes[attrubute] = object
        
        placeholder.setAttributes(attributes, range: NSRange(location: 0, length: placeholder.length))
    }
    
    private func pinTopPlaceholderLabel() {
        topPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
        let views = ["view": topPlaceholderLabel]
        let horizontalMetrics = ["left": leftInset, "right": rightInset]
        let horizontalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-left-[view]-right-|",
            options: [],
            metrics: horizontalMetrics,
            views: views
        )
        let verticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[view]",
            options: [],
            metrics: [:],
            views: views
        )
        
        NSLayoutConstraint.activate(horizontalConstraints)
        NSLayoutConstraint.activate(verticalConstraints)
    }
    
    // MARK: - Errors
    
    func showError(error: String) {
        showingError = true
        topPlaceholderLabel.text = error
        updateTopPlaceholderAppearance()
        setNeedsDisplay()
        setNeedsLayout()
    }
    
    func clearError() {
        showingError = false
        topPlaceholderLabel.text = placeholder
        updateTopPlaceholderAppearance()
        setNeedsDisplay()
        setNeedsLayout()
    }
    
}
