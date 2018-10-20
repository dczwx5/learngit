//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/2/14.
//----------------------------------------------------------------------
package kof.game.character.fight.buff.buffentity {

import QFLib.Foundation.CMap;
import QFLib.Framework.CObject;
import QFLib.Math.CVector2;
import QFLib.Math.CVector3;

import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.display.CBaseDisplay;
import kof.game.character.display.IDisplay;
import kof.game.character.fight.buff.IBuffEffectContainer;
import kof.game.character.fight.emitter.CMasterCompomnent;
import kof.game.character.fight.skill.CComponentUtility;
import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fight.skilleffect.CSkillEffectContainer;
import kof.game.character.property.CCharacterProperty;
import kof.game.character.property.interfaces.ICharacterProperty;
import kof.game.core.CGameObject;
import kof.game.core.ITransform;
import kof.table.Buff;
import kof.table.Skill.EEffectType;
import kof.util.CAssertUtils;
import kof.util.CObjectUtils;

public class CBuff extends CAbstractBuff {
    public function CBuff( id : int , buffId : int ,tableDB : IDatabase = null , skillOwner: CGameObject=null) {
        super(id , buffId);
        m_pDatabase = tableDB;
        var buffTable : IDataTable = m_pDatabase.getTable( KOFTableConstants.BUFF ) as IDataTable;
        m_pBuff = buffTable.findByPrimaryKey( m_nBuffId );
        CAssertUtils.assertNotNull( m_pBuff , "can not find the buff in table  which id = " + buffId );
        buffSkillOwner = skillOwner;
        m_buffInputEffectList = new Array();
    }

    override public function dispose() : void
    {
        if( m_attModifierList )
                m_attModifierList.splice( 0 , m_attModifierList.length );
        m_attModifierList = null;

        if( m_buffInputEffectList )
            m_buffInputEffectList.splice( 0 , m_buffInputEffectList.length );
        m_buffInputEffectList = null;

        m_pDatabase = null;
        m_buffSkillOwner = null;
    }

    override public function get buffAttModifierList() : Array
    {
        if( m_attModifierList )
                return m_attModifierList;

        m_attModifierList = [];
        var attModifier : CBuffModifierInfo;
        if( buffData.AttributeName == null) return null ;
        for ( var i :int = 0 ;i< buffData.AttributeName.length;i++ ){
            var attStr : String = buffData.AttributeName[i];
            if( attStr != null && attStr != "" ) {
                attModifier = new CBuffModifierInfo();
                attModifier.AttributeName = attStr;
                attModifier.AttributeModifyMode = buffData.AttributeModifyMode[i];
                attModifier.AttributeModifyValue = buffData.AttributeModifyValue[i];
                attModifier.AttributeGoal = buffData.AttributeGoal[i];
                m_attModifierList.push( attModifier );
            }
        }

        return m_attModifierList;
    }

    override public function update( delta : Number ) : void
    {
        _SyncBuffGameObjectPosition();

        var bReady : Boolean = true;
        if( bReady ) {
            if( !isNaN( m_effectTime ))
            {
                m_effectTime -= delta;
            }

            if( m_buffInputEffectList.length > 0 && isNaN(m_effectTime )){
                _spwanNewEffect();
            }else if( m_buffInputEffectList.length > 0 && m_effectTime <= 0){
                _spwanNewEffect();
            }
        }
    }

    public function addToTriggerEffectQueue() : void{
        m_buffInputEffectList.push( randomSeed );
        m_bBuffListDirty = true;
    }
    /**
     * buff实体的初始化
     */
    public function addBuffGameObject() : void
    {
        var data : Object = {};
        if( m_buffSkillOwner ) {
            var coloneProperty : CCharacterProperty = buffSkillOwner.getComponentByClass( CCharacterProperty , true )
                    as CCharacterProperty;
            data["fightProperty"] = CObjectUtils.cloneObject(coloneProperty.fightProperty)
        }

        var pTransform : ITransform = m_theContainer.owner.getComponentByClass( ITransform , true ) as ITransform;
        var p2DPosition : CVector3 = _getBuffOwner2DPosition();

        data["skinName"] = buffData.SkinName;
        data[ "fightProperty" ] = CObjectUtils.cloneObject(coloneProperty.fightProperty);
        data["x"] = p2DPosition.x ;
        data["y"] = p2DPosition.y ;
        data["z"] = pTransform.z ;
        data["type"] = CCharacterDataDescriptor.TYPE_BUFF;
        data["id"] = id;
        data["campID"] = CCharacterDataDescriptor.getCampID(m_buffSkillOwner.data );
        var ownerType : int = CCharacterDataDescriptor.getType( m_buffSkillOwner.data );
        if( ownerType == CCharacterDataDescriptor.TYPE_MISSILE ){
            var missilePorperty : CMasterCompomnent = m_buffSkillOwner.getComponentByClass( CMasterCompomnent , true ) as CMasterCompomnent;
            data["ownerId"] = missilePorperty.ownerId;
            data["ownerType"] = missilePorperty.ownerType;
            data["ownerSkin"] = missilePorperty.ownerSkin;
            data["aliasSkillID"] = missilePorperty.aliasSkillID;

        }else if( ownerType == CCharacterDataDescriptor.TYPE_PLAYER ||
                ownerType == CCharacterDataDescriptor.TYPE_MONSTER ){
            var pSkillCaster : CSkillCaster = m_buffSkillOwner.getComponentByClass( CSkillCaster , true ) as CSkillCaster;
            data["ownerId"] = CCharacterDataDescriptor.getID( m_buffSkillOwner.data );
            data["ownerType"] = CCharacterDataDescriptor.getType( m_buffSkillOwner.data );
            data["ownerSkin"] = CCharacterDataDescriptor.getSkinName( m_buffSkillOwner.data );
            data["aliasSkillID"] = pSkillCaster.skillID;
        }

        _createBuffGameObject( data );
    }

    private function _createBuffGameObject( data : Object ) : void
    {
        m_buffGameObject = m_theContainer.addBuffGameObject( data );
    }

    public function removeBuffGameObject() : void
    {
        m_theContainer.removeBuffGameObject( id );
    }

    private function _SyncBuffGameObjectPosition() : void
    {
        if( m_buffGameObject ) {
            var buffDisplay : IDisplay = m_buffGameObject.getComponentByClass( IDisplay , true ) as IDisplay;
            if( !buffDisplay.isReady ) return ;
            var p2DPosiontion : CVector3 = _getBuffOwner2DPosition();
            buffDisplay.modelDisplay.setPositionToFrom2D( p2DPosiontion.x, p2DPosiontion.y );
            m_buffGameObject.transform.x = buffDisplay.modelDisplay.position.x;
            m_buffGameObject.transform.y = buffDisplay.modelDisplay.position.z;
            m_buffGameObject.transform.z = buffDisplay.modelDisplay.position.y;
        }
    }

    private function _getBuffOwner2DPosition() : CVector3
    {
        var pTransform : ITransform = m_theContainer.owner.getComponentByClass( ITransform , true ) as ITransform;
        var p2DPosition : CVector3 = CObject.get2DPositionFrom3D( pTransform.x , pTransform.z , pTransform.y );
        return p2DPosition;
    }

    public function triggerBuffEffect() : void
    {
        _TriggerEffect();
    }

    private function _bReadyBuffObj() : Boolean {
        if( m_buffGameObject ){
            var pDisplay : CBaseDisplay = m_buffGameObject.getComponentByClass( CBaseDisplay , true ) as CBaseDisplay;
            if( pDisplay && pDisplay.isReady )
                    return true;
        }
        return false;
    }

    private function _spwanNewEffect() : void{
        m_buffInputEffectList.pop();
        triggerBuffEffect();
        m_effectTime = 0 ;// m_pBuff.EffectSpan;
    }

    private function _TriggerEffect() : void
    {
        if( m_buffGameObject == null )
            addBuffGameObject();

        _buildBuffEffect( buffData , m_buffGameObject );
    }

    public function _buildBuffEffect( data : Buff , buffGameObj : CGameObject ) : void{
        if( buffGameObj != null ) {
            var theSkillCat : CSkillCaster = buffGameObj.getComponentByClass( CSkillCaster , true ) as CSkillCaster ;

            if( theSkillCat )
            {
                theSkillCat.removeSkillEffects();
                theSkillCat.buildSkillEffects( data , EEffectType.E_BUFF , this );
            }
        }
    }

    /**
     * 标识buff实体
     */
    public function get buffGameObject() : CGameObject
    {
        return m_buffGameObject;
    }

    public function get buffSkillOwner() : CGameObject
    {
        return m_buffSkillOwner;
    }

    public function set buffSkillOwner( value : CGameObject ) : void
    {
        m_buffSkillOwner = value;
    }

    override public function setParent( container : IBuffEffectContainer  ) : void
    {
        super.setParent( container );
//        _spwanNewEffect();
    }

    protected var m_pDatabase : IDatabase;
    private var m_attModifierList : Array;
    private var m_buffSkillOwner : CGameObject;
    private var m_buffGameObject : CGameObject;
    private var m_buffInputEffectList : Array;
    private var m_bBuffListDirty : Boolean;
    private var m_effectTime : Number = NaN;

}
}
