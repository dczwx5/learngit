/**
 * Created by auto on 2016/5/30.
 */
package preview.game.levelServer.trunkState {
import preview.game.levelServer.CLevelServer;

public class CLevelTrunkUnreadyState extends CLevelTrunkState {
    public function CLevelTrunkUnreadyState(server:CLevelServer) {
        super(_UNREADY, server);
    }
    protected override function inState() : void {
        super.inState();
    }
    public override function checkNextState():CLevelTrunkState {
        return new CLevelTrunkActiveState(_server);
    }
}
}
