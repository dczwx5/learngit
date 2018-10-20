//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/7/4
//----------------------------------------------------------------------------------------------------------------------


package QFLib.Node
{
    //
    //
    public class EDirtyFlag
    {
        public static const FLAGS_MATTER_TO_CHILDREN_MASKS : uint       = 0x00000FFF;
        public static const FLAGS_NO_MATTER_TO_CHILDREN_MASKS : uint    = 0x000FF000;
        public static const FLAGS_MASKS_ALL : uint = FLAGS_MATTER_TO_CHILDREN_MASKS | FLAGS_NO_MATTER_TO_CHILDREN_MASKS;

        // flags that will effect to children
        public static const MX_FLAG_GLOBAL : uint                       = 0x00000001;
        public static const MX_FLAG_GLOBAL_SCALED : uint                = 0x00000002;
        public static const MX_FLAG_INVERSE_LOCAL_SCALED : uint         = 0x00000004;
        public static const MX_FLAG_INVERSE_GLOBAL : uint               = 0x00000008;
        public static const MX_FLAG_INVERSE_GLOBAL_SCALED : uint        = 0x00000010;
        public static const MX_FLAG_UPDATED : uint                      = 0x00000020;
        public static const VECTOR_FLAG_GLOBAL_POSITION : uint          = 0x00000040;
        public static const VECTOR_FLAG_GLOBAL_SCALE : uint             = 0x00000080;
        public static const VECTOR_FLAG_GLOBAL_FACE : uint              = 0x00000100;
        public static const VECTOR_FLAG_GLOBAL_UP : uint                = 0x00000200;
        public static const VECTOR_FLAG_GLOBAL_RIGHT : uint             = 0x00000400;

        // flags that have no effect to children when parent flags dirty
        public static const MX_FLAG_LOCAL_SCALED : uint                 = 0x00001000;
        public static const MX_FLAG_INVERSE_LOCAL : uint                = 0x00002000;
        public static const VECTOR_FLAG_LOCAL_POSITION : uint           = 0x00004000;
        public static const VECTOR_FLAG_LOCAL_FACE : uint               = 0x00008000;
        public static const VECTOR_FLAG_LOCAL_UP : uint                 = 0x00010000;
        public static const VECTOR_FLAG_LOCAL_RIGHT : uint              = 0x00020000;
        public static const VECTOR_FLAG_LOCAL_ROTATION : uint           = 0x00040000;

        // flags combination of something changed
        public static const FLAGS_LOCAL_SCALED_CHANGE_MASKS : uint = MX_FLAG_LOCAL_SCALED | MX_FLAG_GLOBAL_SCALED | MX_FLAG_INVERSE_LOCAL_SCALED | MX_FLAG_INVERSE_GLOBAL_SCALED | VECTOR_FLAG_GLOBAL_SCALE | MX_FLAG_UPDATED;
        public static const FLAGS_LOCAL_MATRIX_CHANGE_MASKS : uint = FLAGS_MASKS_ALL & ~VECTOR_FLAG_GLOBAL_SCALE;
        public static const FLAGS_LOCAL_POSITION_CHANGE_MASKS : uint = FLAGS_LOCAL_MATRIX_CHANGE_MASKS & ~VECTOR_FLAG_LOCAL_POSITION;
        public static const FLAGS_LOCAL_ROTATION_CHANGE_MASKS : uint = FLAGS_LOCAL_MATRIX_CHANGE_MASKS & ~VECTOR_FLAG_LOCAL_ROTATION;
        public static const FLAGS_SELF_ROTATION_CHANGE_MASKS : uint = FLAGS_LOCAL_MATRIX_CHANGE_MASKS & ~VECTOR_FLAG_LOCAL_ROTATION & ~VECTOR_FLAG_LOCAL_POSITION & ~VECTOR_FLAG_GLOBAL_POSITION;

    }

}

