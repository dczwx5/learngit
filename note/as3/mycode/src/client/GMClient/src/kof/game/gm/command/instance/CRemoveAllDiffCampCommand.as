/**
 * Created by user on 2016/12/23.
 */
package kof.game.gm.command.instance {

import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;

public class CRemoveAllDiffCampCommand extends CAbstractConsoleCommand {
    public function CRemoveAllDiffCampCommand() {
        super();
        this.name = "removeAllDiffCampObject";
        this.description = "杀死所有敌方单位";
        this.label = "杀死所有敌方单位";

        this.syncToServer = true;
    }
}
}
