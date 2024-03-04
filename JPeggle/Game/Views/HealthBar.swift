import SwiftUI

struct HealthBar: View {
    private static let healthBarWidth = 100.0
    private static let healthBarHeight = 24.0
    private static let healthBarBorderWidth = 4.0
    private static let healthBarInnerWidth = healthBarWidth - 2 * healthBarBorderWidth
    private static let healthBarCornerRadius = 8.0

    let currentHealth: Double
    let maxHealth: Double

    var clampedHealth: Double {
        min(max(currentHealth, 0), maxHealth)
    }

    var healthPercentage: Double {
        clampedHealth / maxHealth
    }

    var body: some View {
        ZStack {
            HStack {
                RoundedRectangle(cornerRadius: Self.healthBarCornerRadius - Self.healthBarBorderWidth)
                    .fill(Color.red)
                    .frame(width: Self.healthBarInnerWidth * healthPercentage)
                    .padding(Self.healthBarBorderWidth)
            }
            .frame(width: Self.healthBarWidth, height: Self.healthBarHeight, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: Self.healthBarCornerRadius)
                    .strokeBorder(Color.black, lineWidth: Self.healthBarBorderWidth)
            )
            Text("\(Int(clampedHealth))")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
    }

}
