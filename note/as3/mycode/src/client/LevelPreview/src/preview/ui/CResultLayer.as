/**
 * Created by auto on 2016/6/1.
 */
package preview.ui {
import preview.ui.compoent.CBaseLayer;
import preview.ui.compoent.CTextField;

public class CResultLayer extends CBaseLayer{
    public function CResultLayer() {

    }
    protected override function _onAdd() : void {
        super._onAdd();
        _winText = new CTextField(500, 500);
//        _winText.text = "你过关了";
        _winText.setFontColor(0xffffff);
        _winText.setFontSize(60);
        this.addChild(_winText);
    }
    protected override function _onRemove() : void {
        super._onRemove();
        _winText.parent.removeChild(_winText);
        _winText = null;
    }

    public function updateFromData(data:Object) : void {
        if (data && data["result"]) {
            visible = true;
        } else {
           visible = false;
        }

    }

    private var _winText:CTextField;
}
}
