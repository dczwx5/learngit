/**
 * Created by auto on 2016/5/30.
 */
package preview.game.levelServer.trunkState {
import preview.game.levelServer.CLevelServer;

public class CLevelTrunkOverState extends CLevelTrunkState{
    public function CLevelTrunkOverState(server:CLevelServer) {
        super(_OVER, server)
    }
    protected override function inState() : void {
        super.inState();
        // 到这里就什么都不干了
    }
    public override function checkNextState():CLevelTrunkState {
        return this;
    }
}
}
