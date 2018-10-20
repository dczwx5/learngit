//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/10/8.
 */
package kof.game.player.view.playerNew.view.heroDevelop {

import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

import kof.framework.CViewHandler;
import kof.game.audio.IAudio;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.event.CPlayerEvent;
import kof.game.player.view.playerNew.data.CHeroAttrData;
import kof.game.player.view.playerNew.data.CQualityResultData;
import kof.game.player.view.playerNew.util.CPlayerHelpHandler;
import kof.game.reciprocation.CReciprocalSystem;
import kof.game.reciprocation.popWindow.EPopWindow;
import kof.ui.CUISystem;
import kof.ui.IUICanvas;
import kof.ui.master.jueseNew.resultWin.HeroQualitySuccWinUI;

import morn.core.components.Box;

import morn.core.components.Component;

import morn.core.components.Dialog;
import morn.core.components.FrameClip;
import morn.core.components.Label;
import morn.core.handlers.Handler;

public class CHeroQualitySuccViewHandler extends CViewHandler {

    private var m_bViewInitialized : Boolean;
    private var m_pViewUI:HeroQualitySuccWinUI;

    private var m_iCount:int;
    private const _CloseCountdownNum:int = 60;

    public function CHeroQualitySuccViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
        return [HeroQualitySuccWinUI];
    }

    override  protected function get additionalAssets() : Array
    {
        return ["frameclip_qualityAdvance.swf"];
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
                m_pViewUI = new HeroQualitySuccWinUI();
                m_pViewUI.btn_confirm.clickHandler = new Handler(_onClickHandler);
                m_pViewUI.list_attr.renderHandler = new Handler(_renderOldAttr);
                m_pViewUI.list_attr2.renderHandler = new Handler(_renderNewAttr);

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
//            invalidate();
            callLater( _addToDisplay );
        }
        else
        {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    private function _addToDisplay() : void
    {
        uiCanvas.addPopupDialog(m_pViewUI);

        _addListeners();
        _initView();
    }

    private function _addListeners():void
    {
//        system.addEventListener(CPlayerEvent.HERO_DATA,_onHeroDataUpdateHandler);
        system.stage.flashStage.addEventListener(KeyboardEvent.KEY_UP, _onKeyboardUp, false, 0, true);
    }

    private function _removeListeners():void
    {
//        system.removeEventListener(CPlayerEvent.HERO_DATA,_onHeroDataUpdateHandler);
        system.stage.flashStage.removeEventListener(KeyboardEvent.KEY_UP, _onKeyboardUp);
    }

    private function _initView():void
    {
        m_pViewUI.box_combat2.visible = false;
//        m_pViewUI.img_combatBg.visible = false;

        m_iCount = _CloseCountdownNum;
        m_pViewUI.btn_confirm.label = "确定("+ m_iCount +"s)";

        updateDisplay();

        _startAnimation();

        schedule(1, _onScheduleHandler);
    }

    private function _onScheduleHandler(delta : Number):void
    {
        m_iCount--;
        if(m_iCount <= 0)
        {
            removeDisplay();
        }
        else
        {
            m_pViewUI.btn_confirm.label = "确 定("+ m_iCount +"s)";
        }
    }

    override protected function updateDisplay():void
    {
        _updateQualityInfo();
        _updateCombatInfo();
        _updateAttrInfo();
    }

    private function _updateQualityInfo():void
    {
        var resultData:CQualityResultData = _playerHelper.qualityResultData;
        if(resultData && resultData.heroId)
        {
            m_pViewUI.txt_quality_before.isHtml = true;
            m_pViewUI.txt_quality_before.text = resultData.oldQualityName;

            m_pViewUI.txt_quality_after.isHtml = true;
            m_pViewUI.txt_quality_after.text = resultData.newQualityName;

            var heroData:CPlayerHeroData = (system as CPlayerSystem).playerData.heroList.getHero(resultData.heroId);

//            m_pViewUI.view_head_before.clip_career.index = heroData.job;
            m_pViewUI.view_head_before.clip_career.visible = false;
            (system as CPlayerSystem).showCareerTips(m_pViewUI.view_head_before.clip_career);
            m_pViewUI.view_head_before.clip_intell.index = heroData.qualityBaseType;
//            m_pViewUI.view_head_before.quality_clip.index = resultData.oldQualityLevelValue;
            m_pViewUI.view_head_before.quality_clip.index = 0;
            m_pViewUI.view_head_before.icon_image.mask = m_pViewUI.view_head_before.hero_icon_mask;
            m_pViewUI.view_head_before.icon_image.url = CPlayerPath.getUIHeroIconMiddlePath(resultData.heroId);
            m_pViewUI.view_head_before.star_list.dataSource = [];

//            m_pViewUI.view_head_after.clip_career.index = heroData.job;
            m_pViewUI.view_head_after.clip_career.visible = false;
            (system as CPlayerSystem).showCareerTips(m_pViewUI.view_head_after.clip_career);
            m_pViewUI.view_head_after.clip_intell.index = heroData.qualityBaseType;
//            m_pViewUI.view_head_after.quality_clip.index = resultData.newQualityLevelValue;
            m_pViewUI.view_head_after.quality_clip.index = 0;
            m_pViewUI.view_head_after.icon_image.mask = m_pViewUI.view_head_after.hero_icon_mask;
            m_pViewUI.view_head_after.icon_image.url = CPlayerPath.getUIHeroIconMiddlePath(resultData.heroId);
            m_pViewUI.view_head_after.star_list.dataSource = [];
        }
    }

    private function _updateCombatInfo():void
    {
        var resultData:CQualityResultData = _playerHelper.qualityResultData;
        if(resultData)
        {
            m_pViewUI.txt_combat.text = resultData.oldCombat.toString();
//            m_pViewUI.txt_combat_upValue.text = "+" + (resultData.newCombat - resultData.oldCombat);
            m_pViewUI.txt_combat2.text = resultData.newCombat.toString();
        }
    }

    private function _updateAttrInfo():void
    {
        var resultData:CQualityResultData = _playerHelper.qualityResultData;
        if(resultData)
        {
            if(resultData.oldAttr && resultData.newAttr)
            {
                m_pViewUI.list_attr.dataSource = _getOldAttrData();
                m_pViewUI.list_attr2.dataSource = _getNewAttrData();
            }
        }
    }

    private function _getOldAttrData():Array
    {
        var resultArr:Array = [];
        var resultData:CQualityResultData = _playerHelper.qualityResultData;
        if(resultData)
        {
            var len:int = resultData.oldAttr.length;
            for(var i:int = 0; i < len; i++)
            {
                var oldAttrData:CHeroAttrData = resultData.oldAttr[i];
                if(oldAttrData)
                {
                    var attrData:CHeroAttrData = new CHeroAttrData();
                    attrData.attrBaseValue = oldAttrData.attrBaseValue;
                    attrData.attrNameCN = oldAttrData.getAttrNameCN();
                    resultArr.push(attrData);
                }
            }
        }

        return resultArr;
    }

    private function _getNewAttrData():Array
    {
        var resultArr:Array = [];
        var resultData:CQualityResultData = _playerHelper.qualityResultData;
        if(resultData)
        {
            var len:int = resultData.newAttr.length;
            for(var i:int = 0; i < len; i++)
            {
                var newAttrData:CHeroAttrData = resultData.newAttr[i];
                var oldAttrData:CHeroAttrData = resultData.oldAttr[i];
                if(newAttrData && oldAttrData)
                {
                    var attrData:CHeroAttrData = new CHeroAttrData();
                    attrData.attrBaseValue = newAttrData.attrBaseValue;
                    attrData.attrNameCN = newAttrData.getAttrNameCN();
                    attrData.qualityUpValue = newAttrData.attrBaseValue - oldAttrData.attrBaseValue;
                    resultArr.push(attrData);
                }
            }
        }

        return resultArr;
    }

    private function _startAnimation():void
    {
        m_pViewUI.frameClip_title.playFromTo(null,null,new Handler(_onAnimationComplHandler));
        function _onAnimationComplHandler():void
        {
        }

        delayCall(0.5, _combatAnimation);
    }

    private function _combatAnimation():void
    {
//        m_pViewUI.img_combatBg.visible = true;
        m_pViewUI.box_combat2.visible = true;
        m_pViewUI.clip_effect_1.visible = true;
        m_pViewUI.clip_effect_1.playFromTo(null,null,new Handler(_onAnimationComplHandler));
        function _onAnimationComplHandler():void
        {
            m_pViewUI.clip_effect_1.visible = false;
            m_pViewUI.clip_effect_1.gotoAndStop(1);
        }

        delayCall(0.2, _attrAnimation);
    }

    private function _attrAnimation():void
    {
        var dataArr:Array = m_pViewUI.list_attr2.dataSource as Array;
        if(dataArr && dataArr.length)
        {
            for(var i:int = 0; i < dataArr.length; i++)
            {
                _delayPlay(i, i * 0.2);
            }
        }
    }

    private function _delayPlay(index:int, delayTime:Number):void
    {
        var item:Box = m_pViewUI.list_attr2.getCell(index);
        var clip:FrameClip = m_pViewUI["clip_effect_" + (index+2)];
        if(clip)
        {
            delayCall(delayTime, play);

            function play():void
            {
                item.visible = true;
                clip.visible = true;
                clip.playFromTo(null,null,new Handler(_onAnimationComplHandler));
                function _onAnimationComplHandler():void
                {
                    clip.visible = false;
                    clip.gotoAndStop(1);
                }

                var audio:IAudio = system.stage.getSystem(IAudio) as IAudio;
                if(audio)
                {
                    audio.playAudioByName("shuxingshan", 1, 0, 1);
                }
            }
        }
    }

    private function _onHeroDataUpdateHandler(e:CPlayerEvent):void
    {
        delayCall(0.2,updateDisplay);
    }

    private function _onClickHandler():void
    {
        removeDisplay();
    }

    public function removeDisplay() : void
    {
        if(m_bViewInitialized)
        {
            _removeListeners();

            unschedule(_onScheduleHandler);

            if(m_pViewUI && m_pViewUI.parent)
            {
                m_pViewUI.close(Dialog.CLOSE);
            }

            if(m_pViewUI.frameClip_title.isPlaying)
            {
                m_pViewUI.frameClip_title.stop();
            }

            for(var i:int = 1; i <= 4; i++)
            {
                var clip:FrameClip = m_pViewUI["clip_effect_"+i] as FrameClip;
                if(clip && clip.isPlaying)
                {
                    clip.stop();
                }
            }

            m_pViewUI.list_attr.dataSource = [];
            m_pViewUI.list_attr2.dataSource = [];

            var resultData:CQualityResultData = _playerHelper.qualityResultData;
            if(resultData)
            {
                resultData.clearData();
            }
        }

        var pReciprocalSystem:CReciprocalSystem = (system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem);
        if(pReciprocalSystem){
            pReciprocalSystem.removeEventPopWindow( EPopWindow.POP_WINDOW_6 );
        }
    }

    private function _renderOldAttr(item:Component, index:int):void
    {
        if(!(item is Box))
        {
            return;
        }

        var render:Box = item as Box;
        var data:CHeroAttrData = render.dataSource as CHeroAttrData;
        var attrName:Label = render.getChildByName("txt_attrName") as Label;
        var attrValue:Label = render.getChildByName("txt_attrValue") as Label;
//        var upValue:Label = render.getChildByName("txt_upValue") as Label;
        if(null != data)
        {
            attrName.text = data.getAttrNameCN();
            attrValue.text = data.attrBaseValue.toString();
//            upValue.text = "+" + data.qualityUpValue;
        }
        else
        {
            attrName.text = "";
            attrValue.text = "";
//            upValue.text = "";
        }

//        render.visible = false;
    }

    private function _renderNewAttr(item:Component, index:int):void
    {
        if(!(item is Box))
        {
            return;
        }

        var render:Box = item as Box;
        var data:CHeroAttrData = render.dataSource as CHeroAttrData;
        var attrName:Label = render.getChildByName("txt_attrName2") as Label;
        var attrValue:Label = render.getChildByName("txt_attrValue2") as Label;
//        var upValue:Label = render.getChildByName("txt_upValue2") as Label;
        if(null != data)
        {
            attrName.text = data.getAttrNameCN();
            attrValue.text = data.attrBaseValue.toString();
//            upValue.text = "+" + data.qualityUpValue;
        }
        else
        {
            attrName.text = "";
            attrValue.text = "";
//            upValue.text = "";
        }

        render.visible = false;
    }

    public function updateInfo():void
    {
        if(isViewShow)
        {
            updateDisplay();

            delayCall(0.1,setVisible);
            function setVisible():void
            {
                var dataArr:Array = m_pViewUI.list_attr.dataSource as Array;
                if(dataArr && dataArr.length)
                {
                    for(var i:int = 0; i < dataArr.length; i++)
                    {
                        var item:Box = m_pViewUI.list_attr.getCell(i);
                        item.visible = true;
                    }
                }
            }
        }
    }

    private function _onKeyboardUp(e:KeyboardEvent) : void
    {
        if(e.keyCode == Keyboard.SPACE)
        {
            removeDisplay();
        }
    }

    public function get isViewShow():Boolean
    {
        return m_pViewUI && m_pViewUI.parent;
    }

    protected function get _playerHelper():CPlayerHelpHandler
    {
        return system.getHandler(CPlayerHelpHandler) as CPlayerHelpHandler;
    }
}
}
