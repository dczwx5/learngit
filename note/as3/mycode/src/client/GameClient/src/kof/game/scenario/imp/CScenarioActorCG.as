/**
 * Created by user on 2016/12/2.
 */
package kof.game.scenario.imp {
import QFLib.Graphics.Sprite.CSprite;
import QFLib.Interface.IDisposable;

public class CScenarioActorCG implements IDisposable{

    public var actorImg:CSprite;

    public function CScenarioActorCG() {
    }

    public function dispose() : void {
        if(actorImg)
        {
            actorImg.dispose();
        }

    }
}
}
