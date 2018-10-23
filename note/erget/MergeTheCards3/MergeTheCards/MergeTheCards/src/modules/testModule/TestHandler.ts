class TestController extends VoyaMVC.Controller{

    activate() {
        this.regMsg(TestModuleMsg.RunTest, this.runTestHandler, this);
    }    

    deactivate() {
        this.unregMsg(TestModuleMsg.RunTest, this.runTestHandler, this);
    }

    private runTestHandler(){
        let data = this.getModel(TestModel).dataContent;
        this.sendMsg(create(TestModuleMsg.SetTfContent).init(data));
        this.sendMsg(create(TestModuleMsg.SetTfVisible).init({visible : true}));
    }

}