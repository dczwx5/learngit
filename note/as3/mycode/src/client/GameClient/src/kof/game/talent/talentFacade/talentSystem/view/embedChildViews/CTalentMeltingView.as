//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/7/25.
 */
package kof.game.talent.talentFacade.talentSystem.view.embedChildViews {

import QFLib.Foundation.CMap;
import QFLib.Utils.HtmlUtil;

import flash.events.MouseEvent;

import kof.framework.IDatabase;
import kof.game.character.property.CBasePropertyData;
import kof.game.common.CAttributeUtil;
import kof.game.common.data.CAttributeBaseData;
import kof.game.item.CItemData;
import kof.game.item.CItemSystem;
import kof.game.item.view.tips.CItemTipsView;
import kof.game.talent.CTalentSystem;
import kof.game.talent.talentFacade.CTalentFacade;
import kof.game.talent.talentFacade.CTalentHelpHandler;
import kof.game.talent.talentFacade.talentSystem.data.CTalentMeltItemData;
import kof.game.talent.talentFacade.talentSystem.data.CTalentMeltingData;
import kof.game.talent.talentFacade.talentSystem.enums.ETalentMeltType;
import kof.game.talent.talentFacade.talentSystem.enums.ETalentWareType;
import kof.game.talent.talentFacade.talentSystem.proxy.CTalentDataManager;
import kof.game.talent.talentFacade.talentSystem.proxy.data.CTalentWarehouseData;
import kof.game.talent.talentFacade.talentSystem.view.CTalentMainView;
import kof.table.TalentSoul;
import kof.table.TalentSoulFurnace;
import kof.ui.IUICanvas;
import kof.ui.demo.talentSys.TalentMeltingItemUI;
import kof.ui.demo.talentSys.TalentSmeltingUI;
import kof.ui.demo.talentSys.TalentUI;
import kof.ui.imp_common.RewardItemUI;

import morn.core.components.Box;
import morn.core.components.Clip;
import morn.core.components.Component;
import morn.core.components.FrameClip;
import morn.core.components.Image;
import morn.core.components.Label;
import morn.core.handlers.Handler;

/**
 * @author sprite
 * 斗魂熔炼
 */
public class CTalentMeltingView {

    private var _talentMainView : CTalentMainView = null;
    private var _talentUI:TalentUI = null;

    private var m_pCurrSelData:CTalentMeltingData;
    private var m_pPropertyData:CBasePropertyData;
    private var m_pBoxArr:Array = [];
    private var m_bIsInited:Boolean;
    private var m_arrSelTalentArr:Array = [];// 当前选中的斗魂id数组
    private var m_mapSelTalentItem:CMap = new CMap();// 传到服务器的信息(id -- num)

    public function CTalentMeltingView(talentMainView : CTalentMainView)
    {
        this._talentMainView = talentMainView;
        this._talentUI = talentMainView.talentUI;

        _viewUI.list_attr.renderHandler = new Handler(_renderAttrHandler);
        _viewUI.list_talentItem.renderHandler = new Handler(_renderTalentItemHandler);

        m_pBoxArr.push(_viewUI.box_high);
        m_pBoxArr.push(_viewUI.box_middle);
        m_pBoxArr.push(_viewUI.box_low);

        _viewUI.btn_oneKeySel.clickHandler = new Handler(_clickOneKeySelHandler);
        _viewUI.btn_melting.clickHandler = new Handler(_clickMeltingHandler);
    }

    private function _initView():void
    {
        m_bIsInited = true;

        for each(var box:Box in m_pBoxArr)
        {
            box.addEventListener(MouseEvent.CLICK, _onSelHandler);
        }

        if(_helper.isTalentMeltOpen(ETalentMeltType.Type_High))
        {
            _selMelt(_viewUI.box_high);
        }
        else if(_helper.isTalentMeltOpen(ETalentMeltType.Type_Middle))
        {
            _selMelt(_viewUI.box_middle);
        }
        else if(_helper.isTalentMeltOpen(ETalentMeltType.Type_Low))
        {
            _selMelt(_viewUI.box_low);
        }
    }

    public function update() : void
    {
        _updateSingleMeltingInfo(ETalentMeltType.Type_High);
        _updateSingleMeltingInfo(ETalentMeltType.Type_Middle);
        _updateSingleMeltingInfo(ETalentMeltType.Type_Low);

        _updateTalentBagInfo();
        _updateTitleInfo();
        _updateLevelAndProgressInfo();
        _updateAttrInfo();
        _updateCombatInfo();

        m_arrSelTalentArr.length = 0;
        m_mapSelTalentItem.clear();

        if(!m_bIsInited)
        {
            _initView();
        }
    }

    /**
     * 单个熔炉信息更新
     */
    private function _updateSingleMeltingInfo(type:int):void
    {
        var box:Box;
        switch (type)
        {
            case ETalentMeltType.Type_High:
                box = _viewUI.box_high as Box;
                break;
            case ETalentMeltType.Type_Middle:
                box = _viewUI.box_middle as Box;
                break;
            case ETalentMeltType.Type_Low:
                box = _viewUI.box_low as Box;
                break;
        }

        var box_hasOpen:Box = box.getChildByName("box_hasOpen") as Box;
        var box_notOpen:Box = box.getChildByName("box_notOpen") as Box;
        var clip_bg:Clip = box.getChildByName("clip_bg") as Clip;

        var data:CTalentMeltingData = CTalentDataManager.getInstance().getMeltingDataByType(type);
        if(data)
        {
            if(_helper.isTalentMeltOpen(type))
            {
                box_hasOpen.visible = true;
                clip_bg.visible = true;
                box_notOpen.visible = false;
                var txt_levelInfo:Label = box_hasOpen.getChildByName("txt_levelInfo") as Label;
                txt_levelInfo.text = "结晶等级：" + data.level;
                var txt_combatInfo:Label = box_hasOpen.getChildByName("txt_combatInfo") as Label;
                txt_combatInfo.text = "结晶战力：" + _getSingleCombat(data);
            }
            else
            {
                box_hasOpen.visible = false;
                box_notOpen.visible = true;
                clip_bg.visible = false;
                var txt_openInfo:Label = box_notOpen.getChildByName("txt_openInfo") as Label;
                var openLevel:int = _helper.getTalentMeltOpenLevel(type);
                txt_openInfo.text = "(" + openLevel +"级可开启)";
            }

            box.dataSource = data;
        }
        else
        {
            _clear(box);
        }
    }

    private function _onSelHandler(e:MouseEvent):void
    {
        var box:Box = e.currentTarget as Box;
        _selMelt(box);
    }

    private function _selMelt(meltBox:Box):void
    {
        if(meltBox)
        {
            var data:CTalentMeltingData = meltBox.dataSource as CTalentMeltingData;
            if(data && _helper.isTalentMeltOpen(data.type))
            {
                if(m_pCurrSelData && m_pCurrSelData.type == data.type)
                {
                    return;
                }

                m_pCurrSelData = data;
                m_arrSelTalentArr.length = 0;
                m_mapSelTalentItem.clear();

                _updateTalentBagInfo();
                _updateTitleInfo();
                _updateLevelAndProgressInfo();
                _updateAttrInfo();

                _selView(meltBox);
            }
        }
    }

    private function _selView(selBox:Box):void
    {
        var frameClip_sel:FrameClip;

        for each(var item:Box in m_pBoxArr)
        {
            frameClip_sel = item.getChildByName("frameClip_sel") as FrameClip;
            var box_hasOpen:Box = item.getChildByName("box_hasOpen") as Box;
            var img_iconSel:Image = box_hasOpen.getChildByName("img_iconSel") as Image;
            img_iconSel.visible = false;
            var img_iconUnsel:Image = box_hasOpen.getChildByName("img_iconUnsel") as Image;

            if(item != selBox)
            {
                frameClip_sel.autoPlay = false;
                frameClip_sel.visible = false;
                img_iconUnsel.visible = true;
            }
            else
            {
                frameClip_sel.visible = true;
                frameClip_sel.autoPlay = true;
                img_iconUnsel.visible = false;
            }
        }
    }

    /**
     * 熔炉标题
     */
    private function _updateTitleInfo():void
    {
        if(m_pCurrSelData)
        {
            switch (m_pCurrSelData.type)
            {
                case ETalentMeltType.Type_High:
                    _viewUI.txt_meltType.text = "高级结晶";
                    _viewUI.txt_meltType.stroke = "0x642bc2";
                    _viewUI.txt_desc.isHtml = true;
                    _viewUI.txt_desc.text = HtmlUtil.color("仅可投放", "#6ea6c0") + HtmlUtil.color("紫色", "#c867ff")
                            + HtmlUtil.color("斗魂", "#6ea6c0");
                    break;
                case ETalentMeltType.Type_Middle:
                    _viewUI.txt_meltType.text = "中级结晶";
                    _viewUI.txt_meltType.stroke = "0x1d87ef";
                    _viewUI.txt_desc.text = HtmlUtil.color("仅可投放", "#6ea6c0") + HtmlUtil.color("蓝色", "#1dbdff")
                            + HtmlUtil.color("斗魂", "#6ea6c0");
                    break;
                case ETalentMeltType.Type_Low:
                    _viewUI.txt_meltType.text = "初级结晶";
                    _viewUI.txt_meltType.stroke = "0x009454";
                    _viewUI.txt_desc.text = HtmlUtil.color("仅可投放", "#6ea6c0") + HtmlUtil.color("绿色", "#00dd92")
                            + HtmlUtil.color("斗魂", "#6ea6c0");
                    break;
            }
        }
        else
        {
            _viewUI.txt_meltType.text = "未选择结晶";
            _viewUI.txt_meltType.stroke = "";
            _viewUI.txt_desc.text = "";
        }
    }

    /**
     * 等级和进度信息
     */
    private function _updateLevelAndProgressInfo():void
    {
        if(m_pCurrSelData)
        {
            _viewUI.txt_level.text = "Lv" + m_pCurrSelData.level;
            _viewUI.txt_levelAdd.text = "";
            _viewUI.progress_exp.visible = true;

            if(m_pCurrSelData.nextConfigData)
            {
                _viewUI.progress_exp.value = m_pCurrSelData.exp / m_pCurrSelData.nextConfigData.needExp;
                _viewUI.txt_progress.text = m_pCurrSelData.exp + "/" + m_pCurrSelData.nextConfigData.needExp;
                _viewUI.img_progressPreview.visible = false;
            }
            else
            {
                _viewUI.progress_exp.value = 1;
                _viewUI.txt_progress.text = "已满级";
            }
        }
        else
        {
            _viewUI.txt_level.text = "";
            _viewUI.txt_levelAdd.text = "";
            _viewUI.progress_exp.value = 0;
            _viewUI.progress_exp.visible = false;
            _viewUI.txt_progress.text = "";
            _viewUI.img_progressPreview.visible = false;
        }
    }

    /**
     * 属性信息
     */
    private function _updateAttrInfo():void
    {
        if(m_pCurrSelData)
        {
            var configData:TalentSoulFurnace = m_pCurrSelData.configData;
            if(configData)
            {
                var arr:Array = CAttributeUtil.parseAttrStr(configData.propertysAdd, _talentSystem);
                _viewUI.list_attr.dataSource = arr;
            }
            else
            {
                _viewUI.list_attr.dataSource = [];
            }
        }
        else
        {
            _viewUI.list_attr.dataSource = [];
        }
    }

    private function _renderAttrHandler(item:Component, index:int):void
    {
        var box:Box = item as Box;
        var data:CAttributeBaseData = item.dataSource as CAttributeBaseData;
        var attrName:Label = box.getChildByName("txt_attrName") as Label;
        var attrValue:Label = box.getChildByName("txt_attrValue") as Label;
        var addValue:Label = box.getChildByName("txt_addValue") as Label;

        if(data)
        {
            attrName.text = data.attrNameCN;
            attrValue.text = "+" + data.attrBaseValue;
            addValue.text = "";
        }
        else
        {
            attrName.text = "";
            attrValue.text = "";
            addValue.text = "";
        }
    }

    /**
     * 斗魂包信息
     */
    private function _updateTalentBagInfo():void
    {
        var arr:Array = _getTalentItemsInBag();
        if(arr.length < 16)
        {
            for(var i:int = arr.length; i < 16; i++)
            {
                arr.push({});
            }
        }

        _viewUI.list_talentItem.dataSource = arr;
    }

    private function _renderTalentItemHandler(item:Component, index:int):void
    {
        var talentItem:TalentMeltingItemUI = item as TalentMeltingItemUI;
        var rewardItem:RewardItemUI = talentItem.item;
        talentItem.removeEventListener(MouseEvent.CLICK, _onClickTalentItemHandler);

        var data:CTalentMeltItemData = item.dataSource as CTalentMeltItemData;
        if(data)
        {
            var itemData : CItemData = (_talentSystem.stage.getSystem( CItemSystem ) as CItemSystem).getItem( data.configData.ID );
            if(itemData)
            {
                rewardItem.icon_image.url = itemData.iconSmall;
                rewardItem.bg_clip.index = itemData.quality;

                rewardItem.num_lable.text = itemData.num > 1 ? itemData.num.toString() : "";
                rewardItem.clip_intelligence.visible = false;
                rewardItem.list_star.dataSource = [];
                rewardItem.list_star.visible = false;
                rewardItem.clip_effect2.visible = false;
                rewardItem.clip_effect2.autoPlay = false;
                rewardItem.box_eff.visible = true;
                rewardItem.clip_eff.visible = itemData.effect;
                rewardItem.clip_eff.autoPlay = itemData.effect;
                talentItem.checkBox_tick.visible = m_arrSelTalentArr.indexOf(data.id) != -1;
                talentItem.img_black.visible = m_arrSelTalentArr.indexOf(data.id) != -1;
                rewardItem.dataSource = itemData;

                rewardItem.toolTip = new Handler( _showItemTips, [ rewardItem ] );
                talentItem.addEventListener(MouseEvent.CLICK, _onClickTalentItemHandler);
            }
            else
            {
                rewardItem.num_lable.text = "";
                rewardItem.icon_image.url = "";
                rewardItem.bg_clip.index = 0;
                rewardItem.clip_intelligence.visible = false;
                rewardItem.list_star.dataSource = [];
                rewardItem.list_star.visible = false;
                rewardItem.clip_eff.autoPlay = false;
                rewardItem.clip_eff.visible = false;
                rewardItem.clip_effect2.autoPlay = false;
                rewardItem.clip_effect2.visible = false;
                talentItem.checkBox_tick.visible = false;
                talentItem.img_black.visible = false;
                rewardItem.dataSource = null;
                rewardItem.toolTip = null;
            }
        }
        else
        {
            talentItem.frameClip_expand.autoPlay = false;
            talentItem.frameClip_expand.visible = false;
            talentItem.checkBox_tick.visible = false;
            talentItem.img_black.visible = false;

            rewardItem.num_lable.text = "";
            rewardItem.icon_image.url = "";
            rewardItem.bg_clip.index = 0;
            rewardItem.clip_intelligence.visible = false;
            rewardItem.list_star.dataSource = [];
            rewardItem.list_star.visible = false;
            rewardItem.clip_eff.autoPlay = false;
            rewardItem.clip_eff.visible = false;
            rewardItem.clip_effect2.autoPlay = false;
            rewardItem.clip_effect2.visible = false;
            rewardItem.dataSource = null;
            rewardItem.toolTip = null;
        }
    }

    private function _showItemTips(item:RewardItemUI) : void
    {
        if(item && item.dataSource && item.dataSource is CItemData)
        {
            (_talentSystem.stage.getSystem(CItemSystem) as CItemSystem).addTips(CItemTipsView, item);
        }
    }

    private function _onClickTalentItemHandler(e:MouseEvent):void
    {
        var item:TalentMeltingItemUI = e.currentTarget as TalentMeltingItemUI;
        var talentItemData:CTalentMeltItemData = item == null ? null : (item.dataSource as CTalentMeltItemData);
        if(item && talentItemData)
        {
            if(item.checkBox_tick.visible)
            {
                item.checkBox_tick.visible = false;
                item.img_black.visible = false;
                var index:int = m_arrSelTalentArr.indexOf(talentItemData.id);
                if(index != -1)
                {
                    m_arrSelTalentArr.splice(index, 1);
                }
            }
            else
            {
                item.checkBox_tick.visible = true;
                item.img_black.visible = true;
                if(m_arrSelTalentArr.indexOf(talentItemData.id) == -1)
                {
                    m_arrSelTalentArr.push(talentItemData.id);
                }
            }
        }
    }

    private function _updateCombatInfo():void
    {
        _viewUI.num_combat.num = _getTotalCombat();
    }

    /**
     * 得某个熔炉的战力
     * @return
     */
    private function _getSingleCombat(data:CTalentMeltingData):int
    {
        if(m_pPropertyData == null)
        {
            m_pPropertyData = new CBasePropertyData();
            m_pPropertyData.databaseSystem = CTalentFacade.getInstance().talentAppSystem.stage.getSystem(IDatabase) as IDatabase;
        }

        m_pPropertyData.clearData();

        if(data)
        {
            var configData:TalentSoulFurnace = data.configData;
            if(configData && configData.propertysAdd)
            {
                var arr:Array = CAttributeUtil.parseAttrStr(configData.propertysAdd, _talentSystem);
                var obj:Object = {};
                for each(var attrData:CAttributeBaseData in arr)
                {
                    obj[attrData.attrNameEN] = attrData.attrBaseValue;
                }

                m_pPropertyData.updateDataByData(obj);
            }
        }

        return m_pPropertyData.getBattleValue();
    }

    private function _getTotalCombat():int
    {
        var data1:CTalentMeltingData = CTalentDataManager.getInstance().getMeltingDataByType(ETalentMeltType.Type_High);
        var data2:CTalentMeltingData = CTalentDataManager.getInstance().getMeltingDataByType(ETalentMeltType.Type_Low);
        var data3:CTalentMeltingData = CTalentDataManager.getInstance().getMeltingDataByType(ETalentMeltType.Type_Middle);

        return _getSingleCombat(data1) + _getSingleCombat(data2) + _getSingleCombat(data3);
    }

    private function _clear(box:Box):void
    {
        var box_hasOpen:Box = box.getChildByName("box_hasOpen") as Box;
        var box_notOpen:Box = box.getChildByName("box_notOpen") as Box;
        var clip_bg:Clip = box.getChildByName("clip_bg") as Clip;
        box_hasOpen.visible = false;
        box_notOpen.visible = true;
        clip_bg.visible = false;
        var txt_openInfo:Label = box_notOpen.getChildByName("txt_openInfo") as Label;
        txt_openInfo.text = "";

        var frameClip_meltSucc:FrameClip = box.getChildByName("frameClip_meltSucc") as FrameClip;
        frameClip_meltSucc.autoPlay = false;
        frameClip_meltSucc.visible = false;

        var frameClip_sel:FrameClip = box.getChildByName("frameClip_sel") as FrameClip;
        frameClip_sel.autoPlay = false;
        frameClip_sel.visible = false;

        box.dataSource = null;
    }

    public function _getTalentItemsInBag():Array
    {
        var resultArr:Array = [];
        if(m_pCurrSelData)
        {
            var configData:TalentSoulFurnace = m_pCurrSelData.nextConfigData;
            if(configData && configData.quality)
            {
                var arr:Array = configData.quality.split("_");
                var qualArr:Array = [];
                for each(var qual:String in arr)
                {
                    qualArr.push(int(qual));
                }

                var count:int = 1;
                var vec : Vector.<CTalentWarehouseData> = CTalentDataManager.getInstance().getTalentWarehouse(ETalentWareType.BENYUAN_WARE);
                for each(var data:CTalentWarehouseData in vec)
                {
                    var talentSoul : TalentSoul = CTalentFacade.getInstance().getTalentSoul(data.soulConfigID);
                    if ( talentSoul && qualArr.indexOf(talentSoul.quality) != -1)
                    {
                        for(var i:int = 0; i < data.soulNum; i++)
                        {
                            talentSoul = CTalentFacade.getInstance().getTalentSoul(data.soulConfigID);
                            var meltItemData:CTalentMeltItemData = new CTalentMeltItemData();
                            meltItemData.id = count++;
                            meltItemData.configData = talentSoul;
                            resultArr.push(meltItemData);
                        }
                    }
                }
            }
        }

        return resultArr;
    }

    /**
     * 一键选择
     */
    private function _clickOneKeySelHandler():void
    {
        var dataArr:Array = _viewUI.list_talentItem.dataSource as Array;
        if(dataArr.length == 0)
        {
            (_talentSystem.stage.getSystem(IUICanvas) as IUICanvas).showMsgAlert("无斗魂可选择");
            return;
        }

        if(dataArr && dataArr.length)
        {
            for(var i:int = 0; i < dataArr.length; i++)
            {
                var meltItemData:CTalentMeltItemData = dataArr[i] as CTalentMeltItemData;
                if(meltItemData && m_arrSelTalentArr.indexOf(meltItemData.id) == -1)
                {
                    m_arrSelTalentArr.push(meltItemData.id);
                }
            }
        }

        var len:int = _viewUI.list_talentItem.cells.length;
        for(i = 0; i < len; i++)
        {
            var item:TalentMeltingItemUI = _viewUI.list_talentItem.getCell(i) as TalentMeltingItemUI;
            if(item && item.dataSource && item.dataSource is CTalentMeltItemData)
            {
                item.checkBox_tick.visible = true;
                item.img_black.visible = true;
            }
        }
    }

    private function _clickMeltingHandler():void
    {
        if(m_pCurrSelData)
        {
            var recycleArr:Array = [];
            for each(var id:int in m_arrSelTalentArr)
            {
                var configId:int = getConfigId(id);
                var exitItem:Object = getExitItem(configId);
                if(exitItem)
                {
                    exitItem.recycleNum += 1;
                }
                else
                {
                    var recycleSoul:Object = {};
                    recycleSoul.soulConfigID = configId;
                    recycleSoul.recycleNum = 1;
                    recycleArr.push(recycleSoul);
                }
            }

            if(recycleArr.length == 0)
            {
                (_talentSystem.stage.getSystem(IUICanvas) as IUICanvas).showMsgAlert("无斗魂可熔炼");
                return;
            }

            CTalentFacade.getInstance().requestSoulRecycle(m_pCurrSelData.type, recycleArr);
        }

        function getExitItem(configId:int):Object
        {
            for each(var obj:Object in recycleArr)
            {
                if(obj && obj.hasOwnProperty("soulConfigID") && obj.soulConfigID == configId)
                {
                    return obj;
                }
            }

            return null;
        }

        function getConfigId(id:int):int
        {
            var arr:Array = _viewUI.list_talentItem.dataSource as Array;
            if(arr && arr.length)
            {
                for(var i:int = 0; i < arr.length; i++)
                {
                    var meltItemData:CTalentMeltItemData = arr[i] as CTalentMeltItemData;
                    if(meltItemData && meltItemData.id == id && meltItemData.configData)
                    {
                        return meltItemData.configData.ID;
                    }
                }
            }

            return 0;
        }
    }

    public function removeDisplay():void
    {
        m_bIsInited = false;

        for each(var box:Box in m_pBoxArr)
        {
            box.removeEventListener(MouseEvent.CLICK, _onSelHandler);
            _clear(box);
        }

        m_pCurrSelData = null;
        m_arrSelTalentArr.length = 0;
        m_mapSelTalentItem.clear();
    }

    public function hide() : void
    {
        m_pCurrSelData = null;
    }

    public function playMeltSuccEffect():void
    {
        if(m_pCurrSelData)
        {
            for each(var box:Box in m_pBoxArr)
            {
                if(box && box.dataSource == m_pCurrSelData)
                {
                    var frameClip_meltSucc:FrameClip = box.getChildByName("frameClip_meltSucc") as FrameClip;

                    frameClip_meltSucc.visible = true;
                    frameClip_meltSucc.playFromTo(null, null, new Handler(onPlayCompl));

                    function onPlayCompl():void
                    {
                        frameClip_meltSucc.visible = false;
                    }
                }
            }
        }
    }

    private function get _viewUI():TalentSmeltingUI
    {
        return _talentUI.view_melting;
    }

    private function get _talentSystem():CTalentSystem
    {
        return CTalentFacade.getInstance().talentAppSystem as CTalentSystem;
    }

    private function get _helper():CTalentHelpHandler
    {
        return _talentSystem.getHandler(CTalentHelpHandler) as CTalentHelpHandler;
    }
}
}

