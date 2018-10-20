//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Administrator on 2017/4/13.
 */
package spineExt {
import QFLib.Qson.CStream;


import flash.utils.ByteArray;

import spine.BlendMode;
import spine.BoneData;
import spine.Event;
import spine.EventData;

import spine.SkeletonData;
import spine.SkeletonJson;
import spine.Skin;
import spine.SlotData;
import spine.animation.*
import spine.attachments.Attachment;
import spine.attachments.AttachmentLoader;
import spine.attachments.AttachmentType;
import spine.attachments.BoundingBoxAttachment;

import spineExt.TimeLineCache.ColorTimelineInCache;
import spineExt.TimeLineCache.FfdTimelineInCache;
import spineExt.TimeLineCache.RotateTimelineInCache;
import spineExt.TimeLineCache.ScaleTimelineIncache;
import spineExt.TimeLineCache.TimelineCache;
import spineExt.TimeLineCache.TranslateTimelineInCache;

import spineExt.starling.StarlingAtlasAttachmentLoader;
import spineExt.starling.*;

public class SkeletonBinary extends spine.SkeletonJson{
    public function SkeletonBinary(attachmentLoader:AttachmentLoader = null)
    {
        super(attachmentLoader);
    }
    public function dispose():void
    {
        m_theStream.dispose();
    }

    public function createSkeletonData (stream : ByteArray, skinName : String, skeletonDataName:String = null) : SkeletonData
    {
        if (stream == null) throw new ArgumentError("stream cannot be null.");
        setStream(stream);
        //confirmStream();
        var skeletonData:SkeletonData = new SkeletonData();
        skeletonData.name = skeletonDataName;

        //skeleton
         _readString();
        skeletonData.hash = _readString();
        skeletonData.version = _readString();
        skeletonData.width = _readFloat();
        skeletonData.height = _readFloat();

        //bones
        _readString();
        var i : int, j : int, k :int, m : int, n :int;
        var count : int = _readInt();
        var boneData:BoneData, parentName : String, parent : BoneData;
        for ( i = 0; i < count; ++i)
        {
            parent = null;
            parentName = _readString();
            if (parentName != "0")
            {
                parent = skeletonData.findBone(parentName);
                if (!parent) throw new Error("Parent bone not found: " + parentName);
            }
            boneData = new BoneData(_readString(), parent);
            boneData.length = _readFloat();
            boneData.x = _readFloat();
            boneData.y = _readFloat();
            boneData.rotation = _readFloat();
            boneData.scaleX = _readFloat();
            boneData.scaleY = _readFloat();
            boneData.inheritScale = _readBoolean();
            boneData.inheritRotation = _readBoolean();
            skeletonData.bones.push(boneData);
        }

        //slots
        _readString();
        count = _readInt();
        if (count > 0)
        {
            var blendMode : String;
            for (i = 0; i < count; ++i)
            {
                boneData = skeletonData.findBone(_readString());
                if (!boneData) throw new Error("Slot bone not found");
                var slotData:SlotData = new SlotData(_readString(), boneData);
                var color:String = _readString();
                if ( color != "0" )
                {
                    slotData.r = toColor(color, 0);
                    slotData.g = toColor(color, 1);
                    slotData.b = toColor(color, 2);
                    slotData.a = toColor(color, 3);
                }

                slotData.attachmentName = _readString();
                if (slotData.attachmentName == "1")
                    slotData.attachmentName = null;
                blendMode = _readString();
                if(blendMode != "1")
                    slotData.blendMode = BlendMode[blendMode];
                else
                    slotData.blendMode = BlendMode["normal"];
                skeletonData.slots.push(slotData);
            }
        }

        //skins
        _readString();
        count = _readInt();
        var slotIndex:int, slotName:String, attachment:Attachment, attachmentName:String, readSkinName : String;
        var slotCount:int, attachmentCount:int;
        if (count > 0)
        {
            for (i = 0; i < count; ++i) {
                var skin : Skin;
                if (count > 1)
                {
                    skin = new Skin( _readString() );
                }
                else
                {
                    _readString();
                    skin = new Skin(skinName);
                }
                slotCount = _readInt();
                for (j = 0; j < slotCount; ++j) {
                    slotName = _readString();
                    slotIndex = skeletonData.findSlotIndex(slotName);
                    attachmentCount = _readInt();
                    for (k = 0; k < attachmentCount; ++k) {
                        attachmentName = _readString();
                        attachment = _readAttachment(skin, slotIndex, attachmentName);
                        if (attachment != null)
                            skin.addAttachment(slotIndex, attachmentName, attachment);
                    }
                }

                skeletonData.skins.push(skin);
                if (skin.name == "default")
                    skeletonData.defaultSkin = skin;
            }
            if (skeletonData.skins.length == 1)
                skeletonData.defaultSkin = skin;
        }
        //events
        _readString();
        count = _readInt();
        var eventData:EventData;
        if (count > 0) {
            for (i = 0; i < count; ++i) {
                eventData = new EventData(_readString());
                skeletonData.events.push(eventData);
            }
        }
        //animations
        var animationCount : int;
        _readString();
        animationCount = _readInt();
        var animationName : String, timelineName : String, timelineCount : int, frameIndex : int;
        var frameCount : int, duration : Number;

        var timelines:Vector.<Timeline>;
        var colorTimeline : ColorTimeline, attachmentTimeline : AttachmentTimeline, ffdTimeline : FfdTimeline, eventTimeline:EventTimeline;
        var drawOrderTimeline:DrawOrderTimeline, drawOrder:Vector.<int>;
        var boneName : String, boneIndex : int;
        var rotateTimeline:RotateTimeline, timeline : TranslateTimeline;
        var timelineScale : Number;
        var vertexCount:int, vertices : Vector.<Number>, verticesStart : int,meshVertices:Vector.<Number>;
        var unchanged:Vector.<int>, originalIndex:int, unchangedIndex:int, offsetsCount : int;

        for (i = 0; i < animationCount; ++i)
        {
            duration = 0;
            timelines = new Vector.<Timeline>();
            animationName = _readString();

            //slots
            _readString();
            slotCount = _readInt();
            for (j = 0; j < slotCount; ++j)
            {
                slotName = _readString();
                slotIndex = skeletonData.findSlotIndex(slotName);
                timelineCount = _readInt();
                for (k = 0; k < timelineCount; ++k)
                {
                    timelineName = _readString();
                    if (timelineName == "color")
                    {
                        frameCount = _readInt();
                        if (TimelineCache.FrameCacheEnabled)
                            colorTimeline = new ColorTimelineInCache(frameCount);
                        else
                            colorTimeline = new ColorTimeline(frameCount);
                        colorTimeline.slotIndex = slotIndex;
                        frameIndex = 0;
                        var sColor : String;
                        for (m = 0; m < frameCount; ++m)
                        {
                            sColor = _readString();
                            colorTimeline.setFrame(frameIndex, _readFloat(), toColor(sColor,0), toColor(sColor,1), toColor(sColor,2), toColor(sColor,3));
                            _readBinaryCurve(colorTimeline, frameIndex);
                            frameIndex++;
                        }

                        timelines[timelines.length] = colorTimeline;
                        duration = Math.max(duration, colorTimeline.frames[colorTimeline.frameCount * 5 - 5]);
                    }
                    else if (timelineName == "attachment")
                    {
                        frameCount = _readInt();
                        attachmentTimeline = new AttachmentTimeline(frameCount);
                        attachmentTimeline.slotIndex = slotIndex;
                        frameIndex = 0;
                        for (m = 0; m < frameCount; ++m)
                        {
                            attachmentName = _readString();
                            if (attachmentName == "0") attachmentName = null;
                            attachmentTimeline.setFrame(frameIndex++, _readFloat(), attachmentName);
                        }
                        timelines[timelines.length] = attachmentTimeline;
                        duration = Math.max(duration, attachmentTimeline.frames[attachmentTimeline.frameCount - 1]);
                    }else
                        throw new Error("Invalid timeline type for a slot: " + timelineName + " (" + slotName + ")");
                }
            }

            //bones
            _readString();
            var boneCount :int = _readInt();
            for (j = 0; j < boneCount; ++j)
            {
                boneName = _readString();
                timelineCount = _readInt();
                boneIndex = skeletonData.findBoneIndex(boneName);
                if (boneIndex == -1) throw new Error("Bone not found: " + boneName);

                for (k = 0; k < timelineCount; ++k)
                {
                    timelineName = _readString();
                    if (timelineName == "rotate")
                    {
                        frameCount = _readInt();
                        if (TimelineCache.FrameCacheEnabled)
                            rotateTimeline = new RotateTimelineInCache(frameCount);
                        else
                            rotateTimeline = new RotateTimeline(frameCount);
                        rotateTimeline.boneIndex = boneIndex;
                        frameIndex = 0;
                        for (m = 0; m < frameCount; ++m)
                        {
                            rotateTimeline.setFrame(frameIndex, _readFloat(), _readFloat());
                            _readBinaryCurve(rotateTimeline, frameIndex);
                            frameIndex++;
                        }
                        timelines[timelines.length] = rotateTimeline;
                        duration = Math.max(duration, rotateTimeline.frames[rotateTimeline.frameCount * 2 - 2]);
                    }
                    else if (timelineName == "translate" || timelineName == "scale")
                    {
                        timelineScale = 1;
                        frameCount = _readInt();
                        frameIndex = 0;
                        if (timelineName == "scale")
                        {
                            if (TimelineCache.FrameCacheEnabled)
                                timeline = new ScaleTimelineIncache(frameCount);
                            else
                                timeline = new ScaleTimeline(frameCount);
                        }
                        else
                        {
                            if (TimelineCache.FrameCacheEnabled)
                                timeline = new TranslateTimelineInCache(frameCount);
                            else
                                timeline = new TranslateTimeline(frameCount);
                            timelineScale = scale;
                        }
                        timeline.boneIndex = boneIndex;
                        for (m = 0; m < frameCount; ++m)
                        {
                            timeline.setFrame(frameIndex, _readFloat(), _readFloat() * timelineScale, _readFloat() * timelineScale);
                            _readBinaryCurve(timeline, frameIndex);
                            frameIndex++;
                        }

                        timelines[ timelines.length ] = timeline;
                        duration = Math.max( duration, timeline.frames[ timeline.frameCount * 3 - 3 ] );
                    }
                    else throw new Error( "Invalid timeline type for a bone: " + timelineName + " (" + boneName + ")" );
                }
            }

            //ffd
            _readString();
            count = _readInt();
            //if (count > 0)
            for ( var p : int = 0; p < count; ++p)
            {
                if (skeletonData.defaultSkin.name != "default")
                {
                    _readString();//skinName
                    skin = skeletonData.findSkin(skinName);
                }
                else
                    skin = skeletonData.findSkin(_readString());
                slotCount = _readInt();
                var verticesValueCount:int;
                for (j = 0; j < slotCount; ++j) {
                    slotName = _readString();
                    slotIndex = skeletonData.findSlotIndex(slotName);
                    attachmentCount = _readInt();
                    for (k = 0; k < attachmentCount; ++k) {
                        attachmentName = _readString();
                        timelineCount = _readInt();
                        if (TimelineCache.FrameCacheEnabled)
                            ffdTimeline = new FfdTimelineInCache(timelineCount);
                        else
                            ffdTimeline = new FfdTimeline(timelineCount);
                        attachment = skin.getAttachment(slotIndex, attachmentName);
                        if (!attachment) throw new Error("FFD attachment not found: " + attachmentName);
                        ffdTimeline.slotIndex = slotIndex;
                        ffdTimeline.attachment = attachment;

                        if (attachment is MeshAttachment)
                            vertexCount = (attachment as MeshAttachment).vertices.length;
                        else
                            vertexCount = (attachment as WeightedMeshAttachment).weights.length / 3 * 2;
                        frameIndex = 0;

                        for (m = 0; m < timelineCount; ++m) {
                            verticesStart = _readInt();
                            verticesValueCount = _readInt();
                            if (vertexCount == 0) {
                                if (attachment is MeshAttachment)
                                    vertices = (attachment as MeshAttachment).vertices;
                                else
                                    vertices = new Vector.<Number>(vertexCount, true);
                            }
                            else {
                                vertices = new Vector.<Number>(vertexCount, true);
                                if (scale == 1) {
                                    for (n = 0; n < verticesValueCount; ++n) {
                                        vertices[n + verticesStart] = _readFloat();
                                    }
                                }
                                else {
                                    for (n = 0; n < verticesValueCount; ++n) {
                                        vertices[n + verticesStart] = _readFloat() * scale;
                                    }
                                }
                                if (attachment is MeshAttachment) {
                                    meshVertices = (attachment as MeshAttachment).vertices;
                                    for (n = 0; n < vertexCount; n++)
                                        vertices[n] += meshVertices[n];
                                }
                            }
                            ffdTimeline.setFrame(frameIndex, _readFloat(), vertices);
                            _readBinaryCurve(ffdTimeline, frameIndex);
                            frameIndex++;
                        }
                        timelines[timelines.length] = ffdTimeline;
                        duration = Math.max(duration, ffdTimeline.frames[ffdTimeline.frameCount - 1]);
                    }
                }
            }
            //drawOrder
            _readString();
            count = _readInt();
            if (count > 0)
            {
                drawOrderTimeline = new DrawOrderTimeline(count);
                slotCount = skeletonData.slots.length;
                frameIndex = 0;

                for (j = 0; j < count; ++j)
                {
                    drawOrder = null;
                    offsetsCount = _readInt();
                    if (offsetsCount > 0)
                    {
                        drawOrder = new Vector.<int>(slotCount);
                        for (k = slotCount - 1; k >= 0; k--)
                            drawOrder[k] = -1;
                        unchanged = new Vector.<int>(slotCount - offsetsCount);
                        originalIndex = 0, unchangedIndex = 0;

                        for (k = 0; k < offsetsCount; ++k)
                        {
                            slotIndex = skeletonData.findSlotIndex(_readString());
                            if (slotIndex == -1) throw new Error("Slot not found: ");
                            while (originalIndex != slotIndex)
                                unchanged[unchangedIndex++] = originalIndex++;

                            drawOrder[originalIndex + _readInt()] = originalIndex++;
                        }
                        // Collect remaining unchanged items.
                        while (originalIndex < slotCount)
                            unchanged[unchangedIndex++] = originalIndex++;
                        // Fill in unchanged items.
                        for (k = slotCount - 1; k >= 0; k--)
                            if (drawOrder[k] == -1) drawOrder[k] = unchanged[--unchangedIndex];
                    }
                    drawOrderTimeline.setFrame(frameIndex++, _readFloat(), drawOrder);
                }
                timelines[timelines.length] = drawOrderTimeline;
                duration = Math.max(duration, drawOrderTimeline.frames[drawOrderTimeline.frameCount - 1]);
            }

            //events
            _readString();
            count = _readInt();
            var event:Event;
            if (count > 0)
            {
                eventTimeline = new EventTimeline(count);
                frameIndex = 0;
                for (j = 0; j < count; ++j)
                {
                    eventData = skeletonData.findEvent(_readString());
                    if (!eventData) throw new Error("Event not found: ");
                    event = new Event(_readFloat(), eventData);
                    eventTimeline.setFrame(frameIndex++, event);
                }
                timelines[timelines.length] = eventTimeline;
                duration = Math.max(duration, eventTimeline.frames[eventTimeline.frameCount - 1]);
            }
            skeletonData.animations[skeletonData.animations.length] = new Animation(animationName, timelines, duration);
        }
        return skeletonData;
    }
    [Inline]
    final private  function _readAttachment(skin:Skin, slotIndex:int, attachmentName:String) : Attachment
    {
        var name : String = _readString();
        if (name != "0")
            attachmentName = name;
        var typeName:String = _readString();
        var type:AttachmentType = AttachmentType[typeName];
        var scale:Number = this.scale;
        var color:String, vertices:Vector.<Number>;
        var path : String = _readString();
        if (path == "0")
            path = attachmentName;

        switch (type) {
            case AttachmentType.region:
                var region:RegionAttachment = (attachmentLoader as StarlingAtlasAttachmentLoader).newRegionAttachmentEx(skin, attachmentName, path);
                if (!region) return null;
                region.path = path;
                region.x = _readFloat();
                region.y = _readFloat();
                region.scaleX = _readFloat();
                region.scaleY = _readFloat();
                region.rotation = _readFloat();
                region.width = _readFloat();
                region.height = _readFloat();
                color = _readString();
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
                var mesh:MeshAttachment =(attachmentLoader as StarlingAtlasAttachmentLoader).newMeshAttachmentEx(skin, attachmentName, path);
                if (!mesh) return null;
                mesh.path = path;

                mesh.width = _readFloat()  * scale;
                mesh.height = _readFloat()  * scale;
                mesh.vertices = _readFloatArray(scale);
                mesh.triangles = _readUintArray();
                mesh.regionUVs = _readFloatArray(scale);
                mesh.updateUVs();

                mesh.hullLength = _readInt() * 2;
//                mesh.edges = _readIntArray();
//                if (mesh.edges.length == 0)
//                        mesh.edges = null;
                color = _readString();
                if (color) {
                    mesh.r = toColor(color, 0);
                    mesh.g = toColor(color, 1);
                    mesh.b = toColor(color, 2);
                    mesh.a = toColor(color, 3);
                }
                return mesh;
            case AttachmentType.weightedmesh:
            case AttachmentType.weightedlinkedmesh:
                var weightedMesh:WeightedMeshAttachment = (attachmentLoader as StarlingAtlasAttachmentLoader).newWeightedMeshAttachmentEx(skin, attachmentName, path);
                if (!weightedMesh) return null;
                weightedMesh.path = path;

                weightedMesh.width = _readFloat()  * scale;
                weightedMesh.height = _readFloat()  * scale;

                vertices = _readFloatArray(scale);
                weightedMesh.triangles = _readUintArray();
                weightedMesh.regionUVs = _readFloatArray(scale);

                var weights:Vector.<Number> = new Vector.<Number>();
                var bones:Vector.<int> = new Vector.<int>();
                for (var i:int = 0, n:int = vertices.length; i < n;) {
                    var boneCount:int = int(vertices[i++]);
                    bones[bones.length] = boneCount;
                    for (var nn:int = i + boneCount * 4; i < nn;) {
                        bones[bones.length] =vertices[i];
                        weights[weights.length] = vertices[i + 1] * scale;
                        weights[weights.length] = vertices[i + 2] * scale;
                        weights[weights.length] = vertices[i + 3];
                        i += 4;
                    }
                }
                weightedMesh.bones = bones;
                weightedMesh.weights = weights;
                weightedMesh.updateUVs();
                weightedMesh.hullLength = _readInt() * 2;
                color = _readString();
                if (color) {
                    weightedMesh.r = toColor(color, 0);
                    weightedMesh.g = toColor(color, 1);
                    weightedMesh.b = toColor(color, 2);
                    weightedMesh.a = toColor(color, 3);
                }
                return weightedMesh;
            case AttachmentType.boundingbox:
                var box:BoundingBoxAttachment = (attachmentLoader as StarlingAtlasAttachmentLoader).newBoundingBoxAttachment(skin, attachmentName);
                box.vertices = _readFloatArray(scale);
                return box;
        }
        return null;
    }

    [Inline]
    final private function _readBinaryCurve(timeline:CurveTimeline, frameIndex:int) : void
    {
        var count : int = _readInt();
        if (count == 0) return;
        else if (count == 1)
            timeline.setStepped(frameIndex);
        else if (count == 4)
        {
            timeline.setCurve(frameIndex, _readFloat(), _readFloat(), _readFloat(), _readFloat());
        }
    }
    public static function setStream( stream : ByteArray ) : void
    {
        stream.position = 0;
        m_theStream = new CStream(stream);
    }

    public function confirmStream() : void
    {
        m_theStream.setSelfStream();
    }

    [Inline]
    final private function _readString() : String
    {
        return m_theStream.readShortString();
    }

    [Inline]
    final private function _readInt() : int
    {
        return m_theStream.readInt();
    }
    [Inline]
    final private function _readBoolean() : Boolean
    {
        return m_theStream.readBoolean();
    }
    [Inline]
    final private function _readFloat() : Number
    {
        return m_theStream.readFloat();
    }
    [Inline]
    final private function _readFloatArray(Scale : Number) : Vector.<Number>
    {
        var count : int = _readInt();
        var i : int;
        var floatArray : Vector.<Number> = new Vector.<Number>(count);
        if (Scale == 1)
        {
            for (i = 0; i < count; ++i)
            {
                floatArray[i] = _readFloat();
            }
        }
        else
        {
            for (i = 0; i < count; ++i)
            {
                floatArray[i] = _readFloat() * Scale;
            }
        }
        return floatArray;
    }
    [Inline]
    final private function _readUintArray() : Vector.<uint>
    {
        var count : int = _readInt();
        var intArray : Vector.<uint> = new Vector.<uint>(count);
        for (var i : int = 0; i < count; ++i)
        {
            intArray[i] = _readInt();
        }
        return intArray;
    }
    [Inline]
    final private function _readIntArray() : Vector.<int>
    {
        var count : int = _readInt();
        var intArray : Vector.<int> = new Vector.<int>(count);
        for (var i : int = 0; i < count; ++i)
        {
            intArray[i] = _readInt();
        }
        return intArray;
    }
    private static var m_theStream : CStream;
}
}
