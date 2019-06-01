
/// Wrapper around `Model.update` to put it in the form that `Program` expects
func update(msg: Msg, model: Model) -> (Model, Command<Msg>?) {
    var newModel = model
    let command = newModel.update(message: msg)
    return (newModel, command)
}

/// The current `Program` representing the state of the entire application
let Current = Program(model: Model.initial, update: update, start: Commands.loadFromPersistence().map(Msg.loadedFromPersistence))
