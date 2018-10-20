//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.display {

import QFLib.Foundation.CPath;
import QFLib.Framework.CCharacter;
import QFLib.Graphics.Character.model.CEquipSkinsInfo;
import QFLib.Graphics.Character.model.ResUrlInfo;
import QFLib.Graphics.RenderCore.starling.display.DisplayObject;
import QFLib.Math.CAABBox2;
import QFLib.ResourceLoader.ELoadingPriority;

import kof.game.character.level.CLevelMediator;

import kof.game.character.level.CScenarioComponent;

import kof.game.character.property.CCharacterProperty;

import kof.game.character.property.interfaces.ICharacterProperty;
import kof.game.character.scene.CSceneMediator;
import kof.game.core.CGameComponent;

/**
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CBaseDisplay extends CGameComponent implements IDisplay {

    private var m_pModelDisplay : CCharacter;
    private var m_iDirection : int;
    private var m_iDirectionY : int;
    private var m_bDirectionDirty : Boolean;
    private var m_fScale : Number;
    private var m_bScaleDirty : Boolean;
    private var m_sSkin : String;
    private var m_sOutsiedName : String;
    // private var _sWeaponName:String;
    private var m_pResUrlInfo : ResUrlInfo;
    private var m_bReady : Boolean;
    private var m_pDefaultBound : CAABBox2;
    private var m_iLoadingPriority : int;

    public function CBaseDisplay( pDisplay : CCharacter = null ) {
        super( "display" );

        m_iLoadingPriority = ELoadingPriority.NORMAL;

        this.setDisplay( pDisplay );
    }

    override public function dispose() : void {
        super.dispose();

        if ( m_pModelDisplay ) {
            m_pModelDisplay.dispose();
        }
        m_pModelDisplay = null;

        if ( m_pResUrlInfo )
            m_pResUrlInfo.dispose();
        m_pResUrlInfo = null;

        m_pDefaultBound = null;
    }

    override protected virtual function onEnter() : void {
        super.onEnter();
    }

    override protected virtual function onDataUpdated() : void {
        super.onDataUpdated();

        if ( 'direction' in owner.data || owner.data.hasOwnProperty( 'direction' ) ) {
            this.direction = int( owner.data.direction );
        } else {
            this.direction = this.direction || 1;
        }

        this.directionY = this.directionY || 1;

        if ( property ) {
            this.skin = property.skinName;
            this.scale = property.size;
        } else {
            this.scale = 1.0;
        }

        if ( 'outsideName' in owner.data || owner.data.hasOwnProperty( 'outsideName' ) ) {
            this.outsideName = String( owner.data.outsideName );
        } else if ( property ) {
            this.outsideName = property.outsideName;
        }
    }

    override protected virtual function onExit() : void {
        super.onExit();

        if ( m_pModelDisplay )
            m_pModelDisplay.dispose();
        m_pModelDisplay = null;
    }

    final protected function get property() : CCharacterProperty {
        return getComponent( CCharacterProperty ) as CCharacterProperty;
    }

/// Testing structure.
    /// @{
    public function showQuaq( quad : DisplayObject, isShow : Boolean ) : void {
        if ( isShow )
            this.modelDisplay.characterObject.addQuad( quad );
        else
            this.modelDisplay.characterObject.removeQuad( quad );
    }

    /// @}

    final public function get modelDisplay() : CCharacter {
        return m_pModelDisplay;
    }

    /** Returns the direction of the display. */
    public function get direction() : int {
        return m_iDirection;
    }

    public function set direction( value : int ) : void {
        if ( this.direction == value )
            return;

        m_iDirection = value;
        m_bDirectionDirty = true;
    }

    public function get directionY() : int {
        return m_iDirectionY;
    }

    public function set directionY( value : int ) : void {
        if ( this.directionY == value )
            return;
        m_iDirectionY = value;
        m_bDirectionDirty = true;
    }

    final public function get isDirectionDirty() : Boolean {
        return m_bDirectionDirty;
    }

    public function get scale() : Number {
        return m_fScale;
    }

    public function set scale( value : Number ) : void {
        if ( this.scale == value )
            return;
        m_fScale = value;
        m_bScaleDirty = true;
    }

    public function get skin() : String {
        return m_sSkin;
    }

    public function set skin( value : String ) : void {
        if ( this.skin == value )
            return;
        this.m_sSkin = value;

        if ( this.m_pResUrlInfo )
            this.m_pResUrlInfo.dispose();
        this.m_pResUrlInfo = null;
    }

    public function set outsideName( value : String ) : void {
        if ( this.m_sOutsiedName == value || value == "" || !value )
            return;
        this.m_sOutsiedName = value;
    }

    public function get outsideName() : String {
        return m_sOutsiedName;
    }

//    public function set weapon( value : String ) : void {
//        if( this._sWeaponName == value || value == "" || !value )
//            return;
//        this._sWeaponName = value;
//    }

    [Inline]
    public function get weapon() : String {
        return property.weapon; // _sWeaponName;
    }


    [Inline]
    final public function getDisplay() : CCharacter {
        return m_pModelDisplay;
    }

    protected function setDisplay( value : CCharacter ) : void {
        if ( this.modelDisplay == value )
            return;
        this.m_pModelDisplay = value;

        if ( this.m_pResUrlInfo )
            this.m_pResUrlInfo.dispose();
        this.m_pResUrlInfo = null;
    }

    final public function get isReady() : Boolean {
        return m_bReady;
    }

    final public function setReady( value : Boolean ) : void {
        m_bReady = value;
    }

    [Inline]
    final public function shake( fIntensity : Number, fTimeDuration : Number ) : void {
        this.modelDisplay.shake( fIntensity, fTimeDuration );
    }

    [Inline]
    final public function shakeXY( fIntensityX : Number, fIntensityY : Number, fTimeDuration : Number, fPeriodTime : Number = 0.02 ) : void {
        this.modelDisplay.shakeXY( fIntensityX, fIntensityY, fTimeDuration, fPeriodTime );
    }

    public function getCharacterBaseURI() : String {
        return "";
    }

    public virtual function update( delta : Number ) : void {
        this.updateDisplay( delta );

        if ( m_bDirectionDirty ) {
            m_bDirectionDirty = false;
            modelDisplay.flipX = this.direction < 0;
            modelDisplay.flipY = this.directionY < 0;
        }

        if ( m_bScaleDirty ) {
            m_bScaleDirty = false;
            modelDisplay.setScale( this.scale, this.scale, this.scale );
        }
    }

    public function get modelCurrentBound() : CAABBox2 {
        return modelDisplay.currentBound;
    }

    public function get defaultBound() : CAABBox2 {
        return m_pDefaultBound;
    }

    public function set defaultBound( value : CAABBox2 ) : void {
        m_pDefaultBound = value;
    }

    protected function updateDisplay( delta : Number ) : void {
        var pModel : CCharacter = this.modelDisplay;

        if ( !m_pResUrlInfo ) {
            var fileName : String = new CPath( skin ).name;
            var outSidePath : String;
            var weaponPath : String;
            if ( skin ) {

                m_pResUrlInfo = new ResUrlInfo();
                m_pResUrlInfo.jsonUrl = getCharacterBaseURI() + skin + '/' + fileName;

                if ( outsideName != null && outsideName.length != 0 ) {
                    var subOutSideName : String = new CPath( outsideName ).name;
                    outSidePath = getCharacterBaseURI() + skin + '/' + subOutSideName;
                }

                var equipSkins : CEquipSkinsInfo;
                if ( weapon != null && weapon.length > 0 ) {
                    var subWeaponName : String = new CPath( weapon ).name;
                    weaponPath = getCharacterBaseURI() + skin + '/' + subWeaponName;
                    if ( weaponPath != null ) {
                        equipSkins = new CEquipSkinsInfo();
                        equipSkins.addEquip( 0, weaponPath );
                    }
                }


                setReady( false );
                var pInstanceFacade : CLevelMediator = owner.getComponentByClass( CLevelMediator, true ) as CLevelMediator;
                if ( pInstanceFacade && pInstanceFacade.isMainCity ) {
                    var loadingFxVec : Vector.<String> = new <String>[ "Idle_1", "Move_1" ];
                    pModel.loadFile( m_pResUrlInfo.jsonUrl, outSidePath, equipSkins, this.loadingPriority, _onResLoadFinished, _onCollisionLoadFinished, null, null, true, false, loadingFxVec );
                } else {
                    pModel.loadFile( m_pResUrlInfo.jsonUrl, outSidePath, equipSkins, this.loadingPriority, _onResLoadFinished, _onCollisionLoadFinished, null, null, true, true, null );
                }
            }
        }
    }

    public function get loadingPriority() : int {
        return m_iLoadingPriority;
    }

    public function set loadingPriority( value : int ) : void {
        m_iLoadingPriority = value;
    }

    protected function get pResUrlInfo() : ResUrlInfo {
        return m_pResUrlInfo;
    }

    protected function set pResUrlInfo( value : ResUrlInfo ) : void {
        m_pResUrlInfo = value;
    }

    public function get boInView() : Boolean {
        return false;
    }

    public function set boInView( isViewRange : Boolean ) : void {
    }

    protected function onResReady() : void {
//       onOutSindeNameChanged();
    }

    protected function onCollisionReady() : void {

    }

    protected function onOutSindeNameChanged() : void {

        if ( outsideName != null && outsideName.length != 0 ) {
            var subOutSideName : String = new CPath( outsideName ).name;
            modelDisplay.loadSkin( subOutSideName );
        }
    }

    protected function _onResLoadFinished( loader : *, idError : int ) : void {
        if ( idError == 0 ) {
            setReady( true );
            this.onResReady();
        }
    }

    protected function _onCollisionLoadFinished( loader : *, idError : int ) : void {
        if ( idError == 0 ) {
            this.onCollisionReady();
        }
    }

}
}

