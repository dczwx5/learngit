//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/2/28.
 */
package kof.game.character.scripts.appear {

import QFLib.Foundation;
import QFLib.Framework.CObject;
import QFLib.Interface.IDisposable;
import QFLib.Math.CVector2;
import QFLib.Math.CVector3;

import flash.geom.Point;

import kof.game.character.CKOFTransform;
import kof.game.character.ai.CAIComponent;
import kof.game.character.display.IDisplay;
import kof.game.character.movement.CMovement;
import kof.game.character.movement.CNavigation;
import kof.game.character.movement.CNavigationEvent;
import kof.game.character.movement.INavigationListener;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.core.CGameObject;
import kof.util.CAssertUtils;

/**
 * Abstract appear action.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CAppearAction implements IDisposable {

    private var m_pOwner : CGameObject;
    private var m_pfnCallback : Function;

    /**
     * Creates a new CAppearAction.
     */
    public function CAppearAction( pOwner : CGameObject ) {
        this.m_pOwner = pOwner;

        CAssertUtils.assertNotNull( m_pOwner, "Invalid 'owner' assign to CAppearAction." );
    }

    /** @inheritDoc */
    public function dispose() : void {
        m_pOwner = null;
        m_pfnCallback = null;
    }

    final public function get owner() : CGameObject {
        return m_pOwner;
    }

    public function execute( pfnCallback : Function = null ) : void {
        this.m_pfnCallback = pfnCallback;

        // Stop AI behavior.
        var pAIComp : CAIComponent = owner.getComponentByClass( CAIComponent, true ) as CAIComponent;
        if ( pAIComp ) {
            pAIComp.enabled = false;
        }

        // Make the owner non-attackable and non-catchable.
        var pStateBoard : CCharacterStateBoard = owner.getComponentByClass(
                        CCharacterStateBoard, true ) as CCharacterStateBoard;
        if ( pStateBoard ) {
            pStateBoard.setValue( CCharacterStateBoard.CAN_BE_ATTACK, false );
            pStateBoard.setValue( CCharacterStateBoard.CAN_BE_CATCH, false );
        }

        // Make the owner movement collision disabled.
        var pMovement : CMovement = owner.getComponentByClass( CMovement, true )
                as CMovement;
        if ( pMovement ) {
            pMovement.collisionEnabled = false;
        }
    }

    protected function setResult( boolOrError : * ) : void {
        if ( boolOrError is Error ) {
            setFailure( boolOrError as Error );
        } else {
            setDone( Boolean( boolOrError ) );
        }
    }

    private function setDone( value : Boolean ) : void {
        // FIXME: case by the value.
        if ( null != m_pfnCallback )
            m_pfnCallback(value);

        if(value){
            return;
        }

        var pAIComp : CAIComponent = owner.getComponentByClass( CAIComponent, true ) as CAIComponent;
        if ( pAIComp ) {
            pAIComp.enabled = true;
        }

        var pStateBoard : CCharacterStateBoard = owner.getComponentByClass(
                        CCharacterStateBoard, true ) as CCharacterStateBoard;
        if ( pStateBoard ) {
            pStateBoard.resetValue( CCharacterStateBoard.CAN_BE_ATTACK );
            pStateBoard.resetValue( CCharacterStateBoard.CAN_BE_CATCH );
        }

        // Make the owner movement collision enabled.
        var pMovement : CMovement = owner.getComponentByClass( CMovement, true )
                as CMovement;
        if ( pMovement ) {
            pMovement.collisionEnabled = true;
        }
    }

    private function setFailure( error : Error ) : void {
        Foundation.Log.logErrorMsg( "AppearAction error caught: " + error.message );
        CONFIG::debug {
            throw error;
        }
    }

    public function  update( delta : Number ) : void {

    }

}

}
