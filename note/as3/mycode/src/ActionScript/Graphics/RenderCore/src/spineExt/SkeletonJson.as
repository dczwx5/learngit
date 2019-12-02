/**
 * (C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
 * Created on 2016/5/11.
 */
package spineExt
{
	import QFLib.Foundation;

import cmodule.hookOggVorbisLib.gvglpixels;

import flash.system.MessageChannelState;

import flash.utils.ByteArray;

	import spine.BlendMode;

	import spine.BoneData;
	import spine.Event;
	import spine.EventData;
	import spine.IkConstraintData;

	import spine.SkeletonData;

	import spine.SkeletonJson;
	import spine.Skin;
	import spine.SlotData;
	import spine.TransformConstraintData;

	import spine.animation.Animation;
	import spine.animation.AttachmentTimeline;
	import spine.animation.ColorTimeline;
    import spine.animation.CurveTimeline;
    import spine.animation.DrawOrderTimeline;
	import spine.animation.EventTimeline;
	import spine.animation.FfdTimeline;
	import spine.animation.IkConstraintTimeline;
	import spine.animation.RotateTimeline;
	import spine.animation.ScaleTimeline;
	import spine.animation.Timeline;
	import spine.animation.TranslateTimeline;
	import spine.attachments.Attachment;
	import spine.attachments.AttachmentLoader;
	import spine.attachments.AttachmentType;
	import spine.attachments.BoundingBoxAttachment;
import spine.attachments.FfdAttachment;

import spineExt.TimeLineCache.ColorTimelineInCache;
import spineExt.TimeLineCache.FfdTimelineInCache;
import spineExt.TimeLineCache.RotateTimelineInCache;
import spineExt.TimeLineCache.ScaleTimelineIncache;
import spineExt.TimeLineCache.TimelineCache;
import spineExt.TimeLineCache.TranslateTimelineInCache;

import spineExt.starling.MeshAttachment;
	import spineExt.starling.RegionAttachment;
	import spineExt.starling.StarlingAtlasAttachmentLoader;
	import spineExt.starling.WeightedMeshAttachment;

	public class SkeletonJson extends spine.SkeletonJson
	{
		public function SkeletonJson(attachmentLoader:AttachmentLoader = null)
		{
			super(attachmentLoader);
		}

		public function dispose():void
		{
		}

		public function createSkeletonData (object:*, skinName : String, skeletonDataName:String = null) : SkeletonData
		{
			if (object == null) throw new ArgumentError("object cannot be null.");

			var root:Object;
			if (object is String)
				root = JSON.parse(String(object));
			else if (object is ByteArray)
				root = JSON.parse(ByteArray(object).readUTFBytes(ByteArray(object).length));
			else if (object is Object)
				root = object;
			else
				throw new ArgumentError("object must be a String, ByteArray or Object.");

			var skeletonData:SkeletonData = new SkeletonData();
			skeletonData.name = skeletonDataName;

			// Skeleton.
			var skeletonMap:Object = root["skeleton"];
			if (skeletonMap) {
				skeletonData.hash = skeletonMap["hash"];
				skeletonData.version = skeletonMap["spine"];
				skeletonData.width = skeletonMap["width"] || 0;
				skeletonData.height = skeletonMap["height"] || 0;
			}

			// Bones.
			var boneData:BoneData;
			for each (var boneMap:Object in root["bones"]) {
				var parent:BoneData = null;
				var parentName:String = boneMap["parent"];
				if (parentName) {
					parent = skeletonData.findBone(parentName);
					if (!parent) throw new Error("Parent bone not found: " + parentName);
				}
				boneData = new BoneData(boneMap["name"], parent);
				boneData.length = Number(boneMap["length"] || 0) * scale;
				boneData.x = Number(boneMap["x"] || 0) * scale;
				boneData.y = Number(boneMap["y"] || 0) * scale;
				boneData.rotation = (boneMap["rotation"] || 0);
				boneData.scaleX = boneMap.hasOwnProperty("scaleX") ? boneMap["scaleX"] : 1;
				boneData.scaleY = boneMap.hasOwnProperty("scaleY") ? boneMap["scaleY"] : 1;
				boneData.inheritScale = boneMap.hasOwnProperty("inheritScale") ? boneMap["inheritScale"] : true;
				boneData.inheritRotation = boneMap.hasOwnProperty("inheritRotation") ? boneMap["inheritRotation"] : true;
				skeletonData.bones[skeletonData.bones.length] = boneData;
			}

			// IK constraints.
			for each (var ikMap:Object in root["ik"]) {
				var ikConstraintData:IkConstraintData = new IkConstraintData(ikMap["name"]);

				for each (var boneName:String in ikMap["bones"]) {
					var bone:BoneData = skeletonData.findBone(boneName);
					if (!bone) throw new Error("IK bone not found: " + boneName);
					ikConstraintData.bones[ikConstraintData.bones.length] = bone;
				}

				ikConstraintData.target = skeletonData.findBone(ikMap["target"]);
				if (!ikConstraintData.target) throw new Error("Target bone not found: " + ikMap["target"]);

				ikConstraintData.bendDirection = (!ikMap.hasOwnProperty("bendPositive") || ikMap["bendPositive"]) ? 1 : -1;
				ikConstraintData.mix = ikMap.hasOwnProperty("mix") ? ikMap["mix"] : 1;

				skeletonData.ikConstraints[skeletonData.ikConstraints.length] = ikConstraintData;
			}

			// Transform constraints.
			for each (var transformMap:Object in root["transform"]) {
				var transformConstraintData:TransformConstraintData = new TransformConstraintData(transformMap["name"]);

				transformConstraintData.bone = skeletonData.findBone(transformMap["bone"]);
				if (!transformConstraintData.bone) throw new Error("Bone not found: " + transformMap["bone"]);

				transformConstraintData.target = skeletonData.findBone(transformMap["target"]);
				if (!transformConstraintData.target) throw new Error("Target bone not found: " + transformMap["target"]);

				transformConstraintData.translateMix = transformMap.hasOwnProperty("translateMix") ? transformMap["translateMix"] : 1;
				transformConstraintData.x = Number(boneMap["x"] || 0) * scale;
				transformConstraintData.y = Number(boneMap["y"] || 0) * scale;

				skeletonData.transformConstraints[skeletonData.transformConstraints.length] = transformConstraintData;
			}

			// Slots.
			for each (var slotMap:Object in root["slots"]) {
				boneName = slotMap["bone"];
				boneData = skeletonData.findBone(boneName);
				if (!boneData) throw new Error("Slot bone not found: " + boneName);
				var slotData:SlotData = new SlotData(slotMap["name"], boneData);

				var color:String = slotMap["color"];
				if (color) {
					slotData.r = toColor(color, 0);
					slotData.g = toColor(color, 1);
					slotData.b = toColor(color, 2);
					slotData.a = toColor(color, 3);
				}

				slotData.attachmentName = slotMap["attachment"];
				slotData.blendMode = BlendMode[slotMap["blend"] || "normal"];

				skeletonData.slots[skeletonData.slots.length] = slotData;
			}

			// Skins.
			var skins:Object = root["skins"];
			var length : int = 0;
			for (var readName : String in skins)
			{
				++length;
			}
			for ( readName in skins) {
				var skin : Skin;
				if ( length > 1)
					skin = new Skin(readName);
				else
					skin = new Skin(skinName);
				var skinMap:Object = skins[readName];
				for (var slotName:String in skinMap) {
					var slotIndex:int = skeletonData.findSlotIndex(slotName);
					var slotEntry:Object = skinMap[slotName];
					for (var attachmentName:String in slotEntry) {
						var attachment:Attachment = readAttachment(skin, slotIndex, attachmentName, slotEntry[attachmentName]);
						if (attachment != null)
							skin.addAttachment(slotIndex, attachmentName, attachment);
					}
				}
				skeletonData.skins[skeletonData.skins.length] = skin;
				if (skin.name == "default")
					skeletonData.defaultSkin = skin;
			}
			if (skeletonData.skins.length == 1)
				skeletonData.defaultSkin = skin;

			// Linked meshes.
			for each (var linkedMesh:LinkedMesh in linkedMeshes) {
				var parentSkin:Skin = !linkedMesh.skin ? skeletonData.defaultSkin : skeletonData.findSkin(linkedMesh.skin);
				if (!parentSkin) throw new Error("Skin not found: " + linkedMesh.skin);
				var parentMesh:Attachment = parentSkin.getAttachment(linkedMesh.slotIndex, linkedMesh.parent);
				if (!parentMesh) throw new Error("Parent mesh not found: " + linkedMesh.parent);
				if (linkedMesh.mesh is MeshAttachment) {
					var mesh:MeshAttachment = MeshAttachment(linkedMesh.mesh);
					mesh.parentMesh = MeshAttachment(parentMesh);
					mesh.updateUVs();
				} else {
					var weightedMesh:WeightedMeshAttachment = WeightedMeshAttachment(linkedMesh.mesh);
					weightedMesh.parentMesh = WeightedMeshAttachment(parentMesh);
					weightedMesh.updateUVs();
				}
			}
			linkedMeshes.length = 0;

			// Events.
			var events:Object = root["events"];
			if (events) {
				for (var eventName:String in events) {
					var eventMap:Object = events[eventName];
					var eventData:EventData = new EventData(eventName);
					eventData.intValue = eventMap["int"] || 0;
					eventData.floatValue = eventMap["float"] || 0;
					eventData.stringValue = eventMap["string"] || null;
					skeletonData.events[skeletonData.events.length] = eventData;
				}
			}

			// Animations.
			var animations:Object = root["animations"];
			for (var animationName:String in animations)
				createAnimation(animationName, animations[animationName], skeletonData, skinName);

			return skeletonData;
		}

		protected override function readAttachment (skin:Skin, slotIndex:int, name:String, map:Object) : Attachment {
			name = map["name"] || name;

			var typeName:String = map["type"] || "region";
			if (typeName == "skinnedmesh") typeName = "weightedmesh";
			var type:AttachmentType = AttachmentType[typeName];
			var path:String = map["path"] || name;

            var pAttachmentLoader : StarlingAtlasAttachmentLoader = attachmentLoader as StarlingAtlasAttachmentLoader;
			var scale:Number = this.scale;
			var color:String, vertices:Vector.<Number>;
			switch (type) {
				case AttachmentType.region:
					var region:RegionAttachment = pAttachmentLoader.newRegionAttachmentEx(skin, name, path);
					if (!region) return null;
					region.path = path;
					region.x = Number(map["x"] || 0) * scale;
					region.y = Number(map["y"] || 0) * scale;
					region.scaleX = map.hasOwnProperty("scaleX") ? map["scaleX"] : 1;
					region.scaleY = map.hasOwnProperty("scaleY") ? map["scaleY"] : 1;
					region.rotation = map["rotation"] || 0;
					region.width = Number(map["width"] || 0) * scale;
					region.height = Number(map["height"] || 0) * scale;
					color = map["color"];
					if (color) {
						region.r = toColor(color, 0);
						region.g = toColor(color, 1);
						region.b = toColor(color, 2);
						region.a = toColor(color, 3);
					}
					region.updateOffset();
					return region;
				case AttachmentType.mesh:
				case AttachmentType.linkedmesh:
					var mesh:MeshAttachment = pAttachmentLoader.newMeshAttachmentEx(skin, name, path);
					if (!mesh) return null;
					mesh.path = path;

					color = map["color"];
					if (color) {
						mesh.r = toColor(color, 0);
						mesh.g = toColor(color, 1);
						mesh.b = toColor(color, 2);
						mesh.a = toColor(color, 3);
					}

					mesh.width = Number(map["width"] || 0) * scale;
					mesh.height = Number(map["height"] || 0) * scale;

					if (!map["parent"]) {
						mesh.vertices = getFloatArray(map, "vertices", scale);
						mesh.triangles = getUintArray(map, "triangles");
						mesh.regionUVs = getFloatArray(map, "uvs", 1);
						mesh.updateUVs();

						mesh.hullLength = int(map["hull"] || 0) * 2;
						if (map["edges"]) mesh.edges = getIntArray(map, "edges");
					} else {
						mesh.inheritFFD = map.hasOwnProperty("ffd") ? map["ffd"] : true;
						linkedMeshes[linkedMeshes.length] = new LinkedMesh(mesh, map["skin"], slotIndex, map["parent"]);
					}
					return mesh;
				case AttachmentType.weightedmesh:
				case AttachmentType.weightedlinkedmesh:
					var weightedMesh:WeightedMeshAttachment = pAttachmentLoader.newWeightedMeshAttachmentEx(skin, name, path);
					if (!weightedMesh) return null;

					weightedMesh.path = path;

					color = map["color"];
					if (color) {
						weightedMesh.r = toColor(color, 0);
						weightedMesh.g = toColor(color, 1);
						weightedMesh.b = toColor(color, 2);
						weightedMesh.a = toColor(color, 3);
					}

					weightedMesh.width = Number(map["width"] || 0) * scale;
					weightedMesh.height = Number(map["height"] || 0) * scale;

					if (!map["parent"]) {
						var uvs:Vector.<Number> = getFloatArray(map, "uvs", 1);
						vertices = getFloatArray(map, "vertices", 1);
						var weights:Vector.<Number> = new Vector.<Number>();
						var bones:Vector.<int> = new Vector.<int>();
						for (var i:int = 0, n:int = vertices.length; i < n;) {
							var boneCount:int = int(vertices[i++]);
							bones[bones.length] = boneCount;
							for (var nn:int = i + boneCount * 4; i < nn;) {
								bones[bones.length] = vertices[i];
								weights[weights.length] = vertices[i + 1] * scale;
								weights[weights.length] = vertices[i + 2] * scale;
								weights[weights.length] = vertices[i + 3];
								i += 4;
							}
						}
						weightedMesh.bones = bones;
						weightedMesh.weights = weights;
						weightedMesh.triangles = getUintArray(map, "triangles");
						weightedMesh.regionUVs = uvs;
						weightedMesh.updateUVs();

						weightedMesh.hullLength = int(map["hull"] || 0) * 2;
						if (map["edges"]) weightedMesh.edges = getIntArray(map, "edges");
					} else {
						weightedMesh.inheritFFD = map.hasOwnProperty("ffd") ? map["ffd"] : true;
						linkedMeshes[linkedMeshes.length] = new LinkedMesh(weightedMesh, map["skin"], slotIndex, map["parent"]);
					}
					return weightedMesh;
				case AttachmentType.boundingbox:
					var box:BoundingBoxAttachment = attachmentLoader.newBoundingBoxAttachment(skin, name);
					vertices = box.vertices;
					for each (var point:Number in map["vertices"])
						vertices[vertices.length] = point * scale;
					return box;
			}

			return null;
		}

		protected function createAnimation (name:String, map:Object, skeletonData:SkeletonData, skinName : String) : void {
		var timelines:Vector.<Timeline> = new Vector.<Timeline>();
		var duration:Number = 0;

		var slotMap:Object, slotIndex:int, slotName:String;
		var values:Array, valueMap:Object, frameIndex:int;
		var i:int;
		var timelineName:String;

		var slots:Object = map["slots"];
		for (slotName in slots) {
			slotMap = slots[slotName];
			slotIndex = skeletonData.findSlotIndex(slotName);

			for (timelineName in slotMap) {
				values = slotMap[timelineName];
				if (timelineName == "color") {
					var colorTimeline:ColorTimeline ;
					if (TimelineCache.FrameCacheEnabled)
						colorTimeline = new ColorTimelineInCache(values.length);
					else
						colorTimeline = new ColorTimeline(values.length);
					colorTimeline.slotIndex = slotIndex;

					frameIndex = 0;
					for each (valueMap in values) {
						var color:String = valueMap["color"];
						var r:Number = toColor(color, 0);
						var g:Number = toColor(color, 1);
						var b:Number = toColor(color, 2);
						var a:Number = toColor(color, 3);
						colorTimeline.setFrame(frameIndex, valueMap["time"], r, g, b, a);
						readCurve(colorTimeline, frameIndex, valueMap);
						frameIndex++;
					}

					timelines[timelines.length] = colorTimeline;
					duration = Math.max(duration, colorTimeline.frames[colorTimeline.frameCount * 5 - 5]);
				} else if (timelineName == "attachment") {
					var attachmentTimeline:AttachmentTimeline = new AttachmentTimeline(values.length);
					attachmentTimeline.slotIndex = slotIndex;

					frameIndex = 0;
					for each (valueMap in values)
						attachmentTimeline.setFrame(frameIndex++, valueMap["time"], valueMap["name"]);
					timelines[timelines.length] = attachmentTimeline;
					duration = Math.max(duration, attachmentTimeline.frames[attachmentTimeline.frameCount - 1]);
				} else
					throw new Error("Invalid timeline type for a slot: " + timelineName + " (" + slotName + ")");
			}
		}

		var bones:Object = map["bones"];
		for (var boneName:String in bones) {
			var boneIndex:int = skeletonData.findBoneIndex(boneName);
			if (boneIndex == -1) throw new Error("Bone not found: " + boneName);
			var boneMap:Object = bones[boneName];

			for (timelineName in boneMap) {
				values = boneMap[timelineName];
				if (timelineName == "rotate") {
					var rotateTimeline:RotateTimeline;
					if (TimelineCache.FrameCacheEnabled)
						rotateTimeline = new RotateTimelineInCache(values.length);
					else
						rotateTimeline = new RotateTimelineInCache(values.length);
					rotateTimeline.boneIndex = boneIndex;

					frameIndex = 0;
					for each (valueMap in values) {
						rotateTimeline.setFrame(frameIndex, valueMap["time"], valueMap["angle"]);
						readCurve(rotateTimeline, frameIndex, valueMap);
						frameIndex++;
					}
					timelines[timelines.length] = rotateTimeline;
					duration = Math.max(duration, rotateTimeline.frames[rotateTimeline.frameCount * 2 - 2]);
				} else if (timelineName == "translate" || timelineName == "scale") {
					var timeline:TranslateTimeline;
					var timelineScale:Number = 1;
					if (timelineName == "scale")
					{
						if (TimelineCache.FrameCacheEnabled)
							timeline = new ScaleTimelineIncache(values.length);
						else
							timeline = new ScaleTimeline(values.length);
					}
					else {
						if (TimelineCache.FrameCacheEnabled)
							timeline = new TranslateTimelineInCache(values.length);
						else
							timeline = new TranslateTimeline(values.length);
						timelineScale = scale;
					}
					timeline.boneIndex = boneIndex;

					frameIndex = 0;
					for each (valueMap in values) {
						var x:Number = Number(valueMap["x"] || 0) * timelineScale;
						var y:Number = Number(valueMap["y"] || 0) * timelineScale;
						timeline.setFrame(frameIndex, valueMap["time"], x, y);
						readCurve(timeline, frameIndex, valueMap);
						frameIndex++;
					}

					timelines[timelines.length] = timeline;
					duration = Math.max(duration, timeline.frames[timeline.frameCount * 3 - 3]);
				} else if (timelineName == "shear") {
					// FIXME: Just ignore now, removed me when AS3 spine supported SpineEditor 3.2
				} else
					throw new Error("Invalid timeline type for a bone: " + timelineName + " (" + boneName + ")");
			}
		}

		var ikMap:Object = map["ik"];
		for (var ikConstraintName:String in ikMap) {
			var ikConstraint:IkConstraintData = skeletonData.findIkConstraint(ikConstraintName);
			values = ikMap[ikConstraintName];
			var ikTimeline:IkConstraintTimeline = new IkConstraintTimeline(values.length);
			ikTimeline.ikConstraintIndex = skeletonData.ikConstraints.indexOf(ikConstraint);
			frameIndex = 0;
			for each (valueMap in values) {
				var mix:Number = valueMap.hasOwnProperty("mix") ? valueMap["mix"] : 1;
				var bendDirection:int = (!valueMap.hasOwnProperty("bendPositive") || valueMap["bendPositive"]) ? 1 : -1;
				ikTimeline.setFrame(frameIndex, valueMap["time"], mix, bendDirection);
				readCurve(ikTimeline, frameIndex, valueMap);
				frameIndex++;
			}
			timelines[timelines.length] = ikTimeline;
			duration = Math.max(duration, ikTimeline.frames[ikTimeline.frameCount * 3 - 3]);
		}

		var ffd:Object = map["ffd"];
		var length : int = 0;
		for (var readName : String in ffd)
		{
			++length;
		}
		for ( readName in ffd) {
			var skin : Skin;
			if (skeletonData.defaultSkin.name != "default")// if defaultSkinName != "default", then there is more than one skin in spine json file
				skin = skeletonData.findSkin(skinName);
			else
				skin = skeletonData.findSkin(readName);
			slotMap = ffd[readName];
			for (slotName in slotMap) {
				slotIndex = skeletonData.findSlotIndex(slotName);
				var meshMap:Object = slotMap[slotName];
				for (var meshName:String in meshMap) {
					values = meshMap[meshName];
					var ffdTimeline:FfdTimeline;
					if (TimelineCache.FrameCacheEnabled)
						ffdTimeline = new FfdTimelineInCache(values.length);
					else
						ffdTimeline = new FfdTimelineInCache(values.length);

					var attachment:Attachment = skin.getAttachment(slotIndex, meshName);
					if (!attachment) throw new Error("FFD attachment not found: " + meshName);
					ffdTimeline.slotIndex = slotIndex;
					ffdTimeline.attachment = attachment;

					var vertexCount:int;
					if (attachment is MeshAttachment)
						vertexCount = (attachment as MeshAttachment).vertices.length;
					else
						vertexCount = (attachment as WeightedMeshAttachment).weights.length / 3 * 2;

					frameIndex = 0;
					for each (valueMap in values) {
						var vertices:Vector.<Number>;
						if (!valueMap["vertices"]) {
							if (attachment is MeshAttachment)
								vertices = (attachment as MeshAttachment).vertices;
							else
								vertices = new Vector.<Number>(vertexCount, true);
						} else {
							var verticesValue:Array = valueMap["vertices"];
							vertices = new Vector.<Number>(vertexCount, true);
							var start:int = valueMap["offset"] || 0;
							var n:int = verticesValue.length;
							if (scale == 1) {
								for (i = 0; i < n; i++)
									vertices[i + start] = verticesValue[i];
							} else {
								for (i = 0; i < n; i++)
									vertices[i + start] = verticesValue[i] * scale;
							}
							if (attachment is MeshAttachment) {
								var meshVertices:Vector.<Number> = (attachment as MeshAttachment).vertices;
								for (i = 0; i < vertexCount; i++)
									vertices[i] += meshVertices[i];
							}
						}

						ffdTimeline.setFrame(frameIndex, valueMap["time"], vertices);
						readCurve(ffdTimeline, frameIndex, valueMap);
						frameIndex++;
					}
					timelines[timelines.length] = ffdTimeline;
					duration = Math.max(duration, ffdTimeline.frames[ffdTimeline.frameCount - 1]);
				}
			}
		}

		var drawOrderValues:Array = map["drawOrder"];
		if (!drawOrderValues) drawOrderValues = map["draworder"];
		if (drawOrderValues) {
			var drawOrderTimeline:DrawOrderTimeline = new DrawOrderTimeline(drawOrderValues.length);
			var slotCount:int = skeletonData.slots.length;
			frameIndex = 0;
			for each (var drawOrderMap:Object in drawOrderValues) {
				var drawOrder:Vector.<int> = null;
				if (drawOrderMap["offsets"]) {
					drawOrder = new Vector.<int>(slotCount);
					for (i = slotCount - 1; i >= 0; i--)
						drawOrder[i] = -1;
					var offsets:Array = drawOrderMap["offsets"];
					var unchanged:Vector.<int> = new Vector.<int>(slotCount - offsets.length);
					var originalIndex:int = 0, unchangedIndex:int = 0;
					for each (var offsetMap:Object in offsets) {
						slotIndex = skeletonData.findSlotIndex(offsetMap["slot"]);
						if (slotIndex == -1) throw new Error("Slot not found: " + offsetMap["slot"]);
						// Collect unchanged items.
						while (originalIndex != slotIndex)
							unchanged[unchangedIndex++] = originalIndex++;
						// Set changed items.
						drawOrder[originalIndex + offsetMap["offset"]] = originalIndex++;
					}
					// Collect remaining unchanged items.
					while (originalIndex < slotCount)
						unchanged[unchangedIndex++] = originalIndex++;
					// Fill in unchanged items.
					for (i = slotCount - 1; i >= 0; i--)
						if (drawOrder[i] == -1) drawOrder[i] = unchanged[--unchangedIndex];
				}
				drawOrderTimeline.setFrame(frameIndex++, drawOrderMap["time"], drawOrder);
			}
			timelines[timelines.length] = drawOrderTimeline;
			duration = Math.max(duration, drawOrderTimeline.frames[drawOrderTimeline.frameCount - 1]);
		}

		var eventsMap:Array = map["events"];
		if (eventsMap) {
			var eventTimeline:EventTimeline = new EventTimeline(eventsMap.length);
			frameIndex = 0;
			for each (var eventMap:Object in eventsMap) {
				var eventData:EventData = skeletonData.findEvent(eventMap["name"]);
				if (!eventData) throw new Error("Event not found: " + eventMap["name"]);
				var event:Event = new Event(eventMap["time"], eventData);
				event.intValue = eventMap.hasOwnProperty("int") ? eventMap["int"] : eventData.intValue;
				event.floatValue = eventMap.hasOwnProperty("float") ? eventMap["float"] : eventData.floatValue;
				event.stringValue = eventMap.hasOwnProperty("string") ? eventMap["string"] : eventData.stringValue;
				eventTimeline.setFrame(frameIndex++, event);
			}
			timelines[timelines.length] = eventTimeline;
			duration = Math.max(duration, eventTimeline.frames[eventTimeline.frameCount - 1]);
		}

		skeletonData.animations[skeletonData.animations.length] = new Animation(name, timelines, duration);
	}

		public  function getAttachment(oldAttachment : Attachment , attachmentLoader : StarlingAtlasAttachmentLoader , skin : Skin, slotIndex : int):Attachment
		{
				var type:AttachmentType = AttachmentType.region;
				if ((oldAttachment as RegionAttachment) != null)
				{
					type = AttachmentType.region;
				}
				else if ((oldAttachment as MeshAttachment) != null)
				{
					type = AttachmentType.mesh;
				}
				else if ((oldAttachment as WeightedMeshAttachment) != null)
				{
					type = AttachmentType.weightedmesh;
				}else if ((oldAttachment as BoundingBoxAttachment) != null)
				{
					type =  AttachmentType.boundingbox;
				}

				switch (type)
				{
					case AttachmentType.region:
						var regionTemp : RegionAttachment = oldAttachment as RegionAttachment;
						var region:RegionAttachment = attachmentLoader.newRegionAttachmentEx(skin, oldAttachment.name, regionTemp.path);
						if (!region) return null;

						region.path = regionTemp.path;
						region.x = regionTemp.x;
						region.y = regionTemp.y;
						region.scaleX = regionTemp.scaleX;
						region.scaleY = regionTemp.scaleY;
						region.rotation = regionTemp.rotation;
						region.width = regionTemp.width;
						region.height = regionTemp.height;

						region.r = regionTemp.r;
						region.g = regionTemp.g;
						region.b = regionTemp.b;
						region.a = regionTemp.a;
						region.updateOffset();
						return region;

					case AttachmentType.mesh:
					case AttachmentType.linkedmesh:
						var meshTemp : MeshAttachment = oldAttachment as MeshAttachment;
						var mesh:MeshAttachment = attachmentLoader.newMeshAttachmentEx(skin, meshTemp.name, meshTemp.path);
						if (!mesh) return null;
						mesh.path = meshTemp.path;

						mesh.r = meshTemp.r;
						mesh.g = meshTemp.g;
						mesh.b = meshTemp.b;
						mesh.a = meshTemp.a;

						mesh.width = meshTemp.width;
						mesh.height = meshTemp.height;

						if (!meshTemp.parentMesh ) {
							mesh.vertices = meshTemp.vertices;
							mesh.triangles =meshTemp.triangles;
							mesh.regionUVs = meshTemp.regionUVs;
							mesh.updateUVs();

							mesh.hullLength = meshTemp.hullLength;
							mesh.edges = meshTemp.edges;
						} else {
							mesh.inheritFFD = meshTemp.inheritFFD;
//							linkedMeshes[linkedMeshes.length] = new LinkedMesh(mesh, map["skin"], slotIndex, map["parent"]);
							linkedMeshes[linkedMeshes.length] = new LinkedMesh(mesh, null, slotIndex, meshTemp.parentMesh.name);

						}
						return mesh;

					case AttachmentType.weightedmesh:
					case AttachmentType.weightedlinkedmesh:
						var weightedMeshTemp : WeightedMeshAttachment = oldAttachment as WeightedMeshAttachment;
						var weightedMesh:WeightedMeshAttachment = attachmentLoader.newWeightedMeshAttachmentEx(skin, weightedMeshTemp.name, weightedMeshTemp.path);
						if (!weightedMesh) return null;

						weightedMesh.path = weightedMeshTemp.path;

						weightedMesh.r = weightedMeshTemp.r;
						weightedMesh.g = weightedMeshTemp.g;
						weightedMesh.b = weightedMeshTemp.b;
						weightedMesh.a = weightedMeshTemp.a;

						weightedMesh.width = weightedMeshTemp.width;
						weightedMesh.height = weightedMeshTemp.height;

						if (!weightedMeshTemp.parentMesh) {
							weightedMesh.bones = weightedMeshTemp.bones;
							weightedMesh.weights = weightedMeshTemp.weights;
							weightedMesh.triangles = weightedMeshTemp.triangles;
							weightedMesh.regionUVs = weightedMeshTemp.regionUVs;
							weightedMesh.updateUVs();

							weightedMesh.hullLength = weightedMeshTemp.hullLength;
							weightedMesh.edges = weightedMeshTemp.edges;
						} else {
							weightedMesh.inheritFFD = weightedMeshTemp.inheritFFD;
//							linkedMeshes[linkedMeshes.length] = new LinkedMesh(weightedMesh, map["skin"], slotIndex, map["parent"]);
							linkedMeshes[linkedMeshes.length] = new LinkedMesh(weightedMesh, null, slotIndex, weightedMeshTemp.parentMesh.name);
						}
						return weightedMesh;
					case AttachmentType.boundingbox:
						var boxTemp : BoundingBoxAttachment = oldAttachment as BoundingBoxAttachment;
						var box:BoundingBoxAttachment = attachmentLoader.newBoundingBoxAttachment(skin, boxTemp.name);
						box.vertices = boxTemp.vertices;
						return box;
				}
				return null;
			}

		public function linkMeshes(skeletonData : SkeletonData) : void
		{
			// Linked meshes.
			for each (var linkedMesh:LinkedMesh in linkedMeshes) {
				var parentSkin:Skin = !linkedMesh.skin ? skeletonData.defaultSkin : skeletonData.findSkin(linkedMesh.skin);
				if (!parentSkin) throw new Error("Skin not found: " + linkedMesh.skin);
				var parentMesh:Attachment = parentSkin.getAttachment(linkedMesh.slotIndex, linkedMesh.parent);
				if (!parentMesh) throw new Error("Parent mesh not found: " + linkedMesh.parent);
				if (linkedMesh.mesh is MeshAttachment) {
					var mesh:MeshAttachment = MeshAttachment(linkedMesh.mesh);
					mesh.parentMesh = MeshAttachment(parentMesh);
					mesh.updateUVs();
				} else {
					var weightedMesh:WeightedMeshAttachment = WeightedMeshAttachment(linkedMesh.mesh);
					weightedMesh.parentMesh = WeightedMeshAttachment(parentMesh);
					weightedMesh.updateUVs();
				}
			}
			linkedMeshes.length = 0;
		}

        [Inline]
        static protected function readCurve (timeline:CurveTimeline, frameIndex:int, valueMap:Object) : void {
            var curve:Object = valueMap["curve"];
            if (!curve) return;
            if (curve == "stepped")
                timeline.setStepped(frameIndex);
            else if (curve is Array)
                timeline.setCurve(frameIndex, curve[0], curve[1], curve[2], curve[3]);
        }

        [Inline]
        static protected function toColor (hexString:String, colorIndex:int) : Number {
            if (hexString.length != 8) throw new ArgumentError("Color hexidecimal length must be 8, recieved: " + hexString);
            return parseInt(hexString.substring(colorIndex * 2, colorIndex * 2 + 2), 16) / 255;
        }

        static private function getFloatArray (map:Object, name:String, scale:Number) : Vector.<Number> {
            var list:Array = map[name];
            var values:Vector.<Number> = new Vector.<Number>(list.length, true);
            var i:int = 0, n:int = list.length;
            if (scale == 1) {
                for (; i < n; i++)
                    values[i] = list[i];
            } else {
                for (; i < n; i++)
                    values[i] = list[i] * scale;
            }
            return values;
        }

        static private function getIntArray (map:Object, name:String) : Vector.<int> {
            var list:Array = map[name];
            var values:Vector.<int> = new Vector.<int>(list.length, true);
            for (var i:int = 0, n:int = list.length; i < n; i++)
                values[i] = int(list[i]);
            return values;
        }

        static private function getUintArray (map:Object, name:String) : Vector.<uint> {
            var list:Array = map[name];
            var values:Vector.<uint> = new Vector.<uint>(list.length, true);
            for (var i:int = 0, n:int = list.length; i < n; i++)
                values[i] = int(list[i]);
            return values;
        }
    }
}

import spine.attachments.Attachment;

internal class LinkedMesh {
	internal var parent:String, skin:String;
	internal var slotIndex:int;
	internal var mesh:Attachment;

	public function LinkedMesh (mesh:Attachment, skin:String, slotIndex:int, parent:String) {
		this.mesh = mesh;
		this.skin = skin;
		this.slotIndex = slotIndex;
		this.parent = parent;
	}
}