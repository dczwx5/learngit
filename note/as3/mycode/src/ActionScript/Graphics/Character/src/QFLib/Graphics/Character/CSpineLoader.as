package QFLib.Graphics.Character
{

import QFLib.Foundation;
import QFLib.Foundation.CMap;
import QFLib.Foundation.CPath;
import QFLib.Graphics.Character.model.CEquipSkinsInfo;
import QFLib.Graphics.RenderCore.CTextureAtlasLoader;
import QFLib.ResourceLoader.CQbinLoader;
import QFLib.ResourceLoader.CResource;
import QFLib.ResourceLoader.CResourceCache;
import QFLib.ResourceLoader.CResourceLoaders;
import QFLib.ResourceLoader.CXmlLoader;
import QFLib.ResourceLoader.ELoadingPriority;
import QFLib.Utils.Quality;

import flash.utils.ByteArray;

import spine.SkeletonData;
import spine.Skin;
import spine.animation.Animation;
import spine.animation.EventTimeline;
import spine.animation.FfdTimeline;
import spine.animation.Timeline;
import spine.attachments.Attachment;

import spineExt.CCharacterResourceData;

import spineExt.SkeletonBinary;
import spineExt.SkeletonJson;
import spineExt.TimeLineCache.FfdTimelineInCache;
import spineExt.TimeLineCache.TimelineCache;
import spineExt.starling.MeshAttachment;
import spineExt.starling.RegionAttachment;
import spineExt.starling.SkeletonAnimation;
import spineExt.starling.StarlingAtlasAttachmentLoader;
import spineExt.starling.WeightedMeshAttachment;

public class CSpineLoader
	{
		public function CSpineLoader()
		{
		}

        public function dispose() : void
        {
			m_sAtlasUrl = null;
			m_sSkeletonUrl = null;
            m_vSkinUrls = null;

            if( m_theSkeletonAnimation != null )
            {
                m_theSkeletonAnimation.removeFromParent();
                m_theSkeletonAnimation.dispose();
                m_theSkeletonAnimation = null;
            }

            if( m_theAnimationBounds != null )
            {
                m_theAnimationBounds.dispose();
                m_theAnimationBounds = null;
            }

            if( m_theSkeletonDataResource != null )
            {
                m_theSkeletonDataResource.dispose();
                m_theSkeletonDataResource = null;
            }

            if (m_mapTextureAtlasResourcesArray != null)
            {
                var aTextureAtlasResource:Array;
                for (var key : String in m_mapTextureAtlasResourcesArray)
                {
                    aTextureAtlasResource = m_mapTextureAtlasResourcesArray.find(key);
                    for each (var resource : CResource in aTextureAtlasResource)
                    {
                        resource.dispose();
                    }
                    aTextureAtlasResource = null;
                }
                m_mapTextureAtlasResourcesArray.clear();
                m_mapTextureAtlasResourcesArray = null;
            }
            m_aTextureAtlasResources = null;

            if( m_theSkeletonFileResource != null )
            {
                m_theSkeletonFileResource.dispose();
                m_theSkeletonFileResource = null;
            }

            if (m_theAtlasXmlResource != null)
            {
                m_theAtlasXmlResource.dispose();
                m_theAtlasXmlResource = null;
            }
            if( m_theAnimationClipInfoResource != null )
            {
                m_theAnimationClipInfoResource.dispose();
                m_theAnimationClipInfoResource = null;
            }

            m_fnOnLoadFinished = null;

            m_bAnimationBoundsReady = false;
            m_bTextureAtlasReady = false;
            m_bDisposed = true;
        }

        public function retrieveAllResources( vResources : Vector.<CResource> = null, iBeginIndex : int = 0 ) : int
        {
            var iCount : int = 0;
            if( m_theSkeletonAnimation != null )
            {
                if( m_theAnimationClipInfoResource != null )
                {
                    if( vResources != null ) vResources[ iBeginIndex + iCount ] = m_theAnimationClipInfoResource;
                    iCount++;
                }
                if( m_theAtlasXmlResource != null )
                {
                    if( vResources != null ) vResources[ iBeginIndex + iCount ] = m_theAtlasXmlResource;
                    iCount++;
                }
                if( m_theSkeletonDataResource != null )
                {
                    if( vResources != null ) vResources[ iBeginIndex + iCount ] = m_theSkeletonDataResource;
                    iCount++;
                }
                if( m_theSkeletonFileResource != null )
                {
                    if( vResources != null ) vResources[ iBeginIndex + iCount ] = m_theSkeletonFileResource;
                    iCount++;
                }
                if( m_aTextureAtlasResources != null )
                {
                    for each( var textureAtlas : CResource in m_aTextureAtlasResources )
                    {
                        if( textureAtlas != null )
                        {
                            if( vResources != null ) vResources[ iBeginIndex + iCount ] = textureAtlas;
                            iCount++;
                        }
                    }
                }
            }
            return iCount;
        }

        [Inline]
        final public function get loadingPriority() : int
        {
            return m_iLoadingPriority;
        }

        //
        // callback: function _onLoadFinished( theSpine : CSpineLoader, iResult : int ) : void
        //
        public function loadFile( sSkeletonUrl : String, sAtlasUrl : String, vMajorSkinUrl : Vector.<String>, theEquipSkinsInfo : CEquipSkinsInfo,
                                    iLoadingPriority : int = ELoadingPriority.NORMAL,
                                    onLoadFinished : Function = null, pArrResUrl : Array = null ) : Boolean
		{
            m_iLoadingPriority = iLoadingPriority;
            m_fnOnLoadFinished = onLoadFinished;

            var vSkinUrl : Vector.<String> = null;
            if (vMajorSkinUrl == null )
            {
                if (theEquipSkinsInfo != null)
                {
                    if (!theEquipSkinsInfo.isEquipsNull)
                    {
                        vSkinUrl = new Vector.<String>();
                        vMajorSkinUrl = new Vector.<String>(1);
                        vMajorSkinUrl[0] = CPath.driverDirName(sSkeletonUrl);
                        vSkinUrl.push(vMajorSkinUrl[0]);
                        vSkinUrl.push(theEquipSkinsInfo.equipURLs)
                    }
                }
            }
            else
            {
                vSkinUrl = new Vector.<String>();
                vSkinUrl.push(vMajorSkinUrl[0]);
                if (theEquipSkinsInfo != null)
                {
                    if (!theEquipSkinsInfo.isEquipsNull)
                    {
                        vSkinUrl.push(theEquipSkinsInfo.equipURLs)
                    }
                }
            }

            pArrResUrl.push( sAtlasUrl );
            pArrResUrl.push( sSkeletonUrl );
            for each ( var url : String in vSkinUrl )
            {
                pArrResUrl.push( url );
            }
            pArrResUrl.push( sSkeletonUrl );

            if( _loadAtlasXmlFile( sAtlasUrl, vSkinUrl ) == false ) return false;
            if( _loadSkeletonFile( sSkeletonUrl ) == false ) return false;

            m_theAnimationBounds.loadFile( sSkeletonUrl, this, m_iLoadingPriority, _onBoundLoadFinished );

            return true;
		}

        [Inline]
        final public function get skeletonAnimation() : SkeletonAnimation
        {
            return m_theSkeletonAnimation;
        }

        [Inline]
        final public function get animationBounds() : CAnimationBounds
        {
            return m_theAnimationBounds;
        }

        [Inline]
        final public function get getAnimationClipInfos() : CMap
        {
            return m_theAnimationClipInfoResource.theObject as CMap;
        }

        [Inline]
        final public function get skeletonFilename() : String
        {
            return m_sSkeletonUrl;
        }

        [Inline]
        final public function get textureAtlasResourcesMap() : CMap
        {
            return m_mapTextureAtlasResourcesArray;
        }

        //
        // callback: function _onAtlasXmlLoadFinished( theSpine : CSpineLoader, iResult : int ) : void
        //
        private function _loadAtlasXmlFile( sAtlasUrl : String, vSkinUrl : Vector.<String>, bLoadSkin : Boolean = false ) : Boolean
        {
            if( sAtlasUrl == null || sAtlasUrl.length == 0 ) return false;
            var theSkinInfo : SkinInfo = new SkinInfo();
            theSkinInfo.sAtlasUrl = sAtlasUrl;
            theSkinInfo.bLoadSkin = bLoadSkin;
            theSkinInfo.vSkinUrl = vSkinUrl;

            CResourceLoaders.instance().startLoadFile( sAtlasUrl, _onAtlasXmlLoadFinished, null, m_iLoadingPriority, false, false, null, theSkinInfo );
            return true;
        }

        private function _loadSkeletonFile( sSkeletonUrl : String ) : Boolean
        {
            if( sSkeletonUrl == null || sSkeletonUrl.length == 0 ) return false;

            sSkeletonUrl = CPath.driverDirName( sSkeletonUrl );
            if( m_sSkeletonUrl == sSkeletonUrl ) return true;

            m_sSkeletonUrl = sSkeletonUrl;

            var vSkeletonFilenames : Vector.<String> = new Vector.<String>( 2 );
            vSkeletonFilenames[0] = sSkeletonUrl + ".qbin";
            vSkeletonFilenames[1] = sSkeletonUrl + ".json";
            CResourceLoaders.instance().startLoadFileFromPathSequence( vSkeletonFilenames, _onSkeletonLoadFinished, CQbinLoader.NAME, m_iLoadingPriority );

            return true;
		}

        //
        //
        private function _onAtlasXmlLoadFinished( loader : CXmlLoader, idErrorCode : int ) : void
        {
            if( m_bDisposed ) return ;
            if( idErrorCode != 0 ) return;

            var theSkinInfo : SkinInfo = loader.arguments[0];

            theSkinInfo.theAtlasXmlResource = loader.createResource();
            AssetsSize += theSkinInfo.theAtlasXmlResource.resourceSize;
            var theXml : Object = theSkinInfo.theAtlasXmlResource.theObject as XML;
//            var listAtlas : XMLList = theXml.descendants( "Atlas" );
//            if( listAtlas == null || listAtlas.length() == 0 )
//                theXml = XML( "<Atlas>" + theXml.toString() + "</Atlas>" );

            var listTextureAtlas : XMLList = theXml.descendants( "TextureAtlas" );
            var iNumTextureAtlases : int = listTextureAtlas.length();
            theSkinInfo.aTextureAtlasResources = new Array( iNumTextureAtlases );

            var i : int;
            var iTextureAtlasCounts : int = 0;

            var sLoadingSkinName : String = null;
            var vSkinUrl : Vector.<String> = theSkinInfo.vSkinUrl;
            // if vSkinUrl == null  , png path will be get from atlas
            if (vSkinUrl == null)
            {
                var sPathUrl : String = CPath.driverDir( theSkinInfo.sAtlasUrl );
                vSkinUrl = new Vector.<String>(iNumTextureAtlases);
                for ( i = 0; i < iNumTextureAtlases; ++i)
                {
                    vSkinUrl[i] = sPathUrl + listTextureAtlas[i].@imagePath;
                    vSkinUrl[i] = CPath.driverDirName(vSkinUrl[i]);
                }
                theSkinInfo.vSkinUrl = vSkinUrl;
                if(listTextureAtlas != null && listTextureAtlas.length() > 0)
                {
                    sLoadingSkinName = CPath.name(listTextureAtlas[0].@imagePath);
                    for  (i = 1; i < listTextureAtlas.length; ++i)
                    {
                        sLoadingSkinName += "-" + CPath.name(listTextureAtlas[i].@imagePath);
                    }
                }
                if(m_theSkeletonAnimation != null &&  m_theSkeletonAnimation.skeleton.data.findSkin(sLoadingSkinName) != null)
                {
                    m_theSkeletonAnimation.skeleton.skinName = sLoadingSkinName;
                    return;
                }
            }
            else if(vSkinUrl.length > 0)
            {
                sLoadingSkinName = CPath.name(vSkinUrl[0]);
                for  (i = 1; i < vSkinUrl.length; ++i)
                {
                    sLoadingSkinName += "-" + CPath.name(vSkinUrl[i]);
                }
            }
            theSkinInfo.sLoadingSkinName = sLoadingSkinName;

            if( iNumTextureAtlases == 0 )
            {
                theSkinInfo.theAtlasXmlResource.dispose();
                theSkinInfo.theAtlasXmlResource = null;
                m_bTextureAtlasReady = true;

                _createSkeletonDataResourceIfReady();
            }
            else
            {
                for( i = 0; i < iNumTextureAtlases; i++ )
                {
                    var vSkinFilenames : Vector.<String> = new Vector.<String>();
                    if(Quality.isLowQualityOfRender)
                    {
                        if(Quality.knifeImageManualSwitch)
                        {
                            vSkinFilenames[ 0 ] = vSkinUrl[i] + "_ko.png";
                        }
                        else
                        {
                            vSkinFilenames[ 0 ] = vSkinUrl[i] + ".png";
                        }
                    }
                    else
                    {
                        vSkinFilenames[ 0 ] = vSkinUrl[i] + ".atf";
                        vSkinFilenames[ 1 ] = vSkinUrl[i] + ".png";
                    }
                    CResourceLoaders.instance().startLoadFileFromPathSequence( vSkinFilenames, onTextureAtlasLoadFinished, CTextureAtlasLoader.NAME, m_iLoadingPriority,
                                                                            false, false, null, i, listTextureAtlas[ i ], theSkinInfo.sAtlasUrl, theSkinInfo );
                }
            }

            function onTextureAtlasLoadFinished( loader : CTextureAtlasLoader, idErrorCode : int ) : void
            {
                var theSkinInfo : SkinInfo = loader.arguments[3];
                if( m_bDisposed )
                {
                    theSkinInfo.dispose();
                    return;
                }

                if( idErrorCode != 0 )
                {
                    theSkinInfo.dispose();
                    Foundation.Log.logErrorMsg( "onTextureLoadFinished(): Can not load texture: " + loader.loadingFilename );
                    return ;
                }

                var theTextureAtlasResource : CResource = loader.createResource();
                if( theTextureAtlasResource == null )
                {
                    theSkinInfo.dispose();
                    Foundation.Log.logErrorMsg( "onTextureAtlasLoadFinished(): cannot get texture atlas's data( null): " + loader.loadingFilename );
                    return ;
                }

                var iTexIdx : int = loader.arguments[ 0 ];
                theSkinInfo.aTextureAtlasResources[ iTexIdx ] = theTextureAtlasResource;
                AssetsSize += theTextureAtlasResource.resourceSize;
                CCharacterResourceData.addResource(theTextureAtlasResource.name.replace(".atf",".json"),theTextureAtlasResource.name,theTextureAtlasResource.resourceSize);

                iTextureAtlasCounts++;
                if( iTextureAtlasCounts == iNumTextureAtlases )
                {
                    m_bTextureAtlasReady = true;

                    if (m_mapTextureAtlasResourcesArray == null)
                    {
                        m_mapTextureAtlasResourcesArray = new CMap();
                    }
                    if (m_mapTextureAtlasResourcesArray.find(theSkinInfo.sLoadingSkinName) == null)
                    {
                        m_mapTextureAtlasResourcesArray.add(theSkinInfo.sLoadingSkinName ,theSkinInfo.aTextureAtlasResources);
                    }

                    m_vSkinUrls = theSkinInfo.vSkinUrl;
                    m_sAtlasUrl = theSkinInfo.sAtlasUrl;
                    for (var m : int = 0 ; m < theSkinInfo.aTextureAtlasResources.length; ++m)
                        (theSkinInfo.aTextureAtlasResources[m] as CResource).clone();
                    m_aTextureAtlasResources = theSkinInfo.aTextureAtlasResources;
                    m_theAtlasXmlResource = theSkinInfo.theAtlasXmlResource.clone();
                    if (theSkinInfo.bLoadSkin)
                    {
                        _attachSkin(theSkinInfo.sLoadingSkinName , theSkinInfo.aTextureAtlasResources , m_theSkeletonAnimation.skeleton.data);
                        m_theSkeletonAnimation.skeleton.skinName = theSkinInfo.sLoadingSkinName;
                    }
                    else
                    {
                        _createSkeletonDataResourceIfReady();
                    }

                    theSkinInfo.dispose();
                    theSkinInfo = null;
                }
            }
        }

        private function _attachSkin( skinName : String , aTextureAtlasResources :Array , skeletonData : SkeletonData): void
        {
            var data : SkeletonData = skeletonData;
            if (data.findSkin(skinName) != null)
                return;
            var attachmentLoader:StarlingAtlasAttachmentLoader = new StarlingAtlasAttachmentLoader(aTextureAtlasResources[0].theObject);
            var length:int = aTextureAtlasResources.length;
            var i : int;
            for (i  = 1; i < length; ++i) {
                attachmentLoader.addPage(aTextureAtlasResources[i].theObject);
            }
            var oldSkin:Skin = data.defaultSkin;

            //append skin data
            var theSkeletonJson : SkeletonJson = new SkeletonJson();
            var skin:Skin = new Skin(skinName);
            var attachment : Attachment = null;
            length = oldSkin.attachments.length;
            for (i = 0 ;i < length ; ++i)
            {
                for (var attachmentName : String in oldSkin.attachments[i])
                {
                    attachment = theSkeletonJson.getAttachment(oldSkin.attachments[i][attachmentName],attachmentLoader,oldSkin,i);
                    skin.addAttachment(i ,attachmentName ,attachment);
                }
            }
            data.skins.push(skin);
            theSkeletonJson.linkMeshes(data);

            // append animation data
            var duration : Number, timelines :Vector.<Timeline>, animationName : String, ffdTimeline : FfdTimeline;
            var tempTimeline : FfdTimeline;
            length = data.animations.length;
            for (i = 0; i < length; ++i)
            {
                duration = data.animations[i].duration;
                animationName = data.animations[i].name;
                timelines = new Vector.<Timeline>();
                for each (var timeline : Timeline in data.animations[i].timelines)
                {
                    timelines.push(timeline);
                    if (timeline is FfdTimeline)
                    {
                        tempTimeline = timeline as FfdTimeline;
                        ffdTimeline = new FfdTimelineInCache( tempTimeline.frameCount );
                        ffdTimeline.slotIndex = tempTimeline.slotIndex;
                        ffdTimeline.attachment = skin.getAttachment(ffdTimeline.slotIndex, tempTimeline.attachment.name);
                        ffdTimeline.frames = tempTimeline.frames;
                        ffdTimeline.frameVertices = tempTimeline.frameVertices;
                        ffdTimeline.setCurves(tempTimeline.getCurves());
                        if (TimelineCache.FrameCacheEnabled)
                            (ffdTimeline as FfdTimelineInCache).m_vvCacheVertices = (tempTimeline as FfdTimelineInCache).m_vvCacheVertices;

                        timelines.push(ffdTimeline);
                    }
                }

                data.animations[i] = new Animation(animationName, timelines, duration);
            }

            theSkeletonJson.dispose();
            theSkeletonJson = null;
            m_aTextureAtlasResources = aTextureAtlasResources;
        }

        private function _onSkeletonLoadFinished(  loader : CQbinLoader, idErrorCode : int  ) : void
        {
            if( m_bDisposed ) return ;

            if( idErrorCode == 0 )
            {
                Foundation.Perf.sectionBegin( "CharacterObject_onSkeletonLoadFinished_createResource" );
                m_theSkeletonFileResource = loader.createResource();
                Foundation.Perf.sectionEnd( "CharacterObject_onSkeletonLoadFinished_createResource" );
                _createSkeletonDataResourceIfReady();
                AssetsSize += m_theSkeletonFileResource.resourceSize;
                CCharacterResourceData.addResource(m_sSkeletonUrl+".json",loader.filename,m_theSkeletonFileResource.resourceSize);
            }
        }

        private function _onBoundLoadFinished( theBounds : CAnimationBounds, iResult : int ) : void
        {
            if( m_bDisposed ) return;

            m_bAnimationBoundsReady = true;
            _createSkeletonDataResourceIfReady();
        }

        private function _createSkeletonDataResourceIfReady() : void
		{
            if( m_theSkeletonFileResource != null && m_bTextureAtlasReady && m_bAnimationBoundsReady )
            {
                //
                // currently don't support changing skins
                //
                m_theSkeletonDataResource = CResourceCache.instance().create( m_sSkeletonUrl, ".SKDATA" );
                var skinName : String;
                if( m_theSkeletonDataResource == null )
                {
                    Foundation.Perf.sectionBegin( "CharacterObject_createSkeletonDataResourceIfReady" );

                    var atlasAttachmentLoader : StarlingAtlasAttachmentLoader = null;
                    if( m_aTextureAtlasResources &&  m_aTextureAtlasResources.length > 0 ) {
                        atlasAttachmentLoader  = new StarlingAtlasAttachmentLoader( m_aTextureAtlasResources[ 0 ].theObject );
                        for ( var i : int = 1; i < m_aTextureAtlasResources.length; i++ ) atlasAttachmentLoader.addPage( m_aTextureAtlasResources[ i ].theObject );
                    }

                    if (m_vSkinUrls != null)
                    {
                        skinName = CPath.name( m_vSkinUrls[ 0 ] );
                        for  (i = 1; i < m_vSkinUrls.length; ++i)
                        {
                            skinName += "-" + CPath.name(m_vSkinUrls[i]);
                        }
                    }
                    else
                        skinName = "default";

                    if (m_theSkeletonFileResource.theObject is ByteArray) {
                        var theSkeletonBinary:SkeletonBinary = new SkeletonBinary(atlasAttachmentLoader);
                        var theSkeletonData:SkeletonData = theSkeletonBinary.createSkeletonData(m_theSkeletonFileResource.theObject as ByteArray, skinName, m_sSkeletonUrl);

                        theSkeletonBinary.dispose();
                        theSkeletonBinary = null;
                    }
                    else
                    {
                        var theSkeletonJson:SkeletonJson = new SkeletonJson(atlasAttachmentLoader);
                        theSkeletonData = theSkeletonJson.createSkeletonData(m_theSkeletonFileResource.theObject, skinName, m_sSkeletonUrl);

                        theSkeletonJson.dispose();
                        theSkeletonJson = null;
                    }
                    m_theSkeletonDataResource = new CResource( m_sSkeletonUrl, ".SKDATA", theSkeletonData );
                    CResourceCache.instance().add( m_sSkeletonUrl, ".SKDATA", m_theSkeletonDataResource, true, true );

                    Foundation.Perf.sectionEnd( "CharacterObject_createSkeletonDataResourceIfReady" );
                }
                else
                {
                    var skeletonData : SkeletonData = SkeletonData(m_theSkeletonDataResource.theObject);
                    if ( m_vSkinUrls != null && m_vSkinUrls.length > 0)
                    {
                        skinName = CPath.name(m_vSkinUrls[0]);
                        for  (i = 1; i < m_vSkinUrls.length; ++i)
                        {
                            skinName += "-" + CPath.name(m_vSkinUrls[i]);
                        }
                        if (skeletonData.findSkin(skinName) == null)
                        {
                            _attachSkin(skinName,m_aTextureAtlasResources, skeletonData);
                        }
                        else
                        {
                            // skeletonData contains not only one character skin, so if some other character is disposed , the opposite texture is also disposed;
                            var isTextureDisposed : Boolean = true;
                            var skin : Skin = skeletonData.findSkin(skinName);
                            var length : int = skin.attachments.length;
                            for ( i = 0; i < length; ++i)
                            {
                                for each ( var attachment : Attachment in skin.attachments[i])
                                {
                                    if (attachment == null)
                                        continue;
                                    if (attachment is RegionAttachment)
                                    {
                                        if ((attachment as RegionAttachment).texture != null && (attachment as RegionAttachment).texture.base != null)
                                        {
                                            isTextureDisposed = false;
                                            break;
                                        }
                                    }
                                    else if (attachment is MeshAttachment)
                                    {
                                        if ((attachment as MeshAttachment).texture != null && (attachment as MeshAttachment).texture.base != null)
                                        {
                                            isTextureDisposed = false;
                                            break;
                                        }
                                    }
                                    else if (attachment is WeightedMeshAttachment)
                                    {
                                        if ((attachment as WeightedMeshAttachment).texture != null && (attachment as WeightedMeshAttachment).texture.base != null)
                                        {
                                            isTextureDisposed = false;
                                            break;
                                        }
                                    }
                                    if (isTextureDisposed)
                                        break;
                                }
                            }
                            if (isTextureDisposed)
                            {
                                length = skeletonData.skins.length;
                                for (i = 0; i < length; ++i)
                                {
                                    if (skeletonData.skins[i ].name == skinName)
                                    {
                                        skeletonData.skins.splice(i,1);
                                        _attachSkin(skinName, m_aTextureAtlasResources, skeletonData);
                                    }
                                }
                            }
                         }
                    }
                }

                _createSkeletonAnimation( SkeletonData(m_theSkeletonDataResource.theObject),skinName  );
            }
		}

        private function _createSkeletonAnimation( theSkeletonData : SkeletonData, skinName : String) : void
        {
            if( theSkeletonData == null ) return ;

            Foundation.Perf.sectionBegin( "CharacterObject_createSkeletonAnimation" );

            m_theSkeletonAnimation = new SkeletonAnimation( theSkeletonData, true, null );
            m_theSkeletonAnimation.name = m_sAtlasUrl;
            if (skinName != null && m_theSkeletonAnimation.skeleton.data.findSkin(skinName) != null)
                m_theSkeletonAnimation.skeleton.skinName = skinName;
            m_theAnimationClipInfoResource = CResourceCache.instance().create( m_sSkeletonUrl, ".ANICLIPINFO" );
            if( m_theAnimationClipInfoResource == null )
            {
                var mapAnimationClipInfos : CMap = new CMap();
                _generateAnimationClipInfos( mapAnimationClipInfos );

                m_theAnimationClipInfoResource = new CResource( m_sSkeletonUrl, ".ANICLIPINFO", mapAnimationClipInfos );
                CResourceCache.instance().add( m_sSkeletonUrl, ".ANICLIPINFO", m_theAnimationClipInfoResource );
            }

            // create empty if load failed
            if( m_theAnimationBounds.isEmpty ) m_theAnimationBounds.createEmptyAnimationBounds( this );

            Foundation.Perf.sectionEnd( "CharacterObject_createSkeletonAnimation" );

            // begin of debug
            if( m_bLoadFinishedCalled )
            {
                Foundation.Log.logErrorMsg( "Should not call m_fnOnLoadFinished twice!!" );
            }
            else m_bLoadFinishedCalled = true;
            // end of debug

            if( m_fnOnLoadFinished != null )
            {
                m_fnOnLoadFinished( this, 0 ); // 0 means load successfully
                m_fnOnLoadFinished = null;
            }
        }

        private function _generateAnimationClipInfos( mapAnimationClipInfos : CMap ) : void // split and generate animation-clip-info for each animation by the event
        {
            if( m_theSkeletonAnimation == null || m_theSkeletonAnimation.skeleton == null ) return;

            // sort the animation array cuz the data from json is not guaranteed the order
            m_theSkeletonAnimation.stateData.skeletonData.animations.sort( Array.CASEINSENSITIVE );

            var theAnimationClipInfo : CAnimationClipInfo = null;

            var aAnimations : Vector.<Animation> = m_theSkeletonAnimation.stateData.skeletonData.animations;
            for( var i : int = 0, n : int = aAnimations.length ; i < n ; ++i )
            {
                for each( var timeline : Timeline in aAnimations[i].timelines )
                {
                    if( timeline is EventTimeline )
                    {
                        //noinspection JSUnresolvedVariable
                        var et : EventTimeline = timeline as EventTimeline;
                        for (var j : int = 0 ; j < et.events.length ; ++j)
                        {
                            var sEventName : String = et.events[ j ].data.name;
                            if( sEventName.indexOf( EVENT_SPLIT_PREFIX_LABEL ) != 0 ) continue;

                            theAnimationClipInfo = new CAnimationClipInfo();
                            theAnimationClipInfo.m_sEventName = sEventName;
                            theAnimationClipInfo.m_fStartTime = et.events[ j ].time;
                            if ( j < et.events.length - 1 )
                            {
                                theAnimationClipInfo.m_fEndTime = et.events[ j + 1 ].time;
                            }
                            else
                            {
                                theAnimationClipInfo.m_fEndTime = aAnimations[i].duration;
                            }

                            theAnimationClipInfo.m_fDuration = theAnimationClipInfo.m_fEndTime - theAnimationClipInfo.m_fStartTime;
                            theAnimationClipInfo.m_sAnimationName = aAnimations[ i ].name;
                            theAnimationClipInfo.m_iAnimationIndex = i;

                            var sPostFix : String = theAnimationClipInfo.m_sEventName.substr( EVENT_SPLIT_PREFIX_LABEL.length );
                            var sName : String = aAnimations[ i ].name + sPostFix;
                            mapAnimationClipInfos.add( sName, theAnimationClipInfo );
                        }
                    }
                }

                //add no event animation
                theAnimationClipInfo = new CAnimationClipInfo();
                theAnimationClipInfo.m_sEventName = "";
                theAnimationClipInfo.m_fStartTime = 0;
                theAnimationClipInfo.m_fEndTime = aAnimations[i].duration;
                theAnimationClipInfo.m_fDuration = theAnimationClipInfo.m_fEndTime;
                theAnimationClipInfo.m_sAnimationName = aAnimations[i].name;
                theAnimationClipInfo.m_iAnimationIndex = i;

                mapAnimationClipInfos.add( theAnimationClipInfo.m_sAnimationName,theAnimationClipInfo );
            }
        }
         //if (sSkinUrls == null)  load atlas pngs ; else  load sSkinUrls;
         public function loadSkin( sAtlasUrl : String, sSkinUrl : Vector.<String> ): void
        {
            _loadAtlasXmlFile( sAtlasUrl, sSkinUrl, true ) ;
        }

        //
        private static const EVENT_SPLIT_PREFIX_LABEL : String = "split";

        public var AssetsSize : int = 0;

        private var m_sSkeletonUrl : String = "";
        private var m_sAtlasUrl : String = "";
        private var m_vSkinUrls : Vector.<String> = null;
        private var m_iLoadingPriority : int = ELoadingPriority.NORMAL;

        private var m_fnOnLoadFinished : Function = null;

        private var m_mapTextureAtlasResourcesArray :CMap = null;
        private var m_aTextureAtlasResources :Array = null; // m_aTextureAtlasResources is one member in the m_mapTextureAtlasResourcesArray
        private var m_theSkeletonFileResource : CResource = null;
        private var m_theSkeletonDataResource : CResource = null;
        private var m_theAtlasXmlResource : CResource = null;
        private var m_theAnimationClipInfoResource : CResource = null;

        private var m_theSkeletonAnimation : SkeletonAnimation = null;
        private var m_theAnimationBounds : CAnimationBounds = new CAnimationBounds();

        private var m_bAnimationBoundsReady : Boolean = false;
        private var m_bTextureAtlasReady : Boolean = false;
        private var m_bDisposed : Boolean = false;

        // for debug
        private var m_bLoadFinishedCalled : Boolean = false;
    }
}

import QFLib.Interface.IDisposable;
import QFLib.ResourceLoader.CResource;

class SkinInfo implements IDisposable {
    public function SkinInfo() {
    }

    public function dispose():void {
        sAtlasUrl = null;
        vSkinUrl = null;
        sLoadingSkinName = null;
        if (theAtlasXmlResource != null)
        {
            theAtlasXmlResource.dispose();
            theAtlasXmlResource = null;
        }
        if( aTextureAtlasResources != null )
        {
            for each( var resource : CResource in aTextureAtlasResources )
            {
                resource.dispose();
                resource = null;
             }
        }
    }

    //
    public var bLoadSkin : Boolean = false;
    public var sAtlasUrl : String = null;
    public var vSkinUrl : Vector.<String> = null;
    public var sLoadingSkinName : String = null;
    public var theAtlasXmlResource : CResource = null;
    public var aTextureAtlasResources :Array = null;

}


