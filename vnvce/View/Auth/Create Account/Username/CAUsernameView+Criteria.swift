
import SwiftUI

extension CAUsernameView {
    @ViewBuilder
    public var Criteria: some View {
        VStack(alignment: .leading, spacing: 6){
            Text("Username criteria:")
                .font(.system(size: 12, weight: .medium, design: .default))
                .foregroundColor(.secondary)
            VStack(alignment: .leading, spacing:3){
                let criteria = """
                • Must be at least 3 and at most 20 characters long.
                • It must contain at least 2 letters.
                • Only numbers, letters, \"_\" and \".\" can be used.
                • Only English letters can be used.
                • It cannot start with \"_\" and \".\"
                • \" _ \" and \" . \" cannot come together.
                """
                
                Group{
                    Text(criteria)
//                    Text("• Must be at least 3 and at most 20 characters long.")
//                    Text("• It must contain at least 2 letters.")
//                    Text("• Only numbers, letters, \"_\" and \".\" can be used.")
//                    Text("• Only English letters can be used.")
//                    Text("• It cannot start with \"_\" and \".\"")
//                    Text("• \" _ \" and \" . \" cannot come together.")
                }
                .font(.system(size: 10, weight: .regular, design: .default))
                .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
