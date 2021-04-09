//
//  Router.swift
//  HW1
//
//  Created by Ilya Doroshkevitch on 05.04.2021.
//

import Foundation
import UIKit


class Router {

    func goTo(from: UIViewController, to: UIViewController) {
        let toViewController = to
        from.navigationController?.pushViewController(toViewController, animated: true)
    }


}
