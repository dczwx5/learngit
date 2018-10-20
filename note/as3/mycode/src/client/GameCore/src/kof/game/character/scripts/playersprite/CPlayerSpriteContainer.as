//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/8/17.
//----------------------------------------------------------------------
package kof.game.character.scripts.playersprite {

import QFLib.Framework.CCharacter;
import QFLib.Graphics.RenderCore.CBaseObject;
import QFLib.Graphics.Sprite.CSpriteSystem;
import QFLib.Graphics.Sprite.CSpriteText;
import QFLib.Interface.IDisposable;
import QFLib.Interface.IUpdatable;
import QFLib.Math.CVector3;

import flash.events.Event;

import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.character.animation.CCharacterDisplay;
import kof.game.character.animation.IAnimation;
import kof.game.character.display.IDisplay;
import kof.game.character.property.CPlayerProperty;
import kof.game.core.CGameObject;

public class CPlayerSpriteContainer implements IDisposable, IUpdatable {
    public function CPlayerSpriteContainer( owner : CGameObject, maxRow : int = 10, maxColumn : int = 10,
                                            xOffset : Number = 0, yOffSet : Number = 0, hPadding : Number = 0,
                                            vPadding : Number = 0 ) {
        m_pOwner = owner;
        m_nMaxColumn = maxColumn;
        m_nMaxRow = maxRow;
        m_nBaseX = xOffset;
        m_nBaseY = yOffSet;
        m_nVPadding = vPadding;
        m_nHPadding = hPadding;
        _initialized();
    }

    public function dispose() : void {

        var pEventMed : CEventMediator = m_pOwner.getComponentByClass( CEventMediator, true ) as CEventMediator;
        if ( pEventMed )
            pEventMed.removeEventListener( CCharacterEvent.DISPLAY_READY, _onUpdatePos );

        if ( m_theSpriteItems ) {
            for each( var item : CPlayerSpriteItem in m_theSpriteItems ) {
                item.dispose();
            }
            m_theSpriteItems.splice( 0, m_theSpriteItems.length );
            m_theSpriteItems = null;
        }

        if ( m_theContainerObj )
            m_theContainerObj.dispose();
        m_theContainerObj = null;

        m_pOwner = null;
        m_nMaxColumn = 0;
        m_nMaxRow = 0;
    }

    public function update( delta : Number ) : void {
        if ( pAnimation ) {
            var vHeroPos : CVector3 = modelDisplay.theObject.position;
            m_theContainerObj.setPosition( vHeroPos.x + m_nBaseX - m_curWidth, vHeroPos.y + m_nBaseY - m_curHeight / 2, vHeroPos.z );
        }

    }

    private function _initialized() : void {
        if ( null == m_theContainerObj )
            m_theContainerObj = new CBaseObject( modelDisplay.theObject.renderer );

        modelDisplay.theObject.parent.addChild( m_theContainerObj );
        m_theContainerObj.setPosition( m_nBaseX, m_nBaseY );

        var pDisplayer : CCharacterDisplay = m_pOwner.getComponentByClass( CCharacterDisplay, false ) as CCharacterDisplay;
        if ( pDisplayer )
            m_pSpriteSystem = pDisplayer.modelDisplay.belongFramework.spriteSystem;
        m_theSpriteItems = new <CPlayerSpriteItem>[];

        var pEventMed : CEventMediator = m_pOwner.getComponentByClass( CEventMediator, true ) as CEventMediator;
        if ( pEventMed )
            pEventMed.addEventListener( CCharacterEvent.DISPLAY_READY, _onUpdatePos );
    }

    public function removeSpriteItem( item : CPlayerSpriteItem ) : void {
        var index : int = m_theSpriteItems.indexOf( item );
        if ( index > -1 )
            m_theSpriteItems.splice( index, 1 );
        if ( item )
            item.dispose();
        item = null;

        _reSortSpriteItems();
    }

    public function hasSpriteText( sp : CSpriteText ) : Boolean {
        for each( var item : CPlayerSpriteItem in m_theSpriteItems ) {
            if ( item.theSpriteText == sp )
                return true;
        }

        return false;
    }

    public function setSpriteText( text : String, index : int ) : void {
        var item : CPlayerSpriteItem;
        if ( index < m_theSpriteItems.length ) {
            item = m_theSpriteItems[ index ];
            item.setText( text );
        }
    }

    public function addSpriteItem( item : CPlayerSpriteItem ) : void {
        if ( m_theSpriteItems.length == m_nMaxColumn * m_nMaxRow ) {
            return;
        }

        m_theSpriteItems.push( item );
        _reSortSpriteItems();
        _addChild( item );
    }

    private function _onUpdatePos( e : Event ) : void {
        var iDisplay : IDisplay = m_pOwner.getComponentByClass( IDisplay, true ) as IDisplay;
        var yOffSet : Number;
        if ( iDisplay && iDisplay.defaultBound )
            yOffSet = -iDisplay.defaultBound.height;

        var pProperty : CPlayerProperty = m_pOwner.getComponentByClass( CPlayerProperty, true ) as CPlayerProperty;
        if ( pProperty ) {
            yOffSet -= pProperty.namedOffsetY;
        }

        m_nBaseY = yOffSet;
    }

    private function _addChild( item : CPlayerSpriteItem ) : void {
        m_theContainerObj.addChild( item.theSpriteText );
    }

    internal function _reSortSpriteItemsVertical() : void {
        m_curWidth = width;
        m_curHeight = height;
        m_theSpriteItems.sort( _sortByPriority );

        var item : CPlayerSpriteItem;
        for ( var iRow : int = 0; iRow < m_nMaxRow; iRow++ ) {
            var nextX : Number = 0;// m_nBaseX;
            var nextY : Number = 0;// m_nBaseY;
            for ( var iCol : int = 0; iCol < m_nMaxColumn; iCol++ ) {
                var index : int = iRow * m_nMaxRow + iCol;
                if ( index >= m_theSpriteItems.length )
                    return;

                item = m_theSpriteItems[ index ];
                item.setPosition( nextX, nextY );
                nextX = nextX + item.width + m_nHPadding;
                nextY = iRow * (item.height + m_nVPadding);
            }
        }
    }

    internal function _reSortSpriteItems() : void {
        m_curWidth = width;
        m_curHeight = height;
        m_theSpriteItems.sort( _sortByPriority );

        var item : CPlayerSpriteItem;
        var nextY : Number = 0;// m_nBaseY;
        for ( var iRow : int = 0; iRow < m_nMaxRow; iRow++ ) {
            var nextX : Number = 0;// m_nBaseX;
            var maxColHeight : Number = 0.0;
            for ( var iCol : int = 0; iCol < m_nMaxColumn; iCol++ ) {
                var index : int = iRow * m_nMaxColumn + iCol;
                if ( index >= m_theSpriteItems.length )
                    return;

                item = m_theSpriteItems[ index ];
                item.setPosition( nextX, nextY );
                nextX = nextX + item.width + m_nHPadding;
                maxColHeight = item.height > maxColHeight ? item.height : maxColHeight;
            }
            nextY = nextY - ( maxColHeight + m_nVPadding);
        }
    }

    internal function _sortByPriority( item1 : CPlayerSpriteItem, item2 : CPlayerSpriteItem ) : int {
        if ( item1.priority > item2.priority )
            return -1;
        else if ( item1.priority < item2.priority )
            return 1;
        else
            return 0;
    }

    final public function  get pSpriteSystem() : CSpriteSystem {
        return m_pSpriteSystem;
    }

    final private function get modelDisplay() : CCharacter {
        var pDisplay : IAnimation = m_pOwner.getComponentByClass( IAnimation, true ) as IAnimation;
        if ( pDisplay )
            return pDisplay.modelDisplay;
        return null;
    }

    final public function get width() : Number {
        var ret : int = 0;
        var spriteItem : CPlayerSpriteItem;
        for ( var iRow : int = 0; iRow < curRow; iRow++ ) {
            var temRet : int = 0;
            for ( var iCol : int = 0; iCol < curColumn; iCol++ ) {
                spriteItem = m_theSpriteItems[ iRow * m_nMaxColumn + iCol ];
                if ( spriteItem )
                    temRet = temRet + spriteItem.width + m_nHPadding;
            }
            if ( temRet > ret )
                ret = temRet;
        }
        return ret;
    }

    final public function get height() : Number {
        var ret : int = 0;
        var temRet : int = 0;
        var spriteItem : CPlayerSpriteItem;
        for ( var iRow : int = 0; iRow < curRow; iRow++ ) {
            for ( var iCol : int = 0; iCol < curColumn; iCol++ ) {
                spriteItem = m_theSpriteItems[ iRow * m_nMaxColumn + iCol ];
                if ( spriteItem ) {
                    if ( spriteItem.height > temRet )
                        temRet = spriteItem.height + m_nVPadding;
                }
            }
            ret = ret + temRet;
        }
        return ret;
    }

    private function get curRow() : int {
        return int( (size - 1) / m_nMaxColumn ) + 1;
    }

    private function get curColumn() : int {
        return size >= m_nMaxColumn ? m_nMaxColumn : size;
    }

    public function get size() : int {
        if ( m_theSpriteItems )
            return m_theSpriteItems.length;
        return 0;
    }

    final private function get pAnimation() : IAnimation {
        return m_pOwner.getComponentByClass( IAnimation, true ) as IAnimation;
    }

    final private function get pDisplayer() : IDisplay {
        return m_pOwner.getComponentByClass( IDisplay, true ) as IDisplay;
    }

    private var m_pOwner : CGameObject;
    private var m_theSpriteItems : Vector.<CPlayerSpriteItem>;
    private var m_pSpriteSystem : CSpriteSystem;
    private var m_nHPadding : int;
    private var m_nVPadding : int;
    private var m_nMaxColumn : int;
    private var m_nMaxRow : int;
    private var m_nBaseX : Number = 0.0;
    private var m_nBaseY : Number = 0.0;
    private var m_theContainerObj : CBaseObject;
    private var m_curWidth : Number;
    private var m_curHeight : Number;
}
}
