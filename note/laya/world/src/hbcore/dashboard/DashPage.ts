import Sprite = Laya.Sprite;
export default class DashPage extends Sprite {
    constructor(root:Sprite) {
        super();

        this.m_pRoot = root;
    }

    updateView() {
        
    }
    updateSize() {
    }
    protected m_pRoot:Sprite;
}