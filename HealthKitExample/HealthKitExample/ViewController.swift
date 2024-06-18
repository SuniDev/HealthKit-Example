//
//  ViewController.swift
//  HealthKitExample
//
//  Created by suni on 6/18/24.
//

import UIKit
import HealthKit

class ViewController: UIViewController {
    
    @IBOutlet weak var stepCountLabel: UILabel!
    
    @IBAction func getStepCountTap(_ sender: Any) {
        requestHealthKitAuthorization() { [weak self] (result, error) in
            self?.getStepCountData()
        }
    }
    
    let healthStore = HKHealthStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
    }
    
    /// 건강 데이터 권한 요청 함수
    func requestHealthKitAuthorization(completion: @escaping (Bool, String?) -> ()) {
        guard HKHealthStore.isHealthDataAvailable() else {
            // HealthKit 사용 불가능
            return
        }
        guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            return
        }
        
        // 읽기 권한을 요청할 데이터 타입 설정
        let readDataTypes: Set<HKObjectType> = [stepCountType]
        
        // 권한 요청
        healthStore.requestAuthorization(toShare: [], read: readDataTypes) { success, error in
            if success {
                print("HealthKit authorization success")
                completion(true, nil)
            } else {
                if let error {
                    print("HealthKit authorization failed: \(error.localizedDescription)")
                    completion(false, error.localizedDescription)
                }
            }
        }
    }
    
    /// 걸음 수 가져오기
    func getStepCountData() {
        guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            return
        }
        
        // 걸음 수를 카운트할 날짜 설정 - 오늘로 설정
        let now = Date()
        let startDate = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)

        // 걸음 수 요청
        let query = HKStatisticsQuery(quantityType: stepCountType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, _ in
            guard let result, let sum = result.sumQuantity() else {
                self?.updateCountLabel("설정 창에서 권한 허용 필요")
                return
            }
            
            let count = sum.doubleValue(for: HKUnit.count())
            self?.updateCountLabel("\(Int(count))")
        }
        
        healthStore.execute(query)
    }
    
    func updateCountLabel(_ text: String) {
        DispatchQueue.main.async {
            self.stepCountLabel.text = text
        }
    }
}
