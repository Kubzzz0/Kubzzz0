import SwiftUI

struct UnitFormView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    var unit: UnitEntity?

    @State private var name: String = ""
    @State private var code: String = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                TextField("Code", text: $code)
            }
            .navigationTitle(unit == nil ? "New Unit" : "Edit Unit")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: { dismiss() })
                }
            }
        }
        .onAppear {
            name = unit?.name ?? ""
            code = unit?.code ?? ""
        }
    }

    private func save() {
        let target = unit ?? UnitEntity(context: context)
        target.name = name
        target.code = code
        target.id = unit?.id ?? UUID()
        try? context.save()
        dismiss()
    }
}
