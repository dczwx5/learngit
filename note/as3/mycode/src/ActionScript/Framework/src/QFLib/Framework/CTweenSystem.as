//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/8/29
//----------------------------------------------------------------------------------------------------------------------

/*
    this class can be used to arrange the tasks / functions for a host object
*/

package QFLib.Framework
{

import QFLib.Foundation;
    import QFLib.Foundation.CMap;
    import QFLib.Framework.CTweener;
    import QFLib.Memory.CSmartObject;

import flash.events.TimerEvent;
import flash.utils.Timer;

//
    //
    //
    public class CTweenSystem extends CSmartObject
    {
        public function CTweenSystem()
        {
        }
        
        public override function dispose() : void
        {
            super.dispose();

            for each( var tweener : CTweener in m_mapTweeners )
            {
                tweener.dispose();
            }
        }
        
        public function addSequentialTweener( theHost : Object, fn : Function, ...args ) : CTweener
        {
            var tweener : CTweener = m_mapTweeners.find( theHost );
            if( tweener == null )
            {
                tweener = new CTweener( theHost );
                m_mapTweeners.add( theHost, tweener );
            }

            tweener.addSequentialProcedure( fn, args );
            return tweener;
        }
        
        public function addParallelTweener( theHost : Object, fn : Function, ...args ) : CTweener
        {
            var tweener : CTweener = m_mapTweeners.find( theHost );
            if( tweener == null )
            {
                tweener = new CTweener( theHost );
                m_mapTweeners.add( theHost, tweener );
            }

            tweener.addParallelProcedure( fn, args );
            return tweener;
        }

        public function clearAll() : void
        {
            for each( var tweener : CTweener in m_mapTweeners )
            {
                tweener.clearAll();
            }
        }

        public function update( fDeltaTime : Number ) : void
        {
            var tweener : CTweener;
            for each( tweener in m_mapTweeners )
            {
                tweener.update( fDeltaTime );
                if( tweener.numSequentialProcedures == 0 ) m_vFinishedTweeners.push( tweener );
            }

            for each( tweener in m_vFinishedTweeners )
            {
                m_mapTweeners.remove( tweener.host );
                tweener.dispose();
            }
            m_vFinishedTweeners.length = 0;
        }


        //
        //
        private var m_mapTweeners : CMap = new CMap();
        private var m_vFinishedTweeners : Vector.<CTweener> = new Vector.<CTweener>();
    }

}

