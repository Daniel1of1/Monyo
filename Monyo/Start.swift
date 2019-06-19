/// Wrapper around `Model.update` to put it in the form that `Program` expects
func update(msg: Msg, model: Model) -> (Model, Command<Msg>?) {
    var newModel = model
    let command = newModel.update(message: msg)
    return (newModel, command)
}

#if DEBUG
/// Implementations for any nondeterministic work the application has to do
/// Any interaction with the outside world is also here.
var Commands = CommandProvider.default
#else
let Commands = CommandProvider.default
#endif

/// The current `Program` representing the state of the entire application
let Current = Program(model: Model.initial, update: update, start: Commands.loadFromPersistence().map(Msg.loadedFromPersistence))
