//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/1/16.
 */
package kof.game.gm.view.gmMenu {

import QFLib.DashBoard.CDashBoard;

import flash.display.DisplayObjectContainer;

import kof.game.common.view.CRootView;
import kof.game.common.view.event.CViewEvent;
import kof.game.gm.CGMConfig;
import kof.game.gm.event.EGmEventType;
import kof.ui.gm.GMMenuItemUI;
import kof.ui.gm.GMMenuTypeViewUI;
import kof.ui.gm.GMenuUI;

import morn.core.components.Component;
import morn.core.handlers.Handler;

public class CGmMenu extends CRootView {

    private var gmCmdList:Array;

    public function CGmMenu() {
        super(GMenuUI, null, null, false);

        gmCmdList = new Array();
        var cmdList:Array = CGMConfig.gmArr;//_data as Array;
        var len:int = cmdList.length;
        var repeatx:int = (int)(1500/(270));
        for(var i:int = 0; i<len; i++){
            var item:GMMenuTypeViewUI = new GMMenuTypeViewUI();
            item.item_list.renderHandler = new Handler(_onRenderItem);
            item.item_list.dataSource = cmdList[i ].gmCmd;
            item.item_list.repeatX = repeatx;
            item.item_list.repeatY = Math.ceil(cmdList[i ].gmCmd.length/repeatx);
            item.txt_typeName.text = cmdList[i ].typeName;
            gmCmdList.push(item);
        }
    }

    protected override function _onCreate() : void {
    }

    protected override function _onHide() : void {
        var pDashBoard:CDashBoard = system.stage.getBean(CDashBoard) as CDashBoard;
        pDashBoard.setTheDashBoardSize(0);
    }
    protected override function _onShow() : void {
        // do thing when show
        super._onShow();
        var pDashBoard:CDashBoard = system.stage.getBean(CDashBoard) as CDashBoard;
        pDashBoard.setTheDashBoardSize(1);
    }

    private var _parent:DisplayObjectContainer;
    public override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        if (_parent == null) {
            if (this._initialArgs && _initialArgs.length > 0) {
                _parent = _initialArgs[0];
            }
        }
        if (_parent) {
            this.addToParent(_parent);
        } else {
            this.addToRoot();
        }

        if(gmCmdList)
        {
            var width:int = 1500;
            if (_parent && _parent.stage) width = _parent.stage.stageWidth;
            var len:int = gmCmdList.length;
            for(var i:int = 0; i<len; i++){
                var item:GMMenuTypeViewUI = gmCmdList[i];
                _ui.addChild(item);

                if(i-1<0){
                    item.y = 0;
                }
                else{
                    var repeatY:int = gmCmdList[i-1 ].item_list.repeatY;
                    var spaceY:int = item.item_list.spaceY;
                    item.y = gmCmdList[i-1 ].y + repeatY * 26 + (spaceY*repeatY-1) + 35;
                }
            }
        }


        return true;
    }

    private function _onRenderItem(com:Component, idx:int) : void {
        var item:GMMenuItemUI = com as GMMenuItemUI;
        if (null == item) return ;
        if (item.dataSource == null) {
            item.visible = false;
            return ;
        }
        item.visible = true;

        item.name_btn.label = item.dataSource.label;
        item.name_btn.toolTip = item.dataSource.description;
        item.name_btn.clickHandler = new Handler(function () : void {
            var params:String = item.param_txt.text;
            sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EGmEventType.EVENT_MENU_CMD, [item.dataSource.name, params]))
        });

    }

    private function get _ui() : GMenuUI {
        return rootUI as GMenuUI;
    }
}
}


