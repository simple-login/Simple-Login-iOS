//
//  HowItWorksView.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 26/02/2022.
//

import SwiftUI

struct HowItWorksView: View {
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                VStack {
                    Text("Shield your inbox with email aliases")
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }

                StepView(step: .one)
                StepView(step: .two)
                StepView(step: .three)
            }
            .padding(.top, 20)
            .padding()
        }
        .navigationTitle("How it works")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct StepView: View {
    let step: HowItWorkStep

    var body: some View {
        VStack {
            Text(step.title)
                .font(.title3)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            Image(step.imageName)
                .resizable()
                .scaledToFill()
            Text(step.description)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color(.systemGray5), radius: 10, x: 0, y: 0)
    }
}
