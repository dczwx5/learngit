/**
 * (C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
 * Created on 2016/5/11.
 */
package spineExt.starling
{
	import QFLib.Graphics.RenderCore.starling.textures.SubTexture;
	import QFLib.Graphics.RenderCore.starling.textures.Texture;
	import QFLib.Graphics.RenderCore.starling.textures.TextureAtlas;

	import flash.geom.Rectangle;

	import spine.Skin;
	import spine.starling.StarlingAtlasAttachmentLoader;

	public class StarlingAtlasAttachmentLoader extends spine.starling.StarlingAtlasAttachmentLoader
	{
		private var _pages:Vector.<TextureAtlas>;

		public function StarlingAtlasAttachmentLoader( texAtlas : TextureAtlas )
		{
			super( texAtlas );
            addPage( texAtlas );
		}

		public function dispose():void
		{
			if(_pages)
			{
				_pages.length = 0;
				_pages = null;
			}
		}

		public function addPage(atlas:TextureAtlas):void
		{
			if (_pages == null)
			{
				_pages = new Vector.<TextureAtlas>();
			}

			if (_pages.indexOf(atlas) == -1)
			{
				_pages.push(atlas);
			}
		}

		public function newRegionAttachmentEx (skin:Skin, name:String, path:String) : RegionAttachment
		{
			return _newRegionAttachment(skin, name, path, _pages);
		}

		public function newMeshAttachmentEx (skin:Skin, name:String, path:String) : MeshAttachment{
			return _newMeshAttachment(skin, name, path, _pages);
		}

		public function newWeightedMeshAttachmentEx (skin:Skin, name:String, path:String) : WeightedMeshAttachment
		{
			return _newWeightedMeshAttachment(skin, name, path, _pages);
		}

		private static function _newRegionAttachment (skin:Skin, name:String, path:String, pages:Vector.<TextureAtlas>) : RegionAttachment
		{
            var arr : Array = [0];
			var texture:Texture = findTexture(name, path, pages, arr);

			if (texture == null)
			{
				throw new Error("Region not found in Starling atlas: " + path + " (region attachment: " + name + ")");
			}

			// It's frame fixed in attachment
			texture.ignoreFrame = true;

			var attachment:RegionAttachment = new RegionAttachment(name);
			var frame:Rectangle = texture.frame;
			if (frame == null)
			{
				frame = new Rectangle(0, 0, texture.width, texture.height);
			}

			texture = Texture.fromTexture(texture);
            var subTexture : SubTexture = texture as SubTexture;
            if ( subTexture )
            {
                var root : Texture = subTexture.root;
                var rectRegion : Rectangle = pages[ arr[ 0 ] ].getRegion ( path );
                var u : Number = rectRegion.x / root.width;
                var v : Number = rectRegion.y / root.height;
                var u2 : Number = (rectRegion.x + subTexture.width) / root.width;
                var v2 : Number = (rectRegion.y + subTexture.height) / root.height;
                attachment.setUVs ( u, v, u2, v2, pages[ arr[ 0 ] ].getRotation ( path ) );
            } else
            {
                attachment.setUVs ( 0, 1, 1, 0, pages[ arr[ 0 ] ].getRotation ( path ) );
            }

            attachment.texture = texture;

			attachment.regionOffsetX = -frame.x;
			attachment.regionOffsetY = -frame.y;
			attachment.regionWidth = texture.width;
			attachment.regionHeight = texture.height;
			attachment.regionOriginalWidth = frame.width;
			attachment.regionOriginalHeight = frame.height;
			return attachment;
		}

		private static function _newMeshAttachment (skin:Skin, name:String, path:String, pages:Vector.<TextureAtlas>) : MeshAttachment
		{
			var texture:Texture = findTexture(name, path, pages);

			if (texture == null)
			{
				throw new Error("Region not found in Starling atlas: " + path + " (region attachment: " + name + ")");
			}

			// It's frame fixed in attachement
			texture.ignoreFrame = true;

			var attachment:MeshAttachment = new MeshAttachment(name);

			var frame:Rectangle = texture.frame;
			if (frame == null) {
				frame = new Rectangle(0, 0, texture.width, texture.height);
			}

			var subTexture:SubTexture = texture as SubTexture;
			if (subTexture)
			{
				var clipping:Rectangle = subTexture.clipping;
				attachment.regionRotate = subTexture.rotated;
				var invw:Number = 1 / subTexture.parent.width;
				var invh:Number = 1 / subTexture.parent.height;

				if (attachment.regionRotate)
				{
					attachment.regionU = clipping.x - (frame.y + frame.width  - texture.width) * invw;
					attachment.regionV = clipping.y + frame.x * invh;
					attachment.regionU2 = attachment.regionU + frame.height * invw;
					attachment.regionV2 = attachment.regionV + frame.width * invh;
				}
				else
				{
					attachment.regionU = clipping.x + frame.x * invw;
					attachment.regionV = clipping.y + frame.y * invh;
					attachment.regionU2 = attachment.regionU + frame.width * invw;
					attachment.regionV2 = attachment.regionV + frame.height * invh;
				}
			}
			else
			{
				attachment.regionU = 0;
				attachment.regionV = 1;
				attachment.regionU2 = 1;
				attachment.regionV2 = 0;
			}

			texture = Texture.fromTexture(texture);
            attachment.texture = texture;
			attachment.regionOffsetX = -frame.x;
			attachment.regionOffsetY = -frame.y;
			attachment.regionWidth = texture.width;
			attachment.regionHeight = texture.height;
			attachment.regionOriginalWidth = frame.width;
			attachment.regionOriginalHeight = frame.height;
			return attachment;
		}

		private static function _newWeightedMeshAttachment (skin:Skin, name:String, path:String, pages:Vector.<TextureAtlas>) : WeightedMeshAttachment
		{
			var texture:Texture = findTexture(name, path, pages);

			if (texture == null)
			{
				throw new Error("Region not found in Starling atlas: " + path + " (region attachment: " + name + ")");
			}

			// It's frame fixed in attachement
			texture.ignoreFrame = true;

			var attachment:WeightedMeshAttachment = new WeightedMeshAttachment(name);

			var frame:Rectangle = texture.frame;
			if (frame == null)
			{
				frame = new Rectangle(0, 0, texture.width, texture.height);
			}

			var subTexture:SubTexture = texture as SubTexture;
			if (subTexture)
			{
				var clipping:Rectangle = subTexture.clipping;
				attachment.regionRotate = subTexture.rotated;
				var invw:Number = 1 / subTexture.parent.width;
				var invh:Number = 1 / subTexture.parent.height;

				if (attachment.regionRotate)
				{
					attachment.regionU = clipping.x - (frame.y + frame.width  - texture.width) * invw;
					attachment.regionV = clipping.y + frame.x * invh;
					attachment.regionU2 = attachment.regionU + frame.height * invw;
					attachment.regionV2 = attachment.regionV + frame.width * invh;
				}
				else
				{
					attachment.regionU = clipping.x + frame.x * invw;
					attachment.regionV = clipping.y + frame.y * invh;
					attachment.regionU2 = attachment.regionU + frame.width * invw;
					attachment.regionV2 = attachment.regionV + frame.height * invh;
				}
			}
			else
			{
				attachment.regionU = 0;
				attachment.regionV = 1;
				attachment.regionU2 = 1;
				attachment.regionV2 = 0;
			}

			texture = Texture.fromTexture(texture);
            attachment.texture = texture;
			attachment.regionOffsetX = -frame.x;
			attachment.regionOffsetY = -frame.y;
			attachment.regionWidth = texture.width;
			attachment.regionHeight = texture.height;
			attachment.regionOriginalWidth = frame.width;
			attachment.regionOriginalHeight = frame.height;
			return attachment;
		}

		private static function findTexture(name:String, path:String, pages:Vector.<TextureAtlas>, arr : Array = null):Texture
		{
			var texture:Texture = null;

			// throw exception if pages is null
			for (var i:int = pages.length - 1; i >= 0; i--)
			{
				if (pages[i].ImageName == path)
				{
					texture = pages[i].getTexture(name);
					if (texture != null)
					{
                        if ( arr != null ) arr[ 0 ] = i;
						return texture;
					}
				}
			}

			// 如果上面没找到，则使用宽松规则找
			for (i = pages.length - 1; i >= 0; i--)
			{
				texture = pages[i].getTexture(path);
				if (texture != null)
				{
                    if ( arr != null ) arr[ 0 ] = i;
					return texture;
				}

				texture = pages[i].getTexture(name);
				if (texture != null)
				{
                    if ( arr != null ) arr[ 0 ] = i;
					return texture;
				}
			}

			return texture;
		}
	}
}
