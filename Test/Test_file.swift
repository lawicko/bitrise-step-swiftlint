extension Test {

    /// Failing example, this will generate an error if the .swiftlint.yml is used for linting
    func getURL() -> URL {
        let url = URL(string: "some.string")!
        return url
    }

    /// Failing example, this will generate a warning if the .swiftlint.yml is used for linting
    func getAnotherURL() -> URL?
    {
        let url = URL(string: "another.string")
        return url
    }

    /// Non-failing example
    func getURL() -> URL? {
        let url = URL(string: "some.string")
        return url
    }
}
