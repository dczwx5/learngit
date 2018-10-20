//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/3/17.
 */
package kof.game.player.view.skillup {

import flash.events.MouseEvent;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.IDataTable;
import kof.game.common.CRewardUtil;
import kof.game.common.view.CChildView;
import kof.game.common.view.CViewExternalUtil;
import kof.game.item.data.CRewardListData;
import kof.game.item.view.part.CRewardItemListView;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.data.CSkillData;
import kof.game.player.enum.EPlayerWndTabType;
import kof.game.player.event.CPlayerEvent;
import kof.table.BreachLvConst;
import kof.table.SkillEmitterConsume;

import morn.core.components.Box;
import morn.core.components.FrameClip;
import morn.core.events.UIEvent;
import morn.core.handlers.Handler;

public class CSkillBreachView extends CChildView {

    private var m_breach : Object;

    private var _playerHeroData : CPlayerHeroData;

    private var _skillData : CSkillData;

    private var _skillID : int;

    private var _curPositon : int ;

    private var m_viewExternal : CViewExternalUtil;

    private var _breachLvConst : BreachLvConst;

    public function CSkillBreachView() {
        super();
    }

    protected override function _onCreate() : void {
        // can not call super._onCreate in this class
        this.setNoneData();
    }
    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }
    protected override function _onShow():void {
        // can not call super._onShow in this class

        _playerSystem.listenEvent(_onDataUpdate);

    }
    protected override function _onHide() : void {
        // can not call super._onHide in this class
        _removeEventListener();
        _playerSystem.unListenEvent(_onDataUpdate);
    }


    public virtual override function updateWindow() : Boolean {
        super.updateWindow();

        _data[0]
        _playerHeroData = _data[1] as CPlayerHeroData;
        m_breach = _ui.view_breach;
        m_breach.detail.btn_break.clickHandler = new Handler( onBreakHandler );
        _addEventListener();

        var pTable : IDataTable  = _databaseSystem.getTable( KOFTableConstants.BREACH_LV_CONST );
        _breachLvConst = pTable.findByPrimaryKey( 1 );

        m_viewExternal = new CViewExternalUtil( CRewardItemListView, this, m_breach.detail);

        m_breach.box_1.visible =
                m_breach.box_2.visible =
                        m_breach.box_3.visible =
                                false;
        return true;
    }

    public function updateView( skillData : CSkillData ):void{

        _skillData = skillData;
        resetHandler();
        var i : int ;
        var item : Object;
        for( i = 1 ; i <= 3 ; i++ ){
            item  = m_breach['position_' + i];
            positionItemHandler( item , i );
        }
        if( _skillData.pSkill ){
            m_breach.imgItem.img.url = CPlayerPath.getSkillBigIcon( _skillData.pSkill.IconName );
            _skillID = _skillData.pSkill.ID;
            _skillData.skillPosition == 5 ? m_breach.imgItem.clip_kuang.index = 1 : m_breach.imgItem.clip_kuang.index = 0;
        }else if( _skillData.passiveSkillUp ){
            m_breach.imgItem.img.url = CPlayerPath.getSkillBigIcon( _skillData.passiveSkillUp.icon );
            _skillID = _skillData.passiveSkillUp.ID;
        }

        m_breach.position_1.dispatchEvent( new MouseEvent( MouseEvent.CLICK ));

    }
    private function positionItemHandler( item : Object , i : int ):void{
        var obj : Object = getPositionInfo(i);
        if( obj ){
            item.dataSource = obj;
            if( obj.isBreak ){
                positionItemView( item , CSkillUpConst.position_isBreak );
            }else if( obj.isActive ){
                positionItemView( item , CSkillUpConst.position_isActive );
            }
        }else{
            positionItemView( item , CSkillUpConst.position_lock );
        }
    }
    private function getPositionInfo( i : int ):Object{
        for each( var obj : Object in _skillData.slotListData.list ){
            if( obj.position == i ){
                return obj;
                break;
            }
        }
        return null;
    }
    private function positionItemView( item : Object ,state :int ):void{
        if( state == CSkillUpConst.position_lock ){
            item.img_lock.visible = true;
            item.img_blue.visible = item.img_fire.visible = false;
            item.img_lightning.visible = item.img_yellove.visible = false;
        }else if( state == CSkillUpConst.position_isActive ){
            item.img_lock.visible = false;
            item.img_blue.visible = item.img_fire.visible = true;
            item.img_lightning.visible = item.img_yellove.visible = false;
        }else if( state == CSkillUpConst.position_isBreak ){
            item.img_lock.visible = false;
            item.img_blue.visible = item.img_fire.visible = false;
            item.img_lightning.visible = item.img_yellove.visible = true;
        }
    }

    private function _onItemClickHandler( evt : MouseEvent ):void{
        var item : Object = evt.currentTarget as Object;
        var position : int = int( item.name.slice( item.name.indexOf('_') + 1,item.name.length ));
        var obj : Object = item.dataSource;
        if( obj ){
            _curPositon = obj.position;
            if( obj.isBreak ){
                detailView( CSkillUpConst.position_isBreak );
            }else if( obj.isActive ){
                detailView( CSkillUpConst.position_isActive );
                getBreachConsume( obj.position );
            }
        }else{
            detailView( CSkillUpConst.position_lock );
            unlockTxt( position );
            _curPositon = -1;
        }
        detailTxt( position );
    }
    private function detailView( state :int ):void{
        if( state == CSkillUpConst.position_lock ){
            m_breach.detail.box_lock.visible = true;
            m_breach.detail.box_isActive.visible =
                    m_breach.detail.box_isBreak.visible = false;
        }else if( state == CSkillUpConst.position_isActive ){
            m_breach.detail.box_isActive.visible = true;
            m_breach.detail.box_lock.visible =
                    m_breach.detail.box_isBreak.visible = false;

        }else if( state == CSkillUpConst.position_isBreak ){
            m_breach.detail.box_isBreak.visible = true;
            m_breach.detail.box_lock.visible =
                    m_breach.detail.box_isActive.visible = false;
        }
    }

    private function detailTxt( position : int ):void{
        if( _skillData.activeSkillUp ){
            m_breach.detail.txt.text = _skillData.activeSkillUp['emittereffectdesc' + position];
        }else if( _skillData.passiveSkillUp ){
            m_breach.detail.txt.text = _skillData.passiveSkillUp['emittereffectdesc' + position];
        }
    }
    private function unlockTxt( position : int ):void{
        m_breach.detail.txt_unlock.text = '开启需要技能等级：' + _breachLvConst['needSkillLv' + position];
    }

    private function _addEventListener():void{
        _removeEventListener();
        if( m_breach ){
            m_breach.position_1.addEventListener( MouseEvent.CLICK,  _onItemClickHandler , false, 0, true);
            m_breach.position_2.addEventListener( MouseEvent.CLICK,  _onItemClickHandler , false, 0, true);
            m_breach.position_3.addEventListener( MouseEvent.CLICK,  _onItemClickHandler , false, 0, true);
        }
    }
    private function _removeEventListener():void{
        if( m_breach ){
            m_breach.position_1.removeEventListener( MouseEvent.CLICK,  _onItemClickHandler );
            m_breach.position_2.removeEventListener( MouseEvent.CLICK,  _onItemClickHandler );
            m_breach.position_3.removeEventListener( MouseEvent.CLICK,  _onItemClickHandler );
        }
    }
    private function resetHandler():void{
        var i : int ;
        var item : Object;
        for( i = 1 ; i <= 3 ; i++ ){
            item  = m_breach['position_' + i];
            item.dataSource = null;
            positionItemView( item , CSkillUpConst.position_lock );
        }
        _curPositon = -1;
    }

    private function getBreachConsume( position : int ):void{
        var pTable : IDataTable  = _databaseSystem.getTable( KOFTableConstants.SKILL_EMITTER_CONSUME );
        var item : SkillEmitterConsume;
        var curConsume : SkillEmitterConsume;
        var tableAry : Array = pTable.toArray();
        for each ( item in tableAry ){
            if( position ==  item.skillEmitterLevel &&
                    _skillData.skillPosition == item.skillPositionID &&
                    _playerHeroData.qualityBase == item.Quality
            ){
                curConsume = item;
                break;
            }
        }
        if( !curConsume )return;
        m_viewExternal.show();
        var ary:Array = [];
        var obj:Object;
        var i:int;
        for( i = 1 ; i <= 2 ; i++ ){
            obj = {};
            obj.ID = curConsume['item' + i];
            obj.num = curConsume['count' + i];
            if( obj.ID != 0 && obj.num != 0)
                ary.push( obj );
        }
        var rewardDataList : CRewardListData = CRewardUtil.createByList( (uiCanvas as CAppSystem).stage, ary );
        m_viewExternal.setData( rewardDataList );
        m_viewExternal.updateWindow();

    }

    private function onBreakHandler():void{
        if( _curPositon < 0 ) return;
        var skillUpHandler : CSkillUpHandler = _playerSystem.getBean( CSkillUpHandler ) as CSkillUpHandler;
        skillUpHandler.onSkillSlotBreakRequest( _playerHeroData.ID , _skillID , _curPositon );
    }

    private function _onDataUpdate(e:CPlayerEvent) : void {
        switch ( e.type ) {
            case CPlayerEvent.SKILL_BREAK:
                if( _curPositon < 0 ) return;
                reduceEffHandler( m_breach['box_' + _curPositon] ,m_breach['frameclip_jihuo' + _curPositon]);
                break;
        }
    }

    private function reduceEffHandler( ctn: Box , frameClip : FrameClip):void{
        stopeff();
        frameClip.addEventListener(UIEvent.FRAME_CHANGED,onChanged);
        ctn.visible = true;
        frameClip.gotoAndPlay(0);
        function onChanged(evt:UIEvent):void{
            if( frameClip.frame >=  frameClip.totalFrame - 1) {
                stopeff();
            }
        }
        function stopeff():void{
            frameClip.removeEventListener( UIEvent.FRAME_CHANGED, onChanged );
            frameClip.stop();
            ctn.visible = false;
        }
    }
    private function get _ui() : Object{
        return (rootUI as Object).viewStack.items[EPlayerWndTabType.STACK_ID_HERO_SKILL_UP] as Object
    }

    private function get _playerSystem() : CPlayerSystem {
        return ( uiCanvas as CAppSystem ).stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }
    private function get _playerData() : CPlayerData {
        return ( _playerSystem.getBean( CPlayerManager ) as CPlayerManager ).playerData;
    }
    private function get _skillUpHandler() : CSkillUpHandler {
        return  _playerSystem.getBean(CSkillUpHandler) as CSkillUpHandler;
    }
    private function get _databaseSystem():CDatabaseSystem {
        return  ( uiCanvas as CAppSystem ).stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
}
}
