import Foundation

extension Calendar {
    func monthString(_ month: Int) -> String {
        switch month {
        case 1:
            return "January"
        case 2:
            return "February"
        case 3:
            return "March"
        case 4:
            return "April"
        case 5:
            return "May"
        case 6:
            return "June"
        case 7:
            return "July"
        case 8:
            return "August"
        case 9:
            return "September"
        case 10:
            return "October"
        case 11:
            return "November"
        case 12:
            return "December"
        default:
            return ""
        }
    }
}

extension Date {
    func isBefore(_ date: Date) -> Bool {
        return self.compare(date) == .orderedAscending
    }
}

extension UIView {
    func roundAllCorners() {
        roundCorners([.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner])
    }

    func roundCorners(_ corners: CACornerMask) {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.bounds.width / 2
        self.layer.maskedCorners = corners
    }
}
