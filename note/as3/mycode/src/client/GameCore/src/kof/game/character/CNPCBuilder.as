//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/1/9.
 */
package kof.game.character {

import QFLib.Framework.CFramework;
import QFLib.Interface.IDisposable;

import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.character.property.CNPCProperty;
import kof.game.character.scripts.CMonsterAppear;
import kof.game.character.scripts.CNPCAppear;
import kof.game.character.scripts.CTXVipSprite;
import kof.game.core.CGameObject;
import kof.table.NPC;
import kof.util.CAssertUtils;

/**
 * 基于CharacterBuilder之上构建NPC的GameObject结构
 *
 * @author Dendi
 */
public class CNPCBuilder implements IDisposable {
    private var m_pCharacterBuilder : CCharacterBuilder;

    public function CNPCBuilder( pCharacterBuilder : CCharacterBuilder = null ) {
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
     * Build the specific <code>obj</code>:CGameObject as a NPC.
     *
     * @param obj the specific obj to build.
     * @return true if built successfully, false otherwise.
     */
    public function build( obj : CGameObject ) : Boolean {
        if ( !CCharacterDataDescriptor.isNPC( obj.data ) ) {
            // isn't a valid npc data.
            CCharacterBuilder.LOG.logErrorMsg( "The specific data of CGameObject hasn't a legal data structure!" );
            return false;
        }

        CAssertUtils.assertNotNull( this.characterBuilder, "A CCharacterBuilder is required by CNPCBuilder." );

        // Building the base components specify for Character.
        var ret : Boolean = true;

        ret = ret && this.buildProperties( obj );
        ret = ret && this.buildBasic( obj );
        ret = ret && this.buildInput( obj );
        ret = ret && this.buildState( obj );
        ret = ret && this.buildRendering( obj );
        ret = ret && this.buildOther( obj );
//        ret = ret && this.buildNetworking( obj );
        ret = ret && this.buildAppSystemSupported( obj );
        ret = ret && this.buildNPC(obj);
        return ret;
    }

    protected function buildProperties( obj : CGameObject ) : Boolean {
        // Nothing specific
        obj.addComponent( new CNPCProperty() );
        return true;
    }

    protected function buildBasic( obj : CGameObject ) : Boolean {
        this.characterBuilder.addBaseComponents( obj );
        this.characterBuilder.buildEventSupported( obj );
        obj.addComponent( new CNPCAppear() );
        return true;
    }

    protected function buildState( obj : CGameObject ) : Boolean {
        // Nothing specific
        this.characterBuilder.buildStateSupported( obj );
        return true;
    }

    public function updateSkin( obj : CGameObject, bForced : Boolean = true ) : Boolean {
        var ret : Boolean = false;
        // Determines the skin in the obj.
        var sSkinName : String = CCharacterDataDescriptor.getSkinName( obj.data );
        if ( bForced || !sSkinName || sSkinName.length == 0 ) {
            // doesn't contains a valid skin, query the configure skin in the database.
            const pTable : IDataTable = this.database.getTable( KOFTableConstants.NPC );
            if ( pTable ) {
                var iNpcID : int = CCharacterDataDescriptor.getPrototypeID( obj.data );
                CAssertUtils.assertNotEquals( 0, iNpcID, "A NPC's data has  illegal prototypeID." );

                var pNPCObject : NPC = pTable.findByPrimaryKey( iNpcID ) as NPC;
                if ( pNPCObject ) {
                    sSkinName = pNPCObject.resource;
                    ret = true;
                }
            }
        }

        CAssertUtils.assertTrue( sSkinName && sSkinName.length > 0, "Builing a NPC hadn't a valid skin, will can't be rendering correctly." );
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
//        obj.addComponent( new CTXVipSprite( m_pCharacterBuilder.pPlayerHandle ) );
        return true;
    }

    protected function buildNPC( obj : CGameObject ) : Boolean {
        this.characterBuilder.buildNPCSupported( obj );
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

} // class CMapObjectBuilder

} // package kof.game.character
