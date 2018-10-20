/**
 * Created by auto on 2016/7/15.
 */
package kof.game.scenario.info {
import QFLib.Math.CVector2;

import kof.game.common.CCreateListUtil;
import kof.game.scenario.enum.EScenarioActorType;
import kof.game.scenario.enum.EScenarioPartType;

public class CScenarioInfo {
		public var scenarioId:int;
 		public var parts:Array; // 原来的actions 动作序列
		public var duration:Number; // 剧情总时间
		public var type:int; // EScenarioControlType 控制类型
		public var hideAvatar:int; // 开幕时隐藏玩家
		public var hideMonster:int; // 是否隐藏怪物
		public var hideAvatarEnd:int; // 剧情结束时是否隐藏玩家
		public var camera:CScenarioCameraInfo; //开场镜头

		public var isTeleport:Boolean = false;//剧情结束后是否瞬移（同步坐标问题）
		public var teleportVec2:CVector2 = new CVector2();//瞬移目标点
		public var teleportDir:int = 1;//瞬移后的朝向

		public var isESCEnable:Boolean = false;
		public var returnLevel:Boolean = true; // 剧情结束是否回到关卡

		public var actorList:Array; // 演员列表, 程序生成

		public function CScenarioInfo(data:Object) : void {
			scenarioId = data["scenarioId"];
			duration = data["duration"];
			type = data["type"];
			hideAvatar = data["hideAvatar"];
			hideMonster = data["hideMonster"];
			if(data.hasOwnProperty("hideAvatarEnd")){
				hideAvatarEnd = data["hideAvatarEnd"];
			}
			if(data.hasOwnProperty("isTeleport")){
				isTeleport = data["isTeleport"];
			}
			if(data.hasOwnProperty("teleportPosition")){
				teleportVec2.x = data["teleportPosition"]["x"];
				teleportVec2.y = data["teleportPosition"]["y"];
				teleportDir = data["teleportPosition"]["dir"];
			}
			if(data.hasOwnProperty("escEnable")){
				isESCEnable = data["escEnable"];
			}
			if(data.hasOwnProperty("returnLevel")){
				returnLevel = data["returnLevel"];
			}

			if(data.hasOwnProperty("camera"))camera = new CScenarioCameraInfo(data["camera"]);

			// 转换u3d出来的格式为客户端格式
			var srcPart:Array = data["parts"];
			var transPart:Array = new Array();
			//transPart = srcPart;
			//**
			actorList = new Array();
			var x:Number;
			var y:Number;
			var z:Number;
			var actorType:int;
			var actorID:int;
			var target:String; // 目标name, id等
			var start:Number;
			var isEvent:Boolean;
			var actorObject:CScenarioActorInfo;
			var campId:int = 0;
			for each (var partobj:Object in srcPart) {
				actorType = partobj["actorType"];
				actorID = partobj["actorID"];
				if(actorType == EScenarioActorType.SCENE_ANIMATION || actorType == EScenarioActorType.EFFECT){
					target = partobj["params"];//场景动画ID,特效ID
				}else{
					target = partobj["target"];
				}

				if(actorType == EScenarioActorType.MONSTER || actorType == EScenarioActorType.PLAYER){
					if(partobj.hasOwnProperty("campID")){
						campId = partobj["campID"];//阵营ID
					}
				}

				x = partobj["x"];
				y = partobj["y"];
				z = partobj["z"];
				actorObject = new CScenarioActorInfo({actorType:actorType, actorID:actorID, target:target, x:x, y:y, z:z, campID:campId});
				actorList.push(actorObject); // actor列表

				for each (var keyObject:Object in partobj["keys"]) {
					start = keyObject["start"];
					isEvent = keyObject["isEvent"];
					for each (var keyDataObject:Object in keyObject["keyData"]) {
						keyDataObject["actorType"] = actorType;
						keyDataObject["actorID"] = actorID;
						keyDataObject["start"] = start;
						keyDataObject["isEvent"] = isEvent;

						if( keyDataObject.hasOwnProperty("type") && keyDataObject["type"] == EScenarioPartType.ACTOR_APPEAR){
							actorObject.x = keyDataObject["params"]["x"];
							actorObject.y = keyDataObject["params"]["y"];
						}

						transPart.push(keyDataObject); // 动作列表
					}
				}
			}
			//*/

			parts = CCreateListUtil.createArrayData(transPart, CScenarioPartInfo);

			//
			//_exportNewPartJson(parts);
		}

	public function getPartTypeById( id:int ):int{
		for each(var partInfo:CScenarioPartInfo in parts){
			if( partInfo.id == id ){
				return partInfo.type;
			}
		}
		return 0;
	}

	public function getPartById( id:int ):CScenarioPartInfo{
		for each(var partInfo:CScenarioPartInfo in parts){
			if( partInfo.id == id ){
				return partInfo;
			}
		}
		return null;
	}

//	private function _exportNewPartJson(parts:Array) : void {
//		// export new json
//		var actorList:Object = new Object();
//		var obj:Object;
//		for each (var partInfo:CScenarioPartInfo in parts) {
//			if (actorList.hasOwnProperty(partInfo.actorID.toString()) == false) {
//				obj = new Object();
//				actorList[partInfo.actorID] = obj;
//				obj["actorType"] = partInfo.actorType;
//				obj["actorID"] = partInfo.actorID;
//			} else {
//				obj = actorList[partInfo.actorID];
//			}
//
//			//
//			if (partInfo.actorType == EScenarioActorType.MONSTER || partInfo.actorType == EScenarioActorType.SCENE_ANIMATION) {
//				if (partInfo.actorType == EScenarioActorType.MONSTER) {
//					if (partInfo.type == EScenarioPartType.ACTOR_APPEAR) {
//						obj["target"] = partInfo.params["monsterID"];
//						obj["x"] = partInfo.params["x"];
//						obj["y"] = partInfo.params["y"];
//					}
//				} else {
//					if (partInfo.type == EScenarioPartType.SCENE_ANIMATION_PLAY) {
//						obj["target"] = partInfo.params["animName"];
//					}
//				}
//			}
//
//			var keysArray:Array = obj["keys"];
//			if (keysArray == null) {
//				keysArray = obj["keys"] = new Array();
//			}
//
//			var start:Number = partInfo.start;
//			var keyObject:Object = null;
//			for each (var tempKeyObject:Object in keysArray) {
//				if (tempKeyObject["start"] == start) {
//					keyObject = tempKeyObject;
//					break;
//				}
//			}
//			if (!keyObject) {
//				keyObject = new Object();
//				keysArray.push(keyObject)
//				keyObject["start"] = start;
//			}
//
//			var keyData:Array = keyObject["keyData"];
//			if (keyData == null) {
//				keyData = new Array();
//				keyObject["keyData"] = keyData;
//			}
//
//			var keyDataObject:Object = new Object();
//			keyDataObject = partInfo.encode();
//			keyData.push(keyDataObject);
//		}
//
//		var exportList:Array = new Array();
//		for each (var actorObject:Object in actorList) {
//			exportList.push(actorObject);
//		}
//
//		var retObject:Object = new Object();
//		retObject["scenarioId"] = scenarioId;
//		retObject["type"] = type;
//		retObject["hideAvatar"] = hideAvatar;
//		retObject["hideMonster"] = hideMonster;
//		retObject["parts"] = exportList;
//
//		var ret:String = JSON.stringify(retObject);
//		trace(ret);
//	}
}
}