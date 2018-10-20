//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Administrator on 2017/4/5.
 */
package kof.game.scenario.timeline.part {
import QFLib.Math.CVector2;

import kof.framework.CAppSystem;
import kof.game.character.CFacadeMediator;
import kof.game.character.fight.skill.CSkillCaster;
import kof.game.core.CGameObject;
import kof.game.core.CGameObject;
import kof.game.scenario.info.CScenarioPartInfo;

public class CScenarioPartActorTeleportation extends CScenarioPartActorBase {
    public function CScenarioPartActorTeleportation(partInfo:CScenarioPartInfo, system:CAppSystem) {
        super(partInfo, system);
    }

    public override function dispose() : void {
        _actionValue = false;
    }
    public override function start() : void {
        _actionValue = true;

        var monster:CGameObject = this.getActor() as CGameObject;
        var isPosition:Boolean = _info.params["isPosition"];
        var x:Number = _info.params["x"];
        var y:Number = _info.params["y"];
        var targetID:Number = _info.params["actorID"];

        if(_info.params.hasOwnProperty("dir")){
            _dir = _info.params["dir"];
        }
        if( isPosition ){
            //如果是瞬移到目标点position
            _teleportToPosition( monster , new CVector2( x , y ));
        }else{
            //如果是瞬移到目标actor
            var target : CGameObject = _scenarioManager.actorManager.getActor(targetID) as CGameObject;
            if( target ){
                _teleportToTarget( monster , target );
            }
        }
    }

    private function _teleportToPosition( target : CGameObject , position : CVector2 ) : void
    {
        var pSkillCaster : CSkillCaster = target.getComponentByClass( CSkillCaster , true ) as CSkillCaster;
        pSkillCaster.castTeleportToPosition( 10000 , position , _teleportEnd);
    }

    private function _teleportToTarget( target : CGameObject , desTarget : CGameObject ) : void
    {
        var pSkillCaster : CSkillCaster = target.getComponentByClass( CSkillCaster , true ) as CSkillCaster;
        pSkillCaster.castTeleportToTarget( 10086 , desTarget , _teleportEnd );
    }

    private function _teleportEnd() : void
    {
        var monster:CGameObject = this.getActor() as CGameObject;
        var facedeMediator:CFacadeMediator = monster.getComponentByClass(CFacadeMediator, false) as CFacadeMediator;
        // 右1， 左-1
        if (facedeMediator){
            facedeMediator.setDisplayDirection( _dir );
        }
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

    private var _dir:int = 1;
}
}
