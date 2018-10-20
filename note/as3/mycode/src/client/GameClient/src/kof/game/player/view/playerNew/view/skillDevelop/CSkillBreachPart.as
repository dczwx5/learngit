//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/8/22.
 * 技能突破
 */
package kof.game.player.view.playerNew.view.skillDevelop {

import kof.SYSTEM_ID;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.KOFSysTags;
import kof.game.bag.CBagManager;
import kof.game.bag.CBagSystem;
import kof.game.bag.data.CBagData;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.item.CItemData;
import kof.game.itemGetPath.CItemGetSystem;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.data.CSkillData;
import kof.game.player.view.equipmentTrain.CEquTipsView;
import kof.game.player.view.playerNew.util.CPlayerHelpHandler;
import kof.game.player.view.skillup.CSkillUpConst;
import kof.game.player.view.skillup.CSkillUpHandler;
import kof.table.BreachLvConst;
import kof.table.PassiveSkillUp;
import kof.table.SkillEmitterConsume;
import kof.ui.CUISystem;
import kof.ui.master.jueseNew.render.HeroDevelopItemUI;
import kof.ui.master.jueseNew.render.SkillBreachRenderUI;
import kof.ui.master.jueseNew.view.SkillBreachViewUI;
import kof.ui.master.messageprompt.GoodsItemUI;

import morn.core.components.Component;
import morn.core.components.Label;
import morn.core.handlers.Handler;

public class CSkillBreachPart extends CViewHandler {

    private var m_pViewUI:SkillBreachViewUI;
    private var m_pData:CPlayerHeroData;
    private var m_pSkillData : CSkillData;
    private var _breachLvConst : BreachLvConst;
    private var m_pTipsView:CEquTipsView;
    private var _skillID : int;
    private var _skillPosition : int;

    private static const LVNAME_ARY : Array = ['','第一阶','第二阶','第三阶'];

    public function CSkillBreachPart( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    public function initializeView():void
    {

        var pTable : IDataTable  = _databaseSystem.getTable( KOFTableConstants.BREACH_LV_CONST );
        _breachLvConst = pTable.findByPrimaryKey( 1 );

        m_pViewUI.list.renderHandler = new Handler( renderItem );
    }

    public function updateView( skillData : CSkillData ,skillID : int, skillPosition : int ):void{
        m_pSkillData = skillData;
        _skillID = skillID;
        _skillPosition = skillPosition;

        m_pViewUI.list.dataSource = ['','',''];//改版
    }

    private function renderItem( item : Component, idx : int ) : void {
        if ( !(item is SkillBreachRenderUI) ) {
            return;
        }
        var position : int = idx + 1;
        var skillItemUI : SkillBreachRenderUI = item as SkillBreachRenderUI;
//        skillItemUI.itemList.renderHandler = new Handler( onItemAwardRenderItem );
//        skillItemUI.itemList.dataSource = [];
        var obj : Object = getPositionInfo( position );
        if( obj ){
            item.dataSource = obj;
            if( obj.isBreak ){
                positionItemView( skillItemUI , CSkillUpConst.position_isBreak ,position);
            }else if( obj.isActive ){
                positionItemView( skillItemUI , CSkillUpConst.position_isActive ,position);
            }
        }else{
            positionItemView( skillItemUI , CSkillUpConst.position_lock , position );
        }

        skillItemUI.clip_bg.index =
                skillItemUI.clip_breach.index = idx;

        skillItemUI.btn_break.clickHandler = new Handler( onBreakHandler ,[ position ]);

        if( null == m_pSkillData ){//只有被动技能才会出现这样情况
            var pTable : IDataTable  = _databaseSystem.getTable( KOFTableConstants.PASSIVE_SKILL_UP );
            var passiveSkillUp : PassiveSkillUp = pTable.findByPrimaryKey( _skillID );
            skillItemUI.txt.text = passiveSkillUp['emittereffectdesc' +  position];
        }else if( m_pSkillData.activeSkillUp ){
            skillItemUI.txt.text = m_pSkillData.activeSkillUp['emittereffectdesc' + position];
        }else if( m_pSkillData.passiveSkillUp ){
            skillItemUI.txt.text = m_pSkillData.passiveSkillUp['emittereffectdesc' +  position];
        }
    }

    private function positionItemView( item : SkillBreachRenderUI ,state : int ,position : int  ):void{
        var curConsume : SkillEmitterConsume = getBreachConsume( position );
        item.box_notopen.disabled =
                item.box_open.disabled =
                        item.box_isBreak.disabled =
                                item.img_breach.disabled =
                                        item.reward_1.disabled =
                                                item.reward_2.disabled =
                                                        item.btn_break.disabled =
                                                                item.clip_bg.disabled =
                                                                        item.clip_breach.disabled = false;
        if( state == CSkillUpConst.position_lock ){//锁

            onRewardView( item , curConsume );
            onSkillPointNeed( curConsume ,item.txt_skillPointNeed );
            onGoldNeed( curConsume ,item.txt_goldNeed );
            item.txt_unlock.text = '招式等级：' + _breachLvConst['needSkillLv' + position];

            item.box_notopen.visible = true;
            item.box_open.visible = false;
            item.box_isBreak.visible = false;
            item.img_breach.disabled = true;
            item.btn_break.visible = true;
            item.txt_skillPointNeed.visible = true;
            item.txt_goldNeed.visible = true;

            item.box_notopen.disabled = false;
            item.box_open.disabled =
                    item.box_isBreak.disabled =
                            item.img_breach.disabled =
                                    item.reward_1.disabled =
                                            item.reward_2.disabled =
                                                    item.btn_break.disabled =
                                                            item.clip_bg.disabled =
                                                                    item.clip_breach.disabled = true;

        }else if( state == CSkillUpConst.position_isActive ){//激活

            onRewardView( item , curConsume );
            onSkillPointNeed( curConsume ,item.txt_skillPointNeed ,true );
            onGoldNeed( curConsume ,item.txt_goldNeed ,true);
            item.txt_lvName.text = LVNAME_ARY[position];

            item.disabled = false;

            item.box_notopen.visible = false;
            item.box_open.visible = true;
            item.box_isBreak.visible = false;
            item.img_breach.disabled = true;
            item.btn_break.visible = true;
            item.txt_skillPointNeed.visible = true;
            item.txt_goldNeed.visible = true;


        }else if( state == CSkillUpConst.position_isBreak ){//突破成功
            item.box_notopen.visible = false;
            item.box_open.visible  = true;
            item.box_isBreak.visible = true;
            item.img_breach.disabled = false;
            item.reward_1.visible = false;
            item.reward_2.visible = false;
            item.btn_break.visible = false;
            item.txt_skillPointNeed.visible = false;
            item.txt_goldNeed.visible = false;

            item.disabled = false;
        }
    }
    private function getPositionInfo( i : int ):Object{
        if ( null == m_pSkillData )
            return null;
        for each( var obj : Object in m_pSkillData.slotListData.list ){
            if( obj.position == i ){
                return obj;
                break;
            }
        }
        return null;
    }

    private function onRewardView( item : SkillBreachRenderUI , curConsume : SkillEmitterConsume ):void{
        if( !curConsume )
            return;
        var ary:Array = [];
        var obj:Object;
        var i:int;
        for( i = 1 ; i <= 2 ; i++ ){
            obj = {};
            obj.ID = curConsume['item' + i];
            obj.num = curConsume['count' + i];
            if( obj.ID != 0 && obj.num != 0){
                ary.push( obj );
                onItemAwardRenderItem( item['reward_' + i], obj );
            }

        }
        //这里不用list，是因为UI报错
        if( ary.length >= 2 ){
            item.reward_1.visible = item.reward_2.visible = true;
            item.reward_1.x = 42;
            item.reward_2.x = 105;
        }else{
            item.reward_1.visible = true
            item.reward_2.visible = false;
            item.reward_1.x = 75;

        }

    }

    private function onItemAwardRenderItem( render : HeroDevelopItemUI, dataObj : Object ):void{
        render.mouseEnabled = true;
        if( !dataObj )
                return;
        var itemId : int = dataObj.ID;
        var needNum : int = dataObj.num;
        if(itemId)
        {
            var itemData : CItemData = _playerHelper.getItemData( itemId ); // 消耗物品
            var bagData : CBagData = _bagManager.getBagItemByUid( itemId ); // item1, 当前拥有
            var itemNum : int = bagData == null ? 0 : bagData.num;

            render.clip_bg.index = itemData.quality;
            render.img_item.url = itemData.iconSmall;
            render.txt_num.isHtml = true;
            render.clip_eff.visible = itemData.effect;

            if( itemNum >= needNum ){
                render.txt_num.text = "<font color = '#ffffff'>" + itemNum + "/" + needNum + "</font>";
                render.img_black.visible = false;
                render.link_get.visible = false;

            }else{
                render.txt_num.text = "<font color = '#ff0000'>" + itemNum + "/" + needNum + "</font>";
                render.img_black.visible = true;
                render.link_get.visible = true;
                render.link_get.clickHandler = new Handler(_onOpenItemGetWay, [itemId]);
            }

            var goodsItem : GoodsItemUI = new GoodsItemUI();
            goodsItem.img.url = itemData.iconBig;
            goodsItem.quality_clip.index = render.clip_bg.index;
            goodsItem.txt.text = itemNum + '';
            render.toolTip = new Handler( _showQualityTips, [ goodsItem, itemId ] );
        }
        else
        {
            render.img_black.visible = false;
            render.img_item.url = "";
            render.txt_num.text = "";
            render.link_get.visible = false;
            render.img_cd.visible = false;
            render.clip_eff.visible = false;
        }
    }
    /**
     * 物品获得途径
     */
    private function _onOpenItemGetWay(itemId:int):void
    {
        ( (uiCanvas as CAppSystem).stage.getSystem( CItemGetSystem ) as CItemGetSystem).showItemGetPath(itemId);
    }
    private function _showQualityTips(item : GoodsItemUI, itemID : int) : void
    {
        _tipsView.showEquiMaterialTips(item, _playerHelper.getItemTableData(itemID), _playerHelper.getItemData(itemID));
    }

    private function get _tipsView():CEquTipsView
    {
        if(m_pTipsView == null)
        {
            m_pTipsView = new CEquTipsView();
        }

        return m_pTipsView;
    }



    private function onSkillPointNeed( curConsume : SkillEmitterConsume ,label : Label ,needShowColor : Boolean = false ):void{
        if( !curConsume || !label )
            return;
        var color :String = '#ffffff';
        if( needShowColor && curConsume.skillConsumeNum >  _playerData.skillData.skillPoint ){
             color  = '#ff0000';
        }
        label.text = "<font color='" + color + "'>需耗" + curConsume.skillConsumeNum + "体能点</font>";

    }
    private function onGoldNeed( curConsume : SkillEmitterConsume ,label : Label ,needShowColor : Boolean = false ):void{
        if( !curConsume || !label )
            return;
        var color :String = '#ffffff';
        if( needShowColor && curConsume.goldConsumeNum >  _playerData.currency.gold ){
             color  = '#ff0000';
        }
        label.text = "<font color='" + color + "'>需耗" + curConsume.goldConsumeNum + "金币</font>";
    }

    private function getBreachConsume( position : int ):SkillEmitterConsume{
        var pTable : IDataTable  = _databaseSystem.getTable( KOFTableConstants.SKILL_EMITTER_CONSUME );
        var item : SkillEmitterConsume;
        var curConsume : SkillEmitterConsume;
        var tableAry : Array = pTable.toArray();
        for each ( item in tableAry ){
            if( position ==  item.skillEmitterLevel &&
                    _skillPosition == item.skillPositionID &&
                    m_pData.qualityBase == item.Quality
            ){
                curConsume = item;
                break;
            }
        }
       return curConsume;
    }

    public function addListeners():void
    {
    }

    public function removeListeners():void
    {
    }

    public function initView():void
    {
    }
    private function onBreakHandler( ...args):void{
        if( null == m_pSkillData )
                return;
        var position : int = args[0];
        var skillUpHandler : CSkillUpHandler = _playerSystem.getBean( CSkillUpHandler ) as CSkillUpHandler;
        var skillID : int;
        if( m_pSkillData.pSkill ){
            skillID = m_pSkillData.pSkill.ID;
        }else if( m_pSkillData.passiveSkillUp ){
            skillID = m_pSkillData.passiveSkillUp.ID;
        }
        var curConsume : SkillEmitterConsume = getBreachConsume( position );

        if(  _playerData.currency.gold < curConsume.goldConsumeNum ){
            _pUISystem.showMsgAlert('很抱歉，您的金币不足');

            var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as
                    ISystemBundleContext;
            if ( pSystemBundleCtx ) {
                var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.BUY_MONEY ) );
                if ( pSystemBundle ) {
                    pSystemBundleCtx.setUserData( pSystemBundle, "activated", true );
                }
            }

            return;
        }

        if( _playerData.skillData.skillPoint < curConsume.skillConsumeNum ){
            _pUISystem.showMsgAlert('体能点不足');
            return;
        }
        skillUpHandler.onSkillSlotBreakRequest( m_pData.ID , skillID , position );
    }

    public function set view(value:SkillBreachViewUI):void
    {
        m_pViewUI = value;
    }
    public function set data(value:*):void
    {
        m_pData = value as CPlayerHeroData;
    }

    private function get _playerData() : CPlayerData {
        return ( _playerSystem.getBean( CPlayerManager ) as CPlayerManager ).playerData;
    }

    private function get _databaseSystem():CDatabaseSystem {
        return  ( uiCanvas as CAppSystem ).stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
    private function get _playerSystem() : CPlayerSystem {
        return ( uiCanvas as CAppSystem ).stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }
    private function get _bagSystem() : CBagSystem {
        return ( uiCanvas as CAppSystem ).stage.getSystem( CBagSystem ) as CBagSystem;
    }
    private function get _bagManager() : CBagManager {
        return _bagSystem.getBean( CBagManager ) as CBagManager;
    }

    protected function get _playerHelper():CPlayerHelpHandler {
        return _playerSystem.getHandler( CPlayerHelpHandler ) as CPlayerHelpHandler;
    }
    private function get _pUISystem() : CUISystem {
        return ( uiCanvas as CAppSystem ).stage.getSystem( CUISystem ) as CUISystem;
    }

}
}
