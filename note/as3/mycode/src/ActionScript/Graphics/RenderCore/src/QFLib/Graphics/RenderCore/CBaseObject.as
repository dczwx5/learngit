package QFLib.Graphics.RenderCore
{
import QFLib.Foundation;
import QFLib.Foundation.CMap;
import QFLib.Foundation.CSet;
import QFLib.Graphics.RenderCore.render.ICamera;
import QFLib.Graphics.RenderCore.starling.display.DisplayObject;
import QFLib.Graphics.RenderCore.starling.display.DisplayObjectContainer;
import QFLib.Graphics.RenderCore.starling.filters.AlphaEffect;
import QFLib.Graphics.RenderCore.starling.filters.BlurEffect;
import QFLib.Graphics.RenderCore.starling.filters.DistortionEffect;
import QFLib.Graphics.RenderCore.starling.filters.FilterEffect;
import QFLib.Graphics.RenderCore.starling.filters.ObjectFilter;
import QFLib.Graphics.RenderCore.starling.filters.OutlineEffect;
import QFLib.Graphics.RenderCore.starling.filters.SmoothEffect;
import QFLib.Interface.IDisposable;
import QFLib.Interface.IRecyclable;
import QFLib.Math.CAABBox2;
import QFLib.Math.CMath;
import QFLib.Math.CVector2;
import QFLib.Math.CVector3;
import QFLib.ResourceLoader.CResource;

public class CBaseObject implements IDisposable, IRecyclable
    {
        public static var TAN_THETA_OF_CAMERA : Number = 0.4; // around 22 degrees of camera angle to the ground
        public static var SORT_TYPE : int = 1; // 1 : Original Mode; 2 : New Mode

        //
        //
        public function CBaseObject( theRenderer : CRenderer )
        {
            m_theRenderer = theRenderer;
            m_theDisplayNode = new DisplayObjectContainer();
        }

        public virtual function dispose() : void
        {
            if( m_bDisposed || m_bRecycled ) return ; // do not dispose recycled object
            //{
            //    Foundation.Log.logErrorMsg( "CBaseObject: Do not dispose a 'Recycled' object!" );
            //    throw new Error( "CBaseObject: Do not dispose a 'Recycled' object!" );
            //}

            if( m_theParentObject != null )
            {
                setParent( null );
                m_theParentObject = null;
            }

            if( m_setChildObjects != null )
            {
                m_vTempChildrenObjects = m_setChildObjects.toVector( m_vTempChildrenObjects );
                for each( var obj : CBaseObject in m_vTempChildrenObjects ) removeChild( obj );
                m_setChildObjects.clear();
                m_setChildObjects = null;
                m_vTempChildrenObjects = null;
            }

            if( m_theDisplayNode != null )
            {
                m_theDisplayNode.removeFromParent();
                m_theDisplayNode.dispose();
                m_theDisplayNode = null;
            }

            if ( m_mapFilter != null )
            {
                for each ( var effects : Vector.<FilterEffect> in m_mapFilter )
                {
                    effects.length = 0;
                    effects = null;
                }
                m_mapFilter.clear ();
                m_mapFilter = null;
            }

            m_vTempChildrenObjects = null;

            m_bDisposed = true;
        }

        [Inline]
        final public function get disposed() : Boolean
        {
            return m_bDisposed;
        }

        public virtual function revive() : void
        {
            if( m_bDisposed )
            {
                Foundation.Log.logErrorMsg( "CBaseObject: Revive a 'Disposed' object!" );
                throw new Error( "CBaseObject: Revive a 'Disposed' object!" );
            }

            this.visible = true;
            m_bRecycled = false;
        }

        public virtual function recycle() : void
        {
            if( m_bDisposed )
            {
                Foundation.Log.logErrorMsg( "CBaseObject: Do not recycle a 'Disposed' object!" );
                throw new Error( "CBaseObject: Do not recycle a 'Disposed' object!" );
            }
            if( m_bRecycled )
            {
                Foundation.Log.logErrorMsg( "CBaseObject: Do not recycle a 'Recycled' object!" );
                throw new Error( "CBaseObject: Do not recycle a 'Recycled' object!" );
            }

            this.visible = false;
            this.setParent( null );
            this.opaque = 1.0;
            this.setScale( 1.0, 1.0, 1.0 );
            this.setPosition( 0.0, 0.0, 0.0 );
            this.setRotation( 0.0 );
            this.flipX = false;
            this.flipY = false;
            m_bRecycled = true;
        }

        public virtual function disposeRecyclable() : void
        {
            m_bRecycled = false;
            dispose();
        }

        [Inline]
        final public function isRecycled() : Boolean
        {
            return m_bRecycled;
        }

        public virtual function clone() : CBaseObject
        {
            var theBaseObject : CBaseObject = new CBaseObject( m_theRenderer );
            theBaseObject.cloneFrom( this );
            return theBaseObject;
        }
        public virtual function cloneFrom( srcBaseObject : CBaseObject ) : void
        {
            this.visible = srcBaseObject.visible;
            //this.setParent( srcBaseObject.m_theParentObject );
            this.opaque = srcBaseObject.m_fOpaque;
            this.setScale( srcBaseObject.m_vScale.x, srcBaseObject.m_vScale.y, srcBaseObject.m_vScale.z );
            this.setPosition( srcBaseObject.m_vPosition.x, srcBaseObject.m_vPosition.y, srcBaseObject.m_vPosition.z );
            this.setRotation( srcBaseObject.rotation );
            this.flipX = srcBaseObject.flipX;
            this.flipY = srcBaseObject.flipY;

            this.setColor( srcBaseObject.m_vColor.r, srcBaseObject.m_vColor.g, srcBaseObject.m_vColor.b, srcBaseObject.m_fOpaque );
        }

        // try getting all used resources - implement by the derived classes
        public virtual function retrieveAllResources( vResources : Vector.<CResource> = null, iBeginIndex : int = 0 ) : int
        {
            return 0;
        }

        virtual public function get renderableObject () : DisplayObject{ return null; }

        [Inline]
        public function get position() : CVector3
        {
            return m_vPosition;
        }
        public function setPosition( x : Number, y : Number, depth : Number = 0.0 ) : void // larger depth, later drawing
        {
            m_vPosition.setValueXYZ( x, y, depth );

            m_theDisplayNode.x = x;
            m_theDisplayNode.y = y;

            _onPositionChanged();
        }

        public function setPosition3D( x : Number, y : Number, z : Number ) : void
        {
            var depth : Number = z * TAN_THETA_OF_CAMERA; // to convert 3D position to 2D screen space
            m_theDisplayNode.x = x;
            m_theDisplayNode.y = -y + depth;

            m_vPosition.setValueXYZ( x, m_theDisplayNode.y, depth );

            _onPositionChanged();
        }

        [Inline]
        public virtual function moveTo( x : Number, y : Number, z : Number ) : void
        {
            setPosition( x, y, z );
        }

        [Inline]
        public virtual function move( x : Number, y : Number, z : Number ) : void
        {
            setPosition( this.m_vPosition.x + x, this.m_vPosition.y + y, this.m_vPosition.z + z );
        }

        [Inline]
        public function setRotation( angle : Number ) : void
        {
            m_theDisplayNode.rotation = angle;
        }

        [Inline]
        public function get rotation() : Number
        {
            return m_theDisplayNode.rotation;
        }

        [Inline]
        public function get x() : Number
        {
            return m_theDisplayNode.x;
        }

        [Inline]
        public function get y() : Number
        {
            return m_theDisplayNode.y;
        }

        public function setScale( x : Number, y : Number, z : Number = 1.00 ) : void
        {
            m_vScale.x = x;
            m_vScale.y = y;
            m_vScale.z = z;
            _setScaleWithFlip();
        }
        [Inline]
        public function get scale() : CVector3
        {
            return m_vScale;
        }

        [Inline]
        public function get flipX() : Boolean
        {
            return m_bFlipX;
        }
        [Inline]
        public function set flipX( bFlip : Boolean ) : void
        {
            m_bFlipX = bFlip;
            _setScaleWithFlip();
        }
        [Inline]
        public function get flipY() : Boolean
        {
            return m_bFlipY;
        }
        [Inline]
        public function set flipY( bFlip : Boolean ) : void
        {
            m_bFlipY = bFlip;
            _setScaleWithFlip();
        }

        [Inline]
        public function get skewXDeg() : Number
        {
            return CMath.radToDeg( m_theDisplayNode.skewX );
        }
        [Inline]
        public function set skewXDeg( fSkewX : Number ) : void
        {
            m_theDisplayNode.skewX = CMath.degToRad( fSkewX );
        }
        [Inline]
        public function get skewYDeg() : Number
        {
            return CMath.radToDeg( m_theDisplayNode.skewY );
        }
        [Inline]
        public function set skewYDeg( fSkewY : Number ) : void
        {
            m_theDisplayNode.skewY = CMath.degToRad( fSkewY );
        }

        [Inline] public function get color() : CVector3 { return m_vColor; }
        [Inline] public virtual function setColor( r : Number, g : Number, b : Number, alpha : Number = 1.0, masking : Boolean = false ) : void
        {
            m_vColor.r = r;
            m_vColor.g = g;
            m_vColor.b = b;
            m_fOpaque = alpha;
        }

        public function setLightColorAndContrast ( r : Number = 1.0, g : Number = 1.0, b : Number = 1.0, alpha : Number = 1.0, contrast : Number = 0.0 ) : void { }

        public function resetColor () : void {}

        [Inline] public function get opaque() : Number { return m_fOpaque; }
        [Inline] public virtual function set opaque( fOpaque : Number ) : void
        {
            if( fOpaque < 0.0 ) fOpaque = 0.0;
            m_fOpaque = fOpaque;
        }

        [Inline] public function set renderQueueID( iQueueID : int ) : void
        {
            m_theDisplayNode.renderQueueID = iQueueID;
        }

        [Inline]
        public function set inheritRenderQueue( value : Boolean ) : void
        {
            m_theDisplayNode.inheritRenderQueue = value;
        }

        [Inline]
        public function set visible( bVisible : Boolean ) : void
        {
            m_theDisplayNode.visible = bVisible;
        }
        [Inline]
        public function get visible() : Boolean
        {
            return m_theDisplayNode.visible;
        }

        [Inline]
        public virtual function get currentBound() : CAABBox2
        {
            return null;
        }

        public function setFilter ( owner : DisplayObject, name : String, enable : Boolean ) : Vector.<FilterEffect>
        {
            if ( owner == null ) return null;
            var effects : Vector.<FilterEffect> = _findFilter ( name );
            if ( effects == null )
            {
                effects = new Vector.<FilterEffect> ();
                owner.filterEnable = true;
                var filter : ObjectFilter = owner.objectFilter;
                switch ( name )
                {
                    case ObjectFilter.SolidOutline:
                        effects.length = 1;
                        effects[ 0 ] = filter.addEffect ( OutlineEffect, enable );
                        filter.setFilterMode ( ObjectFilter.ABOVE );
                        break;
                    case ObjectFilter.RimLightOutline:
                        effects.length = 2;
                        var params : Array = [ true, true ];
                        effects[ 0 ] = filter.addEffect ( BlurEffect, enable, params );
                        params[ 0 ] = false; params[ 1 ] = true;
                        effects[ 1 ] = filter.addEffect ( BlurEffect, enable, params );
                        filter.setFilterMode ( ObjectFilter.BELOW );
                        break;
                    case ObjectFilter.GaussianBlur:
                        effects.length = 3;
                        effects[ 0 ] = filter.addEffect ( SmoothEffect, enable );
                        params = [ true ];
                        effects[ 1 ] = filter.addEffect ( BlurEffect, enable, params );
                        params[ 0 ] = false;
                        effects[ 2 ] = filter.addEffect ( BlurEffect, enable, params );
                        filter.setFilterMode ( ObjectFilter.ABOVE );
                        break;
                    case ObjectFilter.Alpha:
                        effects.length = 1;
                        effects[ 0 ] = filter.addEffect ( AlphaEffect, enable );
                        filter.setFilterMode ( ObjectFilter.ABOVE );
                        break;
                    case ObjectFilter.Smooth:
                        effects.length = 1;
                        effects[ 0 ] = filter.addEffect ( SmoothEffect, enable );
                        filter.setFilterMode ( ObjectFilter.ABOVE );
                        break;
                    case ObjectFilter.Distortion:
                        effects.length = 1;
                        effects[ 0 ] = filter.addEffect ( DistortionEffect, enable );
                        filter.setFilterMode ( ObjectFilter.ABOVE );
                        break;
                    default:
                        break;
                }

                if ( effects.length > 0 )
                    m_mapFilter.add ( name, effects );
            }

            for ( var i : int = 0, count : int = effects.length; i < count; i++ )
            {
                effects[ i ].enable = enable;
            }

            return effects;
        }

        public function get currentGlobalBound() : CAABBox2
        {
            if( this.currentBound != m_theLastCurrentBound ) m_bGlobalVisibleBoundDirty = true;

            if( m_bGlobalVisibleBoundDirty == false ) return m_theGlobalVisibleBound;
            else
            {
                m_theLastCurrentBound = this.currentBound;
                if( m_theLastCurrentBound == null ) m_theGlobalVisibleBound.set( CAABBox2.ZERO );
                else m_theGlobalVisibleBound.set( m_theLastCurrentBound );

                if( this.flipX ) m_theGlobalVisibleBound.multiplyXY( -1.0, 1.0 );
                if( this.flipY ) m_theGlobalVisibleBound.multiplyXY( 1.0, -1.0 );

                var v2DPos : CVector3 = this.position;
                m_theGlobalVisibleBound.move( v2DPos.x, v2DPos.y );

                m_bGlobalVisibleBoundDirty = false;
                return m_theGlobalVisibleBound;
            }
        }

        [Inline]
        public function get renderer() : CRenderer
        {
            return m_theRenderer;
        }
        [Inline]
        public function set usingCamera( cam : ICamera ) : void
        {
            m_theDisplayNode.usingCamera = cam;
        }
        [Inline]
        public function get usingCamera() : ICamera { return m_theDisplayNode.usingCamera; }

        [Inline]
        public function get layer() : int
        {
            return m_theDisplayNode.layer;
        }
        [Inline]
        public function set layer( iLayer : int ) : void
        {
            m_theDisplayNode.layer = iLayer;
        }

        [Inline]
        public function get touchable() : Boolean
        {
            return m_theDisplayNode.touchable;
        }
        [Inline]
        public function set touchable( bTouchable : Boolean ) : void
        {
            m_theDisplayNode.touchable = bTouchable;
        }

        [Inline]
        public function get useHandCursor() : Boolean
        {
            return m_theDisplayNode.useHandCursor;
        }
        [Inline]
        public function set useHandCursor( bTouchable : Boolean ) : void
        {
            m_theDisplayNode.useHandCursor = bTouchable;
        }

		//
		// parent / child functions
		//
        [Inline]
		public function attachToRoot() : void
		{
			m_theRenderer._rootDisplayObjectContainer().addChild( m_theDisplayNode );
		}

        [Inline]
        public function get parent() : CBaseObject
        {
            return m_theParentObject;
        }

        public virtual function setParent( parent : CBaseObject, bLinkDisplayLayer : Boolean = true, bCallParent : Boolean = true ) : void
        {
            if( bCallParent )
            {
                if( m_theParentObject != null ) m_theParentObject.removeChild( this );
                m_theParentObject = parent;
                if( parent != null ) parent.addChild( this );
            }
            else
            {
                m_theParentObject = parent;
            }

            if( bLinkDisplayLayer )
            {
                if( parent == null ) _setParent( null );
                else _setParent( parent.m_theDisplayNode );
            }
        }
        public virtual function addChild( childObj : CBaseObject, bLinkDisplayLayer : Boolean = true ):void
        {
            //if ( childObj.parent == this ) return;
            if( m_setChildObjects == null ) m_setChildObjects = new CSet();

            if( childObj.parent != this ) childObj.setParent( null, bLinkDisplayLayer, true );
            childObj.setParent( this, bLinkDisplayLayer, false );
            m_setChildObjects.add( childObj );

            if( bLinkDisplayLayer ) _addChild( childObj.m_theDisplayNode );

            m_bDepthDirty = true;
        }
        public virtual function removeChild( childObj : CBaseObject, bLinkDisplayLayer : Boolean = true ):void
        {
            childObj.setParent( null, bLinkDisplayLayer, false );
            if( m_setChildObjects != null ) m_setChildObjects.remove( childObj );

            if( bLinkDisplayLayer ) _removeChild( childObj.m_theDisplayNode );
        }

        public function sortChildren() : void
        {
            if( m_setChildObjects == null || m_setChildObjects.count == 0 ) return ;

            m_vTempChildrenObjects = m_setChildObjects.toVector( m_vTempChildrenObjects );

            // src:
//            var obj : CBaseObject;
//            for each( obj in m_vTempChildrenObjects ) _removeChild( obj.m_theDisplayNode ); // 大量的EventDispatch调用，而且是bubble = true的
//
//            m_vTempChildrenObjects.sort( _onSortChildren );
//
//            for each( obj in m_vTempChildrenObjects ) _addChild( obj.m_theDisplayNode ); // 大量的EventDispatch调用，而且是bubble = true的

            // optimize1 : addChildAt
            m_vTempChildrenObjects.sort( _onSortChildren );

            if ( SORT_TYPE == 1 )
            {
                for ( var i : int = 0, len : int = m_vTempChildrenObjects.length; i < len; ++i )
                {
                    // 减少 event dispatch
                    _addChildAt( m_vTempChildrenObjects[i].m_theDisplayNode, i );
                }
//                m_theDisplayNode.mChildren.length = len;
            }
            else if ( SORT_TYPE == 2 )
            {
                for ( i = 0, len = m_vTempChildrenObjects.length; i < len; ++i )
                {
                    // 减少 event dispatch
//                _addChildAt( m_vTempChildrenObjects[i].m_theDisplayNode, i );
                    m_theDisplayNode.replaceChildAt( m_vTempChildrenObjects[i].m_theDisplayNode, i );
                }
                m_theDisplayNode.mChildren.length = len;
            }
            else
            {
                Foundation.Log.logErrorMsg( "sortChildren error type : " + SORT_TYPE );
            }


            // optimize2 : updateChildrenAt
//            m_vTempChildrenObjects.sort( _onSortChildren );
//            var idx : int = 0;
//            for ( var i : int = 0, len : int = m_vTempChildrenObjects.length; i < len; ++i )
//            {
//                // src:
//                var dspObj : DisplayObject = m_vTempChildrenObjects[i].renderableObject;
//                if ( dspObj )
//                {
//                    m_theDisplayNode.updateChildrenAt(idx, dspObj); // 后面再优化
//                    ++idx;
//                }
//            }
        }

		// 由原来的匿名函数改类成员函数，减少匿名函数频繁的create, destroy的gc负担
        private function _onSortChildren( bg1 : CBaseObject, bg2 : CBaseObject ) : int
        {
            var pos1 : CVector3 = bg1.m_vPosition; // 原来bg1.position但Inline无效，换m_vPosition，调用频率高
            var pos2 : CVector3 = bg2.m_vPosition;
            // the bigger z the later drawing
            if( pos1.z > pos2.z ) return 1;
            else if( pos1.z < pos2.z ) return -1;
            else
            {
                // the bigger y the later drawing
                if( pos1.y > pos2.y ) return 1;
                else if( pos1.y < pos2.y ) return -1;
                else
                {
                    // the bigger x the later drawing
                    return pos1.x - pos2.x;
                }
            }
        }

        public function findParentByType( cls : Class ) : *
        {
            var theBaseObject : CBaseObject = this.parent;
            while( theBaseObject != null )
            {
                if( theBaseObject is cls ) return theBaseObject;
                else theBaseObject = theBaseObject.parent;
            }

            return null;
        }

        //
		//
        public virtual function update( fDeltaTime : Number ) : void
        {
            if( m_bDepthDirty )
            {
                sortChildren();
                m_bDepthDirty = false;
            }
        }


        /*public function addTimeTicker(func:Function):void
        {
            if ( m_theTimeTicker == null)
            {
                m_theTimeTicker = new TimeTicker();
                Starling.current.juggler.add(m_theTimeTicker);
            }

            m_theTimeTicker.addTicker(func);
        }

        public function removeTimeTicker(func:Function):void
        {
            if (m_theTimeTicker)
            {
                m_theTimeTicker.removeTicker(func);
            }
        }*/
        //
        //
        [Inline]
        protected virtual function _setParent( parent : DisplayObjectContainer ):void
        {
            if( parent != null ) parent.addChild( m_theDisplayNode );
            else m_theDisplayNode.removeFromParent();
        }
        [Inline]
        protected virtual function _addChild( childObj : DisplayObject ):void
        {
            m_theDisplayNode.addChild( childObj );
        }
        [Inline]
        protected virtual function _addChildAt( childObj : DisplayObject, idx : int ):void
        {
            m_theDisplayNode.addChildAt( childObj, idx );
        }

        [Inline]
        protected virtual function _removeChild( childObj : DisplayObject ):void
        {
            m_theDisplayNode.removeChild( childObj );
        }

        protected virtual function _onPositionChanged() : void
        {
            if( m_fLastDepth != m_vPosition.z )
            {
                m_fLastDepth = m_vPosition.z;
                if( m_theParentObject != null ) m_theParentObject._setDepthDirty();
            }

            m_bGlobalVisibleBoundDirty = true;
        }

        [Inline]
        private function _setDepthDirty() : void
        {
            m_bDepthDirty = true;
        }

        private function _setScaleWithFlip() : void
        {
            if( m_bFlipX ) m_theDisplayNode.scaleX = -m_vScale.x;
            else m_theDisplayNode.scaleX = m_vScale.x;

            if( m_bFlipY ) m_theDisplayNode.scaleY = -m_vScale.y;
            else m_theDisplayNode.scaleY = m_vScale.y;

            m_bGlobalVisibleBoundDirty = true;
        }

        private function _findFilter ( name : String ) : Vector.<FilterEffect>
        {
            var effects : Vector.<FilterEffect> = m_mapFilter.find ( name );
            return effects;
        }

        //
        //
        protected var m_setChildObjects : CSet = null;
        protected var m_theParentObject : CBaseObject = null;
        protected var m_theRenderer : CRenderer = null;
        protected var m_theDisplayNode : DisplayObjectContainer = null;

        protected var m_theGlobalVisibleBound : CAABBox2 = new CAABBox2( CVector2.ZERO );
        protected var m_theLastCurrentBound : CAABBox2 = null;

        protected var m_mapFilter : CMap = new CMap();

        protected var m_vScale : CVector3 = new CVector3( 1.0, 1.0, 1.0 );
        public var m_vPosition : CVector3 = new CVector3();
        protected var m_vColor : CVector3 = new CVector3( 1.0, 1.0, 1.0 );

        protected var m_fOpaque : Number = 1.0;
        protected var m_fLastDepth : Number = 0.0;

        protected var m_bDepthDirty : Boolean = true;
        protected var m_bFlipX : Boolean = false;
        protected var m_bFlipY : Boolean = false;
        protected var m_bGlobalVisibleBoundDirty :Boolean = true;
        protected var m_bDisposed : Boolean = false;
        protected var m_bRecycled : Boolean = false;

        private var m_vTempChildrenObjects : Vector.<Object> = null;
    }
}

