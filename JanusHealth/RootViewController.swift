//
//  RootViewController.swift
//  JanusHealth
//
//  Created by bayers on 11/17/18.
//  Copyright © 2018 bayers. All rights reserved.
//

import UIKit
import ResearchKit
import CareKit


class RootViewController: UITabBarController {
    // MARK: Properties
    
//    fileprivate let sampleData: SampleData
    
    // links to careplan store created in CarePlanStoreManager
    fileprivate let carePlanStoreManager = CarePlanStoreManager.sharedCarePlanStoreManager
    
    // Pulls activities created in the CarePlanData
    fileprivate let carePlanData: CarePlanData
    
    fileprivate var careContentsViewController: OCKCareContentsViewController!
    
//    fileprivate var insightsViewController: OCKInsightsViewController!
    
//    fileprivate var connectViewController: OCKConnectViewController!
    
//    fileprivate var watchManager: WatchConnectivityManager?
    
    
    // MARK: Initialization
    
    required init?(coder aDecoder: NSCoder) {
//        sampleData = SampleData(carePlanStore: storeManager.store)
        
        carePlanData = CarePlanData(carePlanStore: carePlanStoreManager.store)
        
        super.init(coder: aDecoder)
        careContentsViewController = createCareContentsViewController()
//        insightsViewController = createInsightsViewController()
//        connectViewController = createConnectViewController()
        
        self.viewControllers = [
            UINavigationController(rootViewController: careContentsViewController),
//            UINavigationController(rootViewController: insightsViewController),
//            UINavigationController(rootViewController: connectViewController)
        ]
        
        careContentsViewController.delegate = self
//        watchManager = WatchConnectivityManager(withStore: storeManager.store)
//        let glyphType = Glyph.glyphType(rawValue: careContentsViewController.glyphType.rawValue)
//
        // Default the default glyph tint color
        
//        var glyphTintColor = OCKGlyph.defaultColor(for: careContentsViewController.glyphType)
//        if (careContentsViewController.glyphTintColor != nil) {
//            glyphTintColor = careContentsViewController.glyphTintColor
//        }
        
        // Create color component array
//        let glyphTintColorComponents = glyphTintColor.cgColor.components
//        let glyphTintColorArray = [glyphTintColorComponents![0], glyphTintColorComponents![1], glyphTintColorComponents![2], glyphTintColorComponents![3]]
//        watchManager?.glyphType = Glyph.imageNameForGlyphType(glyphType: glyphType!)
//        watchManager?.glyphTintColor = glyphTintColorArray
        
        // Set the custom image name if the glyphType is custom
//        if (careContentsViewController.glyphType == .custom) {
//            let glyphImageName = careContentsViewController.customGlyphImageName
//            if (glyphImageName != "") {
//                watchManager?.glyphImageName = glyphImageName
//            }
    
//            watchManager?.sendGlyphType(glyphType: Glyph.imageNameForGlyphType(glyphType: glyphType!),
//            glyphTintColor;: glyphTintColorArray,
//                                        glyphImageName: glyphImageName)
//        } else {
//            watchManager?.sendGlyphType(glyphType: Glyph.imageNameForGlyphType(glyphType: glyphType!), glyphTintColor: glyphTintColorArray)
//        }
    }

    // MARK: Convenience
    
    
    
    fileprivate func createCareContentsViewController() -> OCKCareContentsViewController {
        let viewController = OCKCareContentsViewController(carePlanStore: carePlanStoreManager.store)
        viewController.title = NSLocalizedString("Care Contents", comment: "")
        viewController.tabBarItem = UITabBarItem(title: viewController.title, image: UIImage(named:"carecard"), selectedImage: UIImage(named: "carecard-filled"))
        viewController.delegate = self;
        return viewController
        
    }
    
}


extension RootViewController: OCKCareContentsViewControllerDelegate {
    
    func careContentsViewController(_ viewController: OCKCareContentsViewController, didSelectRowWithAssessmentEvent assessmentEvent: OCKCarePlanEvent) {
        // Lookup the assessment the row represents.
        guard let activityType = ActivityType(rawValue: assessmentEvent.activity.identifier) else { return }
        guard let sampleAssessment = carePlanData.carePlanStore.activityWithType(activityType) as? Assessment else { return }
        
        /*
         Check if we should show a task for the selected assessment event
         based on its state.
         */
        guard assessmentEvent.state == .initial ||
            assessmentEvent.state == .notCompleted ||
            (assessmentEvent.state == .completed && assessmentEvent.activity.resultResettable) else { return }
        
        // Show an `ORKTaskViewController` for the assessment's task.
        let taskViewController = ORKTaskViewController(task: sampleAssessment.task(), taskRun: nil)
        taskViewController.delegate = self
        
        present(taskViewController, animated: true, completion: nil)
    }
}

extension RootViewController: ORKTaskViewControllerDelegate {
    
    /// Called with then user completes a presented `ORKTaskViewController`.
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        defer {
            dismiss(animated: true, completion: nil)
        }
        
        // Make sure the reason the task controller finished is that it was completed.
        guard reason == .completed else { return }
        
        // Determine the event that was completed and the `SampleAssessment` it represents.
        guard let event = careContentsViewController.lastSelectedEvent,
            let activityType = ActivityType(rawValue: event.activity.identifier),
            let sampleAssessment = carePlanData.activityWithType(activityType) as? Assessment else { return }
        
        // Build an `OCKCarePlanEventResult` that can be saved into the `OCKCarePlanStore`.
        let carePlanResult = sampleAssessment.buildResultForCarePlanEvent(event, taskResult: taskViewController.result)
        
        // Check assessment can be associated with a HealthKit sample.
        if let healthSampleBuilder = sampleAssessment as? HealthSampleBuilder {
            // Build the sample to save in the HealthKit store.
            let sample = healthSampleBuilder.buildSampleWithTaskResult(taskViewController.result)
            let sampleTypes: Set<HKSampleType> = [sample.sampleType]
            
            // Requst authorization to store the HealthKit sample.
            let healthStore = HKHealthStore()
            healthStore.requestAuthorization(toShare: sampleTypes, read: sampleTypes, completion: { success, _ in
                // Check if authorization was granted.
                if !success {
                    /*
                     Fall back to saving the simple `OCKCarePlanEventResult`
                     in the `OCKCarePlanStore`.
                     */
                    self.completeEvent(event, inStore: self.storeManager.store, withResult: carePlanResult)
                    return
                }
                
                // Save the HealthKit sample in the HealthKit store.
                healthStore.save(sample, withCompletion: { success, _ in
                    if success {
                        /*
                         The sample was saved to the HealthKit store. Use it
                         to create an `OCKCarePlanEventResult` and save that
                         to the `OCKCarePlanStore`.
                         */
                        let healthKitAssociatedResult = OCKCarePlanEventResult(
                            quantitySample: sample,
                            quantityStringFormatter: nil,
                            display: healthSampleBuilder.unit,
                            displayUnitStringKey: healthSampleBuilder.localizedUnitForSample(sample),
                            userInfo: nil
                        )
                        
                        self.completeEvent(event, inStore: self.storeManager.store, withResult: healthKitAssociatedResult)
                    }
                    else {
                        /*
                         Fall back to saving the simple `OCKCarePlanEventResult`
                         in the `OCKCarePlanStore`.
                         */
                        self.completeEvent(event, inStore: self.storeManager.store, withResult: carePlanResult)
                    }
                    
                })
            })
        }
        else {
            // Update the event with the result.
            completeEvent(event, inStore: carePlanStoreManager.store, withResult: carePlanResult)
        }
    }
    
    // MARK: Convenience
    
    fileprivate func completeEvent(_ event: OCKCarePlanEvent, inStore store: OCKCarePlanStore, withResult result: OCKCarePlanEventResult) {
        store.update(event, with: result, state: .completed) { success, _, error in
            if !success {
                print(error!.localizedDescription)
            }
        }
    }
}
