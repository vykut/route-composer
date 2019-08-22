//
// Created by Eugene Kazaev on 08/02/2018.
//

import Foundation

enum WishListContext: Int {
    case favorites = 0
    case collections
}

struct WishListDataModel {

    static let data = [
        WishListContext.favorites: ["Gucci", "Dolce & Gabbana", "Anna Valentine", "Lacoste"],
        .collections: ["Shoes", "Dresses", "Hats"]
    ]

}
