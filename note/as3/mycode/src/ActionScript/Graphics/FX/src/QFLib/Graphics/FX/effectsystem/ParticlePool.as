//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by David on 2016/10/19.
 */
package QFLib.Graphics.FX.effectsystem
{
public class ParticlePool
    {
        private var particleList:Vector.<Particle>;

        public static function getInstance () : ParticlePool
        {
            return SingletonHolder.instance ();
        }

        public function ParticlePool ()
        {
            particleList = new Vector.<Particle>();
        }

        public function pop() : Particle
        {
            if(particleList.length > 0)
            {
                return particleList.pop();
            }
            else
            {
                return new Particle();
            }
        }

        public function push( particle:Particle ) : void
        {
            particleList.push(particle);
        }

        public function get count() : int
        {
            return particleList.length;
        }

        public function clear () : void
        {
            particleList.length = 0;
        }
    }
}

import QFLib.Graphics.FX.effectsystem.ParticlePool;

class SingletonHolder
{
    private static var _instance : ParticlePool = new ParticlePool ();

    public static function instance () : ParticlePool { return _instance; }
}
