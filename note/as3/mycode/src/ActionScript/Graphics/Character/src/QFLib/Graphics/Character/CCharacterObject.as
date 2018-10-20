//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/3/25.
//----------------------------------------------------------------------
package QFLib.Graphics.Character
{

    import QFLib.Foundation;
    import QFLib.Foundation.CMap;
    import QFLib.Foundation.CPath;
    import QFLib.Foundation.CSet;
    import QFLib.Graphics.Character.model.CEquipSkinsInfo;
    import QFLib.Graphics.RenderCore.CBaseObject;
    import QFLib.Graphics.RenderCore.CRenderer;
    import QFLib.Graphics.RenderCore.render.IMaterial;
    import QFLib.Graphics.RenderCore.render.IPass;
import QFLib.Graphics.RenderCore.starling.display.DisplayObject;
    import QFLib.Graphics.RenderCore.starling.filters.BlurEffect;
    import QFLib.Graphics.RenderCore.starling.filters.FilterEffect;
    import QFLib.Graphics.RenderCore.starling.filters.ObjectFilter;
    import QFLib.Graphics.RenderCore.starling.filters.OutlineEffect;
    import QFLib.Math.CAABBox2;
    import QFLib.Math.CVector2;
    import QFLib.ResourceLoader.CResource;
    import QFLib.ResourceLoader.ELoadingPriority;

import flash.utils.Dictionary;

import spine.Bone;
import spine.Skin;
import spine.Slot;
import spine.animation.Animation;
    import spine.animation.TrackEntry;

    import spineExt.starling.SkeletonAnimation;

//
    //
    //
    public class CCharacterObject extends CBaseObject
    {
        public const NUM_ANIMATION_TRACKS : int = 4;

        public function CCharacterObject( theRenderer : CRenderer, animationController : CAnimationController = null )
        {
            super( theRenderer );
            m_theAnimationController = animationController;
            if( m_theAnimationController != null ) m_theAnimationController._setCharacter( this );
        }

        public override function dispose() : void
        {
            if( m_theCharacterInfo != null )
            {
                m_theCharacterInfo.dispose();
                m_theCharacterInfo = null;
            }

            if( m_theSpineLoader != null )
            {
                m_theSpineLoader.dispose();
                m_theSpineLoader = null;
            }

            if( m_theSkeletonAnimationRef != null )
            {
                _removeChild( m_theSkeletonAnimationRef );
                m_theSkeletonAnimationRef.dispose();
                m_theSkeletonAnimationRef = null;
            }

            if( m_theAnimationController != null )
            {
                m_theAnimationController.dispose();
                m_theAnimationController = null;
            }

            if (m_mapCharacterComplex != null)
            {
                for each(var complex : CCharacterComplex in m_mapCharacterComplex)
                {
                    removeChild(complex);
                    complex.dispose();
                    complex = null;
                }
                m_mapCharacterComplex.clear();
                m_mapCharacterComplex = null;
            }

            for( var i : int = 0; i < m_vAnimationTracks.length; i++ ) m_vAnimationTracks[ i ] = null;

            m_fnOnLoadFinished = null;
            m_setOnAnimationChangedFunctions.clear();
            super.dispose();
        }

        // loading functions
        public function get isLoaded() : Boolean
        {
            return m_theSkeletonAnimationRef != null;
        }

        override public function get renderableObject() : DisplayObject
        {
            if( m_theSkeletonAnimationRef ) return m_theSkeletonAnimationRef;
            return null;
        }

        // try getting all used resources
        public override function retrieveAllResources( vResources : Vector.<CResource> = null, iBeginIndex : int = 0 ) : int
        {
            var iCount : int = 0;
            if( m_theSpineLoader != null )
            {
                iCount += m_theSpineLoader.retrieveAllResources( vResources, iBeginIndex + iCount );
            }

            return iCount;
        }

        [Inline] final public function get loadingPriority() : int { return m_iLoadingPriority; }

        [Inline] public function get characterInfo () : CCharacterInfo { return m_theCharacterInfo; }
        //
        // callback: function onLoadFinished( theCharacterObject : CCharacterObject, iResult : int ) : void
        //
        public function loadFile( sFilename : String, sSkinUrl : String = null, theEquipSkinsInfo : CEquipSkinsInfo = null,
                                    iLoadingPriority : int = ELoadingPriority.NORMAL,
                                    onLoadFinished : Function = null, pArrResUrl : Array = null ) : void
        {
            var sFile : String = CPath.driverDirName( sFilename );
            var sSkeletonFile : String = sFile;
            var sAtlasFile : String = sFile + ".xml";
            if (sSkinUrl != null)
            {
                sSkinUrl = CPath.driverDirName(sSkinUrl);
                var vSkinUrl:Vector.<String> = new Vector.<String>(1);
                vSkinUrl[0] = sSkinUrl;
            }
            var charInfo : CCharacterInfo = new CCharacterInfo( sSkeletonFile, sAtlasFile, vSkinUrl, theEquipSkinsInfo, null );
            loadCharacterInfo( charInfo, iLoadingPriority, onLoadFinished, pArrResUrl );
        }
        public function loadCharacterInfo( charInfo : CCharacterInfo, iLoadingPriority : int = ELoadingPriority.NORMAL,
                                             onLoadFinished : Function = null, pArrResUrl : Array = null ) : Boolean
        {
            m_iLoadingPriority = iLoadingPriority;
            m_theCharacterInfo = charInfo;
            m_fnOnLoadFinished = onLoadFinished;

            m_theSpineLoader = new CSpineLoader();
            return m_theSpineLoader.loadFile( m_theCharacterInfo.skeletonUrl, m_theCharacterInfo.atlasUrl,  m_theCharacterInfo.skinURLs, m_theCharacterInfo.equipSkinsInfo, iLoadingPriority, _onLoadFinished, pArrResUrl );
        }
        public function loadSkin(majorSkinName : String, theEquipSkins : CEquipSkinsInfo = null):void
        {
            if (majorSkinName == null)
                return;
            if (!isLoaded)
            {
                Foundation.Log.logErrorMsg("function loadSkin must be called after the character load finished");
                return;
            }

            var skinName : String;
            if (theEquipSkins == null)
            {
                skinName = majorSkinName;
            }
            else

            {
                if (theEquipSkins.isEquipsNull)
                {
                    skinName = majorSkinName;
                }
                else
                {
                    skinName =majorSkinName + theEquipSkins.equipName;
                }
            }

            if ( skinName != null &&  m_theSkeletonAnimationRef.skeleton.data.findSkin(skinName) != null)
            {
                //spine change skin function has some bug, so here is some fixes;
                //when change skin by change attachment in slot it is normal. but when you change skin by set corresponding attachment = null or assign s null attachment in slot
                //there would be s wrong display.
                //below is the corresponding modify
                var newSkin : Skin = m_theSkeletonAnimationRef.skeleton.data.findSkin(skinName);
                var oldSkin : Skin = m_theSkeletonAnimationRef.skeleton.skin;
                if (oldSkin != null)
                {
                    for (var index:int = 0; index < oldSkin.attachments.length && index < newSkin.attachments.length; ++index)
                    {
                        if (oldSkin.attachments[index] != newSkin.attachments[index])
                            m_theSkeletonAnimationRef.skeleton.slots[index].attachment = null;
                    }
                    if (oldSkin.attachments.length > newSkin.attachments.length)
                    {
                        for (index = newSkin.attachments.length -1; index < oldSkin.attachments.length; ++index)
                         m_theSkeletonAnimationRef.skeleton.slots[index].attachment = null;
                     }
                }
                m_theSkeletonAnimationRef.skeleton.skin = null;
                m_theSkeletonAnimationRef.skeleton.skin = m_theSkeletonAnimationRef.skeleton.data.findSkin(skinName);
            }
            else
            {
                var vPngUrl : Vector.<String>;
                if (theEquipSkins == null)
                {
                    vPngUrl = new Vector.<String>(1);
                    vPngUrl[0] = CPath.driverDir(m_theCharacterInfo.skeletonUrl) + majorSkinName;
                    m_theCharacterInfo.skinURLs = vPngUrl;
                }
                else
                {
                    if (theEquipSkins.isEquipsNull)
                    {
                        vPngUrl = new Vector.<String>(1);
                        vPngUrl[0] = CPath.driverDir(m_theCharacterInfo.skeletonUrl) + majorSkinName;
                        m_theCharacterInfo.skinURLs = vPngUrl;
                    }
                    else
                    {
                        vPngUrl = new Vector.<String>(1);
                        var vSkinUrl : Vector.<String> = new Vector.<String>(1);
                        vSkinUrl[0] = CPath.driverDir(m_theCharacterInfo.skeletonUrl) + majorSkinName;
                        m_theCharacterInfo.equipSkinsInfo = theEquipSkins;
                        m_theCharacterInfo.skinURLs = vSkinUrl;

                        vPngUrl[0] = vSkinUrl[0];
                        vPngUrl.push(theEquipSkins.equipURLs);
                    }
                }
                m_theSpineLoader.loadSkin(m_theCharacterInfo.atlasUrl, vPngUrl);

            }
        }

        public function loadEquipSkin(equipIndex : int, equipName : String) : void
        {
            var equipUrl : String = CPath.driverDir(m_theCharacterInfo.skeletonUrl) + equipName;
            var theEquipSkins : CEquipSkinsInfo = m_theCharacterInfo.equipSkinsInfo;
            if (theEquipSkins == null)
                theEquipSkins = new CEquipSkinsInfo();
            theEquipSkins.addEquip(equipIndex, equipUrl);

            var majorSkinName : String;
            if (m_theCharacterInfo.skinURLs != null)
                majorSkinName = CPath.name(m_theCharacterInfo.skinURLs[0]);
            else
                majorSkinName = CPath.name(m_theCharacterInfo.skeletonUrl);

            loadSkin(majorSkinName, theEquipSkins);
        }
        public function loadSkinByAtlas( atlasName : String):void
        {
            if(atlasName == null)
                return;
            if (!isLoaded)
            {
                Foundation.Log.logErrorMsg("function loadSkinByAtlas must be called after the character load finished");
                return;
            }
            var atlasUrl : String =  CPath.driverDir(m_theCharacterInfo.atlasUrl) + atlasName + ".xml";
            m_theSpineLoader.loadSkin(atlasUrl,null);
        }
        public function get spineLoader() : CSpineLoader
        {
            return m_theSpineLoader;
        }

        public override function set opaque( fOpaque : Number ) : void
        {
            super.opaque = fOpaque;
            if( m_theSkeletonAnimationRef != null ) m_theSkeletonAnimationRef.alpha = fOpaque;
        }

        public override function setColor( r : Number, g : Number, b : Number, alpha : Number = 1.0, masking : Boolean = false ) : void
        {
            super.setColor( r, g, b, alpha, masking );

            if ( m_theSkeletonAnimationRef != null ) m_theSkeletonAnimationRef.setColor(r, g, b, alpha, masking);
        }

        public override function setLightColorAndContrast ( r : Number = 1.0, g : Number = 1.0, b : Number = 1.0, alpha : Number = 1.0, contrast : Number = 0.0 ) : void
        {
            if ( m_theSkeletonAnimationRef != null ) m_theSkeletonAnimationRef.setLightColorAndContrast ( r, g, b, alpha, contrast );
        }

        public override function resetColor () : void
        {
            if ( m_theSkeletonAnimationRef != null ) m_theSkeletonAnimationRef.resetColor ();
        }

        [Inline] public function get material () : IMaterial
        {
            if ( m_theSkeletonAnimationRef != null ) return m_theSkeletonAnimationRef.material;
            return null;
        }

        //
        // callback: function _onAnimationChanged( iTrackIdx : int ) : void
        //
        public function addOnAnimationChangedCallback( fnOnAnimationChanged : Function ) : void
        {
            if( fnOnAnimationChanged != null ) m_setOnAnimationChangedFunctions.add( fnOnAnimationChanged );
        }
        public function removeOnAnimationChangedCallback( fnOnAnimationChanged : Function ) : void
        {
            if( fnOnAnimationChanged != null ) m_setOnAnimationChangedFunctions.remove( fnOnAnimationChanged );
        }

        // animation offset flags and function
        public function get extractAnimationOffset() : Boolean
        {
            return m_bExtractAnimationOffset;
        }
        public function set extractAnimationOffset( bExtract : Boolean ) : void
        {
            m_bExtractAnimationOffset = bExtract;
        }

        public function addExtractAnimationOffsetBone( sBoneName : String ) : void
        {
            if( m_vExtractAnimationOffsetBones == null ) m_vExtractAnimationOffsetBones = new Vector.<String>();

            for each( var sExtractedBoneName : String in m_vExtractAnimationOffsetBones )
            {
                if( sExtractedBoneName == sBoneName ) return ;
            }

            m_vExtractAnimationOffsetBones.push( sBoneName );
            _addExtractAnimationOffsetBoneIndex( sBoneName );
        }
        public function clearExtractAnimationOffsetBones() : void
        {
            if( m_vExtractAnimationOffsetBones == null ) return ;

            m_vExtractAnimationOffsetBones.length = 0;
            m_vExtractAnimationOffsetBoneIndices.length = 0;
        }
        public function getAnimationOffset( iTrackIdx : int = -1, bClear : Boolean = false ) : CVector2 // -1 means add on all entry's animation offset
        {
            if( iTrackIdx < 0 )
            {
                m_vAnimationOffset.zero();
                for( var i : int = 0; i < m_vAnimationTracks.length; i++ )
                {
                    if( m_vAnimationTracks[ i ] != null )
                    {
                        m_vAnimationOffset.addOn( m_vAnimationTracks[ i ].m_vAnimationOffset );
                        if( bClear ) m_vAnimationTracks[ i ].m_vAnimationOffset.zero();
                    }
                }

                if( m_bFlipX ) m_vAnimationOffset.x = -m_vAnimationOffset.x;
                if( m_bFlipY ) m_vAnimationOffset.y = -m_vAnimationOffset.y;
                return m_vAnimationOffset;
            }
            else
            {
                if( m_vAnimationTracks[ iTrackIdx ] != null ) return m_vAnimationTracks[ iTrackIdx ].m_vAnimationOffset;
                else return null;
            }
        }
        public function getAnimationOffsetPerSec( iTrackIdx : int = -1 ) : CVector2 // -1 means add on all entry's animation offset
        {
            if( iTrackIdx < 0 )
            {
                m_vAnimationOffsetPerSec.zero();
                for( var i : int = 0; i < m_vAnimationTracks.length; i++ )
                {
                    if( m_vAnimationTracks[ i ] != null )
                    {
                        m_vAnimationOffsetPerSec.addOn( m_vAnimationTracks[ i ].m_vAnimationOffsetPerSec );
                    }
                }

                if( m_bFlipX ) m_vAnimationOffsetPerSec.x = -m_vAnimationOffsetPerSec.x;
                if( m_bFlipY ) m_vAnimationOffsetPerSec.y = -m_vAnimationOffsetPerSec.y;
                return m_vAnimationOffsetPerSec;
            }
            else
            {
                if( m_vAnimationTracks[ iTrackIdx ] != null ) return m_vAnimationTracks[ iTrackIdx ].m_vAnimationOffsetPerSec;
                else return null;
            }
        }

        //
        [Inline]
        final public function get numAnimationClipInfos() : int
        {
            if( m_theSkeletonAnimationRef == null ) return 0;
            return m_mapAnimationClipInfosRef.length;
        }
        [Inline]
        final public function findAnimationClipInfo( sClipName : String ) : CAnimationClipInfo
        {
            if( m_mapAnimationClipInfosRef == null ) return null;
            return m_mapAnimationClipInfosRef.find( sClipName ) as CAnimationClipInfo;
        }
        public function retrieveAllAnimationClipNames( vAnimationNames : Vector.<String> ) : void
        {
            if( m_theSkeletonAnimationRef == null ) return ;

            if( vAnimationNames == null )vAnimationNames = new Vector.<String>( m_mapAnimationClipInfosRef.length );
            else vAnimationNames.length = m_mapAnimationClipInfosRef.length;

            var i : int = 0;
            for( var key : String in m_mapAnimationClipInfosRef ) vAnimationNames[ i++ ] = key;
        }

        // animation clip infos / functions
        public function get currentAnimationClip() : CAnimationClip
        {
            return m_vAnimationTracks[ 0 ];
        }
        public function get currentAnimationClipTime() : Number
        {
            return getCurrentAnimationClipTime( 0 );
        }
        public function get currentAnimationTotalTime():Number
        {
            return getCurrentAnimationTotalTime( 0 );
        }
        public function get currentAnimationClipDuration() : Number
        {
            return getCurrentAnimationClipDuration( 0 );
        }
        public function get currentAnimationClipTimeLeft() : Number
        {
            return getCurrentAnimationClipTimeLeft( 0 );
        }
        public function getCurrentAnimationClip( iTrackIdx : int ) : CAnimationClip
        {
            if( iTrackIdx < m_vAnimationTracks.length ) return m_vAnimationTracks[ iTrackIdx ];
            else return null;
        }
        public function getCurrentAnimationClipDuration( iTrackIdx : int ) : Number
        {
            if( iTrackIdx < 0 && iTrackIdx >= m_vAnimationTracks.length ) return 0.0;
            if( m_vAnimationTracks[ iTrackIdx ] == null ) return 0.0;

            return m_vAnimationTracks[ iTrackIdx ].m_fDuration;
        }
        public function getCurrentAnimationClipTime( iTrackIdx : int ) : Number
        {
            if( iTrackIdx < 0 && iTrackIdx >= m_vAnimationTracks.length ) return 0.0;
            if( m_vAnimationTracks[ iTrackIdx ] == null ) return 0.0;

            return m_vAnimationTracks[ iTrackIdx ].m_fTime - m_vAnimationTracks[ iTrackIdx ].m_fStartTime;
        }
        public function getCurrentAnimationTotalTime( iTrackIdx : int ):Number
        {
            if( iTrackIdx < 0 && iTrackIdx >= m_vAnimationTracks.length ) return 0.0;
            if( m_vAnimationTracks[ iTrackIdx ] == null ) return 0.0;

            return m_vAnimationTracks[ iTrackIdx ].m_fTotalTime;
        }
        public function getCurrentAnimationClipTimeLeft( iTrackIdx : int, bCheckLoop : Boolean = true ) : Number
        {
            if( m_theSkeletonAnimationRef == null ) return 0.0;

            var theEntry : TrackEntry = m_theSkeletonAnimationRef.state.getCurrent( iTrackIdx );
            if( theEntry == null )
            {
                return 0.0;
            }
            else
            {
                if( bCheckLoop && m_vAnimationTracks[ iTrackIdx ].m_bLoop ) return Number.MAX_VALUE;
                else return m_vAnimationTracks[ iTrackIdx ].m_fEndTime - m_vAnimationTracks[ iTrackIdx ].m_fTime;
            }
        }
        public function getAnimationClipDurationByName( sClipName : String ) : Number
        {
            if( m_theSkeletonAnimationRef == null ) return 0.0;

            var animationInfo : CAnimationClipInfo = m_mapAnimationClipInfosRef.find( sClipName );
            if( animationInfo ) return animationInfo.m_fDuration;
            else return 0.0;
        }

        [Inline]
        final public function get suppressPlayAnimationErrorMsg() : Boolean
        {
            return m_bSuppressPlayAnimationErrorMsg;
        }
        [Inline]
        final public function set suppressPlayAnimationErrorMsg( bSuppress : Boolean ) : void
        {
            m_bSuppressPlayAnimationErrorMsg = bSuppress;
        }

        public override function get currentBound() : CAABBox2
        {
            var theAnimationClip : CAnimationClip = m_vAnimationTracks[ 0 ];
            if( theAnimationClip == null ) return _getBound( -1, false );
            if( theAnimationClip.m_theAnimationInfoRef == null ) return _getBound( -1, false );

            var iAnimationClipIndex : int = theAnimationClip.m_theAnimationInfoRef.m_iAnimationIndex;
            var bExtractAnimationOffset : Boolean = theAnimationClip.m_bExtractAnimationOffset;
            return _getBound( iAnimationClipIndex, bExtractAnimationOffset );
        }
        public function getBound( sAnimationClipName : String, bExtractAnimationOffset : Boolean ) : CAABBox2
        {
            if( m_theSkeletonAnimationRef == null ) return null;

            var theAnimationInfo : CAnimationClipInfo = m_mapAnimationClipInfosRef.find( sAnimationClipName );
            if( theAnimationInfo == null ) return null;

            return _getBound( theAnimationInfo.m_iAnimationIndex, bExtractAnimationOffset );
        }

        public function setAnimationClipBlendTime( sFromClipName : String, sToClipName : String, fBlendTime : Number ) : void
        {
            if( m_theSkeletonAnimationRef != null )
            {
                var theFromAnimationClipInfo : CAnimationClipInfo = m_mapAnimationClipInfosRef.find( sFromClipName );
                if( theFromAnimationClipInfo == null )
                {
                    // don't show this message cuz not all characters have all specify animations
                    //Foundation.Log.logErrorMsg( "find no animation clip for blending: " + sFromClipName + " in character: " + m_theSpineLoader.skeletonFilename + ", so abort this blend setting..." );
                }

                var theToAnimationClipInfo : CAnimationClipInfo =  m_mapAnimationClipInfosRef.find( sToClipName );
                if( theToAnimationClipInfo == null )
                {
                    // don't show this message cuz not all characters have all specify animations
                    //Foundation.Log.logErrorMsg( "find no animation clip for blending: " + sToClipName + " in character: " + m_theSpineLoader.skeletonFilename + ", so abort this blend setting..." );
                }

                if( theFromAnimationClipInfo != null && theToAnimationClipInfo != null )
                {
                    m_theSkeletonAnimationRef.stateData.setMixByName( theFromAnimationClipInfo.m_sAnimationName, theToAnimationClipInfo.m_sAnimationName, fBlendTime );
                }
            }
            else
            {
                Foundation.Log.logMsg( "Cannot set animation clip mix before load finished!" );
            }
        }

        // animation controller
        public virtual function get animationController() : CAnimationController
        {
            return m_theAnimationController;
        }
        public virtual function set animationController( controller : CAnimationController ) : void
        {
            if( m_theAnimationController == controller ) return;

            if( m_theAnimationController ) m_theAnimationController._setCharacter( null );
            m_theAnimationController = controller;
            if( m_theAnimationController ) m_theAnimationController._setCharacter( this );
        }

        public function playState( sStateName : String, bForceLoop : Boolean = false, bForceReplay : Boolean = false, iTrackIdx : int = 0 ) : void
        {

            m_theAnimationController.playState( sStateName, bForceLoop, bForceReplay, iTrackIdx );
        }

        public function getStateDuration( sStateName : String ) : Number
        {
            if( m_theSkeletonAnimationRef == null || m_theAnimationController == null ) return 0.0;

            var state : CAnimationState = m_theAnimationController.findState( sStateName );
            if( state != null )
            {
                return getAnimationClipDurationByName( state.animationName );
            }
            else return 0.0;
        }

        //
        // fLoopTime: the play time when bLoop == true
        // callback: function _onAnimationFinished( theCharacterObject : CCharacterObject ) : void
        //
        public function playAnimation( sClipName : String, bLoop : Boolean, bForceReplay : Boolean = false,
                                         bExtractAnimationOffset : Boolean = false, iTrackIdx : int = 0, bRandomStart : Boolean = false,
                                         fLoopTime : Number = 0.0, fnOnAnimationFinished : Function = null ) : Boolean
        {
            if( m_theSkeletonAnimationRef == null ) return null;

            return _playAnimation( sClipName, bLoop, bForceReplay, bExtractAnimationOffset, iTrackIdx, bRandomStart, fLoopTime, fnOnAnimationFinished );
        }

        // bone
        public function findBoneIndex( sBoneName : String ) : int
        {
            if( m_theSkeletonAnimationRef == null ) return -1;
            return m_theSkeletonAnimationRef.skeleton.findBoneIndex( sBoneName );
        }
        public function retrieveBonePosition( iIndex : int, vBonePos : CVector2, bLocal : Boolean, bAddOn : Boolean ) : Boolean
        {
            if( m_theSkeletonAnimationRef == null )
            {
                if( bAddOn )
                {
                    vBonePos.addOnValueXY( 0.0, 0.0 );
                }
                else
                {
                    vBonePos.setValueXY( 0.0, 0.0 );
                }
                return false;
            }

            var bBoneFound : Boolean;
            var theBone : Bone;
            if( iIndex < 0 || iIndex >= m_theSkeletonAnimationRef.skeleton.bones.length )
            {
                theBone = m_theSkeletonAnimationRef.skeleton.rootBone;
                bBoneFound = false;
            }
            else
            {
                theBone = m_theSkeletonAnimationRef.skeleton.bones[ iIndex ];
                bBoneFound = true;
            }

            if( bAddOn )
            {
                if( bLocal ) vBonePos.addOnValueXY( theBone.x, theBone.y );
                else vBonePos.addOnValueXY( theBone.worldX, theBone.worldY );
            }
            else
            {
                if( bLocal ) vBonePos.setValueXY( theBone.x, theBone.y );
                else vBonePos.setValueXY( theBone.worldX, theBone.worldY );
            }

            return bBoneFound;
        }
        public function extractBonePosition( iIndex : int, vBonePos : CVector2, bLocal : Boolean, bAddOn : Boolean, bUpdateTransform : Boolean ) : Boolean
        {
            if( m_theSkeletonAnimationRef == null ) return false;
            if( iIndex < 0 || iIndex >= m_theSkeletonAnimationRef.skeleton.bones.length ) return false;

            var theBone : Bone = m_theSkeletonAnimationRef.skeleton.bones[ iIndex ];

            if( bAddOn )
            {
                if( bLocal ) vBonePos.addOnValueXY( theBone.x, theBone.y );
                else vBonePos.addOnValueXY( theBone.worldX, theBone.worldY );
            }
            else
            {
                if( bLocal ) vBonePos.setValueXY( theBone.x, theBone.y );
                else vBonePos.setValueXY( theBone.worldX, theBone.worldY );
            }

            theBone.x = 0.0;
            theBone.y = 0.0;

            if( bUpdateTransform ) m_theSkeletonAnimationRef.skeleton.updateWorldTransform();
            return true;
        }

        public function clearAnimationOffsetBonePositions( bUpdateTransform : Boolean ) : void
        {
            if( m_theSkeletonAnimationRef == null ) return;

            if( m_vExtractAnimationOffsetBoneIndices != null )
            {
                var iBoneIdx : int;
                var theBone : Bone;
                for( var i : int = 0; i < m_vExtractAnimationOffsetBoneIndices.length; i++ )
                {
                    iBoneIdx = m_vExtractAnimationOffsetBoneIndices[ i ];
                    if( iBoneIdx >= 0 || iBoneIdx < m_theSkeletonAnimationRef.skeleton.bones.length )
                    {
                        theBone = m_theSkeletonAnimationRef.skeleton.bones[ iBoneIdx ];
                        theBone.x = theBone.y = 0.0;
                    }
                }

                if( bUpdateTransform ) m_theSkeletonAnimationRef.skeleton.updateWorldTransform();
            }
        }

        public function setRootBonePosition( vBonePos : CVector2, bAddOn : Boolean = false, bUpdateTransform : Boolean = true ) : void
        {
            if( m_theSkeletonAnimationRef == null ) return;

            var theBone : Bone = m_theSkeletonAnimationRef.skeleton.rootBone;
            if( theBone == null ) return ;

            if( bAddOn )
            {
                theBone.x += vBonePos.x;
                theBone.y += vBonePos.y;
            }
            else
            {
                theBone.x = vBonePos.x;
                theBone.y = vBonePos.y;
            }

            if( bUpdateTransform ) m_theSkeletonAnimationRef.skeleton.updateWorldTransform();
        }

        // the update function
        public override function update( fDeltaTime : Number ) : void
        {
            Foundation.Perf.sectionBegin( "CharacterObject_Update" );

            if( m_theSkeletonAnimationRef )
            {
                //
                Foundation.Perf.sectionBegin( "CharacterObject_advanceTimeOnly" );

                m_theSkeletonAnimationRef.advanceTimeOnly( fDeltaTime );

                var animationClip : CAnimationClip;
                for( var j : int = 0; j < NUM_ANIMATION_TRACKS; j++ )
                {
                    animationClip = m_vAnimationTracks[ j ];
                    if( animationClip == null ) continue;

                    animationClip.update( fDeltaTime );
                    if( j != 0 && animationClip.m_bLoop == false && animationClip.m_fTime >= animationClip.m_fEndTime )
                    {
                        m_vAnimationTracks[ j ] = null;
                        onAnimationChanged( j );
                    }
                }

                // apply updates to the skeleton
                m_theSkeletonAnimationRef.state.apply( m_theSkeletonAnimationRef.skeleton );

                Foundation.Perf.sectionEnd( "CharacterObject_advanceTimeOnly" );

                // try extract the offset from bones that need to be extract
                if( m_vExtractAnimationOffsetBoneIndices != null && m_bExtractAnimationOffset )
                {
                    for( var i : int = 0; i < m_vAnimationTracks.length; i++ )
                    {
                        if( m_vAnimationTracks[ i ] != null ) _extractAnimationOffsetData( m_vAnimationTracks[ i ], fDeltaTime );
                    }
                }

                Foundation.Perf.sectionBegin( "CharacterObject_UpdateWorldTransform" );
                // update skeleton's matrices
                m_theSkeletonAnimationRef.skeleton.updateWorldTransform();
                Foundation.Perf.sectionEnd( "CharacterObject_UpdateWorldTransform" );

                if( m_theAnimationController != null ) m_theAnimationController.update( fDeltaTime );

                _updateComplex(fDeltaTime);
            }

            Foundation.Perf.sectionBegin( "CharacterBaseObject_Update" );
            super.update( fDeltaTime );
            Foundation.Perf.sectionEnd( "CharacterBaseObject_Update" );

            Foundation.Perf.sectionEnd( "CharacterObject_Update" );
        }

        //
        //

        public function retrieveBoneRotation( iIndex : int ):Number
        {
            if( m_theSkeletonAnimationRef == null ) return 0;
            if( iIndex < 0 || iIndex >= m_theSkeletonAnimationRef.skeleton.bones.length ) return 0;

            var theBone : Bone = m_theSkeletonAnimationRef.skeleton.bones[ iIndex ];
            if(null != theBone)
            {
                var worldRotation:Number = Math.atan2(theBone.worldRotationX, theBone.worldRotationY);
                return worldRotation;
            }

            return 0;
        }
        protected function _onLoadFinished( theSpine : CSpineLoader, iResult : int ) : void
        {
            if( this.disposed )
            {
                theSpine.dispose();
                return;
            }

            if( theSpine != m_theSpineLoader )
            {
                Foundation.Log.logErrorMsg( "theSpine should equal to m_theSpineLoader!" );
                return;
            }

            if( iResult == 0 )
            {
                AssetsSize = theSpine.AssetsSize;

                m_theSkeletonAnimationRef = theSpine.skeletonAnimation;
                m_mapAnimationClipInfosRef = theSpine.getAnimationClipInfos;
                _addChild( m_theSkeletonAnimationRef );

                m_theSkeletonAnimationRef.setColor( this.color.r, this.color.g, this.color.b, m_fOpaque );

                m_theSkeletonAnimationRef.autoRecalculateBound = false; // set bound manually when animation changed

                // relink the bone indices of extracting animation offset from m_vExtractAnimationOffsetBones
                if( m_vExtractAnimationOffsetBones != null )
                {
                    for( var i : int = 0; i < m_vExtractAnimationOffsetBones.length; i++ )
                    {
                        _addExtractAnimationOffsetBoneIndex( m_vExtractAnimationOffsetBones[ i ] );
                    }
                }

                // relink the controller
                if( m_theAnimationController != null )
                {
                    m_theAnimationController._setCharacterLoadFinished();
                    var state : CAnimationState = m_theAnimationController.currentState;
                    _playAnimationWithState( state, false, false, 0, false, 0.0 );
                }

                if ( m_bEnableOutline )
                {
                    var effects : Vector.<FilterEffect> = setFilter ( m_theSkeletonAnimationRef, ObjectFilter.RimLightOutline, true );
                    if ( effects != null )
                    {
                        var blurEffect : BlurEffect = effects[ 0 ] as BlurEffect;
                        blurEffect.setGlowColor ( m_OutlineRed, m_OutlineGreen, m_OutlineBlue );
                        blurEffect.setGlowSize ( m_OutlineSize );

                        blurEffect = effects[ 1 ] as BlurEffect;
                        blurEffect.setGlowColor ( m_OutlineRed, m_OutlineGreen, m_OutlineBlue );
                        blurEffect.setGlowSize ( m_OutlineSize );
                    }
                }
            }
            if( m_fnOnLoadFinished != null )
            {
                m_fnOnLoadFinished( this, iResult );
                m_fnOnLoadFinished = null;
            }
        }

        public virtual function onAnimationChanged( iTrackIdx : int ) : void
        {
            for each( var callback : Function in m_setOnAnimationChangedFunctions ) callback( iTrackIdx );
        }

        public function addQuad( quad : DisplayObject) : void
        {
            _addChild(quad);
        }

        public function removeQuad( quad : DisplayObject) : void
        {
            _removeChild(quad);
        }

        public function rimLightOutline( enable:Boolean, red:Number = 1.0, green:Number = 1.0 , blue:Number = 1.0, alpha:Number = 1.0, size: Number = 3.0):void
        {
            m_OutlineRed = red;
            m_OutlineGreen = green;
            m_OutlineBlue = blue;
            m_OutlineAlpha = alpha;
            m_OutlineSize = size;
            m_bEnableOutline = enable;
            if ( m_theSkeletonAnimationRef != null )
            {
                var effects : Vector.<FilterEffect> = setFilter ( m_theSkeletonAnimationRef, ObjectFilter.RimLightOutline, enable );
                if ( effects != null )
                {
                    var blurEffect : BlurEffect = effects[ 0 ] as BlurEffect;
                    blurEffect.setGlowColor ( red, green, blue );
                    blurEffect.setGlowSize ( size );

                    blurEffect = effects[ 1 ] as BlurEffect;
                    blurEffect.setGlowColor ( red, green, blue );
                    blurEffect.setGlowSize ( size );
                }
            }
        }

        internal function _playAnimationWithState( theState : CAnimationState, bForceLoop : Boolean, bForceReplay : Boolean, iTrackIdx : int,
                                                      bForceRandomStart : Boolean, fLoopTime : Number ) : Boolean
        {
            return _playAnimation( theState.animationName, theState.animationLoop || bForceLoop, theState.animationForceReplay || bForceReplay,
                                    theState.animationExtractOffset, iTrackIdx, theState.randomStart || bForceRandomStart, fLoopTime, null );
        }

        //
        // fLoopTIme: the play time when bLoop == true
        // callback: function _onAnimationFinished( theCharacterObject : CCharacterObject ) : void
        //
        public function _playAnimation( sClipName : String, bLoop : Boolean, bForceReplay : Boolean,
                                          bExtractAnimationOffset : Boolean, iTrackIdx : int, bRandomStart : Boolean,
                                          fLoopTime : Number, fnOnAnimationFinished : Function ) : Boolean
        {
            if( m_theSkeletonAnimationRef == null ) return false;

            var animationClip : CAnimationClip = m_vAnimationTracks[ iTrackIdx ];
            if( animationClip == null ) animationClip = new CAnimationClip( this );

            var theEntry : TrackEntry = m_theSkeletonAnimationRef.state.getCurrent( iTrackIdx );
            if( theEntry == null || bForceReplay || animationClip.m_sName != sClipName )
            {
                var theAnimationClipInfo : CAnimationClipInfo = m_mapAnimationClipInfosRef.find( sClipName );
                if( theAnimationClipInfo != null )
                {
                    // make sure it run to the last frame of current animation clip
                    if( animationClip.isActive() )
                    {
                        var fRemainTime : Number = animationClip.m_fDuration - animationClip.m_fTime;
                        if( fRemainTime > 0.0 )
                        {
                            m_theSkeletonAnimationRef.advanceTimeOnly( fRemainTime );
                            animationClip.reset( true );
                        }
                    }

                    if( bForceReplay && theEntry != null )
                        theEntry.time = theAnimationClipInfo.m_fStartTime;
                    // set to new animation clip
                    var theAnimationClip : Animation = m_theSkeletonAnimationRef.stateData.skeletonData.animations[ theAnimationClipInfo.m_iAnimationIndex ];
                    var bound : CAABBox2 = this._getBound ( theAnimationClipInfo.m_iAnimationIndex, bExtractAnimationOffset );
                    m_theSkeletonAnimationRef.setBound( bound );

//                    m_theSkeletonAnimationRef.skeleton.setToSetupPose();
                    theEntry = m_theSkeletonAnimationRef.state.setAnimation( iTrackIdx, theAnimationClip, bLoop );
                    theEntry.time = theAnimationClipInfo.m_fStartTime;
                    theEntry.endTime = theAnimationClipInfo.m_fEndTime;
                    //theEntry.previous = null;
                    m_theSkeletonAnimationRef.advanceTimeOnly( 0.0, true );
                    if( bRandomStart ) m_theSkeletonAnimationRef.advanceTimeOnly( Math.random() * theAnimationClipInfo.m_fDuration + theAnimationClipInfo.m_fStartTime, true );
                    if( theEntry != null )
                    {
                        animationClip.set( sClipName, bLoop, bExtractAnimationOffset, theAnimationClipInfo, theEntry, fLoopTime, fnOnAnimationFinished );
                        m_vAnimationTracks[ iTrackIdx ] = animationClip;

                        // apply updates to the skeleton
                        m_theSkeletonAnimationRef.state.apply( m_theSkeletonAnimationRef.skeleton );
                        _resetAnimationOffsetData( animationClip );
                        m_theSkeletonAnimationRef.skeleton.updateWorldTransform();

                        onAnimationChanged( iTrackIdx );
                    }
                    else
                    {
                        if( m_bSuppressPlayAnimationErrorMsg == false )
                        {
                            Foundation.Log.logErrorMsg( "find no animation entry: '" + theAnimationClipInfo.m_sAnimationName + "' in character: " + m_theSpineLoader.skeletonFilename );
                        }
                        return false;
                    }
                }
                else
                {
                    if( m_bSuppressPlayAnimationErrorMsg == false )
                    {
                        Foundation.Log.logErrorMsg( "find no animation clip info: '" + sClipName + "' in character: " + m_theSpineLoader.skeletonFilename );
                    }
                    return false;
                }
            }
            else
            {
                if( animationClip.m_bLoop != bLoop )
                {
                    theEntry.loop = bLoop;
                    animationClip.m_bLoop = bLoop;
                }
                if( animationClip.m_bExtractAnimationOffset != bExtractAnimationOffset ) animationClip.m_bExtractAnimationOffset = bExtractAnimationOffset;
                if( animationClip.m_fLoopTime != fLoopTime ) animationClip.m_fLoopTime = fLoopTime;
                if( animationClip.m_fnAnimationFinished != fnOnAnimationFinished ) animationClip.m_fnAnimationFinished = fnOnAnimationFinished;
            }

            if( m_mapCharacterComplex != null )
            {
                for each (var complex : CCharacterComplex in  m_mapCharacterComplex)
                {
                    complex._playAnimation( sClipName, bLoop, bForceReplay, false, iTrackIdx, false, fLoopTime, null );
                    (complex.m_theSkeletonAnimationRef).advanceTimeOnly( m_theSkeletonAnimationRef.state.getCurrent(iTrackIdx).time );
                }
            }
            return true;
        }
        private function _resetAnimationOffsetData( animationClip : CAnimationClip ) : void
        {
            if( m_vExtractAnimationOffsetBoneIndices != null )
            {
                animationClip.m_vAnimationOffsetPosLast.zero();
                for( var i : int = 0; i < m_vExtractAnimationOffsetBoneIndices.length; i++ )
                {
                    extractBonePosition( m_vExtractAnimationOffsetBoneIndices[ i ], animationClip.m_vAnimationOffsetPosLast, true, true, false );
                    //retrieveBonePosition( m_vExtractAnimationOffsetBoneIndices[ i ], animationClip.m_vAnimationOffsetPosLast, true, true );
                }

                animationClip.m_vAnimationOffset.zero();
                animationClip.m_vAnimationOffsetPerSec.zero();
            }
        }
        private function _extractAnimationOffsetData( animationClip : CAnimationClip, fDeltaTime :Number ) : void
        {
            if( animationClip.m_bExtractAnimationOffset )
            {
                var bCalculate : Boolean = true;
                if( animationClip.m_fLastTime == animationClip.m_fTime ) bCalculate = false;
                else if( animationClip.m_bLoop && animationClip.m_fTime < animationClip.m_fLastTime ) bCalculate = false;
                else ;

                if( bCalculate )
                {
                    animationClip.m_vAnimationOffsetPos.zero();
                    for( var i : int = 0; i < m_vExtractAnimationOffsetBoneIndices.length; i++ )
                    {
                        extractBonePosition( m_vExtractAnimationOffsetBoneIndices[ i ], animationClip.m_vAnimationOffsetPos, true, true, false );
                    }

                    animationClip.m_vAnimationOffset.set( animationClip.m_vAnimationOffsetPos );
                    animationClip.m_vAnimationOffset.subOn( animationClip.m_vAnimationOffsetPosLast );
                    animationClip.m_vAnimationOffsetPosLast.set( animationClip.m_vAnimationOffsetPos );

                    animationClip.m_vAnimationOffsetPerSec.set( animationClip.m_vAnimationOffset );
                    animationClip.m_vAnimationOffsetPerSec.divOnValue( fDeltaTime );
                }
                else
                {
                    _resetAnimationOffsetData( animationClip );
                }
            }
        }

        private function _addExtractAnimationOffsetBoneIndex( sBoneName : String ) : void
        {
            if( m_vExtractAnimationOffsetBoneIndices == null ) m_vExtractAnimationOffsetBoneIndices = new Vector.<int>();

            var iIdx : int = findBoneIndex( sBoneName );
            if( iIdx >= 0 ) m_vExtractAnimationOffsetBoneIndices.push( iIdx );
        }

        [Inline]
        final protected function _getBound( iAnimationClipIndex : int, bExtractAnimationOffset : Boolean ) : CAABBox2
        {
            if( m_theSkeletonAnimationRef == null ) return null;
            return m_theSpineLoader.animationBounds.getBound( iAnimationClipIndex, bExtractAnimationOffset, m_vExtractAnimationOffsetBoneIndices );
        }

        public function loadComplex(complexKey : String, complexUrl : String , depth : Number, boneName : String = null, onLoadFinished : Function = null ) : Boolean
        {
            m_fnOnComplexLoadFinished = onLoadFinished;
            if (!isLoaded)
            {
                Foundation.Log.logErrorMsg("this function must be called after the character is loaded!");
                return false;
            }
            var bone : Bone;
            if (boneName == null) {
                bone = m_theSkeletonAnimationRef.skeleton.rootBone;
            }
            else
            {
                bone = m_theSkeletonAnimationRef.skeleton.findBone(boneName);
            }
            if(m_mapCharacterComplex == null)
                m_mapCharacterComplex = new CMap();
            var complex : CCharacterComplex = new CCharacterComplex(m_theRenderer);
            complex.bone = bone;


            var tempComplex : CCharacterComplex = m_mapCharacterComplex.find(complexKey);
            if (tempComplex != null)
            {
                tempComplex.dispose();
                m_mapCharacterComplex.remove(complexKey);
                complex.loadFile(complexUrl, null, null, m_iLoadingPriority, _onComplexLoadFinished);
                return true;
            }
            else
            {
                complex.loadFile(complexUrl, null, null, m_iLoadingPriority, _onComplexLoadFinished);
            }
            return false;

            function _onComplexLoadFinished(): void
            {
                m_mapCharacterComplex.add(complexKey, complex);

                addChild(complex);
                complex.setScale( scale.x, scale.y, scale.z );
                complex.playAnimation(currentAnimationClip.m_sName, currentAnimationClip.m_bLoop, false, false, 0, false, currentAnimationClip.m_fLoopTime);
                complex.m_theSkeletonAnimationRef.advanceTimeOnly( m_theSkeletonAnimationRef.state.getCurrent(0).time);
                complex.m_theSkeletonAnimationRef.state.apply( complex.m_theSkeletonAnimationRef.skeleton );
                complex.m_theSkeletonAnimationRef.skeleton.updateWorldTransform();

                if( m_fnOnComplexLoadFinished != null )
                {
                    m_fnOnComplexLoadFinished( complex, 0 ); // 0 means load successfully
                    m_fnOnComplexLoadFinished = null;
                }
            }
        }

        public function unloadComplex(complexKey : String): Boolean
        {
            if (m_mapCharacterComplex.find(complexKey) == null)
            {
                Foundation.Log.logWarningMsg("can not find " + complexKey + ", please check!");
                return false;
            }
            else
            {
                (m_mapCharacterComplex[complexKey] as CCharacterComplex).dispose();
                m_mapCharacterComplex[complexKey] = null;
                m_mapCharacterComplex.remove(complexKey);
                return true;
            }
        }

        private function _updateComplex(fDeltaTime : Number):void
        {
            if (complexMap == null)
                return;
            for each(var complex : CCharacterComplex in complexMap)
            {
                if (complex.isLoaded)
                {
                    complex.setPosition(complex.bone.worldX ,complex.bone.worldY,0);
                    complex.update(fDeltaTime);
                }
            }
        }

        public function get complexMap():CMap
        {
            return m_mapCharacterComplex;
        }
        //
        //
        public var AssetsSize : int = 0;

        protected var m_vAnimationTracks : Vector.<CAnimationClip> = new Vector.<CAnimationClip>( NUM_ANIMATION_TRACKS );

        protected var m_theSkeletonAnimationRef : SkeletonAnimation = null;
        protected var m_mapAnimationClipInfosRef : CMap = null;
        protected var m_theAnimationController : CAnimationController = null;

        protected var m_theCharacterInfo : CCharacterInfo;
        protected var m_fnOnLoadFinished : Function;
        protected var m_setOnAnimationChangedFunctions : CSet = new CSet();

        //mounts、wing and so on
        protected var m_mapCharacterComplex : CMap = null;
        protected var m_fnOnComplexLoadFinished : Function = null;

        private var m_theSpineLoader : CSpineLoader = null;
        private var m_iLoadingPriority : int = ELoadingPriority.NORMAL;

        private var m_vExtractAnimationOffsetBones : Vector.< String > = null;
        private var m_vExtractAnimationOffsetBoneIndices : Vector.< int > = null;
        private var m_vAnimationOffset : CVector2 = new CVector2();
        private var m_vAnimationOffsetPerSec : CVector2 = new CVector2();
        private var m_bExtractAnimationOffset : Boolean = true;

        private var m_OutlineRed : Number = 1.0;
        private var m_OutlineGreen : Number = 1.0;
        private var m_OutlineBlue : Number = 1.0;
        private var m_OutlineAlpha : Number = 1.0;
        private var m_OutlineSize : Number = 1.0;
        private var m_bSuppressPlayAnimationErrorMsg : Boolean = false;
        private var m_bEnableOutline : Boolean;
    }
}

import QFLib.Graphics.Character.CAnimationController;
import QFLib.Graphics.Character.CCharacterObject;
import QFLib.Graphics.RenderCore.CRenderer;

import spine.Bone;

class CCharacterComplex extends CCharacterObject
    {
         public function CCharacterComplex(theRenderer : CRenderer, animationController : CAnimationController = null)
         {
             super (theRenderer, animationController);
         }

        public function get bone() : Bone
        {
            return m_theBindBone;
        }
        public function set bone(bindBone : Bone): void
        {
            m_theBindBone = bindBone;
        }

        protected var m_theBindBone : Bone = null;
    }