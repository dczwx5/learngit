//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/3.
 */
package kof.game.instance.mainInstance.view.result {

import QFLib.Foundation.CKeyboard;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;

import kof.game.common.CLang;
import kof.game.common.view.CRootView;
import kof.game.common.view.event.CViewEvent;
import kof.game.instance.mainInstance.control.CInstanceLoseControl;
import kof.game.instance.mainInstance.enum.EInstanceWndResType;
import kof.game.instance.mainInstance.view.event.EInstanceViewEventType;
import kof.table.BundleEnable;
import kof.table.Enhanceability;
import kof.ui.instance.InstanceLoseUI;
import morn.core.components.Button;
import morn.core.components.Image;
import morn.core.handlers.Handler;
// pve 总失败
public class CInstanceLoseView extends CRootView {

    public function CInstanceLoseView() {
        super(InstanceLoseUI, [], EInstanceWndResType.INSTANCE_LOSE_RESULT, false)
    }

    protected override function _onCreate() : void {
//        _keyBoard = new CKeyboard(system.stage.flashStage);
    }

    protected override function _onDispose() : void {
    }
    protected override function _onShow():void {
        _ui.ok_btn.clickHandler = new Handler(_onOk);

        for (var i:int = 0; i < 3; i++) {
            var btn:Button = getButton(i);
            btn.clickHandler = new Handler(_onClick, [i]);
        }

//        _keyBoard.registerKeyCode(false, Keyboard.SPACE, _onKeyDown);
        system.stage.flashStage.addEventListener( KeyboardEvent.KEY_UP, _onKeyboardUp, false, 0, true );

        this.setNoneData();
        invalidate();

        m_iLeftTime = 30;
        schedule(1, _onScheduleHandler);
    }

    private function _onKeyboardDown( e:KeyboardEvent ) : void
    {
    }

    private function _onKeyboardUp( e:KeyboardEvent ) : void
    {
        if( e.keyCode == Keyboard.SPACE)
        {
            if (_ui.ok_btn.visible)
            {
                close();
            }
        }
    }

    private function _onScheduleHandler(delta : Number):void
    {
        _ui.txt_countDown.text = "("+m_iLeftTime + "s后自动关闭)";
        m_iLeftTime--;

        if(m_iLeftTime <= -1)
        {
            this.close();
        }
    }

    protected override function _onHide() : void {
        _ui.ok_btn.clickHandler = null;

        for (var i:int = 0; i < 3; i++) {
            var btn:Button = getButton(i);
            btn.clickHandler = null;
        }

//        _keyBoard.unregisterKeyCode(false, Keyboard.SPACE, _onKeyDown);
        system.stage.flashStage.removeEventListener( KeyboardEvent.KEY_UP, _onKeyboardUp);

        unschedule(_onScheduleHandler);
    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        _ui.ok_btn.label = CLang.Get("common_exit_instance");
//        _ui.btn_1.selected = true;

        var handler:CInstanceLoseControl = controlList[0];
        _bundlerList = handler.getRecommondList();

        // 设置数据
        var pDatabase:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;
        var pBundleEnableTable : IDataTable = pDatabase.getTable( KOFTableConstants.BUNDLE_ENABLE );
        for (var i:int = 0; i < 3; i++) {
            var btn:Button = getButton(i);
            var img:Image = getImage(i);
            var enhance:Enhanceability = _bundlerList[i] as Enhanceability;
            if (enhance) {
                var pBundleEnable : BundleEnable = pBundleEnableTable.findByPrimaryKey( enhance.TagID );
                img.skin = pBundleEnable.IconURI;
                btn.label = enhance.Description;
            } else {
                btn.visible = false;
            }
        }

        this.addToDialog();

        return true;
    }

    private var _bundlerList:Array;

    private function _onOk() : void {
        //
        this.close();
    }
    private function _onKeyDown(keyCode:uint):void {
        switch (keyCode) {
            case Keyboard.SPACE:
                if (_ui.parent) {
                    close();
                }
                break;
        }
    }

    private function _onClick(index:int) : void {
        var enhance : Enhanceability = _bundlerList[ index ] as Enhanceability;
        sendEvent( new CViewEvent( CViewEvent.UI_EVENT, EInstanceViewEventType.INSTANCE_LOSE_JUMP, enhance ) );
    }

    private function get _ui() : InstanceLoseUI {
        return rootUI as InstanceLoseUI;
    }

    private function getButton(index:int) : Button {
        return _ui["btn_" + (index+1)];
    }
    private function getImage(index:int) : Image {
        return _ui["img" + (index+1)];
    }
    private var _keyBoard:CKeyboard;
    private var m_iLeftTime:int;

}
}
