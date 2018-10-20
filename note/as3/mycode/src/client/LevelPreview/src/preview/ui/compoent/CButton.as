/**
 * Created by auto on 2016/5/31.
 */
package preview.ui.compoent {
import flash.display.SimpleButton;
import flash.events.MouseEvent;

public class CButton extends CBaseSprite {
    public function CButton(w:int, h:int) {
        super (w, h);
        _btn = new SimpleButton();
        _caption = new CTextField(uiWidth, uiHeight-4);
    }
    protected override function _onAdd() : void {
        super._onAdd();

        this.addChild(_btn);
        _btn.width = uiWidth;
        this.addEventListener(MouseEvent.CLICK, _onClick)

        this.addChild(_caption);
        _caption.alignCenter();
        _caption.y = 2;


        _funClicks = new Vector.<Function>();

    }
    protected override function _onRemove() : void {
        super._onRemove();
        this.removeChild(_btn);
        _btn = null;
        _funClicks = null;
        this.removeChild(_caption);
        _caption = null;
        this.removeEventListener(MouseEvent.CLICK, _onClick)

    }
    public override function setSize(w:int, h:int) : void {
        super.setSize(w, h);
        _caption.setSize(w, h);
    }
    private function _onClick(e:MouseEvent) : void {
        e.stopImmediatePropagation();
        for each (var fun:Function in _funClicks) {
            fun(e);
        }
    }

    public function addClickFunc(func:Function) : void {
        _funClicks.push(func);
    }
    public function setCaption(cap:String, color:int = -1, size:int = 10, style:String = "Verdana") : void {
        _caption.text = cap;
        _caption.setFontColor(color);
        _caption.setFontSize(size);
        _caption.setFontStyle(style);
    }

    private var _btn:SimpleButton;
    private var _caption:CTextField;
    private var _funClicks:Vector.<Function>;
}
}
