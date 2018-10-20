//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character {

import QFLib.Framework.CFramework;

import QFLib.Interface.IDisposable;

import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.character.ai.CAIComponent;
import kof.game.character.animation.IAnimation;
import kof.game.character.dynamicBlock.CDynamicBlockComponent;
import kof.game.character.fight.CAutoRecoveryComponent;
import kof.game.character.fight.skillcalc.CFightCalc;
import kof.game.character.fight.skillcalc.hurt.CFightDamageComponent;
import kof.game.character.fight.skillcalc.hurt.CFightProperty;
import kof.game.character.fight.skillcalc.hurt.CProfessionRelation;
import kof.game.character.movement.CNavigationViewDebug;
    import kof.game.character.property.CMonsterProperty;
import kof.game.character.scripts.CMonsterAppear;
import kof.game.character.scripts.CMonsterRemoval;
import kof.game.core.CGameObject;
import kof.table.ActionSeq;
import kof.table.Monster;
import kof.table.MonsterSkill;
import kof.table.Skill;
import kof.util.CAssertUtils;

/**
 * 基于CharacterBuilder之上构建Monster的GameObject结构
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public final class CMonsterBuilder implements IDisposable {

    private var m_pCharacterBuilder : CCharacterBuilder;

    public function CMonsterBuilder( pCharacterBuilder : CCharacterBuilder = null ) {
        m_pCharacterBuilder = pCharacterBuilder;
    }

    public function dispose() : void {
        m_pCharacterBuilder = null;
    }

    final public function get characterBuilder() : CCharacterBuilder {
        return m_pCharacterBuilder;
    }

    final public function set characterBuilder( value : CCharacterBuilder ) : void {
        m_pCharacterBuilder = value;
    }

    final public function get database() : IDatabase {
        return this.characterBuilder.database;
    }

    final public function get graphicFramework() : CFramework {
        return this.characterBuilder.graphicsFramework;
    }

    /**
     * Build the specific <code>obj</code>:CGameObject as a Monster.
     *
     * @param obj the specific obj to build.
     * @return true if built successfully, false otherwise.
     */
    public function build( obj : CGameObject ) : Boolean {
        if ( !CCharacterDataDescriptor.isMonster( obj.data ) ) {
            // isn't a valid monster data.
            CCharacterBuilder.LOG.logErrorMsg( "The specific data of CGameObject hasn't a legal data structure!" );
            return false;
        }

        CAssertUtils.assertNotNull( this.characterBuilder, "A CCharacterBuilder is required by CMonsterBuilder." );

        // Building the base components specify for Character.
        var ret : Boolean = true;

        ret = ret && this.buildProperties( obj );
        ret = ret && this.buildBasic( obj );
        ret = ret && this.buildInput( obj );
        ret = ret && this.buildAI( obj );
        ret = ret && this.buildState( obj );
        ret = ret && this.buildSkill( obj );
        ret = ret && this.buildRendering( obj );
        ret = ret && this.buildSubAnimation( obj );
        ret = ret && this.buildOther( obj );
        ret = ret && this.buildNetworking( obj );
        ret = ret && this.buildAppSystemSupported( obj );
        ret = ret && this.bulidBlock( obj );
        ret = ret && this.buildOtherFightSupport(obj);
        CONFIG::debug{
            ret = ret && this.buildNavigation(obj);
        }
        return ret;
    }

    protected function buildNavigation( obj : CGameObject ) : Boolean {
        obj.addComponent( new CNavigationViewDebug() );
        return true;
    }

    protected function buildAI( obj : CGameObject ) : Boolean {
        obj.addComponent( new CAIComponent() );
        return true;
    }

    protected function buildProperties( obj : CGameObject ) : Boolean {
        // Nothing specific
        obj.addComponent( new CMonsterProperty() );
        obj.addComponent( new CProfessionRelation());
        obj.addComponent( new CFightCalc() );
        obj.addComponent( new CFightProperty() );
        obj.addComponent( new CFightDamageComponent());
        return true;
    }

    protected function buildBasic( obj : CGameObject ) : Boolean {
        this.characterBuilder.addBaseComponents( obj );
        this.characterBuilder.buildEventSupported( obj );
        obj.addComponent( new CMonsterAppear(m_pCharacterBuilder.pPlayerHandle) );
        return true;
    }

    protected function buildState( obj : CGameObject ) : Boolean {
        // Nothing specific
        this.characterBuilder.buildStateSupported( obj );
        return true;
    }

    protected function bulidBlock( obj : CGameObject ) : Boolean {
        obj.addComponent( new CDynamicBlockComponent( this.characterBuilder.sceneFacade ) );
        return true;
    }

    protected function buildOtherFightSupport( obj : CGameObject ) : Boolean{
        obj.addComponent( new CAutoRecoveryComponent());
        return true;
    }

    protected function buildSkill( obj : CGameObject ) : Boolean {
        this.characterBuilder.buildSkillSupported( obj );
        obj.addComponent(new CSkillInterruptList());

        // Retrieves a skillList from the table "MonsterSkill".
        var pTableMonsterSkill : IDataTable = this.database.getTable( KOFTableConstants.MONSTER_SKILL );

        CAssertUtils.assertNotNull( pTableMonsterSkill, "DataTable \"Monster\" required from CMonsterBuilder." );

        var prototypeID : int = CCharacterDataDescriptor.getPrototypeID( obj.data );
        CAssertUtils.assertNotEquals( 0, prototypeID, "A Monster's data has illegal prototypeID." );

        var pMonsterSkill : MonsterSkill = pTableMonsterSkill.findByPrimaryKey( prototypeID );
        if ( pMonsterSkill ) {
            var pSkillList : CSkillList = obj.getComponentByClass( CSkillList, false ) as CSkillList;
            var pInterruptList : CSkillInterruptList = obj.getComponentByClass( CSkillInterruptList , false) as CSkillInterruptList;
            if ( pSkillList ) {
                var i : int = 0, l : int = pMonsterSkill.SkillID.length;
                for ( ; i < l; ++i ) {
                    var nSkillID : int = int( pMonsterSkill.SkillID[ i ] );
                    if ( nSkillID == 0 )
                        continue;

                    pSkillList.setSkillIDByIndex( i, nSkillID );
                    pSkillList.setSkillDamageRevisionByIndex( i ,pMonsterSkill.DamageRevision[ i ]);
                    if( pInterruptList )
                            pInterruptList.setInterruptList( i , pMonsterSkill.Interrupt[ i ]);
                }
            }
        }

        return true;
    }

    public function updateSkin( obj : CGameObject, bForced : Boolean = true ) : Boolean {
        var ret : Boolean = false;
        // Determines the skin in the obj.
        var sSkinName : String = CCharacterDataDescriptor.getSkinName( obj.data );
        if ( bForced || !sSkinName || sSkinName.length == 0 ) {
            // doesn't contains a valid skin, query the configure skin in the database.
            const pTable : IDataTable = this.database.getTable( KOFTableConstants.MONSTER );
            if ( pTable ) {
                var iMonsterID : int = CCharacterDataDescriptor.getPrototypeID( obj.data );
                CAssertUtils.assertNotEquals( 0, iMonsterID, "A Monster's data has  illegal prototypeID." );

                var pMonsterObject : Monster = pTable.findByPrimaryKey( iMonsterID ) as Monster;
                if ( pMonsterObject ) {
                    sSkinName = pMonsterObject.SkinName;
                    ret = true;
                }
            }
        }

        CAssertUtils.assertTrue( sSkinName && sSkinName.length > 0, "Builing a Monster hadn't a valid skin, will can't be rendering correctly." );
        CCharacterDataDescriptor.setSkinName( obj.data, sSkinName );
        return ret;
    }

    protected function buildRendering( obj : CGameObject ) : Boolean {
        this.updateSkin( obj );
        this.characterBuilder.buildRenderingSupported( obj );

        return true;
    }

    /** Old format for skill action sequence
    protected function buildAnimation( obj : CGameObject ) : Boolean {
        this.characterBuilder.buildPhysicalSupported( obj );

        var pTableActionSeq : IDataTable = this.database.getTable( KOFTableConstants.ACTION_SEQ );
        CAssertUtils.assertNotNull( pTableActionSeq, "DataTable \"ActionSeq\" required from CMonsterBuilder." );

        // Resolves the "ActionSeq", make an unconflict animation list.
        var allSkills : Vector.<uint> = this.characterBuilder.findAllSkillIDs( obj );
        var pAnimation : IAnimation = obj.getComponentByClass( IAnimation, false ) as IAnimation;

        for ( var i : int = 0, l : int = allSkills.length; i < l; ++i ) {
            var nSkillID : int = allSkills[ i ];
            if ( 0 == nSkillID )
                continue;

            var pActionSeq : ActionSeq = pTableActionSeq.findByPrimaryKey( nSkillID );
            // FIXME: Log warning needed?
            if ( !pActionSeq )
                continue;
            var nActinoIndex : int = 0;
            var boTimer2Idle : Boolean = false;
            for each ( var sAnimationName : String in pActionSeq.AnimationName ) {
                if ( !sAnimationName || !sAnimationName.length )
                    continue;
                sAnimationName = StringUtil.trim( sAnimationName );
                if ( !sAnimationName.length )
                    continue;

                nActinoIndex++;
                if( nActinoIndex == pActionSeq.AnimationName.length )
                        boTimer2Idle = true;

                pAnimation.addSkillAnimationState( sAnimationName.toUpperCase(), sAnimationName );
            }
        }

        return true;
    }*/

    protected function buildSubAnimation( obj : CGameObject ) : Boolean {
        this.characterBuilder.buildPhysicalSupported( obj );

        /**
        var pTableActionSeq : IDataTable = this.database.getTable( KOFTableConstants.ACTION_SEQ2 );
        var pTableSkill : IDataTable = this.database.getTable( KOFTableConstants.SKILL );
        CAssertUtils.assertNotNull( pTableActionSeq, "DataTable \"ActionSeq\" required from CMonsterBuilder." );

        // Resolves the "ActionSeq", make an unconflict animation list.
        var allSkills : Vector.<uint> = this.characterBuilder.findAllSkillIDs( obj );
        var pAnimation : IAnimation = obj.getComponentByClass( IAnimation, false ) as IAnimation;

        for ( var i : int = 0, l : int = allSkills.length; i < l; ++i ) {
            var nSkillID : int = allSkills[ i ];
            if ( 0 == nSkillID )
                continue;
            var skillInfo : Skill = pTableSkill.findByPrimaryKey( nSkillID );
            var pActionSeq : ActionSeq = pTableActionSeq.findByPrimaryKey( skillInfo.SkinName + "_" + skillInfo.ActionFlag );
            // FIXME: Log warning needed?
            if ( !pActionSeq )
                continue;

//            var nActinoIndex : int = 0;
//            var boTimer2Idle : Boolean = false;


            for each ( var sAnimationName : String in pActionSeq.AnimationName ) {
                if ( !sAnimationName || !sAnimationName.length )
                    continue;
                sAnimationName = StringUtil.trim( sAnimationName );
                if ( !sAnimationName.length )
                    continue;
//                nActinoIndex++;
//                if( nActinoIndex == pActionSeq.AnimationName.length )
//                    boTimer2Idle = true;

                pAnimation.addSkillAnimationState( sAnimationName.toUpperCase(), sAnimationName );
            }
        } */

        return true;
    }

    protected function buildInput( obj : CGameObject ) : Boolean {
        this.characterBuilder.buildInputSupported( obj );
        return true;
    }

    protected function buildOther( obj : CGameObject ) : Boolean {
        this.characterBuilder.buildOtherSupported( obj );

        // 怪物死亡移除
        obj.addComponent( new CMonsterRemoval( this.characterBuilder.sceneHandler.removeMonster ) );
        return true;
    }

    protected function buildNetworking( obj : CGameObject ) : Boolean {
        this.characterBuilder.buildBaseNetworkingSupported( obj );
        return true;
    }

    protected function buildAppSystemSupported( obj : CGameObject ) : Boolean {
        this.characterBuilder.buildAppSystemSupported( obj );
        return true;
    }

} // class CMonsterBuilder

} // package kof.game.character

// vim:ft=as3 tw=120
