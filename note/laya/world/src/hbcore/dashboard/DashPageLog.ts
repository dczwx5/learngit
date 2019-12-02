import DashPage from "./DashPage";
import debugout from "./debugout";
import Sprite = Laya.Sprite;
export default class DashPageLog extends DashPage {
    constructor(root:Sprite) {
        super(root);
        this._createUI();
    }

    private _createUI() {
        this.m_text = new Laya.Text();
        // this.m_text.autoSize = true;
        // this.m_text.height = '';
        // this.m_text.mouseEnabled = false;
        // this.m_text.mouseThrough = true;
        this.m_text.pos(0, 10);
        this.updateSize();
        this.m_text.fontSize = 14;
        this.m_text.color = '#ffffff';
        // this.m_text.wordWrap = true;
        this.m_text.text = ""; // debugout.instance.getLog();//"abc";// JSON.stringify();

        this.addChild(this.m_text);
    }
    updateView() {
        this.m_text.text = debugout.instance.getLog();//"abc";// JSON.stringify();  
        this.m_text.height = this.m_text.textHeight + 50;
        this.height = this.m_text.height;
        // this.m_text.scrollTo(this.m_text.height);
        
    }
    updateSize() {
        // this.m_text.size(this.m_pRoot.width - 50, this.m_pRoot.height - 10);
        this.m_text.width = this.m_pRoot.width - 50;
    }

    private m_text:Laya.Text;
}