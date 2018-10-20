//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.fight.catches {

import QFLib.Foundation;
import QFLib.Foundation.CMap;
import QFLib.Foundation.free;
import QFLib.Interface.IUpdatable;
import QFLib.Math.CAABBox2;
import QFLib.Math.CVector3;

import kof.game.character.CCharacterDataDescriptor;

import kof.game.character.CCharacterTransform;
import kof.game.character.CFacadeMediator;
import kof.game.character.CKOFTransform;
import kof.game.character.animation.IAnimation;
import kof.game.character.display.IDisplay;
import kof.game.character.fight.CCharacterNetworkInput;
import kof.game.character.level.CLevelMediator;
import kof.game.character.state.CCharacterActionStateConstants;
import kof.game.character.state.CCharacterBeCatchState;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.character.state.CCharacterStateMachine;
import kof.game.core.CGameComponent;
import kof.game.core.CGameObject;

/**
 * 技能抓取组件
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CSkillCatcher extends CGameComponent implements IUpdatable {// CSubscribeBehaviour

    private var m_theCatches : CMap;
    // TODO: cache the owner's bone matrix every time.
    [Ignore]
    private var m_pBonePosCaches : CMap;

    /**
     * Creates a new CSkillCatcher.
     */
    public function CSkillCatcher() {
        super( "skillCatcher" );
    }

    override public function dispose() : void {
        super.dispose();

        if ( m_theCatches ) {
            var vInfos : Array = m_theCatches.toArray();
            disposeInfos( vInfos );

            m_theCatches.clear();
        }
        m_theCatches = null;
    }

    protected function disposeInfos( vInfos : Array ) : void {
        if ( !vInfos )
            return;

        for each ( var temp : ICatcherInfo in vInfos ) {
            if ( !temp )
                continue;

            free( temp );
        }

        vInfos.splice( 0, vInfos.length );
    }

    override protected function onEnter() : void {
        super.onEnter();

        m_theCatches = new CMap( true );
        m_pBonePosCaches = new CMap();
    }

    override protected function onExit() : void {
        super.onExit();

        removeAll();
        if ( m_theCatches )
            m_theCatches.clear();

        if ( m_pBonePosCaches )
            m_pBonePosCaches.clear();
    }

    public function update( delta : Number ) : void {
//        super.update( delta );

        if ( !m_theCatches || !m_theCatches.length )
            return;

        var vTrans : CCharacterTransform = null;
        var v_pAnimation : IAnimation;
        var v_pDisplay : IDisplay;
        var v_pTargetStateBoard : CCharacterStateBoard;

        for each ( var vInfo : CCatchingInfo in m_theCatches ) {
            if ( !vInfo || vInfo.owner != this.owner || !vInfo.owner )
                continue;


            var iDirX : int = 0;

            v_pAnimation = vInfo.target.getComponentByClass( IAnimation, true ) as IAnimation;
            v_pDisplay = vInfo.target.getComponentByClass( IDisplay, true ) as IDisplay;
            v_pTargetStateBoard = vInfo.target.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;

            if ( v_pDisplay ) {
                iDirX = v_pDisplay.direction;

                if ( vInfo.targetFlipXUpdateNeeded && vInfo.targetFlipX ) {
                    vInfo.targetFlipXUpdateNeeded = false;
                    v_pDisplay.direction *= -1;

                    if ( v_pTargetStateBoard )
                        v_pTargetStateBoard.setValue( CCharacterStateBoard.DIRECTION_DISPLAY_PERMIT, false );
                }

                // trace( v_pDisplay.direction );

                if ( vInfo.targetFlipYUpdateNeeded && vInfo.targetFlipY ) {
                    vInfo.targetFlipYUpdateNeeded = false;
                    v_pDisplay.directionY *= -1;
//                    CONFIG::debug {
//                        Foundation.Log.logWarningMsg( "Request FlipY to: " + v_pDisplay.directionY );
//                    }
                }
            }

            if ( v_pAnimation ) {
                var rot : CVector3 = v_pAnimation.modelDisplay.localRotation;
                if ( !isNaN( vInfo.targetRotation ) )
                    v_pAnimation.modelDisplay.setLocalRotation( rot.x, rot.y, vInfo.targetRotation * iDirX );
            }

            if ( vInfo.alignment == 1 ) {
                v_pAnimation = vInfo.owner.getComponentByClass( IAnimation, true ) as IAnimation;
            }

            if ( v_pAnimation ) {
                var bAnimationEnabled : Boolean = v_pAnimation.animationOffsetEnabled;
                v_pAnimation.physicsEnabled = false;
                v_pAnimation.animationOffsetEnabled = bAnimationEnabled;
                v_pAnimation.noPhysicsAndAnimationOffset = true;
            }

            vInfo.update( delta );

            var vPair : Vector.<CVector3> = vInfo.pair;
            if ( !vPair[ 0 ] || !vPair[ 1 ] )
                continue;

            if ( v_pTargetStateBoard )
                iDirX = v_pTargetStateBoard.getValue( CCharacterStateBoard.DIRECTION ).x;

            var vDur : CVector3 = vPair[ 1 ];
            var vOffset : CVector3 = null;

            vDur = vDur.sub( vPair[ 0 ] );

            if ( vInfo.alignment == 0 ) { // align to owner.
                vTrans = vInfo.target.transform as CCharacterTransform;
                vDur.mulOnValue( -1 );
                vOffset = vInfo.targetOffset.clone();
            } else if ( vInfo.alignment == 1 ) { // align to target.
                vTrans = vInfo.owner.transform as CCharacterTransform;
                vOffset = vInfo.ownerOffset.clone();
            }

            if ( vTrans ) {
                if ( vTrans.position.z + vDur.y < 0 )
                    vDur.y = -vTrans.position.z;

                vOffset.x *= iDirX;
                vOffset.x *= -1;

                vDur.addOn( vOffset );

                CONFIG::debug {
//                    Foundation.Log.logTraceMsg( "CatchSyncDur: " + vDur.toString() );
                }

                vTrans.move( vDur.x, vDur.y, vDur.z, true, false );

                CONFIG::debug {
                    Foundation.Log.logTraceMsg( "Transform's position: " + vTrans.position.toString() );
                }
            }
        }

        CCatchingInfo.clearCache();
    }

    public function findCatchingInfo( pTarget : CGameObject ) : ICatcherInfo {
        if ( !pTarget )
            return null;
        return m_theCatches.find( pTarget );
    }

    public function catches( pTag : Object, sCatchingName : String, pTarget : CGameObject,
                             sCatchesName : String, iAlignment : int = 0, iLayerPriority : int = 0,
                             bFlipX : Boolean = false, bFlipY : Boolean = false,
                             bOwnerRotAppend : Boolean = false, bTargetRotAppend : Boolean = false, fRotation : Number = NaN ) : ICatcherInfo {
        //----------------------------------------------------------------------
        // pretty line.

        var vInfo : CCatchingInfo = m_theCatches.find( pTarget );
        if ( !vInfo ) {
            vInfo = new CCatchingInfo( this.remove );
            CONFIG::debug {
                Foundation.Log.logTraceMsg( "Catches 添加对象！！！！！！" );
            }
            m_theCatches.add( pTarget, vInfo );
        }

        this.revertTargetStates( vInfo );

        vInfo.tag = pTag;
        vInfo.owner = this.owner;
        vInfo.ownerBoneName = sCatchingName;
        vInfo.target = pTarget;
        vInfo.targetBoneName = sCatchesName;
        vInfo.alignment = iAlignment;
        vInfo.layerPriority = iLayerPriority;
        vInfo.ownerRotationAppend = bOwnerRotAppend;
        vInfo.targetRotationAppend = bTargetRotAppend;
        vInfo.targetOffset = vInfo.targetOffset || CVector3.ZERO;
        vInfo.ownerOffset = vInfo.ownerOffset || CVector3.ZERO;
        vInfo.targetFlipX = bFlipX;
        vInfo.targetFlipY = bFlipY;
        vInfo.targetRotation = fRotation;

//        Foundation.Log.logMsg( "targetFlipX: " + bFlipX + " | targetFlipY: " + bFlipY );

        return vInfo;
    }

    public function targetOffset( pTarget : CGameObject, vOffset : CVector3 ) : void {
        if ( !pTarget )
            return;
        var vInfo : CCatchingInfo = m_theCatches.find( pTarget );
        if ( !vInfo )
            return;

        vInfo.targetOffset = vOffset;
    }

    public function ownerOffset( pTarget : CGameObject, vOffset : CVector3 ) : void {
        if ( !pTarget )
            return;
        var vInfo : CCatchingInfo = m_theCatches.find( pTarget );
        if ( !vInfo )
            return;

        vInfo.ownerOffset = vOffset;
    }

    public function targetRotation( pTarget : CGameObject, fDeg : Number ) : void {
        if ( !pTarget )
            return;
        var vInfo : CCatchingInfo = m_theCatches.find( pTarget );
        if ( !vInfo )
            return;

        vInfo.targetRotation = fDeg;
    }

    public function remove( pTarget : CGameObject ) : ICatcherInfo {
        if ( !pTarget )
            return null;
        var vInfo : CCatchingInfo = m_theCatches.find( pTarget );
        m_theCatches.remove( pTarget );

        // Free the catching relationship.
        var v_bTerminateNeed : Boolean = vInfo && vInfo.target && vInfo.target.isRunning;
        if ( v_bTerminateNeed ) {
            var v_pTargetAnimation : IAnimation = vInfo.target.getComponentByClass( IAnimation, true ) as IAnimation;
            var v_pFSM : CCharacterStateMachine = vInfo.target.getComponentByClass( CCharacterStateMachine, true ) as CCharacterStateMachine;
            var v_Transform : CKOFTransform = vInfo.target.getComponentByClass( CKOFTransform, true ) as CKOFTransform;
            if ( v_pTargetAnimation ) {
                // Enabled target's physics anyway.
                v_pTargetAnimation.physicsEnabled = true;
                var v_pRot : CVector3 = v_pTargetAnimation.modelDisplay.localRotation;
                v_pTargetAnimation.modelDisplay.setLocalRotation( v_pRot.x, v_pRot.y, 0 );
            }

            if ( v_Transform ) {
                if ( v_Transform.z < 0.0 )
                    v_Transform.move( 0, 0, 0, false, true );
            }

            this.revertTargetStates( vInfo );

            if ( v_pFSM ) {
                // Exit the FSM back to idle.
                CONFIG::debug {
                    Foundation.Log.logTraceMsg( "Catches 移除对象" + CCharacterDataDescriptor.getSimpleDes( pTarget.data ) );
                }

                v_pFSM.actionFSM.on( CCharacterActionStateConstants.EVENT_CATCH_END );

            }
        }

        return vInfo;
    }

    public function removeAll() : void {
        if ( !m_theCatches )
            return;
        var vInfo : ICatcherInfo;
        for ( var vObj : CGameObject in m_theCatches ) {
            vInfo = this.remove( vObj );
            free( vInfo );
        }
    }

    [Inline]
    final public function get infos() : CMap {
        return m_theCatches;
    }

    [Inline]
    final public function get infoIterator() : Object {
        return m_theCatches;
    }

    private function revertTargetStates( vInfo : CCatchingInfo ) : void {
        if ( !vInfo || !vInfo.target )
            return;

        var v_pTargetStateBoard : CCharacterStateBoard =
                vInfo.target.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;

        if ( v_pTargetStateBoard )
            v_pTargetStateBoard.setValue( CCharacterStateBoard.DIRECTION_DISPLAY_PERMIT, true );

        var vDisplay : IDisplay = vInfo.target.getComponentByClass( IDisplay, true ) as IDisplay;

        if ( !vDisplay )
            return;

        if ( vInfo.targetFlipX && !vInfo.targetFlipXUpdateNeeded )
            vDisplay.direction *= -1;

        if ( vInfo.targetFlipY && !vInfo.targetFlipYUpdateNeeded ) {
//            CONFIG::debug {
//                Foundation.Log.logWarningMsg("Revert FlipY to: " + vDisplay.directionY * -1 );
//            }
            vDisplay.directionY *= -1;

            // 如果是从-1变成1，需要把坐标重置下
            var pBound : CAABBox2 = vDisplay.modelCurrentBound || vDisplay.defaultBound;
            var fTargetHeight : Number = vInfo.target.transform.z;
            if ( vDisplay.directionY == 1 ) {
                if ( pBound ) {
                    fTargetHeight -= pBound.height;
                    fTargetHeight = Math.max( 0, fTargetHeight );
                }

            } else if ( vDisplay.directionY == -1 ) {
                if ( pBound ) {
                    fTargetHeight += pBound.height;
                    fTargetHeight = Math.max( 0, fTargetHeight );
                }
            }

            vInfo.target.transform.z = fTargetHeight;
        }

        // clear the target or owner's physics and animation offset limited.
        var pTargetAnimation : IAnimation = null;
        if ( vInfo.alignment == 0 ) {
            pTargetAnimation = vInfo.target.getComponentByClass( IAnimation, true ) as IAnimation;
        } else if ( vInfo.alignment == 1 ) {
            pTargetAnimation = vInfo.owner.getComponentByClass( IAnimation, true ) as IAnimation;
        }

        if( pTargetAnimation && pTargetAnimation.modelDisplay ) {
            pTargetAnimation.modelDisplay.velocity.zero();
            pTargetAnimation.noPhysicsAndAnimationOffset = false;
            pTargetAnimation.physicsEnabled = true;
        }
    }

}
}

import QFLib.Framework.CCharacter;
import QFLib.Interface.IUpdatable;
import QFLib.Math.CVector2;
import QFLib.Math.CVector3;

import flash.geom.Matrix3D;
import flash.geom.Orientation3D;
import flash.geom.Vector3D;

import kof.game.character.display.IDisplay;
import kof.game.character.fight.catches.ICatcherInfo;
import kof.game.core.CGameObject;

/**
 * Structures of Catcher mapping.
 */
class CCatchingInfo implements ICatcherInfo, IUpdatable {

    private static const sToAng : Number = 57.2957795130823;
    private static const sToRad : Number = 0.0174532925199433;

    public static function getRotation( m : Matrix3D, out : Vector3D = null ) : Vector3D {
        out = out || new Vector3D();
        var v : Vector3D = m.decompose( Orientation3D.EULER_ANGLES )[ 1 ];
        out.x = v.x * sToAng;
        out.y = v.y * sToAng;
        out.z = v.z * sToAng;
        return out;
    }

    private var m_pTag : Object;
    private var m_pOwner : CGameObject;
    private var m_pTarget : CGameObject;
    private var m_sOwnerBoneName : String;
    private var m_sTargetBoneName : String;
    private var m_pfnRemoved : Function;
    private var m_thePair : Vector.<CVector3>;
    private var m_iAlignment : int;
    private var m_bOwnerRotationAppend : Boolean;
    private var m_bTargetRotationAppend : Boolean;
    private var m_iLayerPriority : int;
    private var m_pOnwerWorldMatTmp : Matrix3D;
    private var m_pTargetWorldMatTmp : Matrix3D;

    private var m_pOwnerOffset : CVector3;
    private var m_pTargetOffset : CVector3;
    private var m_fTargetRotation : Number;
    private var m_pTargetFlipVec2 : CVector2;
    private var m_pTargetFlipXYUpdateFlags : int;

    /**
     * Creates a new CCatchingInfo.
     */
    public function CCatchingInfo( pfnRemoved : Function ) {
        super();

        this.m_pfnRemoved = pfnRemoved;
    }

    public function dispose() : void {
        this.remove();
        if ( m_thePair )
            m_thePair.splice( 0, m_thePair.length );
        m_thePair = null;

        m_pTag = null;
        m_pOwner = null;
        m_pTarget = null;
        m_pfnRemoved = null;

        m_pOnwerWorldMatTmp = null;
        m_pTargetWorldMatTmp = null;

        m_pTargetOffset = null;
        m_pOwnerOffset = null;

        m_pTargetFlipVec2 = null;
    }

    [Inline]
    final public function get tag() : Object {
        return m_pTag;
    }

    [Inline]
    final public function set tag( value : Object ) : void {
        m_pTag = value;
    }

    [Inline]
    final public function get ownerOffset() : CVector3 {
        return m_pOwnerOffset;
    }

    public function set ownerOffset( value : CVector3 ) : void {
        m_pOwnerOffset = value;
    }

    [Inline]
    final public function get targetOffset() : CVector3 {
        return m_pTargetOffset;
    }

    public function set targetOffset( value : CVector3 ) : void {
        m_pTargetOffset = value;
    }

    [Inline]
    final public function get targetFlipX() : Boolean {
        return m_pTargetFlipVec2 ? m_pTargetFlipVec2.x : false;
    }

    public function set targetFlipX( value : Boolean ) : void {
        m_pTargetFlipVec2 = m_pTargetFlipVec2 || new CVector2;
        m_pTargetFlipVec2.x = value ? 1 : 0;
        this.targetFlipXUpdateNeeded = true;
    }

    [Inline]
    final public function get targetFlipY() : Boolean {
        return m_pTargetFlipVec2 ? m_pTargetFlipVec2.y : false;
    }

    public function set targetFlipY( value : Boolean ) : void {
        m_pTargetFlipVec2 = m_pTargetFlipVec2 || new CVector2;
        m_pTargetFlipVec2.y = value ? 1 : 0;
        this.targetFlipYUpdateNeeded = true;
    }

    final public function get targetFlipXUpdateNeeded() : Boolean {
        return m_pTargetFlipXYUpdateFlags & (1 << 0);
    }

    public function set targetFlipXUpdateNeeded( value : Boolean ) : void {
        if ( value ) {
            m_pTargetFlipXYUpdateFlags |= (1 << 0);
        } else {
            m_pTargetFlipXYUpdateFlags &= ~(1 << 0);
        }
    }

    final public function get targetFlipYUpdateNeeded() : Boolean {
        return m_pTargetFlipXYUpdateFlags & (1 << 1);
    }

    public function set targetFlipYUpdateNeeded( value : Boolean ) : void {
        if ( value ) {
            m_pTargetFlipXYUpdateFlags |= (1 << 1);
        } else {
            m_pTargetFlipXYUpdateFlags &= ~(1 << 1);
        }
    }

    [Inline]
    final public function get targetRotation() : Number {
        return m_fTargetRotation;
    }

    public function set targetRotation( deg : Number ) : void {
        m_fTargetRotation = deg;
    }

    [Inline]
    final public function get alignment() : int {
        return m_iAlignment;
    }

    public function set alignment( value : int ) : void {
        m_iAlignment = value;
    }

    [Inline]
    final public function get ownerRotationAppend() : Boolean {
        return m_bOwnerRotationAppend;
    }

    public function set ownerRotationAppend( value : Boolean ) : void {
        m_bOwnerRotationAppend = value;
    }

    [Inline]
    final public function get targetRotationAppend() : Boolean {
        return m_bTargetRotationAppend;
    }

    public function set targetRotationAppend( value : Boolean ) : void {
        m_bTargetRotationAppend = value;
    }

    [Inline]
    final public function get layerPriority() : int {
        return m_iLayerPriority;
    }

    public function set layerPriority( value : int ) : void {
        m_iLayerPriority = value;
    }

    [Inline]
    final public function get owner() : CGameObject {
        return m_pOwner;
    }

    public function set owner( value : CGameObject ) : void {
        m_pOwner = value;
    }

    [Inline]
    final public function get ownerBoneName() : String {
        return m_sOwnerBoneName;
    }

    public function set ownerBoneName( value : String ) : void {
        m_sOwnerBoneName = value;
    }

    [Inline]
    final public function get target() : CGameObject {
        return m_pTarget;
    }

    public function set target( value : CGameObject ) : void {
        m_pTarget = value;
    }

    [Inline]
    final public function get targetBoneName() : String {
        return m_sTargetBoneName;
    }

    public function set targetBoneName( value : String ) : void {
        m_sTargetBoneName = value;
    }

    public function remove() : void {
        if ( null != m_pfnRemoved )
            m_pfnRemoved( m_pTarget );
    }

    [Inline]
    final public function get pair() : Vector.<CVector3> {
        return m_thePair;
    }

    public function get ownerWorldMat() : Matrix3D {
        if ( m_pOwner ) {
            if ( !m_pOnwerWorldMatTmp )
                m_pOnwerWorldMatTmp = getWorldMat( m_pOwner, m_sOwnerBoneName, m_bOwnerRotationAppend, NaN );
            return m_pOnwerWorldMatTmp;
        }
        return null;
    }

    public function get targetWorldMat() : Matrix3D {
        if ( m_pTarget ) {
            if ( !m_pTargetWorldMatTmp )
                m_pTargetWorldMatTmp = getWorldMat( m_pTarget, m_sTargetBoneName, m_bTargetRotationAppend, m_fTargetRotation );
            return m_pTargetWorldMatTmp;
        }
        return null;
    }

    public function getWorldMat( vObj : CGameObject, sBone : String,
                                 bRotLocalAppended : Boolean = false, fRotGlobal : Number = NaN, bFlipX : Boolean =
                                         false, bFlipY : Boolean = false, pMatRef : Matrix3D = null ) : Matrix3D {
        //----------------------------------------------------------------------

        var vDisplay : IDisplay = vObj.getComponentByClass( IDisplay, true ) as IDisplay;
        if ( !vDisplay || !vObj.isRunning || !vDisplay.modelDisplay )
            return null;

        const vModel : CCharacter = vDisplay.modelDisplay;
        const idxBone : int = vModel.findBoneIndex( sBone );
        var vPos : CVector2 = new CVector2( 0, 0 );
        var vBoneMat : Matrix3D = new Matrix3D();
        var vWorldMat : Matrix3D = pMatRef || new Matrix3D();
        var fRot : Number = NaN;

        vModel.characterObject.retrieveBonePosition( idxBone, vPos, false, true );
        if ( bRotLocalAppended )
            fRot = vModel.characterObject.retrieveBoneRotation( idxBone );

        {
            var iTransX : Number = vPos.x * vDisplay.direction;
            var iTransY : Number = vPos.y * -1;
            var iTransZ : Number = 0.0;

            /* if ( bFlipX ) */
            /* iTransX *= -1; */

            if ( bFlipY )
                iTransY *= -1;

            vBoneMat.identity();
            vBoneMat.appendScale( 1.0, 1.0, 1.0 );
            if ( !isNaN( fRot ) )
                vBoneMat.appendRotation( -fRot, Vector3D.Z_AXIS );
            vBoneMat.appendTranslation( iTransX, iTransY, iTransZ );
        }

//        Foundation.Log.logMsg( "vBoneMat's position: " + vBoneMat.position.toString() );

        {
            vWorldMat.identity();
            vWorldMat.appendScale( vDisplay.modelDisplay.scale.x, vDisplay.modelDisplay.scale.y, vDisplay.modelDisplay.scale.z );
            if ( !isNaN( fRotGlobal ) && 0.0 != fRotGlobal )
                vWorldMat.appendRotation( -fRotGlobal * vDisplay.direction, Vector3D.Z_AXIS );
            vWorldMat.appendTranslation( vObj.transform.x, vObj.transform.z, vObj.transform.y );
        }

        vWorldMat.prepend( vBoneMat );

        return vWorldMat;
    }

    public function update( delta : Number ) : void {
        if ( !m_thePair )
            m_thePair = new Vector.<CVector3>( 2, true );

        // calc owner's world location of catching bone.
        var v_bRotCalc : Boolean = this.ownerRotationAppend;
        var vOwnerMat : Matrix3D = getWorldMat( m_pOwner, m_sOwnerBoneName,
                v_bRotCalc, NaN, false, false, m_pOnwerWorldMatTmp );

        if ( !vOwnerMat ) {
            m_thePair[ 0 ] = null;
            return;
        }

        if ( m_thePair[ 0 ] )
            m_thePair[ 0 ].setValueXYZ( vOwnerMat.position.x, vOwnerMat.position.y, vOwnerMat.position.z );
        else
            m_thePair[ 0 ] = new CVector3( vOwnerMat.position.x, vOwnerMat.position.y, vOwnerMat.position.z );

//        Foundation.Log.logMsg( "OwnerWorldMat: " + m_thePair[ 0 ].toString() );

        var v_fRotAppend : Number = NaN;

        if ( this.targetRotationAppend )
            v_fRotAppend = getRotation( vOwnerMat ).z;

        if ( isNaN( v_fRotAppend ) )
            v_fRotAppend = m_fTargetRotation;
        else
            v_fRotAppend += m_fTargetRotation;

        var vTargetMat : Matrix3D = getWorldMat( m_pTarget, m_sTargetBoneName,
                false, v_fRotAppend, targetFlipX, targetFlipY, m_pTargetWorldMatTmp );

        if ( !vTargetMat ) {
            m_thePair[ 1 ] = null;
            return;
        }

        if ( m_thePair[ 1 ] )
            m_thePair[ 1 ].setValueXYZ( vTargetMat.position.x, vTargetMat.position.y, vTargetMat.position.z );
        else
            m_thePair[ 1 ] = new CVector3( vTargetMat.position.x, vTargetMat.position.y, vTargetMat.position.z );

//        Foundation.Log.logMsg( "TargetWorldMat: " + m_thePair[ 1 ].toString() );

        m_pOnwerWorldMatTmp = vOwnerMat;
        m_pTargetWorldMatTmp = vTargetMat;
    }

    public static function clearCache() : void {
        // NOOP
    }

}
// vim:ft=as3 tw=120 sw=4 ts=4 expandtab
