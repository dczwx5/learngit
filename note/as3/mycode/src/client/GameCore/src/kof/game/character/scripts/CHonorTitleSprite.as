//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2018/6/1.
//----------------------------------------------------------------------
package kof.game.character.scripts {

import QFLib.Foundation.CLog;

import flash.events.Event;

import kof.framework.events.CEventPriority;
import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.character.display.IDisplay;
import kof.game.character.fight.CFightTextConst;
import kof.game.character.handler.CPlayHandler;
import kof.game.character.scripts.playersprite.CPlayerSpriteContainer;
import kof.game.character.scripts.playersprite.CPlayerSpriteItem;
import kof.game.character.scripts.playersprite.CVipTextConst;
import kof.game.core.CSubscribeBehaviour;

//纯图片版
public class CHonorTitleSprite extends CSubscribeBehaviour {
    public function CHonorTitleSprite( playHandle : CPlayHandler ) {
        super( "Honor_title" );
        m_pPlayHandler = playHandle;
    }

    override public function dispose() : void {
        super.dispose();
        m_theSpriteContainer = null;
    }

    override public function update( delta : Number ) : void {
        if ( m_theSpriteContainer )
            m_theSpriteContainer.update( delta );
    }

    override protected function onDataUpdated() : void {
        super.onDataUpdated();
        m_TitleIDs = [ 1 ];
        _updateTitles();
    }

    override protected function onEnter() : void {
        var pEventMediator : CEventMediator = owner.getComponentByClass( CEventMediator, true ) as CEventMediator;
        pEventMediator.addEventListener( CCharacterEvent.DISPLAY_READY, _onCharacterDisplayReady, false, CEventPriority.DEFAULT, true );
    }

    override protected function onExit() : void {
        if ( m_theSpriteContainer )
            m_theSpriteContainer.dispose();
    }

    private function _onCharacterDisplayReady( e : CCharacterEvent ) : void {
        var iDisplay : IDisplay = getComponent( IDisplay ) as IDisplay;
        if ( iDisplay.defaultBound )
            m_yOffset = -iDisplay.defaultBound.height;

        m_theSpriteContainer = new CPlayerSpriteContainer( owner, 10, 1, 0, m_yOffset - 40, 2, 3 );
        _updateTitles();
    }

    private function _updateTitles() : void {
        if ( m_theSpriteContainer != null &&
                m_TitleIDs != null && m_TitleIDs.length > 0 ) {
            for ( var titleIndex : int = 0; titleIndex < m_TitleIDs.length; titleIndex++ ) {
                var honorText : String = _getCharByTitlelId( m_TitleIDs[ titleIndex ] );
                var spriteItem : CPlayerSpriteItem;
                var containerSize : int = m_theSpriteContainer.size;
                if ( titleIndex < containerSize ) {
                    m_theSpriteContainer.setSpriteText( honorText, titleIndex );
                }
                else {
                    spriteItem = _createPlayerVipItem( honorText,150, 50, titleIndex, 0, 0 );
                    m_theSpriteContainer.addSpriteItem( spriteItem );
                }
            }
        }
    }

    private function _getCharByTitlelId( titelID : int ) : String {
        var titles : Array = [ "", CFightTextConst.SIGN_BOSS, CFightTextConst.TEXT_PO_FANG, CFightTextConst.P3_SELF, CFightTextConst.TEXT_PO_FANG ];
        return titles[ titelID ];
    }

    private function _createPlayerVipItem( text : String, width : int, height : int, priority : int, extrax : Number = 0.0, extray : Number = 0.0 ) : CPlayerSpriteItem {
        var spriteItem : CPlayerSpriteItem = new CPlayerSpriteItem( m_theSpriteContainer );
        spriteItem.createSpriteText( text, m_sFontName, 45, width, height, priority, extrax, extray );
        return spriteItem;
    }

    private var m_pPlayHandler : CPlayHandler;
    private var m_theSpriteContainer : CPlayerSpriteContainer;
    private var m_TitleIDs : Array;
    private var m_yOffset : Number;
    private var m_sFontName : String = "FightText";
}
}
