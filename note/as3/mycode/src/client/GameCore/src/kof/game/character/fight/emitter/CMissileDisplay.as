//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/8/12.
//----------------------------------------------------------------------
package kof.game.character.fight.emitter {

import QFLib.Foundation.CPath;
import QFLib.Framework.CAnimationController;
import QFLib.Framework.CAnimationState;
import QFLib.Framework.CCharacter;
import QFLib.Framework.CFramework;
import QFLib.Graphics.Character.model.ResUrlInfo;
import QFLib.ResourceLoader.ELoadingPriority;

import kof.game.character.CCharacterDataDescriptor;

import kof.game.character.CCharacterEvent;

import kof.game.character.CEventMediator;

import kof.game.character.animation.CBaseAnimationDisplay;
import kof.game.character.display.IDisplay;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.property.CMissileProperty;
import kof.game.core.CGameObject;
import kof.table.Aero;

/**
 * missile display class that has a spine animation
 */
public class CMissileDisplay extends CBaseAnimationDisplay {

    public function CMissileDisplay( theFrameWork : CFramework = null ) {
        super();
        var statusList : Array = getMissileStatus();

        const pAnimationController : CAnimationController = new CAnimationController( statusList[ 0 ] );

        for each( var status : CAnimationState in statusList ) {
            if ( status == statusList[ 0 ] )
                continue;
            if ( !pAnimationController.findState( status.stateName ) )
                pAnimationController.addState( status );
        }

//        pAnimationController.addStateRelationship( CMissileStatesConst.FLY_1, CMissileStatesConst.EFFECT_1, flyingToEffect );
//        pAnimationController.addStateRelationship( CMissileStatesConst.EFFECT_1, CMissileStatesConst.FLY_1, effectToFly );
//        pAnimationController.addStateRelationship( CMissileStatesConst.EFFECT_1, CMissileStatesConst.EXPLOSION_1, effectToExplosion );
//        pAnimationController.addStateRelationship( CMissileStatesConst.FLY_1, CMissileStatesConst.EXPLOSION_1, effectToExplosion );

        var pModel : CCharacter = new CCharacter( theFrameWork, pAnimationController );
        this.setDisplay( pModel );
    }

    private function _buildDefaultRelationShip() : void {
        animationController.addStateRelationship( CMissileStatesConst.FLY_1, CMissileStatesConst.EFFECT_1, flyingToEffect );
        animationController.addStateRelationship( CMissileStatesConst.EFFECT_1, CMissileStatesConst.FLY_1, effectToFly );
        animationController.addStateRelationship( CMissileStatesConst.EFFECT_1, CMissileStatesConst.EXPLOSION_1, effectToExplosion );
        animationController.addStateRelationship( CMissileStatesConst.FLY_1, CMissileStatesConst.EXPLOSION_1, effectToExplosion );

    }

    override public function dispose() : void {
        super.dispose();
    }

    override protected function onEnter() : void {
        super.onEnter();
    }

    override protected virtual function onDataUpdated() : void {
        super.onDataUpdated();

        if ( owner.data.hasOwnProperty( "skin" ) )
            skin = owner.data.skin;

        if ( modelDisplay ) {
            modelDisplay.setPosition( transform.x, transform.z, transform.y );
            modelDisplay.animationSpeed = 1.0;
        }

        _buildStateRelationship();
    }

    override protected virtual function onExit() : void {
        super.onExit();
    }

    override public function get physicsEnabled() : Boolean {
        return false;
    }

    override public function set physicsEnabled( physicsEnabled : Boolean ) : void {
        // NOOP.
    }

    private function _buildStateRelationship() : void {
        var pMissileProperty : CMissileProperty = owner.getComponentByClass( CMissileProperty, true ) as CMissileProperty;
        var missileID : int = pMissileProperty.missileId;
        var missileData : Aero = CSkillCaster.skillDB.getAeroByID( missileID, "" );
        if ( missileData == null ) {
            _buildDefaultRelationShip();
            return;
        }
        var sFlyAnimation : String = missileData.SFXName.toUpperCase();
        var sEffectAnimation : String = missileData.EffectSFXName.toUpperCase();
        var sExplosionAnimation : String = missileData.DeadSFXName.toUpperCase();

        animationController.addStateRelationship( sFlyAnimation, sEffectAnimation, flyingToEffect );
        animationController.addStateRelationship( sEffectAnimation, sFlyAnimation, effectToFly );
        animationController.addStateRelationship( sEffectAnimation, sExplosionAnimation, effectToExplosion );
        animationController.addStateRelationship( sFlyAnimation, sExplosionAnimation, effectToExplosion );

    }

    private function getMissileStatus() : Array {
        return [
            new CAnimationState( CMissileStatesConst.FLY_1, "Fly_1", true ),
            new CAnimationState( CMissileStatesConst.FLY_2, "Fly_2", true ),
            new CAnimationState( CMissileStatesConst.FLY_3, "Fly_3", true ),
            new CAnimationState( CMissileStatesConst.FLY_4, "Fly_4", true ),
            new CAnimationState( CMissileStatesConst.FLY_5, "Fly_5", true ),

            new CAnimationState( CMissileStatesConst.EXPLOSION_1, "Explosion_1", false ),
            new CAnimationState( CMissileStatesConst.EXPLOSION_2, "Explosion_2", false ),
            new CAnimationState( CMissileStatesConst.EXPLOSION_3, "Explosion_3", false ),
            new CAnimationState( CMissileStatesConst.EXPLOSION_4, "Explosion_4", false ),
            new CAnimationState( CMissileStatesConst.EXPLOSION_5, "Explosion_5", false ),

            new CAnimationState( CMissileStatesConst.EFFECT_1, "Explosion_1", false ),
            new CAnimationState( CMissileStatesConst.EFFECT_2, "Explosion_2", false ),
            new CAnimationState( CMissileStatesConst.EFFECT_3, "Explosion_3", false ),
            new CAnimationState( CMissileStatesConst.EFFECT_4, "Explosion_4", false ),
            new CAnimationState( CMissileStatesConst.EFFECT_5, "Explosion_5", false ),
        ]
    }

    override public function update( delta : Number ) : void {
        super.update( delta );
//        updateSimulateAnimationTime( delta );
        updateEffectTime( delta );


        /**
         if(isStateActive( CMissileStateValue.EXLORSION_1 ) && !m_explosionEnd)
         {
             m_explosionTickTime += delta;

             if( isNaN(currentCollisionLoopDuration) || m_explosionTickTime >= currentCollisionLoopDuration )
             {
                 var fT : CCharacterFightTriggle = owner.getComponentByClass( CCharacterFightTriggle , true ) as CCharacterFightTriggle;
                 fT.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.MISSILE_EXPLOSION_END , null , null ));
                 m_explosionEnd = true;
             }
         }*/
    }

    public function updateSimulateAnimationTime( delta : Number ) : void {

        var boEnd : Boolean;

        if ( isNaN( currentCollisionLoopDuration ) )
            boEnd = true;
        else {
            if ( (m_currentAnimationState & stateValue) == 0 ) {
                resetCurrentAnimationTime();
                m_currentAnimationState = stateValue;
            } else {
                if ( isNaN( m_currentAnimationLeftTime ) )
                    m_currentAnimationLeftTime = currentCollisionLoopDuration;

                m_currentAnimationLeftTime -= delta;
                if ( m_currentAnimationLeftTime <= 0.0 ) {
                    resetCurrentAnimationTime();
                    boEnd = true;
                }
            }
        }

        if ( boEnd ) {
            _dispatchFightEvent( CFightTriggleEvent.MISSILE_ANIMATION_END, null, null );
        }
    }

    public function updateEffectTime( delta : Number ) : void {
        if ( !isReady )
            return;

        if ( (m_currentAnimationState & stateValue) == 0 ) {
            m_currentAnimationLeftTime = 0.0;
            m_currentAnimationState = stateValue;
            m_boStateValueChange = true;
        }
        m_currentAnimationLeftTime += delta;
        var endAnimation : String = animationController.currentState.animationName;
        var animationDurationTime : Number = getCollisionDurantionTimeByName( endAnimation );//animationController.currentState.animationName );
        if ( isNaN( animationDurationTime ) || m_currentAnimationLeftTime >= animationDurationTime ) {
            m_boStateValueChange = false;
            _dispatchFightEvent( CFightTriggleEvent.MISSILE_ANIMATION_END, null,  [ endAnimation ]);
        }
    }

    private function _dispatchFightEvent( eventName : String, param : CGameObject = null, paramList : Array = null ) : void {
        var fT : CCharacterFightTriggle = owner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
        fT.dispatchEvent( new CFightTriggleEvent( eventName, param, paramList ) );
    }

    override protected function updateDisplay( delta : Number ) : void {
        var pModel : CCharacter = this.modelDisplay;

        if ( !pResUrlInfo ) {
            if ( skin ) {
                var fileName : String = new CPath( skin ).name;
                pResUrlInfo = new ResUrlInfo();
                pResUrlInfo.jsonUrl = getCharacterBaseURI() + skin + '/' + fileName;
                setReady( false );

                pModel.loadCharacterFile( getCharacterBaseURI() + "missile.json" );
                pModel.loadCharacterGameFile( pResUrlInfo.jsonUrl, ELoadingPriority.NORMAL, _onResLoadFinished );

            }
        }
    }

    override public function getCharacterBaseURI() : String {
        return "assets/character/missile/";
    }

    public function getCollisionDurantionTimeByName( animation : String ) : Number {
        return modelDisplay.getCollisionDurationTimeByName( animation );
    }

    private function flyingToEffect() : Boolean {
        if ( isStateActive( CMissileStateValue.EFFECT_1 ) && m_boStateValueChange ) {
            popState( CMissileStateValue.FLYING_1 );
            m_boStateValueChange = false;
            return true;
        }
        return false;
    }

    private function effectToFly() : Boolean {
        if ( isStateActive( CMissileStateValue.FLYING_1 ) && m_boStateValueChange ) {
            popState( CMissileStateValue.EFFECT_1 );
            m_boStateValueChange = false;
            return true;
        }
        return false;
    }

    private function effectToExplosion() : Boolean {
        if ( isStateActive( CMissileStateValue.EXLORSION_1) && m_boStateValueChange ) {
            m_boStateValueChange = false;
            return true;
        }
        return false;
    }

    public function set boStateValueChange( value : Boolean ) : void {
        this.m_boStateValueChange = value;
    }

    override protected function onResReady() : void {
        super.onResReady();
        _loadHitEffectFile1();

        var pEventMediator : CEventMediator = this.getComponent( CEventMediator ) as CEventMediator;
        if ( pEventMediator ) {
            pEventMediator.dispatchEvent( new CCharacterEvent( CCharacterEvent.DISPLAY_READY, owner ) );
        }
    }

    protected function _loadHitEffectFile() : void {
        var masterCmp : CMasterCompomnent = owner.getComponentByClass( CMasterCompomnent, true ) as CMasterCompomnent;
        var pCharacter : CGameObject;
        var pDisplay : IDisplay;
        var hitEffectUrl : String;
        if ( masterCmp ) {
            pCharacter = masterCmp.master;
            var sSkinName : String = CCharacterDataDescriptor.getSkinName( pCharacter.data );
            var sfileName : String = new CPath( sSkinName ).name;
            hitEffectUrl = getMasterCharacterBaseURI() + sSkinName + "/" + sfileName;
        }

        var mAnimation : IDisplay = owner.getComponentByClass( IDisplay, true ) as IDisplay;
        mAnimation.modelDisplay.loadHitEffectFile( hitEffectUrl + "_he" + ".json" );
    }

    protected function _loadHitEffectFile1() : void {
        var masterCmp : CMasterCompomnent = owner.getComponentByClass( CMasterCompomnent, true ) as CMasterCompomnent;
        var hitEffectUrl : String;
        if ( masterCmp ) {
            var sSkinName : String = masterCmp.ownerSkin;
            var sfileName : String = new CPath( sSkinName ).name;
            hitEffectUrl = getMasterCharacterBaseURI() + sSkinName + "/" + sfileName;
        }

        var mAnimation : IDisplay = owner.getComponentByClass( IDisplay, true ) as IDisplay;
        mAnimation.modelDisplay.loadHitEffectFile( hitEffectUrl + "_he" + ".json" );
    }

    public function getMasterCharacterBaseURI() : String {
        return "assets/character/";
    }

    public function resetCurrentAnimationTime() : void {
        m_currentAnimationLeftTime = 0.0;
    }


    private var m_explosionTickTime : Number = 0.0;
    private var m_explosionEnd : Boolean;

    private var m_currentAnimationLeftTime : Number = 0.0;
    private var m_currentAnimationState : int = 0;
    private var m_boStateValueChange : Boolean;

}
}
