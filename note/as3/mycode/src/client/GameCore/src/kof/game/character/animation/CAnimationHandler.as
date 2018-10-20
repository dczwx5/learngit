//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.animation {

import flash.geom.Point;

import kof.game.character.CCharacterDataDescriptor;

import kof.game.character.ICharacterProfile;
import kof.game.character.display.IDisplay;
import kof.game.character.fight.emitter.CMissile;
import kof.game.character.scripts.CHornorTitleComponent;
import kof.game.character.scripts.CNamedSprite;
import kof.game.character.scripts.CTXVipSprite;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.core.CGameObject;
import kof.game.core.CGameSystemHandler;
import kof.game.scene.CSceneSystem;

/**
 * @author Jeremy (jeremy@qifun.com)
 */
public class CAnimationHandler extends CGameSystemHandler implements ICharacterProfile {

    /** @private */
    private var m_bNameDisplayed : Boolean;
    private var m_bPlayerDisplayed : Boolean = true;
    private var m_bIsNeedChange : Boolean;
    private var m_bTitleDisplayed : Boolean = true;

    /**
     * Creates a new CAnimationHandler.
     */
    public function CAnimationHandler() {
        super( IAnimation );
    }

    /** @inheritDoc */
    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        this.nameDisplayed = true;

        return ret;
    }

    /** @inheritDoc */
    override protected virtual function onShutdown() : Boolean {
        return super.onShutdown();
    }

    /** @inheritDoc */
    override public function tickValidate( delta : Number, obj : CGameObject ) : Boolean {
        var bValidated : Boolean = super.tickValidate( delta, obj );
        bValidated = obj.isRunning;

        if ( bValidated ) {
            var pDisplay : IDisplay = obj.getComponentByClass( IDisplay, true ) as IDisplay;

            var pStateBoard : CCharacterStateBoard = obj.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;

            // Sync the position with Character display.
            if ( pDisplay && pStateBoard ) {
                var bDirectionPermit : Boolean = pStateBoard.getValue( CCharacterStateBoard.DIRECTION_DISPLAY_PERMIT );
                if ( bDirectionPermit ) {
                    var pDir : Point = pStateBoard.getValue( CCharacterStateBoard.DIRECTION );
                    if ( pDir.x != 0 ) {
                        pDisplay.direction = pDir.x > 0 ? 1 : -1;
                    }
                }
            }

            if ( pDisplay ) {
                pDisplay.boInView = pDisplay.modelDisplay.isInViewRange;
            }

            var pNamedSprite : CNamedSprite = obj.getComponentByClass( CNamedSprite, true ) as CNamedSprite;
            var pTxVipSprite : CTXVipSprite = obj.getComponentByClass( CTXVipSprite, true ) as CTXVipSprite;
            var titleComp: CHornorTitleComponent = obj.getComponentByClass( CHornorTitleComponent , true ) as CHornorTitleComponent;
            if ( pNamedSprite ) {
                pNamedSprite.enabled = this.nameDisplayed;
            }
            if ( pTxVipSprite )
                pTxVipSprite.enabled = this.nameDisplayed;
            if( titleComp ) {
                if ( CCharacterDataDescriptor.isPlayer(obj.data ) && !CCharacterDataDescriptor.isHero(obj.data ) ) {
                    titleComp.enabled = this.playerTitleDisplayed;
                }
            }

            var animation : IAnimation = obj.getComponentByClass( IAnimation, true ) as IAnimation;
            animation.update( delta );

            if ( pDisplay && pDisplay is CCharacterDisplay && isNeedChange ) {
                var characterDisplay : CCharacterDisplay = pDisplay as CCharacterDisplay;
                if ( CCharacterDataDescriptor.isPlayer( characterDisplay.owner.data ) && !CCharacterDataDescriptor.isHero( characterDisplay.owner.data ) ) {
                    pDisplay.modelDisplay.visible = playerDisplayed;
                }
            }
        }

        return bValidated;
    }

    /** @inheritDoc */
    override public function tickUpdate( delta : Number, obj : CGameObject ) : void {
    }

    override public function afterTick( delta : Number ) : void {

    }

    public function get nameDisplayed() : Boolean {
        return m_bNameDisplayed;
    }

    public function set nameDisplayed( value : Boolean ) : void {
        m_bNameDisplayed = value;
    }

    public function get playerDisplayed() : Boolean {
        return m_bPlayerDisplayed;
    }

    public function set playerDisplayed( value : Boolean ) : void {
        m_bPlayerDisplayed = value;
    }

    public function get isNeedChange() : Boolean {
        return m_bIsNeedChange;
    }

    public function set isNeedChange( value : Boolean ) : void {
        m_bIsNeedChange = value;
    }

    public function get playerTitleDisplayed() : Boolean{
        return m_bTitleDisplayed;
    }

    public function set playerTitleDisplayed(value : Boolean) : void{
        m_bTitleDisplayed = value;
    }

}
}
