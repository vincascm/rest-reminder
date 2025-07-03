import SwiftUI
import AppKit

struct ReminderView: View {
    @State private var countdown: Int
    let width: CGFloat
    let height: CGFloat
    let initialCountdown: Int // Make it a constant property
    let closeAction: () -> Void
    
    @State private var backgroundColor: Color
    @State private var textColor: Color
    @State private var progressValue: Double = 1.0 // 1.0 for 100%, 0.0 for 0%

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(width: CGFloat, height: CGFloat, initialCountdown: Int, closeAction: @escaping () -> Void) {
        self.width = width
        self.height = height
        self.closeAction = closeAction
        self.initialCountdown = initialCountdown // Assign to the new property
        self._countdown = State(initialValue: initialCountdown)
        
        let randomRed = Double.random(in: 0...1)
        let randomGreen = Double.random(in: 0...1)
        let randomBlue = Double.random(in: 0...1)
        let newBackgroundColor = Color(red: randomRed, green: randomGreen, blue: randomBlue)

        let nsColor = NSColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        
        let newTextColor: Color
        if let brightness = nsColor.usingColorSpace(.genericRGB)?.brightnessComponent, brightness < 0.5 {
            newTextColor = .white
        } else {
            newTextColor = .black
        }
        
        self._backgroundColor = State(initialValue: newBackgroundColor)
        self._textColor = State(initialValue: newTextColor)
    }
    
    var body: some View {
        VStack {
            Spacer()
            Text("Time to take a break!")
                .font(.system(size: 60, weight: .bold))
                .foregroundColor(textColor)
            
            ProgressView(value: progressValue) // Progress bar
                .progressViewStyle(LinearProgressViewStyle(tint: textColor))
                .padding(.horizontal, 350) // Increased horizontal padding to make it shorter
                .scaleEffect(x: 1, y: 4, anchor: .center) // Make it thicker
                .padding(.bottom, 20) // Space between progress bar and text

            Text("Window will close in: \(countdown)s")
                .font(.title)
                .padding()
                .foregroundColor(textColor)
            
            Spacer()
            
            Button(action: closeAction) {
                Text("Dismiss")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 15)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(25)
                    .foregroundColor(textColor)
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
        }
        .onReceive(timer) { _ in
            if countdown > 0 {
                countdown -= 1
                progressValue = Double(countdown) / Double(initialCountdown) // Update progress based on initialCountdown
            } else {
                closeAction()
            }
        }
        .frame(width: width, height: height)
        .background(backgroundColor)
        .cornerRadius(10)
        .edgesIgnoringSafeArea(.all)
    }
}