//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2017/4/18.
 * Time: 10:17
 */
package kof.game.talent.talentFacade.talentSystem.view {

import flash.display.Sprite;
import flash.geom.Point;
import flash.utils.Dictionary;

import kof.data.CDataTable;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.game.KOFSysTags;
import kof.game.common.CLang;
import kof.game.common.CSystemRuleUtil;
import kof.game.common.data.CAttributeBaseData;
import kof.game.switching.CSwitchingSystem;
import kof.game.talent.CTalentViewHandler;
import kof.game.talent.CTalentViewHandler;
import kof.game.talent.talentFacade.CTalentFacade;
import kof.game.talent.talentFacade.CTalentHelpHandler;
import kof.game.talent.talentFacade.talentSystem.enums.ETalentPageType;
import kof.game.talent.talentFacade.talentSystem.enums.ETalentPointTakeOffType;
import kof.game.talent.talentFacade.talentSystem.enums.ETalentViewType;
import kof.game.talent.talentFacade.talentSystem.mediator.CAbstractTalentMediator;
import kof.game.talent.talentFacade.talentSystem.mediator.CTalentMediator;
import kof.game.talent.talentFacade.talentSystem.view.embedChildViews.CBenYuanView;
import kof.game.talent.talentFacade.talentSystem.view.embedChildViews.CTalentMeltingView;
import kof.game.talent.talentFacade.talentSystem.view.embedChildViews.CTalentPeakView;
import kof.table.GamePrompt;
import kof.table.PassiveSkillPro;
import kof.table.TalentSoulPoint;
import kof.ui.CUISystem;
import kof.ui.demo.talentSys.TalentUI;

import morn.core.components.Box;
import morn.core.components.Component;
import morn.core.components.Dialog;
import morn.core.components.FrameClip;
import morn.core.components.Label;
import morn.core.handlers.Handler;

public class CTalentMainView extends CAbstractTalentView {
    private var _talentUI : TalentUI = null;
    private var _closeHandlder : Handler = null;
    private var _mask : Sprite = null;
    public var pRecordPropertyAdd : Dictionary = new Dictionary();

    private var _isUpdate : Boolean = false;
    private var _isShow : Boolean = false;
    private var _currentPage : int = 0;
    private var _curSelectIndex : int = 0;
    //---------childView----------
    private var _benYuanView : CBenYuanView = null;
    private var _peakView : CTalentPeakView = null;
    private var _meltView : CTalentMeltingView = null;

    public function get currentPage() : int {
        return _currentPage;
    }

    public function get talentUI() : TalentUI {
        return _talentUI;
    }

    public function get isShow() : Boolean {
        return _isShow;
    }

    public function CTalentMainView( mediator : CAbstractTalentMediator ) {
        super( mediator );
        _talentUI = new TalentUI();
        _talentUI.closeHandler = new Handler( _close );
        _talentUI.bagBtn.clickHandler = new Handler( _openTalentBag );
        _talentUI.fastCancle.clickHandler = new Handler( _unloadAllTalent );

        _talentUI.bagBtn.y = _talentUI.shopBtn.y;

        _talentUI.proList.renderHandler = new Handler( _propertyRender );
        _talentUI.valueList.renderHandler = new Handler( _valueRender );

        _talentUI.shopBtn.clickHandler = new Handler( _talentShop );
        _talentUI.niudanShopBtn.clickHandler = new Handler(_talentShop);
        _talentUI.tabBtn.selectHandler = new Handler( _tabSelectHandler );
        _talentUI.tabBtn.selectedIndex = 0;
        _currentPage = ETalentPageType.BEN_YUAN;
        _curSelectIndex = 0;
        _talentUI.benyuan.visible = true;
        _talentUI.peak.visible = false;
        _drawMask();
        _benYuanView = new CBenYuanView( this );
        _peakView = new CTalentPeakView( this );
        _meltView = new CTalentMeltingView( this );
        CSystemRuleUtil.setRuleTips(_talentUI.help,CLang.Get("talent_rule"));
    }

    private function _tabSelectHandler( selectIndex : int ) : void {
        if ( selectIndex == _curSelectIndex )return;

        if(_curSelectIndex == 2)
        {
            _meltView.removeDisplay();
        }

        CTalentMediator(_mediator).talentSelectPointView.hide();
        if ( selectIndex == 0 ) {
            _curSelectIndex = 0;
            _currentPage = ETalentPageType.BEN_YUAN;
            _talentUI.benyuan.visible = true;
            _talentUI.peak.visible = false;
            _talentUI.view_melting.visible = false;
//            _talentUI.proTitleClip.index = 0;
            _benYuanView.update();
        } else if ( selectIndex == 1 ) {
            _curSelectIndex = 1;
            _currentPage = ETalentPageType.PEAK;
            _talentUI.benyuan.visible = false;
            _talentUI.view_melting.visible = false;
            _talentUI.peak.visible = true;
//            _talentUI.proTitleClip.index = 1;
            _peakView.update();
        }
        else if(selectIndex == 2)
        {
            _curSelectIndex = 2;
            _currentPage = ETalentPageType.MELT;
            _talentUI.view_melting.visible = true;
            _talentUI.benyuan.visible = false;
            _talentUI.peak.visible = false;
            _meltView.update();
        }

        if(_currentPage==ETalentPageType.BEN_YUAN){
//            _talentUI.shopBtn.visible = true;
//            _talentUI.niudanShopBtn.visible = false;
        }else if(_currentPage==ETalentPageType.PEAK){
//            _talentUI.shopBtn.visible=false;
//            _talentUI.niudanShopBtn.visible=true;
        }
    }

    private function _talentShop() : void {
        CTalentFacade.getInstance().showShopTalent(currentPage);
    }

    private function _drawMask() : void {
        _mask = new Sprite();
        _mask.graphics.beginFill( 0, 0 );
        _mask.graphics.drawRect( _talentUI.x, _talentUI.y, _talentUI.width, _talentUI.height );
        _mask.graphics.endFill();
        _talentUI.addChild( _mask );
        _mask.visible = false;
        _mask.name = "mask";
    }

    private function _unloadAllTalent() : void {
        CTalentFacade.getInstance().showAlertWindow( _requestTakeOff );
    }

    private function _requestTakeOff() : void {
        CTalentFacade.getInstance().requestTakeOff( ETalentPointTakeOffType.FAST_UNLOAD, ETalentPageType.BEN_YUAN, 0 );
    }

    private function _openTalentBag() : void {
        this._mediator.contact( this, ETalentViewType.BAG );
    }

    public final function get ui() : TalentUI {
        return _talentUI;
    }

    override public function show( data : Object = null ) : void {
        if ( !_isUpdate ) {
            update();
        }
        var pTalentViewHandler:CTalentViewHandler = CTalentFacade.getInstance().talentAppSystem.getBean(CTalentViewHandler) as CTalentViewHandler;
        pTalentViewHandler.setTweenData(KOFSysTags.TALENT);
        pTalentViewHandler.showDialog(_talentUI);

        _talentUI.tabRed1.visible = _helper.isCanOperateByPage(ETalentPageType.BEN_YUAN) && _isPageOpen(ETalentPageType.BEN_YUAN);
        _talentUI.tabRed2.visible = _helper.isCanOperateByPage(ETalentPageType.PEAK) && _isPageOpen(ETalentPageType.PEAK);
        _talentUI.tabRed3.visible = _helper.isCanMelt() && _isPageOpen(ETalentPageType.MELT);

        _isShow = true;
    }

    private function _isPageOpen(pageType:int):Boolean
    {
        var system:CAppSystem = CTalentFacade.getInstance().talentAppSystem;
        var tag:String;

        switch(pageType)
        {
            case ETalentPageType.BEN_YUAN:
                tag = KOFSysTags.TALENT;
                break;
            case ETalentPageType.PEAK:
                tag = KOFSysTags.TALENT_PEAK;
                break;
            case ETalentPageType.MELT:
                tag = KOFSysTags.TALENT_MELT;
                break;
        }
//        var tag:String = pageType == ETalentPageType.BEN_YUAN ? KOFSysTags.TALENT : KOFSysTags.TALENT_PEAK;
        var isSystemOpen:Boolean = (system.stage.getSystem(CSwitchingSystem) as CSwitchingSystem).isSystemOpen(tag);
        if(isSystemOpen)
        {
            return true;
        }

        return false;
    }

    override public function close() : void {
        var pTalentViewHandler:CTalentViewHandler = CTalentFacade.getInstance().talentAppSystem.getBean(CTalentViewHandler) as CTalentViewHandler;
        pTalentViewHandler.closeDialog(function () : void {
            _isShow = false;
        });
    }

    override public function update() : void {
        var labels:String = "本源";
        if((CTalentFacade.getInstance().talentAppSystem.stage.getSystem(CSwitchingSystem)
                as CSwitchingSystem).isSystemOpen(KOFSysTags.TALENT_PEAK))
        {
//            _talentUI.tabBtn.labels="本源,拳皇大赛";
            labels += ",拳皇大赛";
        }

        if((CTalentFacade.getInstance().talentAppSystem.stage.getSystem(CSwitchingSystem)
                as CSwitchingSystem).isSystemOpen(KOFSysTags.TALENT_MELT))
        {
            labels += ",斗魂实验室";
        }

        _talentUI.tabBtn.labels = labels;

        _talentUI.tabBtn.space = _talentUI.tabBtn.space;

        if(_currentPage == ETalentPageType.BEN_YUAN)
        {
            _benYuanView.update();
//            _talentUI.shopBtn.visible = true;
//            _talentUI.niudanShopBtn.visible = false;
        }
        else if(_currentPage == ETalentPageType.PEAK)
        {
            _peakView.update();
//            _talentUI.shopBtn.visible=false;
//            _talentUI.niudanShopBtn.visible=true;
        }
        else if(_currentPage == ETalentPageType.MELT)
        {
            _meltView.update();
        }

        _talentUI.tabRed1.visible = _helper.isCanOperateByPage(ETalentPageType.BEN_YUAN);
        _talentUI.tabRed2.visible = _helper.isCanOperateByPage(ETalentPageType.PEAK);
        _talentUI.tabRed3.visible = _helper.isCanMelt();

        _isUpdate = true;
    }

    private function _propertyRender( item : Component, idx : int ) : void {
        var box : Box = item as Box;
        var propertyID : int = int( item.dataSource );
        if ( propertyID == 0 ) {
            return;
        }
        var passiveSkillPro : PassiveSkillPro = CTalentFacade.getInstance().getPassiveSkillProData( propertyID );
        (box.getChildByName( "txt" ) as Label).text = passiveSkillPro.name;
    }

    private function _valueRender( item : Component, idx : int ) : void {
        var box : Box = item as Box;
        var propertyID : int = int( item.dataSource );
        if ( propertyID == 0 ) {
            return;
        }

        var value:int = pRecordPropertyAdd[propertyID] == null ? 0 : int(pRecordPropertyAdd[propertyID].addValue);
        var attrData:CAttributeBaseData = _helper.getSuitAttrDataById(_currentPage, propertyID);
        if(attrData)
        {
            value += attrData.attrBaseValue;
        }

        (box.getChildByName( "txt" ) as Label).text = "+" + value ;
    }

    public function getTalentPointOpneLv( ID : int ,page:int) : int {
        var openLv : int = CTalentFacade.getInstance().getTalentOpenLv( ID ,page);
        return openLv;
    }

    public function getTalentPointTypeDesc( pointID : int ) : String {
        var typeDesc : String = CTalentFacade.getInstance().getTalentPointMosaicTypeDesc( pointID );
        return typeDesc;
    }

    public function embedTalentPoint( pointID : int, x : Number, y : Number, state : int, soulConfigId : Number ) : void {
        CTalentFacade.getInstance().currentClickTalentPointID = pointID;
        _mediator.contact( this, ETalentViewType.SELECT, {
            x : x,
            y : y,
            pointID : pointID,
            state : state,
            soulConfigId : soulConfigId
        } );
    }

    /**
     * @param pointID 位置id
     * @param positionOnlyID 位置表唯一id
     * @param openType 开启类型，默认 正常开启
     * @param openClip 开启特效
     * 0正常开启 1付费开启
     *
     * */
    public function openTalentPoint( pointID : int, positionOnlyID : int, openClip:FrameClip = null ) : void {
        CTalentFacade.getInstance().currentClickTalentPointID = pointID;
        //先判断等级够不够
        var talentPointSoul : TalentSoulPoint = CTalentFacade.getInstance().getTalentPointSoulForID( positionOnlyID );
//        if ( CTalentFacade.getInstance().teamLevel >= talentPointSoul.openLevel ) {
        if ( _helper.isTalentCanOpen(talentPointSoul) )
        {
            CTalentFacade.getInstance().requestOpenTalentPoint( positionOnlyID, 0 );
            _playOpenEffect(openClip);
        }
        else if ( talentPointSoul.canPayOpen ) //战队等级不够，判断是否可以付费开启
        {
            var currencyType : int = talentPointSoul.payOpenCostCurrencyType;
            var uiSystem : CUISystem = CTalentFacade.getInstance().talentAppSystem.stage.getSystem( CUISystem ) as CUISystem;

            if ( currencyType == 1 )//金币
            {
                uiSystem.showMsgBox( "确认花费 " + talentPointSoul.payOpenCostCurrencyCount + "金币 开启斗魂插槽吗？", function () : void {
                    CTalentFacade.getInstance().requestOpenTalentPoint( positionOnlyID, 1 );
                    _playOpenEffect(openClip);
                } );
            }
            else if ( currencyType == 3 )//钻石
            {
                uiSystem.showMsgBox( "确认花费" + talentPointSoul.payOpenCostCurrencyCount + "钻石 开启斗魂插槽吗？", function () : void {
                    CTalentFacade.getInstance().requestOpenTalentPoint( positionOnlyID, 1 );
                    _playOpenEffect(openClip);
                },null,true,null,null,true,"COST_BIND_D" );
            }
            else if(currencyType == 2)//绑钻
            {
                uiSystem.showMsgBox( "确认花费" + talentPointSoul.payOpenCostCurrencyCount + "绑钻 开启斗魂插槽吗？", function () : void {
                    CTalentFacade.getInstance().requestOpenTalentPoint( positionOnlyID, 1 );
                    _playOpenEffect(openClip);
                },null,true,null,null,true,"COST_DIAMOND");
            }
        }
        else
        {
            selectPrompt( 1107 );
        }
    }

    private function _playOpenEffect(effect:FrameClip):void
    {
        if(effect)
        {
            effect.visible = true;
            effect.playFromTo(null, null, new Handler(onPlayEnd));
        }

        function onPlayEnd():void
        {
            effect.visible = false;
        }
    }

    private function selectPrompt( id : int ) : void {
        var talble : CDataTable;
        var pDatabaseSystem : CDatabaseSystem = CTalentFacade.getInstance().talentAppSystem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
        talble = pDatabaseSystem.getTable( KOFTableConstants.GAME_PROMPT ) as CDataTable;
        var gamePrompt : GamePrompt = talble.findByPrimaryKey( id );
        (CTalentFacade.getInstance().talentAppSystem.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( gamePrompt.content, gamePrompt.type );
    }

    public function showTips( data : Object ) : void {
        _mediator.contact( this, ETalentViewType.TIPS, data );
    }

    public function showSuitTips(data : Object):void
    {
        _mediator.contact( this, ETalentViewType.SUIT_TIPS, data );
    }

    public function tipsContent() : void {

    }

    public function set closeHanlder( closeHandler : Handler ) : void {
        _closeHandlder = closeHandler;
    }

    private function _close( type : String ) : void {
        if ( type == Dialog.CLOSE ) {
            if ( _closeHandlder ) {
                _closeHandlder.execute();
            }
        }
    }

    public function updateMeltInfo():void
    {
        if(_meltView && _curSelectIndex == 2)
        {
            _meltView.playMeltSuccEffect();
        }
    }

    private function get _helper():CTalentHelpHandler
    {
        return CTalentFacade.getInstance().talentAppSystem.getHandler(CTalentHelpHandler) as CTalentHelpHandler;
    }
}
}
