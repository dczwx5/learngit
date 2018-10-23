class CloseContextHandler extends HandlerBase{

    public init(data?: any) : CloseContextHandler{
        return this;
    }

    protected execute() {
        let evt = ContextEvent.create(ContextEvent, ContextEvent.CLOSE_CONTEXT);
        this.dispatchContextEvent(evt);
        ContextEvent.release(evt);
        this.closeAsync();
    }

    protected clear() {
    }
}
window["CloseContextHandler"] = CloseContextHandler;