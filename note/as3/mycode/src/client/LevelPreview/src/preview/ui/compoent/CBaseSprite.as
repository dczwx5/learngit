/**
 * Created by auto on 2016/5/31.
 */
package preview.ui.compoent {
import QFLib.Interface.IUpdatable;

import flash.display.Sprite;
import flash.events.Event;

/***
 * 宽高使用uiWidth, uiHeight, 如果不是需要特别外理宽高的, 可以不用理他, 构造函数也不传值就行了
 * _onAdd, _onRemove,子类重写这两个函数, 做添加和移除之后的初始化与析造
 * 一般情况下, 在_onAdd下做初始化, 要比在构造函数做初始化好, 因为这个时候parent也有了,
 * 保证使用时, 都继承CBaseSprite
 *
 */
public class CBaseSprite extends Sprite implements IUpdatable {
    public function CBaseSprite(width:int = 0, height:int = 0) {
        this._uiWidth = width;
        this._uiHeight = height;

        this.addEventListener(Event.ADDED_TO_STAGE, _onAddA);
        this.addEventListener(Event.REMOVED_FROM_STAGE, _onRemoveA);
    }
    private function _onAddA(e:Event) : void {
        this.removeEventListener(Event.ADDED_TO_STAGE, _onAddA);
        _onAdd();
    }
    private function _onRemoveA(e:Event) : void {
        this.removeEventListener(Event.REMOVED_FROM_STAGE, _onRemoveA);
        _onRemove();
    }
    protected virtual function _onAdd() : void {
    }
    protected virtual function _onRemove() : void {
    }

    public virtual function update(delta:Number) : void {

    }
    // parent, 应该是一个BaseSprite的对象
    public function getParent() : CBaseSprite {
        return parent as CBaseSprite;
    }

    // 布局, 各个边界
    public function toLeft() : void {
        x = 0;
    }
    public function toRight() : void {
        if (getParent()) {
            x = getParent().uiWidth-this.uiWidth
        }
    }
    public function toTop() : void {
        y = 0;
    }
    public function toBottom() : void {
        if (getParent()) {
            y = getParent().uiHeight-this.uiHeight;
        }
    }
    public function toLeftTop() : void {
        toLeft();
        toTop();
    }
    public function toLeftBottom() : void {
        toLeft();
        toBottom();
    }
    public function toRightTop() : void {
        toRight();
        toTop();
    }
    public function toRightBottom() : void {
        toRight();
        toBottom();
    }
    public function toCenter() : void {
        if (getParent()) {
            x = (getParent().uiWidth-uiWidth)/2;
            y = (getParent().uiHeight-uiHeight)/2;
        }
    }

    protected function _drawRect(color:int, x:int, y:int, w:int, h:int, alpha:Number = 1.0) : void {
        if (w > 0 && h > 0) {
            graphics.beginFill(color, alpha);
            graphics.drawRect(x, y, w, h);
            graphics.endFill();
        }
    }

    public function setSize(w:int, h:int) : void {
        _uiWidth = w;
        _uiHeight = h;
    }

    // 外部使用, 用uiWidth, uiHeight
    public function set uiWidth(v:int) : void {
        _uiWidth = v;
    }
    public function set uiHeight(v:int) : void {
        _uiHeight = v;
    }
    final public function get uiWidth() : int {
        return _uiWidth == 0 ? this.width : _uiWidth;
    }
    final public function get uiHeight() : int {
        return _uiHeight == 0 ? this.height : _uiHeight;
    }
    private var _uiWidth:int;
    private var _uiHeight:int;
}
}
