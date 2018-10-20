//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/8/8.
 */
package kof.game.scenario.timeline.part {

import QFLib.Framework.CObject;
import QFLib.Math.CVector3;

import kof.framework.CAppSystem;
import kof.game.character.CFacadeMediator;
import kof.game.character.animation.CCharacterDisplay;
import kof.game.character.display.IDisplay;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.core.CGameObject;
import kof.game.scenario.enum.EScenarioActorType;
import kof.game.scenario.info.CScenarioPartInfo;

public class CScenarioPartActorAppear extends CScenarioPartActorBase {
    public function CScenarioPartActorAppear(partInfo:CScenarioPartInfo, system:CAppSystem) {
        super (partInfo, system);
    }
    public override function dispose() : void {
        _actionValue = false;
    }
    public override function start() : void {
        var monster:CGameObject = this.getActor() as CGameObject;
        (monster.getComponentByClass(CCharacterDisplay, false) as CCharacterDisplay).modelDisplay.visible = true;

//        if (_info.actorType == EScenarioActorType.MONSTER) {
//            var pStateBoard : CCharacterStateBoard = monster.getComponentByClass(
//                            CCharacterStateBoard, true ) as CCharacterStateBoard;
//            if ( pStateBoard ) {
//                pStateBoard.setValue( CCharacterStateBoard.CAN_BE_ATTACK, true );
//                pStateBoard.setValue( CCharacterStateBoard.CAN_BE_CATCH, true );
//            }
//        }


        if(_info.params.hasOwnProperty("shadow")){
            var isShadow:Boolean = _info.params["shadow"];
            if(!isShadow){
                (monster.getComponentByClass(IDisplay,false) as IDisplay).modelDisplay.castShadow = false;//隐藏影子
            }
        }

        var dir:int = _info.params["direction"];
        // 右1， 左-1
        if ((monster.getComponentByClass(CFacadeMediator, false) as CFacadeMediator)){
            if( dir >= 0 ) dir = 1;
            (monster.getComponentByClass(CFacadeMediator, false) as CFacadeMediator).setDisplayDirection(dir);
        }
        _actionValue = true;
    }
    public override function end() : void {
        _actionValue = false;
    }

    public override function update(delta:Number) : void {
        super.update(delta);
    }
    public override function isActionFinish() : Boolean {
        return _actionValue;
    }

}
}
