//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/8/17.
//----------------------------------------------------------------------
package kof.game.character.scripts {

import QFLib.Graphics.Sprite.CSpriteText;

import flash.events.Event;

import kof.framework.events.CEventPriority;
import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.character.display.IDisplay;
import kof.game.character.handler.CPlayHandler;
import kof.game.character.property.CPlayerProperty;
import kof.game.character.property.interfaces.ITXPlatformProperty;
import kof.game.character.scripts.playersprite.CPlayerSpriteContainer;
import kof.game.character.scripts.playersprite.CPlayerSpriteItem;
import kof.game.character.scripts.playersprite.CVipTextConst;
import kof.game.core.CSubscribeBehaviour;

public class CTXVipSprite extends CSubscribeBehaviour {
    public function CTXVipSprite( thePHandle : CPlayHandler = null ) {
        super( "TxVipSprite" );
        this.m_pPlayerHandler = thePHandle;
    }

    override public function dispose() : void {
        m_theSpriteContainer = null;
    }

    override protected function onEnter() : void {

        var pEventMediator : CEventMediator = owner.getComponentByClass( CEventMediator, true ) as CEventMediator;
        pEventMediator.addEventListener( CCharacterEvent.DISPLAY_READY, _onCharacterDisplayReady, false, CEventPriority.DEFAULT, true );

    }

    override public function update( delta : Number ) : void {

        if ( m_theSpriteContainer )
            m_theSpriteContainer.update( delta );
    }

    override public function set enabled( value : Boolean ) : void {
        if ( this.enabled == value ) return;
        super.enabled = value;
        if ( value ) {
            _showVipIcons();
        } else {
            _destroyIcons();
        }
    }

    public function addSpriteText( text : CSpriteText, width : int = 160, height : int = 60,
                                   priority : int = -1, extraX : Number = 0.0, extraY : Number = 0.0 ) : void {
        if ( !text ) return;
        if ( !m_theSpriteContainer )
            _initialContainer();

        if ( m_theSpriteContainer.hasSpriteText( text ) ) return;

        var item : CPlayerSpriteItem = new CPlayerSpriteItem( m_theSpriteContainer );
        item.setSpriteText( text, width, height, priority );
        item.setExtraPosition( extraX, extraY );
        m_theSpriteContainer.addSpriteItem( item );
    }

    public function removeSpriteItem( item : CPlayerSpriteItem ) : void {
        if ( !item || !m_theSpriteContainer ) return;
        m_theSpriteContainer.removeSpriteItem( item );
    }

    override protected function onExit() : void {
        if ( m_theSpriteContainer )
            m_theSpriteContainer.dispose();

        var pEventMediator : CEventMediator = owner.getComponentByClass( CEventMediator, true ) as CEventMediator;
        if ( pEventMediator )
            pEventMediator.removeEventListener( CCharacterEvent.DISPLAY_READY, _onCharacterDisplayReady );
    }

    private function _destroyIcons() : void {
        if ( m_theSpriteContainer )
            m_theSpriteContainer.dispose();
        m_theSpriteContainer = null;
    }

    override protected function onDataUpdated() : void {
        super.onDataUpdated();
        if ( !enabled )
            return;
        if ( m_boDisplayReady )
            _showGameVipIcons();
        var pTxPlatformProperty : ITXPlatformProperty = owner.getComponentByClass( ITXPlatformProperty, true ) as ITXPlatformProperty;
        if ( pTxPlatformProperty ) {
            var pf : String = pTxPlatformProperty.pf;
            if ( pf == null || pf == "" )
                return;

            if ( m_boDisplayReady && !m_boShow ) {
                _showVipIcons();
            }
        }
    }

    private function _onCharacterDisplayReady( e : Event ) : void {
        if ( !enabled ) return;
        m_boDisplayReady = true;
        if ( m_boShow )
            return;

        _showVipIcons();
        _showGameVipIcons();
    }

    private function _showVipIcons() : void {
        _initialContainer();
        var pTxPlatformProperty : ITXPlatformProperty = owner.getComponentByClass( ITXPlatformProperty, true ) as ITXPlatformProperty;
        if( pTxPlatformProperty == null )
                return;

        m_boShow = true;
        var pf : String = pTxPlatformProperty.pf;
        if ( pf == null || pf == "" )
            return;
        if ( pf == "qqgame" )
            _setupBlueVipInfo( pTxPlatformProperty );
        if ( pf == "qzone" )
            _setupYellowVipInfo( pTxPlatformProperty );

    }

    private function _showGameVipIcons() : void {

        _initialContainer();
        var playerProperty : CPlayerProperty = owner.getComponentByClass( CPlayerProperty, true ) as CPlayerProperty;
        if( playerProperty == null )
                return;

        if ( playerProperty.vipLevel != m_currentGameVipLevel ) {
            m_currentGameVipLevel = playerProperty.vipLevel;
            showGameVipInfo( playerProperty.vipLevel );
        }
    }

    private function _initialContainer() : void {
        if ( m_theSpriteContainer == null ) {
            var iDisplay : IDisplay = getComponent( IDisplay ) as IDisplay;
            var yOffSet : Number;
            if ( iDisplay.defaultBound )
                yOffSet = -iDisplay.defaultBound.height;

            var pProperty : CPlayerProperty = getComponent( CPlayerProperty ) as CPlayerProperty;
            if ( pProperty ) {
                yOffSet -= pProperty.namedOffsetY;
            }

            m_theSpriteContainer = new CPlayerSpriteContainer( owner, 1, 10, 50, yOffSet, 2, 2 );
        }
    }

    private function _setupBlueVipInfo( pTxProperty : ITXPlatformProperty ) : void {
        if ( pTxProperty.blueVipLevel > 0 ) {
            if ( pTxProperty.isSuperBlueVip ) {
                showBlueSuper( pTxProperty.blueVipLevel );
                if ( pTxProperty.isBlueYearVip )
                    showBlueYear();
            } else if ( pTxProperty.isBlueVip ) {
                showBlue( pTxProperty.blueVipLevel );
                if ( pTxProperty.isBlueYearVip )
                    showBlueYear();
            }
        }
    }

    private function _setupYellowVipInfo( pTxProperty : ITXPlatformProperty ) : void {
        if ( pTxProperty.yellowVipLevel > 0 ) {
            if ( pTxProperty.isYellowHighVip ) {
                if ( pTxProperty.isYellowYearVip )
                    showYellowYear( pTxProperty.yellowVipLevel );
                else
                    showYellow( pTxProperty.yellowVipLevel );
            } else if ( pTxProperty.isYellowVip ) {
                if ( pTxProperty.isYellowYearVip )
                    showYellowYear( pTxProperty.yellowVipLevel );
                else
                    showYellow( pTxProperty.yellowVipLevel );
            }
        }
    }

    //蓝钻
    private function showBlueSuper( level : int ) : void {
        var spriteItem : CPlayerSpriteItem;
        var text : String = CVipTextConst.getSuperBlueYearByLevel( level );
        spriteItem = _createSpriteItem( text, 21, 20, 9 );
        m_theSpriteContainer.addSpriteItem( spriteItem );
    }

    private function showBlue( level : int ) : void {
        var spriteItem : CPlayerSpriteItem;
        var text : String = CVipTextConst.getBlueByLevel( level );
        spriteItem = _createSpriteItem( text, 21, 19, 9 );
        m_theSpriteContainer.addSpriteItem( spriteItem );
    }

    private function showBlueYear() : void {
        var spriteItem : CPlayerSpriteItem;
        var text : String = CVipTextConst.BLUE_YEAR.toString();
        spriteItem = _createSpriteItem( text, 18, 18, 0 );
        m_theSpriteContainer.addSpriteItem( spriteItem );
    }

    //黄钻
    private function showYellow( lvl : int ) : void {
        var spriteItem : CPlayerSpriteItem;
        var text : String = CVipTextConst.getYellowByLevel( lvl ).toString();
        spriteItem = _createSpriteItem( text, 24, 17, 9 );
        m_theSpriteContainer.addSpriteItem( spriteItem );
    }

    private function showYellowYear( level : int ) : void {
        var spriteItem : CPlayerSpriteItem;
        var text : String = CVipTextConst.getYearYellowByLevel( level ).toString();
        spriteItem = _createSpriteItem( text, 44, 17, 9 );
        m_theSpriteContainer.addSpriteItem( spriteItem );
    }

    private function showGameVipInfo( level: int ) : void {
        var spriteItem : CPlayerSpriteItem;
        var text : String = CVipTextConst.getYearYellowByLevel( level + 1 ).toString();
        if( m_currentGameVipItem == null ) {
            spriteItem = _createPlayerVipItem( text, 38, 31, 10, 8 , -7 );
            m_theSpriteContainer.addSpriteItem( spriteItem );
            m_currentGameVipItem = spriteItem;
        }else{
            m_currentGameVipItem.setText(text);
        }
    }

    private function _createSpriteItem( text : String, width : int, height : int, priority : int ) : CPlayerSpriteItem {
        var spriteItem : CPlayerSpriteItem = new CPlayerSpriteItem( m_theSpriteContainer );
        spriteItem.createSpriteText( text, CVipTextConst.TX_VIP_FONT, CVipTextConst.FONT_SIZE, width, height, priority );
        return spriteItem;
    }

    private function _createPlayerVipItem(text : String, width : int, height : int, priority : int ,extrax : Number = 0.0 ,extray:Number = 0.0) : CPlayerSpriteItem {
        var spriteItem : CPlayerSpriteItem = new CPlayerSpriteItem( m_theSpriteContainer );
        spriteItem.createSpriteText( text, CVipTextConst.PLAYER_VIP,38, width, height, priority ,extrax, extray);
        return spriteItem;
    }

    private var m_theSpriteContainer : CPlayerSpriteContainer;
    private var m_boDisplayReady : Boolean;
    private var m_boShow : Boolean;
    private var m_pPlayerHandler : CPlayHandler;
    private var m_BocurrentVip : Boolean;
    private var m_currentGameVipLevel : int;
    private var m_currentGameVipItem : CPlayerSpriteItem;
}
}
