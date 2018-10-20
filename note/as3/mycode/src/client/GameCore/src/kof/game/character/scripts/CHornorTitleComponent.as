//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2018/6/12.
//----------------------------------------------------------------------
package kof.game.character.scripts {

import QFLib.Foundation;
import QFLib.Framework.CFX;
import QFLib.Framework.CFX;

import flash.events.Event;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;

import kof.framework.IDataTable;

import kof.framework.IDatabase;

import kof.framework.events.CEventPriority;

import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CCharacterEvent;
import kof.game.character.CDatabaseMediator;
import kof.game.character.CEventMediator;
import kof.game.character.animation.IAnimation;
import kof.game.character.display.IDisplay;

import kof.game.character.fx.CFXMediator;
import kof.game.character.level.CLevelMediator;
import kof.game.character.property.CPlayerProperty;
import kof.game.character.state.CCharacterStateBoard;

import kof.game.core.CSubscribeBehaviour;
import kof.table.TitleConfig;

//特效版
public class CHornorTitleComponent extends CSubscribeBehaviour {
    public function CHornorTitleComponent() {
        super( "Honor Component" );
    }

    override public function update( delta : Number ) : void {
//        if( pAnimation && pAnimation.modelDisplay && pAnimation.modelDisplay.visible ) {
//            this.enabled = true;
            if ( pDisplay && pDisplay.modelDisplay && !isNaN( m_yOffSet ) ) {
                var zIdx : Number;

                zIdx = pDisplay.modelDisplay.position.z;

                if ( m_bodyFX )
                    m_bodyFX.setPositionTo( pDisplay.modelDisplay.position.x, pDisplay.modelDisplay.position.y - (m_yOffSet + 50) / 2, zIdx + 1 );
                if ( m_titleFX )
                    m_titleFX.setPositionTo( pDisplay.modelDisplay.position.x, pDisplay.modelDisplay.position.y - m_yOffSet, zIdx );
            }
//        }else {
//            this.enabled = false;
//        }
    }

    final private function get pDisplay() : IDisplay {
        return owner.getComponentByClass( IDisplay, true ) as IDisplay;
    }

    private function get pAnimation() : IAnimation{
        return owner.getComponentByClass( IAnimation , true ) as IAnimation;
    }

    override public function dispose() : void {
        if ( m_bodyFX && !m_bodyFX.disposed )
            CFX.manuallyRecycle( m_bodyFX );
        if ( m_titleFX && !m_titleFX.disposed )
            CFX.manuallyRecycle( m_titleFX );

        m_bodyFX = null;
        m_titleFX = null;
        m_pFxMediator = null;
    }

    override protected function onEnter() : void {
        m_pFxMediator = owner.getComponentByClass( CFXMediator, true ) as CFXMediator;
        m_pLevelMediator = owner.getComponentByClass( CLevelMediator , true ) as CLevelMediator;
        var pEventMediator : CEventMediator = owner.getComponentByClass( CEventMediator, true ) as CEventMediator;
        pEventMediator.addEventListener( CCharacterEvent.DISPLAY_READY, _onCharacterDisplayReady, false, CEventPriority.DEFAULT, true );
        var pDB : CDatabaseMediator = owner.getComponentByClass( CDatabaseMediator , true ) as CDatabaseMediator;
        m_pTitleTable = pDB.getTable(KOFTableConstants.TitleConfig);
    }

    private function _onCharacterDisplayReady( e : Event ) : void {
        if ( pDisplay && pDisplay.defaultBound )
            m_yOffSet = -pDisplay.defaultBound.height - 50;
    }

    override public function set enabled( value : Boolean ) : void {
        if ( this.enabled == value ) return;
        super.enabled = value;
        show(value);
    }

    protected function show( value : Boolean ) : void {
        if ( !value ) {
            if ( m_titleFX ) {
                m_titleFX.pause();
                m_titleFX.visible = false;
            }
            if ( m_bodyFX ) {
                m_bodyFX.pause();
                m_bodyFX.visible = false;
            }
        } else {
            if ( m_titleFX ) {
                m_titleFX.play();
                m_titleFX.visible = true;
            }
            else {
                _updateTitleFx();
            }
            ;
            if ( m_bodyFX ) {
                m_bodyFX.play();
                m_bodyFX.visible = true;
            }
            else {
                _updateBodyFx();
            }
            ;
        }
    }

    override protected function onDataUpdated() : void {
        super.onDataUpdated();
        var playProperty : CPlayerProperty = owner.getComponentByClass( CPlayerProperty, false ) as CPlayerProperty;
        if ( playProperty ) {
            var playerHonorID : int = playProperty.honorID ;
            if ( playerHonorID != m_honorID  ) {
                m_honorID = playerHonorID;
                _updateHonor();
            }
        }
    }

    private function _updateHonor() : void {
        _updateBodyFx();
        _updateTitleFx();
    }

    private function _updateTitleFx() : void {
        if(!m_pLevelMediator || !m_pLevelMediator.isMainCity ) return;
        if ( m_titleFX )
            CFX.manuallyRecycle( m_titleFX );
        m_titleFX = null;

        var titleFx : String = getTitleFx();
        m_titleFX = m_pFxMediator.createFXLoop( titleFx, 0, 0, 0 );
    }

    private function _updateBodyFx() : void {
        if(!m_pLevelMediator || !m_pLevelMediator.isMainCity ) return;
        if ( m_bodyFX )
            CFX.manuallyRecycle( m_bodyFX )
        m_bodyFX = null;

        var bodyFX : String = getBodyFx();
        m_bodyFX = m_pFxMediator.createFXLoop( bodyFX, 0, 0, 0 );
    }

    private function getTitleFx() : String {
        if( m_honorID > 0 ) {
            var titleConfig : TitleConfig = m_pTitleTable.findByPrimaryKey( m_honorID );
            if ( titleConfig == null ) {
                Foundation.Log.logWarningMsg( "can not find config data in table ID = " + m_honorID );
            } else {
//            return "npc_touding_ui_tx/npc_ui_tx_0007";
                return titleConfig.wearHeadEffect;
            }
        }
        return "";
    }

    private function getBodyFx() : String {
        if( m_honorID > 0 ) {
            var titleConfig : TitleConfig = m_pTitleTable.findByPrimaryKey( m_honorID );
            if ( titleConfig == null ) {
                Foundation.Log.logWarningMsg( "can not find config data in table ID = " + m_honorID );
            } else {
//            return "tx_huanjingguang/tx_huanjingguang_0002";
                return titleConfig.wearBodyEffect;
            }
        }
        return "";
    }

    private var m_titleFX : CFX;
    private var m_bodyFX : CFX;
    private var m_pFxMediator : CFXMediator;
    private var m_pLevelMediator : CLevelMediator;
    private var m_honorID : int;
    private var m_yOffSet : Number;
    private var m_pTitleTable : IDataTable;
}
}
