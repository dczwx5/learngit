//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2016/11/29.
 */
package kof.game.fightui.compoment {

import com.greensock.TweenLite;

import flash.display.DisplayObject;
import flash.events.Event;

import kof.framework.CViewHandler;
import kof.framework.events.CPropertyUpdateEvent;
import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.character.CTarget;
import kof.game.character.property.CPlayerProperty;
import kof.game.character.property.interfaces.ICharacterProperty;
import kof.game.core.CGameObject;
import kof.game.instance.enum.EInstanceType;
import kof.game.level.CLevelManager;
import kof.game.level.CLevelSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.scene.ISceneFacade;
import kof.ui.components.KOFProgressBar;
import kof.ui.demo.TeammateUI;

import morn.core.components.Component;
import morn.core.components.List;
import morn.core.handlers.Handler;

public class CEnemiesViewHandler extends CViewHandler {

    private var pTarget : CTarget;

    private var _heroEventMediator : CEventMediator;

    private var _tweenLiteAry:Array;

    private var m_list:List;

    public function CEnemiesViewHandler( ) {
        super();
        _tweenLiteAry = [];
    }
    public function setData(hero:CGameObject,list : List):void {
        hide();
        if (  !hero )
            return;
        m_list = list;
        if(_heroEventMediator && _heroEventMediator.owner && _heroEventMediator.owner.isRunning)
            _heroEventMediator.removeEventListener(CCharacterEvent.TARGET_CHANGED ,_onTargetUpdate);
        m_list.visible = false;
        pTarget  = hero.getComponentByClass( CTarget, true ) as CTarget;
        _heroEventMediator = pTarget.getComponent( CEventMediator ) as CEventMediator;
        if ( _heroEventMediator )
            _heroEventMediator.addEventListener(CCharacterEvent.TARGET_CHANGED ,_onTargetUpdate, false, 0, true );
        _onTargetUpdate( null );
    }
    private function _onTargetUpdate(evt:Event):void {

        if( EInstanceType.isWorldBoss (_pLevelManager.instanceType) )
                return;
        var pScene : ISceneFacade = system.stage.getSystem( ISceneFacade ) as ISceneFacade;
        var targetHeroList: Vector.<CGameObject> = pScene.findTargetHeroList(pTarget.targetObject);
        if(!targetHeroList)
            return;
        var ary:Array = [];
        for(var i:int = 0 ; i < targetHeroList.length;  i++ ){
            if(pTarget.targetObject == targetHeroList[i])
                continue;
            ary.push(targetHeroList[i]);
        }
        m_list.dataSource = ary;
        m_list.renderHandler = new Handler(renderTeammate);
        m_list.visible = ary.length > 0;
    }
    private function renderTeammate(item:Component, idx:int):void {
        if (!(item is TeammateUI)) {
            return;
        }
        var pRoleHead:TeammateUI = item as TeammateUI;
        pRoleHead.en_1.visible =
                pRoleHead.en_2.visible =
                        pRoleHead.en_3.visible = false;
        var pMaskDisplayObject : DisplayObject = pRoleHead.getChildByName( 'mask' );
        if ( pMaskDisplayObject ) {
            pRoleHead.img_head.cacheAsBitmap = true;
            pMaskDisplayObject.cacheAsBitmap = true;
            pRoleHead.img_head.mask = pMaskDisplayObject;
        }

        if(!pRoleHead.dataSource)
            return;

        pRoleHead.img_head.url = CPlayerPath.getUIHeroIconBigPath(pRoleHead.dataSource.data.prototypeID);
//        pRoleHead.txt_lv.text = "等级." + pRoleHead.dataSource.data.level;

        var property : ICharacterProperty = pRoleHead.dataSource.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty;
//        pRoleHead.txt_name.text = property.nickName;
        if(!property)
                return;

        var hpValue:Number = int(( property.HP/property.MaxHP)*100)/100;
        pRoleHead.pro_hp.value = hpValue;

        var pPlayerProperty : CPlayerProperty = pRoleHead.dataSource.getComponentByClass( CPlayerProperty, true ) as CPlayerProperty;
        if(!pPlayerProperty)
                return;
        var pHeroEventMediator : CEventMediator = pPlayerProperty.getComponent( CEventMediator ) as CEventMediator;
        if ( pHeroEventMediator )
            pHeroEventMediator.addEventListener(CCharacterEvent.CHARACTER_PROPERTY_UPDATE,_onPropertyUpdate, false, 0, true );
        propertyChange(property,pRoleHead);
    }
    private function _onPropertyUpdate(evt:CPropertyUpdateEvent):void {
        var owner:CGameObject = evt.owner;
        var property : ICharacterProperty = owner.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty;
        for each(var pRoleHead:TeammateUI in m_list.cells){
            if(pRoleHead.dataSource == owner){
                propertyChange(property,pRoleHead);
                break;
            }
        }
    }
    private function  propertyChange(property:ICharacterProperty, pRoleHead:TeammateUI):void {

        var hpValue:Number = int(( property.HP/property.MaxHP)*100)/100;
        TweenLite.killTweensOf(pRoleHead.pro_hp,true);
        _tweenLiteAry.push( pRoleHead.pro_hp );
        TweenLite.to(pRoleHead.pro_hp,.8,{value:hpValue,onComplete:onComplete,onCompleteParams:[pRoleHead.pro_hp]});

//        var defenseValue:Number = int(( property.DefensePower/property.MaxDefensePower)*100)/100;
//        TweenLite.killTweensOf(pRoleHead.pro_def,true);
//        _tweenLiteAry.push( pRoleHead.pro_def );
//        TweenLite.to(pRoleHead.pro_def,.5,{value:defenseValue,onComplete:onComplete,onCompleteParams:[pRoleHead.pro_def]});

//        var attValue:Number = int(( property.AttackPower/property.MaxAttackPower)*100)/100;
//        TweenLite.killTweensOf(pRoleHead.pro_att,true);
//        _tweenLiteAry.push( pRoleHead.pro_att );
//        TweenLite.to(pRoleHead.pro_att,.5,{value:attValue,onComplete:onComplete,onCompleteParams:[pRoleHead.pro_att]});

        var maxValue:int = property.MaxRagePower/property.maxRageCount;
        var enNum:int = Math.floor(property.RagePower/maxValue);
        pRoleHead.en_1.visible =
                pRoleHead.en_2.visible =
                        pRoleHead.en_3.visible = false;
        for( var i:int = 1 ; i <= enNum ; i++ ){
            pRoleHead["en_" + i ].visible = true;
        }
    }
    private function onComplete(pro:KOFProgressBar):void{
        _tweenLiteAry.splice(_tweenLiteAry.indexOf(pro),1);
    }
    private function updateView():void {
    }
    public function hide(removed:Boolean = true):void {
        for each( var pro:KOFProgressBar in _tweenLiteAry){
            TweenLite.killTweensOf(pro,true);
        }
        if(_tweenLiteAry)
            _tweenLiteAry.splice( 0 ,_tweenLiteAry.length );
    }

    private function get _pLevelManager():CLevelManager {
        return  _pLevelSystem.getBean(CLevelManager) as CLevelManager;
    }
    private function get _pLevelSystem():CLevelSystem {
        return  system.stage.getSystem(CLevelSystem) as CLevelSystem;
    }
}
}
