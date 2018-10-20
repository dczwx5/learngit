//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.scripts {

import QFLib.Framework.CCharacter;
import QFLib.Framework.CObject;
import QFLib.Framework.CTweener;
import QFLib.Graphics.Sprite.CSpriteText;
import QFLib.Math.CMath;
import QFLib.Math.CVector3;

import flash.events.Event;
import flash.geom.Rectangle;

import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;

import kof.game.character.display.IDisplay;
import kof.game.character.fight.CFightTextConst;
import kof.game.character.fight.emitter.CMasterCompomnent;
import kof.game.character.level.CLevelMediator;
import kof.game.core.CGameComponent;
import kof.game.level.ILevelFacade;

/**
 * 战斗飘字组件
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CFightFloatSprite extends CGameComponent {

    /**
     * Creates a new CFightFloatSprite.
     */
    private var m_pLevelMediator: CLevelMediator;
    public function CFightFloatSprite() {
        super();
    }

    override public function dispose() : void {
        super.dispose();
    }

    override protected virtual function onEnter() : void {
        super.onEnter();
        m_pLevelMediator = owner.getComponentByClass( CLevelMediator ,true ) as CLevelMediator;
    }

    override protected virtual function onDataUpdated() : void {
        super.onDataUpdated();
    }

    override protected virtual function onExit() : void {
        super.onExit();
    }

    final public function get display() : IDisplay {
        return getComponent( IDisplay ) as IDisplay;
    }

    /**
     * create a Number bubble String
     * @param value
     */
    public function createBubbleNumber( value : Number, tPosition : CVector3 = null,
                                        sAppareFont : String = "Numbers", sHighLightFont : String = "shinningnums",
                                        sApparePoolName : String = "DynamicNumberText", sHightLightPool : String = "DynamicShiningText", nfontSize : int = 40 ) : void {
        var modelDisplay : CCharacter = this.display.modelDisplay;
        var sp : CSpriteText = modelDisplay.belongFramework.spriteSystem.createSpriteFromPool( sApparePoolName ) as CSpriteText;
        if ( sp == null ) {
            sp = new CSpriteText( modelDisplay.belongFramework.spriteSystem, 256.0, 64.0, true );
        }
        sp.fontName = sAppareFont;
        sp.fontSize = nfontSize;

        var spShinning : CSpriteText = modelDisplay.belongFramework.spriteSystem.createSpriteFromPool( sHightLightPool ) as CSpriteText;
        if ( spShinning == null ) {
            spShinning = new CSpriteText( modelDisplay.belongFramework.spriteSystem, 256.0, 64, true );
            spShinning.fontName = sHighLightFont;//"shinningnums";
            spShinning.fontSize = nfontSize;
        }
        spShinning.text = value.toString();
        sp.text = value.toString();
        modelDisplay.theObject.parent.addChild( sp );
        modelDisplay.theObject.parent.addChild( spShinning );
        var vHeroPos : CVector3;
        var position : CVector3 = tPosition != null ? tPosition.clone() : null;
        if ( !position ) {
            vHeroPos = modelDisplay.theObject.position;
            vHeroPos.y = vHeroPos.z + 100;
        }
        else {
            vHeroPos = position;
            vHeroPos.y = position.y * CObject.TAN_THETA_OF_CAMERA;
            vHeroPos.z = position.z;
        }

        var delDeg : int = CMath.rand() * 180;
        var delR : int = 30;
        var deltX : int = CMath.cosDeg( delDeg ) * delR;
        var deltY : int = CMath.sinDeg( delDeg ) * delR;
        var delZ : Number = modelDisplay.theObject.position.z + 100;
        var keepAwayTrunkDel : Number = getXOffsetPerTrunk( vHeroPos.x + deltX );
        var retXPosition : Number = vHeroPos.x + deltX + keepAwayTrunkDel;
        sp.setPosition( retXPosition , vHeroPos.y - 350.0 + deltY, delZ );
        spShinning.setPosition( vHeroPos.x + deltX + keepAwayTrunkDel , vHeroPos.y - 350.0 + deltY, delZ );

        sp.opaque = 1.0;
        sp.setScale( 0.3, 0.3, 0.3 );
        spShinning.setScale( 2.0, 2.0, 2.0 );

//        modelDisplay.belongFramework.tweenSystem.addSequentialTweener( sp, CTweener.moveToXYZ, 0.0, 0.033, vHeroPos.x  + deltX, vHeroPos.y - 350.0 + deltY, delZ );
        modelDisplay.belongFramework.tweenSystem.addSequentialTweener( sp, CTweener.moveToXYZ, 0.0, 0.76, retXPosition , vHeroPos.y - 350.0 + deltY, delZ );
//        modelDisplay.belongFramework.tweenSystem.addParallelTweener( sp, CTweener.scaleToXYZ, 0.0, 0.033, 0.3 ,0.3,0.3 , true);
        modelDisplay.belongFramework.tweenSystem.addParallelTweener( sp, CTweener.scaleToXYZ, 0.033, 0.066, 1.0, 1.0, 1.0, true );
        modelDisplay.belongFramework.tweenSystem.addParallelTweener( sp, CTweener.opaqueTo, 0.0, 0.03, 0.0 );

//        modelDisplay.belongFramework.tweenSystem.addSequentialTweener( spShinning, CTweener.moveToXYZ, 0.0, 0.033, vHeroPos.x  + deltX, vHeroPos.y - 350.0 + deltY, delZ );
        modelDisplay.belongFramework.tweenSystem.addSequentialTweener( spShinning, CTweener.moveToXYZ, 0.033, 0.18, retXPosition , vHeroPos.y - 350.0 + deltY, delZ );
//        modelDisplay.belongFramework.tweenSystem.addParallelTweener( spShinning, CTweener.scaleToXYZ, 0.33, 0.066 , 3.0 , 3.0,3.0,true);
        modelDisplay.belongFramework.tweenSystem.addParallelTweener( spShinning, CTweener.opaqueTo, 0.033, 0.18, 0.0 );
        modelDisplay.belongFramework.tweenSystem.addParallelTweener( spShinning, CTweener.scaleToXYZ, 0.066, 0.18, 1.0, 1.0, 1.0, 1.0, true );
        modelDisplay.belongFramework.tweenSystem.addSequentialTweener( spShinning, CTweener.recycleObject, "DynamicShining" );

        //差高亮衰减
//        modelDisplay.belongFramework.tweenSystem.addParallelTweener( sp, CTweener.scaleToXYZ, 0.033, 0.066 , 3.0 , 3.0, 3.0,true);

        modelDisplay.belongFramework.tweenSystem.addParallelTweener( sp, CTweener.opaqueTo, 0.18, 0.20, 1.0 );
        modelDisplay.belongFramework.tweenSystem.addParallelTweener( sp, CTweener.scaleToXYZ, 0.066, 0.18, 1.0, 1.0, 1.0, 1.0, true );


        //^^^^^
        modelDisplay.belongFramework.tweenSystem.addParallelTweener( sp, CTweener.moveToXYZ, 0.18, 0.38,retXPosition , vHeroPos.y - 350.0 + deltY, delZ );
        modelDisplay.belongFramework.tweenSystem.addParallelTweener( sp, CTweener.moveToXYZ, 0.38, 0.76, retXPosition , vHeroPos.y - 380.0 + deltY, delZ );
        modelDisplay.belongFramework.tweenSystem.addParallelTweener( sp, CTweener.opaqueTo, 0.38, 0.76, 0.0 );

        modelDisplay.belongFramework.tweenSystem.addSequentialTweener( sp, CTweener.recycleObject, "DynamicNumberText" );

        /**
         modelDisplay.belongFramework.tweenSystem.addSequentialTweener( sp, CTweener.moveToXYZ, 0.0, 0.25, vHeroPos.x, vHeroPos.y - 350.0, vHeroPos.z + 100 );
         modelDisplay.belongFramework.tweenSystem.addParallelTweener( sp, CTweener.opaqueTo, 0.0, 0.25, 1.0 );
         modelDisplay.belongFramework.tweenSystem.addParallelTweener( sp, CTweener.opaqueTo, 0.35, 0.65, 0.0 );
         modelDisplay.belongFramework.tweenSystem.addParallelTweener( sp, CTweener.moveToXYZ, 0.25, 0.35, vHeroPos.x, vHeroPos.y - 350.0, vHeroPos.z + 100 );
         modelDisplay.belongFramework.tweenSystem.addParallelTweener( sp, CTweener.scaleToXYZ, 0.0, 0.25, 2.0, 2.0, 2.0, true );
         modelDisplay.belongFramework.tweenSystem.addParallelTweener( sp, CTweener.scaleToXYZ, 0.35, 0.65, 1.0, 1.0, 1.0, true );
         modelDisplay.belongFramework.tweenSystem.addParallelTweener( sp, CTweener.moveToXYZ, 0.35, 0.65, vHeroPos.x, vHeroPos.y - 450.0, vHeroPos.z + 100 );
         modelDisplay.belongFramework.tweenSystem.addSequentialTweener( sp, CTweener.recycleObject, "DynamicNumberText" );*/

    }

    private function getXOffsetPerTrunk( x : Number) : Number{
        if( !m_pLevelMediator ) return 0.0;
        var rect : Rectangle = m_pLevelMediator.getLevelCurTrunk();
        if( !rect ) return 0.0;
        if( x < rect.left ) return (rect.left - x );
        if( x > (rect.right - 100) ) return  -200.0;
        return 0.0;
    }

    public function createNumText( damage : int , boShowHeroStyle : Boolean , boCrit : Boolean = false , position : CVector3 = null) : void {


        if ( !boCrit ) {
            if ( boShowHeroStyle ) {
                createBubbleNumber( -damage,position );
            } else
                createBubbleNumber( -damage, position, CFightTextConst.EN_NUMBER, "shinningnums", CFightTextConst.EN_NUMBER_POOL, "DynamicShiningText" );
        } else {
            if ( boShowHeroStyle ) {
                createBubbleNumber( -damage, position,
                        CFightTextConst.CRITICAL_FONT, CFightTextConst.CRITICAL_HIGH_FONT, CFightTextConst.CRI_APPARE_POOL_NAME, CFightTextConst.CRI_SHINNING_POOL_NAME, 48 );
            } else {
                createBubbleNumber( -damage, position,
                        CFightTextConst.EN_CRITICALNUMBER, CFightTextConst.CRITICAL_HIGH_FONT, CFightTextConst.EN_CRITICAL_POOL, CFightTextConst.CRI_SHINNING_POOL_NAME, 48 );
            }
        }
    }

    public function createGreenNumText( value : int, position : CVector3 = null ) : void {
        var modelDisplay : CCharacter = this.display.modelDisplay;
        var sp : CSpriteText = modelDisplay.belongFramework.spriteSystem.createSpriteFromPool( "GreenNumsPool" ) as CSpriteText;
        if ( sp == null ) {
            sp = new CSpriteText( modelDisplay.belongFramework.spriteSystem, 256.0, 64.0, true );
            sp.fontName = "GreenNumbers";
            sp.fontSize = 40;
        }

        sp.text = value.toString();
        modelDisplay.theObject.parent.addChild( sp );

        var vHeroPos : CVector3;
        if ( !position ) {
            vHeroPos = modelDisplay.theObject.position;
            vHeroPos.y = vHeroPos.z + 100;
        }
        else {
            vHeroPos = position;
            vHeroPos.y = position.y * CObject.TAN_THETA_OF_CAMERA;
            vHeroPos.z = position.z;
        }

        var delDeg : int = CMath.rand() * 180;
        var delR : int = 30;
        var deltX : int = CMath.cosDeg( delDeg ) * delR;
        var deltY : int = CMath.sinDeg( delDeg ) * delR;
        var delZ : Number = modelDisplay.theObject.position.z + 100;
        var keepAwayTrunkDel : Number = getXOffsetPerTrunk( vHeroPos.x + deltX );
        var retXPosition : Number = vHeroPos.x + deltX + keepAwayTrunkDel;
        sp.setPosition( retXPosition  , vHeroPos.y - 350.0 + deltY, delZ );

        modelDisplay.belongFramework.tweenSystem.addSequentialTweener( sp, CTweener.moveToXYZ, 0.0, 0.25, retXPosition , vHeroPos.y - 350.0, vHeroPos.z + 100 );
        modelDisplay.belongFramework.tweenSystem.addParallelTweener( sp, CTweener.opaqueTo, 0.0, 0.25, 1.0 );
        modelDisplay.belongFramework.tweenSystem.addParallelTweener( sp, CTweener.opaqueTo, 0.35, 0.65, 0.0 );
        modelDisplay.belongFramework.tweenSystem.addParallelTweener( sp, CTweener.moveToXYZ, 0.25, 0.35, retXPosition, vHeroPos.y - 350.0, vHeroPos.z + 100 );
        modelDisplay.belongFramework.tweenSystem.addParallelTweener( sp, CTweener.scaleToXYZ, 0.0, 0.25, 1.5, 1.5, 1.5, true );
        modelDisplay.belongFramework.tweenSystem.addParallelTweener( sp, CTweener.scaleToXYZ, 0.35, 0.65, 1.0, 1.0, 1.0, true );
        modelDisplay.belongFramework.tweenSystem.addParallelTweener( sp, CTweener.moveToXYZ, 0.35, 0.65,retXPosition, vHeroPos.y - 450.0, vHeroPos.z + 100 );
        modelDisplay.belongFramework.tweenSystem.addSequentialTweener( sp, CTweener.recycleObject, "GreenNumsPool" );
    }

    public function createFightText( value : int, position : CVector3 = null ) : void {
        var modelDisplay : CCharacter = this.display.modelDisplay;
        var sp : CSpriteText = modelDisplay.belongFramework.spriteSystem.createSpriteFromPool( "DynamicpoFangText" ) as CSpriteText;
        if ( sp == null ) {
            sp = new CSpriteText( modelDisplay.belongFramework.spriteSystem, 256.0, 64.0, true );
            sp.fontName = "FightText";
            sp.fontSize = 48;
        }

        sp.text = value.toString();
        modelDisplay.theObject.parent.addChild( sp );

        var vHeroPos : CVector3;
        if ( !position )
            vHeroPos = modelDisplay.theObject.position;
        else
            vHeroPos = position;

        var xDel : Number = (sp.width) / 2;
        sp.setPosition( vHeroPos.x - xDel, vHeroPos.y - 250.0, vHeroPos.z + 100 );

        modelDisplay.belongFramework.tweenSystem.addSequentialTweener( sp, CTweener.moveToXYZ, 0.0, 0.15, vHeroPos.x - xDel, vHeroPos.y - 300.0, vHeroPos.z + 100 );
        modelDisplay.belongFramework.tweenSystem.addParallelTweener( sp, CTweener.scaleToXYZ, 0.0, 0.15, 1.5, 1.5, 1.5, true );
        modelDisplay.belongFramework.tweenSystem.addParallelTweener( sp, CTweener.moveToXYZ, 0.15, 0.65, vHeroPos.x - xDel, vHeroPos.y - 300.0, vHeroPos.z + 100 );
        modelDisplay.belongFramework.tweenSystem.addSequentialTweener( sp, CTweener.recycleObject, "DynamicpoFangText" );
    }
}
}

