/**
 * Created by auto on 2016/5/17.
 */
package preview.game.levelServer {

import QFLib.Interface.IUpdatable;

import kof.framework.CAppSystem;

public class CLevelServerSystem extends CAppSystem implements IUpdatable {
    public function CLevelServerSystem() {
        super();
    }

    public override function dispose() : void {
        super.dispose();
    }
    // ====================================================================
    protected override function onSetup():Boolean {
        var ret:Boolean = super.onSetup();
        if (ret) {
            ret = ret && this.addBean(_server = new CLevelServer());
        }
        return ret;
    }

    public function update(delta:Number):void {
        if (_server) _server.update(delta);
    }
    // ====================================================================

    // server
    private var _server:CLevelServer;

}
}