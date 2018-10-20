//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/8/2.
 */
package kof.game.fightui.compoment {

import com.greensock.TweenLite;

import flash.utils.clearInterval;

import flash.utils.setInterval;

import kof.framework.CViewHandler;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.event.CInstanceEvent;
import kof.game.resourceInstance.CResourceInstanceSystem;
import kof.game.resourceInstance.CGoldInstanceEvent;
import kof.ui.demo.FightUI;

import morn.core.components.Box;
import morn.core.components.Clip;

import morn.core.components.Component;

import morn.core.components.FrameClip;
import morn.core.components.Label;
import morn.core.handlers.Handler;

public class CGoldInstanceTipsView extends CViewHandler {
    private var _bViewInitialized : Boolean = false;
    private var _fightUI : FightUI = null;
    private var _timeStampIntervelID:int;
    public function CGoldInstanceTipsView( fightUI : FightUI ) {
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
        (system.stage.getSystem( CResourceInstanceSystem ) as CResourceInstanceSystem).addEventListener( CGoldInstanceEvent.ADD_GOLD, _addGoldFun );
        (system.stage.getSystem( CResourceInstanceSystem ) as CResourceInstanceSystem).addEventListener( CGoldInstanceEvent.START_TIME, _startTimeFun );
        (system.stage.getSystem( CResourceInstanceSystem ) as CResourceInstanceSystem).addEventListener( CGoldInstanceEvent.UPDATE_DAMAGE, _updateDamageFun );
    }

    private function _updateDamageFun(e:CGoldInstanceEvent):void{
        _fightUI.gold_damageUI.txt_damage.text = e.data.damage.toString();
    }

    private function _startTimeFun(e:CGoldInstanceEvent):void{
        var time:int = e.data.time;
        _fightUI.gold_damageUI.txt_second.text = time.toString()+"s";
        _fightUI.gold_damageUI.txt_damage.text = "0";
        clearInterval( _timeStampIntervelID );
        _timeStampIntervelID = setInterval(function():void{
            time -= 1;
            if(time<=1){
                clearInterval( _timeStampIntervelID );
            }
            _fightUI.gold_damageUI.txt_second.text = time.toString()+"s";
        },1000)
    }

    private function _addGoldFun(e:CGoldInstanceEvent):void{
        var goldFrameClip:FrameClip = new FrameClip("frameclip_jinbi902");
        goldFrameClip.autoPlay = true;
        goldFrameClip.interval = 33;
        goldFrameClip.x = e.data.startPos.x;
        goldFrameClip.y = e.data.startPos.y;
        _fightUI.addChild(goldFrameClip);
        var _x:int = _fightUI.gold_ui.x+_fightUI.gold_ui.img_gold.x+_fightUI.gold_ui.img_gold.width/2 - 5;
        var _y:int = _fightUI.gold_ui.y+_fightUI.gold_ui.img_gold.y+_fightUI.gold_ui.img_gold.height/2 - 5;
        TweenLite.to(goldFrameClip,2,{x:_x,y:_y,scaleX:0.5,scaleY:0.5, onComplete:function () : void {
                _fightUI.gold_ui.txt_goldNum.text = e.data.goldNum.toString();
                goldFrameClip.gotoAndStop(0);
                _fightUI.removeChild(goldFrameClip);
                goldFrameClip = null;
            }
        });
        _fightUI.gold_ui.goldIcon_list.dataSource = e.data.countArr;
    }

    private function _renderItem(item:Component, idx:int):void{
        if(idx == 3 && item.dataSource != 0){
            (item.getChildByName("clip_icon" ) as Clip).index = idx+1;
        }else{
            (item.getChildByName("clip_icon" ) as Clip).index = idx;
        }

        (item.getChildByName("txt_count" ) as Label).text = item.dataSource.toString();
    }

    private function _enterInstance( e : CInstanceEvent ) : void {
        var _instanceDate:CChapterInstanceData = (system.stage.getSystem(CInstanceSystem) as CInstanceSystem).getInstanceByID(int(e.data));
        if ( _instanceDate.instanceType == EInstanceType.TYPE_GOLD_INSTANCE ) {
            _fightUI.gold_ui.visible = true;
            _fightUI.gold_damageUI.visible = true;
            _initView();
        } else {
            _fightUI.gold_ui.visible = false;
            _fightUI.gold_damageUI.visible = false;
        }
    }

    private function _initView() : void {
        _fightUI.gold_ui.txt_goldNum.text = "0";
        _fightUI.gold_damageUI.txt_damage.text = "0";
        _fightUI.gold_ui.goldIcon_list.dataSource = [0,0,0,0];
        _fightUI.gold_ui.goldIcon_list.renderHandler = new Handler(_renderItem);
        if ( !App.loader.getResLoaded( "frameclip_gold.swf" ) ) {
            App.loader.loadAssets( [ "frameclip_gold.swf" ]);
        }
    }

    override public function dispose() : void {
        super.dispose();
        (system.stage.getSystem( CInstanceSystem ) as CInstanceSystem).removeEventListener( CInstanceEvent.ENTER_INSTANCE, _enterInstance );
        (system.stage.getSystem( CResourceInstanceSystem ) as CResourceInstanceSystem).removeEventListener( CGoldInstanceEvent.ADD_GOLD, _addGoldFun );
    }
}
}
