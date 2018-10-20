/**
 * Created by Maniac on 2017/4/11.
 */
package kof.game.gm.command.marquee {

import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;

/**
 * GM指令 广播走马灯消息
 */
public class CMarqueeMsgCommand extends CAbstractConsoleCommand {

    public function CMarqueeMsgCommand( name : String = null, desc : String = null, label : String = null ) {
        super();

        this.name = "marquee_msg";
        this.description = "GM广播消息（走马灯），Usage:" + this.name + "  要发送内容";
        this.label = "GM广播消息（走马灯）";

        this.syncToServer = true;
    }
}
}
