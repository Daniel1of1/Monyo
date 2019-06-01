import Foundation

class Program<MODEL,MSG> {
    // TODO: move into special debug program class maybe
    var history = [(message: MSG, model: MODEL, command: Command<MSG>?)]()
    
    private let modelUpdateQueue = DispatchQueue(label: "Program.model.update", qos: .userInitiated)
    private(set) var model: MODEL
    private var update: (MSG, MODEL) -> (MODEL,Command<MSG>?)
    var viewUpdate: ((MODEL) -> Void)? // could also just be a delegate

    
    func update(message: MSG) {
        modelUpdateQueue.async { [unowned self] in
            let (newModel, command) = self.update(message,self.model)
            self.history.append((message,newModel,command))
            self.model = newModel
            command?.run { [unowned self] in
                self.update(message: $0)
            }
            DispatchQueue.main.async {
                self.viewUpdate?(newModel)
            }
        }
    }
    
    func run(command: Command<MSG>) {
        command.run { [unowned self] msg in
            self.update(message: msg)
        }
    }
    
    func reset(model: MODEL) {
        DispatchQueue.main.async {
            self.model = model
            self.viewUpdate?(model)
        }
    }

    init(model: MODEL, update:@escaping (MSG, MODEL) -> (MODEL,Command<MSG>?), start: Command<MSG>?) {
        self.model = model
        self.update = update
        start.map(self.run)
    }
    
}
