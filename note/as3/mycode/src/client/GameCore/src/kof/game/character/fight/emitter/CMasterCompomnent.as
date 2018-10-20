//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/10/14.
//----------------------------------------------------------------------
package kof.game.character.fight.emitter {

import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skillcalc.CFightCalc;
import kof.game.character.fight.skillcalc.CFightOthersCalc;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.scene.CSceneMediator;
import kof.game.core.CGameComponent;
import kof.game.core.CGameObject;

/**
 * 声明一个需要向其反馈响应的父组件
 */
public class CMasterCompomnent extends CGameComponent{
    public function CMasterCompomnent() {
        super("mastercomp" , true );
    }

    override protected function onEnter() : void {
        super.onEnter();
    }

    override protected function onDataUpdated() : void
    {
        super.onDataUpdated();
        if( owner.data && owner.data.hasOwnProperty( 'ownerId' )) {
            ownerId = owner.data.ownerId;
        }

        if( owner.data && owner.data.hasOwnProperty( 'ownerType' )) {
            ownerType = owner.data.ownerType;
        }

        if( owner.data && owner.data.hasOwnProperty( 'ownerSkin' )) {
            ownerSkin = owner.data.ownerSkin;
        }

        if( owner.data && owner.data.hasOwnProperty( 'aliasSkillID' )) {
            aliasSkillID = owner.data.aliasSkillID;
        }
    }

    override protected function onExit() : void {
        super.onExit()
    }

    public function attachFightTriggleEvent( fightEvent : CFightTriggleEvent) : void
    {
        if( masterFightTrigger )
                masterFightTrigger.dispatchEvent( fightEvent ) ; //new CFightTriggleEvent( fightEvent , null , [aliasSkillID] ));
    }

    public function attachHitContinue( isReset : Boolean ) : void{
        if( master )
        {
            var pFightCal : CFightCalc = master.getComponentByClass( CFightCalc , true ) as CFightCalc;
            if( pFightCal ){
                var otherCal : CFightOthersCalc = pFightCal.otherFightCalc;
                if( isReset ){
                    otherCal.boResetNext = false;
                }
                otherCal.increaseCHitWithCount( 1 );
            }
        }
    }

    final private function get masterFightTrigger() : CCharacterFightTriggle
    {
        if( master )
                return master.getComponentByClass( CCharacterFightTriggle , true ) as CCharacterFightTriggle;

        return null;
    }

    public final function get master() : CGameObject
    {
        return pSceneMediator.findGameObj( ownerType , ownerId );
    }

    private final function get pSceneMediator() : CSceneMediator
    {
        return owner.getComponentByClass( CSceneMediator , true ) as CSceneMediator;
    }

    public function get ownerId() : Number
    {
        return data.ownerId;
    }

    public function set ownerId( ownerId : Number ) : void{
        if( this.data.ownerId == ownerId )
            return;
        data.ownerId = ownerId;
    }

    public function get ownerType() : int{
        return data.ownerType;
    }

    public function set ownerType( value : int ) : void{
        if( data.ownerType == value )
            return ;
        data.ownerType = value;
    }

    public final function get ownerSkin() : String {

        return data.ownerSkin;
    }

    public function set ownerSkin(value : String ) : void{
        if( data.ownerSkin == value )
            return ;
        data.ownerSkin = value;
    }

    public final function get aliasSkillID() : int {

        return data.aliasSkillID;
    }

    public function set aliasSkillID(value : int ) : void{
        if( data.aliasSkillID == value )
            return ;
        data.aliasSkillID = value;
    }



}
}
