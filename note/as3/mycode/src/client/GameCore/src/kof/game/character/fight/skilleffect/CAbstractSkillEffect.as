//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/7/25.
//----------------------------------------------------------------------
package kof.game.character.fight.skilleffect {

import QFLib.Interface.IDisposable;
import QFLib.Interface.IUpdatable;

import kof.game.character.fight.CTargetCriteriaComponet;

import kof.game.character.fight.skill.CSkillCaster;

import kof.game.character.fight.skill.CSkillDataBase;
import kof.game.character.fx.CFXMediator;
import kof.game.character.property.CCharacterProperty;
import kof.game.core.CGameObject;

public class CAbstractSkillEffect implements ISkillEffect ,IDisposable, IUpdatable{
    public function CAbstractSkillEffect(id : int , startFrame : Number , hitEvent : String ,etype : int , des : String = "") {
        this.m_effectType = etype;
        this.m_effectID = id ;
        this.m_effectStartFrame = startFrame;
        this.m_effectDes = des;
        this.m_hitEventSinal = hitEvent;
        this.m_isValid = true;
    }

    public function update( delta : Number ) : void {
        if( isNaN( m_fElapseTickTime ))
            return;

        m_fElapseTickTime += delta ;
        if( boReachEffectTime && !boStarted )
                doStart();
        if( isRunning )
                doRunning( delta );
    }

    public function lastUpdate( delta : Number ) : void {
        if( isNaN( m_fElapseTickTime ) )
                return;

        //没有持续时间就不做处理，表示一直存在直到效果消失
        if( isNaN( m_effectDuarationFrame ) )
                return;

        if( boRunOutEffectTime && !boOutDate )
                doEnd();
    }

    public virtual function doRunning( delta : Number ) : void{

    }

    public virtual function doStart() : void {
        m_boStarted = true;
    }

    public virtual function doEnd() : void {
        m_boOutDate = true;
        m_fElapseTickTime = NaN;
    }

    public virtual function get isRunning() : Boolean
    {
        return m_boStarted && !m_boOutDate ;
    }

    protected function get boStarted() : Boolean
    {
        return m_boStarted;
    }

    protected function get boOutDate() : Boolean
    {
        return m_boOutDate;
    }

    protected function get boReachEffectTime() : Boolean
    {
        return m_fElapseTickTime >= effectStartTime;
    }

    protected function get boRunOutEffectTime() : Boolean
    {
        return m_fElapseTickTime >= ( effectDuarationTime + effectStartTime );
    }

    public function get endTime() : Number{
        return effectDuarationTime + effectStartTime;
    }

    public function setContainer(container : CSkillEffectContainer) : void
    {
        m_pContainer = container;
    }

    public function initData(... args) : void
    {
        m_fElapseTickTime = 0.0;
    }

    public function dispose() : void
    {
        if( !boOutDate )
                doEnd();
    }

     public function resetEffect() : void
     {

     }

    public function get effectDuarationTime() : Number
    {
        return m_effectDuarationFrame * CSkillDataBase.TIME_IN_ONEFRAME;
    }

    final public function get effectID() : int
    {
        return m_effectID;
    }

    final public function get effectType() : int
    {
        return m_effectType;
    }

    final public function get effectStartTime() : Number
    {
        return m_effectStartFrame ;
    }

    public function get effectDes() : String {
        return m_effectDes;
    }

    final public function get hitEventSignal() : String
    {
        return m_hitEventSinal;
    }

    final public function get pSkillCaster() : CSkillCaster
    {
        return owner.getComponentByClass( CSkillCaster , true ) as CSkillCaster;
    }

    final protected function get pCriteriaComp() : CTargetCriteriaComponet{
        return owner.getComponentByClass( CTargetCriteriaComponet , true ) as CTargetCriteriaComponet;
    }

    final protected function get pFxMediator() : CFXMediator{
        return owner.getComponentByClass( CFXMediator , true ) as CFXMediator;
    }

    final protected function get pCharacterProperty() : CCharacterProperty
    {
        return owner.getComponentByClass( CCharacterProperty , true ) as CCharacterProperty;
    }

    public function set effectStartFrame( value : Number ) : void {
        m_effectStartFrame = value;
    }

    public function get isValid() : Boolean {
        return m_isValid;
    }

    public function syncResponse( ...arg ) : void
    {

    }

    protected function get owner() : CGameObject
    {
        return m_pContainer.owner;
    }

    public function get entityType() : int
    {
        return m_pContainer.entityType;
    }

    public function get entityInfo() : *
    {
        return m_pContainer.entityInfo;
    }

    public function set boSyncEffect( value : Boolean ) : void{
        this.m_boSyncEffect = value;
    }

    public function get boSyncEffect() : Boolean{
        return m_boSyncEffect;
    }

    public function get boLastUpdateDirty() : Boolean{
        return m_boLastUpdateDirty;
    }

    public function set boLastUpdateDirty( value : Boolean ) : void{
        this.m_boLastUpdateDirty = value;
    }

    protected var m_effectID : int;
    protected var m_effectType : int;
    protected var m_effectStartFrame : Number;
    protected var m_effectDuarationFrame : Number;
    protected var m_effectDes : String;
    protected var m_hitEventSinal : String;

    protected var m_isValid : Boolean;
    protected var m_pContainer : CSkillEffectContainer;

    protected var m_fElapseTickTime : Number;
    protected var m_boStarted : Boolean;
    protected var m_boOutDate : Boolean;
    protected var m_boSyncEffect : Boolean;

    protected var m_boLastUpdateDirty : Boolean;
}
}
