//
//  OnboardingViewModel.swift
//  OnboardingProject
//
//  Created by Muhammet Guler on 18.01.2025.
//

import Foundation

import Foundation

class OnboardingViewModel {
    // Slides Data
    private(set) var slides: [OnboardingSlide] = [
        OnboardingSlide(image: "onboardingBackground1", title: "DOKUN DENE, MOBİLDEN EVE", description: "Mağazada beğendiğin ürünün bedeni yok mu? Barkodu okut istediğin bedeni sipariş ver."),
        OnboardingSlide(image: "onboardingBackground3", title: "ÜYE OL, FIRSATLARI KAÇIRMA", description: "Sende şimdi bize katıl, 375 TL'ye 125 TL alışveriş indirimi ve ilk siparişe özel ücretsiz kargo fırsatını kaçırma.")
    ]
    
    // Current Slide Index
    private(set) var currentSlideIndex: Int = 0

    // Observable Closure for Page Control Update
    var onPageChanged: ((Int) -> Void)?

    // Get slide count
    func getSlideCount() -> Int {
        return slides.count
    }

    // Get slide for a specific index
    func getSlide(at index: Int) -> OnboardingSlide {
        return slides[index]
    }

    // Update current page and notify observers
    func updateCurrentPage(to index: Int) {
        currentSlideIndex = index
        onPageChanged?(index)
    }
}
