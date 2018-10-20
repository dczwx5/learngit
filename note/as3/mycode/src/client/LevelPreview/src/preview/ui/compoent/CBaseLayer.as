/**
 * Created by auto on 2016/5/31.
 */
package preview.ui.compoent {

public class CBaseLayer extends CBaseSprite {
    public function CBaseLayer(w:int = 0, h:int = 0) {
        super(w, h);

    }

    protected override function _onAdd() : void {
        super._onAdd();
        _bg = new CRectSprite(0, uiWidth, uiHeight, 0.7);
        this.addChild(_bg);
    }
    protected override function _onRemove() : void {
        super._onRemove();
        if (_bg) this.removeChild(_bg);
        _bg = null;
    }

    public override function setSize(w:int, h:int) : void {
        super.setSize(w, h);
        if (_bg) _bg.setSize(w, h);
    }
    public function get bg() : CRectSprite {
        return _bg;
    }
    public function bgGoDie() : void {
        if (_bg) this.removeChild(_bg);
        _bg = null;
    }

    private var _bg:CRectSprite;

    public var _bufVisible:Boolean;
}
}
