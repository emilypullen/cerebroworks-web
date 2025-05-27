//
//  ExportEntriesButton.swift
//  Blackberry
//
//  Created by Emily Pullen on 2025-05-03.
//

import SwiftUI
import CoreData
import UIKit
import Foundation

struct ExportEntriesButton: View {
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("isProUser") private var isProUser: Bool = false

    var body: some View {
        Group {
            if isProUser {
                Button(action: {
                    exportEntriesToPDF()
                }) {
                    Text("Export Jobs & Rates")
                        .font(AppFonts.body)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.accent)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            } else {
                Text("🔒 Export is a Pro feature")
                    .font(AppFonts.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private func exportEntriesToPDF() {
        let entries = fetchEntries()

        guard !entries.isEmpty else {
            print("⚠️ No entries to export.")
            return
        }

        let pdfFileName = getDocumentsDirectory().appendingPathComponent("EntriesExport.pdf")

        let format = UIGraphicsPDFRendererFormat()
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792), format: format)

        let data = renderer.pdfData { context in
            context.beginPage()

            let title = "Work Log Entries"
            let titleFont = UIFont.boldSystemFont(ofSize: 22)
            let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont]
            title.draw(at: CGPoint(x: 40, y: 40), withAttributes: titleAttributes)

            var y = 80

            for entry in entries {
                let jobName = entry.job ?? "Unknown Job"
                let date = DateFormatter.localizedString(from: entry.date ?? Date(), dateStyle: .medium, timeStyle: .none)
                let tasks = entry.tasks ?? "-"
                let notes = entry.notes ?? "-"

                let block = """
                \(jobName) on \(date)
                Tasks: \(tasks)
                Notes: \(notes)

                """

                let paragraph = NSAttributedString(string: block, attributes: [.font: UIFont.systemFont(ofSize: 14)])
                paragraph.draw(in: CGRect(x: 40, y: CGFloat(y), width: 520, height: 1000))
                y += 100

                if y > 700 {
                    context.beginPage()
                    y = 40
                }
            }
        }

        do {
            try data.write(to: pdfFileName)
            print("✅ PDF saved at: \(pdfFileName.path)")
            sharePDF(fileURL: pdfFileName)
        } catch {
            print("❌ Failed to save PDF: \(error.localizedDescription)")
        }
    }

    private func sharePDF(fileURL: URL) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)

            if let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
               let rootVC = windowScene.windows
                .first(where: { $0.isKeyWindow })?.rootViewController {
                
                rootVC.presentedViewController?.dismiss(animated: false) {
                    rootVC.present(activityVC, animated: true)
                }
            } else {
                print("❌ Could not find valid rootViewController.")
            }
        }
    }

    private func fetchEntries() -> [EntryData] {
        let request = NSFetchRequest<EntryData>(entityName: "EntryData")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \EntryData.date, ascending: false)]

        do {
            return try viewContext.fetch(request)
        } catch {
            print("❌ Failed to fetch entries: \(error.localizedDescription)")
            return []
        }
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
