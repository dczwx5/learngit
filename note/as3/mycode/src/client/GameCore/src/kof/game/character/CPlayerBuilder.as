//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character {

import QFLib.Framework.CFramework;
import QFLib.Interface.IDisposable;

import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.character.NPC.CNPCByPlayer;
import kof.game.character.NPC.CNPCTriggerMediator;
import kof.game.character.ai.CAIComponent;
import kof.game.character.fight.CAutoRecoveryComponent;
import kof.game.character.fight.skill.CSuperControlComponent;
import kof.game.character.fight.skillcalc.CFightCalc;
import kof.game.character.fight.skillcalc.hurt.CFightDamageComponent;
import kof.game.character.fight.skillcalc.hurt.CFightProperty;
import kof.game.character.fight.skillcalc.hurt.CProfessionRelation;
import kof.game.character.movement.CMoveInterpolation;
    import kof.game.character.movement.CNavigationViewDebug;
    import kof.game.character.property.CPlayerProperty;
import kof.game.character.scripts.CHeroAppear;
import kof.game.character.scripts.CHonorTitleSprite;
import kof.game.character.scripts.CHornorTitleComponent;
import kof.game.character.scripts.CPlayerInitializer;
import kof.game.character.scripts.CTXVipSprite;
import kof.game.core.CGameObject;
import kof.game.scene.ISceneFacade;
import kof.table.PlayerBasic;
import kof.table.PlayerSkill;
import kof.util.CAssertUtils;

/**
 * 基于CharacterBuilder之上构建Player的GameObject结构
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public final class CPlayerBuilder implements IDisposable {

    private var m_pCharacterBuilder : CCharacterBuilder;

    public function CPlayerBuilder( pCharacterBuilder : CCharacterBuilder = null ) {
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

    final public function get sceneFacade() : ISceneFacade{
        return this.characterBuilder.sceneFacade;
    }

    /**
     * Build the specific <code>obj</code>:CGameObject as a Player.
     *
     * @param obj the specific obj to build.
     * @return true if built successfully, false otherwise.
     */
    public function build( obj : CGameObject ) : Boolean {
        if ( !CCharacterDataDescriptor.isPlayer( obj.data ) ) {
            // isn't a valid monster data.
            CCharacterBuilder.LOG.logErrorMsg( "The specific data of CGameObject hasn't a legal data structure!" );
            return false;
        }

        CAssertUtils.assertNotNull( this.characterBuilder, "A CCharacterBuilder is required by CPlayerBuilder." );

        // Building the base components specify for Character.
        var ret : Boolean = true;

        ret = ret && this.buildProperties( obj );
        ret = ret && this.buildBasic( obj );
        ret = ret && this.buildInput( obj );
        ret = ret && this.buildState( obj );
        ret = ret && this.buildSkill( obj );
        ret = ret && this.buildRendering( obj );
        ret = ret && this.buildSubAnimation( obj );
//        ret = ret && this.buildAnimation( obj );
        ret = ret && this.buildOther( obj );
        ret = ret && this.buildNetworking( obj );
        ret = ret && this.buildAppSystemSupported( obj );
        ret = ret && this.buildAI( obj );
        ret = ret && this.buildNPC( obj );
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

    protected function buildNPC( obj : CGameObject ):Boolean{
        obj.addComponent( new CNPCByPlayer() );
        return true;
    }

    protected function buildProperties( obj : CGameObject ) : Boolean {
        // Nothing specific
        obj.addComponent( new CPlayerProperty() );
        obj.addComponent( new CProfessionRelation());
        obj.addComponent( new CFightCalc() );
        obj.addComponent( new CFightProperty() );
        obj.addComponent( new CFightDamageComponent());
        return true;
    }

    protected function buildBasic( obj : CGameObject ) : Boolean {
        this.characterBuilder.addBaseComponents( obj );
        this.characterBuilder.buildEventSupported( obj );
        if ( CCharacterDataDescriptor.isHero( obj.data ))
            obj.addComponent( new CHeroAppear() );
        else
            obj.addComponent( new CPlayerInitializer() );
        return true;
    }

    protected function buildState( obj : CGameObject ) : Boolean {
        // Nothing specific
        this.characterBuilder.buildStateSupported( obj );
        return true;
    }

    protected function buildSkill( obj : CGameObject ) : Boolean {
        this.characterBuilder.buildSkillSupported( obj );

        // Retrieves a skillList from the table "PlayerSkill".
        var pTablePlayerSkill : IDataTable = this.database.getTable( KOFTableConstants.PLAYER_SKILL );

        CAssertUtils.assertNotNull( pTablePlayerSkill, "DataTable \"Player\" required from CPlayerBuilder." );

        var prototypeID : int = CCharacterDataDescriptor.getPrototypeID( obj.data );
        CAssertUtils.assertNotEquals( 0, prototypeID, "A Player's data has illegal prototypeID." );

        var pPlayerSkill : PlayerSkill = pTablePlayerSkill.findByPrimaryKey( prototypeID );
        if ( pPlayerSkill ) {
            var pSkillList : CSkillList = obj.getComponentByClass( CSkillList, false ) as CSkillList;
            if ( pSkillList ) {
                var i : int = 0, l : int = pPlayerSkill.SkillID.length;
                for ( ; i < l; ++i ) {
                    var nSkillID : int = int( pPlayerSkill.SkillID[ i ] );
                    if ( nSkillID == 0 )
                        continue;

                    pSkillList.setSkillIDByIndex( i, nSkillID );
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
            const pTable : IDataTable = this.database.getTable( KOFTableConstants.PLAYER_BASIC );
            if ( pTable ) {
                var iPlayerID : int = CCharacterDataDescriptor.getPrototypeID( obj.data );
                CAssertUtils.assertNotEquals( 0, iPlayerID, "A Player's data has  illegal prototypeID." );

                var pPlayerObject : PlayerBasic = pTable.findByPrimaryKey( iPlayerID ) as PlayerBasic;
                if ( pPlayerObject ) {
                    sSkinName = pPlayerObject.SkinName;
                    ret = true;
                }
            }
        }

        CAssertUtils.assertTrue( sSkinName && sSkinName.length > 0, "Building a Player hadn't a valid skin, will can't be rendering correctly." );
        CCharacterDataDescriptor.setSkinName( obj.data, sSkinName );

        return ret;
    }

    protected function buildRendering( obj : CGameObject ) : Boolean {
        this.updateSkin( obj );
        this.characterBuilder.buildRenderingSupported( obj );
        return true;
    }

    protected function buildAnimation( obj : CGameObject ) : Boolean {
        this.characterBuilder.buildPhysicalSupported( obj );
        return true;
    }

    protected function buildSubAnimation( obj : CGameObject ) : Boolean {

        this.characterBuilder.buildPhysicalSupported( obj );
        return true;
    }

    protected function buildInput( obj : CGameObject ) : Boolean {
        this.characterBuilder.buildInputSupported( obj );
        return true;
    }

    protected function buildOther( obj : CGameObject ) : Boolean {
        this.characterBuilder.buildOtherSupported( obj );
        obj.addComponent( new CTXVipSprite( m_pCharacterBuilder.pPlayerHandle ) );
//        obj.addComponent( new CHonorTitleSprite( m_pCharacterBuilder.pPlayerHandle ));
        obj.addComponent( new CHornorTitleComponent());
        return true;
    }

    protected function buildNetworking( obj : CGameObject ) : Boolean {
        this.characterBuilder.buildNetworkingSupported( obj );
        obj.addComponent( new CMoveInterpolation() );
        return true;
    }

    protected function buildAppSystemSupported( obj : CGameObject ) : Boolean {
        this.characterBuilder.buildAppSystemSupported( obj );
        return true;
    }

    protected function buildOtherFightSupport( obj : CGameObject ) : Boolean{
        obj.addComponent( new CAutoRecoveryComponent());
        obj.addComponent( new CSuperControlComponent(  sceneFacade ));
        return true;
    }

} // class CPlayerBuilder

} // package kof.game.character

// vim:ft=as3 tw=120
