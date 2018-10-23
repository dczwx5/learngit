abstract class SceneMediator extends VoyaMVC.Mediator {

    private _scene: App.BaseScene;

    constructor() {
        super();
        this._scene = this.createScene();
    }

    protected abstract createScene(): App.BaseScene;


    activate(...params) {
        this.regMsg(SystemMsg.EnterScene, this.onEnterScene, this);
    }

    deactivate() {
        this.unregMsg(SystemMsg.EnterScene, this.onEnterScene, this);
    }

    protected onEnterScene(msg: SystemMsg.EnterScene) {
        this.exit();
        if (msg.body.scene == getClassByEntity(this.scene)) {
            this.enter();
        }
    }

    protected enter() {
        this.scene.enter();
    }

    protected exit() {
        this.sendMsg(create(SystemMsg.CloseAllViews).init({closeSystemView: false}));
        this.scene.exit();
    }

    protected get scene(): App.BaseScene {
        return this._scene;
    }
}
