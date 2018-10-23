class TestMediator extends ViewMediator {
    view: App.IBaseView;

    protected readonly viewClass: new () => TestView = TestView;

    private tf:egret.TextField;

    constructor() {
        super();

        this.tf = new egret.TextField();
    }

    protected onViewOpen() {
        this.regMsg(TestModuleMsg.SetTfVisible, this.tfVisibleHandler, this);
        this.regMsg(TestModuleMsg.SetTfContent, this.setTfContentHandler, this);
    }
    protected onViewClose() {
        this.unregMsg(TestModuleMsg.SetTfVisible, this.tfVisibleHandler, this);
        this.unregMsg(TestModuleMsg.SetTfContent, this.setTfContentHandler, this);
    }

    private tfVisibleHandler(msg: TestModuleMsg.SetTfVisible) {
        let visible = msg.body.visible;
        let tf = this.tf;
        if(visible){
            StageUtils.getStage().addChild(tf);
        }else{
            if(tf.parent){
                tf.parent.removeChild(tf);
            }
        }
    }

    private setTfContentHandler(msg : TestModuleMsg.SetTfContent){
        let body = msg.body;
        this.tf.text = `${body.num}  ${body.str}`;
    }


    protected get openViewMsg()  {
        return TestModuleMsg.OpenTestView;
    }

    protected get closeViewMsg()  {
        return TestModuleMsg.CloseTestView;
    }
}

