//
//  ViewController.swift
//  KVO&KVC&Notifications
//
//  Created by Anatoly Ryavkin on 31.03.2020.
//  Copyright © 2020 AnatolyRyavkin. All rights reserved.
//

import UIKit

class SomeClass: NSObject{

    @ objc dynamic var num: Int = 0

    override func setValue(_ value: Any?, forKey key: String) {
        if key == "num"{
            guard let valueSet = value as? Int else { return super.setValue(value, forKey: key) }
            super.setValue(valueSet + 100, forKey: key)
            return
        }
        super.setValue(value, forKey: key)
    }

    override func didChangeValue(forKey key: String) {
        if key == "num"{
            print("NUM chanded")
        }
    }
}

class ViewController: UIViewController {

    @objc dynamic let someClass = SomeClass()
    var nameObservation: NSKeyValueObservation?
    var newValue: Int = 2
    var oldValue: Int = 1
    var context: Int = 3
    var contextIn: Int = 10
    var o: Void!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        someClass.addObserver(self, forKeyPath: "num", options: [.new, .old], context: &context)
        someClass.addObserver(self, forKeyPath: "num", options: [.new, .old], context: &contextIn)
        self.observeValue(forKeyPath: "someClass.num", of: self, change: [.newKey : newValue, .oldKey : oldValue], context: &context)
        self.observeValue(forKeyPath: "someClass.num", of: self, change: [.newKey : newValue, .oldKey : oldValue], context: &contextIn)
        print("Past notify requqrded someClass.num = ",someClass.num)
        print("NewValue someClass.num = ",someClass.num)
        print("NewValue context = ",context)

/*              Vriant shared !!!!

        nameObservation = observe(\.someClass.num , options: [.new, .old]) { (class, value) in
            guard let updatedValue = value.newValue else{ return }
            print("new value = ",updatedValue)
            guard let oldValue = value.oldValue else{ return }
            print("old value = ",oldValue)
        }
*/
    }

    // customization setValue

    override func setValue(_ value: Any?, forKey key: String) {
        if key == "contextIn"{
            guard let valueSet = value as? Int else { return super.setValue(value, forKey: key) }
            self.contextIn = valueSet
            return
        }
        if key == "someClass.num"{
            guard let valueSet = value as? Int else { return super.setValue(value, forKey: key) }
            someClass.num = valueSet + 10000000000
            return
        }
        super.setValue(value, forKey: key)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print("observe start!")
        guard let oldValue = change?[.oldKey] else{ return }
        print("old value = ",oldValue)
        guard let newValue = change?[.newKey] else{ return }
        print("new value = ",newValue)
        guard let cont: UnsafeMutableRawPointer = UnsafeMutableRawPointer(context) else{ return }
        let oldValueContext = cont.load(as: Int.self)
        var newValueContext = oldValueContext + (newValue as! Int)
        _ = withUnsafeMutablePointer(to: &newValueContext) {
            cont.copyMemory(from: $0, byteCount: 8) // write from one amount memory to another !!! count bytes at begin address
        }
        print("change context from : \(oldValueContext) to addition context : ",cont.load(as: Int.self))
        if let obj = object as? SomeClass{
            print("obj.value(forKey: keyPath!)! = ",obj.value(forKey: keyPath!)!)
            sleep(2)
            //obj.setValue(9, forKey: keyPath!)   // - RUN LOOP COUNT ->∞
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        sleep(10)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("1 - change !")
        sleep(1)
        self.willChangeValue(forKey: "someClass.num")
        someClass.num = 100
        self.someClass.setValue(100 , forKey: "num")
        someClass.setValue(333 , forKey: "num")
        //setValue(333 , forKey: ".someClass.num")
        someClass.didChangeValue(forKey: "num")
        //sleep(1)
        print("NewValue someClass.num = ",someClass.num)
        print("NewValue context = ",context)
        print("NewValue contextIn = ",contextIn)
        sleep(2)
        print("begin change contextIn")
        print("contextIn begining = ",contextIn)
        sleep(2)
        setValue(1000, forKey: "contextIn")
        sleep(2)
        print("contextIn  ending = ",contextIn)
        self.setValue(7777777, forKey: "someClass.num")
        print(" someClass.num = ",someClass.num)
    }

}


//    var nameObservation: NSKeyValueObservation?
//    func obser(){
//        nameObservation = observe(\SomeClass.num , options: [.new, .old]) { (class, value) in
//            guard let updatedValue = value.newValue else{ return }
//            print("new value = ",updatedValue)
//            guard let oldValue = value.oldValue else{ return }
//            print("old value = ",oldValue)
//        }
//    }


