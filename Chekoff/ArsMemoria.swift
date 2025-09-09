import SwiftUI

struct ArsMemoriaView: View {
    var body: some View {
        NavigationView {
            List {
                // First test link
                NavigationLink("Digit Span Test") {
                    DigitSpanTestView()
                }
                
                NavigationLink("Letter Span Test") {
                    LetterSpanTestView()
                }
                
                NavigationLink("Free Recall") {
                    FreeRecallTestView()
                }

                // Later you can add more tests here:
                // NavigationLink("Word List Test") { WordListView() }
                // NavigationLink("Paired Associates") { PairedAssociatesView() }
            }
            .navigationTitle("Ars Memoria")
        }
    }
}
