/**
 * Created by Administrator on 2017/4/11.
 */
package kof.game.gm.command.marquee {

import kof.game.gm.command.gmaeCore.CAbstractCommandHandler;

/**
 *
 */
public class CMarqueeCommandHandler extends CAbstractCommandHandler {
    public function CMarqueeCommandHandler() {
        super();
    }

    override public function dispose() : void {
        super.dispose();
    }

    override protected virtual function onSetup() : Boolean {

        var ret : Boolean = super.onSetup();
        ret = ret && this.registerConsoleCommand( new CMarqueeMsgCommand());

        return ret;
    }
}
}
