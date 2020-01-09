import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    router.get { req in
        return "DungeonChat"
    }

    let userController = UserController()
    try userController.boot(router: router)
    
    let campaignController = CampaignController()
    try campaignController.boot(router: router)
}
