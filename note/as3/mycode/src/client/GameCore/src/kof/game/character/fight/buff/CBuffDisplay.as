//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/2/18.
//----------------------------------------------------------------------
package kof.game.character.fight.buff {

import QFLib.Foundation.CPath;
import QFLib.Framework.CAnimationController;
import QFLib.Framework.CAnimationState;
import QFLib.Framework.CCharacter;
import QFLib.Framework.CFramework;
import QFLib.Graphics.Character.model.ResUrlInfo;
import QFLib.ResourceLoader.ELoadingPriority;

import kof.game.character.animation.CBaseAnimationDisplay;
import kof.game.character.display.IDisplay;
import kof.game.character.fight.emitter.CMasterCompomnent;
import kof.game.core.CGameObject;

public class CBuffDisplay extends CBaseAnimationDisplay {
    public function CBuffDisplay( theFrameWork : CFramework = null ) {
        super();
        var statusList : Array = getMissileStatus();

        const pAnimationController : CAnimationController = new CAnimationController( statusList[ 0 ] );

        for each( var status : CAnimationState in statusList ) {
            if ( status == statusList[ 0 ] )
                continue;
            if ( !pAnimationController.findState( status.stateName ) )
                pAnimationController.addState( status );
        }


        pAnimationController.addStateRelationship( CBuffStatesConst.IDLE_1 , CBuffStatesConst.EFFECT_1 , idleToEffect);

        var pModel : CCharacter = new CCharacter( theFrameWork, pAnimationController );
        this.setDisplay( pModel );
    }

    override public function dispose() : void {
        super.dispose();
    }

    override protected function onEnter() : void {
        super.onEnter();
        this.playAnimation( CBuffStatesConst.IDLE_1 );
    }

    override protected virtual function onDataUpdated() : void {
        super.onDataUpdated();

        if ( owner.data.hasOwnProperty( "skinName" ) )
            skin = owner.data.skinName;

        if ( modelDisplay ) {
            modelDisplay.setPosition( transform.x, transform.z, transform.y );
            modelDisplay.enablePhysics = false;
            modelDisplay.animationSpeed = 1.0;
        }
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

    private function getMissileStatus() : Array {
        return [
            new CAnimationState( CBuffStatesConst.IDLE_1, "Fly_1", true ),
            new CAnimationState( CBuffStatesConst.EFFECT_1, "Explosion_1", false ),
        ]
    }

    override public function update( delta : Number ) : void {
        super.update( delta );
    }

    override public function getCharacterBaseURI() : String {
        return "assets/character/buff/";
    }

    override protected function updateDisplay( delta : Number ) : void {
        var pModel : CCharacter = this.modelDisplay;

        if ( !pResUrlInfo ) {
            var fileName : String = new CPath( skin ).name;
            if ( skin ) {

                pResUrlInfo = new ResUrlInfo();
                pResUrlInfo.jsonUrl = getCharacterBaseURI() + skin + '/' + fileName;
                setReady( false );

                pModel.loadCharacterFile( getCharacterBaseURI() + "buff.json" );
                pModel.loadCharacterGameFile( pResUrlInfo.jsonUrl, ELoadingPriority.NORMAL, _onResLoadFinished );
            }
        }
    }

    private function idleToEffect() : Boolean {
        if ( isStateActive( CBuffStatesConst.EFFECT_V_2 ) ) {
            popState( CBuffStatesConst.IDLE_V_1 );
            return true;
        }
        return false;
    }

    override protected function onResReady() : void
    {
        super.onResReady();
        _loadHitEffectFile();

    }

    protected function _loadHitEffectFile() : void
    {
        var masterCmp : CMasterCompomnent = owner.getComponentByClass( CMasterCompomnent , true ) as CMasterCompomnent;
        var pCharacter : CGameObject;
        var pDisplay : IDisplay;
        var hitEffectUrl: String;
        if( masterCmp ) {
            pCharacter = masterCmp.master;
            pDisplay = pCharacter.getComponentByClass( IDisplay , true ) as IDisplay;
            hitEffectUrl =pDisplay.getCharacterBaseURI() + pDisplay.skin + "/" + pDisplay.skin;
        }

        var mAnimation : IDisplay = owner.getComponentByClass( IDisplay , true ) as IDisplay;
        mAnimation.modelDisplay.loadHitEffectFile( hitEffectUrl + "_he" + ".json" );
    }

    private var m_explosionTickTime : Number = 0.0;
    private var m_explosionEnd :Boolean;
}
}
