/**
 * Created by Administrator on 2017/4/20.
 */
package kof.game.gm.command.instance {

import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;

public class CPassAllInstanceCommand extends CAbstractConsoleCommand {
    public function CPassAllInstanceCommand() {
        super();

        this.name = "pass_all_instance";
        this.description = "请求通过所有副本";
        this.label = "通过所有副本";

        this.syncToServer = true;
    }
}
}
