/**
 * Created by user on 2016/12/23.
 */
package kof.game.gm.command.instance {

import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;

public class CRemoveOneCampCommand extends CAbstractConsoleCommand {
    public function CRemoveOneCampCommand() {
        super();
        this.name = "removeOneCampObject";
        this.description = "杀死一个友方单位";
        this.label = "杀死一个友方单位";

        this.syncToServer = true;
    }
}
}
