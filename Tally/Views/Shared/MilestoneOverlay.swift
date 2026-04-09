//
//  MilestoneService.swift
//  Tally
//
//  Created by David Castaneda on 3/29/26.
//

import SwiftUI

struct MilestoneOverlay: View {
    let milestone: MilestoneDefinition?
    @Binding var isPresented: Bool

    @State private var hasAppeared = false
    @State private var dismissTask: Task<Void, Never>?

    var body: some View {
        Group {
            if isPresented, let milestone {
                ZStack {
                    Color.black
                        .opacity(hasAppeared ? 0.72 : 0.0)

                    VStack(spacing: 20) {
                        Spacer()

                        animationView(for: milestone)
                            .frame(maxWidth: .infinity)
                            .frame(height: 240)

                        VStack(spacing: 10) {
                            Image(systemName: iconName(for: milestone.animationType))
                                .font(.system(size: 42, weight: .bold))
                                .symbolEffect(.bounce, value: hasAppeared)

                            Text(milestone.name)
                                .font(.system(size: 34, weight: .heavy, design: .rounded))

                            Text("Streak milestone reached")
                                .font(.headline)
                                .foregroundStyle(.secondary)

                            Text("\(milestone.threshold) day\(milestone.threshold == 1 ? "" : "s")")
                                .font(.subheadline.weight(.semibold))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(.ultraThinMaterial, in: Capsule())
                        }
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .scaleEffect(hasAppeared ? 1.0 : 0.92)
                        .opacity(hasAppeared ? 1.0 : 0.0)

                        Spacer()

                        Text("Tap anywhere to dismiss")
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.75))
                            .padding(.bottom, 36)
                            .opacity(hasAppeared ? 1.0 : 0.0)
                    }
                }
                .ignoresSafeArea()
                .transition(.opacity)
                .zIndex(999)
                .animation(.easeInOut(duration: 0.25), value: isPresented)
                .animation(.easeInOut(duration: 0.25), value: hasAppeared)
                .onAppear {
                    showOverlay()
                }
                .onDisappear {
                    dismissTask?.cancel()
                    dismissTask = nil
                }
                .onTapGesture {
                    dismissOverlay()
                }
            }
        }
    }

    @ViewBuilder
    private func animationView(for milestone: MilestoneDefinition) -> some View {
        switch milestone.animationType {
        case .particleBurst:
            ParticleBurstView()
        case .flame:
            FlameAnimationView()
        case .lightning:
            LightningEffectView()
        case .supernova:
            SupernovaView()
        case .legendBadge:
            Image(systemName: "crown.fill")
                .font(.system(size: 84, weight: .bold))
                .foregroundStyle(.yellow)
                .symbolEffect(.bounce, value: hasAppeared)
        }
    }

    private func iconName(for animationType: AnimationType) -> String {
        switch animationType {
        case .particleBurst:
            return "sparkles"
        case .flame:
            return "flame.fill"
        case .lightning:
            return "bolt.fill"
        case .supernova:
            return "sparkles.rectangle.stack.fill"
        case .legendBadge:
            return "crown.fill"
        }
    }

    private func showOverlay() {
        hasAppeared = true

        HapticManager.shared.playMilestone()

        dismissTask?.cancel()
        dismissTask = Task {
            try? await Task.sleep(for: .seconds(3))
            guard !Task.isCancelled else { return }

            await MainActor.run {
                dismissOverlay()
            }
        }
    }

    private func dismissOverlay() {
        dismissTask?.cancel()
        dismissTask = nil

        withAnimation(.easeInOut(duration: 0.22)) {
            hasAppeared = false
            isPresented = false
        }
    }
}