//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Administrator on 2017/5/3.
 */
package kof.game.scenario.timeline.part {

import QFLib.Foundation;

import kof.framework.CAppSystem;
import kof.game.character.scripts.CMonsterSprite;
import kof.game.core.CGameObject;
import kof.game.scenario.info.CScenarioPartInfo;

public class CScenarioPartActorTopFace extends CScenarioPartActorBase {
    public function CScenarioPartActorTopFace( partInfo : CScenarioPartInfo, system : CAppSystem ) {
        super( partInfo, system );
    }


    override public virtual function dispose() : void {
        super.dispose();
    }

    override public virtual function update( delta : Number ) : void {
        super.update(delta);
    }

    override public virtual function start() : void {
        var faceName:String = _info.params["faceName"];
        var monster:CGameObject = this.getActor() as CGameObject;

        if( faceName && faceName != ""){
            var monsterSprite:CMonsterSprite = monster.getComponentByClass( CMonsterSprite, false ) as CMonsterSprite;
            monsterSprite.show( faceName );
        }else{
            Foundation.Log.logMsg( "剧情角色表情为空..." );
        }
        _actionValue = true;
    }

    override public virtual function end() : void {
        _actionValue = false;
    }

    override public virtual function isActionFinish() : Boolean {
        return _actionValue;
    }

    override public function stop() : void {
        super.stop();
    }
}
}
