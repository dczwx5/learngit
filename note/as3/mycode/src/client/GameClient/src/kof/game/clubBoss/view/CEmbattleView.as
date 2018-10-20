//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/10/27.
 * Time: 15:18
 */
package kof.game.clubBoss.view {

import com.greensock.TweenLite;

import flash.events.Event;

import flash.events.MouseEvent;

import kof.game.clubBoss.CClubBossHandler;
import kof.game.clubBoss.datas.CCBDataManager;
import kof.game.clubBoss.enums.EBossStateType;
import kof.game.clubBoss.enums.EClubBossEventType;
import kof.game.clubBoss.net.CCBNet;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerHeroData;
import kof.ui.master.JueseAndEqu.RoleItem03UI;
import kof.ui.master.clubBoss.CBEmbattleUI;

import morn.core.components.Component;
import morn.core.handlers.Handler;

/**
 * @author yili(guoyiligo@qq.com)
 * 2017/10/27
 * 出阵编制
 */
public class CEmbattleView {
    private var _mainUI : CCBMainView = null;
    private var _embattleUI : CBEmbattleUI = null;
    private var _cbDataManager : CCBDataManager = null;
    private var _cbNet : CCBNet = null;
    private var _currentHeroId : Number = 0;
    private var _pSelectedHeroIdVec : Vector.<Component> = new <Component>[];
    private var _curClickComponent : Component = null;
    private var _curClickHeroId : Number = 0;
    private var _bCanClick : Boolean = true;
    private var _inEmbattleHeroId : Vector.<Number> = new <Number>[];

    private static const ALL:int=0;
    private static const ATTACK : int = 1;
    private static const DEFENSE : int = 2;
    private static const SKILL : int = 3;
    private var _curSelectJob:int=0;


    public function get currentHeroId() : Number {
        return _currentHeroId;
    }

    public function CEmbattleView( mainUI : CCBMainView ) {
        this._mainUI = mainUI;
        this._embattleUI = mainUI.mainUI.embattaleView;
        _init();
    }

    private function _init() : void {
        this._embattleUI.hideBtn.clickHandler = new Handler( _hideView );
        this._embattleUI.list.renderHandler = new Handler( _renderHero );
        _cbDataManager = this._mainUI.system.getBean( CCBDataManager ) as CCBDataManager;
        this._cbNet = (this._mainUI.system.getBean( CClubBossHandler ) as CClubBossHandler).cbNet;

        this._embattleUI.tabBtn.selectHandler = new Handler( _selectHeroJob );
        _addEvent();
    }

    private function _selectHeroJob( idx : int ) : void {
        var arr : Array = [];
        _curSelectJob = idx;
        if ( idx == ALL ) {//全部
            this._embattleUI.list.dataSource = _screenHeroJob( ALL );
        } else if ( idx == ATTACK ) {//攻
            this._embattleUI.list.dataSource = _screenHeroJob( ATTACK );
        } else if ( idx == DEFENSE ) {//防
            this._embattleUI.list.dataSource = _screenHeroJob( DEFENSE );
        } else if ( idx == SKILL ) {//技
            this._embattleUI.list.dataSource = _screenHeroJob( SKILL );
        }
    }

    private function _screenHeroJob( type : int ) : Array {
        if(type==ALL){
            _cbDataManager.playerData.heroList.list.sort(_compareFight);
            return _cbDataManager.playerData.heroList.list;
        }
        var newArr : Array = [];
        var len : int = _cbDataManager.playerData.heroList.list.length;
        var arr : Array = _cbDataManager.playerData.heroList.list;
        for ( var i : int = 0; i < len; i++ ) {
            if ( arr[ i ].job == type-1 ) {
                newArr.push( arr[ i ] );
            }
        }
        newArr.sort(_compareFight);
        return newArr;
    }

    private function _compareFight(a:CPlayerHeroData,b:CPlayerHeroData):int{
        if(a.battleValue>b.battleValue){
            return -1;
        }else if(a.battleValue<b.battleValue){
            return 1;
        }else{
            if(a.ID>b.ID){
                return -1;
            }else if(a.ID<b.ID){
                return 1;
            }else{
                return 0;
            }
        }
    }

    private function _addEvent() : void {
        _cbDataManager.addEventListener( EClubBossEventType.SET_EMBATTLE, _setEmbattleResponse );
        this._cbDataManager.addEventListener( EClubBossEventType.UPDATE_MAINUI, _updateUI );
    }

    public function _updateUI( e : Event ) : void {
        _inEmbattleHeroId.splice( 0, _inEmbattleHeroId.length );
        var len : int = _cbDataManager.vec_BossInfo.length;
        for ( var i : int = 0; i < len; i++ ) {
            var heroId : int = _cbDataManager.vec_BossInfo[ i ].heroId;
            _inEmbattleHeroId.push( heroId );
        }
        this._embattleUI.list.dataSource = _screenHeroJob(_curSelectJob);
    }

    private function _setEmbattleResponse( e : Event ) : void {
        var errorCode : Number = _cbDataManager.promptID;
        if ( _cbDataManager.promptID != 0 ) {
            this._mainUI.showPrompt( errorCode );
        } else {
//            _embattleHero( _curClickComponent, _curClickHeroId );
            _cbNet.queryClubBossInfoRequest();
            if ( _curClickHeroId != 0 ) {
                this._mainUI.showPrompt( 2806 );
            } else {
                this._mainUI.showPrompt( 2808 );
            }
        }
        _bCanClick = true;
    }

    private function _renderHero( comp : Component, idx : int ) : void {
        comp.getChildByName( "selectImg" ).visible = false;
        comp.getChildByName( "blackImg" ).visible = false;
        var itemUI : RoleItem03UI = comp.getChildByName( "roleItem" ) as RoleItem03UI;
        var data : CPlayerHeroData = comp.dataSource as CPlayerHeroData;
        if ( !data )return;
        itemUI.icon_image.url = CPlayerPath.getUIHeroIconMiddlePath( data.prototypeID );
        itemUI.icon_image.mask = itemUI.hero_icon_mask;
        itemUI.clip_intell.index = data.qualityBaseType;
//        itemUI.clip_career.index = data.job;
        itemUI.clip_career.visible = false;
        itemUI.star_list.repeatX = data.star;
        itemUI.toolTip = new Handler(_playerSystem.showHeroTips, [data]);
        comp.addEventListener( MouseEvent.CLICK, _selectHeroClick );
        if ( _inEmbattleHeroId.indexOf( data.prototypeID ) != -1 ) {
            comp.getChildByName( "selectImg" ).visible = true;
        }
    }

    private function get _playerSystem():CPlayerSystem{
        return _mainUI.system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
    }

    public function unloadHero( index : int ) : void {
        if ( !_bCanClick )return;
        _bCanClick = false;
        _curClickHeroId = 0;
        var net : CCBNet = (this._mainUI.system.getBean( CClubBossHandler ) as CClubBossHandler).cbNet;
        net.unloadHeroRequest( index );
    }

    private function _selectHeroClick( e : MouseEvent ) : void {
        if ( !_bCanClick )return;
        _bCanClick = false;
        _curClickComponent = e.currentTarget as Component;
        _curClickHeroId = (_curClickComponent.dataSource as CPlayerHeroData).prototypeID;
        if ( _curClickComponent.getChildByName( "selectImg" ).visible ) { // 勾选状态，表明已出战
            if ( _curClickHeroId != this._mainUI.bossItemView.currentHeroId ) {
                this._mainUI.showPrompt( 2809 ); //提示已出战其他boss
                _bCanClick = true;
            } else {
                if(_curClickHeroId == this._mainUI.bossItemView.currentHeroId){
                    if ( this._mainUI.bossItemView.getCurSelectBossItemForState() == EBossStateType.BEAT ) {
                        this._mainUI.showPrompt( 2810 ); //已击败不能下阵
                        _bCanClick = true;
                    } else {
                        _curClickHeroId = 0;
                        this._cbNet.unloadHeroRequest( this._mainUI.bossItemView.currentSelectBossId ); //下阵
                    }
                }
            }
        } else {
            if ( this._mainUI.bossItemView.getCurSelectBossItemForState() == EBossStateType.BEAT ) {
                this._mainUI.showPrompt( 2810 ); //已击败不能下阵
                _bCanClick = true;
                return;
            }
            this._cbNet.setClubBossRequest( this._mainUI.bossItemView.currentSelectBossId, _curClickHeroId );
        }
    }

    private function _embattleHero( comp : Component, heroId : Number ) : void {
        comp.getChildByName( "selectImg" ).visible = true;
        _currentHeroId = heroId;
        var heroIdIndex : int = _inEmbattleHeroId.indexOf( heroId );
        if ( heroIdIndex != -1 ) {
            _inEmbattleHeroId.splice( heroIdIndex, 1 ); //下阵处理
        }
        var replaceHeroId : Number = this._mainUI.bossItemView.currentHeroId;
        for ( var i : int = 0; i < _pSelectedHeroIdVec.length; i++ ) {
            var serchHeroId : Number = CPlayerHeroData( _pSelectedHeroIdVec[ i ].dataSource ).prototypeID;
            if ( serchHeroId == replaceHeroId ) {
                _pSelectedHeroIdVec[ i ].getChildByName( "selectImg" ).visible = false;
                if ( _inEmbattleHeroId.indexOf( replaceHeroId ) != -1 ) {
                    _inEmbattleHeroId.splice( _inEmbattleHeroId.indexOf( replaceHeroId ), 1 );//替换处理
                }
            }
        }
        this._mainUI.bossItemView.setHero( heroId );
        _pSelectedHeroIdVec.push( comp );
    }

    private function _hideView() : void {
        TweenLite.to( this._embattleUI, 0.5, {x : this._mainUI.mainUI.pt.x, onComplete : _hideSelf} );
    }

    private function _hideSelf() : void {
        this._mainUI.mainUI.embattaleView.visible = false;
    }
}
}
