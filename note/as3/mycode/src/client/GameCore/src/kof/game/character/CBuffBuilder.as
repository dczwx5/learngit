//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/2/18.
//----------------------------------------------------------------------
package kof.game.character {
import QFLib.Framework.CFramework;
import QFLib.Interface.IDisposable;
import kof.framework.IDatabase;
import kof.game.character.animation.CCharacterDisplay;
import kof.game.character.fight.buff.CBuffDisplay;
import kof.game.character.fight.emitter.CMasterCompomnent;
import kof.game.character.fight.emitter.CMissileBuilder;
import kof.game.character.fight.skillcalc.CFightCalc;
import kof.game.character.fight.skillcalc.hurt.CFightDamageComponent;
import kof.game.character.fight.skillcalc.hurt.CFightProperty;
import kof.game.character.property.CCharacterProperty;
import kof.game.character.property.CFromTargetProperty;
import kof.game.character.property.CBuffProperty;
import kof.game.character.property.CMonsterProperty;
import kof.game.character.property.CPlayerProperty;
import kof.game.character.scripts.CFightFloatSprite;
import kof.game.character.scripts.CMonsterAppear;
import kof.game.character.scripts.CPlayerIndexSprite;
import kof.game.character.scripts.CRootRingSpirte;
import kof.game.character.skin.CSkinDisplay;
import kof.game.core.CGameObject;
import kof.util.CAssertUtils;


public class CBuffBuilder implements IDisposable {
    private var m_pCharacterBuilder : CCharacterBuilder;
    public function CBuffBuilder( pCharacterBuilder : CCharacterBuilder = null ) {
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
        if ( !CCharacterDataDescriptor.isBuff( obj.data ) ) {
            CCharacterBuilder.LOG.logErrorMsg( "The specific data of CGameObject hasn't a legal data structure!" );
            return false;
        }

        CAssertUtils.assertNotNull( this.characterBuilder, "A CCharacterBuilder is required by CBuffBuilder." );

        // Building the base components specify for Character.
        var ret : Boolean = true;

        ret = ret && this.buildProperties( obj );
        ret = ret && this.buildBasic( obj );
        ret = ret && this.buildInput( obj );
        ret = ret && this.buildState( obj );
        ret = ret && this.buildSkill( obj );
        ret = ret && this.buildRendering( obj );
        ret = ret && this.buildSubAnimation( obj );
        ret = ret && this.buildOther( obj );
        ret = ret && this.buildNetworking( obj );
        ret = ret && this.buildAppSystemSupported( obj );

        return ret;
    }

    protected function buildProperties( obj : CGameObject ) : Boolean {
        // Nothing specific
        obj.addComponent( new CBuffProperty() );
        obj.addComponent( new CFightCalc() );
        obj.addComponent( new CFightProperty() );
        obj.addComponent( new CFightDamageComponent());
        return true;
    }

    protected function buildBasic( obj : CGameObject ) : Boolean {
        this.characterBuilder.addBaseComponents( obj );
        this.characterBuilder.buildEventSupported( obj );
        obj.addComponent( new CMonsterAppear() );
        return true;
    }

    protected function buildState( obj : CGameObject ) : Boolean {
        // Nothing specific
        this.characterBuilder.buildStateSupported( obj );
        return true;
    }

    protected function buildSkill( obj : CGameObject ) : Boolean {
        obj.addComponent( new CMasterCompomnent() );
        this.characterBuilder.buildSkillSupported( obj );
        return true;
    }

    protected function buildSubAnimation( obj : CGameObject ) : Boolean {

        this.characterBuilder.buildPhysicalSupported( obj );
        return true;
    }

    protected function buildRendering( obj : CGameObject ) : Boolean {
//        updateSkin( obj );
        obj.addComponent( new CSkinDisplay( m_pCharacterBuilder.graphicsFramework ) );
        obj.addComponent( new CBuffDisplay( m_pCharacterBuilder.graphicsFramework ) );
        obj.addComponent( new CFightFloatSprite() );
        return true;
    }

    public function updateSkin( obj : CGameObject, bForced : Boolean = true ) : Boolean {
        return false;
    }

    protected function buildInput( obj : CGameObject ) : Boolean {
        this.characterBuilder.buildInputSupported( obj );
        return true;
    }

    protected function buildOther( obj : CGameObject ) : Boolean {
        this.characterBuilder.buildOtherSupported( obj );
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
}
}
