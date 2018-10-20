//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2018/4/27.
//----------------------------------------------------------------------
package kof.game.character.fight.skilleffect {

import QFLib.Collision.CCharacterCollisionBound;
import QFLib.Framework.CCharacter;
import QFLib.Math.CAABBox3;
import kof.game.character.collision.CCollisionComponent;
import kof.game.character.display.IDisplay;
import kof.game.character.fight.catches.CKeepAwayTrunk;
import kof.game.character.fight.skill.CSkillDebugLog;

public class CSkillAwayTrunkEffect extends CAbstractSkillEffect {

    public function CSkillAwayTrunkEffect( id : int, startFrame : Number, hitEvent : String, etype : int, des : String = "" ) {
        super( id, startFrame, hitEvent, etype, des );
    }

    override public function dispose() : void{
        m_collisionBox = null;
    }

    override public function update( delta : Number ) : void {
        if ( keepAwayTrunk ) {
            var targetBox : CAABBox3 = this.findCollisionBox();
            if( targetBox != null )
                keepAwayTrunk.keepAwayBox = targetBox;
        }
    }

    private function findCollisionBox() : CAABBox3{
        var collisionComp : CCollisionComponent = owner.getComponentByClass( CCollisionComponent, true ) as CCollisionComponent;
        if ( collisionComp ) {
            var collisionBox : CCharacterCollisionBound = collisionComp.getCollisionBoundByHitEvent( hitEventSignal );
            if ( collisionBox ) {
                CSkillDebugLog.logMsg( "抓取后退标识 " + hitEventSignal );
                if ( m_collisionBox == null ) {
                    m_collisionBox = collisionBox.characterCollision.AABBBox.clone();
                }
                var vCollisionBox : CAABBox3 = collisionBox.characterCollision.testAABBBox;
                return vCollisionBox;
            }
        }
        return null;
    }

    private function calCollisionBox() : CAABBox3{
        if( m_collisionBox == null )
                return null ;

        var modelDisplay : CCharacter = pModelDisplay;
        var retBox : CAABBox3 = m_collisionBox.clone();
        if( retBox ) {
            if( modelDisplay ) {
                var flipX : Number = modelDisplay.flipX ? -1 : 1;
                var flipY : Number = modelDisplay.flipZ ? -1 : 1;
                var flipZ : Number = modelDisplay.flipY ? 1 : -1;
                retBox.center.mulOnValueXYZ( 1.0 , 1.0 , modelDisplay.scale.y );
                retBox.center.mulOnValueXYZ(flipX , flipY , flipZ );
                retBox.center.addOnValueXYZ( modelDisplay.position.x , modelDisplay.position.z , modelDisplay.position.y );
                retBox.ext.mul( modelDisplay.scale );
            }
        }

        return retBox;
    }

    [inline]
    final private function get keepAwayTrunk() : CKeepAwayTrunk {
        return owner.getComponentByClass( CKeepAwayTrunk, true ) as CKeepAwayTrunk;
    }

    final private function get pModelDisplay() : CCharacter{
        return (owner.getComponentByClass( IDisplay , true ) as IDisplay).modelDisplay;
    }

    private var m_collisionBox : CAABBox3;
}
}

