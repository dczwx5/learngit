//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2016/5/26.
 * 队友信息
 */
package kof.game.fightui.compoment {

import com.greensock.TweenLite;

import flash.display.DisplayObject;
import flash.events.MouseEvent;

import kof.framework.CViewHandler;
import kof.framework.events.CPropertyUpdateEvent;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.character.CFacadeMediator;
import kof.game.character.handler.CPlayHandler;
import kof.game.character.property.CPlayerProperty;
import kof.game.character.property.interfaces.ICharacterProperty;
import kof.game.core.CECSLoop;
import kof.game.core.CGameObject;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.event.CInstanceEvent;
import kof.game.player.config.CPlayerPath;
import kof.game.scene.ISceneFacade;
import kof.ui.components.KOFProgressBar;
import kof.ui.demo.TeammateUI;

import morn.core.components.Component;
import morn.core.components.Image;
import morn.core.components.List;
import morn.core.handlers.Handler;

public class CTeammateViewHandler extends CViewHandler {

    private var _tweenLiteAry:Array;

    private var m_list:List;

    public function CTeammateViewHandler( ) {
        super();
        _tweenLiteAry = [];
    }
    public function setData(hero:CGameObject,list : List, qImg:Image, eImage:Image, canQE:Boolean):void {
        hide();
        if(  !hero )
            return;

        m_list = list;

        var pScene : ISceneFacade = system.stage.getSystem( ISceneFacade ) as ISceneFacade;
        var heroAsList:Vector.<CGameObject> = pScene.findHeroAsList();
        if(!heroAsList)
                return;
        var ary:Array = [];
        for(var i:int = 0 ; i < heroAsList.length;  i++ ){
            if(CCharacterDataDescriptor.getID(hero.data) == CCharacterDataDescriptor.getID(heroAsList[i ].data))
                    continue;
            ary.push(heroAsList[i]);
        }

        m_list.renderHandler = new Handler(renderTeammate);
        m_list.dataSource = ary;

        m_list.visible = ary.length > 0;

        if (canQE) {
            m_list.mouseHandler = new Handler(_onQESelectHero);
            if (qImg) {
                qImg.visible = ary.length > 0;
            }
            if (eImage) {
                eImage.visible = ary.length > 1;
            }
        } else {
            m_list.mouseHandler = null;
            if (qImg) {
                qImg.visible = false;
            }
            if (eImage) {
                eImage.visible = false;
            }
        }

        system.stage.getSystem(CInstanceSystem ).addEventListener(CInstanceEvent.LEVEL_STARTED, _onLevelStartHandler);
    }

    private function _onLevelStartHandler(e:CInstanceEvent):void
    {
        var ary:Array = [];
        var pScene : ISceneFacade = system.stage.getSystem( ISceneFacade ) as ISceneFacade;
        pScene.initialHeroShowList();
        var heroAsList:Vector.<CGameObject> = pScene.findHeroAsList();
        for(var i:int = 0 ; i < heroAsList.length;  i++ ){
            if( CCharacterDataDescriptor.isHero(heroAsList[ i ].data))
                continue;
            ary.push(heroAsList[i]);
        }

        if(m_list.renderHandler == null)
        {
            m_list.renderHandler = new Handler(renderTeammate);
        }

        m_list.dataSource = ary;
    }

    private function _onQESelectHero(e:MouseEvent, idx:int):void {
        if (e.type == MouseEvent.CLICK ) {
            var playHandler : CPlayHandler = (system.stage.getSystem( CECSLoop ) as CECSLoop).getBean( CPlayHandler ) as CPlayHandler;
            var pHero:CGameObject = playHandler.hero;
            if (pHero) {
                var pFacade:CFacadeMediator = pHero.getComponentByClass(CFacadeMediator, true) as CFacadeMediator;
                if (idx == 0) {
                    pFacade.switchQItem();
                } else {
                    pFacade.switchEItem();
                }
            }
        }

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

        var hpValue:Number = 0;
        if( property )
             hpValue = int(( property.HP/property.MaxHP)*100)/100;
        pRoleHead.pro_hp.value = hpValue;

        var pPlayerProperty : CPlayerProperty = pRoleHead.dataSource.getComponentByClass( CPlayerProperty, true ) as CPlayerProperty;
        if( pPlayerProperty ){
            var pHeroEventMediator: CEventMediator = pPlayerProperty.getComponent( CEventMediator ) as CEventMediator;
            if ( pHeroEventMediator )
                pHeroEventMediator.addEventListener(CCharacterEvent.CHARACTER_PROPERTY_UPDATE,_onPropertyUpdate, false, 0, true );
            if( property )
                propertyChange(property,pRoleHead);
        }

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
        TweenLite.to(pRoleHead.pro_hp,.8,{value:hpValue ,onComplete:onComplete,onCompleteParams:[pRoleHead.pro_hp]});

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
        if (showQEEffect && enNum >= 3) {
            if (!pRoleHead.full_power_clip.visible) {
                pRoleHead.full_power_clip.visible = true;
                pRoleHead.full_power_clip.play();
            }
        } else {
            if (pRoleHead.full_power_clip.visible) {
                pRoleHead.full_power_clip.visible = false;
                pRoleHead.full_power_clip.stop();
            }
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
        _tweenLiteAry.splice(_tweenLiteAry.indexOf(pro),1);
    }

    public var showQEEffect:Boolean = true;

}


}
