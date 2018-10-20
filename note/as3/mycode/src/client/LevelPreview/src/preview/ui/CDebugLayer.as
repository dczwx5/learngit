/**
 * Created by auto on 2016/7/4.
 */
package preview.ui {
import flash.text.TextField;
import flash.text.TextFieldType;

import preview.ui.compoent.CBaseLayer;
import preview.ui.compoent.CTextField;

public class CDebugLayer extends CBaseLayer {
    public function CDebugLayer(w:int, h:int) {
        super(w, h);
    }

    protected override function _onAdd() : void {
        super._onAdd();

        _log = new CTextField(uiWidth-30, uiHeight);
        this.addChild(_log);

        _log.setSelectAble(true);
        _log.setType(TextFieldType.INPUT);
        _log.getCompoent().multiline = true;
        _log.getCompoent().wordWrap = true;

        this.bg.setColor(0xffffff);
        bg.setAlpha(1);
    }
    protected override function _onRemove() : void {
        super._onRemove();
        if (_log) {
            _log.parent.removeChild(_log);
            _log = null;
        }
    }
    public function updateFromData(data:Object) : void {
        _log.getCompoent().htmlText = _log.getCompoent().htmlText + data as String;
        _log.getCompoent().setSelection(_log.getCompoent().selectionEndIndex, _log.getCompoent().selectionEndIndex);
        //_log.getCompoent().htmlText = _log.getCompoent().htmlText.replace("<P ALIGN=\"LEFT\">", "");
        //_log.getCompoent().htmlText = _log.getCompoent().htmlText.replace("</P>", "");
    }

    private var _log:CTextField;

}
}
