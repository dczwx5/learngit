/**
 * Created by auto on 2016/5/30.
 */
package preview.game.levelServer {

import kof.game.levelCommon.info.event.CSceneEventInfo;
import kof.game.levelCommon.info.trunk.CTrunkConfigInfo;

public class CLevelServerTrunkData {
    public function CLevelServerTrunkData(rTrunkConfigInfo:CTrunkConfigInfo, rParent:CLevelServerTrunkData, rIsChildrenFinish:Boolean) {
        this.trunkInfo = rTrunkConfigInfo;
        this.parent = rParent;
        isChildrenFinish = rIsChildrenFinish;
        var isFindNextTrunk:Boolean = false;

        if (this.parent) {
            // 同级trunk
            isFindNextTrunk = _createNextTrunk(this.trunkInfo.passEvents, parent);
            if (!isFindNextTrunk) {
                // 同级trunk, 照理说。这个是不应该有的
                isFindNextTrunk = _createNextTrunk(this.trunkInfo.completeEvents, parent);
            }
            if (!isFindNextTrunk) {
                // 后面没有了 指向父trunk, 创建另一个父trunk对象, 主要为了让创建流程跑下去, 另外在处理state时, 也使用到
                this.nextTrunk = new CLevelServerTrunkData(parent.trunkInfo, null, true)// parent;
            }
        } else {
            // 有子trunk
            if (!isChildrenFinish) {
                isFindNextTrunk = _createNextTrunk(this.trunkInfo.passEvents, this);
            }
            if (!isFindNextTrunk) {
                // 同级trunk
                isFindNextTrunk = _createNextTrunk(this.trunkInfo.completeEvents, null);
            }
            if (!isFindNextTrunk) {
                // 后面没有了
                this.nextTrunk = null;
            }
        }
    }
    private function _createNextTrunk(events:Array, rParent:CLevelServerTrunkData) : Boolean {
        var nextTnkID:int;
        var nextTnkInfo:CTrunkConfigInfo;
        nextTnkID = _findNextTrunkID(events);
        if (-1 != nextTnkID) {
            nextTnkInfo = trunkInfo.getTrunkByID(nextTnkID);
            if (nextTnkInfo) {
                this.nextTrunk = new CLevelServerTrunkData(nextTnkInfo, rParent, false);
                return nextTrunk != null;
            }
        }
        return false;
    }
    private function _findNextTrunkID(events:Array) : int {
        var nextTrunkID:int = -1;
        if (!events || events.length == 0) return nextTrunkID;

        const NEXT_TRUNK_KEY:String = "OnActiveTrunk";
        for each (var e:CSceneEventInfo in events) {
            if (e.name == NEXT_TRUNK_KEY) {
                nextTrunkID = (int)(e.parameter);
                break;
            }
        }
        return nextTrunkID;
    }
    public function get isChildren() : Boolean {
        return parent != null;
    }

    // trunk100 -> trunk101 -> trunk102 ->trunk100 -> trunk200 -> trunk201 -> trunk200, （trunk结构）
    // 主trunk如果有子trunk, 链表中会有两个主trunk对象(且不是同一个对象), isChildrenFinish区别是否处理完子trunk
    public var parent:CLevelServerTrunkData; // 主trunk没parent, 子trunk有parent, 不是链表的前置节点
    public var nextTrunk:CLevelServerTrunkData; // 链表下一个节点
    public var trunkInfo:CTrunkConfigInfo;
    public var isChildrenFinish:Boolean; // 是否已经创建完子trunk回到父trunk, 这时候寻找completeEvent, 找同级trunk

}
}
