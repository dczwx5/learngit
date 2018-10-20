// =================================================================================================
//
//	Starling Framework
//	Copyright 2011 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package QFLib.Graphics.RenderCore.starling.textures
{

	import QFLib.Utils.Quality;

	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	/** A texture atlas is a collection of many smaller textures in one big image. This class
     *  is used to access textures from such an atlas.
     *  
     *  <p>Using a texture atlas for your textures solves two problems:</p>
     *  
     *  <ul>
     *    <li>Whenever you switch between textures, the batching of image objects is disrupted.</li>
     *    <li>Any Stage3D texture has to have side lengths that are powers of two. Starling hides 
     *        this limitation from you, but at the cost of additional graphics memory.</li>
     *  </ul>
     *  
     *  <p>By using a texture atlas, you avoid both texture switches and the power-of-two 
     *  limitation. All textures are within one big "super-texture", and Starling takes care that 
     *  the correct part of this texture is displayed.</p>
     *  
     *  <p>There are several ways to create a texture atlas. One is to use the atlas generator 
     *  script that is bundled with Starling's sibling, the <a href="http://www.sparrow-framework.org">
     *  Sparrow framework</a>. It was only tested in Mac OS X, though. A great multi-platform 
     *  alternative is the commercial tool <a href="http://www.texturepacker.com">
     *  Texture Packer</a>.</p>
     *  
     *  <p>Whatever tool you use, Starling expects the following file format:</p>
     * 
     *  <listing>
     * 	&lt;TextureAtlas imagePath='atlas.png'&gt;
     * 	  &lt;SubTexture name='texture_1' x='0'  y='0' width='50' height='50'/&gt;
     * 	  &lt;SubTexture name='texture_2' x='50' y='0' width='20' height='30'/&gt; 
     * 	&lt;/TextureAtlas&gt;
     *  </listing>
     *  
     *  <p>If your images have transparent areas at their edges, you can make use of the 
     *  <code>frame</code> property of the Texture class. Trim the texture by removing the 
     *  transparent edges and specify the original texture size like this:</p>
     * 
     *  <listing>
     * 	&lt;SubTexture name='trimmed' x='0' y='0' height='10' width='10'
     * 	    frameX='-10' frameY='-10' frameWidth='30' frameHeight='30'/&gt;
     *  </listing>
     */
    public class TextureAtlas
    {
        private var mAtlasTexture:Texture;
        private var mTextureInfos:Dictionary;
        private var mXmlURL:String;
		private var mImageName:String; 
		
        /** helper objects */
        private static var sNames:Vector.<String> = new <String>[];
        
        /** Create a texture atlas from a texture by parsing the regions from an XML file. */
        public function TextureAtlas(texture:Texture, atlasXml:XML=null, __xmlURL:String="", imageName:String = "")
        {
            mTextureInfos = new Dictionary();
            mAtlasTexture = texture;
            
            if (atlasXml)
                parseAtlasXml(atlasXml);
			
			mXmlURL=__xmlURL;
			mImageName = imageName;
        }

		public function get xmlURL():String
		{
			return mXmlURL;
		}
		
		public function get ImageName():String
		{
			return mImageName;
		}
        
        /** Disposes the atlas texture. */
        public function dispose():void
        {
			for(var name:String in mTextureInfos){
				delete mTextureInfos[name];
			}
			mTextureInfos = null;
			
			if(mAtlasTexture){
				mAtlasTexture.dispose();
				mAtlasTexture = null;
			}
            
			mXmlURL = null;
			mImageName = null;
        }
        
        /** This function is called by the constructor and will parse an XML in Starling's 
         *  default atlas file format. Override this method to create custom parsing logic
         *  (e.g. to support a different file format). */
        protected function parseAtlasXml(atlasXml:XML):void
        {
            var scale:Number = mAtlasTexture.scale;
            
			var name:String;
			var x:Number;
			var y:Number;
			var width:Number;
			var height:Number;
			var frameX:Number;
			var frameY:Number;
			var frameWidth:Number;
			var frameHeight:Number;
			var rotated:Boolean;
			
			var region:Rectangle;
			var frame:Rectangle;
			var subTexture:XML;
			
            for each (subTexture in atlasXml.SubTexture)
            {
                name        = subTexture.@name;
                x           = parseFloat(subTexture.@x) / scale;
                y           = parseFloat(subTexture.@y) / scale;
                width       = parseFloat(subTexture.@width) / scale;
                height      = parseFloat(subTexture.@height) / scale;
                frameX      = parseFloat(subTexture.@frameX) / scale;
                frameY      = parseFloat(subTexture.@frameY) / scale;
                frameWidth  = parseFloat(subTexture.@frameWidth) / scale;
                frameHeight = parseFloat(subTexture.@frameHeight) / scale;
                rotated    = parseBool(subTexture.@rotated);

                if(Quality.isLowQualityOfRender && Quality.knifeImageManualSwitch)
                {
                    x *= 0.5;
                    y *= 0.5;
                    width *= 0.5;
                    height *= 0.5;
                    frameX *= 0.5;
                    frameY *= 0.5;
                    frameWidth *= 0.5;
                    frameHeight *= 0.5;
                }
				
                region = new Rectangle(x, y, width, height);
                frame  = frameWidth > 0 && frameHeight > 0 ?
                        new Rectangle(frameX, frameY, frameWidth, frameHeight) : null;
                
                addRegion(name, region, frame, rotated);
            }
        }
		
		public function getTextureInfo(name:String):TextureInfo
		{
			var info:TextureInfo = mTextureInfos[name];
			
			if (info == null)
			{
				return null;
			}
			
			return info;
		}
		
        
        /** Retrieves a subtexture by name. Returns <code>null</code> if it is not found. */
        public function getTexture(name:String):Texture
        {
            var info:TextureInfo = mTextureInfos[name];
            
            if (info == null)
			{
				return null;
			}
            
			return Texture.fromTexture(mAtlasTexture, info.region, info.frame, info.rotated);
        }
        
        /** Returns all textures that start with a certain string, sorted alphabetically
         *  (especially useful for "MovieClip"). */
        public function getTextures(prefix:String="", result:Vector.<Texture>=null):Vector.<Texture>
        {
            if (result == null) result = new <Texture>[];
            
            for each (var name:String in getNames(prefix, sNames)) 
                result.push(getTexture(name)); 

            sNames.length = 0;
            return result;
        }
        
        /** Returns all texture names that start with a certain string, sorted alphabetically. */
        public function getNames(prefix:String="", result:Vector.<String>=null):Vector.<String>
        {
            if (result == null) result = new <String>[];
            
            for (var name:String in mTextureInfos)
                if (name.indexOf(prefix) == 0)
                    result.push(name);
            
            result.sort(Array.CASEINSENSITIVE);
            return result;
        }
        
        /** Returns the region rectangle associated with a specific name. */
        public function getRegion(name:String):Rectangle
        {
            var info:TextureInfo = mTextureInfos[name];
            return info ? info.region : null;
        }
        
        /** Returns the frame rectangle of a specific region, or <code>null</code> if that region 
         *  has no frame. */
        public function getFrame(name:String):Rectangle
        {
            var info:TextureInfo = mTextureInfos[name];
            return info ? info.frame : null;
        }

	    /** If true, the specified region in the atlas is rotated by 90 degrees (clockwise). The
	     *  SubTexture is thus rotated counter-clockwise to cancel out that transformation. */
	    public function getRotation(name:String):Boolean
	    {
		    var info:TextureInfo = mTextureInfos[name];
		    return info ? info.rotated : false;
	    }
        
        /** Adds a named region for a subtexture (described by rectangle with coordinates in 
         *  pixels) with an optional frame. */
        public function addRegion(name:String, region:Rectangle, frame:Rectangle=null,
                                  rotated:Boolean=false):void
        {
            mTextureInfos[name] = new TextureInfo(region, frame, rotated);
        }
        
        /** Removes a region with a certain name. */
        public function removeRegion(name:String):void
        {
            delete mTextureInfos[name];
        }
        
        /** The base texture that makes up the atlas. */
        public function get texture():Texture { return mAtlasTexture; }
        
        // utility methods
        
        private static function parseBool(value:String):Boolean
        {
            return value.toLowerCase() == "true";
        }
    }
}

