//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/10/9.
 */
package kof.game.player.view.playerNew.view.heroDevelop {

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.geom.Matrix;

import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.KOFSysTags;
import kof.game.audio.IAudio;
import kof.game.common.CUIFactory;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.data.CSkillData;
import kof.game.player.event.CPlayerEvent;
import kof.game.player.view.playerNew.data.CHeroAttrData;
import kof.game.player.view.playerNew.data.CStarResultData;
import kof.game.player.view.playerNew.util.CPlayerHelpHandler;
import kof.game.reciprocation.CReciprocalSystem;
import kof.game.reciprocation.popWindow.EPopWindow;
import kof.table.PassiveSkillUp;
import kof.table.PlayerSkill;
import kof.table.SkillGetCondition;
import kof.ui.master.jueseNew.resultWin.HeroStarSuccWinUI;

import morn.core.components.Box;

import morn.core.components.Component;
import morn.core.components.Dialog;
import morn.core.components.FrameClip;
import morn.core.components.Label;
import morn.core.handlers.Handler;

public class CHeroStarSuccViewHandler extends CViewHandler {

    private var m_bViewInitialized : Boolean;
    private var m_pViewUI:HeroStarSuccWinUI;
    private var m_pSkillFlyViewHandler:CHeroPassSkillFlyViewHandler;
    private var m_sSkillName:String;
    private var m_bHasSkillInfo:Boolean;

    public function CHeroStarSuccViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override protected function onSetup() : Boolean
    {
        var ret : Boolean = super.onSetup();
        ret = ret && onInitialize();
        if ( loadViewByDefault ) {
            ret = ret && loadAssetsByView( viewClass );
            ret = ret && onInitializeView();
        }

        ret = this.addBean(m_pSkillFlyViewHandler = new CHeroPassSkillFlyViewHandler());

        return ret;
    }

    override public function get viewClass() : Array
    {
        return [HeroStarSuccWinUI];
    }

    override  protected function get additionalAssets() : Array
    {
        return ["frameclip_starAdvance.swf"];
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
                m_pViewUI = new HeroStarSuccWinUI();
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

//        _addListeners();
        _initView();
    }

    private function _addListeners():void
    {
        system.addEventListener(CPlayerEvent.HERO_DATA,_onHeroDataUpdateHandler);
    }

    private function _removeListeners():void
    {
        system.removeEventListener(CPlayerEvent.HERO_DATA,_onHeroDataUpdateHandler);
    }

    private function _initView():void
    {
        m_pViewUI.box_combat2.visible = false;
//        m_pViewUI.img_combatBg.visible = false;
        m_pViewUI.clip_starEffect.visible = false;
        m_pViewUI.box_skill.visible = false;
        m_pViewUI.clip_skillOpen.visible = false;
        m_pViewUI.clip_skillSurround.visible = false;
        m_pViewUI.clip_skillSurround.autoPlay = false;
        m_pViewUI.img_skillBg.visible = false;
        m_pViewUI.btn_confirm.visible = false;

        updateDisplay();

        _startAnimation();
    }

    override protected function updateDisplay():void
    {
        _updateStarInfo();
        _updateCombatInfo();
        _updateAttrInfo();
        _updateSkillInfo();
    }

    private function _updateStarInfo():void
    {
        var resultData:CStarResultData = _playerHelper.starResultData;
        if(resultData)
        {
            m_pViewUI.list_star_before.dataSource = new Array(resultData.oldStar);
            m_pViewUI.list_star_after.dataSource = new Array(resultData.newStar);
            var cell:Box = m_pViewUI.list_star_after.getCell(resultData.newStar - 1);
            if(cell)
            {
                cell.visible = false;
            }

            var starWidth:int = 30 * resultData.oldStar + m_pViewUI.list_star_before.spaceX * (resultData.oldStar - 1);
            m_pViewUI.list_star_before.x = 298 - starWidth >> 1;

            starWidth = 30 * resultData.newStar + m_pViewUI.list_star_after.spaceX * (resultData.newStar - 1);
            m_pViewUI.list_star_after.x = 298 - starWidth >> 1;

            var heroData:CPlayerHeroData = (system as CPlayerSystem).playerData.heroList.getHero(resultData.heroId);

//            m_pViewUI.view_head_before.clip_career.index = heroData.job;
            m_pViewUI.view_head_before.clip_career.visible = false;
            (system as CPlayerSystem).showCareerTips(m_pViewUI.view_head_before.clip_career);
            m_pViewUI.view_head_before.clip_intell.index = heroData.qualityBaseType;
//            m_pViewUI.view_head_before.quality_clip.index = heroData.qualityLevelValue;
            m_pViewUI.view_head_before.quality_clip.index = 0;
            m_pViewUI.view_head_before.icon_image.mask = m_pViewUI.view_head_before.hero_icon_mask;
            m_pViewUI.view_head_before.icon_image.url = CPlayerPath.getUIHeroIconMiddlePath(resultData.heroId);
            m_pViewUI.view_head_before.star_list.dataSource = [];

//            m_pViewUI.view_head_after.clip_career.index = heroData.job;
            m_pViewUI.view_head_after.clip_career.visible = false;
            (system as CPlayerSystem).showCareerTips(m_pViewUI.view_head_after.clip_career);
            m_pViewUI.view_head_after.clip_intell.index = heroData.qualityBaseType;
//            m_pViewUI.view_head_after.quality_clip.index = heroData.qualityLevelValue;
            m_pViewUI.view_head_after.quality_clip.index = 0;
            m_pViewUI.view_head_after.icon_image.mask = m_pViewUI.view_head_after.hero_icon_mask;
            m_pViewUI.view_head_after.icon_image.url = CPlayerPath.getUIHeroIconMiddlePath(resultData.heroId);
            m_pViewUI.view_head_after.star_list.dataSource = [];
        }
    }

    private function _updateCombatInfo():void
    {
        var resultData:CStarResultData = _playerHelper.starResultData;
        if(resultData)
        {
            m_pViewUI.txt_combat.text = resultData.oldCombat.toString();
            m_pViewUI.txt_combat2.text = resultData.newCombat.toString();
//            m_pViewUI.txt_combat_upValue.text = "+" + (resultData.newCombat - resultData.oldCombat);
        }
    }

    private function _updateAttrInfo():void
    {
        var resultData:CStarResultData = _playerHelper.starResultData;
        if(resultData)
        {
            if(resultData.oldAttr && resultData.newAttr)
            {
                m_pViewUI.list_attr.dataSource = _getOldAttrData();
                m_pViewUI.list_attr2.dataSource = _getNewAttrData();
            }
            else
            {
//                (system.stage.getSystem(IUICanvas) as CUISystem).showMsgAlert("属性数据为空");
            }
        }
    }

    private function _getOldAttrData():Array
    {
        var resultArr:Array = [];
        var resultData:CStarResultData = _playerHelper.starResultData;
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
//                    attrData.starUpValue = oldAttrData.attrBaseValue - oldAttrData.attrBaseValue;
                    resultArr.push(attrData);
                }
            }
        }

        return resultArr;
    }

    private function _getNewAttrData():Array
    {
        var resultArr:Array = [];
        var resultData:CStarResultData = _playerHelper.starResultData;
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
                    attrData.starUpValue = newAttrData.attrBaseValue - oldAttrData.attrBaseValue;
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

//        var resultData:CStarResultData = _playerHelper.starResultData;
//        if(resultData)
//        {
//            m_pViewUI.clip_starEffect.visible = true;
//            m_pViewUI.clip_starEffect.x = m_pViewUI.list_star_after.x + 15 + 30 * (resultData.newStar-1);
//            m_pViewUI.clip_starEffect.playFromTo(null,null,new Handler(_onStarAnimationComplHandler));
//            function _onStarAnimationComplHandler():void
//            {
//                m_pViewUI.clip_starEffect.visible = false;
//            }
//        }

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

        var audio:IAudio = system.stage.getSystem(IAudio) as IAudio;
        if(audio)
        {
            audio.playAudioByName("shuxingshan", 1, 0, 1);
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

        delayCall(i * 0.2, _playStarEffect);
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

    private function _playStarEffect():void
    {
        var resultData:CStarResultData = _playerHelper.starResultData;
        if(resultData)
        {
            var cell:Box = m_pViewUI.list_star_after.getCell(resultData.newStar - 1);
            if(cell)
            {
                cell.visible = true;
            }

            m_pViewUI.clip_starEffect.visible = true;
            m_pViewUI.clip_starEffect.x = m_pViewUI.list_star_after.x + 15 + 30 * (resultData.newStar-1);
            m_pViewUI.clip_starEffect.playFromTo(null,null,new Handler(_onStarAnimationComplHandler));
            function _onStarAnimationComplHandler():void
            {
                m_pViewUI.clip_starEffect.visible = false;
//                _onSkillAnimation();
            }

            delayCall(0.2, _onSkillAnimation);
        }
    }

    private function _onSkillAnimation():void
    {
        if(m_bHasSkillInfo)
        {
            m_pViewUI.btn_confirm.visible = true;
            m_pViewUI.clip_skillOpen.visible = true;
            m_pViewUI.box_skill.visible = true;
            m_pViewUI.img_skillBg.visible = true;
            m_pViewUI.clip_skillOpen.playFromTo(null,null,new Handler(_onSkillOpenEffectComplHandler));
            function _onSkillOpenEffectComplHandler():void
            {
                m_pViewUI.clip_skillOpen.visible = false;
                m_pViewUI.clip_skillSurround.visible = true;
                m_pViewUI.clip_skillSurround.autoPlay = true;
                m_pViewUI.btn_confirm.visible = true;
            }
        }
        else
        {
            m_pViewUI.btn_confirm.visible = true;
        }
    }

    private function _onHeroDataUpdateHandler(e:CPlayerEvent):void
    {
        delayCall(0.2,updateDisplay);
    }

    private function _onClickHandler():void
    {
        if(m_pViewUI.box_skill.visible && _playerHelper.isChildSystemOpen(KOFSysTags.SKIL_LEVELUP))
        {
            var bmp:Bitmap = CUIFactory.getBitmap();
            var bmd:BitmapData = new BitmapData(m_pViewUI.view_skill.width, m_pViewUI.view_skill.height);
            bmd.draw(m_pViewUI.view_skill, new Matrix(1,0,0,1));
            bmp.bitmapData = bmd;
            m_pSkillFlyViewHandler.flySkillIcon(KOFSysTags.ROLE, m_pViewUI.view_skill, m_sSkillName);
        }

        removeDisplay();
    }

    public function removeDisplay() : void
    {
        if(m_bViewInitialized)
        {
            _removeListeners();

            if(m_pViewUI && m_pViewUI.parent)
            {
                m_pViewUI.close(Dialog.CLOSE);
            }

            if(m_pViewUI.frameClip_title.isPlaying)
            {
                m_pViewUI.frameClip_title.stop();
            }

            if(m_pViewUI.clip_starEffect.isPlaying)
            {
                m_pViewUI.clip_starEffect.stop();
            }

            if(m_pViewUI.clip_skillOpen.isPlaying)
            {
                m_pViewUI.clip_skillOpen.stop();
            }

            if(m_pViewUI.clip_skillSurround.isPlaying)
            {
                m_pViewUI.clip_skillSurround.stop();
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
            m_pViewUI.list_star_after.dataSource = [];
            m_pViewUI.list_star_before.dataSource = [];

            var resultData:CStarResultData = _playerHelper.starResultData;
            if(resultData)
            {
                resultData.clearData();
            }

            m_bHasSkillInfo = false;
        }

        var pReciprocalSystem:CReciprocalSystem = (system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem);
        if(pReciprocalSystem){
            pReciprocalSystem.removeEventPopWindow( EPopWindow.POP_WINDOW_5 );
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
//            upValue.text = "+" + data.starUpValue;
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
//        var upValue:Label = render.getChildByName("txt_upValue") as Label;
        if(null != data)
        {
            attrName.text = data.getAttrNameCN();
            attrValue.text = data.attrBaseValue.toString();
//            upValue.text = "+" + data.starUpValue;
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

    private function _updateSkillInfo():void
    {
        var resultData:CStarResultData = _playerHelper.starResultData;
        if(resultData)
        {
            var skillId:int = _getPassiveSkill(resultData.heroId);
            if(skillId)
            {
                m_bHasSkillInfo = true;
//                m_pViewUI.box_skill.visible = true;
                m_pViewUI.box_skill.addChild(m_pViewUI.view_skill);
                m_pViewUI.view_skill.x = 103;
                m_pViewUI.view_skill.y = 0;
                m_pViewUI.view_skill.visible = true;
                m_pViewUI.view_skill.txt_key.text = "被";
                var passiveSkillUp : PassiveSkillUp = _passiveSkill.findByPrimaryKey( skillId );
                m_pViewUI.view_skill.img.url = CPlayerPath.getPassiveSkillBigIcon( passiveSkillUp.icon );

                m_pViewUI.view_skill.clip_zhi.visible = false;
                m_pViewUI.view_skill.maskimg.visible =
                        m_pViewUI.view_skill.maskimgII.visible =
                                m_pViewUI.view_skill.maskimgH.visible = false;
                m_pViewUI.view_skill.box_dou.visible = false;

                var pMaskDisplayObject : DisplayObject =  m_pViewUI.view_skill.maskimgII;
                if ( pMaskDisplayObject )
                {
                    m_pViewUI.view_skill.img.cacheAsBitmap = true;
                    pMaskDisplayObject.cacheAsBitmap = true;
                    m_pViewUI.view_skill.img.mask = pMaskDisplayObject;
                }

                m_pViewUI.txt_skillName.text = passiveSkillUp.skillname;
                m_sSkillName = passiveSkillUp.skillname;

                var skillInfo:Object = {};
                var skillData : CSkillData = _getSkillDataByID(skillId);
                skillInfo["skillData"] = skillData;
                skillInfo["skillId"] = skillId;
                var playerSystem:CPlayerSystem = system.stage.getSystem(CPlayerSystem ) as CPlayerSystem;

                m_pViewUI.view_skill.toolTip = new Handler( playerSystem.showHeroSkillTips, [skillData]);
            }
            else
            {
//                m_pViewUI.box_skill.visible = false;
                m_bHasSkillInfo = false;
            }
        }
        else
        {
//            m_pViewUI.box_skill.visible = false;
            m_bHasSkillInfo = false;
        }
    }

    /**
     * 得升星后解锁的被动技能
     * @param heroId
     * @return
     */
    private function _getPassiveSkill( heroId:int ):int
    {
        var playerSkill : PlayerSkill = _playerSkill.findByPrimaryKey(heroId);
        var skillArr : Array = playerSkill.SkillID;

        var resultData:CStarResultData = _playerHelper.starResultData;
        var passiveSkillArr:Array = [skillArr[7], skillArr[8], skillArr[9], skillArr[10], skillArr[11], skillArr[12],
            skillArr[13]];
        for(var i:int = 0; i < passiveSkillArr.length; i++)
        {
            var skillPos:int = 7 + i;
            var needStar:int = _getPassiveSkillNeedStar(skillPos);

            if(resultData && resultData.newStar == needStar)
            {
                return passiveSkillArr[i] as int;
            }
        }

        return 0;
    }

    private function _getPassiveSkillNeedStar(skillPosition:int):int
    {
        var tableArr : Array = _skillGetCondition.toArray();
        var skillGetCondition : SkillGetCondition ;
        for each ( skillGetCondition in tableArr )
        {
            if( skillGetCondition.skillPositionID == skillPosition )
            {
                return skillGetCondition.star;
            }
        }

        return 0;
    }

    private function _getSkillDataByID( skillID : int ):CSkillData
    {
        var resultData:CStarResultData = _playerHelper.starResultData;
        var skillData : CSkillData;
        var playerData:CPlayerData = (system.stage.getSystem(CPlayerSystem ) as CPlayerSystem).playerData;
        var skillAry:Array = playerData.heroList.getHero(resultData.heroId).skillList.list;
        if( skillAry )
        {
            for each ( skillData in skillAry )
            {
                if( skillData.skillID == skillID )
                {
                    return skillData;
                }
            }
        }
        return null;
    }

    public function get isViewShow():Boolean
    {
        return m_pViewUI && m_pViewUI.parent;
    }

    protected function get _playerHelper():CPlayerHelpHandler
    {
        return system.getHandler(CPlayerHelpHandler) as CPlayerHelpHandler;
    }

    private function get _playerSkill():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.PLAYER_SKILL);
    }

    private function get _skillGetCondition():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.SKILLGETCONDITION);
    }

    private function get _skill():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.SKILL);
    }

    private function get _passiveSkill():IDataTable
    {
        return _dataBase.getTable( KOFTableConstants.PASSIVE_SKILL_UP );
    }

    private function get _dataBase():IDatabase
    {
        return system.stage.getSystem(IDatabase) as IDatabase;
    }
}
}
