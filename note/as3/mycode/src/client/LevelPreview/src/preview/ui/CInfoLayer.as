/**
 * Created by auto on 2016/5/31.
 */
package preview.ui {

import preview.ui.compoent.CBaseLayer;
import preview.ui.compoent.CTextField;

public class CInfoLayer extends CBaseLayer {
    public function CInfoLayer(w:int, h:int) {
        super(w, h);
    }

    protected override function _onAdd() : void {
        super._onAdd();

        _textList = new Vector.<CTextField>(4);
        for (var i:int = 0; i < _textList.length; i++) {
            _textList[i] = new CTextField(uiWidth-30, 25);
            _textList[i].y = i * 25;
            _textList[i].visible = false;
            this.addChild(_textList[i])
        }

//        _button = new CButton(30, 30);
//        this.addChild(_button);
//        _button.caption = "remove";
//        _button.addClickFunc(this._onClickRemoveButton);

        this.bg.setColor(0xffffff);
        bg.setAlpha(1);
    }
    protected override function _onRemove() : void {
        super._onRemove();
        for (var i:int = 0; i < _textList.length; i++) {
            _textList[i].parent.removeChild(_textList[i]);
        }
        _textList = null;
    }

    public function updateByData(data:Object) : void {
        var i:int = 0;
        for (; i < _textList.length; i++) {
            _textList[i].visible = false;
        }

        i = 0;
        for each (var value:String in data) {
            if (i >= _textList.length) {
                var text:CTextField = new CTextField(uiWidth-30, 25);
                text.y = i * 25;
                text.visible = false;
                this.addChild(text)
                _textList[i] = text;

            }
            _textList[i].getCompoent().htmlText = value;
            _textList[i].visible = true;
            i++;
        }

        reCalcSize();
    }

    private function get visualLength() : int {
        var c:int = 0;
        for each (var t:CTextField in _textList) {
            if (t.visible) c++;
        }
        return c;
    }
    private function reCalcSize() : void {
        var height:int = visualLength * 25;
        if (height != uiHeight) {
            this.setSize(uiWidth, height);
        }
    }

    private var _textList:Vector.<CTextField>;
    // private var _button:CButton;

}
}
