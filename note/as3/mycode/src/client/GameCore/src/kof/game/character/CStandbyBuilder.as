//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/3/15.
 */
package kof.game.character {

import QFLib.Framework.CFramework;
import QFLib.Interface.IDisposable;

import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.character.animation.CCharacterDisplay;
import kof.game.character.property.CPlayerProperty;
import kof.game.character.skin.CSkinDisplay;
import kof.game.core.CGameObject;
import kof.table.PlayerBasic;
import kof.util.CAssertUtils;

public class CStandbyBuilder implements IDisposable {

    private var m_pCharacterBuilder : CCharacterBuilder;

    public function CStandbyBuilder( pCharacterBuilder : CCharacterBuilder = null ) {
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
        if ( !CCharacterDataDescriptor.isStandby( obj.data ) ) {
            CCharacterBuilder.LOG.logErrorMsg( "The specific data of CGameObject hasn't a legal data structure!" );
            return false;
        }

        CAssertUtils.assertNotNull( this.characterBuilder, "A CCharacterBuilder is required by CBuffBuilder." );

        // Building the base components specify for Character.
        var ret : Boolean = true;
        ret = ret && this.buildProperties( obj );
        ret = ret && this.buildBasic( obj );
        ret = ret && this.buildState( obj );
        ret = ret && this.buildRendering( obj );
//        ret = ret && this.buildAppSystemSupported( obj );
//        ret = ret && this.buildInput( obj );
//        ret = ret && this.buildOther( obj );
        return ret;
    }

    protected function buildOther( obj : CGameObject ) : Boolean {
        this.characterBuilder.buildOtherSupported( obj );
        return true;
    }

    protected function buildInput( obj : CGameObject ) : Boolean {
    this.characterBuilder.buildInputSupported( obj );
        return true;
    }

    protected function buildState( obj : CGameObject ) : Boolean {
        // Nothing specific
        this.characterBuilder.buildStateSupported( obj );
        return true;
    }

    protected function buildAppSystemSupported( obj : CGameObject ) : Boolean {
        this.characterBuilder.buildAppSystemSupported( obj );
        return true;
    }

    protected function buildBasic( obj : CGameObject ) : Boolean {
        this.characterBuilder.addBaseComponents( obj );
        this.characterBuilder.buildEventSupported( obj );

        var pInit : CCharacterInitializer = new CCharacterInitializer();
        pInit.moveToAvailablePosition = false;
        obj.addComponent( pInit );
        return true;
    }

    protected function buildRendering( obj : CGameObject ) : Boolean {
        this.updateSkin( obj );
        obj.addComponent( new CSkinDisplay( this.characterBuilder.graphicsFramework ) );
        obj.addComponent( new CCharacterDisplay( this.characterBuilder.graphicsFramework ) );
        return true;
    }

    protected function buildSubAnimation( obj : CGameObject ) : Boolean {

        // this.characterBuilder.buildPhysicalSupported( obj );
        return true;
    }

    protected function buildProperties( obj : CGameObject ) : Boolean {
        // Nothing specific
        obj.addComponent( new CPlayerProperty() );
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
}
}
