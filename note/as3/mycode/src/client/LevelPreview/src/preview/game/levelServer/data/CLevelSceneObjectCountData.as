/**
 * Created by Administrator on 2016/9/20.
 */
package preview.game.levelServer.data {
import flash.utils.getTimer;

// 数量数据, 用于monsterTrigger
public class CLevelSceneObjectCountData {
    public function CLevelSceneObjectCountData() {
    }

    public function clear() : void {
        _addCount = 0;
        _removeCount = 0;
        _countChangeTime = -1;
        _currentCount = 0;
    }


    public function add(v:int) : void {
        _addCount += v;
        _currentCount++;
        _changeTime(getTimer());

    }
    public function remove(v:int) : void {
        _removeCount += v;
        _currentCount--;
        _changeTime(getTimer());
    }

    public function removeCurrentCount(v:int):void{
        _currentCount--;
        _changeTime(getTimer());
    }

    private function _changeTime(v:int) : void {
        _countChangeTime = v;
    }
    public function get addCount() : int {
        return _addCount;
    }
    public function get removeCount() : int {
        return _removeCount;
    }
    public function get countChangeTime() : int {
        return _countChangeTime;
    }
    public function get currentCount() : int {
        return _currentCount;
    }

    public function clone() : CLevelSceneObjectCountData {
        var data:CLevelSceneObjectCountData = new CLevelSceneObjectCountData();
        data._addCount = _addCount;
        data._removeCount = _removeCount;
        data._countChangeTime = _countChangeTime;
        data._currentCount = _currentCount;
        return data;
    }


    private var _addCount:int; // 已增加多少
    private var _removeCount:int; // 已减少多少
    private var _countChangeTime:int; // 怪物数量改变时间点

    private var _currentCount:int;
}
}
