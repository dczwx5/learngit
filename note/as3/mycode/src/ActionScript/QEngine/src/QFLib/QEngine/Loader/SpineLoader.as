/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Loader
{
    import QFLib.Foundation;
    import QFLib.Foundation.CMap;
    import QFLib.Foundation.CPath;
    import QFLib.QEngine.Animation.AnimationClipInfo;
    import QFLib.QEngine.Animation.SpineExt.AnimationBounds;
    import QFLib.QEngine.Renderer.Entities.SkeletonAnimation;
    import QFLib.QEngine.Renderer.Entities.SpineExtension.AtlasAttachmentLoader;
    import QFLib.QEngine.Renderer.Entities.SpineExtension.SkeletonJsonExt;
    import QFLib.QEngine.ThirdParty.Spine.SkeletonData;
    import QFLib.QEngine.ThirdParty.Spine.Skin;
    import QFLib.QEngine.ThirdParty.Spine.animation.Animation;
    import QFLib.QEngine.ThirdParty.Spine.animation.EventTimeline;
    import QFLib.QEngine.ThirdParty.Spine.animation.Timeline;
    import QFLib.QEngine.ThirdParty.Spine.attachments.Attachment;
    import QFLib.ResourceLoader.CQsonLoader;
    import QFLib.ResourceLoader.CResource;
    import QFLib.ResourceLoader.CResourceCache;
    import QFLib.ResourceLoader.CResourceLoaders;
    import QFLib.ResourceLoader.CXmlLoader;
    import QFLib.ResourceLoader.ELoadingPriority;

    //
    //
    //
    public class SpineLoader
    {
        private static const EVENT_SPLIT_PREFIX_LABEL : String = "split";

        public function SpineLoader()
        {
        }

        //
        // callback: function _onLoadFinished( theSpine : CSpineLoader, iResult : int ) : void
        //
        private var m_sSkeletonUrl : String = "";
        private var m_sAtlasUrl : String = "";
        private var m_vSkinUrls : Vector.<String> = null;
        private var m_fnOnAtlasLoadFinished : Function = null;
        private var m_fnOnSkeletonLoadFinished : Function = null;
        private var m_fnOnLoadFinished : Function = null;

        //
        // callback: function _onAtlasXmlLoadFinished( theSpine : CSpineLoader, iResult : int ) : void
        //
        private var m_mapTextureAtlasResourcesArray : CMap = null;
        private var m_aTextureAtlasResources : Array = null;

        //
        //
        private var m_theSkeletonJsonResource : CResource = null;
        private var m_theSkeletonDataResource : CResource = null;
        private var m_theAnimationClipInfoResource : CResource = null;
        private var m_theSkeletonAnimation : SkeletonAnimation = null;
        private var m_theAnimationBounds : AnimationBounds = new AnimationBounds();
        private var m_bAnimationBoundsReady : Boolean = false;
        private var m_bTextureAtlasReady : Boolean = false;

        //if (sSkinUrls == null)  load atlas pngs ; else  load sSkinUrls;
        private var m_bDisposed : Boolean = false;

        //

        [Inline]
        final public function get skeletonAnimation() : SkeletonAnimation
        {
            return m_theSkeletonAnimation;
        }

        [Inline]
        final public function get animationBounds() : AnimationBounds
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

        public function dispose() : void
        {
            m_sAtlasUrl = null;
            m_sSkeletonUrl = null;
            m_vSkinUrls = null;

            if( m_theSkeletonAnimation != null )
            {
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

            if( m_mapTextureAtlasResourcesArray != null )
            {
                var aTextureAtlasResource : Array;
                for( var key : String in m_mapTextureAtlasResourcesArray )
                {
                    aTextureAtlasResource = m_mapTextureAtlasResourcesArray.find( key );
                    for each ( var resource : CResource in aTextureAtlasResource )
                    {
                        resource.dispose();
                    }
                    aTextureAtlasResource = null;
                }
                m_mapTextureAtlasResourcesArray.clear();
                m_mapTextureAtlasResourcesArray = null;
            }

            if( m_theSkeletonJsonResource != null )
            {
                m_theSkeletonJsonResource.dispose();
                m_theSkeletonJsonResource = null;
            }

            if( m_theAnimationClipInfoResource != null )
            {
                m_theAnimationClipInfoResource.dispose();
                m_theAnimationClipInfoResource = null;
            }

            m_fnOnAtlasLoadFinished = null;
            m_fnOnSkeletonLoadFinished = null;
            m_fnOnLoadFinished = null;

            m_bAnimationBoundsReady = false;
            m_bTextureAtlasReady = false;
            m_bDisposed = true;
        }

        public function loadFile( sSkeletonUrl : String, sAtlasUrl : String, sSkinUrl : Vector.<String>, onLoadFinished : Function = null ) : Boolean
        {
            m_fnOnLoadFinished = onLoadFinished;

            if( _loadAtlasXmlFile( sAtlasUrl, sSkinUrl, _onAtlasLoadFinished ) == false ) return false;
            function _onAtlasLoadFinished( theSpine : SpineLoader, iResult : int ) : void
            {
            }

            if( _loadSkeletonFile( sSkeletonUrl, _onSkeletonLoadFinished ) == false ) return false;
            function _onSkeletonLoadFinished( theSpine : SpineLoader, iResult : int ) : void
            {
            }

            /** 先注释: 后期调整 **/
            //m_theAnimationBounds.loadFile ( sSkeletonUrl, this, _onBoundLoadFinished );

            return true;
        }

        public function loadSkin( sAtlasUrl : String, sSkinUrl : Vector.<String> ) : void
        {
            _loadAtlasXmlFile( sAtlasUrl, sSkinUrl, null, true );
        }

        private function _loadAtlasXmlFile( sAtlasUrl : String, vSkinUrl : Vector.<String>, onLoadFinished : Function, bLoadSkin : Boolean = false ) : Boolean
        {
            if( sAtlasUrl == null || sAtlasUrl.length == 0 ) return false;

            var theSkinInfo : SkinInfo = new SkinInfo();
            theSkinInfo.sAtlasUrl = sAtlasUrl;
            theSkinInfo.bLoadSkin = bLoadSkin;
            theSkinInfo.vSkinUrl = vSkinUrl;

            m_fnOnAtlasLoadFinished = onLoadFinished;

            CResourceLoaders.instance().startLoadFile( sAtlasUrl, _onAtlasXmlLoadFinished, null, ELoadingPriority.NORMAL, false, false, null, theSkinInfo );
            return true;
        }

        private function _loadSkeletonFile( sSkeletonUrl : String, onLoadFinished : Function ) : Boolean
        {
            if( sSkeletonUrl == null || sSkeletonUrl.length == 0 ) return false;

            sSkeletonUrl = CPath.driverDirName( sSkeletonUrl );
            if( m_sSkeletonUrl == sSkeletonUrl ) return true;

            m_sSkeletonUrl = sSkeletonUrl;
            m_fnOnSkeletonLoadFinished = onLoadFinished;

            //CResourceLoader.instance().startLoadFile( m_sSkeletonUrl, _onSkeletonLoadFinished );
            var vSkeletonFilenames : Vector.<String> = new Vector.<String>( 2 );
            vSkeletonFilenames[ 0 ] = sSkeletonUrl + ".qson";
            vSkeletonFilenames[ 1 ] = sSkeletonUrl + ".json";

            CResourceLoaders.instance().startLoadFileFromPathSequence( vSkeletonFilenames, _onSkeletonLoadFinished, CQsonLoader.NAME );
            return true;
        }

        private function _onAtlasXmlLoadFinished( loader : CXmlLoader, idErrorCode : int ) : void
        {
            if( m_bDisposed ) return;
            if( idErrorCode != 0 ) return;

            var theSkinInfo : SkinInfo = loader.arguments[ 0 ];

            theSkinInfo.theAtlasXmlResource = loader.createResource();
            var theXml : Object = theSkinInfo.theAtlasXmlResource.theObject as XML;
            var listAtlas : XMLList = theXml.descendants( "Atlas" );
            if( listAtlas == null || listAtlas.length() == 0 ) theXml = XML( "<Atlas>" + theXml.toString() + "</Atlas>" );

            var listTextureAtlas : XMLList = theXml.descendants( "TextureAtlas" );
            var iNumTextureAtlases : int = listTextureAtlas.length();
            theSkinInfo.aTextureAtlasResources = new Array( iNumTextureAtlases );

            var i : int;
            var iTextureAtlasCounts : int = 0;

            var sLoadingSkinName : String = null;
            var vSkinUrl : Vector.<String> = theSkinInfo.vSkinUrl;
            if( vSkinUrl == null ) // if vSkinUrl == null  , png path will be get from atlas
            {
                var sPathUrl : String = CPath.driverDir( theSkinInfo.sAtlasUrl );
                vSkinUrl = new Vector.<String>( iNumTextureAtlases );
                for( i = 0; i < iNumTextureAtlases; ++i )
                {
                    vSkinUrl[ i ] = sPathUrl + listTextureAtlas[ i ].@imagePath;
                    vSkinUrl[ i ] = CPath.driverDirName( vSkinUrl[ i ] );
                }
                if( listTextureAtlas != null && listTextureAtlas.length() > 0 )
                    sLoadingSkinName = CPath.name( sPathUrl + listTextureAtlas[ 0 ].@imagePath );

                if( m_theSkeletonAnimation != null && m_theSkeletonAnimation.skeleton.data.findSkin( sLoadingSkinName ) != null )
                {
                    m_theSkeletonAnimation.skeleton.skinName = sLoadingSkinName;
                    return;
                }
            }
            else if( vSkinUrl.length > 0 )
            {
                sLoadingSkinName = CPath.name( vSkinUrl[ 0 ] );
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
                    var vSkinFilenames : Vector.<String> = new Vector.<String>( 2 );
                    vSkinFilenames[ 0 ] = vSkinUrl[ i ] + ".atf";
                    vSkinFilenames[ 1 ] = vSkinUrl[ i ] + ".png";
                    CResourceLoaders.instance().startLoadFileFromPathSequence( vSkinFilenames, onTextureAtlasLoadFinished, TextureAtlasLoader.NAME, ELoadingPriority.NORMAL,
                            false, false, null, i, listTextureAtlas[ i ], theSkinInfo.sAtlasUrl, theSkinInfo );
                }
            }

            function onTextureAtlasLoadFinished( loader : TextureAtlasLoader, idErrorCode : int ) : void
            {
                var theSkinInfo : SkinInfo = loader.arguments[ 3 ];
                if( m_bDisposed )
                {
                    theSkinInfo.dispose();
                    return;
                }

                if( idErrorCode != 0 )
                {
                    theSkinInfo.dispose();
                    Foundation.Log.logErrorMsg( "onTextureLoadFinished(): Can not load texture: " + loader.loadingFilename );
                    return;
                }

                var theTextureAtlasResource : CResource = loader.createResource();
                if( theTextureAtlasResource == null )
                {
                    theSkinInfo.dispose();
                    Foundation.Log.logErrorMsg( "onTextureAtlasLoadFinished(): cannot get texture atlas's data( null): " + loader.loadingFilename );
                    return;
                }

                var iTexIdx : int = loader.arguments[ 0 ];
                theSkinInfo.aTextureAtlasResources[ iTexIdx ] = theTextureAtlasResource;

                iTextureAtlasCounts++;
                if( iTextureAtlasCounts == iNumTextureAtlases )
                {
                    m_bTextureAtlasReady = true;

                    if( m_mapTextureAtlasResourcesArray == null )
                    {
                        m_mapTextureAtlasResourcesArray = new CMap();
                    }
                    if( m_mapTextureAtlasResourcesArray.find( theSkinInfo.sLoadingSkinName ) == null )
                    {
                        m_mapTextureAtlasResourcesArray.add( theSkinInfo.sLoadingSkinName, theSkinInfo.aTextureAtlasResources );
                    }

                    m_vSkinUrls = theSkinInfo.vSkinUrl;
                    m_sAtlasUrl = theSkinInfo.sAtlasUrl;
                    m_aTextureAtlasResources = theSkinInfo.aTextureAtlasResources;
                    if( theSkinInfo.bLoadSkin )
                    {
                        _attachSkin( theSkinInfo.sLoadingSkinName, theSkinInfo.aTextureAtlasResources, m_theSkeletonAnimation.skeleton.data );
                    }
                    else
                    {
                        _createSkeletonDataResourceIfReady();
                    }

                    theSkinInfo.aTextureAtlasResources = null;
                    theSkinInfo.dispose();
                    theSkinInfo = null;
                }
            }
        }

        private function _attachSkin( skinName : String, aTextureAtlasResources : Array, skeletonData : SkeletonData ) : void
        {
            var data : SkeletonData = skeletonData;
            if( data.findSkin( skinName ) != null )
                return;
            var attachmentLoader : AtlasAttachmentLoader = new AtlasAttachmentLoader( aTextureAtlasResources[ 0 ].theObject );
            var length : int = aTextureAtlasResources.length;
            var i : int;
            for( i = 1; i < length; ++i )
            {
                attachmentLoader.addPage( aTextureAtlasResources[ i ].theObject );
            }
            var oldSkin : Skin = data.defaultSkin;

            var theSkeletonJson : SkeletonJsonExt = new SkeletonJsonExt();
            var skin : Skin = new Skin( skinName );
            var attachment : Attachment = null;
            length = oldSkin.attachments.length;
            for( i = 0; i < length; ++i )
            {
                for( var name : String in oldSkin.attachments[ i ] )
                {
                    attachment = theSkeletonJson.getAttachment( oldSkin.attachments[ i ][ name ], attachmentLoader, oldSkin, i );
                    skin.addAttachment( i, name, attachment );
                }
            }
            data.skins.push( skin );
            theSkeletonJson.linkMeshes( data );

            theSkeletonJson.dispose();
            theSkeletonJson = null;
            m_aTextureAtlasResources = aTextureAtlasResources;
        }

        private function _onSkeletonLoadFinished( loader : CQsonLoader, idErrorCode : int ) : void
        {
            if( m_bDisposed ) return;

            if( idErrorCode == 0 )
            {
                Foundation.Perf.sectionBegin( "CharacterObject_onSkeletonLoadFinished_createResource" );
                m_theSkeletonJsonResource = loader.createResource();
                Foundation.Perf.sectionEnd( "CharacterObject_onSkeletonLoadFinished_createResource" );
                _createSkeletonDataResourceIfReady();
            }
        }

        private function _onBoundLoadFinished( theBounds : AnimationBounds, iResult : int ) : void
        {
            if( m_bDisposed ) return;

            m_bAnimationBoundsReady = true;
            _createSkeletonDataResourceIfReady();
        }

        private function _createSkeletonDataResourceIfReady() : void
        {
            if( m_theSkeletonJsonResource != null && m_bTextureAtlasReady /** 先注释， 后期再调整 && m_bAnimationBoundsReady **/ )
            {
                //
                // currently don't support changing skins
                //
                m_theSkeletonDataResource = CResourceCache.instance().create( m_sSkeletonUrl, ".SKDATA" );
                var skinName : String;
                if( m_theSkeletonDataResource == null )
                {
                    Foundation.Perf.sectionBegin( "CharacterObject_createSkeletonDataResourceIfReady" );

                    var atlasAttachmentLoader : AtlasAttachmentLoader = null;
                    if( m_aTextureAtlasResources && m_aTextureAtlasResources.length > 0 )
                    {
                        atlasAttachmentLoader = new AtlasAttachmentLoader( m_aTextureAtlasResources[ 0 ].theObject );
                        for( var i : int = 1; i < m_aTextureAtlasResources.length; i++ ) atlasAttachmentLoader.addPage( m_aTextureAtlasResources[ i ].theObject );
                    }

                    if( m_vSkinUrls != null )
                    {
                        skinName = CPath.name( m_vSkinUrls[ 0 ] );
                        for( i = 1; i < m_vSkinUrls.length; ++i )
                        {
                            skinName += "-" + CPath.name( m_vSkinUrls[ i ] );
                        }
                    }
                    else
                        skinName = "default";

                    var theSkeletonJson : SkeletonJsonExt = new SkeletonJsonExt( atlasAttachmentLoader );
                    var theSkeletonData : SkeletonData = theSkeletonJson.createSkeletonData( m_theSkeletonJsonResource.theObject, skinName, m_sSkeletonUrl );
                    theSkeletonData.defaultSkin = theSkeletonData.findSkin( skinName );

                    // for debug
                    /*var aObjectBytes : ByteArray = new ByteArray();
                     aObjectBytes.writeObject( m_theSkeletonJsonResource.theObject );
                     aObjectBytes.position = 0;
                     // for debug
                     Foundation.Perf.sectionBegin( "ReadObject_test_n.parse" );
                     var newObject : Object = aObjectBytes.readObject();
                     Foundation.Perf.sectionEnd( "ReadObject_test_n.parse" );*/

                    // release some data after m_theSkeletonData is generated
                    m_theSkeletonJsonResource.dispose();
                    m_theSkeletonJsonResource = null;
                    theSkeletonJson.dispose();
                    theSkeletonJson = null;
                    //m_aTextureAtlasResources = null;

                    m_theSkeletonDataResource = new CResource( m_sSkeletonUrl, ".SKDATA", theSkeletonData );
                    CResourceCache.instance().add( m_sSkeletonUrl, ".SKDATA", m_theSkeletonDataResource, true, true );

                    Foundation.Perf.sectionEnd( "CharacterObject_createSkeletonDataResourceIfReady" );
                }
                else
                {
                    var skeletonData : SkeletonData = SkeletonData( m_theSkeletonDataResource.theObject );
                    if( m_vSkinUrls != null && m_vSkinUrls.length > 0 )
                    {
                        skinName = CPath.name( m_vSkinUrls[ 0 ] );
                        for( i = 1; i < m_vSkinUrls.length; ++i )
                        {
                            skinName += "-" + CPath.name( m_vSkinUrls[ i ] );
                        }
                        if( skeletonData.findSkin( skinName ) == null )
                        {
                            _attachSkin( skinName, m_aTextureAtlasResources, skeletonData );
                        }
                    }
                }

                _createSkeletonAnimation( SkeletonData( m_theSkeletonDataResource.theObject ), skinName );
            }
        }

        private function _createSkeletonAnimation( theSkeletonData : SkeletonData, skinName : String ) : void
        {
            if( theSkeletonData == null ) return;

            Foundation.Perf.sectionBegin( "CharacterObject_createSkeletonAnimation" );

            m_theSkeletonAnimation = new SkeletonAnimation( null, theSkeletonData, null );
            m_theSkeletonAnimation.name = m_sAtlasUrl;
            if( skinName != null )
                m_theSkeletonAnimation.skeleton.skinName = skinName;
            m_theAnimationClipInfoResource = CResourceCache.instance().create( m_sSkeletonUrl, ".ANICLIPINFO" );
            if( m_theAnimationClipInfoResource == null )
            {
                var mapAnimationClipInfos : CMap = new CMap();
                _generateAnimationClipInfos( mapAnimationClipInfos );

                m_theAnimationClipInfoResource = new CResource( m_sSkeletonUrl, ".ANICLIPINFO", mapAnimationClipInfos );
                CResourceCache.instance().add( m_sSkeletonUrl, ".ANICLIPINFO", m_theAnimationClipInfoResource );
            }

            /** 先注释 后期再调整 **/
                // create empty if load failed
//            if ( m_theAnimationBounds.isEmpty ) m_theAnimationBounds.createEmptyAnimationBounds ( this );

            Foundation.Perf.sectionEnd( "CharacterObject_createSkeletonAnimation" );

            if( m_fnOnLoadFinished != null ) m_fnOnLoadFinished( this, 0 ); // 0 means load successfully
        }

        private function _generateAnimationClipInfos( mapAnimationClipInfos : CMap ) : void // split and generate animation-clip-info for each animation by the event
        {
            if( m_theSkeletonAnimation == null || m_theSkeletonAnimation.skeleton == null ) return;

            // sort the animation array cuz the data from json is not guaranteed the order
            m_theSkeletonAnimation.stateData.skeletonData.animations.sort( Array.CASEINSENSITIVE );

            var theAnimationClipInfo : AnimationClipInfo = null;

            var aAnimations : Vector.<Animation> = m_theSkeletonAnimation.stateData.skeletonData.animations;
            for( var i : int = 0, n : int = aAnimations.length; i < n; ++i )
            {
                for each( var timeline : Timeline in aAnimations[ i ].timelines )
                {
                    if( timeline is EventTimeline )
                    {
                        //noinspection JSUnresolvedVariable
                        var et : EventTimeline = timeline as EventTimeline;
                        for( var j : int = 0; j < et.events.length; ++j )
                        {
                            var sEventName : String = et.events[ j ].data.name;
                            if( sEventName.indexOf( EVENT_SPLIT_PREFIX_LABEL ) != 0 ) continue;

                            theAnimationClipInfo = new AnimationClipInfo();
                            theAnimationClipInfo.m_sEventName = sEventName;
                            theAnimationClipInfo.m_fStartTime = et.events[ j ].time;
                            if( j < et.events.length - 1 )
                            {
                                theAnimationClipInfo.m_fEndTime = et.events[ j + 1 ].time;
                            }
                            else
                            {
                                theAnimationClipInfo.m_fEndTime = aAnimations[ i ].duration;
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
                theAnimationClipInfo = new AnimationClipInfo();
                theAnimationClipInfo.m_sEventName = "";
                theAnimationClipInfo.m_fStartTime = 0;
                theAnimationClipInfo.m_fEndTime = aAnimations[ i ].duration;
                theAnimationClipInfo.m_fDuration = theAnimationClipInfo.m_fEndTime;
                theAnimationClipInfo.m_sAnimationName = aAnimations[ i ].name;
                theAnimationClipInfo.m_iAnimationIndex = i;

                mapAnimationClipInfos.add( theAnimationClipInfo.m_sAnimationName, theAnimationClipInfo );
            }
        }
    }
}

import QFLib.Interface.IDisposable;
import QFLib.ResourceLoader.CResource;

class SkinInfo implements IDisposable
{
    public function SkinInfo()
    {
    }

    public function dispose() : void
    {
        sAtlasUrl = null;
        vSkinUrl = null;
        sLoadingSkinName = null;
        if( theAtlasXmlResource != null )
        {
            theAtlasXmlResource.dispose();
            if( aTextureAtlasResources != null )
            {
                for each( var resource : CResource in aTextureAtlasResources ) resource.dispose();
            }
            theAtlasXmlResource = null;
        }
    }

    //
    public var bLoadSkin : Boolean = false;
    public var sAtlasUrl : String = null;
    public var vSkinUrl : Vector.<String> = null;
    public var sLoadingSkinName : String = null;
    public var theAtlasXmlResource : CResource = null;
    public var aTextureAtlasResources : Array = null;

}


