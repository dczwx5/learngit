package script {
import laya.ui.View;
import ui.NumberViewUI;
import laya.utils.Handler;
import laya.components.Component;
import laya.ui.Clip;
import laya.ui.Box;
import laya.ui.List;
import laya.display.Sprite;

public class CNumberView extends NumberViewUI {
    public function CNumberView() {
        list.itemRender = Number_Clip;
        list.renderHandler = new Handler(this, _onItemRender); // Handler.create(this, _onItemRender, null, false);
    }
    public function set num(v:int) : void {
        m_value = Math.floor(v);

        updateData();
    }
    public function get num() : int {
        return m_value;
    }

    public function updateData() : void {
        var str:String = m_value.toString();
        if (!m_arr) {
            m_arr = [];
        }
        m_arr.length = 0;
        for (var i:int = 0; i < str.length; i++) {
            m_arr[i] = str.charAt(i);
        }
        list.repeatX = m_arr.length;
        list.array = m_arr;
        _updateView();
    }
    private function _updateView() : void {
        if (m_align != -1) {
            if (ALIGN_CENTER == m_align) {
                var thisWidth:int = 91 * m_arr.length + list.spaceX * (m_arr.length - 1);
                x = ((parent as Sprite).displayWidth - thisWidth) * 0.5;
            } else if (ALIGN_LEFT == m_align) {
                x = 0;
            }
        }
    }
    private function _onItemRender(comp:Component, idx:int) : void {
        var item:Clip = comp as Clip; // (comp).getChildByName("num_clip") as Clip;
        var dataSource:int = item.dataSource;
        item.index = dataSource;
    }

    public function set align(v:int) : void {
        m_align = v;
        updateData();
    }

    private var m_value:int;
    private var m_arr:Array;
    private var m_align:int = 0;

    public static const ALIGN_CENTER:int = 0;
    public static const ALIGN_LEFT:int = 1;
}
}

import laya.ui.Clip;

class Number_Clip extends Clip{
    public function Number_Clip() {
        skin = 'gameUI/clip_number1.png';
        clipX = 10;
        clipY = 1;
        index = 0;
        width = 91;
    }
}