//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2016/10/27.
 */
package kof.ui {

import flash.utils.Dictionary;

import kof.framework.CViewHandler;
import kof.game.common.CLang;
import kof.ui.demo.Bag.ImportantNoteUI;

import morn.core.components.Button;
import morn.core.components.CheckBox;
import morn.core.components.Component;
import morn.core.components.Dialog;
import morn.core.handlers.Handler;

public class CMsgBoxHandler extends CViewHandler {

    public function CMsgBoxHandler() {
        super( true ); // load view by default to call onInitializeView
    }
    private var _noteUIAry : Array = [];
    private var _cacleDic : Dictionary;    //记录提示框的操作类型和下次是否继续显示

    override public function get viewClass() : Array {
        return [ ImportantNoteUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
    }

    private var _cancelIsVisible : Boolean;

    public function show( msg : String, okFun : Function = null, closeFun : Function = null, cancelIsVisible : Boolean = true,
                          okLable:String = null, cancelLable:String = null, closeBtnIsVisible:Boolean = true, showType : String = "", bAppPopLayer : Boolean = false ) : void {

        //判断之前是否勾选了不再显示，若是，则直接跳过box显示执行okFun
        for(var key:String in _cacleDic)
        {
            if(key == showType && _cacleDic[key] == true)
            {
                okFun.apply();
                return;
            }
        }

        var noteUI : ImportantNoteUI = new ImportantNoteUI();
        _noteUIAry.push( noteUI );
        _cancelIsVisible = cancelIsVisible;
        udpateButton( noteUI );
        noteUI.closeHandler = new Handler( _onClose, [ okFun, closeFun, noteUI ] );
        noteUI.txt_cont.text = msg;

        var btnCancel : Button = noteUI.getChildByName( "cancel" ) as Button;
        var okCancel : Button = noteUI.getChildByName( "ok" ) as Button;
        if (okLable != null && okLable.length > 0) {
            okCancel.label = okLable;
        } else {
            okCancel.label = CLang.Get("common_ok");
        }
        if (cancelLable != null && cancelLable.length > 0) {
            btnCancel.label = cancelLable;
        } else {
            btnCancel.label = CLang.Get("common_cancel");
        }
        var closeBtn:Component = noteUI.getChildByName("close") as Component;
        if (closeBtn) {
            closeBtn.visible = closeBtnIsVisible;
        }
        //如果传了操作类型过来，则显示勾选框，提供不再显示选择，取消弹窗时，则不记录
        //=========================Start==========by Lune===================
        if(showType != "")
        {
            noteUI.checkBox.visible = true;
            okCancel.clickHandler = new Handler(_checkFunc,[showType,noteUI.checkBox,true]);
            btnCancel.clickHandler = new Handler(_checkFunc,[showType,noteUI.checkBox,false]);
            (closeBtn as Button).clickHandler = new Handler(_checkFunc,[showType,noteUI.checkBox,false]);
        }
        else
        {
            noteUI.checkBox.visible = false;
        }
        //=========================End======================================
        if ( bAppPopLayer )
            uiCanvas.addAppPrompt( noteUI );
        else
            uiCanvas.addPopupDialog( noteUI );
    }

    private function udpateButton( noteUI : ImportantNoteUI ) : void {
        var btnCancel : Button = noteUI.getChildByName( "cancel" ) as Button;
        var okCancel : Button = noteUI.getChildByName( "ok" ) as Button;
        btnCancel.visible = _cancelIsVisible;
        if ( !_cancelIsVisible )
            okCancel.x = (noteUI.bg.width - okCancel.width) / 2;
    }

    public function closeAllDialog():void{
        var noteUI : ImportantNoteUI;
        for each ( noteUI in _noteUIAry ){
            if( noteUI.parent )
                noteUI.close( Dialog.CLOSE );
        }
    }

    private function _onClose( ... params ) : void {
        switch ( params[ 3 ] ) {
            case Dialog.CLOSE:
            case Dialog.CANCEL:
                if ( params[ 1 ] )
                    ( params[ 1 ] as Function ).apply();
                break;
            case Dialog.OK:
                if ( params[ 0 ] )
                    ( params[ 0 ] as Function ).apply();
                break;
        }

        var noteUI : ImportantNoteUI = params[ 2 ] as ImportantNoteUI;
        _noteUIAry.splice( _noteUIAry.indexOf( noteUI ) , 1 );
    }

    /**
     * 用于记录勾选框，是否不再显示
     * 参数1，调用弹窗的操作类型
     * 参数2，checkBox状态
     * @author Lune
     */
    private function _checkFunc(... params ):void
    {
        var checkBox : CheckBox = params[ 1 ] as CheckBox;
        _cacleDic ||= new Dictionary();
        _cacleDic[params[ 0 ]] = checkBox.selected && params[ 2 ];
    }
}
}
