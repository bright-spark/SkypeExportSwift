//
//  SkypeSQLiteDao.swift
//  SkypeExport
//
//  Created by Aleksandar Kovacevic on 2/12/15.
//  Copyright (c) 2015 Aleksandar Kovacevic. All rights reserved.
//

import Foundation
import SQLite

class SkypeDB {
    var db: Database;

    init(pathToDB dbPath: String, isBusyHandler: (Int -> Bool)) {
        
        self.db = Database(dbPath, readonly: true)
        self.db.busy(isBusyHandler)
    }
    
    func getSkypeContacts(fromSkypeUser SkypeUser:String) -> [String] {
        let contacts=db["Contacts"]
        //select skypename from Contacts where type=1;
        let skypename = Expression<String?>("skypename")
        let type = Expression<Int?>("type")
        var result:[String]=[]
        let query = contacts.select(skypename)           // SELECT "email" FROM "users"
            .filter(type == 1)     // WHERE "name" IS NOT NULL
            .order(skypename.asc) // ORDER BY "email" DESC, "name"
        
        for row in query {
            result += ["\(row[skypename]!)"]
            // id: 1, name: Optional("Alice"), email: alice@mac.com
        }
        
        return result;
        
    }
    
    func getMessages(fromSkypeUser skypeUser:String, withDialogPartner diaPartner: String) -> [(from:String, to:String, timestamp:String, message:String)] {
        println("input: skypeUser - \(skypeUser) , dialogPartner - \(diaPartner)")
        let messages=db["Messages"]
        let author = Expression<String?>("author")
        let dialog_partner = Expression<String?>("dialog_partner")
        let timeInEpochs = Expression<Int?>("timestamp")
        let body = Expression<String?>("body_xml")
        var result:[(from:String, to:String, timestamp:String, message:String)]=[]
        let query = messages.select(author,dialog_partner,timeInEpochs,body)           // SELECT "email" FROM "users"
            .filter(dialog_partner == diaPartner)     // WHERE "name" IS NOT NULL
            .order(timeInEpochs.desc) // ORDER BY "email" DESC, "name"
        
        for message in query {
                result += [(from: "\(message[author]!)", to: "\(message[dialog_partner]!)", timestamp: "\(message[timeInEpochs]!)", message: "\(message[body]!)")]
            // id: 1, name: Optional("Alice"), email: alice@mac.com
        }
        
        return result;
    }
    
    func getContacts(ofSkypeUser skypeUser:String) -> [(name:String, contactName:String, phone:String)]{
        var dummy:[(name:String, contactName:String, phone:String)] = []
        dummy += [(name:"Sandra", contactName:"sandrestina", phone:"1234567")]
        return dummy;
    }
/*select author,dialog_partner,datum as datetime(timestamp, 'unixepoch', 'localtime'),body_xml from Messages where dialog_partner = '$2';*/

/*
let messages=db["Messages"]
let users = db["users"]
let id = Expression<Int>("id")
let name = Expression<String?>("name")
let email = Expression<String>("email")

db.create(table: users) { t in
    t.column(id, primaryKey: true)
    t.column(name)
    t.column(email, unique: true)
}
// CREATE TABLE "users" (
//     "id" INTEGER PRIMARY KEY NOT NULL,
//     "name" TEXT,
//     "email" TEXT NOT NULL UNIQUE
// )

var alice: Query?
if let insertId = users.insert(name <- "Alice", email <- "alice@mac.com") {
    println("inserted id: \(insertId)")
    // inserted id: 1
    alice = users.filter(id == insertId)
}
// INSERT INTO "users" ("name", "email") VALUES ('Alice', 'alice@mac.com')

for user in users {
    println("id: \(user[id]), name: \(user[name]), email: \(user[email])")
    // id: 1, name: Optional("Alice"), email: alice@mac.com
}
// SELECT * FROM "users"

alice?.update(email <- replace(email, "mac.com", "me.com"))?
// UPDATE "users" SET "email" = replace("email", 'mac.com', 'me.com')
// WHERE ("id" = 1)

alice?.delete()?
// DELETE FROM "users" WHERE ("id" = 1)

users.count
// SELECT count(*) FROM "users"
*/
}