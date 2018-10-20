//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/11/15.
 */
package kof.game.player.view.playerNew.view {

import com.greensock.TimelineLite;
import com.greensock.TweenMax;

import flash.filters.BlurFilter;
import flash.geom.Point;

import kof.framework.CViewHandler;
import kof.game.audio.IAudio;
import kof.game.common.CBitmapNumberText;
import kof.game.common.CFlyPointEffect;
import kof.game.common.CUIFactory;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.CInstanceUIHandler;
import kof.game.instance.mainInstance.enum.EInstanceWndType;
import kof.game.instance.mainInstance.view.instanceScenario.CInstanceScenarioView;
import kof.game.lobby.CLobbySystem;
import kof.game.lobby.view.CPlayerHeadViewHandler;
import kof.game.player.CPlayerSystem;
import kof.game.player.CPlayerUIHandler;
import kof.game.player.enum.EPlayerWndType;
import kof.game.player.view.heroGet.CHeroGetViewHandler;
import kof.game.player.view.heroGet.CPlayerHeroGetView;
import kof.game.playerCard.util.CTransformSpr;
import kof.ui.CUISystem;
import kof.ui.components.KOFNum;
import kof.ui.master.combatChange.CombatUpViewUI;

import morn.core.handlers.Handler;

public class CCombatUpViewHandler extends CViewHandler {

    private var m_bViewInitialized : Boolean;
    private var m_pViewUI:CombatUpViewUI;
    private var m_pCombatValueTxt:CBitmapNumberText;
    private var m_pAddValueTxt:CBitmapNumberText;
    private var m_pAddValueTxtCopy:CBitmapNumberText;
    private var m_iOldCombat:int;
    private var m_iNewCombat:int;
    private var m_pTransformSpr:CTransformSpr;
    private var m_pTimeline1:TimelineLite;
    private var m_pTimeline2:TimelineLite;
    private var m_bVisible:Boolean = true;
    private static var _filter:BlurFilter = new BlurFilter(20, 5);

    public function CCombatUpViewHandler( bLoadViewByDefault : Boolean = true )
    {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
        return [CombatUpViewUI];
    }

    override protected function onAssetsLoadCompleted() : void
    {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean
    {
        if ( !super.onInitializeView() )
        {
            return false;
        }

        if ( !m_bViewInitialized )
        {
            if ( !m_pViewUI )
            {
                m_pViewUI = new CombatUpViewUI();

                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }

    public function addDisplay() : void
    {
        this.loadAssetsByView( viewClass, _showDisplay );
    }

    protected function _showDisplay() : void
    {
        if ( onInitializeView() )
        {
            _addToDisplay();
        }
        else
        {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    private function _addToDisplay() : void
    {
        if(m_pViewUI.parent == null)
        {
            (uiCanvas as CUISystem).effectLayer.addChild(m_pViewUI);
            m_pViewUI.x = system.stage.flashStage.stageWidth - m_pViewUI.width >> 1;
            m_pViewUI.y = system.stage.flashStage.stageHeight - 200;

            _addListeners();
        }
        else
        {
            _clear();
        }

        _initView();
    }

    private function _initView():void
    {
        visible = m_bVisible;

        if(m_pCombatValueTxt == null)
        {
            m_pCombatValueTxt = CUIFactory.gBitmapNumberText(90, 3, 21, 31, "png.common.nums.kofnum_zhandouli2", m_pViewUI.box_combat,
                    -1, 0, "", 10);
            m_pCombatValueTxt.rollDirection = CBitmapNumberText.Left;
            m_pCombatValueTxt.callBack = _onRollComplHandler;
        }

        if(m_pAddValueTxt == null)
        {
            m_pAddValueTxt = CUIFactory.gBitmapNumberText(0, 0, 21, 31, "png.common.nums.kofnum_zhandouli2", m_pViewUI.box_combat,
                    -1, 0, "", 10);
        }

        if(m_pAddValueTxtCopy == null)
        {
            m_pAddValueTxtCopy = CUIFactory.gBitmapNumberText(0, 0, 21, 31, "png.common.nums.kofnum_zhandouli2", m_pViewUI.box_combat,
                    -1, 0, "", 10);
        }

        m_pCombatValueTxt.x = 90;
        m_pCombatValueTxt.y = 3;
        m_pAddValueTxt.y = 3;
        m_pAddValueTxtCopy.y = 3;
        m_pViewUI.box_combat.x = 0;
        m_pViewUI.box_combat.y = 0;

        if(m_pTransformSpr == null)
        {
            m_pTransformSpr = CUIFactory.getTransformSpr();
            m_pViewUI.addChild(m_pTransformSpr);
        }

        m_pTransformSpr.alpha = 0;

        m_pCombatValueTxt.value = m_iOldCombat;
        m_pAddValueTxt.text = "+" + (m_iNewCombat - m_iOldCombat);
        m_pAddValueTxtCopy.text = "+" + (m_iNewCombat - m_iOldCombat);

        m_pCombatValueTxt.visible = false;
        m_pAddValueTxt.visible = false;
        m_pAddValueTxtCopy.visible = false;
        m_pViewUI.box_combat.visible = false;
        m_pViewUI.txt_addValue.visible = false;

        delayCall(0.1, _startAnimation);
    }

    private function _startAnimation():void
    {
        if(m_pCombatValueTxt == null)
        {
            return;
        }

        m_pViewUI.box_combat.visible = true;

        m_pCombatValueTxt.visible = true;
        m_pCombatValueTxt.filters = [_filter];
        m_pViewUI.box_combat.filters = [_filter];

        m_pAddValueTxt.visible = true;
        m_pAddValueTxt.filters = [_filter];
        var addValueX:int = 90 + m_pCombatValueTxt.width + 10;

        if(m_pTimeline1 == null)
        {
            m_pTimeline1 = new TimelineLite();
        }

//        m_pTimeline1.insert(TweenMax.fromTo(m_pCombatValueTxt, 0.2, {x:-260, alpha:0}, {x:90, alpha:1}));
        m_pTimeline1.insert(TweenMax.fromTo(m_pViewUI.box_combat, 0.2, {x:0 - m_pViewUI.x, alpha:0}, {x:0, alpha:1, onComplete:onCompleteHandler}));
        var diff:int = system.stage.flashStage.stageWidth - addValueX;
//        m_pTimeline1.insert(TweenMax.fromTo(m_pAddValueTxt, 0.2, {x:addValueX + 260+200, alpha:0}, {x:addValueX, alpha:1}));
        m_pTimeline1.insert(TweenMax.fromTo(m_pAddValueTxt, 0.2, {x:addValueX + diff, alpha:0}, {x:addValueX, alpha:1}));

        function onCompleteHandler():void
        {
            m_pCombatValueTxt.filters = null;
            m_pAddValueTxt.filters = null;
            m_pViewUI.box_combat.filters = null;

            delayCall(0.5, _startRolling);
        }
    }

    private function _startRolling():void
    {
        var oldWidth:int = m_pCombatValueTxt.width;

        if(m_pCombatValueTxt)
        {
            m_pCombatValueTxt.rollingToValue(m_iNewCombat);
        }

        var newWidth:int = m_pCombatValueTxt.width;
        var toX:int = 90 + m_pCombatValueTxt.width + 10;
        if(oldWidth != newWidth)
        {
            TweenMax.to(m_pAddValueTxt, 0.1, {x:toX});
        }
    }

    private function _onRollComplHandler():void
    {
        m_pViewUI.addChild(m_pAddValueTxtCopy);
        m_pAddValueTxtCopy.x = m_pAddValueTxt.x;
        m_pAddValueTxtCopy.y = m_pAddValueTxt.y;
        m_pAddValueTxtCopy.visible = true;

        m_pTransformSpr.transformObj = m_pAddValueTxtCopy;
        TweenMax.fromTo(m_pTransformSpr, 0.6, {scale:1, alpha:1}, {scale:1.8, alpha:0});

        delayCall(0.8, _onFadeoutHandler);
    }

    /*
    private function _showAddValue():void
    {
        if(m_pCombatValueTxt == null)
        {
            return;
        }

        var toX:int = Math.abs(m_pCombatValueTxt.x) + m_pCombatValueTxt.width + 10;
        var toY:int = Math.abs(m_pCombatValueTxt.y);
        m_pViewUI.txt_addValue.text = "+" + (m_iNewCombat - m_iOldCombat);
        m_pAddValueTxt.text = "+" + (m_iNewCombat - m_iOldCombat);

        TweenMax.fromTo(m_pAddValueTxt, 0.2, {x:toX, y:toY + 50, alpha:0}, {x:toX, y:toY, alpha:1});
        TweenMax.fromTo(m_pAddValueTxt, 0.2, {x:toX, y:toY, alpha:1}, {x:toX, y:toY - 50, alpha:0, delay:1, onComplete:_onAddValueCompl});
    }

    private function _onAddValueCompl():void
    {
        _flyPointEffect();

        m_pCombatValueTxt.filters = [_filter];
        m_pViewUI.box_combat.filters = [_filter];
        TweenMax.to(m_pCombatValueTxt, 0.2, {x:-260, alpha:0});
        TweenMax.to(m_pViewUI.box_combat, 0.25, {x:-260, alpha:0, onComplete:_onLastCompl});
    }
    */

    private function _onFadeoutHandler():void
    {
        _flyPointEffect();

        m_pCombatValueTxt.filters = [_filter];
        m_pViewUI.box_combat.filters = [_filter];
        m_pAddValueTxt.filters = [_filter];
        var addValueX:int = 90 + m_pCombatValueTxt.width + 10;

        if(m_pTimeline2 == null)
        {
            m_pTimeline2 = new TimelineLite();
        }

//        m_pTimeline2.insert(TweenMax.to(m_pCombatValueTxt, 0.2, {x:-260, alpha:0}));
        var diff:int = system.stage.flashStage.stageWidth - addValueX;
//        m_pTimeline2.insert(TweenMax.to(m_pAddValueTxt, 0.2, {x:addValueX+260+200, alpha:0}));
        m_pTimeline2.insert(TweenMax.to(m_pAddValueTxt, 0.2, {x:addValueX + diff, alpha:0}));
        m_pTimeline2.insert(TweenMax.to(m_pViewUI.box_combat, 0.25, {x:0 - m_pViewUI.x, alpha:0, onComplete:_onLastCompl}));
    }

    private function _flyPointEffect():void
    {
        var startPoint:Point = m_pCombatValueTxt.localToGlobal(new Point(m_pCombatValueTxt.width/2, 0));
        var headView:CPlayerHeadViewHandler = (system.stage.getSystem(CLobbySystem ).getHandler(CPlayerHeadViewHandler)) as CPlayerHeadViewHandler;
        if(headView && headView.viewUI)
        {
            var combatNum:KOFNum = headView.viewUI.numFightScore;
            var endPoint:Point = combatNum.localToGlobal(new Point(combatNum.width/2, 0));
            CFlyPointEffect.instance.play(startPoint, endPoint, system, 40, 80, _playCombatEffect);
            CFlyPointEffect.instance.visible = _isShowEffect();

            var audio:IAudio = system.stage.getSystem(IAudio) as IAudio;
            if(audio)
            {
                audio.playAudioByName("zhanli", 1, 0);
            }
        }
    }

    private function _isShowEffect():Boolean
    {
        var instanceSystem:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if(instanceSystem)
        {
            if(!instanceSystem.isMainCity)
            {
                return false;
            }
        }

//        var uiHandler:CPlayerUIHandler = system.getHandler(CPlayerUIHandler) as CPlayerUIHandler;
//        var heroGetView:CPlayerHeroGetView = uiHandler.getCreatedWindow(EPlayerWndType.WND_PLAYER_HERO_GET) as CPlayerHeroGetView;
//        if(heroGetView && heroGetView._ui && heroGetView._ui.parent)
//        {
//            return false;
//        }

        var heroGetView:CHeroGetViewHandler = system.getHandler(CHeroGetViewHandler) as CHeroGetViewHandler;
        if(heroGetView && heroGetView.isViewShow)
        {
            return false;
        }

        var instanceUIHandler:CInstanceUIHandler = system.stage.getSystem(CInstanceSystem ).getHandler(CInstanceUIHandler) as CInstanceUIHandler;
        var instanceView:CInstanceScenarioView = instanceUIHandler.getCreatedWindow(EInstanceWndType.WND_INSTANCE_SCENARIO) as CInstanceScenarioView;
        if(instanceView && instanceView._ui && instanceView._ui.parent)
        {
            return false;
        }

        var instanceView2:CInstanceScenarioView = instanceUIHandler.getCreatedWindow(EInstanceWndType.WND_INSTANCE_ELITE) as CInstanceScenarioView;
        if(instanceView2 && instanceView2._ui && instanceView2._ui.parent)
        {
            return false;
        }

        return true;
    }

    private function _playCombatEffect():void
    {
        var headView:CPlayerHeadViewHandler = (system.stage.getSystem(CLobbySystem ).getHandler(CPlayerHeadViewHandler)) as CPlayerHeadViewHandler;
        if(headView)
        {
            headView.viewUI.clip_combatEffect.visible = true;
            headView.viewUI.clip_combatEffect.playFromTo(null,null,new Handler(_onComplHandler));
            function _onComplHandler():void
            {
                headView.viewUI.clip_combatEffect.visible = false;
                headView.viewUI.clip_combatEffect.gotoAndStop(1);
            }

            var newCombat:int = (system as CPlayerSystem).playerData.teamData.battleValue;
            headView.updateCombat(newCombat);
        }
    }

    private function _onLastCompl():void
    {
        removeDisplay();
    }

    public function setData(oldCombat:int, newCombat:int):void
    {
        m_iOldCombat = oldCombat;
        m_iNewCombat = newCombat;
    }

    public function removeDisplay() : void
    {
        if(m_bViewInitialized)
        {
            _removeListeners();

            if (m_pViewUI && m_pViewUI.parent)
            {
                m_pViewUI.parent.removeChild(m_pViewUI);
            }

            if(m_pCombatValueTxt)
            {
                m_pCombatValueTxt.dispose();
                m_pCombatValueTxt.alpha = 1;
                m_pCombatValueTxt.filters = null;
                m_pCombatValueTxt = null;
            }

            if(m_pAddValueTxt)
            {
                m_pAddValueTxt.dispose();
                m_pAddValueTxt.alpha = 1;
                m_pAddValueTxt = null;
            }

            if(m_pAddValueTxtCopy)
            {
                m_pAddValueTxtCopy.dispose();
                m_pAddValueTxtCopy.alpha = 1;
                m_pAddValueTxtCopy = null;
            }

            if(m_pTransformSpr)
            {
                m_pTransformSpr.dispose();
                m_pTransformSpr = null;
            }

            m_pViewUI.box_combat.filters = null;
            m_pViewUI.box_combat.alpha = 1;

            if(m_pTimeline1)
            {
                m_pTimeline1._kill();
                m_pTimeline1.clear();
                m_pTimeline1 = null;
            }

            if(m_pTimeline2)
            {
                m_pTimeline2._kill();
                m_pTimeline2.clear();
                m_pTimeline2 = null;
            }

            m_iOldCombat = 0;
            m_iNewCombat = 0;
        }
    }

    private function _clear():void
    {
        unschedule(_startAnimation);
        unschedule(_startRolling);
        unschedule(_onFadeoutHandler);

        if(m_pCombatValueTxt)
        {
            m_pCombatValueTxt.alpha = 1;
            m_pCombatValueTxt.filters = null;
            m_pCombatValueTxt.text = "";
        }

        if(m_pAddValueTxt)
        {
            m_pAddValueTxt.alpha = 1;
            m_pAddValueTxt.filters = null;
            m_pAddValueTxt.text = "";
        }

        if(m_pTimeline1)
        {
            m_pTimeline1._kill();
            m_pTimeline1.clear();
        }

        if(m_pTimeline2)
        {
            m_pTimeline2._kill();
            m_pTimeline2.clear();
        }

        if(m_pTransformSpr)
        {
            TweenMax.killTweensOf(m_pTransformSpr);
            m_pTransformSpr.clear();
        }

        if(m_pAddValueTxtCopy)
        {
            m_pAddValueTxtCopy.visible = false;
            m_pAddValueTxtCopy.text = "";
        }
    }

    private function _addListeners():void
    {
    }

    private function _removeListeners():void
    {
    }

    override protected function updateDisplay():void
    {
    }

    public function set visible(value:Boolean):void
    {
        m_bVisible = value;

        if(m_pViewUI)
        {
            m_pViewUI.visible = value;
        }
    }

    public function get isViewShow():Boolean
    {
        return m_pViewUI && m_pViewUI.parent;
    }

}
}
