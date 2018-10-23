class LoadMediator extends ViewMediator{

    protected view: LoadingView;

    protected get viewClass():  new()=>LoadingView  {
        return LoadingView;
    }

    protected get openViewMsg(): new()=>VoyaMVC.IMsg  {
        return LoadMsg.OpenLoadingView;
    }

    protected get closeViewMsg(): new()=>VoyaMVC.IMsg  {
        return LoadMsg.CloseLoadingView;
    }

    private closeAfterComplete:boolean;
    private taskName:string;

    protected onViewOpen() {
        this.regTaskMsg();
    }
    protected onViewClose() {
        this.unregTaskMsg();
    }

    protected onOpenViewHandler(msg: LoadMsg.OpenLoadingView) {
        this.taskName = msg.body.taskName;
        this.closeAfterComplete = msg.body.closeAfterComplete;
        super.onOpenViewHandler(msg);
    }

    protected onCloseViewHandler(msg: LoadMsg.CloseLoadingView){
        super.onCloseViewHandler(msg);
        this.taskName = null;
    }

    private onTaskProgress(msg:LoadMsg.OnTaskProgress){
        if(this.view && this.view.isInited){
            let body = msg.body;
            if(body.taskName == this.taskName){
                this.view.setProgress(body.curr, body.total);
            }
        }
    }

    private onTaskCancel(msg:LoadMsg.OnTaskCancel){
        let body = msg.body;
        if(body.taskName == this.taskName && this.closeAfterComplete){
            this.sendMsg(create(LoadMsg.CloseLoadingView));
        }
    }

    private onTaskComplete(msg:LoadMsg.OnTaskComplete){
        let body = msg.body;
        if(body.taskName == this.taskName && this.closeAfterComplete){
            this.sendMsg(create(LoadMsg.CloseLoadingView));
        }
    }

    private regTaskMsg(){
        this.regMsg(LoadMsg.OnTaskProgress, this.onTaskProgress, this);
        this.regMsg(LoadMsg.OnTaskComplete, this.onTaskComplete, this);
        this.regMsg(LoadMsg.OnTaskCancel, this.onTaskCancel, this);
    }
    private unregTaskMsg(){
        this.unregMsg(LoadMsg.OnTaskProgress, this.onTaskProgress, this);
        this.unregMsg(LoadMsg.OnTaskComplete, this.onTaskComplete, this);
        this.unregMsg(LoadMsg.OnTaskCancel, this.onTaskCancel, this);
    }
}