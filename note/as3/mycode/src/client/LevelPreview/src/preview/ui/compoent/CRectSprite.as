/**
 * Created by auto on 2016/5/31.
 */
package preview.ui.compoent {
public class CRectSprite extends CBaseSprite {
    public function CRectSprite(color:int, w:int, h:int, alpha:Number = 1.0) {
        change(color, w, h, alpha);
    }

    public function change(color:int, w:int, h:int, alpha:Number = 1.0) : void {
        graphics.clear();
        _drawRect(color, 0, 0, w, h, alpha);
        _setData(color, w, h, alpha);
        super.setSize(w, h);
    }
    public override function setSize(w:int, h:int) : void {
        change(_color, w, h, _alpha);
    }
    public function setColor(color:int) : void {
        change(color, uiWidth, uiHeight, _alpha);
    }
    public function setAlpha(alpha:Number) : void {
        change(_color, uiWidth, uiHeight, alpha);
    }
    public function move(x:int, y:int) : void {
        this.x = x;
        this.y = y;
    }
    public function clear() : void {
        graphics.clear();
    }

    private function _setData(color:int, w:int, h:int, alpha:Number = 1.0) : void {
        uiWidth = w;
        uiHeight = h;
        _color = color;
        _alpha = alpha;
    }
    private var _color:int;
    private var _alpha:Number;
}
}
