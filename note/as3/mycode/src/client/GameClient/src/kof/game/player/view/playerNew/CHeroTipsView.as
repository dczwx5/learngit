//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/8/12.
 */
package kof.game.player.view.playerNew {

import QFLib.Utils.HtmlUtil;

import flash.display.DisplayObject;

import kof.data.KOFTableConstants;

import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.bag.CBagManager;
import kof.game.bag.CBagSystem;
import kof.game.bag.data.CBagData;
import kof.game.common.CLang;
import kof.game.common.tips.ITips;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.view.playerNew.util.CPlayerHelpHandler;
import kof.table.Impression;
import kof.table.PassiveSkillPro;
import kof.table.PlayerBasic;
import kof.table.PlayerDisplay;
import kof.table.PlayerLines;
import kof.table.PlayerSkill;
import kof.table.Skill;
import kof.ui.master.jueseNew.HeroDetailInfoTipsUI;
import kof.ui.master.jueseNew.render.SkillListRenderUI;

import morn.core.components.Component;
import morn.core.handlers.Handler;

public class CHeroTipsView extends CViewHandler implements ITips{

    private var m_pViewUI:HeroDetailInfoTipsUI;
    private var m_pTipsObj:Component;
    private var m_pTipsData:CPlayerHeroData;

    public function CHeroTipsView( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
        return [ HeroDetailInfoTipsUI ];
    }

    public function addTips(component:Component, args:Array = null):void
    {
        if (m_pViewUI == null)
        {
            m_pViewUI = new HeroDetailInfoTipsUI();
            m_pViewUI.list_skill.renderHandler = new Handler(_renderSkillInfo);
        }

        m_pTipsObj = component;

        var isSelf:Boolean = args[1] as Boolean;
        var heroData:CPlayerHeroData;
        if(args != null)
        {
            heroData = args[0] as CPlayerHeroData;
        }
        else
        {
            heroData = component.dataSource as CPlayerHeroData;
        }

        m_pViewUI.img_common_piece.visible = false;

        m_pTipsData = heroData;
        if(heroData)
        {
            // 头部
//            m_pViewUI.item_head.hero_icon_mask.cacheAsBitmap = true;
            m_pViewUI.item_head.icon_image.mask = m_pViewUI.item_head.hero_icon_mask;
            m_pViewUI.item_head.icon_image.url = CPlayerPath.getUIHeroIconMiddlePath(heroData.prototypeID);
            m_pViewUI.item_head.clip_intell.index = heroData.qualityBaseType;
//            m_pViewUI.item_head.quality_clip.index = heroData.qualityLevelValue;
            m_pViewUI.item_head.quality_clip.index = 0;
            m_pViewUI.txt_heroName.isHtml = true;
            m_pViewUI.txt_heroName.text = _playerHelper.getHeroWholeName(heroData);
            m_pViewUI.item_head.box_star.visible = false;
            m_pViewUI.item_head.clip_career.visible = false;
            m_pViewUI.list_star.dataSource = new Array(heroData.star);
            m_pViewUI.clip_career.index = heroData.job;
            m_pViewUI.txt_addition_basic.isHtml = true;
            m_pViewUI.txt_addition_basic.text = _getBasicAdditionStr();
            m_pViewUI.txt_addition_fullStar.isHtml = true;
            m_pViewUI.txt_addition_fullStar.text = _getFullStarAdditionStr();

            if(heroData.hasData)
            {
                var progressValue : Number = 1;
                var piceData : CBagData = _bagManager.getBagItemByUid(heroData.pieceID);
                var currValue:int = piceData == null ? 0 : piceData.num;
                var totalValue:int = heroData.nextStarPieceCost;

                if(heroData.star >= CPlayerHeroData.MAX_STAR_LEVEL)//满星
                {
                    progressValue = 1;
                    m_pViewUI.progress_chips.label = CLang.Get("highStarLv");
//                    m_pViewUI.progress_chips.label = currValue.toString();
                }
                else
                {
                    //更新显示万能碎片进度，并取得用于补足的万能碎片数量:
                    var commonPieceCostNum:int = _renderCommonPiece(heroData, currValue, totalValue);
                    if(totalValue > 0)
                    {
                        progressValue = currValue / totalValue;
                        m_pViewUI.progress_chips.label = (currValue + commonPieceCostNum) + "/" + totalValue;
                    }
                    else
                    {
                        m_pViewUI.progress_chips.label = "";
                    }
                }

                m_pViewUI.progress_chips.value = progressValue;
//            m_pViewUI.progress_chips.value = isNaN(heroData.pieceRate) ? 0 : heroData.pieceRate;
//            m_pViewUI.progress_chips.label = CLang.Get("common_v1_v2", {v1:heroData.currentPieceCount, v2:heroData.hireNeedPieceCount});

                m_pViewUI.txt_heroName.text += " Lv."+heroData.level;
            }
            else
            {
                m_pViewUI.progress_chips.value = heroData.pieceRate;
                m_pViewUI.progress_chips.label = CLang.Get("common_v1_v2", {v1:heroData.currentPieceCount, v2:heroData.hireNeedPieceCount});
            }
            m_pViewUI.progress_chips.barLabel.y = -3;

            // 描述
            var playerLines:PlayerLines = _playerLines.findByPrimaryKey(heroData.prototypeID) as PlayerLines;
            m_pViewUI.txt_heroDesc.text = playerLines == null ? "" : playerLines.RoleSet;

            // 技能
            m_pViewUI.list_skill.dataSource = _getSkillListData();

            // 战力
            if (isSelf) {
                m_pViewUI.num_combat.num = heroData.battleValue;
            } else {
                m_pViewUI.num_combat.num = heroData.battleValueBase;
            }
//            TweenMax.fromTo(m_pViewUI.num_combat,0.2,{num:0},{num:heroData.battleValue});
            m_pViewUI.box_combat.centerX = 0;

            m_pViewUI.box_combat.visible = heroData.hasData;

            //操作难度
            var playerDisplay:PlayerDisplay = _playerDisplay.findByPrimaryKey(heroData.prototypeID) as PlayerDisplay;
            m_pViewUI.clip_LearningDifTxt.index =
                    m_pViewUI.clip_LearningDifImg.index = playerDisplay.LearningDif - 1;
        }

        App.tip.addChild(m_pViewUI);
    }

    //更新显示万能碎片进度，并取得用于补足的万能碎片数量
    private function _renderCommonPiece(heroData:CPlayerHeroData, currValue:int, totalValue:int):int {
        //把万能碎片进度图片addChild到进度条里，防止盖住进度条文本:
        if (m_pViewUI.img_common_piece.parent != m_pViewUI.progress_chips) {
            m_pViewUI.progress_chips.addChildAt(m_pViewUI.img_common_piece, 2);
            m_pViewUI.img_common_piece.x = 0;
            m_pViewUI.img_common_piece.y = 0;
        }
        //万能碎片进度:
        var commonPieceCostNum:int = 0;
        var commonPieceBagData:CBagData = null;
        //如果碎片不足，算出使用万能碎片代替的数量：
        if (currValue < totalValue) {
            commonPieceBagData = _playerHelper.getCommomPieceBagData(heroData);
            var commonPieceOwnNum:int = commonPieceBagData == null ? 0 : commonPieceBagData.num;//当前拥有对应的万能碎片的数量
            commonPieceCostNum = Math.min(commonPieceOwnNum, Math.max(0, totalValue - currValue));//用于补足的万能碎片数量
        }
        //显示万能碎片进度条：
        if (commonPieceCostNum > 0) {
            m_pViewUI.img_common_piece.visible = true;
            var progresWidth:int = m_pViewUI.progress_chips.comXml.@width;
            m_pViewUI.img_common_piece.width = progresWidth * (commonPieceCostNum/totalValue);
            m_pViewUI.img_common_piece.x = progresWidth * (currValue / totalValue);
        }
        return commonPieceCostNum;
    }

    private static const KEY_ARY:Array = ["U","I","O","space"];
    private function _renderSkillInfo(item:Component, index:int):void
    {
        if(!(item is SkillListRenderUI))
        {
            return;
        }

        var render:SkillListRenderUI = item as SkillListRenderUI;
        render.view_skillItem_small.visible = index != 3;
        render.view_skillItem_big.visible = index == 3;

        var skillId:int = render.dataSource as int;
        if(skillId)
        {
            var db : IDatabase = system.stage.getSystem( IDatabase ) as IDatabase;
            var skillTable : IDataTable = db.getTable( KOFTableConstants.SKILL );
            var skill : Skill = skillTable.findByPrimaryKey( skillId );
            if(skill)
            {
                render.txt_skillName.text = skill.Name;
                render.txt_skillDesc.text = skill.Description;
                if(index < 3)
                {
                    render.view_skillItem_small.txt_key.text = KEY_ARY[index];
                    render.view_skillItem_small.img.url = CPlayerPath.getSkillBigIcon( skill.IconName );
//                    render.view_skillItem_small.clip_SuperScript.visible = skill.SuperScript > 0 ;
//                    if( render.view_skillItem_small.clip_SuperScript.visible )
//                    {
//                        render.view_skillItem_small.clip_SuperScript.index = skill.SuperScript - 1;
//                    }
                }
                else
                {
                    render.view_skillItem_big.img.url = CPlayerPath.getSkillBigIcon( skill.IconName );
                }
            }

            if(index < 3)
            {
                render.view_skillItem_small.clip_zhi.visible = false;
                render.view_skillItem_small.maskimg.visible =
                        render.view_skillItem_small.maskimgII.visible =
                                render.view_skillItem_small.maskimgH.visible = false;
                render.view_skillItem_small.box_dou.visible = false;
                render.view_skillItem_small.maskimg.visible = false;
                //todo UI改版后删掉
                render.view_skillItem_small.maskimgII.visible = false;
                var pMaskDisplayObject : DisplayObject;
                pMaskDisplayObject =  render.view_skillItem_small.maskimgII;
                if ( pMaskDisplayObject )
                {
                    render.view_skillItem_small.img.cacheAsBitmap = true;
                    pMaskDisplayObject.cacheAsBitmap = true;
                    render.view_skillItem_small.img.mask = pMaskDisplayObject;
                }
            }
            else
            {
                pMaskDisplayObject =  render.view_skillItem_big.maskimgII;
                if ( pMaskDisplayObject )
                {
                    render.view_skillItem_big.img.cacheAsBitmap = true;
                    pMaskDisplayObject.cacheAsBitmap = true;
                    render.view_skillItem_big.img.mask = pMaskDisplayObject;
                    render.view_skillItem_big.eff_fire1.autoPlay = false;
                    render.view_skillItem_big.eff_fire2.autoPlay = false;
                    render.view_skillItem_big.eff_fire1.visible = false;
                    render.view_skillItem_big.eff_fire2.visible = false;
                    render.view_skillItem_big.box_dou_1.visible = false;
                    render.view_skillItem_big.box_dou_2.visible = false;
                    render.view_skillItem_big.box_dou_3.visible = false;
                }
            }
        }
        else
        {

        }
    }

    private function _getSkillListData():Array
    {
        var playerSkill : PlayerSkill = _playerSkill.findByPrimaryKey(m_pTipsData.prototypeID);

        var skillAry : Array = playerSkill.SkillID.concat();
        skillAry.splice(0,2);

//        spcicalSkill(playerSkill.SkillID[5]);

        return skillAry;
    }

    /**
     * 基础加成(攻、防、血)
     * @return
     */
    private function _getBasicAdditionStr():String
    {
        var resultStr:String = "";
        if(m_pTipsData)
        {
            var playerBasic:PlayerBasic = _playerBasic.findByPrimaryKey(m_pTipsData.prototypeID);
            if(playerBasic)
            {
                var str:String = playerBasic.InitPerProperty;
                var strArr:Array = str ? str.split(",") : null;
                if(strArr && strArr.length)
                {
                    var subStr:String = strArr[0] as String;
                    var subStrArr:Array = subStr ? subStr.split(":") : null;
                    if(subStrArr && subStrArr.length)
                    {
                        var value:Number = int(subStrArr[1]) / 100;
                        var valueString:String = value % 1 == 0 ? value.toString() : value.toFixed(2);
                        resultStr = HtmlUtil.color("全属性(攻防血) ","#ffffff")
                            + HtmlUtil.color(valueString + "% ", "#00ff00")
                            + HtmlUtil.color("(资质" + m_pTipsData.qualityBase + ")", "#ffffff");
                    }
                }
            }
        }

        return resultStr;
    }

    /**
     * 满星级加成(好感度)
     * @return
     */
    private function _getFullStarAdditionStr():String
    {
        var resultStr:String = "";

        if(m_pTipsData)
        {
            var heroStar:int = m_pTipsData.star;
            var tableArr:Array = _impression.findByProperty("roleId",m_pTipsData.prototypeID);
            if(tableArr && tableArr.length)
            {
                var impression:Impression = tableArr[0] as Impression;
                if(impression && impression.star7 && impression.hasOwnProperty("star"+heroStar) && impression["star"+heroStar])
                {
                    var starStr:String = impression["star"+heroStar];
                    var attrStr1 : String = starStr.slice(1, starStr.length - 1);
                    var strArr1:Array = attrStr1.split(":");
                    if(strArr1 && strArr1.length)
                    {
                        var attrType:Number = int(strArr1[0]);
                        var attrValue:Number = int(strArr1[2]) / 100;
                        var attrName:String = _getAttrNameCN(attrType);
                        var valueString:String = attrValue % 1 == 0 ? attrValue.toString() : attrValue.toFixed(2);
                        resultStr = HtmlUtil.color("全体格斗家"+attrName, "#ffffff")
                                    + HtmlUtil.color("+" + valueString + "% ", "#00ff00");
                    }

                    var attrStr2 : String = impression.star7.slice(1, impression.star7.length - 1);
                    var strArr2:Array = attrStr2.split(":");
                    if(strArr2 && strArr2.length)
                    {
                        attrType = int(strArr2[0]);
                        attrValue = int(strArr2[2]) / 100;
                        attrName = _getAttrNameCN(attrType);
                        valueString = attrValue % 1 == 0 ? attrValue.toString() : attrValue.toFixed(2);
                        if(m_pTipsData.star == 7)
                        {
                            resultStr += HtmlUtil.color("(满星"+attrName+"+" + valueString + "%)", "#ffffff");
                        }
                        else
                        {
                            resultStr += HtmlUtil.color("(满星"+attrName+"+" + valueString + "%)", "#9c9c9c");
                        }
                    }
                }
                else if(heroStar == 0)
                {
                    attrStr2 = impression.star7.slice(1, impression.star7.length - 1);
                    strArr2 = attrStr2.split(":");
                    if(strArr2 && strArr2.length)
                    {
                        attrType = int(strArr2[0]);
                        attrValue = int(strArr2[2]) / 100;
                        attrName = _getAttrNameCN(attrType);
                        valueString = attrValue % 1 == 0 ? attrValue.toString() : attrValue.toFixed(2);
                        resultStr += HtmlUtil.color("(满星"+attrName+"+" + valueString + "%)", "#9c9c9c");
                    }
                }
            }
        }

        return resultStr;
    }

    private function _getAttrNameCN(attrType : int) : String
    {
        var arr : Array = _passiveSkillProTable.findByProperty("ID", attrType);
        if(arr && arr.length)
        {
            return (arr[ 0 ] as PassiveSkillPro).name;
        }

        return "";
    }

    public function hideTips():void
    {
        if(m_pViewUI)
        {
            m_pViewUI.remove();
        }
    }

    private function get _dataBase():IDatabase
    {
        return system.stage.getSystem(IDatabase) as IDatabase;
    }

    private function get _playerLines():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.PLAYER_LINES);
    }
    private function get _playerDisplay():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.PLAYER_DISPLAY);
    }

    private function get _playerSkill():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.PLAYER_SKILL);
    }

    private function get _playerBasic():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.PLAYER_BASIC);
    }

    private function get _impression():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.IMPRESSION);
    }

    private function get _passiveSkillProTable():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.PASSIVE_SKILL_PRO);
    }

    private function get _playerHelper():CPlayerHelpHandler
    {
        return system.getHandler(CPlayerHelpHandler) as CPlayerHelpHandler;
    }

    private function get _bagManager():CBagManager
    {
        return system.stage.getSystem(CBagSystem).getHandler(CBagManager) as CBagManager;
    }
}
}
