/**
 * Created by user on 2016/12/23.
 */
package kof.game.gm.command.instance {

import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;

public class CRemoveOneDiffCampCommand extends CAbstractConsoleCommand {
    public function CRemoveOneDiffCampCommand() {
        super();
        this.name = "removeOneDiffCampObject";
        this.description = "杀死一个敌方单位";
        this.label = "杀死一个敌方单位";

        this.syncToServer = true;
    }
}
}
