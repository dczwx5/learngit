//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/3/23.
//----------------------------------------------------------------------
package QFLib.Framework {

import QFLib.Collision.CCharacterCollisionBound;
import QFLib.Collision.CCollisionBound;
import QFLib.Collision.CCollisionBound;
import QFLib.Collision.CCollisionManager;
import QFLib.Collision.ICollisable;
import QFLib.Foundation;
import QFLib.Framework.CharacterExtData.CCharacterCollisionBoundInfo;
import QFLib.Framework.CharacterExtData.CCharacterCollisionKey;
import QFLib.Framework.Util.CCollisionTimeLine;
import QFLib.Framework.Util.CCollisionTimeLine;
import QFLib.Graphics.RenderCore.CBaseObject;
import QFLib.Graphics.RenderCore.starling.display.DisplayObject;
import QFLib.Interface.IDisposable;
import QFLib.Interface.IUpdatable;
import QFLib.Math.CAABBox3;
import QFLib.Math.CVector3;


public class CCollisionObject implements IDisposable , IUpdatable , ICollisable{
    public function CCollisionObject( collisionSystem : CCollisionManager , theCharacterObj : CObject) {
        m_pCollisionSystem = collisionSystem;
        m_pCharacterObjectRef = theCharacterObj;
        m_theCollisionTimeLine = new CCollisionTimeLine( collisionSystem , this );
    }

    public function update( delta : Number ) : void
    {
        delta = delta * collisionSpeed;
        _updateTimeLine( delta );
        _updateBounds( delta );
    }

    private function _updateTimeLine( delta : Number ) : void
    {
        m_theCollisionTimeLine.update( delta );
    }

    private function _updateBounds( delta : Number ) : void
    {
        for each( var charaBound : CCharacterCollisionBound in m_theCollisionBounds ){
            charaBound.update( delta );
        }
    }

    public function get collisionSpeed() : Number {
        return m_fCollisionSpeed;
    }

    public function set collisionSpeed( speed : Number ) : void{
        m_fCollisionSpeed = speed;
    }

    public function updateRemoval( delta : Number ) : void
    {
        var curBounds : Array = m_theCollisionBounds.slice();
        for each( var charaBound : CCharacterCollisionBound in curBounds){//} m_theCollisionBounds ){
            if( charaBound.isOutDate )
                destroyCollisionBound( charaBound );
        }
    }

    public function dispose() : void
    {
        m_pCollisionSystem = null;
        m_theCollisionTimeLine.dispose();
        m_theCollisionTimeLine = null;
    }

    public function setCollisionData( collisionData : Vector.<CCharacterCollisionKey> ): void
    {
        _reset();
        if( !enable ) return;
        m_theCollisionTimeLine.setCollisionData( collisionData );
    }

    /**
     * 设置外部用户数据
     * @param data
     */
    public function set ownerData( data : Object ) : void
    {
        m_pOwnerData = data;
    }

    public function get ownerData() : Object
    {
        return m_pOwnerData;
    }

    public function createCollisionBound( type : int , box : CAABBox3 ,hitEvent : String, duration : Number) : CCollisionBound
    {
        var characterBound : CCharacterCollisionBound = new CCharacterCollisionBound();
        var basicBound : CCollisionBound = m_pCollisionSystem.registerCollisionBound( type , box , ownerData  ) as CCollisionBound;
        basicBound.resetPairs();
        basicBound.pAttacherRef = this;
        characterBound.characterCollision = basicBound;
        characterBound.hitEvent = hitEvent;
        characterBound.durationTime = duration;
        m_theCollisionBounds.push( characterBound );
        return basicBound;
    }

    public function destroyCollisionBound( bound : CCharacterCollisionBound ) : void
    {
        var idx : int = m_theCollisionBounds.indexOf( bound );
        if( idx > -1 )
                m_theCollisionBounds.splice( idx , 1 );

        m_pCollisionSystem.unRegisterCollisionBound( bound.characterCollision );
    }

    public function setRelativeBlockAABB( block : CAABBox3 ) : void
    {
        m_blockBox = block;
    }

    public function getRelativeBlockAABB() : CAABBox3
    {
        return m_blockBox;
    }

    public function getRealTimeBlockAABB() : CAABBox3
    {
        if( m_blockBox )
            return getAttachAABBToCharacter( m_blockBox );
        Foundation.Log.logTraceMsg("Has Not initial defautl bolckBox");
        return null;
    }

    protected function getAttachAABBToCharacter( box : CAABBox3 ) : CAABBox3
    {
        var srcBox : CAABBox3 = box.clone();
        var vSize : CVector3 = srcBox.ext.mul( scale );
        var tranPosition : CVector3 = position;
        var vPos : CVector3 = ((srcBox.center).mul( dir )).add(new CVector3( tranPosition.x ,  tranPosition.y ,tranPosition.z ));
        srcBox.setCenterExt( vPos, vSize );
        return srcBox;
    }

    private function _reset() : void
    {
        if( m_theCollisionTimeLine )
            m_theCollisionTimeLine.stop();

        if( m_theCollisionBounds ) {
            var bounds : Array = m_theCollisionBounds;
            while( m_theCollisionBounds.length!=0 ){
                var bound : CCharacterCollisionBound = m_theCollisionBounds[ 0 ];
                destroyCollisionBound( bound );
            }

            m_theCollisionBounds.length = 0;
        }

    }

    public function createCAABB3FromInfo( boundInfo : CCharacterCollisionBoundInfo ) : CAABBox3
    {
        var abBox : CAABBox3;
        abBox = CAABBox3.ZERO.clone();
        var offset : CVector3 = new CVector3( boundInfo.v3Position.x, boundInfo.v3Position.y, boundInfo.v3Position.z);
        var size : CVector3 = new CVector3( boundInfo.v3Size.x, boundInfo.v3Size.y, boundInfo.v3Size.z );
        offset.mulOn( CCollisionTimeLine.UNITY_TO_FLASH );
        abBox.setCenterExt( offset , size );
        return abBox;
    }

    public function set enable( value : Boolean ) : void
    {
        m_pEnable = value;
        _reset();
    }

    public function get enable( ) : Boolean
    {
        return m_pEnable;
    }

    public function get collisionBounds() : Array
    {
        return m_theCollisionBounds;
    }

    /**
     * implemet Icollisable
     */
    public function get position() : CVector3
    {
        return m_pCharacterObjectRef.position;
    }

    public function get flipX() : Boolean
    {
        return m_pCharacterObjectRef.flipX;
    }

    public function get flipY() : Boolean
    {
        return m_pCharacterObjectRef.flipY;
    }

    public function get flipZ() : Boolean{
        return m_pCharacterObjectRef.flipZ;
    }

    public function get scale() : CVector3
    {
        return m_pCharacterObjectRef.scale;
    }

    public function get dir() : CVector3
    {
        var dir : CVector3;
        var fFlipX : Number = flipX ? -1 : 1;
        var fFlipY : Number = flipY ? -1 : 1;
        var fFlipZ : Number = -1;
        dir =  new CVector3( fFlipX, fFlipY , fFlipZ );
        return dir;
    }

    public function get renderableObject () : CBaseObject
    {
        return m_pCharacterObjectRef.theObject ;
    }

    private var m_theCollisionBounds : Array = [];//Vector.<CCharacterCollisionBound> = new Vector.<CCharacterCollisionBound>();
    private var m_pCollisionSystem : CCollisionManager;
    private var m_theCollisionTimeLine : CCollisionTimeLine;
    private var m_pOwnerData : Object;
    private var m_pCharacterObjectRef : CObject;
    private var m_pEnable : Boolean = true;
    private var m_blockBox : CAABBox3;
    private var m_fCollisionSpeed : Number = 1.0;
}
}
