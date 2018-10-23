class LoadResController extends VoyaMVC.Controller{

    activate() {
        this.regMsg(LoadMsg.LoadRes, this.loadResHandler, this);
    }
    deactivate() {
        this.unregMsg(LoadMsg.LoadRes, this.loadResHandler, this);
    }
    
    private loadResHandler(msg:LoadMsg.LoadRes){
        let resMng = app.resManager;
        resMng.loadResTask({
            keys:msg.body.sources,
            taskName:msg.body.taskName,
            onComplete:task=>{
                this.sendMsg(create(LoadMsg.OnTaskComplete).init({taskName:task.taskName}));
            },
            onProgress:(task, curr, total)=>{
                this.sendMsg(create(LoadMsg.OnTaskProgress).init({curr:curr, total:total, taskName:task.taskName}));
            },
            onCancel:task=>{
                this.sendMsg(create(LoadMsg.OnTaskCancel).init({taskName:task.taskName}));
            }
        });
    }

}