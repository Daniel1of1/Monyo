import Dispatch

// TODO: move into `Cont` lib
extension Command {
    /// convert [Command<T>] to Commnad<[T]> representing all of the
    /// values returned from each individual command's run method.
    /// - Note: this will only call the result continuation once when all values from the input continuations have been acquired.
    static func combine<T>(_ commands:[Command<T>]) -> Command<[T]> {
        return Command { cont in
            let serialQueue = DispatchQueue.init(label: "dev.haight.command.combine")
            var values = [T]()
            for command in commands {
                command.run { a in
                    serialQueue.async {
                        values.append(a)
                        if values.count == commands.count {
                            cont(values)
                        }
                    }
                }
            }
        }
    }
}
