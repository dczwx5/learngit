/**
 * Created by user on 2016/12/23.
 */
package kof.game.gm.command.instance {

import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;


public class CRemoveAllCampCommand extends CAbstractConsoleCommand {
    public function CRemoveAllCampCommand() {
        super();
        this.name = "removeAllCampObject";
        this.description = "杀死所有友方单位";
        this.label = "杀死所有友方单位";
        this.syncToServer = true;
    }
}
}
