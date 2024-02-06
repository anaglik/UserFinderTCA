import Foundation
import CoreData

@objc(UserEntity)
public final class UserEntity: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserEntity> {
            return NSFetchRequest<UserEntity>(entityName: "UserEntity")
        }

        @NSManaged public var id: Int64
        @NSManaged public var login: String
        @NSManaged public var name: String
        @NSManaged public var publicRepos: Int16
        @NSManaged public var followers: Int16
        @NSManaged public var avatarURL: URL
}

extension UserEntity: Identifiable { }
