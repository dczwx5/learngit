/**
 * Created by Administrator on 2016/6/6.
 */
package preview.ui {
import preview.ui.compoent.CBaseLayer;
import preview.ui.compoent.CButton;

public class CGoLayer extends CBaseLayer {
    public function CGoLayer(w:int, h:int) {
        super(w, h);
        _go = new CButton(uiWidth, uiHeight);
        _isToRight = false;
    }
    protected override function _onAdd() : void {
        super._onAdd();
        this.bgGoDie();

        this.addChild(_go);
//        _go.setCaption("Go ->", 0xffffff, 50);
        _go.buttonMode = false;
        _go.mouseEnabled = false;

    }
    protected override function _onRemove() : void {
        super._onRemove();
        _go.parent.removeChild(_go);
        _go = null;
    }

    public override function update(delta:Number) : void {
        const speed:Number = 100;
        if (_isToRight) {
            _go.x += delta * speed;
        } else {
            _go.x -= delta * speed;
        }

        if (_go.x >= 0) {
            _go.x = 0;
            _isToRight = false;
        }
        if (_go.x <= -uiWidth) {
            _go.x = -uiWidth;
            _isToRight = true;
        }

    }

    private var _go:CButton;

    private var _isToRight:Boolean;
}
}
