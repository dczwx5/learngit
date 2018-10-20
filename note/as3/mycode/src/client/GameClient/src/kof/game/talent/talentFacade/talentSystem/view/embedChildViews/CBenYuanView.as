//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/10/17.
 * Time: 17:47
 */
package kof.game.talent.talentFacade.talentSystem.view.embedChildViews {

import flash.events.MouseEvent;
import flash.utils.Dictionary;
import flash.utils.setTimeout;

import kof.framework.IDatabase;

import kof.game.character.property.CBasePropertyData;

import kof.game.common.data.CAttributeBaseData;

import kof.game.talent.talentFacade.CTalentFacade;
import kof.game.talent.talentFacade.CTalentHelpHandler;
import kof.game.talent.talentFacade.talentSystem.enums.ETalentColorType;
import kof.game.talent.talentFacade.talentSystem.enums.ETalentPageType;
import kof.game.talent.talentFacade.talentSystem.enums.ETalentPointStateType;
import kof.game.talent.talentFacade.talentSystem.enums.ETalentTipsViewType;
import kof.game.talent.talentFacade.talentSystem.proxy.CTalentDataManager;
import kof.game.talent.talentFacade.talentSystem.proxy.data.CTalentAllPointData;
import kof.game.talent.talentFacade.talentSystem.proxy.data.CTalentPointData;
import kof.game.talent.talentFacade.talentSystem.view.CTalentMainView;
import kof.table.PassiveSkillPro;
import kof.table.TalentSoul;
import kof.table.TalentSoulPoint;
import kof.table.TalentSoulSuit;
import kof.ui.demo.talentSys.TalentIco3UI;
import kof.ui.demo.talentSys.TalentIco3UI;
import kof.ui.demo.talentSys.TalentIcoUI;
import kof.ui.demo.talentSys.TalentUI;

import morn.core.components.Box;
import morn.core.components.Clip;
import morn.core.components.Component;
import morn.core.components.Label;
import morn.core.components.Label;
import morn.core.events.UIEvent;

import morn.core.handlers.Handler;

/**
 * @author yili(guoyiligo@qq.com)
 * 2017/10/17
 */
public class CBenYuanView {
    private var _talentMainView : CTalentMainView = null;
    private var _talentUI:TalentUI=null;
    private var _alreadyOpenPointID : Vector.<int> = new <int>[];
    private var _recordTalentAdd : Dictionary = new Dictionary();
    private var _talentTotalLv : int = 0;
    private var _propertyData:CBasePropertyData;

    public function CBenYuanView( talentMainView : CTalentMainView ) {
        this._talentMainView = talentMainView;
        this._talentUI = talentMainView.talentUI;
    }

    public function update() : void {
        var talentPageData : CTalentAllPointData = CTalentDataManager.getInstance().getTalentPagePointData( ETalentPageType.BEN_YUAN );
        var i : int = 0;
        var openLv : int = 0;
        var talenPointTypeDesc : String = "";
        var data : Object = null;
        var talentIcoUI : TalentIcoUI = null;
        var talentPointSoul : TalentSoulPoint = null;
        var isShowTabRedPoint:Boolean = false;
        if ( talentPageData ) {
            var talentPointDataVec : Vector.<CTalentPointData> = talentPageData.pointInfos;
            var len : int = talentPointDataVec.length;
            var talentPointData : CTalentPointData = null;
            _alreadyOpenPointID.length = 0;
            for ( var j : int = 0; j < len; j++ ) {
                talentPointData = talentPointDataVec[ j ];
                talentPointSoul = CTalentFacade.getInstance().getTalentPointSoulForID(talentPointData.soulPointConfigID);
                _alreadyOpenPointID.push( talentPointSoul.pointID );
                for ( i = 1; i <= 30; i++ ) {
                    if ( i == talentPointSoul.pointID) {
                        talentIcoUI = _talentUI.benyuan.getChildByName( "item" + i ) as TalentIcoUI;
                        talentPointSoul = CTalentFacade.getInstance().getTalentPointSoulForPointIDAndPage( i ,ETalentPageType.BEN_YUAN);
                        talentIcoUI.txt1.visible = false;
                        talentIcoUI.txt2.visible = false;
                        talentIcoUI.btn.visible = true;
                        talentIcoUI.btn.clickHandler = new Handler( _talentMainView.embedTalentPoint, [ i, talentIcoUI.x, talentIcoUI.y, talentPointData.state, talentPointData.soulConfigID ] );
                        talenPointTypeDesc = _talentMainView.getTalentPointTypeDesc( i );
                        data = {};
                        data.talenPointTypeDesc = talenPointTypeDesc;
                        if ( talentPointData.state == ETalentPointStateType.OPEN_CAN_EMBED ) {
                            talentIcoUI.lvClipWhite.visible = false;
                            talentIcoUI.lvClipBlue.visible = false;
                            talentIcoUI.lvClipGreen.visible = false;
                            talentIcoUI.lvClipOrange.visible = false;
                            talentIcoUI.lvClipPurple.visible = false;
                            talentIcoUI.lvClipHuang.visible = false;
                            talentIcoUI.lvClipHong.visible = false;
                            talentIcoUI.ico.visible = false;
                            data.talentTipsViewType = ETalentTipsViewType.OPEN_CAN_EMBED;
                            if ( CTalentDataManager.getInstance().getTalentPointForWarehouse( i , ETalentPageType.BEN_YUAN).length ) {
                                talentIcoUI.img_red.visible = true;
                                isShowTabRedPoint = true;
                            } else {
                                talentIcoUI.img_red.visible = false;
                            }
                            talentIcoUI.kuangClip.index = CTalentFacade.getInstance().getBenYuanTalentGridBgColorForTalentMainType( talentPointSoul.mainType )+3;
                        }
                        else if ( talentPointData.state == ETalentPointStateType.EMBED ) {
                            talentIcoUI.img_red.visible = false;
                            var colorIndex : int = CTalentFacade.getInstance().getTalentPointColorIndexForTalentMainType( talentPointSoul.mainType );
                            var talentSoul : TalentSoul = CTalentFacade.getInstance().getTalentSoul( talentPointData.soulConfigID );
                            talentIcoUI.lvClipWhite.visible = false;
                            talentIcoUI.lvClipBlue.visible = false;
                            talentIcoUI.lvClipGreen.visible = false;
                            talentIcoUI.lvClipOrange.visible = false;
                            talentIcoUI.lvClipPurple.visible = false;
                            talentIcoUI.lvClipHuang.visible = false;
                            talentIcoUI.lvClipHong.visible = false;
                            if ( colorIndex == ETalentColorType.BLUE ) {
                                talentIcoUI.lvClipBlue.visible = false;
                                talentIcoUI.lvClipBlue.index = talentSoul.quality - 1;
                            }
                            else if ( colorIndex == ETalentColorType.GREEN ) {
                                talentIcoUI.lvClipGreen.visible = false;
                                talentIcoUI.lvClipGreen.index = talentSoul.quality - 1;
                            }
                            else if ( colorIndex == ETalentColorType.ORANGE ) {
                                talentIcoUI.lvClipOrange.visible = false;
                                talentIcoUI.lvClipOrange.index = talentSoul.quality - 1;
                            }
                            else if ( colorIndex == ETalentColorType.PURPLE ) {
                                talentIcoUI.lvClipPurple.visible = false;
                                talentIcoUI.lvClipPurple.index = talentSoul.quality - 1;
                            }
                            else if ( colorIndex == ETalentColorType.COLOR_6 ) {
                                talentIcoUI.lvClipHuang.visible = false;
                                talentIcoUI.lvClipHuang.index = talentSoul.quality - 1;
                            }
                            else if ( colorIndex == ETalentColorType.COLOR_7 ) {
                                talentIcoUI.lvClipHong.visible = false;
                                talentIcoUI.lvClipHong.index = talentSoul.quality - 1;
                            }
                            talentIcoUI.ico.visible = true;
                            talentIcoUI.ico.url = CTalentFacade.getInstance().getTalentIcoPath( talentSoul.icon );
                            talenPointTypeDesc = _talentMainView.getTalentPointTypeDesc( talentPointSoul.ID );
                            data.talentTipsViewType = ETalentTipsViewType.OPEN_EMBED;
                            data.soulConfigID = talentPointData.soulConfigID;
                            data.mainType = talentPointSoul.mainType;
                            data.pointId = i;
                            talentIcoUI.kuangClip.index = CTalentFacade.getInstance().getBenYuanTalentGridBgColorForTalentMainType( talentPointSoul.mainType )+6;
                        }
                        talentIcoUI.btn.toolTip = new Handler( _talentMainView.showTips, [ data ] );
                        break;
                    }
                }
            }
            //没开启的全部隐藏
            for ( i = 1; i <= 30; i++ ) {
                if ( _alreadyOpenPointID.indexOf( i ) == -1 ) {
                    talentIcoUI = _talentUI.benyuan.getChildByName( "item" + i ) as TalentIcoUI;
                    talentIcoUI.txt1.visible = false;
                    talentIcoUI.txt2.visible = false;
                    talentIcoUI.lvClipWhite.visible = false;
                    talentIcoUI.lvClipBlue.visible = false;
                    talentIcoUI.lvClipGreen.visible = false;
                    talentIcoUI.lvClipOrange.visible = false;
                    talentIcoUI.lvClipPurple.visible = false;
                    talentIcoUI.lvClipHuang.visible = false;
                    talentIcoUI.lvClipHong.visible = false;
                    talentIcoUI.ico.visible = false;
                    talentIcoUI.btn.visible = false;
                    talentPointSoul = CTalentFacade.getInstance().getTalentPointSoulForPointIDAndPage( i ,ETalentPageType.BEN_YUAN);
                    var colorIndexNotOpen : int = CTalentFacade.getInstance().getBenYuanTalentGridBgColorForTalentMainType( talentPointSoul.mainType );
                    talentIcoUI.kuangClip.index = colorIndexNotOpen;
                }
            }
            //下一个开启的位置
            var nextPointArr:Array = CTalentFacade.getInstance().nextOpenSePointID(ETalentPageType.BEN_YUAN);
            var nextPoint : int = nextPointArr.length>0?nextPointArr[0]:0;
            if ( nextPoint > 0 ) {
                talentPointSoul = CTalentFacade.getInstance().getTalentPointSoulForPointIDAndPage( nextPoint ,ETalentPageType.BEN_YUAN);
                openLv = this._talentMainView.getTalentPointOpneLv( talentPointSoul.pointID , ETalentPageType.BEN_YUAN);
                talentIcoUI = _talentUI.benyuan.getChildByName( "item" + nextPoint ) as TalentIcoUI;
//                if ( openLv <= CTalentFacade.getInstance().teamLevel ) {
                if(_helper.isTalentCanOpen(talentPointSoul))
                {
                    talentIcoUI.img_red.visible = true;
                    isShowTabRedPoint=true;

                }
                else
                {
                    talentIcoUI.img_red.visible = false;
                }
                talentIcoUI.txt1.visible = true;
                talentIcoUI.txt2.visible = true;
                talentIcoUI.txt1.text = "Lv." + openLv;
                talentIcoUI.lvClipWhite.visible = false;
                talentIcoUI.lvClipBlue.visible = false;
                talentIcoUI.lvClipGreen.visible = false;
                talentIcoUI.lvClipOrange.visible = false;
                talentIcoUI.lvClipPurple.visible = false;
                talentIcoUI.lvClipHuang.visible = false;
                talentIcoUI.lvClipHong.visible = false;
                talentIcoUI.kuangClip.index = ETalentColorType.WHITE;
                talentIcoUI.ico.visible = false;
                talentIcoUI.btn.visible = true;
                talentIcoUI.btn.clickHandler = new Handler( _talentMainView.openTalentPoint, [ nextPoint , talentPointSoul.ID ] );
                talenPointTypeDesc = _talentMainView.getTalentPointTypeDesc( talentPointSoul.ID );
                data = {};
                data.talenPointTypeDesc = talenPointTypeDesc;
                data.talentTipsViewType = ETalentTipsViewType.NEXT_OPEN;
                data.openLv = openLv;
                data.pointId = nextPoint;
                talentPointSoul = CTalentFacade.getInstance().getTalentPointSoulForPointIDAndPage( nextPoint ,ETalentPageType.BEN_YUAN);
                data.conditionId = talentPointSoul.openConditionID;
                talentIcoUI.btn.toolTip = new Handler( _talentMainView.showTips, [ data ] );
                var colorIndexNextOpen : int = CTalentFacade.getInstance().getBenYuanTalentGridBgColorForTalentMainType( talentPointSoul.mainType );
                talentIcoUI.kuangClip.index = colorIndexNextOpen;
            }
        } else {//一个都没开启的时候
            for ( i = 1; i <= 30; i++ ) {
                talentIcoUI = (_talentUI.benyuan.getChildByName( "item" + i ) as TalentIcoUI);
                talentPointSoul = CTalentFacade.getInstance().getTalentPointSoulForPointIDAndPage( i ,ETalentPageType.BEN_YUAN);
                talentIcoUI.kuangClip.index = CTalentFacade.getInstance().getBenYuanTalentGridBgColorForTalentMainType( talentPointSoul.mainType );
                if ( i == 1 ) {
                    talentIcoUI.txt1.visible = true;
                    talentIcoUI.txt2.visible = true;
                    talentIcoUI.lvClipWhite.visible = false;
                    talentIcoUI.lvClipBlue.visible = false;
                    talentIcoUI.lvClipGreen.visible = false;
                    talentIcoUI.lvClipOrange.visible = false;
                    talentIcoUI.lvClipPurple.visible = false;
                    talentIcoUI.lvClipHuang.visible = false;
                    talentIcoUI.lvClipHong.visible = false;
                    talentIcoUI.ico.visible = false;
                    talentIcoUI.btn.visible = true;
                    (_talentUI.benyuan.getChildByName( "item" + i ) as TalentIcoUI).btn.clickHandler = new Handler( _talentMainView.openTalentPoint, [ i , talentPointSoul.ID ] );
                    openLv = _talentMainView.getTalentPointOpneLv( talentPointSoul.pointID ,ETalentPageType.BEN_YUAN);
                    talentIcoUI.txt1.text = "Lv." + openLv;
                    talenPointTypeDesc = _talentMainView.getTalentPointTypeDesc( talentPointSoul.ID );
                    data = {};
                    data.talenPointTypeDesc = talenPointTypeDesc;
                    data.talentTipsViewType = ETalentTipsViewType.NEXT_OPEN;
                    data.openLv = openLv;
                    data.pointId = i;
                    data.conditionId = talentPointSoul.openConditionID;
                    talentIcoUI.btn.toolTip = new Handler( _talentMainView.showTips, [ data ] );
//                    if ( openLv <= CTalentFacade.getInstance().teamLevel ){
                    if(_helper.isTalentCanOpen(talentPointSoul))
                    {
                        talentIcoUI.img_red.visible = true;
                        isShowTabRedPoint=true;
                    }
                }
                else {
                    talentIcoUI.txt1.visible = false;
                    talentIcoUI.txt2.visible = false;
                    talentIcoUI.lvClipWhite.visible = false;
                    talentIcoUI.lvClipBlue.visible = false;
                    talentIcoUI.lvClipGreen.visible = false;
                    talentIcoUI.lvClipOrange.visible = false;
                    talentIcoUI.lvClipPurple.visible = false;
                    talentIcoUI.lvClipHuang.visible = false;
                    talentIcoUI.lvClipHong.visible = false;
                    talentIcoUI.ico.visible = false;
                    talentIcoUI.btn.visible = false;
                }
            }
        }

        var isShowTabRedPoint2:Boolean = _updateSpecialTalent();

        if(isShowTabRedPoint || isShowTabRedPoint2){
//            _talentMainView.talentUI.tabRed1.visible = true;
        }else{
//            _talentMainView.talentUI.tabRed1.visible=false;
        }
        if(_talentMainView.currentPage==ETalentPageType.BEN_YUAN)
        {
            _updateProertyValue();

            setTimeout(_updateCombat, 100);
        }

        // 斗魂套装
        if(_talentUI.clip_suit)
        {
            _talentUI.clip_suit.toolTip = null;
            _talentUI.clip_suit.toolTip = new Handler(_talentMainView.showSuitTips, [_talentMainView.currentPage]);
        }

        _talentUI.clip_suit.removeEventListener(MouseEvent.CLICK, _onClickSuitHandler);
        _talentUI.clip_suit.addEventListener(MouseEvent.CLICK, _onClickSuitHandler);

        _talentUI.txt_totalLevelLabel.text = "本源斗魂总等级";
    }

    /**
     * 中间的特殊斗魂
     * @return
     */
    private function _updateSpecialTalent():Boolean
    {
        var isShowTabRedPoint:Boolean;
        for(var i:int = 31; i <= 33; i++)
        {
            var talentIcoUI:TalentIco3UI = _talentUI.getChildByName( "specialItem_" + (i-30) ) as TalentIco3UI;
            if(_alreadyOpenPointID.indexOf(i) != -1)// 已开启
            {
                var talentSoulPoint:TalentSoulPoint = CTalentFacade.getInstance().getTalentPointSoulForPointIDAndPage( i ,ETalentPageType.BEN_YUAN);
                talentIcoUI.txt1.visible = false;
                talentIcoUI.txt2.visible = false;
                talentIcoUI.btn.visible = true;

                if(!talentIcoUI.frameClip_lock.isPlaying)
                {
                    talentIcoUI.frameClip_lock.visible = false;
                }
                talentIcoUI.kuangClip.index = 1;
                var talentPointData:CTalentPointData = _getTalentPointData(i);
                if(talentPointData)
                {
                    talentIcoUI.btn.clickHandler = new Handler( _talentMainView.embedTalentPoint,
                            [ i, talentIcoUI.x+8, talentIcoUI.y-93, talentPointData.state, talentPointData.soulConfigID ] );
                }

                var talenPointTypeDesc:String = _talentMainView.getTalentPointTypeDesc(i);
                var data:Object = {};
                data.talenPointTypeDesc = talenPointTypeDesc;
                if ( talentPointData.state == ETalentPointStateType.OPEN_CAN_EMBED )// 可镶嵌
                {
                    talentIcoUI.ico.visible = false;
                    data.talentTipsViewType = ETalentTipsViewType.OPEN_CAN_EMBED;
                    if ( CTalentDataManager.getInstance().getTalentPointForWarehouse( i , ETalentPageType.BEN_YUAN).length ) {
                        talentIcoUI.img_red.visible = true;
                        _isShowArroundEffect(talentIcoUI, true);
                        isShowTabRedPoint = true;
                    } else {
                        talentIcoUI.img_red.visible = false;
                        _isShowArroundEffect(talentIcoUI, false);
                        isShowTabRedPoint = false;
                    }
//                    talentIcoUI.kuangClip.index = CTalentFacade.getInstance().getBenYuanTalentGridBgColorForTalentMainType( talentSoulPoint.mainType )+3;
                }
                else if ( talentPointData.state == ETalentPointStateType.EMBED )// 已镶嵌
                {
                    talentIcoUI.img_red.visible = false;
                    _isShowArroundEffect(talentIcoUI, false);
                    var talentSoul : TalentSoul = CTalentFacade.getInstance().getTalentSoul( talentPointData.soulConfigID );
                    talentIcoUI.ico.visible = true;
                    talentIcoUI.ico.url = CTalentFacade.getInstance().getTalentIcoPath( talentSoul.icon );
                    data.talentTipsViewType = ETalentTipsViewType.OPEN_EMBED;
                    data.soulConfigID = talentPointData.soulConfigID;
                    data.mainType = talentSoulPoint.mainType;
                    data.pointId = i;
//                    talentIcoUI.kuangClip.index = CTalentFacade.getInstance().getBenYuanTalentGridBgColorForTalentMainType( talentSoulPoint.mainType )+6;
                }
                talentIcoUI.btn.toolTip = new Handler( _talentMainView.showTips, [ data ] );
            }
            else// 未开启
            {
                talentIcoUI = _talentUI.getChildByName("specialItem_" + (i-30)) as TalentIco3UI;
                talentIcoUI.txt1.visible = false;
                talentIcoUI.txt2.visible = false;
                talentIcoUI.ico.visible = false;
                talentIcoUI.btn.visible = false;
                talentSoulPoint = CTalentFacade.getInstance().getTalentPointSoulForPointIDAndPage( i ,ETalentPageType.BEN_YUAN);
//                var colorIndexNotOpen : int = CTalentFacade.getInstance().getBenYuanTalentGridBgColorForTalentMainType( talentPointSoul.mainType );
//                talentIcoUI.kuangClip.index = colorIndexNotOpen;
                talentIcoUI.btn.clickHandler = null;

                if(!talentIcoUI.frameClip_lock.isPlaying)
                {
                    talentIcoUI.frameClip_lock.autoPlay = false;
                    talentIcoUI.frameClip_lock.visible = false;
                }

                if(_helper.isTalentCanOpen(talentSoulPoint))
                {
                    talentIcoUI.img_red.visible = true;
                    _isShowArroundEffect(talentIcoUI, true);
                    talentIcoUI.kuangClip.index =0;
                    isShowTabRedPoint = true;

                    talentIcoUI.btn.visible = true;
                    talentIcoUI.btn.clickHandler = new Handler( _talentMainView.openTalentPoint, [ talentSoulPoint.pointID , talentSoulPoint.ID, talentIcoUI.frameClip_lock ] );
                }
                else
                {
                    talentIcoUI.img_red.visible = false;
                    _isShowArroundEffect(talentIcoUI, false);
                    talentIcoUI.kuangClip.index = 0;
                    isShowTabRedPoint = false;
                }

                data = {};
                data.talenPointTypeDesc = _talentMainView.getTalentPointTypeDesc(i);
                data.talentTipsViewType = ETalentTipsViewType.NEXT_OPEN;
                data.pointId = i;
                data.conditionId = talentSoulPoint.openConditionID;
                talentIcoUI.btn.visible = true;
                talentIcoUI.btn.toolTip = new Handler( _talentMainView.showTips, [ data ] );
            }
        }

        return isShowTabRedPoint;
    }

    private function _getTalentPointData(pointId:int):CTalentPointData
    {
        var talentPageData : CTalentAllPointData = CTalentDataManager.getInstance().getTalentPagePointData( ETalentPageType.BEN_YUAN );
        var talentPointDataVec : Vector.<CTalentPointData> = talentPageData.pointInfos;
        var len : int = talentPointDataVec.length;
        var talentPointData : CTalentPointData = null;
        for ( var j : int = 0; j < len; j++ )
        {
            talentPointData = talentPointDataVec[ j ];
            var talentPointSoul:TalentSoulPoint = CTalentFacade.getInstance().getTalentPointSoulForID( talentPointData.soulPointConfigID );
            if(talentPointSoul.pointID == pointId)
            {
                return talentPointData;
            }
        }

        return null;
    }

    private function _isShowArroundEffect(view:TalentIco3UI, value:Boolean):void
    {
        if(view)
        {
            if(value)
            {
                view.frameClip_around.visible = true;
                view.frameClip_around.autoPlay = true;
            }
            else
            {
                view.frameClip_around.stop();
                view.frameClip_around.autoPlay = false;
                view.frameClip_around.visible = false;
            }
        }
    }

    private function _onClickSuitHandler(e:MouseEvent):void
    {
        var component:Component = e.target as Component;
        component.dispatchEvent(new UIEvent(UIEvent.SHOW_TIP, component.toolTip, true));

        _talentMainView.showSuitTips(ETalentPageType.BEN_YUAN);
    }

    private function _updateProertyValue() : void {
        _talentTotalLv = 0;
        for ( var ke : int in _recordTalentAdd ) {
            delete _recordTalentAdd[ ke ];
        }
        for ( var kk : int in _talentMainView.pRecordPropertyAdd ) {
            delete _talentMainView.pRecordPropertyAdd[ kk ];
        }
        _talentUI.proList.dataSource = [];
        _talentUI.valueList.dataSource = [];
        var allTalentPointInfos : CTalentAllPointData = CTalentDataManager.getInstance().getTalentPagePointData( ETalentPageType.BEN_YUAN );
        if ( allTalentPointInfos ) {
            var vec : Vector.<CTalentPointData> = allTalentPointInfos.pointInfos;
            vec.forEach( function filterpropertyAdd( item : CTalentPointData, idx : int, vec : Vector.<CTalentPointData> ) : void {
                if ( item.soulConfigID != 0 ) {
                    var talentSoul : TalentSoul = CTalentFacade.getInstance().getTalentSoul( item.soulConfigID );
                    if ( _recordTalentAdd[ talentSoul.ID ] ) {
                        _recordTalentAdd[ talentSoul.ID ]++;
                    }
                    else {
                        _recordTalentAdd[ talentSoul.ID ] = 1;
                    }
                }
            } );
            var nu : int = 0;
            var talentSoul : TalentSoul = null;
            var sProperty : String = "";
            var dataArr : Array = [];
            var propertyID : int = 0;
            var valueArr : Array = [];
            var obj : Object = null;
            //第一次先算基础值
            for ( var key1 : int in _recordTalentAdd ) {
                nu = _recordTalentAdd[ key1 ];
                talentSoul = CTalentFacade.getInstance().getTalentSoul( key1 );
                _talentTotalLv += talentSoul.quality * nu;
                sProperty = _formatStr( talentSoul.propertysAdd );
                dataArr = sProperty.split( ";" );
                propertyID = 0;
                var addValue : int = 0;
                for ( var i : int = 0; i < dataArr.length; i++ ) {
                    valueArr = dataArr[ i ].split( ":" );
                    propertyID = valueArr[ 0 ];
                    addValue = valueArr[ 1 ];
                    if ( _talentMainView.pRecordPropertyAdd[ propertyID ] ) {
                        obj = _talentMainView.pRecordPropertyAdd[ propertyID ];
                        obj.addValue += addValue * nu;
                        _talentMainView.pRecordPropertyAdd[ propertyID ] = obj;
                    }
                    else {
                        addValue = addValue * nu;
                        _talentMainView.pRecordPropertyAdd[ propertyID ] = {addValue : addValue};
                    }
                }
            }
            //第二次算比分比加成
            for ( var key2 : int in _recordTalentAdd ) {
                nu = _recordTalentAdd[ key2 ];
                talentSoul = CTalentFacade.getInstance().getTalentSoul( key2 );
                sProperty = _formatStr( talentSoul.propertysAdd );
                dataArr = sProperty.split( ";" );
                propertyID = 0;
                var addPercent : Number = 0;
                for ( var j : int = 0; j < dataArr.length; j++ ) {
                    valueArr = dataArr[ j ].split( ":" );
                    propertyID = valueArr[ 0 ];
                    addPercent = valueArr[ 2 ] / 10000;
                    if ( _talentMainView.pRecordPropertyAdd[ propertyID ] ) {
                        obj = _talentMainView.pRecordPropertyAdd[ propertyID ];
                        obj.addValue = obj.addValue * Math.pow( (1 + addPercent), nu );
                        _talentMainView.pRecordPropertyAdd[ propertyID ] = obj;
                    } else {
                        addValue = 0;
                        _talentMainView.pRecordPropertyAdd[ propertyID ] = {addValue : addValue};
                    }
                }
            }
            var arr : Array = [];
            for ( var k : * in _talentMainView.pRecordPropertyAdd ) {
                arr.push( k );
            }

            var suitInfo:TalentSoulSuit = _helper.getCurrSuitInfo(ETalentPageType.BEN_YUAN);
            var attrs:Array = _helper.getSuitAttrInfo(suitInfo);
            for each(var attrData:CAttributeBaseData in attrs)
            {
                if(arr.indexOf(attrData.attrType) == -1)
                {
                    arr.push(attrData.attrType);
                }
            }

            _talentUI.proList.repeatY = arr.length;
            _talentUI.valueList.repeatY = arr.length;
            _talentUI.valueList.spaceY = 0;
            _talentUI.proList.dataSource = arr;
            _talentUI.valueList.dataSource = arr;
        }
//        var b : int = 0;
//        var s : int = 0;
//        var g : int = 0;
        _visibleClipNu();
        _talentUI.txt_totalLevel.text = _talentTotalLv.toString();
//        if ( _talentTotalLv < 10 ) {
//            ((_talentUI.getChildByName( "cb" ) as Box).getChildByName( "cb1" ) as Box).visible = true;
//            (((_talentUI.getChildByName( "cb" ) as Box).getChildByName( "cb1" ) as Box).getChildByName( "clip" ) as Clip).index = _talentTotalLv;
//        } else if ( _talentTotalLv >= 10 && _talentTotalLv < 100 ) {
//            s = int( _talentTotalLv / 10 );
//            g = int( _talentTotalLv % 10 );
//            ((_talentUI.getChildByName( "cb" ) as Box).getChildByName( "cb2" ) as Box).visible = true;
//            (((_talentUI.getChildByName( "cb" ) as Box).getChildByName( "cb2" ) as Box).getChildByName( "clip1" ) as Clip).index = s;
//            (((_talentUI.getChildByName( "cb" ) as Box).getChildByName( "cb2" ) as Box).getChildByName( "clip2" ) as Clip).index = g;
//        } else if ( _talentTotalLv >= 100 && _talentTotalLv < 1000 ) {
//            b = int( _talentTotalLv / 100 );
//            s = int( _talentTotalLv / 10 % 10 );
//            g = int( _talentTotalLv % 100 % 10 );
//            ((_talentUI.getChildByName( "cb" ) as Box).getChildByName( "cb3" ) as Box).visible = true;
//            (((_talentUI.getChildByName( "cb" ) as Box).getChildByName( "cb3" ) as Box).getChildByName( "clip1" ) as Clip).index = b;
//            (((_talentUI.getChildByName( "cb" ) as Box).getChildByName( "cb3" ) as Box).getChildByName( "clip2" ) as Clip).index = s;
//            (((_talentUI.getChildByName( "cb" ) as Box).getChildByName( "cb3" ) as Box).getChildByName( "clip3" ) as Clip).index = g;
//        }

        _talentUI.num_suitLevel.num = _helper.getCurrSuitLevel(ETalentPageType.BEN_YUAN);
    }

    private function _visibleClipNu() : void {
//        ((_talentUI.getChildByName( "cb" ) as Box).getChildByName( "cb1" ) as Box).visible = false;
//        ((_talentUI.getChildByName( "cb" ) as Box).getChildByName( "cb2" ) as Box).visible = false;
//        ((_talentUI.getChildByName( "cb" ) as Box).getChildByName( "cb3" ) as Box).visible = false;
    }

    private function _formatStr( str : String ) : String {
        str = str.replace( "[", "" );
        str = str.replace( "]", "" );
        return str;
    }

    private function _updateCombat():void
    {
        if(_propertyData == null)
        {
            _propertyData = new CBasePropertyData();
            _propertyData.databaseSystem = CTalentFacade.getInstance().talentAppSystem.stage.getSystem(IDatabase) as IDatabase;
        }

        _propertyData.clearData();

        var data:Object = {};
        var arr:Array = _talentUI.proList.dataSource as Array;
        if(arr && arr.length)
        {
            for(var i:int = 0; i < arr.length; i++)
            {
                var attrName:String = _propertyData.getAttrNameEN(int(arr[i]));
                var label:Label = _talentUI.valueList.getCell(i).getChildByName("txt") as Label;
                var attrValue:int = int(label.text.substring(1, label.text.length));
                data[attrName] = attrValue;
            }
        }

        _propertyData.updateDataByData(data);
        _talentUI.num_combat.num = _propertyData.getBattleValue();
    }

    public function hide() : void {
        var levelBox:Box = _talentUI.getChildByName("cb") as Box;
        levelBox.removeEventListener(MouseEvent.CLICK, _onClickSuitHandler);
    }

    private function get _helper():CTalentHelpHandler
    {
        return CTalentFacade.getInstance().talentAppSystem.getHandler(CTalentHelpHandler) as CTalentHelpHandler;
    }
}
}
