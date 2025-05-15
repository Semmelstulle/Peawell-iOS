import SwiftUI

struct LogSectionsView: View {
    @AppStorage("settingShowMoodSection") private var settingShowMoodSection = true
    @AppStorage("settingShowMedicationSection") private var settingShowMedicationSection = true
    
    var body: some View {
        HStack(spacing: 16) {
            if settingShowMoodSection {
                NavigationLink(destination: MoodLogView()) {
                    TileView(
                        tileTitle: NSLocalizedString("module.moods", comment: "just says mood diary"),
                        tileImage: "moodGood", // Asset name
                        tileGradient: LinearGradient(
                            colors: [.gray, .white],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                }
            }
            if settingShowMedicationSection {
                NavigationLink(destination: MedLogView()) {
                    TileView(
                        tileTitle: NSLocalizedString("module.med", comment: "just says medication log"),
                        tileImage: "Round pill", // Asset name
                        tileGradient: LinearGradient(
                            colors: [.orange, .yellow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                }
            }
        }
        .padding()
    }
}

struct TileView: View {
    let tileTitle: String
    let tileImage: String
    let tileGradient: LinearGradient
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(tileGradient)
                .shadow(radius: 2)
            VStack {
                HStack {
                    Image(tileImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .padding(5)
                    Spacer()
                }
                Spacer()
            }
            // Huge, bottom-right, clipped text
            GeometryReader { geo in
                Text(tileTitle)
                    .lineLimit(1)
                    .font(.system(size: geo.size.height * 0.3, weight: .bold))
                    .foregroundColor(.black.opacity(0.2))
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .bottomTrailing)
                    .offset(x: geo.size.width * 0.2, y: geo.size.height * 0)
                    .clipped()
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            // Chevron overlay
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.title)
                        .foregroundColor(.white.opacity(0.5))
                        .padding()
                }
                Spacer()
            }
        }
        .frame(height: 120)
    }
}


struct LogSectionsView_Previews: PreviewProvider {
    static var previews: some View {
        LogSectionsView()
    }
}
