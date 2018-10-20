//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/11/23.
//----------------------------------------------------------------------
package kof.game.character.scripts {

import QFLib.Foundation;
import QFLib.Framework.CCharacter;
import QFLib.Framework.CTweener;
import QFLib.Graphics.Sprite.CSpriteText;
import QFLib.Interface.IUpdatable;
import QFLib.Math.CVector3;

import flash.events.Event;

import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.character.display.IDisplay;
import kof.game.character.fight.CFightTextConst;
import kof.game.character.property.CMonsterProperty;
import kof.game.character.property.CPlayerProperty;
import kof.game.core.CGameComponent;
import kof.table.Monster.EMonsterType;

public class CPlayerIndexSprite extends CGameComponent implements IUpdatable {
    public function CPlayerIndexSprite( name : String = null, branchData : Boolean = false ) {
        super( name, branchData );
    }

    public function update( delta : Number ) : void {
        if ( !enabled )
            return;

        if ( m_makeDisapear )
            return;

        if ( !m_boShow && m_nShowIndex ) {
            __showPlayerIndex( m_nShowIndex );
            m_boShow = true;
        }

        var vHeroPos : CVector3 = this.display.modelDisplay.theObject.position;

        if ( m_boShow )
            m_elapsTime += delta;

        var v_fHeight : Number = 250.0;

        if ( this.display.defaultBound )
            v_fHeight = this.display.defaultBound.height;

        var pPlayerProperty : CPlayerProperty = this.getComponent( CPlayerProperty ) as CPlayerProperty;
        if ( pPlayerProperty ) {
            v_fHeight += pPlayerProperty.namedOffsetY;
        }

        if ( m_spIndext ) {
            // var xDel : Number = (m_spIndext.width) / 2;
            m_spIndext.setPosition( vHeroPos.x, vHeroPos.y - v_fHeight - 30, vHeroPos.z + 100 );
        }

        if ( m_spArrow ) {
            m_spArrow.setPosition( vHeroPos.x, vHeroPos.y - v_fHeight, vHeroPos.z + 133 );
        }

        if ( m_elapsTime >= M_LIVETIME ) {
            var modelDisplay : CCharacter = this.display.modelDisplay;
            modelDisplay.belongFramework.tweenSystem.addParallelTweener( m_spIndext, CTweener.opaqueTo, 0.35, 0.65, 0.0 );
            modelDisplay.belongFramework.tweenSystem.addSequentialTweener( m_spIndext, CTweener.recycleObject, "DynamicPlayerIndexText" );
            modelDisplay.belongFramework.tweenSystem.addParallelTweener( m_spArrow, CTweener.opaqueTo, 0.35, 0.65, 0.0 );
            modelDisplay.belongFramework.tweenSystem.addSequentialTweener( m_spArrow, CTweener.recycleObject, "DynamicArrowText" );
            m_makeDisapear = true;
        }
    }

    override public function set enabled( value : Boolean ) : void {
        if ( value != enabled ) {
            if ( m_spIndext )
                m_spIndext.visible = value;
            if ( m_spArrow )
                m_spArrow.visible = value;
            super.enabled = value;
        }

    }

    private function setOperator() : void {
        var nShowIndex : *;
        if ( objType == CCharacterDataDescriptor.TYPE_PLAYER ) {
            if ( objOperateSide == 1 ) {
                switch ( objOperateIndex ) {
                    case 1:
                        nShowIndex = CFightTextConst.P1_SELF;
                        break;
                    case 2:
                        nShowIndex = CFightTextConst.P2_SELF;
                        break;
                    case 3:
                        nShowIndex = CFightTextConst.P3_SELF;
                        break;
                }
            } else {
                switch ( objOperateIndex ) {
                    case 1:
                        nShowIndex = CFightTextConst.P1_ENEMY;
                        break;
                    case 2:
                        nShowIndex = CFightTextConst.P2_ENEMY;
                        break;
                    case 3 :
                        nShowIndex = CFightTextConst.P3_ENEMY;
                        break;
                }
            }
        } else if ( objType == CCharacterDataDescriptor.TYPE_MONSTER ) {
            var pMonsterPro : CMonsterProperty = owner.getComponentByClass( CMonsterProperty, true ) as CMonsterProperty;
            if ( pMonsterPro.monsterType == EMonsterType.BOSS || pMonsterPro.monsterType == EMonsterType.WORLD_BOSS)
                nShowIndex = CFightTextConst.SIGN_BOSS;
        }


        if ( nShowIndex > 0 || nShowIndex is String ) {
            m_nShowIndex = nShowIndex;
        }
    }

    public function resetShow() : void {
        m_boShow = false;
        m_nShowIndex = 0;
        m_elapsTime = 0;
        m_makeDisapear = false;
    }

    override public function dispose() : void {
        super.dispose();

        if ( m_spIndext && !m_spIndext.isRecycled() && !m_spIndext.disposed )
            m_spIndext.recycle();
        m_spIndext = null;

        if ( m_spArrow && !m_spArrow.isRecycled() && !m_spArrow.disposed )
            m_spArrow.recycle();
        m_spArrow = null;
    }

    final private function get objType() : int {
        return CCharacterDataDescriptor.getType( owner.data );
    }

    final private function get objOperateSide() : int {
        return CCharacterDataDescriptor.getOperateSide( owner.data );
    }

    final private function get objOperateIndex() : int {
        return CCharacterDataDescriptor.getOperateIndex( owner.data );
    }

    override protected virtual function onEnter() : void {
        super.onEnter();

        pEventMediator.addEventListener( CCharacterEvent.INSTANCE_STARTED, _onShow );
    }

    override protected virtual function onDataUpdated() : void {
        super.onDataUpdated();
    }

    override protected virtual function onExit() : void {
        super.onExit();

        if ( m_spIndext && !m_spIndext.isRecycled() && !m_spIndext.disposed )
            m_spIndext.recycle();
        m_spIndext = null;

        if ( m_spArrow && !m_spArrow.isRecycled() && !m_spArrow.disposed )
            m_spArrow.recycle();
        m_spArrow = null;

        m_nShowIndex = 0;
        m_boShow = false;
        m_elapsTime = 0;

        if ( pEventMediator )
            pEventMediator.removeEventListener( CCharacterEvent.INSTANCE_STARTED, _onShow );
    }

    private function __showPlayerIndex( type : * ) : void {
        var arrowType : String;
        switch ( type ) {
            case CFightTextConst.P1_SELF:
            case CFightTextConst.P2_SELF:
            case CFightTextConst.P3_SELF:
                arrowType = CFightTextConst.ARROW_SELF;
                break;
            case CFightTextConst.P1_ENEMY:
            case CFightTextConst.P2_ENEMY:
            case CFightTextConst.P3_ENEMY:
                arrowType = CFightTextConst.ARROW_ENEMY;
                break;
            case CFightTextConst.P1_MATE:
            case CFightTextConst.P2_MATE:
            case CFightTextConst.P3_MATE:
                arrowType = CFightTextConst.ARROW_MATE;
                break;
            case CFightTextConst.SIGN_BOSS:
                arrowType = CFightTextConst.ARROW_BOSS;
                break;
        }

        if ( arrowType != null ) {
            _showWholePlayerIndex( type, arrowType );
        } else {
            _showWholePlayerIndex( type, null );
        }
    }

    private function _onShow( e : Event ) : void {
        setOperator();
    }

    private function _showWholePlayerIndex( type : *, arrow : String ) : void {
        var modelDisplay : CCharacter = this.display.modelDisplay;
        var sp : CSpriteText = modelDisplay.belongFramework.spriteSystem.createSpriteFromPool( "DynamicPlayerIndexText" ) as CSpriteText;
        if ( sp == null ) {
            sp = new CSpriteText( modelDisplay.belongFramework.spriteSystem, 256.0, 64.0, true );
            sp.fontName = "FightText";
            sp.fontSize = 48;
        }

        sp.text = type.toString();
        modelDisplay.theObject.parent.addChild( sp );

        if ( m_spIndext != null )
            m_spIndext.recycle ();
        m_spIndext = sp;

        if ( arrow != null ) {
            var arraySp : CSpriteText = modelDisplay.belongFramework.spriteSystem.createSpriteFromPool( "DynamicArrowText" ) as CSpriteText;
            if ( arraySp == null ) {
                arraySp = new CSpriteText( modelDisplay.belongFramework.spriteSystem, 256.0, 64.0, true );
                arraySp.fontName = "FightText";
                arraySp.fontSize = 48;
            }

            arraySp.text = arrow;
            modelDisplay.theObject.parent.addChild( arraySp );

            if( m_spArrow != null )
                m_spArrow.recycle();
            m_spArrow = arraySp;
        }
    }

    final private function get pEventMediator() : CEventMediator {
        return owner.getComponentByClass( CEventMediator, true ) as CEventMediator;
    }

    final public function get display() : IDisplay {
        return getComponent( IDisplay ) as IDisplay;
    }

    private var m_spIndext : CSpriteText;
    private var m_spArrow : CSpriteText;
    private var m_boShow : Boolean;
    private var m_nShowIndex : int;
    private var m_makeDisapear : Boolean;
    private const M_LIVETIME : Number = 3.0;
    private var m_elapsTime : Number = 0.0;
}
}
