//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * 经验副本
 * Created by user on 2017/10/24.
 */
package kof.game.fightui.compoment {

import kof.framework.CViewHandler;
import kof.game.common.CItemUtil;
import kof.game.common.CLang;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.event.CInstanceEvent;
import kof.game.resourceInstance.CResourceInstanceSystem;
import kof.game.resourceInstance.CTrainInstanceEvent;
import kof.message.Instance.ExpInstanceUpResourceResponse;
import kof.ui.demo.FightUI;

import morn.core.components.Component;

import morn.core.handlers.Handler;

public class CTrainInstanceTipsView extends CViewHandler {
    private var _bViewInitialized : Boolean = false;
    private var _fightUI : FightUI = null;

    public function CTrainInstanceTipsView( fightUI : FightUI  ) {
        super();
        this._fightUI = fightUI;
    }

    override protected function onSetup() : Boolean {
        if ( !super.onInitializeView() )
            return false;
        if ( !_bViewInitialized ) {
            _addEvent();
            _bViewInitialized = true;
        }
        return _bViewInitialized;
    }

    private function _addEvent() : void {
        (system.stage.getSystem( CInstanceSystem ) as CInstanceSystem).addEventListener( CInstanceEvent.ENTER_INSTANCE, _enterInstance );
        (system.stage.getSystem( CResourceInstanceSystem ) as CResourceInstanceSystem).addEventListener( CTrainInstanceEvent.ROUND, _updateRound );
        (system.stage.getSystem( CResourceInstanceSystem ) as CResourceInstanceSystem).addEventListener( CTrainInstanceEvent.UPDATE_AWARD, _updateAward );
    }

    private function _updateAward(e:CTrainInstanceEvent):void{
        _fightUI.train_ui.list.dataSource = e.data;
    }

    private function _updateRound(e:CTrainInstanceEvent):void{
         _fightUI.train_round_ui.txt_round.text = CLang.Get("trainInstance_round", {v1:e.data.round,v2:e.data.total});
    }

    private function _enterInstance( e : CInstanceEvent ) : void {
        var _instanceDate:CChapterInstanceData = (system.stage.getSystem(CInstanceSystem) as CInstanceSystem).getInstanceByID(int(e.data));
        if ( _instanceDate.instanceType == EInstanceType.TYPE_TRAIN_INSTANCE ) {
            _fightUI.train_round_ui.visible = true;
            _fightUI.train_ui.visible = true;
            _initView();
        } else {
            _fightUI.train_ui.visible = false;
            _fightUI.train_round_ui.visible = false;
        }
    }

    private function _initView() : void {
        _fightUI.train_round_ui.txt_round.text = "";
        _fightUI.train_ui.list.renderHandler = new Handler(CItemUtil.getItemRenderFunc(system));
        _fightUI.train_ui.list.dataSource = [];
    }

    override public function dispose() : void {
        super.dispose();
        (system.stage.getSystem( CInstanceSystem ) as CInstanceSystem).removeEventListener( CInstanceEvent.ENTER_INSTANCE, _enterInstance );
    }
}
}
