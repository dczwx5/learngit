//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.scripts {

import QFLib.Foundation.free;
import QFLib.Graphics.Sprite.CSpriteText;
import QFLib.Math.CAABBox2;

import flash.filters.GlowFilter;

import kof.framework.events.CEventPriority;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.character.animation.IAnimation;
import kof.game.character.display.IDisplay;
import kof.game.character.property.interfaces.ICharacterProperty;
import kof.game.character.scene.CSceneMediator;
import kof.game.core.CSubscribeBehaviour;

/**
 * 角色头顶显示名字
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CNamedSprite extends CSubscribeBehaviour {

    static private var s_fDefaultHeight : Number = 240.0;

    private var m_pNamedSp : CSpriteText;
    private var m_pAppellationSp : CSpriteText;
    private var m_fHeight : Number;

    public function CNamedSprite( name : String = "characterName", branchData : Boolean = false ) {
        super( name, branchData );
    }

    override public function dispose() : void {
        super.dispose();

        if ( !_boHasSpriteContainer ) {
            free( m_pNamedSp );
            m_pNamedSp = null;
            free( m_pAppellationSp );
            m_pAppellationSp = null;
        }
    }

    override protected virtual function onEnter() : void {
        super.onEnter();

        var pEventMediator : CEventMediator = this.getComponent( CEventMediator ) as CEventMediator;
        if ( pEventMediator ) {
            pEventMediator.addEventListener( CCharacterEvent.DISPLAY_READY, _onCharacterDisplayReady, false, CEventPriority.DEFAULT, true );
        }

        var pPlayerSpriteContainer : CTXVipSprite = owner.getComponentByClass( CTXVipSprite, true ) as CTXVipSprite;
        _boHasSpriteContainer = pPlayerSpriteContainer != null;

        this.m_fHeight = s_fDefaultHeight;
    }

    override protected virtual function onDataUpdated() : void {
        super.onDataUpdated();

        if ( this.enabled && !this.m_pNamedSp )
            createTextSprite();

        if ( this.m_pNamedSp ) {
            var pProperty : ICharacterProperty = getComponent( ICharacterProperty ) as ICharacterProperty;
            if ( pProperty ) {
                this.m_pNamedSp.text = pProperty.nickName;
                if ( pProperty.appellation && pProperty.appellation != "" ) {
                    this.m_pAppellationSp.text = pProperty.appellation;
                }
            }
        }
    }

    override protected virtual function onExit() : void {
        super.onExit();
        if ( !_boHasSpriteContainer ) {
            free( m_pNamedSp );
            m_pNamedSp = null;
        }

        var pEventMediator : CEventMediator = this.getComponent( CEventMediator ) as CEventMediator;
        if ( pEventMediator ) {
            pEventMediator.removeEventListener( CCharacterEvent.DISPLAY_READY, _onCharacterDisplayReady );
        }
    }

    public function get baseHeight() : Number {
        return m_fHeight;
    }

    public function set baseHeight( value : Number ) : void {
        if ( m_fHeight == value )
            return;
        m_fHeight = value;
    }

    override public function set enabled( value : Boolean ) : void {
        if ( this.enabled == value )
            return;

        super.enabled = value;

        if ( this.enabled ) {
            // 打开
            this.createTextSprite();
        } else {
            // 关闭
            if ( !_boHasSpriteContainer )
                this.destroyTextSprite();
        }
    }

    protected function get characterName() : String {
        var pProperty : ICharacterProperty = this.getComponent( ICharacterProperty ) as ICharacterProperty;
        if ( pProperty ) {
            return pProperty.nickName;
        }
        return null;
    }

    protected function get appellation() : String {
        var pProperty : ICharacterProperty = this.getComponent( ICharacterProperty ) as ICharacterProperty;
        if ( pProperty ) {
            return pProperty.appellation;
        }
        return null;
    }


    protected function createTextSprite() : void {
        if ( !this.characterName )
            return;

        var fHeight : Number = this.baseHeight;
        var bCenterAnchor : Boolean;
        if ( !_boHasSpriteContainer )
            bCenterAnchor = true;

        if ( !m_pNamedSp ) {
            var pSceneMediator : CSceneMediator = this.getComponent( CSceneMediator ) as CSceneMediator;
            if ( pSceneMediator && pSceneMediator.graphicFramework ) {
                m_pNamedSp = new CSpriteText( pSceneMediator.graphicFramework.spriteSystem, 220.0, 32.0, bCenterAnchor );
            }
        }
        if ( !m_pAppellationSp ) {
            pSceneMediator = this.getComponent( CSceneMediator ) as CSceneMediator;
            if ( pSceneMediator && pSceneMediator.graphicFramework ) {
                m_pAppellationSp = new CSpriteText( pSceneMediator.graphicFramework.spriteSystem, 220.0, 32.0, bCenterAnchor );
            }
        }

        {
            const pNameSp : CSpriteText = m_pNamedSp;
            pNameSp.fontName = "宋体";

            if ( CCharacterDataDescriptor.isHero( owner.data ) ) {
                pNameSp.filters = [ new GlowFilter( 0x0, 1, 2, 2, 1000, 1, false, false ) ];
                pNameSp.fontSize = 14;
                pNameSp.fontColor = 0x7DEF29;
                pNameSp.fontBold = true;
            } else if ( CCharacterDataDescriptor.isNPC( owner.data ) ) {
                pNameSp.filters = [ new GlowFilter( 0x0, 1, 2, 2, 1000, 1, false, false ) ];
                pNameSp.fontSize = 14;
                pNameSp.fontColor = 0xf3d949;
                pNameSp.fontBold = true;
            } else {
                pNameSp.fontSize = 14;
                pNameSp.fontColor = 0xEFEFEF;
                pNameSp.filters = [ new GlowFilter( 0x0, 1, 2, 2, 1000, 1, false, false ) ];
            }


            if ( !_boHasSpriteContainer ) {
                pSceneMediator.graphicFramework.spriteSystem.addToSpriteLayer( m_pNamedSp );
                pSceneMediator.graphicFramework.spriteSystem.addToSpriteLayer( m_pAppellationSp );
                pNameSp.fontHorizontalAlign = "center";
                _initialSpPosition( pNameSp );
            } else {
                pNameSp.fontHorizontalAlign = "left";
                pNameSp.autoSize = "horizontal";
            }

            pNameSp.fontAutoScale = false;
            pNameSp.setBackroundColor( 0xff0000, 0x000000, 0x0 );
            pNameSp.text = this.characterName;
        }
    }

    private function _initialSpPosition( pNameSp : CSpriteText ) : void {
        var fHeight : Number = this.baseHeight;
        if ( this.appellation && this.appellation != "" ) {
            pNameSp.setPosition( 0, -fHeight - 30 );
        } else {
            pNameSp.setPosition( 0, -fHeight - 15 );
        }

        m_pAppellationSp.filters = [ new GlowFilter( 0x0, 1, 2, 2, 1000, 1, false, false ) ];
        m_pAppellationSp.fontSize = 14;
        m_pAppellationSp.fontColor = 0xeae5c8;
        m_pAppellationSp.fontBold = false;

        m_pAppellationSp.fontHorizontalAlign = "center";
        m_pAppellationSp.fontAutoScale = false;
        m_pAppellationSp.setBackroundColor( 0xff0000, 0x000000, 0x0 );
        m_pAppellationSp.setPosition( 0.0, -fHeight );

        if ( this.appellation && this.appellation != "" )
            m_pAppellationSp.text = this.appellation;

        var pDisplay : IDisplay = this.getComponent( IDisplay ) as IDisplay;
        if ( pDisplay ) {
            pDisplay.modelDisplay.theObject.addChild( pNameSp );
            pDisplay.modelDisplay.theObject.addChild( m_pAppellationSp );
        }
    }

    protected function destroyTextSprite() : void {
        if ( !_boHasSpriteContainer ) {
            free( m_pNamedSp );
            m_pNamedSp = null;
            free( m_pAppellationSp );
            m_pAppellationSp = null;
        }
    }

    override public virtual function update( delta : Number ) : void {
        super.update( delta );
        if ( !_boHasSpriteContainer )
            _updateNameSpDir();
    }

    private function _updateNameSpDir() : void {
        if ( m_pNamedSp ) {
            var pAnimation : IAnimation = getComponent( IAnimation ) as IAnimation;
            m_pNamedSp.flipX = pAnimation.direction == -1;
        }
        if ( m_pAppellationSp ) {
            pAnimation = getComponent( IAnimation ) as IAnimation;
            m_pAppellationSp.flipX = pAnimation.direction == -1;
        }
    }

    private function _onCharacterDisplayReady( event : CCharacterEvent ) : void {
        var pDisplay : IDisplay = this.getComponent( IDisplay ) as IDisplay;
        var fHeight : Number = this.baseHeight;
        var bDirty : Boolean = false;
        if ( pDisplay ) {
            var pBound : CAABBox2 = pDisplay.defaultBound;
            if ( pBound ) {
                fHeight = pBound.height;
                bDirty = true;
            }
        }

        if ( bDirty ) {
            this.baseHeight = fHeight;
            this.destroyTextSprite();
            if ( this.enabled ) {
                _createAndAttachNameSp();
            }
        }
    }

    private function _createAndAttachNameSp() : void {
        if ( !m_pNamedSp )
            createTextSprite();

        if ( !_boHasSpriteContainer ) {
            if ( m_pNamedSp ) {
                var pDisplay : IDisplay = this.getComponent( IDisplay ) as IDisplay;
                if ( pDisplay && null == m_pNamedSp.parent ) {
                    pDisplay.modelDisplay.theObject.addChild( m_pNamedSp );
                    pDisplay.modelDisplay.theObject.addChild( m_pAppellationSp );
                }
//                var h : Number = (this.appellation && this.appellation != "") ? 20 : 0;
//                this.m_pNamedSp.setPosition( -100, -this.baseHeight - 20 );
//                this.m_pAppellationSp.setPosition( -100, -this.baseHeight );
            }
        }
        else {
            _addToSpriteContainer( m_pNamedSp );
        }
    }

    private function _addToSpriteContainer( st : CSpriteText ) : void {
        if ( !m_pNamedSp )
            return;

        var pPlayerSpriteContainer : CTXVipSprite = owner.getComponentByClass( CTXVipSprite, true ) as CTXVipSprite;
        if ( pPlayerSpriteContainer ) {
            pPlayerSpriteContainer.addSpriteText( st, 220, 32, -10, m_pNamedSp._getTextObject().width / 2 );
        }
    }

    private var _boHasSpriteContainer : Boolean;
}
}
