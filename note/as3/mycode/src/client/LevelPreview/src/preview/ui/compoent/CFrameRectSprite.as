/**
 * Created by auto on 2016/6/1.
 */
package preview.ui.compoent {
public class CFrameRectSprite extends CRectSprite {
    // x2 : 内矩x, y2 : 内矩y, color2内矩color
    public function CFrameRectSprite(color:int, w:int, h:int, color2:int, x2Rate:Number, y2Rate:Number, alpha:Number = 1.0) {
        _xRate = x2Rate;
        _yRate = y2Rate;
        _rectInside = new CRectSprite(color2, w-w*_xRate*2, h-h*_yRate*2, alpha);
        this.addChild(_rectInside);

        super (color, w, h, alpha);


    }
    protected override function _onAdd() : void {
    }
    protected override function _onRemove() : void {
        _rectInside.parent.removeChild(_rectInside);
        _rectInside = null;
    }
    public override function clear() : void {
        super.clear();
        _rectInside.clear();
    }

    public override function change(color:int, w:int, h:int, alpha:Number = 1.0) : void {
        super.change(color, w, h, alpha);

        _rectInside.setSize(w-w*_xRate*2, h-h*_yRate*2);
        _rectInside.move(w*_xRate, h*_yRate);
    }


    private var _rectInside:CRectSprite;
    private var _xRate:Number;
    private var _yRate:Number;


}
}
