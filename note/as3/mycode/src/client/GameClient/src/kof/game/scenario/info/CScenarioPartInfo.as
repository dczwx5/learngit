/**
 * Created by auto on 2016/7/15.
 */
package kof.game.scenario.info {
import kof.game.common.CCreateListUtil;

public class CScenarioPartInfo {
	public var type:int; // EScenarioPartType
	public var id:int; // 只是一个序列ID, 每个part的ID不一样。递增

	public var actorType:int; // 演员类型 EScenarioActorType
	public var actorID:Number; // 演员ID
	// public var entityID:Number; // 怪物/特效/音效有意义
	// public var from:int; // EScenarioFromType, 演员是从关卡取还是从剧情取, 目前剧情只能控制剧情创建的怪物, 但是场景动画需要控制关卡或场景的, 对主角没意义

	public var appearType:int; /**@see ELevelAppearType*/
	public var start:Number; //
	public var duration:Number; // 持续时间为 -1，说明这个动作的结束不为时间轴控制。而是以动作播放的结束判断
	public var triggerAction:Array; // ?
	public var params:Object; // 不同type params的参数不同
	public var isEvent:Boolean;//说明这个动作不是时间轴控制的。而是其他动作结束了去启动。

	public var surrender:int; // 是否废弃 value : 0, 1
	public var autoDelete:int; // 动作结束时, 是否删除对象, default : 0, 1 : delete
	public var x:Number;
	public var y:Number;
	public var direction:int;//朝向

	public function CScenarioPartInfo(data:Object) {
		type = data["type"];
		id = data["id"];
		actorType = data["actorType"];
		actorID = data["actorID"];
		//entityID = data["entityID"];

		// from = data["from"];
		x = data["x"];
		y = data["y"];
		direction = data["direction"];

		appearType = data["appearType"];
		start = data["start"];
		isEvent = data["isEvent"];
		duration = data["duration"];
		triggerAction = CCreateListUtil.createArrayData(data["triggerAction"], CScenarioPartTriggerActionInfo);
		params = data["params"];

		surrender = data["surrender"];
		autoDelete = data["autoDelete"];

	}

	public function isStartByTimeLine() : Boolean {
		return !isEvent;
	}

	public function isDurationByTimeLine() : Boolean {
		return !(duration <= 0);
	}

	public function hasTriggerEvent() : Boolean {
		return triggerAction && triggerAction.length > 0;
	}

	public function encode() : Object {
		var obj:Object = new Object();
		obj["type"] = type;
		obj["id"] = id;
		obj["duration"] = duration;
		if (triggerAction) {
			obj["triggerAction"] = new Array();
			for each (var trigger:CScenarioPartTriggerActionInfo in triggerAction) {
				obj["triggerAction"].push(trigger.encode());
			}
		}
		if (params) obj["params"] = params;
		obj["surrender"] = surrender;

		return obj;
	}
}
}