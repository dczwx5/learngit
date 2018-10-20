/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2017/1/9.
 */
package QFLib.QEngine.Core
{
    import QFLib.Foundation;
    import QFLib.Foundation.CMap;
    import QFLib.Interface.IDisposable;
    import QFLib.Math.CMath;
    import QFLib.Math.CMatrix4;
    import QFLib.Math.CQuaternion;
    import QFLib.Math.CVector3;
    import QFLib.Math.QuaternionUtil;
    import QFLib.QEngine.Renderer.*;

    public class Transform implements IDisposable
    {
        use namespace Engine_Internal;

        private static const sVector3DHelper : CVector3 = CVector3.zero();
        private static const sQuaternionHelper : CQuaternion = CQuaternion.identity;
        private static const sRawDataHelper : Vector.<Number> = new Vector.<Number>( 16 );

        public function Transform( theOwnerNode : SceneNode = null )
        {
            m_pOwnerNode = theOwnerNode;

            m_LocalMatrix = new CMatrix4();
            m_WorldMatrix = new CMatrix4();

            m_LocalMatrixDirty = false;
            m_WorldMatrixDirty = false;
        }
        private var m_mapChildren : CMap = new CMap();
        private var m_WorldMatrix : CMatrix4;
        private var m_LocalMatrix : CMatrix4;
        /**
         * local rotation/scale/position
         */
        private var m_LocalRotation : CQuaternion = CQuaternion.identity;
        private var m_LocalScale : CVector3 = CVector3.one();
        private var m_LocalPosition : CVector3 = CVector3.zero();
        /**
         * world rotation/scale/position
         */
        private var m_WorldRotation : CQuaternion = CQuaternion.identity;
        private var m_WorldScale : CVector3 = CVector3.one();
        private var m_WorldPosition : CVector3 = CVector3.zero();
        private var m_pParent : Transform = null;
        private var m_pOwnerNode : SceneNode = null;
        private var m_LocalMatrixDirty : Boolean = true;
        private var m_WorldMatrixDirty : Boolean = true;
        private var m_LocalPositionDirty : Boolean = true;
        private var m_LocalScaleDirty : Boolean = true;
        private var m_LocalRotationDirty : Boolean = true;

        public function get localMatrix() : CMatrix4
        {
            if( m_LocalMatrixDirty )
            {
                _computeLocalMatrix();
                m_LocalMatrixDirty = false;
            }

            return m_LocalMatrix;
        }

        public function get worldMatrix() : CMatrix4
        {
            if( m_WorldMatrixDirty )
            {
                _computeWorldMatrix();
                m_WorldMatrixDirty = false;
            }

            return m_WorldMatrix;
        }

        [Inline]
        final public function set x( value : Number ) : void
        {
            if( m_LocalPosition.x != value )
            {
                m_LocalPosition.x = value;
                m_LocalPositionDirty = true;
                _localMatrixDirty = true;
            }
        }

        [Inline]
        final public function set y( value : Number ) : void
        {
            if( m_LocalPosition.y != value )
            {
                m_LocalPosition.y = value;
                m_LocalPositionDirty = true;
                _localMatrixDirty = true;
            }
        }

        [Inline]
        final public function set z( value : Number ) : void
        {
            if( m_LocalPosition.z != value )
            {
                m_LocalPosition.z = value;
                m_LocalPositionDirty = true;
                _localMatrixDirty = true;
            }
        }

        [Inline]
        final public function set scaleX( value : Number ) : void
        {
            if( m_LocalScale.x != value )
            {
                m_LocalScale.x = value;
                m_LocalScaleDirty = true;
                _localMatrixDirty = true;
            }
        }

        [Inline]
        final public function set scaleY( value : Number ) : void
        {
            if( m_LocalScale.y != value )
            {
                m_LocalScale.y = value;
                m_LocalScaleDirty = true;
                _localMatrixDirty = true;
            }
        }

        [Inline]
        final public function set scaleZ( value : Number ) : void
        {
            if( m_LocalScale.x != value )
            {
                m_LocalScale.x = value;
                m_LocalScaleDirty = true;
                _localMatrixDirty = true;
            }
        }

        public function get worldScale() : CVector3
        {
            if( m_pParent == null )
            {
                m_WorldScale.set( m_LocalScale );
            }
            else if( m_LocalScaleDirty )
            {
                m_WorldScale.x = m_pParent.worldScale.x * m_LocalScale.x;
                m_WorldScale.x = m_pParent.worldScale.y * m_LocalScale.y;
                m_WorldScale.x = m_pParent.worldScale.z * m_LocalScale.z;

                m_LocalScaleDirty = false;
            }
            return m_WorldScale;
        }

        public function get worldOrientation() : CQuaternion
        {
            if( m_pParent == null )
            {
                m_WorldRotation.copy( m_LocalRotation );
            }
            else if( m_LocalRotationDirty )
            {
                m_WorldRotation.copy( m_pParent.worldOrientation );
                m_WorldRotation.premultipyQuaternion( m_LocalRotation );

                m_LocalRotationDirty = false;
            }

            return m_WorldRotation;
        }

        public function get worldPosition() : CVector3
        {
            if( m_pParent == null )
            {
                m_WorldPosition.set( m_LocalPosition );
            }
            if( m_LocalPositionDirty )
            {
                m_WorldPosition.x = m_pParent.worldPosition.x + m_LocalPosition;
                m_WorldPosition.x = m_pParent.worldPosition.x + m_LocalPosition;
                m_WorldPosition.x = m_pParent.worldPosition.x + m_LocalPosition;

                m_LocalPositionDirty = false;
            }
            return m_WorldPosition;
        }

        [Inline]
        final public function get localScale() : CVector3
        {
            return m_LocalScale;
        }

        [Inline]
        final public function get localOrientation() : CQuaternion
        {
            return m_LocalRotation;
        }

        [Inline]
        final public function get localPosition() : CVector3
        {
            return m_LocalPosition;
        }

        [Inline]
        final public function get theOwnerNode() : Node
        {
            return m_pOwnerNode;
        }

        [Inline]
        final public function get parent() : Transform
        { return m_pParent; }

        public function set parent( value : Transform ) : void
        {
            if( m_pParent == value ) return;

            var parentNode : Node = value.theOwnerNode;
            parentNode.addChild( m_pOwnerNode );
        }

        public function dispose() : void
        {
            m_LocalMatrix = null;
            m_WorldMatrix = null;

            m_LocalRotation = null;
            m_LocalScale = null;
            m_LocalPosition = null;

            m_WorldRotation = null;
            m_WorldScale = null;
            m_WorldPosition = null;

            m_pOwnerNode = null;
            m_pParent = null;
            m_mapChildren.clear();
            m_mapChildren = null;
        }

        public function setLocalScale( scale : CVector3 ) : void
        {
            if( m_LocalScale.equals( scale ) ) return;

            m_LocalScale.set( scale );
            m_LocalScaleDirty = true;
            _localMatrixDirty = true;
        }

        public function setLocalRotation( rotation : CQuaternion ) : void
        {
            if( m_LocalRotation.equal( rotation ) ) return;

            m_LocalRotation.mX = rotation.mX;
            m_LocalRotation.mY = rotation.mY;
            m_LocalRotation.mZ = rotation.mZ;
            m_LocalRotation.mW = rotation.mW;

            m_LocalRotationDirty = true;
            _localMatrixDirty = true;
        }

        public function setLocalPosition( position : CVector3 ) : void
        {
            if( m_LocalPosition.equals( position ) ) return;

            m_LocalPosition.set( position );
            m_LocalPositionDirty = true;
            _localMatrixDirty = true;
        }

        /**
         * rotate with y axis;
         * @param angle: radian
         * @param space
         */
        public function yaw( angle : Number, space : int = CMath.SPACE_LOCAL ) : void
        {
            if( Math.abs( angle ) < CMath.BIG_EPSILON ) return;

            var q : CQuaternion = new CQuaternion();
            q.setupNormAxisRotate( CMath.Y_Axis, angle );

            rotate( q, space );
        }

        /**
         * rotate with x axis
         * @param angle: radian
         * @param space
         */
        public function pitch( angle : Number, space : int = CMath.SPACE_LOCAL ) : void
        {
            if( Math.abs( angle ) < CMath.BIG_EPSILON ) return;

            var q : CQuaternion = new CQuaternion();
            q.setupNormAxisRotate( CMath.X_Axis, angle );

            rotate( q, space );
        }

        /**
         * rotate with z axis
         * @param angle: radian
         * @param space
         */
        public function roll( angle : Number, space : int = CMath.SPACE_LOCAL ) : void
        {
            if( Math.abs( angle ) < CMath.BIG_EPSILON ) return;

            var q : CQuaternion = new CQuaternion();
            q.setupNormAxisRotate( CMath.Z_Axis, angle );

            rotate( q, space );
        }

        public function rotate( quat : CQuaternion, space : int = CMath.SPACE_LOCAL ) : void
        {
            var normQuat : CQuaternion = QuaternionUtil.normalized( quat );
            switch( space )
            {
                case CMath.SPACE_LOCAL:
                    m_LocalRotation.premultipyQuaternion( normQuat );
                    break;
                case CMath.SPACE_PARENT:
                    m_LocalRotation.postmultiplyQuaternion( normQuat );
                    break;
                case CMath.SPACE_GLOBAL:
                    var result : CQuaternion = QuaternionUtil.quaternionMultiple( m_WorldRotation, normQuat );
                    result = QuaternionUtil.quaternionMultiple( m_WorldRotation.getInverse(), result, result );
                    m_LocalRotation.premultipyQuaternion( result );
                    break;
                default:
                    Foundation.Log.logWarningMsg( "There were just only three target space you can rotate to, please chech it!" );
                    break;
            }
        }

        public function transform( scale : CVector3, rotation : CQuaternion, position : CVector3 ) : void
        {
            m_LocalScale.mulOn( scale );
            m_LocalRotation.premultipyQuaternion( rotation );
            m_LocalPosition.addOn( position );

            _localMatrixDirty = true;
        }

        public function world2LocalTransform( point : CVector3 ) : CVector3
        {
            return CVector3.zero();
        }

        public function local2WorldTransform( point : CVector3 ) : CVector3
        {
            return CVector3.zero();
        }

        Engine_Internal function _notifyAddChild( child : Transform ) : void
        {
            m_mapChildren.add( m_mapChildren.count, child );
            child._notifyAddToParent( this );
        }

        Engine_Internal function _notifyRemoveChild( child : Transform ) : void
        {
            child._notifyRemoveFromParent();
            m_mapChildren.remove( child.theOwnerNode.indexInParent );
        }

        Engine_Internal function _notifyRemoveFromParent() : void
        {
            m_pParent = null;
            _worldMatrixDirty = true;
        }

        Engine_Internal function _notifyAddToParent( value : Transform ) : void
        {
            m_pParent = value;
            _worldMatrixDirty = true;
        }

        Engine_Internal function set _worldMatrixDirty( value : Boolean ) : void
        {
            if( value ) _notifyChildrenWorldMatrixDirty();
            m_WorldMatrixDirty = value;
        }

        Engine_Internal function set _localMatrixDirty( value : Boolean ) : void
        {
            if( value ) _notifyChildrenWorldMatrixDirty();
            m_LocalMatrixDirty = value;
            m_WorldMatrixDirty = value;
        }

        Engine_Internal function _notifyChildrenWorldMatrixDirty() : void
        {
            var child : Transform = null;
            for( var i : int = 0, n : int = m_mapChildren.count; i < n; i++ )
            {
                child = m_mapChildren[ i ];
                child._worldMatrixDirty = true;
            }
        }

        Engine_Internal function _computeWorldMatrix() : void
        {
            if( m_pParent == null )
                m_WorldMatrix.copy( localMatrix );
            else
            {
                m_WorldMatrix.copy( localMatrix );
                m_WorldMatrix.append( m_pParent.worldMatrix );
            }
        }

        Engine_Internal function _computeLocalMatrix() : void
        {
            m_LocalMatrix.identity();

            var rawData : Vector.<Number> = sRawDataHelper;
            m_LocalMatrix.matrix3D.copyRawDataTo( rawData );
            m_LocalRotation.toMatrix4( m_LocalMatrix );
            rawData[ 12 ] = m_LocalPosition.x;
            rawData[ 13 ] = m_LocalPosition.y;
            rawData[ 14 ] = m_LocalPosition.z;
            rawData[ 15 ] = 1.0;

            rawData[ 0 ] *= m_LocalScale.x;
            rawData[ 5 ] *= m_LocalScale.y;
            rawData[ 10 ] *= m_LocalScale.z;
            m_LocalMatrix.matrix3D.copyRawDataFrom( rawData );
        }
    }
}
