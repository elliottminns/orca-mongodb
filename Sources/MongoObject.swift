

/**
*  A protocol that allows documents to be described in an Object Orientated way.
*/
protocol MongoObject {

    func Document() throws -> MongoDocument
    func properties() -> DocumentData
}

extension MongoObject {

    /**
    - returns: Returns a MongoDocument initialized from the Schema.
    */
    func Document() throws -> MongoDocument {
        return try MongoDocument(withSchemaObject: self)
    }

    /**
    - returns: Returns each of the properties of class in the form of DocumentData ([String : AnyObject])
    */
    func properties() -> DocumentData {

        var children = DocumentData()

        for child in Mirror(reflecting: self).children {

            if let label = child.label {

                if label.characters[label.startIndex] != "_" {

                    if let value = child.value as? AnyObject {
                        children[label] = value
                    }
                }
            }
        }
        return children
    }
}
