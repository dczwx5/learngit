//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/7/4
//----------------------------------------------------------------------------------------------------------------------


package QFLib.Node
{
    import QFLib.Foundation.CSet;
    import QFLib.Math.CVector2;
    import QFLib.Math.CVector3;
    import QFLib.Memory.CSmartObject;

    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;

    //
    //
    public class CNode extends CSmartObject
    {
        public function CNode()
        {
        }

        public override function dispose() : void
        {
            if( m_theParent != null ) setParent( null, false );

            for each( var child : CNode in m_setChildren )
            {
                child.setParent( null );
            }
            m_setChildren.clear();
            m_setChildren = null;

            super.dispose();
        }

        // parent / child
        public virtual function setParent( theParentNode : CNode, bResetLocalTransform : Boolean = true, eParentMode : int = EParentMode.PARENT_NORMAL ) : void
        {
            if( m_theParent == theParentNode && m_eParentMode == eParentMode ) return ;
            else m_eParentMode = eParentMode;

            var mxGlobal : Matrix3D;
            if( bResetLocalTransform ) mxGlobal = this._globalMatrix;

            if( m_theParent != null ) m_theParent._removeChild( this, true );
            if( theParentNode != null )
            {
                m_eParentMode = eParentMode;
                theParentNode._addChild( this, true );
            }

            if( bResetLocalTransform )
            {
                if( m_theParent != null )
                {
                    m_mxLocal.copyFrom( mxGlobal );
                    m_mxLocal.append( this.m_theParent._inverseGlobalMatrix );
                }
                else m_mxLocal.copyFrom( mxGlobal );

                _setDirtyFlags( EDirtyFlag.MX_FLAG_GLOBAL, false ); // every thing remain the same except the global matrix were recalculated above
            }
            else _setDirtyFlags( EDirtyFlag.FLAGS_MATTER_TO_CHILDREN_MASKS, true ); // every thing except the local are changed
        }
        public function get parent() : CNode
        {
            return m_theParent;
        }
        public function set parent( theParentNode : CNode ) : void
        {
            setParent( theParentNode )
        }
        public function get parentMode() : int
        {
            return m_eParentMode;
        }
        public function set parentMode( eParentMode : int ) : void
        {
            m_eParentMode = eParentMode;
        }

        public function numChildren() : int
        {
            return m_setChildren.count;
        }

        public function setScreenPosition ( x : Number, y : Number, depth : Number ) : void {}

        //
        // global position
        //
        public virtual function setPosition( fGlobalX : Number, fGlobalY : Number, fGlobalZ : Number ) : void
        {
            if( m_theParent == null )
            {
                setLocalPosition( fGlobalX, fGlobalY, fGlobalZ );
            }
            else
            {
                m_vTemp.setTo( fGlobalX, fGlobalY, fGlobalZ );
                var vPos : Vector3D = m_theParent._inverseGlobalMatrix.transformVector( m_vTemp ); // m_vTemp * this._inverseGlobalMatrix
                setLocalPosition( vPos.x, vPos.y, vPos.z );
            }
        }
        public function get position() : CVector3
        {
            if( _checkDirtyFlags( EDirtyFlag.VECTOR_FLAG_GLOBAL_POSITION ) == false ) return m_vGlobalPosition;
            _unsetDirtyFlags( EDirtyFlag.VECTOR_FLAG_GLOBAL_POSITION );

            if( m_theParent == null )
            {
                if( m_vGlobalPosition != this.localPosition ) m_vGlobalPosition = m_vLocalPosition;
            }
            else
            {
                if( m_vGlobalPosition == m_vLocalPosition ) m_vGlobalPosition = new CVector3();

                var v : Vector3D = this._globalMatrix.position;
                m_vGlobalPosition.setValueXYZ( v.x, v.y, v.z );
            }
            return m_vGlobalPosition;
        }o

        //
        public function setScale( fLocalX : Number, fLocalY : Number, fLocalZ : Number ) : void
        {
            m_vLocalScale.setValueXYZ( fLocalX, fLocalY, fLocalZ );

            if( m_mxLocalScaled == m_mxLocal )
            {
                m_mxLocalScaled = new Matrix3D();
                if( m_mxGlobalScaled == m_mxLocal ) m_mxGlobalScaled = m_mxLocalScaled; // m_mxGlobalScaled default is the same as m_mxLocalScaled,
                                                                                        // if m_mxLocalScaled changed, change m_mxGlobalScaled too
            }
            _setDirtyFlags( EDirtyFlag.FLAGS_LOCAL_SCALED_CHANGE_MASKS, true );
        }
        public function get scale() : CVector3
        {
            return m_vLocalScale;
        }
        public function get globalScale() : CVector3
        {
            if( _checkDirtyFlags( EDirtyFlag.VECTOR_FLAG_GLOBAL_SCALE ) == false ) return m_vGlobalScale;
            _unsetDirtyFlags( EDirtyFlag.VECTOR_FLAG_GLOBAL_SCALE );

            if( m_theParent == null )
            {
                if( m_vGlobalScale != m_vLocalScale ) m_vGlobalScale = m_vLocalScale;
            }
            else
            {
                if( m_vGlobalScale == m_vLocalScale ) m_vGlobalScale = new CVector3();
                m_vGlobalScale.set( m_vLocalScale );
                m_vGlobalScale.mulOn( m_theParent.globalScale );
            }
            return m_vGlobalScale;
        }

        //
        public function pointAt( vGlobalPos : CVector3, vSelfFace : CVector3 = null, vSelfUp : CVector3 = null ) : void
        {
            m_vTemp.setTo( vGlobalPos.x, vGlobalPos.y, vGlobalPos.z );
            var vPos : Vector3D = this._inverseGlobalMatrix.transformVector( m_vTemp ); // m_vTemp * this._inverseGlobalMatrix

            if( vSelfFace == null ) m_vTemp.setTo( CVector3.Z_AXIS.x, CVector3.Z_AXIS.y, CVector3.Z_AXIS.z );
            else m_vTemp.setTo( vSelfFace.x, vSelfFace.y, vSelfFace.z );

            if( vSelfUp == null ) m_vTemp2.setTo( CVector3.Y_AXIS.x, CVector3.Y_AXIS.y, CVector3.Y_AXIS.z );
            else m_vTemp2.setTo( vSelfUp.x, vSelfUp.y, vSelfUp.z );

            m_mxLocal.pointAt( vPos, m_vTemp, m_vTemp2 );

            _setDirtyFlags( EDirtyFlag.FLAGS_LOCAL_MATRIX_CHANGE_MASKS, true );
        }
        public function faceTo( vGlobalFace : CVector3, vGlobalUp : CVector3 ) : void
        {
            m_vTemp.setTo( vGlobalFace.x, vGlobalFace.y, vGlobalFace.z );
            var vLocalFace : Vector3D = this._inverseGlobalMatrix.transformVector( m_vTemp ); // m_vTemp * this._inverseGlobalMatrix
            vLocalFace.normalize();
            m_mxLocal.copyColumnFrom( 2, vLocalFace );

            m_vTemp.setTo( vGlobalUp.x, vGlobalUp.y, vGlobalUp.z );
            var vLocalUp : Vector3D = this._inverseGlobalMatrix.transformVector( m_vTemp ); // m_vTemp * this._inverseGlobalMatrix
            vLocalUp.normalize();
            m_mxLocal.copyColumnFrom( 1, vLocalUp );

            var vLocalRight : Vector3D = vLocalFace.crossProduct( vLocalUp );
            m_mxLocal.copyColumnFrom( 0, vLocalRight );

            _setDirtyFlags( EDirtyFlag.FLAGS_LOCAL_MATRIX_CHANGE_MASKS, true );
        }

        //
        public function get face() : CVector3
        {
            if( _checkDirtyFlags( EDirtyFlag.VECTOR_FLAG_GLOBAL_FACE ) == false ) return m_vGlobalFace;
            _unsetDirtyFlags( EDirtyFlag.VECTOR_FLAG_GLOBAL_FACE );

            if( m_theParent == null )
            {
                if( m_vGlobalFace != this.localFace ) m_vGlobalFace = m_vLocalFace;
            }
            else
            {
                if( m_vGlobalFace == null || m_vGlobalFace == m_vLocalFace ) m_vGlobalFace = new CVector3();

                _globalMatrix.copyColumnTo( 2, m_vTemp );
                m_vGlobalFace.setValueXYZ( m_vTemp.x, m_vTemp.y, m_vTemp.z );
            }
            return m_vGlobalFace;
        }
        public function get up() : CVector3
        {
            if( _checkDirtyFlags( EDirtyFlag.VECTOR_FLAG_GLOBAL_UP ) == false ) return m_vGlobalUp;
            _unsetDirtyFlags( EDirtyFlag.VECTOR_FLAG_GLOBAL_UP );

            if( m_theParent == null )
            {
                if( m_vGlobalUp != this.localUp ) m_vGlobalUp = m_vLocalUp;
            }
            else
            {
                if( m_vGlobalUp == null || m_vGlobalUp == m_vLocalUp ) m_vGlobalUp = new CVector3();

                _globalMatrix.copyColumnTo( 1, m_vTemp );
                m_vGlobalUp.setValueXYZ( m_vTemp.x, m_vTemp.y, m_vTemp.z );
            }
            return m_vGlobalUp;
        }
        public function get right() : CVector3
        {
            if( _checkDirtyFlags( EDirtyFlag.VECTOR_FLAG_GLOBAL_RIGHT ) == false ) return m_vGlobalRight;
            _unsetDirtyFlags( EDirtyFlag.VECTOR_FLAG_GLOBAL_RIGHT );

            if( m_theParent == null )
            {
                if( m_vGlobalRight != this.localRight ) m_vGlobalRight = m_vLocalRight;
            }
            else
            {
                if( m_vGlobalRight == null || m_vGlobalRight == m_vLocalRight ) m_vGlobalRight = new CVector3();

                _globalMatrix.copyColumnTo( 0, m_vTemp );
                m_vGlobalRight.setValueXYZ( -m_vTemp.x, -m_vTemp.y, -m_vTemp.z );
            }
            return m_vGlobalRight;
        }

        //
        //
        public function setLocalPosition( fX : Number, fY : Number, fZ : Number ) : void
        {
            m_vLocalPosition.setValueXYZ( fX, fY, fZ );

            m_vTemp.setTo( fX, fY, fZ );
            m_mxLocal.position = m_vTemp;

            //Foundation.Log.logMsg( "m_iDirtyFlags: " + m_iDirtyFlags.toString( 16 ) );
            _setDirtyFlags( EDirtyFlag.FLAGS_LOCAL_POSITION_CHANGE_MASKS , true );
            //Foundation.Log.logMsg( "m_iDirtyFlags: " + m_iDirtyFlags.toString( 16 ) );
        }
        public function get localPosition() : CVector3
        {
            if( _checkDirtyFlags( EDirtyFlag.VECTOR_FLAG_LOCAL_POSITION ) == false ) return m_vLocalPosition;
            _unsetDirtyFlags( EDirtyFlag.VECTOR_FLAG_LOCAL_POSITION );

            var v : Vector3D = m_mxLocal.position;
            m_vLocalPosition.setValueXYZ( v.x, v.y, v.z );
            return m_vLocalPosition;
        }

        //
        //
        public function get localFace() : CVector3
        {
            if( _checkDirtyFlags( EDirtyFlag.VECTOR_FLAG_LOCAL_FACE ) == false ) return m_vLocalFace;
            _unsetDirtyFlags( EDirtyFlag.VECTOR_FLAG_LOCAL_FACE );

            if( m_vLocalFace == null ) m_vLocalFace = new CVector3();

            m_mxLocal.copyColumnTo( 2, m_vTemp );
            m_vLocalFace.setValueXYZ( m_vTemp.x, m_vTemp.y, m_vTemp.z );
            return m_vLocalFace;
        }
        public function get localUp() : CVector3
        {
            if( _checkDirtyFlags( EDirtyFlag.VECTOR_FLAG_LOCAL_UP ) == false ) return m_vLocalUp;
            _unsetDirtyFlags( EDirtyFlag.VECTOR_FLAG_LOCAL_UP );

            if( m_vLocalUp == null ) m_vLocalUp = new CVector3();

            m_mxLocal.copyColumnTo( 1, m_vTemp );
            m_vLocalUp.setValueXYZ( m_vTemp.x, m_vTemp.y, m_vTemp.z );
            return m_vLocalUp;
        }
        public function get localRight() : CVector3
        {
            if( _checkDirtyFlags( EDirtyFlag.VECTOR_FLAG_LOCAL_RIGHT ) == false ) return m_vLocalRight;
            _unsetDirtyFlags( EDirtyFlag.VECTOR_FLAG_LOCAL_RIGHT );

            if( m_vLocalRight == null ) m_vLocalRight = new CVector3();

            m_mxLocal.copyColumnTo( 0, m_vTemp );
            m_vLocalRight.setValueXYZ( -m_vTemp.x, -m_vTemp.y, -m_vTemp.z );
            return m_vLocalRight;
        }

        //
        //
        public function rotateLocalX( fDeg : Number ) : void
        {
            localRotation.x += fDeg;

            m_mxLocal.appendRotation( -fDeg, Vector3D.X_AXIS ); // rotation * m_mxLocal
            _setDirtyFlags( EDirtyFlag.FLAGS_LOCAL_ROTATION_CHANGE_MASKS, true );
        }
        public function rotateLocalY( fDeg : Number ) : void
        {
            localRotation.y += fDeg;

            m_mxLocal.appendRotation( -fDeg, Vector3D.Y_AXIS ); // rotation * m_mxLocal
            _setDirtyFlags( EDirtyFlag.FLAGS_LOCAL_ROTATION_CHANGE_MASKS, true );
        }
        public function rotateLocalZ( fDeg : Number ) : void
        {
            localRotation.z += fDeg;

            m_mxLocal.appendRotation( -fDeg, Vector3D.Z_AXIS ); // rotation * m_mxLocal
            _setDirtyFlags( EDirtyFlag.FLAGS_LOCAL_ROTATION_CHANGE_MASKS, true );
        }

        //
        //
        public function get localRotation() : CVector3
        {
            if( _checkDirtyFlags( EDirtyFlag.VECTOR_FLAG_LOCAL_ROTATION ) == false ) return m_vLocalRotation;
            _unsetDirtyFlags( EDirtyFlag.VECTOR_FLAG_LOCAL_ROTATION );

            return m_vLocalRotation;
        }
        public function setLocalRotation( fDegX : Number, fDegY : Number, fDegZ : Number ) : void
        {
            var fDegXDiff : Number = fDegX - localRotation.x;
            var fDegYDiff : Number = fDegY - localRotation.y;
            var fDegZDiff : Number = fDegZ - localRotation.z;

            pitch( fDegXDiff );
            yaw( fDegYDiff );
            roll( fDegZDiff );
        }

        public function pitch( fDeg : Number ) : void
        {
            localRotation.x += fDeg;

            m_mxLocal.copyColumnTo( 3, m_vTemp ); // backup position
            m_vTemp2.setTo( 0.0, 0.0, 0.0 );
            m_mxLocal.copyColumnFrom( 3, m_vTemp2 ); // set to original point
            m_mxLocal.appendRotation( -fDeg, Vector3D.X_AXIS ); // rotation * m_mxLocal
            m_mxLocal.copyColumnFrom( 3, m_vTemp ); // restore position

            _setDirtyFlags( EDirtyFlag.FLAGS_SELF_ROTATION_CHANGE_MASKS, true );
        }
        public function yaw( fDeg : Number ) : void
        {
            localRotation.y += fDeg;

            m_mxLocal.copyColumnTo( 3, m_vTemp ); // backup position
            m_vTemp2.setTo( 0.0, 0.0, 0.0 );
            m_mxLocal.copyColumnFrom( 3, m_vTemp2 ); // set to original point
            m_mxLocal.appendRotation( -fDeg, Vector3D.Y_AXIS ); // rotation * m_mxLocal
            m_mxLocal.copyColumnFrom( 3, m_vTemp ); // restore position

            _setDirtyFlags( EDirtyFlag.FLAGS_SELF_ROTATION_CHANGE_MASKS, true );
        }
        public function roll( fDeg : Number ) : void
        {
            localRotation.z += fDeg;

            m_mxLocal.copyColumnTo( 3, m_vTemp ); // backup position
            m_vTemp2.setTo( 0.0, 0.0, 0.0 );
            m_mxLocal.copyColumnFrom( 3, m_vTemp2 ); // set to original point
            m_mxLocal.appendRotation( -fDeg, Vector3D.Z_AXIS ); // rotation * m_mxLocal
            m_mxLocal.copyColumnFrom( 3, m_vTemp ); // restore position

            _setDirtyFlags( EDirtyFlag.FLAGS_SELF_ROTATION_CHANGE_MASKS, true );
        }

        public function get flipX() : Boolean
        {
            return m_bFlipX;
        }
        public virtual function set flipX( bFlip : Boolean ) : void
        {
            m_bFlipX = bFlip;
            _setDirtyFlags( EDirtyFlag.FLAGS_LOCAL_SCALED_CHANGE_MASKS, true );
        }
        public function get flipY() : Boolean
        {
            return m_bFlipY;
        }
        public virtual function set flipY( bFlip : Boolean ) : void
        {
            m_bFlipY = bFlip;
            _setDirtyFlags( EDirtyFlag.FLAGS_LOCAL_SCALED_CHANGE_MASKS, true );
        }
        public function get flipZ() : Boolean
        {
            return m_bFlipZ;
        }
        public virtual function set flipZ( bFlip : Boolean ) : void
        {
            m_bFlipZ = bFlip;
            _setDirtyFlags( EDirtyFlag.FLAGS_LOCAL_SCALED_CHANGE_MASKS, true );
        }

        //
        //
        protected function get _localMatrix() : Matrix3D
        {
            return m_mxLocal;
        }
        protected function get _localScaledMatrix() : Matrix3D
        {
            if( _checkDirtyFlags( EDirtyFlag.MX_FLAG_LOCAL_SCALED ) == false ) return m_mxLocalScaled;
            _unsetDirtyFlags( EDirtyFlag.MX_FLAG_LOCAL_SCALED );

            if( m_mxLocalScaled == m_mxLocal ) return m_mxLocalScaled;
            else
            {
                m_mxLocalScaled.copyFrom( m_mxLocal );

                var fScaleX : Number =  m_vLocalScale.x;
                if( m_bFlipX ) fScaleX = -fScaleX;
                var fScaleY : Number =  m_vLocalScale.y;
                if( m_bFlipY ) fScaleX = -fScaleY;
                var fScaleZ : Number =  m_vLocalScale.z;
                if( m_bFlipZ ) fScaleX = -fScaleZ;

                m_mxLocalScaled.appendScale( fScaleX, fScaleY, fScaleZ ); // scale * m_mxLocalScaled
                return m_mxLocalScaled;
            }
        }

        public function get _globalMatrix() : Matrix3D
        {
            if( _checkDirtyFlags( EDirtyFlag.MX_FLAG_GLOBAL ) == false ) return m_mxGlobal;
            _unsetDirtyFlags( EDirtyFlag.MX_FLAG_GLOBAL );

            if( m_theParent == null )
            {
                if( m_mxGlobal != m_mxLocal ) m_mxGlobal = m_mxLocal;
            }
            else
            {
                if( m_mxGlobal == m_mxLocal ) m_mxGlobal = new Matrix3D();
                m_mxGlobal.copyFrom( m_mxLocal );

                m_mxGlobal.append( m_theParent._globalMatrix ); // m_mxGlobal * m_theParent._globalMatrix
            }
            return m_mxGlobal;
        }
        protected function get _globalScaledMatrix() : Matrix3D
        {
            if( _checkDirtyFlags( EDirtyFlag.MX_FLAG_GLOBAL_SCALED ) == false ) return m_mxGlobalScaled;
            _unsetDirtyFlags( EDirtyFlag.MX_FLAG_GLOBAL_SCALED );

            if( m_theParent == null )
            {
                if( m_mxGlobalScaled != m_mxLocalScaled ) m_mxGlobalScaled = m_mxLocalScaled;
            }
            else
            {
                if( m_mxGlobalScaled == m_mxLocalScaled ) m_mxGlobalScaled = new Matrix3D();
                m_mxGlobalScaled.copyFrom( this._localScaledMatrix );
                m_mxGlobalScaled.append( m_theParent._globalScaledMatrix ); // m_mxGlobalScaled * m_theParent._globalScaledMatrix
            }
            return m_mxGlobalScaled;
        }

        protected function get _inverseLocalMatrix() : Matrix3D
        {
            if( _checkDirtyFlags( EDirtyFlag.MX_FLAG_INVERSE_LOCAL ) == false ) return m_mxInverseLocal;
            _unsetDirtyFlags( EDirtyFlag.MX_FLAG_INVERSE_LOCAL );

            if( m_mxInverseLocal == null ) m_mxInverseLocal = new Matrix3D();
            m_mxInverseLocal.copyFrom( m_mxLocal );
            m_mxInverseLocal.invert();
            return m_mxInverseLocal;
        }
        protected function get _inverseLocalScaledMatrix() : Matrix3D
        {
            if( _checkDirtyFlags( EDirtyFlag.MX_FLAG_INVERSE_LOCAL_SCALED ) == false ) return m_mxInverseLocalScaled;
            _unsetDirtyFlags( EDirtyFlag.MX_FLAG_INVERSE_LOCAL_SCALED );

            if( m_mxLocalScaled == m_mxLocal ) m_mxInverseLocalScaled = this._inverseLocalMatrix;
            else
            {
                if( m_mxInverseLocalScaled == null || m_mxInverseLocalScaled == m_mxInverseLocal ) m_mxInverseLocalScaled = new Matrix3D();
                m_mxInverseLocalScaled.copyFrom( this._localScaledMatrix );
                m_mxInverseLocalScaled.invert();
            }
            return m_mxInverseLocalScaled;
        }

        protected function get _inverseGlobalMatrix() : Matrix3D
        {
            if( _checkDirtyFlags( EDirtyFlag.MX_FLAG_INVERSE_GLOBAL ) == false ) return m_mxInverseGlobal;
            _unsetDirtyFlags( EDirtyFlag.MX_FLAG_INVERSE_GLOBAL );

            if( m_theParent == null )
            {
                if( m_mxInverseGlobal != this._inverseLocalMatrix ) m_mxInverseGlobal = m_mxInverseLocal;
            }
            else
            {
                if( m_mxInverseGlobal == null || m_mxInverseGlobal == m_mxInverseLocal ) m_mxInverseGlobal = new Matrix3D();
                m_mxInverseGlobal.copyFrom( this._globalMatrix );
                m_mxInverseGlobal.invert();
            }
            return m_mxInverseGlobal;
        }
        protected function get _inverseGlobalScaledMatrix() : Matrix3D
        {
            if( _checkDirtyFlags( EDirtyFlag.MX_FLAG_INVERSE_GLOBAL_SCALED ) == false ) return m_mxInverseGlobalScaled;
            _unsetDirtyFlags( EDirtyFlag.MX_FLAG_INVERSE_GLOBAL_SCALED );

            if( m_theParent == null )
            {
                if( m_mxInverseGlobalScaled != this._inverseLocalScaledMatrix ) m_mxInverseGlobalScaled = m_mxInverseLocalScaled;
            }
            else
            {
                if( m_mxInverseGlobalScaled == null || m_mxInverseGlobalScaled == m_mxInverseLocalScaled ) m_mxInverseGlobalScaled = new Matrix3D();
                m_mxInverseGlobalScaled.copyFrom( this._globalScaledMatrix );
                m_mxInverseGlobalScaled.invert();
            }
            return m_mxInverseGlobalScaled;
        }

        //
        //
        protected function _addChild( theNode : CNode, bSetItsParent : Boolean ) : void
        {
            m_setChildren.add( theNode );
            if( bSetItsParent ) theNode.m_theParent = this;
        }
        protected function _removeChild( theNode : CNode, bRemoveItsParent : Boolean ) : void
        {
            m_setChildren.remove( theNode );
            if( bRemoveItsParent ) theNode.m_theParent = null;
        }

        protected function _setDirtyFlags( iMask : int, bSetChildren : Boolean ) : void
        {
            m_iDirtyFlags = m_iDirtyFlags | iMask;
            if( bSetChildren && m_setChildren.count > 0 )
            {
                var iFlag : int = iMask & ~EDirtyFlag.FLAGS_NO_MATTER_TO_CHILDREN_MASKS;
                for( var node : CNode in m_setChildren )
                {
                    node._setDirtyFlags( iFlag, bSetChildren );
                }
            }
        }

        [Inline]
        final protected function _unsetDirtyFlags( iMask : int ) : void
        {
            m_iDirtyFlags = m_iDirtyFlags & ~iMask;
        }

        [Inline]
        final protected function _checkDirtyFlags( iMask : int ) : Boolean
        {
            if( ( m_iDirtyFlags & iMask ) != 0 ) return true;
            else return false;
        }

        //
        //
        // Hierarchy
        protected var m_setChildren : CSet = new CSet();
        protected var m_theParent : CNode = null;
        protected var m_eParentMode : int = EParentMode.PARENT_NORMAL;

        // matrix
        private var m_mxLocal : Matrix3D = new Matrix3D();
        private var m_mxLocalScaled : Matrix3D = m_mxLocal;
        private var m_mxGlobal : Matrix3D = m_mxLocal;
        private var m_mxGlobalScaled : Matrix3D = m_mxLocalScaled;
        private var m_mxInverseLocal : Matrix3D = null;
        private var m_mxInverseLocalScaled : Matrix3D = null;
        private var m_mxInverseGlobal : Matrix3D = null;
        private var m_mxInverseGlobalScaled : Matrix3D = null;

        private var m_vLocalPosition : CVector3 = new CVector3( 0.0, 0.0, 0.0 );
        private var m_vGlobalPosition : CVector3 = m_vLocalPosition;
        private var m_vLocalScale : CVector3 = new CVector3( 1.0, 1.0, 1.0 );
        private var m_vGlobalScale : CVector3 = m_vLocalScale;
        private var m_vLocalRotation : CVector3 = new CVector3( 0.0, 0.0, 0.0 );

        private var m_vLocalFace : CVector3 = null;
        private var m_vLocalUp : CVector3 = null;
        private var m_vLocalRight : CVector3 = null;
        private var m_vGlobalFace : CVector3 = null;
        private var m_vGlobalUp : CVector3 = null;
        private var m_vGlobalRight : CVector3 = null;

        private var m_vTemp : Vector3D = new Vector3D();
        private var m_vTemp2 : Vector3D = new Vector3D();
        public var m_iDirtyFlags : int = EDirtyFlag.FLAGS_MASKS_ALL;

        private var m_bFlipX : Boolean = false;
        private var m_bFlipY : Boolean = false;
        private var m_bFlipZ : Boolean = false;
    }

}

