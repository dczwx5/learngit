/**
 * Created by user on 2015/6/1.
 */
package QFLib.Graphics.RenderCore.starling.utils
{
    import flash.utils.Dictionary;

    /**
     * Creates a wek reference to an object
     */
    public class WeakRef
    {
        private var dic : Dictionary;

        /**
         * The constructor - creates a weak reference.
         *
         * @param obj the object to create a weak reference to
         */
        public function WeakRef( obj : * )
        {
            dic = new Dictionary( true );
            dic[obj] = 1;
        }

        /**
         * To get a strong reference to the object.
         *
         * @return a strong reference to the object or null if the
         * object has been garbage collected
         */
        public function get() : *
        {
            for ( var item:* in dic )
            {
                return item;
            }
            return null;
        }
    }
}
